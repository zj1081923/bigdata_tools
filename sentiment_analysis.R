install.packages("plyr")
install.packages("dplyr")
install.packages("textdata")
library(dplyr)

library(stringr)
library(tidytext)
library(ggthemes)
library(extrafont)
loadfonts()

library(plyr)
library(stringr)


#name <- "sqoop_review.txt"
#name <- "mongodb_review.txt"
name <- "spark_review.txt"
reviews <- readLines(name)
posDic = readLines("posDic.txt")
negDic = readLines("negDic.txt")

l <- 0

sentimental = function(sentences, positive, negative){

  scores = laply(sentences, function(sentence, positive, negative) {
    
    sentence = gsub('[[:punct:]]', ' ', sentence) # 문장부호 제거
    sentence = gsub('[[:cntrl:]]', ' ', sentence) # 특수문자 제거
    sentence = gsub('\\d+', ' ', sentence)        # 숫자 제거
    
    word.list = str_split(sentence, '\\s+')      # 공백 기준으로 단어 생성 -> \\s+ : 공백 정규식, +(1개 이상)
    words = unlist(word.list)                    # unlist() : list를 vector 객체로 구조변경
    words <- casefold(words) #대문자 -> 소문자
    
    l <<- l+length(words)

    pos.matches = match(words, positive)           # words의 단어를 positive에서 matching
    neg.matches = match(words, negative)

    pos.matches = !is.na(pos.matches)            # NA 제거, 위치(숫자)만 추출
    neg.matches = !is.na(neg.matches)
    
    score = sum(pos.matches) - sum(neg.matches)  # 긍정 - 부정   
    return(score)
  }, positive, negative)
  
  scores.df = data.frame(score=scores, text=sentences)
  return(scores.df)
}

get_word = function(reviews){
    reviews = gsub('[[:punct:]]', ' ', reviews) # 문장부호 제거
    reviews = gsub('[[:cntrl:]]', ' ', reviews) # 특수문자 제거
    reviews = gsub('\\d+', ' ', reviews)        # 숫자 제거
    word.list = str_split(reviews, '\\s+')      # 공백 기준으로 단어 생성 -> \\s+ : 공백 정규식, +(1개 이상)
    words = unlist(word.list)                    # unlist() : list를 vect 
    words <- casefold(words)
    return(words)

}

result = sentimental(reviews, posDic, negDic)
#w = get_word(reviews)
print(l)

result$color[result$score >=1] = "blue"
result$color[result$score ==0] = "green"
result$color[result$score < 0] = "red"
#table(result$color)


sent_result <- table(result$color)
lbls <- c("positive ", "neutral ", "negative ")
pct <- round(sent_result/sum(sent_result)*100)
lbls <- paste(lbls, pct, "%", sep="")

#barplot(result$score, col=result$color, main="sqoop reviews pos-neg degree", xlab="each word", ylab="pos-neg degree")
#barplot(result$score, col=result$color, main="mongoDB reviews pos-neg degree", xlab="each word", ylab="pos-neg degree")
#barplot(result$score, col=result$color, main="spark reviews pos-neg degree", xlab="each word", ylab="pos-neg degree")


#pie(sent_result, labels=lbls, main="sqoop sentiment analysis pie chart")
#pie(sent_result, labels=lbls, main="mongoDB sentiment analysis pie chart")
#pie(sent_result, labels=lbls, main="spark sentiment analysis pie chart")




############################################
#단어 얻기
words <- get_word(reviews)
library(tidyverse)
len = length(words)

# tidy text를 사용할 수 있게 자료변환
text_df <- data_frame(line=1:len, text=words)
text_df2 <- text_df %>%
	unnest_tokens(word, text) %>%
	count(word, sort=TRUE)

text_word_counts <- text_df2 %>%
	inner_join(get_sentiments("bing"))    # joining, by = "word"

library(dplyr)

top_text_words <- text_word_counts %>%
	group_by(sentiment) %>%
	top_n(20, n) %>%
	ungroup() %>%
	mutate(word = reorder(word, n))


top_neg <- filter(top_text_words, sentiment == "negative")
top_pos <- filter(top_text_words, sentiment == "positive")
top_neg <- top_neg[1:20,]
top_pos <- top_pos[1:20,]
top_neg <- na.omit(top_neg)
top_pos <- na.omit(top_pos)

final_top <- rbind(top_pos, top_neg)


#plot 그리기
ggplot(final_top, aes(word, n, valfill = sentiment)) +
	geom_col(show.legend = FALSE) +
	facet_wrap(~sentiment, scales = "free") +
	coord_flip() +
	labs(x="", y="") +
	ggtitle("Top words in each sentiment (sqoop)")+   # 제목 입력
  	theme(plot.title = element_text(size=14,  # 크기 입력 및 서식 입력                                 
            face="bold",hjust=0.5))
