#common procedure
rm(list=ls())

#Checking messy library
.libPaths()
.libPaths(.libPaths()[2])

# Libraries
library(data.table)
library(dplyr)
library(ggplot2)
library(tidyverse)
library(RColorBrewer)
library(viridis)
library(sqldf) 
library(plotly)
library(viridis)
library(paletteer)
library(reshape2)
library(lubridate)
library(CausalImpact)

# Working directory
setwd('E:/github/redditbots')
getwd()

#Load data
fds_subm <- read_csv('E:/github/redditbots/data/fds/fds_subm.csv')

fm_post <- read_csv('E:/github/redditbots/data/control-fds/feminism_unb_post_res.csv')
fm_pre <- read_csv('E:/github/redditbots/data/control-fds/feminism_unb_pre_res.csv')

fds_pre <- read_csv('E:/github/redditbots/data/fds/fds_unb_pre_res.csv')
fds_post <- read_csv('E:/github/redditbots/data/fds/fds_unb_post_res.csv')

twoX_pre <- read_csv('E:/github/redditbots/data/control-fds/twoX_unb_pre_res.csv') 
twoX_post <- read_csv('E:/github/redditbots/data/control-fds/twoX_unb_post_res.csv')

wvsp_pre <- read_csv('E:/github/redditbots/data/control-fds/wvsp_unb_pre_res.csv')
wvsp_post <- read_csv('E:/github/redditbots/data/control-fds/wvsp_unb_post_res.csv')

#Take subscriber info
#Function
subscriber_num <- function(source_dir){
  df <- read_csv(source_dir)
  df <- df %>% 
    select(c('created_utc','subreddit_subscribers')) %>% 
    mutate(time = as_date(lubridate::as_datetime(created_utc))) %>%
    group_by(time)%>%
    summarise(max = max(subreddit_subscribers)) %>%
    filter(time >= as.Date('2019-09-28') & time <= as.Date('2019-11-27'))
  names(df)[2] <- 'subscriber'
  return(df)
}
  
fds_subsc <- subscriber_num('E:/github/redditbots/data/fds/fds_subm.csv')
fm_subsc <- subscriber_num('E:/github/redditbots/data/fds/fds_subm.csv') #Dont run need to update. Data is not there


#control groups
#Function
clean <- function(df,post) {
  df <- df%>%
    mutate(time = as_date(lubridate::as_datetime(created_utc))) %>%
    group_by(time) %>%
    summarise(toxicity_m = mean(toxicity), severe_toxicity_m = mean(severe_toxicity), obscene_m = mean(obscene),
              identity_attack_m = mean(identity_attack), insult_m = mean(insult), threat_m = mean(threat),
              sexual_explicit_m = mean(sexual_explicit),
              toxicity_p = mean(toxicity_flag), severe_toxicity_p = mean(severe_toxicity_flag), 
              obscene_p = mean(obscene_flag), identity_attack_p = mean(identity_attack_flag), insult_p = mean(insult_flag), 
              threat_p = mean(threat_flag), sexual_explicit_p = mean(sexual_explicit_flag)) %>%
    mutate(post = post)
  return(df) #this can be further optimized
}

#Apply function clean
fds_pre_cleaned <- clean(fds_pre, post = 0)
fds_post_cleaned <- clean(fds_post, post = 1)
fds_df <- rbind(fds_pre_cleaned, fds_post_cleaned)[-31,] #Do something about this

fm_pre_clean <- clean(fm_pre, post = 0)
fm_post_clean <- clean(fm_post, post = 1)
fm_df <- rbind(fm_pre_clean,fm_post_clean)[-31,] 

twoX_pre_clean <- clean(twoX_pre, post = 0)
twoX_post_clean <- clean(twoX_post, post = 1)
twoX <- rbind(twoX_pre_clean, twoX_post_clean)[-31,]

wvsp_pre_clean <- clean(wvsp_pre,post=0)
wvsp_post_clean <- clean(wvsp_post,post=1)
wvsp <- rbind(wvsp_pre_clean, wvsp_post_clean)[-31,]


#identity attack
test <- cbind(fds_df['identity_attack_m'],fds_subsc['subscriber'],fm_df['identity_attack_m'],twoX['identity_attack_m'],wvsp['identity_attack_m'])


test <- cbind(fds_df['identity_attack_p'],fds_subsc['subscriber'],fm_df['identity_attack_p'],
              twoX['identity_attack_p'],wvsp['identity_attack_p'])

names(test)[1] <- 'Y'
names(test)[3] <- 'feminism'
names(test)[4] <- 'twoX'
names(test)[5] <- 'wvsp'



pre.period <- c(1, 30)
post.period <- c(31, 61)

impact <- CausalImpact(test, pre.period, post.period,  model.args = list(niter = 5000, nseasons = 7))
