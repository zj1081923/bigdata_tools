#install.packages("XML")
#install.packages("stringr")

#library(XML)
#library(stringr)

all_reviews <- NULL

#below url is for review of mongodb
#url_base <- "https://www.g2.com/products/mongodb/reviews?page="
url_base <- "mongodb_capterra"
	
#because of ddos, use delay
delay <- function(x)
{
	p1 <- proc.time()
	Sys.sleep(x)
	proc.time() - p1  #The cpu usage should be negligible

}


for (i in 1:1){
	newr <- NULL
	
	# get url on each review page
	#url <- paste(url_base, i, sep='')
	#url <- paste(url_base, i, ".html", sep='')
	url <- paste(url_base, ".html", sep='')

	# because of ddos, use delay
	#delay(5.5)

	txt <- readLines(url, encoding="UTF-8")
	# read html and save it at txt
	#txt <- readLines(url)

	# because 
	#reviews <- txt[which(str_detect(txt, "class=\"formatted-text\""))+1]
	reviews <- txt[which(str_detect(txt, "class=\"ReviewSection__Root-sc-189472c-0 icjcMH\""))+1]

	reviews <- gsub("<.+?>|\t"," ", reviews)

	newr <- cbind(reviews)
	all_reviews <- rbind(all_reviews, newr)

}

write.table(all_reviews, "mongodb_review2.txt")

