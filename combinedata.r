rm(list = ls())

library(data.table)
library(tidyverse)
library(dplyr)
library(readr)
library(lubridate)
library(plotly)

setwd("E:/gihub-data/redditbots/temp")
getwd()
tbl <-
  list.files(pattern = "*.csv") %>% 
  map_df(~read_csv(.))
head(tbl)

source("E:/github/redditbots/redditbots_function.R")

unpop1 <- distinct(tbl)
#write_csv(unpop1, "E:/gihub-data/redditbots/fds/unpop_comments_retrieved_1.csv")

unpop_org <- read_csv("E:/gihub-data/redditbots/control-fds/unpopularopinion.csv")
unpop_org1 <- distinct(unpop_org)

unpop1_agg <- unpop1 %>%
  mutate(created_date = as_date(lubridate::as_datetime(created_utc))) %>%
  group_by(created_date) %>%
  summarise( n = n())

unpop_org_agg <-  unpop_org %>%
  mutate(created_date = as_date(lubridate::as_datetime(created_utc))) %>%
  group_by(created_date) %>%
  summarise( n = n())

plot_ly(data = unpop1_agg,
  x = ~created_date,
  y = ~n,
  type = "bar",
  name = "Reddit Retrieved"
) %>% 
  add_trace(data = unpop_org_agg, y=~n, name = "Pushift")

unpop2 <- unpop1 %>%
  mutate(created_date = as_date(lubridate::as_datetime(created_utc))) %>%
  filter(created_date == as_date('2019-09-29')) %>%
  select(created_date, id, link_id, permalink) %>%
  rename(created_date.y = created_date)

unpop_org2 <- unpop_org %>% 
  mutate(created_date = as_date(lubridate::as_datetime(created_utc))) %>%
  filter(created_date == as_date('2019-09-29')) %>%
  select(created_date, id, link_id, permalink)

join2 <- merge(unpop_org2,unpop2, all.x = TRUE)

join3 <- join2 %>%
  filter(is.na(created_date.y))
write_csv(join3, "unpop_missing_sep29.csv")
