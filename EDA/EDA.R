library(stringr)
library(ggplot2)

data <- read.csv('EDA/data.csv',
                 header = FALSE,
                 col.names = c("User", "URL", "Date", "Comment", 
                               "Rating", "Recommendation"),
                 colClasses = c("character", "character", "Date",
                                "character", "factor", "integer"))
# check NA(OK, almost...)
sum(apply(data, 2, is.na))
# drop unused level in Rating col
data <- subset(data, Rating != "")
# data format
str(data)


# comments analysis

# remove all the symbols
clean_string <- function (string){
  return(gsub("[\\，\\.\\。\\\r\n\ ]", "", string))
}
data$Comment <- sapply(data$Comment, clean_string)
# count chars
data$words <- sapply(data$Comment, nchar)

# Central: mean, median
mean(data$words)
median(data$words)
# Spread: range, quantile, var, std
range(data$words)
quantile(data$words)
var(data$words)
sd(data$words)

# hist of comments words
words <- ggplot(data, aes(fill=Rating, x=words))
words + geom_bar(stat = 'bin')
ggsave('EDA/pics/hist.png')

# box(and violin) plot
words <- ggplot(data, aes(x=Rating, y=words))
#words + geom_boxplot(aes(color=Rating, shape=Rating))

words + geom_violin(aes(color=Rating)) +
        geom_boxplot(width=0.2)
ggsave('EDA/pics/violin.png')


# word cloud
library(wordcloud2)
library(jiebaR)
wk = worker(stop_word = 'EDA/stopwords-zh.txt')
comment_freq <- as.data.frame(table(wk[data$Comment]))
comment_freq_sorted <- comment_freq[sort(comment_freq$Freq, decreasing = TRUE, 
                                         index.return=TRUE)$ix,]
top500 <- head(comment_freq_sorted, 500)
cloud_graph <- wordcloud2(top500)
# save it
library(webshot)
webshot::install_phantomjs()
# save it in html
library("htmlwidgets")
saveWidget(cloud_graph,"tmp.html",selfcontained = F)
# and in png
webshot("tmp.html","fig_1.png", delay =20, vwidth = 880, vheight=880)


# Recommendation(support trending)
support <- ggplot(data, aes(x=Date, y=Recommendation,
                            color=Rating)) +
           geom_line(aes(linetype=Rating), alpha=0.8)
support
ggsave('EDA/pics/trending.png')

