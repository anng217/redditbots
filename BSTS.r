# common procedure
rm(list = ls())

# Checking messy library
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
setwd("E:/github-data/redditbots")
getwd()

# Function ----
## Function: Take subscriber info
subscriber_num <- function(source_dir, from_date, to_date) {
  df <- read_csv(source_dir)
  df <- df %>%
    dplyr::select(created_utc, subreddit_subscribers) %>%
    mutate(time = as_date(lubridate::as_datetime(created_utc))) %>%
    group_by(time) %>%
    summarise(max = max(subreddit_subscribers)) %>%
    filter(time >= as.Date(from_date) & time <= as.Date(to_date))
  # from = "2019-09-28", to = "2019-11-27"
  names(df)[2] <- "subscriber"
  return(df)
}

## Function: Clean data for BSTS
clean <- function(source_dir) {
  df <- read_csv(source_dir)
  df <- df %>%
    mutate(time = as_date(lubridate::as_datetime(created_utc))) %>%
    group_by(time) %>%
    summarise(
      toxicity = mean(toxicity),
      severe_toxicity = mean(severe_toxicity),
      obscene = mean(obscene),
      identity_attack = mean(identity_attack),
      insult = mean(insult), threat = mean(threat),
      # sexual_explicit_m = mean(sexual_explicit),
      toxicity_p = mean(toxicity_flag),
      severe_toxicity_p = mean(severe_toxicity_flag),
      obscene_p = mean(obscene_flag),
      identity_attack_p = mean(identity_attack_flag),
      insult_p = mean(insult_flag),
      # exual_explicit_p = mean(sexual_explicit_flag),
      threat_p = mean(threat_flag)
    )
  return(df)
}

# Function: Cross users
cross_users <- function(source_dir1, df1_name, source_dir2, df2_name) {
  df1 <- read_csv(source_dir1)
  df2 <- read_csv(source_dir2)
  df1 %>%
    group_by(author) %>%
    summarise(num_coms = n())
  df2 %>%
    group_by(author) %>%
    summarise(num_coms = n())
  df <- left_join(df1, df2, by = author, suffix = c(df1_name, df2_name))
  return(df)
}

# Data Cleaning ----
fds_df <- clean("E:/gihub-data/redditbots/fds/fds_res.csv")
wgtow <- clean("E:/github/redditbots/data/wgotw/wgtow_res.csv")

fm_df <- clean("E:/github-data/redditbots/data/control-fds/feminism_res.csv")
twoX_df <- clean("E:/github/redditbots/data/control-fds/twoX_res.csv")
wvsp_df <- clean("E:/github/redditbots/data/control-fds/wvsp_res.csv")
trollX_df <- clean("E:/github/redditbots/data/control-fds/trollX_res.csv")

mgtow_df <- clean("E:/github/redditbots/data/control-fds/MGTOW_res.csv")
trp_df <- clean("E:/github/redditbots/data/control-fds/TheRedPill_res.csv")

fds_bsts <- clean("E:/gihub-data/redditbots/fds/fds_res.csv")
fm_bsts <- clean("E:/gihub-data/redditbots/control-fds/feminism_res.csv")
twoX_bsts <- clean("E:/gihub-data/redditbots/control-fds/twoX_res.csv")
wvsp_bsts <- clean("E:/gihub-data/redditbots/control-fds/wvsp_res.csv")
trollX_bsts <- clean("E:/gihub-data/redditbots/control-fds/trollX_res.csv")
mgtow_bsts <- clean("E:/gihub-data/redditbots/control-fds/mgtow_res.csv")
trp_bsts <- clean("E:/gihub-data/redditbots/control-fds/TheRedPill_res.csv")

# Take subscribers ----
fds_subsc <- subscriber_num(
  source_dir = "E:/gihub-data/redditbots/fds/fds_clean_subm.csv",
  from_date = "2019-09-28", to_date = "2019-11-27"
)

fm_subsc <- subscriber_num(
  source_dir = "E:/gihub-data/redditbots/control-fds/feminism_subsc.csv",
  from_date = "2019-09-28", to_date = "2019-11-27"
)

twoX_subsc <- subscriber_num(
  source_dir = "E:/gihub-data/redditbots/control-fds/twoX_subsc.csv",
  from_date = "2019-09-28", to_date = "2019-11-27"
)

wvsp_subsc <- subscriber_num(
  source_dir = "E:/gihub-data/redditbots/control-fds/wvsp_subsc.csv",
  from_date = "2019-09-28", to_date = "2019-11-27"
)

trollX_subsc <- subscriber_num(
  source_dir = "E:/gihub-data/redditbots/control-fds/trollX_subsc.csv",
  from_date = "2019-09-28", to_date = "2019-11-27"
)

trp_subsc <- subscriber_num(
  source_dir = "E:/gihub-data/redditbots/control-fds/trp_subsc.csv",
  from_date = "2019-09-28", to_date = "2019-11-27"
)

mgtow_subsc <- subscriber_num(
  source_dir = "E:/gihub-data/redditbots/control-fds/mgtow_subsc.csv",
  from_date = "2019-09-28", to_date = "2019-11-27"
)

# Set pre-post period ----
pre_period <- c(1, 30)
post_period <- c(31, 61)

#_______________________________ ---------
# FDS AS FOCAL COMMUNITY ----
## fds ~ fm + twoX + trollX ----
### * identity attack: fds ~ fm + twoX + trollX ----
identity_attack_m <- cbind(
  fds_df["identity_attack"], 
  fm_df["identity_attack"], fm_subsc["subscriber"],
  twoX_df["identity_attack"], twoX_subsc["subscriber"],
  trollX_df["identity_attack"], trollX_subsc["subscriber"]
)

names(identity_attack_m) <- c("Y", "fm_ia", "fm_subsc", "twoX_ia", 
                              "twoX_subsc", "trollX_ia", "troll_subsc")

identity_attack_m_impact <- CausalImpact(identity_attack_m, pre_period, post_period,model.args = list(niter = 5000, nseasons = 7))

plot(identity_attack_m_impact)
summary(identity_attack_m_impact)

### * insult: fds ~ fm + twoX + trollX ----
insult_m <- cbind(
  fds_df["insult"],
  fm_df["insult"], fm_subsc["subscriber"],
  twoX_df["insult"], twoX_subsc["subscriber"],
  trollX_df["identity_attack"], trollX_subsc["subscriber"]
)

names(insult_m) <- c("Y", "fm_ia", "fm_subsc", "twoX_ia", 
                     "twoX_subsc", "trollX_ia", "troll_subsc")

insult_m_impact <- CausalImpact(insult_m, pre_period, post_period, model.args = list(niter = 5000, nseasons = 7)) # nolint

plot(insult_m_impact)
summary(insult_m_impact)

### * toxicity: fds ~ fm + twoX + trollX ----
toxicity_m <- cbind(
  fds_df["toxicity"],
  fm_df["toxicity"], fm_subsc["subscriber"],
  twoX_df["toxicity"], twoX_subsc["subscriber"],
  trollX_df["toxicity"], trollX_subsc["subscriber"]
)

names(toxicity_m) <- c("Y", "fm_ia", "fm_subsc", "twoX_ia", 
                       "twoX_subsc", "trollX_ia", "troll_subsc")

toxicity_m_impact <- CausalImpact(toxicity_m, pre_period,
  post_period,
  model.args = list(niter =5000, nseasons = 7)
)

plot(toxicity_m_impact)
summary(toxicity_m_impact)

### * severe_toxicity: fds ~ fm + twoX + trollX ----
stoxicity_m <- cbind(
  fds_df["severe_toxicity"],
  fm_df["severe_toxicity"], fm_subsc["subscriber"],
  twoX_df["severe_toxicity"], twoX_subsc["subscriber"],
  trollX_df["severe_toxicity"], trollX_subsc["subscriber"]
)

names(stoxicity_m) <-  c("Y", "fm_ia", "fm_subsc", "twoX_ia", 
                         "twoX_subsc", "trollX_ia", "troll_subsc")


stoxicity_m_impact <- CausalImpact(stoxicity_m, pre_period,
  post_period,
  model.args = list(niter = 5000, nseasons = 7)
)

plot(stoxicity_m_impact)
summary(stoxicity_m_impact)

### * obscenity: : fds ~ fm + twoX ----
obscene_m <- cbind(
  fds_df["obscene"], fds_subsc["subscriber"],
  fm_df["obscene"], fm_subsc["subscriber"],
  twoX_df["obscene"], twoX_subsc["subscriber"]
)

names(obscene_m) <- c(
  "Y", "sub", "fm_ins", "fm_subsc",
  "twoX_ins", "twoX_subsc"
)

obscene_m_impact <- CausalImpact(obscene_m, pre_period,
  post_period,
  model.args = list(niter = 5000, nseasons = 7)
) # nolint

plot(obscene_m_impact)
summary(obscene_m_impact)

### * subscriber: fds ~ fm + twoX + trollX ----
df.sub <- cbind(log(fds_subsc["subscriber"]),
  log(fm_subsc["subscriber"]),
  log(twoX_subsc["subscriber"]),
  log(trollX_subsc["subscriber"])
)

names(df.sub) <- c("Y", "sub", "sub2","sub3")

mod.sub <- CausalImpact(df.sub, pre_period,
  post_period,
  model.args = list(niter = 5000, nseasons = 7)
) # nolint

plot(mod.sub)

# _ _ _ _----
## fds ~ trp + mgtow + twoX + trollX ----
### * identity attack ----
identity_attack_m <- cbind(
  fds_df["identity_attack"],
  twoX_df["identity_attack"], twoX_subsc["subscriber"],
  fm_df["identity_attack"], fm_subsc["subscriber"],
  trollX_df["identity_attack"], trollX_subsc["subscriber"],
  trp_df["identity_attack"], trp_subsc["subscriber"],
  mgtow_df["identity_attack"], mgtow_subsc["subscriber"])

names(identity_attack_m) <- c("Y", "twoX", "twoX_subsc","fm_ia", "fm_subsc", 
                      "trollX_ia", "troll_subsc", "trp", "trp_subsc", "mgtow_ia", 
                              "mgtow_subsc") #, "trollX_ia", "troll_subsc")

identity_attack_m_impact <- CausalImpact(identity_attack_m, pre_period, post_period,model.args = list(niter = 10000, nseasons = 7))

plot(identity_attack_m_impact)
summary(identity_attack_m_impact)

### * insult ----
insult_m <- cbind(
  fds_df["insult"],
  twoX_df["insult"], twoX_subsc["subscriber"],
  fm_df["insult"], fm_subsc["subscriber"],
  trollX_df["insult"], trollX_subsc["subscriber"],
  trp_df["insult"], trp_subsc["subscriber"],
  mgtow_df["insult"], mgtow_subsc["subscriber"])

names(insult_m) <- c("Y", "twoX", "twoX_subsc","fm_ia", "fm_subsc", 
                              "trollX_ia", "troll_subsc", "trp", "trp_subsc", "mgtow_ia", 
                              "mgtow_subsc") #, "trollX_ia", "troll_subsc")

insult_m_impact <- CausalImpact(insult_m, pre_period, post_period,model.args = list(niter = 10000, nseasons = 7))

plot(insult_m_impact)
summary(insult_m_impact)

# ________________________________ ---- 
# WGTOW AS FOCAL COMMUNITY (too complicated. Later) ----
## Data Cleaning ----
wgtow_df <- clean("E:/github/redditbots/data/wgtow/wgtow_res.csv")

## Take Subscribers ----
wgtow_subsc <- subscriber_num(
  source_dir = "E:/github/redditbots/data/wgtow/wgtow_clean_subm.csv",
  from_date = "2021-03-30", to_date = "2021-05-29"
)

## _ _ _ _ ----
## wgtow ~ fm + twoX + trollX ----
### * subscriber: wgtow ~ fm + twoX + trollX ----


# ________________________________ ---- 
# WVSP AS FOCAL COMMUNITY (also missing submission date)----
## Data Cleaning ----
wvsp_df <- clean("E:/github/redditbots/data/witchesvspatriarchy/wvsp_res.csv")

## Take Subscribers ----
wvsp_subsc <- subscriber_num(
  source_dir = "E:/github/redditbots/data/witchesvspatriarchy/wvsp_clean_subm.csv",
  from_date = "2020-11-22", to_date = "2021-01-21"
)

## wgtow ~ fm + twoX + trollX ----
### * subscriber: wgtow ~ fm + twoX + trollX ----


library(rdd)
library(fixest)



df <- read.csv("E:/github/redditbots/data/fds/fds_res.csv")

df$date <-  as.Date(df$created_utc, "%Y-%m-%d")

df$post_tt <- ifelse(df$Rel_Date < 0, 0, 1)

df$relative_day <- difftime(df$date,as.Date('2019-10-28', "%Y-%m-%d"), units = "days")

df$post_tt <- ifelse(df$relative_day < 0, 0, 1)

df$relative_day <- as.numeric(df$relative_day)


bw <- with(df, IKbandwidth(relative_day, toxicity, cutpoint = -0.5))

rdd_simple <- RDestimate(toxicity ~ relative_day, data = df, cutpoint = 0)

rdd_simple

