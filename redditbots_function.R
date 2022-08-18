# required package
# library(dplyr)
# library(tidyverse)
# library(lubridate)

subscriber_num <- function(source_dir, from_date, to_date) {
  df <- read_csv(source_dir)
  df <- df %>%
    dplyr::select(created_utc, subreddit_subscribers) %>%
    mutate(created_date = as_date(lubridate::as_datetime(created_utc))) %>%
    group_by(created_date) %>%
    summarise(max = max(subreddit_subscribers)) %>%
    filter(created_date >= as.Date(from_date) & created_date <= as.Date(to_date))
  # from = "2019-09-28", to = "2019-11-27"
  names(df)[2] <- "subscriber"
  return(df)
}

agg_data <- function(source_dir, toxic_thresh, insult_thresh, ia_thresh) {
  df <- read_csv(source_dir)
  df <- df %>%
    mutate(created_date = as_date(lubridate::as_datetime(created_utc)),
           toxicity_f = ifelse(toxicity > toxic_thresh,1,0),
           identity_attack_f = ifelse(identity_attack > ia_thresh,1,0),
           insult_f = ifelse(insult > insult_thresh, 1, 0)) %>%
    group_by(created_date) %>%
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
      identity_attack_p = mean(identity_attack_f),
      insult_p = mean(insult_f),
      # exual_explicit_p = mean(sexual_explicit_flag),
      threat_p = mean(threat_flag)
    )
  return(df)
}

add_relDate <- function(df, day_zero) {
  df$relative_day <- difftime(df$created_date, as.Date(day_zero, "%Y-%m-%d"), units = "days")
  df$post <- ifelse(df$relative_day <0, 0, 1)
  df$relative_day <- as.numeric(df$relative_day)
  return(df)
}


adjust_thresh <-  function (df, toxic_thresh = 0.5, s.toxic_thresh = 0.5,
                            obscene_thresh = 0.5, threat_thresh = 0.5, 
                            insult_thresh = 0.5, ia_thresh = 0.5) {
  df <- df %>%
    mutate_if(toxicity_f = ifelse(toxicity > toxic_thresh,1,0),
              s.toxity_f = ifelse(toxicity > toxic_thresh,1,0),
              identity_attack_f = ifelse(identity_attack > ia_thresh,1,0),
              insult_f = ifelse(insult > insult_thresh, 1, 0))
  return(df)
}

clean_comm.api <-  function(source_dir){
  df <-  read_csv(source_dir)
  df <- df %>%
    dplyr::select(total_awards_received, approved_at_utc, edited, banned_by,
                   removal_reason, link_id, replies, id, banned_at_utc,
                   gilded, author, created_utc, parent_id, score, mod_note, all_awardings,
                   subreddit_id, subreddit, body, awarders, name, downs, associated_award,
                   stickied, can_gild, top_awarded_type, permalink, num_reports, 
                   report_reasons, created, treatment_tags, controversiality, mod_reports,
                   ups, downs, author_fullname) %>%
    mutate(created_date = date(as_datetime(created_utc)))
  return(df)
}

#not tested
comm_push.api <- function(source_dir.push, source_dir.api, report = TRUE){
  df.push <- read_csv(source_dir.push)
  df.api <- read_csv(source_dir.api)
  df.pushs <- df.push %>%
    dplyr::select(author, body, id, link_id, permalink) %>%
    rename(author.push = author, body.push = body, id.push = id,
           link_id.push = link_id, permalink.push = permalink)
  df.api <- read_csv(source_dir.api)%>%
    dplyr::select(author, body, id, link_id, permalink)
  df.compr <- left_join(df.push, df.api, by = c("id.push" = "id"), prefix = c(".x",".y"))
  if (report == TRUE){
    x1 = length(df.compr %>% filter(body.push == "[deleted]", body == "[deleted]"))
    print(paste("Both were deleted: ", x1))
    x2 = length(df.compr %>% filter(body.push == "[removed]", body == "[removed]"))
    print(paste("Both were removed", x2))
    x3 = (length(df.compr %>% filter(body.push  != "[deleted]", body == "[removed]")))
    print(paste("Deleted on Reddit after Pushift scraped", x3))
    x4 = length(df.compr %>% filter(body.push == "[deleted]", body != "[deleted]"))
    print(paste("Pushift deleted but recovered by now", x4))
    x5 = length(df.compr %>% filter(body.push != "[removed]", body == "[removed]"))
    print(paste("Removed on Reddit after Pushift scraped", x5))
    x6 = length(df.compr %>% filter(body.push == "[removed]", body != "[removed]"))
    print(paste("Pushift removed but recovered by now", x6))
  }
  return(df.compr)
}

#not tested, translted from Python
clean_comm.push <- function(source_dir, bot_epoch, report = TRUE, save_dir){
  df <- read_csv(source_dir)
  df <-  df %>%
    unique() %>%
    dplyr::select(body, author, id, created_utc, retrieved_on, permalink,
                  parent_id, subreddit, subreddit_id) %>%
    filter(created_utc > as_datetime(bot_epoch) + ddays(30) &
             created_utc <  as_datetime(bot_epoch) - ddays(30)) %>%
    mutate(created_date = as_datetime(created_utc),
    post = ifelse(created_date > bot_epoch, 0, 1))
  if (report == TRUE) {
    tibb1 <- df %>% filter(body == "[deleted]" | body == "[removed]") %>%
      group_by(body,post) %>%
      summarise(N = n())
    print(as_tibble(tibb))
    tibb2 <- df %>% group_by(post)%>%
      summarise(N = n())
  }
  if (save_dir != FALSE){
    write_excel_csv(save_dir)
  }
  return(df)
}

x = as_datetime(1660857409)
x + ddays(30)
