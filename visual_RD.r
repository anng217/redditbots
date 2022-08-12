# Packages ----
library(tidyverse)
library(dplyr)
library(ggplot2)
library(fixest)
library(rdd)

# Routine ----
rm(list = ls())

# Load data ----
df <- read.csv("E:/gihub-data/redditbots/fds/fds_res.csv")

df$date <-  as.Date(df$created_utc, "%Y-%m-%d")

df$relative_day <- difftime(df$date,as.Date('2019-10-28', "%Y-%m-%d"), units = "days")

df$post <- ifelse(df$relative_day <0, 0, 1)

df$relative_day <- as.numeric(df$relative_day)

## Try to run RDD with package rdd but was not successful
bw <- with(df, IKbandwidth(relative_day, toxicity))

rdd_simple <- RDestimate(toxicity ~ relative_day, bw = optbw, data = df, kernel = "triangular")


##########################################
## Code Replicate - Calculate Bandwidth ## ----
#########################################

X <- df$relative_day
Y <- df$toxicity
cutpoint <-  -0.5
sub<-complete.cases(X)&complete.cases(Y)
X <- X[sub]
Y <- Y[sub]
Nx<-length(X)
Ny<-length(Y)

#Pilot bandwidth
h1<-1.84*sd(X)*Nx^(-1/5)
left<- X>=(cutpoint-h1) & X<=cutpoint
right<- X>cutpoint & X<=(cutpoint+h1)
Nl<-sum(left)
Nr<-sum(right)
Ybarl<-mean(Y[left])
Ybarr<-mean(Y[right])
fbarx<-(Nl+Nr)/(2*Nx*h1)
varY<-(sum((Y[left]-Ybarl)^2)+sum((Y[right]-Ybarr)^2))/(Nl+Nr)
medXl<-median(X[X<=cutpoint])
medXr<-median(X[X>cutpoint])
Nl<-sum(X<cutpoint)
Nr<-sum(X>=cutpoint)
cX<-X-cutpoint
if(sum(X[left]>medXl)==0 | sum(X[right]<medXr)==0)
  stop("Insufficient data in vicinity of the cutpoint to calculate bandwidth.")
#Model a cubic within the pilot bandwidth
df_poly <- as.data.frame(cbind(X,Y))
mod<-lm(Y~I(X>=cutpoint)+poly(cX,3,raw=T),subset =(X>=medXl&X<=medXr) ,data= df_poly)
m3<-6*coef(mod)[5]
#New bandwidth estimate
h2l<-3.56*(Nl^(-1/7))*(varY/(fbarx*max(m3^2,0.01)))^(1/7)
h2r<-3.56*(Nr^(-1/7))*(varY/(fbarx*max(m3^2,0.01)))^(1/7)
left<-(X>=(cutpoint-h2l)) & (X<cutpoint)
right<-(X>=cutpoint) & (X<= (cutpoint+h2r))
Nl<-sum(left)
Nr<-sum(right)
if(Nl==0 | Nr==0)
  stop("Insufficient data in vicinity of the cutpoint to calculate bandwidth.")
#Estimate quadratics for curvature estimation
mod<-lm(Y~poly(cX,2,raw=T),subset=right)
m2r<-2*coef(mod)[3]
mod<-lm(Y~poly(cX,2,raw=T),subset=left)
m2l<-2*coef(mod)[3]
rl<-720*varY/(Nl*(h2l^4))
rr<-720*varY/(Nr*(h2r^4))
#Which kernel are we using?
ck <- 3.43754
#And there's our optimal bandwidth
optbw<-ck*(2*varY/(fbarx*((m2r-m2l)^2+rr+rl)))^(1/5)*(Nx^(-1/5))
left <-(X>=(cutpoint-optbw)) & (X<cutpoint)
right<-(X>=cutpoint) & (X<= (cutpoint+optbw))
if(sum(left)==0 | sum(right)==0)
  stop("Insufficient data in the calculated bandwidth.")
names(optbw)<-NULL
if(verbose) cat("Imbens-Kalyanamaran Optimal Bandwidth: ",sprintf("%.3f",optbw),"\n")
return(optbw)

#############################################
## End Code Replicate - Calculate Bandwidth## ---- 
############################################


###########################################
##Start of Code Replicate - Calculate RDD# ---- 
#########################################
data  <- df
formula <- toxicity ~ relative_day
subset <- NULL
cluster <- NULL
cutpoint <- NULL
bw <- optbw
kernel <- "triangular"
se.type <- "HC1"
cluster <- NULL
verbose <- FALSE
model <- FALSE
frame <- FALSE

call<-match.call()
if(missing(data)) data<-environment(formula)
formula<-as.Formula(formula)

X <- model.frame(formula,rhs=1,lhs=0,data=data,na.action=na.pass)[[1]]
Y <- model.frame(formula,rhs=0,lhs=NULL,data=data,na.action=na.pass)[[1]]

if(!is.null(subset)){
  X <- X[subset]
  Y <- Y[subset]
  if(!is.null(cluster)) cluster<-cluster[subset]
}

if (!is.null(cluster)) {
  cluster <- as.character(cluster)
  robust.se <- function(model, cluster){
    M <- length(unique(cluster))
    N <- length(cluster)           
    K <- model$rank
    dfc <- (M/(M - 1)) * ((N - 1)/(N - K))
    uj  <- apply(estfun(model), 2, function(x) tapply(x, cluster, sum));
    rcse.cov <- dfc * sandwich(model, meat. = crossprod(uj)/N)
    rcse.se <- coeftest(model, rcse.cov)
    return(rcse.se[2,2])
  }
}

na.ok<-complete.cases(X)&complete.cases(Y)
if(length(all.vars(formula(formula,rhs=1,lhs=F)))>1){
  type<-"fuzzy" 
  Z<-model.frame(formula,rhs=1,lhs=0,data=data,na.action=na.pass)[[2]]
  if(!is.null(subset)) Z<-Z[subset]
  na.ok<-na.ok&complete.cases(Z)
  if(length(all.vars(formula(formula,rhs=1,lhs=F)))>2)
    stop("Invalid formula. Read ?RDestimate for proper syntax")
} else {
  type="sharp" 
}

covs<-NULL

if(length(formula)[2]>1){
  covs<-model.frame(formula,rhs=2,lhs=0,data=data,na.action=na.pass)
  if(!is.null(subset)) covs<-subset(covs,subset)
  na.ok<-na.ok&complete.cases(covs)
  covs<-subset(covs,na.ok)
}

X<-X[na.ok]
Y<-Y[na.ok]
if(type=="fuzzy") Z<-as.double(Z[na.ok])

if(is.null(cutpoint)) {
  cutpoint<-0
  if(verbose) cat("No cutpoint provided. Using default cutpoint of zero.\n")
}

if(frame) {
  if(type=="sharp") {
    if (!is.null(covs))
      dat.out<-data.frame(X,Y,covs)
    else
      dat.out<-data.frame(X,Y)
  } else {
    if (!is.null(covs))
      dat.out<-data.frame(X,Y,Z,covs)
    else
      dat.out<-data.frame(X,Y,Z)
  }
}

if(is.null(bw)) {
  bw<-IKbandwidth(X=X,Y=Y,cutpoint=cutpoint,kernel=kernel, verbose=verbose)
  bws<-c(bw,.5*bw,2*bw)
  names(bws)<-c("LATE","Half-BW","Double-BW")
} else if (length(bw)==1) {
  bws<-c(bw,.5*bw,2*bw)
  names(bws)<-c("LATE","Half-BW","Double-BW")
} else {
  bws<-bw
}

#Setup values to be returned
o <- list()
o$type <- type
o$call <- call
o$est <- vector(length=length(bws),mode="numeric")
names(o$est) <- names(bws)
o$bw <- as.vector(bws)
o$se <- vector(mode="numeric")
o$z <- vector(mode="numeric")
o$p <- vector(mode="numeric")
o$obs <- vector(mode="numeric")
o$ci <- matrix(NA,nrow=length(bws),ncol=2)
o$model <- list()
if(type=="fuzzy") {
  o$model$firststage<-list()
  o$model$iv<-list()
}
o$frame <- list()
o$na.action <- which(na.ok==FALSE)
class(o) <- "RD"
X <- X-cutpoint
Xl <- (X<0)*X
Xr <- (X>=0)*X
Tr <- as.integer(X>=0)

# for(bw in bws){ ##Temp comment out
  bw <- bws[1]
  ibw <- which(bw==bws)
  #Subset to within the bandwidth, except for when using gaussian weighting
  sub<- X >= (-bw) & X <= (+bw)
  
  if(kernel == "gaussian") 
    sub <- TRUE
  
  w <- kernelwts(X,0,bw,kernel=kernel)
  o$obs[ibw] <- sum(w>0)
  
  if(type == "sharp"){
    if(verbose) {
      cat("Running Sharp RD\n")
      cat("Running variable:",all.vars(formula(formula,rhs=1,lhs=F))[1],"\n")
      cat("Outcome variable:",all.vars(formula(formula,rhs=F,lhs=1))[1],"\n")
      if(!is.null(covs)) cat("Covariates:",paste(names(covs),collapse=", "),"\n")
    }
    if(!is.null(covs)) {
      data <- data.frame(Y,Tr,Xl,Xr,covs,w)
      form <- as.formula(paste("Y~Tr+Xl+Xr+",paste(names(covs),collapse="+",sep=""),sep=""))
    } else {
      data <- data.frame(Y,Tr,Xl,Xr,w)
      form <- as.formula(Y~Tr+Xl+Xr)
    }
    
    mod <- lm(form,weights=w,data=subset(data,w>0))
    if(verbose==TRUE) {
      cat("Model:\n")
      print(summary(mod))
    }    
    if(verbose==TRUE) {
      cat("Model:\n")
      print(summary(mod))
    }
    o$est[ibw] <- coef(mod)["Tr"]
    if (is.null(cluster)) {
      o$se[ibw] <- coeftest(mod,vcovHC(mod,type=se.type))[2,2]
    } else {
      o$se[ibw] <- robust.se(mod,cluster[na.ok][w>0])
    }
    o$z[ibw]<-o$est[ibw]/o$se[ibw]
    o$p[ibw]<-2*pnorm(abs(o$z[ibw]),lower.tail=F)
    o$ci[ibw,]<-c(o$est[ibw]-qnorm(.975)*o$se[ibw],o$est[ibw]+qnorm(.975)*o$se[ibw])
    
    if(model) o$model[[ibw]]=mod
    if(frame) o$frame[[ibw]]=dat.out
    
  } else {
    if(verbose){
      cat("Running Fuzzy RD\n")
      #CLEAN UP
      cat("Running variable:",all.vars(formula(formula,rhs=1,lhs=F))[1],"\n")
      cat("Outcome variable:",all.vars(formula(formula,rhs=F,lhs=1))[1],"\n")
      cat("Treatment variable:",all.vars(formula(formula,rhs=1,lhs=F))[2],"\n")
      if(!is.null(covs)) cat("Covariates:",paste(names(covs),collapse=", "),"\n")
    }
    
    if(!is.null(covs)) {
      data<-data.frame(Y,Tr,Xl,Xr,Z,covs,w)
      form<-as.Formula(paste(
        "Y~Z+Xl+Xr+",paste(names(covs),collapse="+"),
        "|Tr+Xl+Xr+",paste(names(covs),collapse="+"),sep=""))
      form1<-as.Formula(paste("Z~Tr+Xl+Xr+",paste(names(covs),collapse="+",sep="")))
    } else {
      data<-data.frame(Y,Tr,Xl,Xr,Z,w)
      form<-as.Formula(Y~Z+Xl+Xr|Tr+Xl+Xr)
      form1<-as.formula(Z~Tr+Xl+Xr)
    }
    
    mod1<-lm(form1,weights=w,data=subset(data,w>0))
    mod<-ivreg(form,weights=w,data=subset(data,w>0))
    if(verbose==TRUE) {
      cat("First stage:\n")
      print(summary(mod1))
      cat("IV-RD:\n")
      print(summary(mod))
    }
    o$est[ibw]<-coef(mod)["Z"]
    if (is.null(cluster)) {
      o$se[ibw]<-coeftest(mod,vcovHC(mod,type=se.type))[2,2]
    } else {
      o$se[ibw]<-robust.se(mod,cluster[na.ok][w>0])
    }
    o$z[ibw]<-o$est[ibw]/o$se[ibw]
    o$p[ibw]<-2*pnorm(abs(o$z[ibw]),lower.tail=F)
    o$ci[ibw,]<-c(o$est[ibw]-qnorm(.975)*o$se[ibw],o$est[ibw]+qnorm(.975)*o$se[ibw])
    
    if(model) {
      o$model$firststage[[ibw]]<-mod1
      o$model$iv[[ibw]]=mod
    }
    if(frame) o$frame=dat.out
  }

###########################################
## End of Code Replicate - Calculate RDD## ---- 
#########################################

# Visualization with rdd
plot_rdd_date <- function(data, y, duration, ylab) {
  data <- data %>% group_by(data$date) %>%
    summarise(y = mean(y), relative_day = relative_day, date = date) %>%
    filter(relative_day > duration & relative_day < duration) %>%
    select(y, relative_day) %>%
    mutate(threshold = as.factor(ifelse(relative_day >= 0, 1, 0)))
  
  data %>% ggplot(aes(x = relative_day, y = y, color = threshold)) +
    geom_point() +
    geom_smooth(method = 'lm',se = T) +
    scale_color_brewer(palette = "Accent") +
    guides(color = FALSE) +
    geom_vline(xintercept = -0.5, color = "red",
               size = 1, linetype = "dashed") +
    labs(y = ylab,
         x = "Days Since Treatment",
         title ='Discontinuity in Toxicity') + 
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black"))
  return (data)
}

  
df %>% group_by(date) %>%
  summarise(toxicity= mean(toxicity), relative_day = relative_day) %>%
  filter(relative_day > -16 & relative_day < 16) %>%
  select(toxicity, relative_day) %>%
  mutate(threshold = as.factor(ifelse(relative_day >= 0, 1, 0))) %>%
  ggplot(aes(x = relative_day, y = toxicity, color = threshold)) +
  geom_point() +
  geom_smooth(method = 'lm',se = T) +
  scale_color_brewer(palette = "Accent") +
  guides(color = FALSE) +
  geom_vline(xintercept = -0.5, color = "red",
             size = 1, linetype = "dashed") +
  labs(y = "Toxicity Score",
       x = "Days Since Treatment",
       title ='Discontinuity in Toxicity') + 
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black"))


