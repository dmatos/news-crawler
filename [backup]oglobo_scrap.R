library(rvest)
library(RCurl) 

treatLink = function(url, date){
	print(date)
	print(paste('https:', url, sep=''))

	stat <- httr::HEAD(paste('https:', url, sep=''))

	request <- httr::GET(paste('https:', url, sep=''))

	content <- httr::content(request, 'text')	

	print(content)

	a_pos <- regexpr('URL=\'', content) + 5

	print(paste('URL\' pos: ', a_pos))

	print(paste('length of str content: ', nchar(content)))

	print(substr(content, 4, 10))

	b_pos <- regexpr('\'', substr(content, a_pos, nchar(content))) + a_pos - 2

	print(paste('\' pos', b_pos))

	print(substr(content, a_pos, b_pos))

	next_url <- substr(content, a_pos, b_pos)

	print(paste('next_url: ', next_url))

	request <- httr::GET(next_url)	

	content <- httr::content(request, 'raw')

	html <- xml2::read_html(content) 

	url <- gsub('/', '_', next_url)

	url <- gsub(':', '_', url)

	filename <- paste(paste('oglobo/', date, sep=''), url, sep='-')

	items <- rvest::html_nodes(html, 'p')

	text <- ' '

	for(item in items){
		print('FLAG')
		print(rvest::html_text(item))

		temp_txt <- rvest::html_text(item)
		text <- paste(text, temp_txt)
	}

	write(text, file=filename)
}

oglobo_scraper = function(next_url, query_list=NULL, start_date=NULL, end_date=NULL){

	g1_request <- httr::GET(next_url)

	if(!is.null(query_list)){
		g1_request <- httr::GET(next_url, 
			query = query_list)
	} else {
		print("NULL QUERY LIST")
	}

	print(g1_request)

	print(httr::http_status(g1_request))

	g1_content <- httr::content(g1_request, 'raw')

	g1_html <- xml2::read_html(g1_content)

	print(g1_html)

	#list of news
	items <- rvest::html_nodes(g1_html, xpath = '//*[@class="cor-produto"]')

	print(paste("# of results on this page: ", length(items)))

	for(item in items){
	    #item_node <- rvest::html_node(item, 'a')
	    link <- rvest::html_attr(item, 'href')

	    print(paste('LINK: ', link))

	    date_container <- rvest::html_node(item, xpath = '//*[@class="busca-tempo-decorrido"]')

	    date_text <- rvest::html_text(date_container)

	    i <- regexpr("*[0-9]+/[0-9]+/[0-9]+",date_text)

	    #print(length(i))

	    if( length(i) >= 1 && substr(link,0,2) == '//'){

		    date <- substr(date_text, i, i+9)

		    #print(date)
		    #print(as.Date(date, '%d/%m/%Y'))

		    realDate <- gsub('.', '-', date)#as.Date(date, '%d/%m/%Y')

		    if(is.na(realDate)){
		    	realDate <- Sys.Date()
		    }

		    if(!is.null(start_date) && is.null(end_date)){
		    	if(realDate > as.Date(start_date, '%d/%m/%Y')){
		    		treatLink(link, realDate)
		    	}
		    	#print('START')
		    }
		    else if(!is.null(end_date) && is.null(start_date)){
		    	if(realDate < as.Date(end_date, '%d/%m/%Y')){
		    		treatLink(link, realDate)
		    	}
		    	#print('END')
		    }
		    else if(!is.null(end_date) && !is.null(start_date)){
				if(realDate > as.Date(start_date, '%d/%m/%Y')
					&& realDate < as.Date(end_date, '%d/%m/%Y') ){
					treatLink(link, realDate)
				}
				#print('BOTH')
		    }
		    else if(!is.null(start_date) && realDate < as.Date(start_date, '%d/%m/%Y')){
		    	return(NULL)
		    }
		    else {
		    	treatLink(link, realDate)
		    	#print('NEITHER')
		    }	    
		}
	}	

	pagination <- rvest::html_nodes(g1_html, xpath='//*[@class="proximo fundo-cor-produto"]')

	if(length(pagination) > 0){
		print (length(pagination))

		#page_a_node <- rvest::html_node(pagination, 'a')

		next_page_href <-  ('https://oglobo.globo.com/busca')

		print(paste("next page href: ", next_page_href))

		return (next_page_href)
			
	} else {
		print ("no pages left")
		return (NULL)
	}
}


#argument are a query_list like the g1QueryListExample
#multiple keywords must be separated by "+" simbol in a sigle string, i.e., "terrorismo+França"

ogloboQuery = function(query_list, start_date=NULL, end_date=NULL, limit=0){

	print("running ogloboQuery")

	if(is.null(start_date) && is.null(end_date) && limit == 0){
		limit <- 10
	} else if(limit==0){
		limit <- Inf
	}

	next_page <- oglobo_scraper('https://oglobo.globo.com/busca', query_list, start_date, end_date)

	counter <- 2

	while(!is.null(next_page) && next_page != 'NA' && counter < limit){
		print(counter)
		print("Going to next link : ")
		print(next_page)
		
		query_list["page"] <- paste('',counter,sep='')

		print(query_list)

		next_page <- oglobo_scraper(next_page, query_list=query_list, start_date, end_date)

		counter <- counter + 1
	}	
}

ogloboQueryListExample =  function(){
	query_list <- list('q'='terrorismo')
	return(query_list) 
}