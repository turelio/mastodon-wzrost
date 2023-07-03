library(ggplot2)
library(dplyr)

files <- list.files(path="dane/", pattern="*.csv", full.names=TRUE, recursive=FALSE)

files

day_summary <- function(x) {
  df<-read.csv(x)
  df$day_date <- as.Date(substr(x, nchar(x)-9, nchar(x)-4), "%y%m%d")
  banned <- c('mastodon.adtension.com',
              'switter.at',
              'mastodon-social.activitypub-proxy.cf', 
              'mstdn-social.activitypub-proxy.cf', 
              'masto-ai.activitypub-proxy.cf',
              'kolektiva-social.activitypub-proxy.cf',
              'mastodon-social.social.shrimpcam.pw',
              'hellsite.site')
  
  df <- df %>%
    filter(software=='mastodon') %>%
    filter(!hostname %in% banned)
  
  df<-df %>% 
    mutate(
      # Create categories
      user_group = dplyr::case_when(
        user_count <= 1            ~ "1",
        user_count > 1 & user_count <= 10 ~ "2",
        user_count > 10 & user_count <= 100 ~ "3",
        user_count > 100 & user_count <= 1000   ~ "4",
        user_count > 1000 & user_count <= 10000   ~ "5",
        user_count > 10000   ~ "6"
      ),
      # Convert to factor
      user_group = factor(
        user_group,
        level = c("1","2","3","4","5","6")
    )
    )

  return(df[,c("hostname","day_date","user_group")])
}

test1 <- day_summary("dane/230511.csv")
full<-lapply(files, function(x){return(day_summary(x))})       
result<-bind_rows(full)

write.csv(result, "all-mastodon.csv")
