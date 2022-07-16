#BUSCANDO RESULTADOS DE UMA PESQUISA NA PÁGINA DA FOLHA

library(rvest)
library(RCurl) 
library(lubridate)

bbcTreatLink = function(url, date){

	print(date)
	print(url)

	request <- httr::GET(url)

	content <- httr::content(request, 'raw')

	html <- xml2::read_html(content) 

	url <- gsub('/', '_', url)

	url <- gsub(':', '_', url)

	filename <- paste(paste('bbc/', date, sep=''), url, sep='-')

	items <- rvest::html_nodes(html, 'p')

	text <- ' '

	for(item in items){
		temp_txt <- rvest::html_text(item)
		text <- paste(text, temp_txt)
	}

	write(text, file=filename)
}

bbc_scraper = function(next_url, query_list=NULL, start_date=NULL, end_date=NULL){

	folha_request <- httr::GET(next_url)

	if(!is.null(query_list)){
		folha_request <- httr::GET(next_url, 
			query = query_list)
	}

	print(httr::http_status(folha_request))

	folha_content <- httr::content(folha_request, 'raw')

	folha_html <- xml2::read_html(folha_content)

	items <- rvest::html_nodes(folha_html, xpath = '//*[@class="hard-news-unit__headline-link"]')

	date_container <- rvest::html_nodes(items, xpath = '//*[@class="date date--v2"]')

	print(paste("# of results on this page: ", length(items)))

	date_counter <- 1

	for(item in items){
	    item_node <- rvest::html_node(item, 'a')
	    link <- rvest::html_attr(item, 'href')

	    print(paste('link: ', link))
	    
	    #print(date_container)

	    date_text <- rvest::html_attr(date_container[date_counter], 'data-seconds')

	    date_counter <- date_counter + 1

	    print(paste('RAW DATE', date_text))

	    #date <- as.Date(date_str)

	    #print(date)
	    #print(as.Date(date, '%d/%m/%Y'))

	    realDate <- as.Date(as_datetime(as.numeric(date_text)), format='%d/%m/%Y')
	     #as.Date(as.numeric(date_text), '%d/%m/%Y', origin='1970-01-01')

	    print(paste('DATE:', realDate))

	    if(is.na(realDate)){
	    	realDate <- Sys.Date()
	    }

	    if(!is.null(start_date) && is.null(end_date)){
	    	if(realDate >= as.Date(start_date, '%d/%m/%Y')){
	    		print('START')
	    		bbcTreatLink(link, realDate)
	    	}
	    	#print('START')
	    }
	    else if(!is.null(end_date) && is.null(start_date)){
	    	if(realDate <= as.Date(end_date, '%d/%m/%Y')){
	    		print('END')
	    		bbcTreatLink(link, realDate)
	    	}
	    	#print('END')
	    }
	    else if(!is.null(end_date) && !is.null(start_date)){
			if(realDate >= as.Date(start_date, '%d/%m/%Y')
				&& realDate <= as.Date(end_date, '%d/%m/%Y') ){
				print('BOTH')
				bbcTreatLink(link, realDate)
			}
			#print('BOTH')
	    }
	    else if(!is.null(start_date) && realDate <= as.Date(start_date, '%d/%m/%Y')){
	    	print("TOO SOON")
	    	return(NULL)
	    }
	    else {
	    	bbcTreatLink(link, realDate)
	    	#print('NEITHER')
	    }	    
	}	

	pagination <- rvest::html_node(folha_html, xpath='//*[@class="ws-search-pagination__link next"]')

	if(length(pagination) > 0){	
		hrefq <- rvest::html_attr(pagination, 'href')	
		next_page_href <- paste('https://www.bbc.com/portuguese/search/', hrefq, sep='')

		print(paste('NEXT: ', next_page_href))

		return (next_page_href)

	} else {
		print ("no pages left")
		return (NULL)
	}
}

bbcQuery = function(query_list, limit = 0, start_date=NULL, end_date=NULL){

	print("running bbcQuery")

	if(is.null(start_date) && is.null(end_date) && limit == 0){
		limit <- 30
	} else if(limit==0){
		limit <- Inf
	}

	 print(paste("START", start_date))
    print(paste("END", end_date))


	next_page <- bbc_scraper('https://www.bbc.com/portuguese/search/', query_list, start_date, end_date)

	counter <- 1

	while(!is.null(next_page) && next_page != 'NA' && counter < limit){
		print("Going to next link: ")
		print(next_page)
		
		next_page <- bbc_scraper(next_page, query_list=NULL, start_date=start_date, end_date=end_date)

		counter <- counter + 1
	}	
}

bbcQueryListExample =  function(){
	query_list <- list('q'='terrorismo')
	return(query_list) 
}

