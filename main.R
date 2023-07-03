library(ggplot2)
library(dplyr)

files <- list.files(path="dane/", pattern="*.csv", full.names=TRUE, recursive=FALSE)

files

day_summary <- function(x) {
  df<-read.csv(x)
  print(x)
  day_date <- substr(x, nchar(x)-9, nchar(x)-4)
  day_date <- as.Date(day_date, "%y%m%d")
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
        user_count > 1 & user_count <= 10 ~ "2-10",
        user_count > 10 & user_count <= 100 ~ "11-100",
        user_count > 100 & user_count <= 1000   ~ "101-1000",
        user_count > 1000 & user_count <= 10000   ~ "1001-10000",
        user_count > 10000   ~ "10001+"
      ),
      # Convert to factor
      user_group = factor(
        user_group,
        level = c("0-1", "2-10","11-100", "101-1000", "1001-10000", "10001+")
      )
    )
  
  group_summary <- masto %>%
    group_by(user_group) %>%
    summarize(date=day_date,
              instance_count = n(), 
              instance_perc=instance_count/instance_total,
              user_sum=sum(user_count),
              user_perc=sum(user_count)/user_total,post_sum=sum(note_count),
              post_perc=sum(note_count)/post_total, 
              post_ratio=post_sum/user_sum)
  total_df<-data.frame(day_date,instance_total,1,user_total,1,post_total,1,post_total/user_total)
  names(total_df)<-c("date","instance_count", "instance_perc", "user_sum", "user_perc", "post_perc", "post_ratio")
  
  # total value
  #group_summary<- rbind(group_summary, total_df)
  return(group_summary)
}



full<-lapply(files, function(x){return(day_summary(x))})       
result<-bind_rows(full)

result2 <- result %>%
  group_by(user_group) %>%
  arrange(date) %>%
  mutate(instance_diff = instance_count - lag(instance_count, default = first(instance_count)), 
         user_diff = user_sum - lag(user_sum, default = first(user_sum)), 
         post_diff = post_sum - lag(post_sum, default = first(post_sum)), 
         post_ratio_diff = post_ratio - lag(post_ratio, default = first(post_ratio)))

p1 <- ggplot(result, aes(fill=user_group, y=instance_count, x=date)) + 
  geom_area(position="stack", stat="identity") +
  labs(title="Liczba instancji według rzędów wielkości", subtitle="Grupowanie według liczby użytkowników") +
  xlab("Data") +
  ylab("Liczba instancji") +
  scale_fill_brewer(palette="Spectral")
p1 + theme_light()

p2 <- ggplot(result, aes(fill=user_group, y=instance_perc, x=date)) + 
  geom_area(position="stack", stat="identity") +
  labs(title="Rozkład procentowy instancji według rzędów wielkości", subtitle="Grupowanie według liczby użytkowników") +
  xlab("Data") +
  ylab("Procent udziału grupy") +
  scale_fill_brewer(palette="Spectral")

p2 + theme_light()

p3 <- ggplot(result, aes(fill=user_group, y=user_sum, x=date)) + 
  geom_area(position="stack", stat="identity") +
  labs(title="Liczba użytkowników według rzędów wielkości instancji", subtitle="Grupowanie według liczby użytkowników") +
  xlab("Data") +
  ylab("Liczba użytkowników") +
  scale_fill_brewer(palette="Spectral")

p3 + theme_light()

p4 <- ggplot(result, aes(fill=user_group, y=user_perc, x=date)) + 
  geom_area(position="stack", stat="identity") +
  labs(title="Rozkład procentowy użytkowników według rzędów wielkości instancji", subtitle="Grupowanie według liczby użytkowników") +
  xlab("Data") +
  ylab("Liczba użytkowników") +
  scale_fill_brewer(palette="Spectral")

p4 + theme_light()


p5<-ggplot(result, aes(fill=user_group, y=post_sum, x=date)) + 
  geom_area(position="stack", stat="identity") +
  #  coord_flip() +
  labs(title="Liczba postów wg wielkości instancji")


p6 <- ggplot(result, aes(fill=user_group, y=post_perc, x=date)) + 
  geom_area(position="stack", stat="identity") +
  labs(title="Rozkład procentowy wpisów według rzędów wielkości instancji", subtitle="Grupowanie według liczby użytkowników") +
  xlab("Data") +
  ylab("Liczba wpisów") +
  scale_fill_brewer(palette="Spectral")

p6 + theme_light()

p7 <- ggplot(result, aes(fill=user_group, y=post_ratio, x=date)) + 
  geom_area(position="stack", stat="identity") +
  labs(title="Średnia liczba wpisów na użytkownika według rzędów wielkości instancji", subtitle="Grupowanie według liczby użytkowników") +
  xlab("Data") +
  ylab("wpis/uż.") +
  scale_fill_brewer(palette="Spectral")

p7 + theme_light()

p7<-ggplot(result, aes(fill=user_group, y=post_ratio, x=date)) + 
  geom_area(position="stack", stat="identity") +
  #  coord_flip()  +
  labs(title="Średnia postów na użytkownika wg wielkości instancji")

p8<-ggplot(result2, aes(y=user_diff, x=date)) + 
  geom_bar(stat="identity") +
  facet_wrap(user_group ~., scales="free") +
  labs(title="Dzienna zmiana liczby użytkowników")

p9<-ggplot(result2, aes(y=instance_diff, x=date)) + 
  geom_bar(stat="identity") +
  facet_wrap(user_group ~., scales="free") +
  labs(title="Dzienna zmiana liczby instancji")

p10<-ggplot(result2, aes(y=post_diff, x=date)) + 
  geom_bar(stat="identity") +
  facet_wrap(user_group ~., scales="free") +
  labs(title="Dzienna zmiana liczby wpisów")

p11<-ggplot(result2, aes(y=post_ratio_diff, x=date)) + 
  geom_bar(stat="identity") +
  facet_wrap(user_group ~., scales="free") +
  labs(title="Dzienna zmiana średniej liczby wpisów na użytkownika")


# 
# charts=list(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11)
# p1
# p2
# p3
# p4
# p5
# p6
# p7
# p8
# p9
# p10
# p11
# pdf("rafinacja/all.pdf")
# charts
# dev.off()

write.csv(result2, "result.csv")
