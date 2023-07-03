library(dplyr)
library(lubridate)
library(tidyr)
df <- read.csv("rafinacja/dane-dzien-grupy.csv")
df2 <- read.csv("rafinacja/dane-dzien-total.csv")

result1 <- df %>%
  group_by(user_group, lubridate::month(date),lubridate::year(date) ) %>%
  summarise(instance_average = mean(instance_count),
            user_average = mean(user_sum),
            post_average = mean(post_sum)) %>%
  unite("date", "lubridate::year(date)","lubridate::month(date)", sep="-") %>%
  arrange(date) %>%
  mutate(instance_diff = instance_average - lag(instance_average, default = first(instance_average)), 
         user_diff = user_average - lag(user_average, default = first(user_average)), 
         post_diff = post_average - lag(post_average, default = first(post_average)))

result2 <- df2 %>%
  group_by(lubridate::month(date),lubridate::year(date) ) %>%
  summarise(instance_average = mean(instance_count),
            user_average = mean(user_sum),
            post_average = mean(post_sum)) %>%
  unite("date", "lubridate::year(date)","lubridate::month(date)", sep="-") %>%
  arrange(date) %>%
  mutate(instance_diff = instance_average - lag(instance_average, default = first(instance_average)), 
         user_diff = user_average - lag(user_average, default = first(user_average)), 
         post_diff = post_average - lag(post_average, default = first(post_average)))



write.csv(result1, "rafinacja/dane-miesiac-grupy.csv")
write.csv(result2, "rafinacja/dane-miesiac-total.csv")
