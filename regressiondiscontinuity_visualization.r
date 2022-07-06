library(tidyverse)
library(fixest)
df <- read.csv('E:/github/redditbots/datareddit.csv')
df2 <- read.csv('E:/github/redditbots/agg.csv')

df$date <-  as.Date(df$Date, "%Y-%m-%d")
df$post_tt <- ifelse(df$Rel_Date < 0, 0, 1)

df$relative_day <- difftime(df$date,as.Date('2019-10-28', "%Y-%m-%d"), units = "days")

df$post <- ifelse(df$relative_day <0, 0, 1)
df$relative_day <- as.numeric(df$relative_day)
library(rdd)

bw <- with(df, IKbandwidth(relative_day, toxicity, cutpoint = -0.5))


rdd_simple <- RDestimate(toxicity ~ relative_day, data = df, cutpoint = -0.5)


df2 %>% filter(Rel_Date > -16 & Rel_Date < 16) %>%
  select(toxicity, Rel_Date) %>%
  mutate(threshold = as.factor(ifelse(Rel_Date >= 0, 1, 0))) %>%
  ggplot(aes(x = Rel_Date, y = toxicity, color = threshold)) +
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



df2 %>% filter(Rel_Date > -16 & Rel_Date < 16) %>%
  select(identity_attack, Rel_Date) %>%
  mutate(threshold = as.factor(ifelse(Rel_Date >= 0, 1, 0))) %>%
  ggplot(aes(x = Rel_Date, y = identity_attack, color = threshold)) +
  geom_point() +
  geom_smooth(method = 'lm',se = T) +
  scale_color_brewer(palette = "Accent") +
  guides(color = FALSE) +
  geom_vline(xintercept = -0.5, color = "red",
             size = 1, linetype = "dashed") +
  labs(y = "Identity Attack Score",
       x = "Days Since Treatment",
       title ='Discontinuity in Identity Attack') +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black"))

