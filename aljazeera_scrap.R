#BUSCANDO RESULTADOS DE UMA PESQUISA NA PÁGINA DA FOLHA

library(rvest)
library(RCurl) 
library(RSelenium)

aljazeeraCheckDate = function(realDate, start_date=NULL, end_date=NULL){
	if(is.na(realDate)){
    	realDate <- Sys.Date()
    }

    if(!is.null(start_date) && is.null(end_date)){
    	if(realDate >= as.Date(start_date, '%d/%m/%Y')){
    		return(TRUE)
    	}
    	#print('START')
    }
    else if(!is.null(end_date) && is.null(start_date)){
    	if(realDate <= as.Date(end_date, '%d/%m/%Y')){
    		return(TRUE)
    	}
    	#print('END')
    }
    else if(!is.null(end_date) && !is.null(start_date)){
		if(realDate >= as.Date(start_date, '%d/%m/%Y')
			&& realDate <= as.Date(end_date, '%d/%m/%Y') ){
			return(TRUE)
		}
		#print('BOTH')
    }
    else if(!is.null(start_date) && realDate <= as.Date(start_date, '%d/%m/%Y')){
    	return(FALSE)
    }
    else {
    	return(FALSE)
    	#print('NEITHER')
    }	   
    return(FALSE)
}

aljazeeraTreatLink = function(url, start_date=NULL, end_date=NULL){

	print(url)

	request <- httr::GET(url)

	content <- httr::content(request, 'raw')

	html <- xml2::read_html(content) 

	url <- gsub('/', '_', url)

	url <- gsub(':', '_', url)

	date_node <- rvest::html_node(html, 'time')

	date <- rvest::html_text(date_node) #, 'datetime')

	print(paste('FOUND DATE', substr(date, 0, 11)))

	myLoc <- Sys.getlocale("LC_TIME")
	Sys.setlocale("LC_TIME", 'C')

	date <- as.Date(substr(date, 0, 11), '%d %b %Y')

	print(paste('START', start_date))

	print(paste('END', end_date))

	print(paste('SEARCH DATE', date))

	if(aljazeeraCheckDate(date, start_date, end_date) == TRUE){

		print('CHECKED')

		filename <- paste(paste('aljazeera/', date, sep=''), url, sep='-')

		items <- rvest::html_nodes(html, 'p')

		text <- ' '

		for(item in items){
			temp_txt <- rvest::html_text(item)
			text <- paste(text, temp_txt)
		}

		write(text, file=filename)
	}

	Sys.setlocale("LC_TIME", myLoc)
}

aljazeeraQueryListExample =  function(){
	query_list <- list('q'='Bir+Al-abed')
	return(query_list) 
}

aljazeeraQuery = function(query_list, start_date=NULL, end_date=NULL){
	rD <- rsDriver(port=4567L, browser='chrome')
	remDr <- rD[['client']]

	remDr$navigate(paste('https://www.aljazeera.com/Search/?', paste(paste(names(query_list), '=', sep='' ),query_list, collapse='&', sep=''), sep=''))

	Sys.sleep(6)

	links <- try(remDr$findElements(using = 'xpath', '//*[@ctype="c"]'), NULL, silent=FALSE)
	
	for(link in links){

		print("LINK")
		print(link)

		outerHtml <- link$getElementAttribute('outerHTML')
		href_start_pos <- regexpr('href=', outerHtml) + length('href=')+5

		href <- substr(outerHtml, href_start_pos, nchar(outerHtml))

		href_end_pos <- regexpr('>', href) - 2

		href <- substr(href, 0, href_end_pos)

		href <- paste('https://www.aljazeera.com/', href, sep="")

		aljazeeraTreatLink(href, start_date, end_date)
	}


	#all pagination is done by clicking a button
	#after that we have all links returned by the seach

	Sys.sleep(5)
	print("fucking CLICKING")
	el <- try(remDr$findElement(using = 'xpath', '/html/body/form/div[7]/div/div[2]/div/div/div[1]/div/section/div/div/div/div[1]/div/div/div/div/div/div[1]/div/div/div[2]/div/div/div[1]/div/div[1]/div/div/div[1]/div/div/div/div[3]/section/div/div/div[2]/nav/ul/li[7]/a/span[1]'), silent=TRUE)
  Sys.sleep(3)
		if(!is.null(el)) el$clickElement()

	counter <- 1
	while(!is.null(el)){
		print(paste('Loading next page in 5 seconds. Page: ', counter))

		Sys.sleep(5)

		links <- try(remDr$findElements(using = 'xpath', '//*[@ctype="c"]'), NULL, silent=FALSE)
	
		for(link in links){			

			outerHtml <- link$getElementAttribute('outerHTML')
			href_start_pos <- regexpr('href=', outerHtml) + length('href=')+5

			href <- substr(outerHtml, href_start_pos, nchar(outerHtml))

			href_end_pos <- regexpr('>', href) - 2

			href <- substr(href, 0, href_end_pos)

			href <- paste('https://www.aljazeera.com/', href, sep="")

			aljazeeraTreatLink(href, start_date, end_date)
		}
		  
		Sys.sleep(5)
		
		print("CLICKING")
		
		counter <- counter + 1
		el <- try(remDr$findElement(using = 'xpath', "/html/body/form/div[7]/div/div[2]/div/div/div[1]/div/section/div/div/div/div[1]/div/div/div/div/div/div[1]/div/div/div[2]/div/div/div[1]/div/div[1]/div/div/div[1]/div/div/div/div[3]/section/div/div/div[2]/nav/ul/li[7]/a"), silent=TRUE)
		if(!is.null(el)) el$clickElement()		
	}

}
