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
setwd("E:/github/redditbots")
getwd()

#Function: Take subscriber info
subscriber_num <- function(source_dir, from_date, to_date) {
  df <- read_csv(source_dir)
  df <- df %>%
    dplyr::select(created_utc, subreddit_subscribers)%>% 
    mutate(time = as_date(lubridate::as_datetime(created_utc))) %>%
    group_by(time)%>%
    summarise(max = max(subreddit_subscribers)) %>%
    filter(time >= as.Date(from_date) & time <= as.Date(to_date))
    #from = "2019-09-28", to = "2019-11-27"
  names(df)[2] <- "subscriber"
  return(df)
}

#Function: Clean data for BSTS
clean <- function(source_dir) {
  df <- read_csv(source_dir)
  df <- df %>%
    mutate(time = as_date(lubridate::as_datetime(created_utc))) %>%
    group_by(time) %>%
    summarise(toxicity = mean(toxicity),
    severe_toxicity = mean(severe_toxicity),
    obscene = mean(obscene),
    identity_attack = mean(identity_attack),
    insult = mean(insult), threat = mean(threat),
    #sexual_explicit_m = mean(sexual_explicit),
    toxicity_p = mean(toxicity_flag),
    severe_toxicity_p = mean(severe_toxicity_flag),
    obscene_p = mean(obscene_flag),
    identity_attack_p = mean(identity_attack_flag),
    insult_p = mean(insult_flag),
    #exual_explicit_p = mean(sexual_explicit_flag),
    threat_p = mean(threat_flag)) #%>%
    #mutate(post = post)
  return(df)
}

#Function: Cross users
cross_users <- function(source_dir1, df1_name source_dir2, df2_name) {
  df1 <- read_csv(source_dir1)
  df2 <- read_csv(source_dir2)
  df1 %>% group_by(author) %>%
    summarise(num_coms = n())
  df2 %>% group_by(author) %>%
    summarise(num_coms = n())
  df <- left_join(df1, df2, by = author, suffix = c(df1_name, df2_name))
  return (df)
}

# Data Cleaning
fds_df <- clean("E:/github/redditbots/data/fds/fds_res.csv")
fm_df <- clean("E:/github/redditbots/data/control-fds/feminism_res.csv")
twoX_df <- clean("E:/github/redditbots/data/control-fds/twoX_res.csv")
wvsp_df <- clean("E:/github/redditbots/data/control-fds/wvsp_res.csv") 
mgtow <- clean("E:/github/redditbots/data/control-fds/wvsp_res.csv")

#Take subscribers
fds_subsc <- subscriber_num(source_dir = "E:/github/redditbots/data/fds/fds_subm.csv", from_date = "2019-09-28" , to_date  = "2019-11-27") 

fm_subsc <- subscriber_num(source_dir = "E:/github/redditbots/data/control-fds/ feminism_subsc.csv", from_date = "2019-09-28" , to_date  = "2019-11-27")

twoX_subsc <- subscriber_num(source_dir = "E:/github/redditbots/data/control-fds/twoX_subsc.csv", from_date = "2019-09-28" , to_date  = "2019-11-27") #no lint

wvsp_subsc <- subscriber_num(source_dir = "E:/github/redditbots/data/control-fds/wvsp_subsc.csv", from_date = "2019-09-28" , to_date  = "2019-11-27") #no lint

#Set pre-post periof
pre_period <- c(1, 30)
post_period <- c(31, 61)

#identity attack: No witches vs patriarchy
identity_attack_m <- cbind(fds_df["identity_attack"],fds_subsc["subscriber"],
fm_df["identity_attack"], fm_subsc["subscriber"],
twoX_df["identity_attack"], twoX_subsc["subscriber"])

names(identity_attack_m) <- c('Y', 'sub', 'fm_ia', 'fm_subsc',
                              'twoX_ia', 'twoX_subsc')

identity_attack_m_impact <- CausalImpact(identity_attack_m, pre_period, post_period, model.args = list(niter = 5000, nseasons = 7))

plot(identity_attack_m_impact)

#insult
insult_m <- cbind(fds_df["insult"],fds_subsc["subscriber"],
fm_df["insult"], fm_subsc["subscriber"],
twoX_df["insult"], twoX_subsc["subscriber"])

names(insult_m) <- c('Y', 'sub','fm_ins', 'fm_subsc',
                              'twoX_ins', 'twoX_subsc')

insult_m_impact <- CausalImpact(insult_m, pre_period, post_period, model.args = list(niter = 5000, nseasons = 7))

plot(insult_m_impact)
summary(insult_m_impact)

#insult
toxicity_m <- cbind(fds_df["severe_toxicity"],fds_subsc["subscriber"],
fm_df["severe_toxicity"], fm_subsc["subscriber"],
twoX_df["severe_toxicity"], twoX_subsc["subscriber"])

names(toxicity_m) <- c('Y', 'sub', 'fm_ia', 'fm_subsc',
                              'twoX_ia', 'twoX_subsc')

toxicity_m_impact <- CausalImpact(toxicity_m, pre_period, post_period, model.args = list(niter = 5000, nseasons = 7))

plot(toxicity_m_impact)