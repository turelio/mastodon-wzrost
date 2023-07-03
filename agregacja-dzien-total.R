# skrypt agreguje dane dzienne i zbiera je w nowy arkusz, grupując wartości tylko według daty
library(ggplot2)
library(dplyr)

# pobieranie listy plików z danymi źródłowymi
files <- list.files(path="dane/", pattern="*.csv", full.names=TRUE, recursive=FALSE)

files

day_summary <- function(x) {
  df<-read.csv(x)
  print(x)
  day_date <- substr(x, nchar(x)-9, nchar(x)-4)
  day_date <- as.Date(day_date, "%y%m%d")
  
  # poniższe serwery zostały wyłączone ze zbioru ze względu na:
  # 1. błędną klasyfikację typu serwera (serwery proxy, które efektywnie duplikowały statystyki instancji)
  # 2. błędne lub jawnie zafałszowane statystyki (np. liczba postów zawyżona o rzędy wielkości)
  banned <- c('mastodon.adtension.com',
              'switter.at',
              'mastodon-social.activitypub-proxy.cf', 
              'mstdn-social.activitypub-proxy.cf', 
              'masto-ai.activitypub-proxy.cf',
              'kolektiva-social.activitypub-proxy.cf',
              'mastodon-social.social.shrimpcam.pw',
              'hellsite.site')
  
  masto <- df %>%
    filter(software=='mastodon') %>%
    filter(!hostname %in% banned)
  
  user_total<-sum(masto['user_count'])
  post_total<-sum(masto['note_count'])
  instance_total<-nrow(masto)
  
  masto<-masto %>% 
    mutate(
      # Create categories
      user_group = dplyr::case_when(
        user_count <= 1            ~ "0-1",
        user_count > 1 & user_count <= 10 ~ "1-10",
        user_count > 10 & user_count <= 100 ~ "10-100",
        user_count > 100 & user_count <= 1000   ~ "100-1000",
        user_count > 1000 & user_count <= 10000   ~ "1000-10000",
        user_count > 10000   ~ "10000+"
      ),
      # Convert to factor
      user_group = factor(
        user_group,
        level = c("0-1", "1-10","10-100", "100-1000", "1000-10000", "10000+")
      )
    )
  
  group_summary <- masto %>%
    summarize(date=day_date,
              instance_count = n(), 
              user_sum=sum(user_count),
              post_sum=sum(note_count),
              post_ratio=post_sum/user_sum)
  total_df<-data.frame(day_date,instance_total,1,user_total,1,post_total,1,post_total/user_total)
  names(total_df)<-c("date","instance_count", "user_sum", "post_sum", "post_ratio")

  return(group_summary)
}


full<-lapply(files, function(x){return(day_summary(x))})       
result<-bind_rows(full)

# dodatkowe kolumny
result2 <- result %>%
  arrange(date) %>%
  mutate(instance_diff = instance_count - lag(instance_count, default = first(instance_count)), 
         user_diff = user_sum - lag(user_sum, default = first(user_sum)), 
         post_diff = post_sum - lag(post_sum, default = first(post_sum)), 
         post_ratio_diff = post_ratio - lag(post_ratio, default = first(post_ratio)))



write.csv(result2, "rafinacja/dane-dzien-total.csv")
