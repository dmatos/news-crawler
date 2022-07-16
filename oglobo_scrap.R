library(rvest)
library(RCurl) 

checkDate = function(realDate, start_date=NULL, end_date=NULL){
	if(is.na(realDate)){
    	realDate <- Sys.Date()
    }

    #print(paste("CHECKING DATE of ", realDate))
    #print(paste("start at ", as.Date(start_date, '%d/%m/%Y')))
    #print(paste("end at ", as.Date(end_date, '%d/%m/%Y')))

    if(!is.null(start_date) && is.null(end_date)){
    	#print('START')
    	if(realDate >= as.Date(start_date, '%d/%m/%Y')){
    		return(TRUE)
    	} else return(FALSE)
    	#print('START')
    }
    else if(!is.null(end_date) && is.null(start_date)){
    	#print('END')
    	if(realDate <= as.Date(end_date, '%d/%m/%Y')){
    		return(TRUE)
    	} else return(FALSE)
    	#print('END')
    }
    else if(!is.null(end_date) && !is.null(start_date)){
		#print('BOTH')
		if(realDate >= as.Date(start_date, '%d/%m/%Y')
			&& realDate <= as.Date(end_date, '%d/%m/%Y') ){
			print("OK")
			return(TRUE)
		} else {
		  print(paste("NOT OK because ", realDate, "is not in interval ", start_date, " - ", end_date, sep =""))
		  return(FALSE)
		}
		#print('BOTH')
    }
    else if(!is.null(start_date) && realDate <= as.Date(start_date, '%d/%m/%Y')){
    	#print('BEFORE no donuts')
    	return(FALSE)
    }
    else {
    	#print('NEITHER')
    	return(TRUE)
    	#print('NEITHER')
    }	   
}

treatLink = function(url, date, start_date=NULL, end_date=NULL){
	print(paste('DATE:', date))
	print(paste('https:', url, sep=''))

	stat <- httr::HEAD(paste('https:', url, sep=''))

	request <- httr::GET(paste('https:', url, sep=''))

	content <- httr::content(request, 'text')	

	#print(content)

	a_pos <- regexpr('URL=\'', content) + 5

	#print(paste('URL\' pos: ', a_pos))

	#print(paste('length of str content: ', nchar(content)))

	#print(substr(content, 4, 10))

	b_pos <- regexpr('\'', substr(content, a_pos, nchar(content))) + a_pos - 2

	#print(paste('\' pos', b_pos))

	#print(substr(content, a_pos, b_pos))

	next_url <- substr(content, a_pos, b_pos)

	#print(paste('next_url: ', next_url))

	request <- httr::GET(next_url)	

	content <- httr::content(request, 'raw')

	html <- xml2::read_html(content) 

	url <- gsub('/', '_', next_url)

	url <- gsub(':', '_', url)

	#date_node <- rvest::html_node(html, xpath = '//*[@class="article__date"]')

	#date <- substr(rvest::html_text(date_node), 2, 11) #html_attr(date_node, 'datetime')

	#print(paste("datetime attr", date))

	date <- as.Date(date, '%d/%m/%Y')
	
	if(is.na(date)){
	  date <- as.Date(date, '%Y-%m-%d')
	}

	#print(paste("REAL DATE: ", date))
	#print(paste("START", start_date))
	#print(paste("END", end_date))

	if(checkDate(date, start_date, end_date)){

		filename <- paste(paste('oglobo/', date, sep=''), url, sep='-')

		items <- rvest::html_nodes(html, 'p')

		text <- ' '

		for(item in items){
			#print('FLAG')
			#print(rvest::html_text(item))

			temp_txt <- rvest::html_text(item)
			text <- paste(text, temp_txt)
		}

		write(text, file=filename)
	}
}

oglobo_scraper = function(next_url, query_list=NULL, start_date=NULL, end_date=NULL){

	g1_request <- httr::GET(next_url)

	if(!is.null(query_list)){
		g1_request <- httr::GET(next_url, 
			query = query_list)
	} else {
		print("NULL QUERY LIST")
	}

	#print(g1_request)

	#print(httr::http_status(g1_request))

	g1_content <- httr::content(g1_request, 'raw')

	g1_html <- xml2::read_html(g1_content)

	print(g1_html)

	#list of news
	divClass <- '//*[@class="widget--info__title product-color "]'
	print("Buscando noticias em : ")
	print(divClass)
	items <- rvest::html_nodes(g1_html, xpath = divClass)

	print(paste("# of results on this page: ", length(items)))

	for(item in items){
	    #item_node <- rvest::html_node(item, 'a')
	  
	    #print(paste("item: ", item, sep = ""))
	    link <- rvest::html_node(item, xpath = '//*[@class="widget--info__text-container"]')
	    link <- rvest::html_node(link, 'a')
	    link <- rvest::html_attr(link, 'href')
	    
	    #print(paste("link: ", link, sep=""))
	   
	    date_container <- rvest::html_node(item, xpath = '//*[@class="widget--info__meta--card"]')

	    date_text <- rvest::html_text(date_container)
	    
	    #print("date found:  ")
	    #print(date_text)

	    if(is.na(date_text)){
			date_container <- rvest::html_node(item, xpath = '//*[@class="busca-tempo-decorrido"]')

		    date_text <- rvest::html_text(date_container)

	    }

	    i <- regexpr("*[0-9]+/[0-9]+/[0-9]+",date_text)

	    if( i[1] >= 1 && substr(link,0,2) == '//'){

		    date <- substr(date_text, i[1], i[1]+9)

		    #print(date)
		    #print(as.Date(date, '%d/%m/%Y'))

		    realDate <- as.Date(date, '%d/%m/%Y')
    	    print(paste('LINK: ', link))
    	    print(paste("News date: ", realDate))
		    
		    if(is.na(realDate)){
		    	realDate <- Sys.Date()
		    }

		    treatLink(link, realDate, start_date, end_date)    
		}
	}	

	pagination <- rvest::html_nodes(g1_html, xpath='//*[@class="fundo-cor-produto pagination__load-more"]')

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
	query_list <- list('q'='terrorismo','species'='notícias')
	return(query_list) 
}