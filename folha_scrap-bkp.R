#BUSCANDO RESULTADOS DE UMA PESQUISA NA PÁGINA DA FOLHA

library(rvest)
library(RCurl) 

setwd('/home/dmatos/workspace2/aulas_R/aulas_R_web_scraping/')

folhaTreatLink = function(url, date){
	#print(date)
	print(url)

	request <- httr::GET(url)

	content <- httr::content(request, 'raw')

	html <- xml2::read_html(content) 

	url <- gsub('/', '_', url)

	url <- gsub(':', '_', url)

	date_nodes <- rvest::html_nodes(html, 'time')

	#print(paste('SIZE', length(date_node)))

	date_time <- rvest::html_attr(date_nodes[2], 'datetime')

	print(paste('DATETIME:', date_time))

	space_sep <- regexpr(' ', date_time) - 1

	date <- substr(date_time, 0, space_sep)

	print(date)

	filename <- paste(paste('folha/', date, sep=''), url, sep='-')

	items <- rvest::html_nodes(html, 'p')

	text <- ' '

	for(item in items){
		temp_txt <- rvest::html_text(item)
		text <- paste(text, temp_txt)
	}

	write(text, file=filename)
}

folha_scraper = function(next_url, query_list=NULL){

	folha_request <- httr::GET(next_url)

	if(!is.null(query_list)){
		folha_request <- httr::GET(next_url, 
			query = query_list)
	}

	print(httr::http_status(folha_request))

	folha_content <- httr::content(folha_request, 'raw')

	folha_html <- xml2::read_html(folha_content)

	items <- rvest::html_nodes(folha_html, xpath = '//*[@id="view-view"]')

	print(paste("# of results on this page: ", length(items)))

	for(item in items){
	    item_node <- rvest::html_node(item, 'a')
	    link <- rvest::html_attr(item_node, 'href')

	    date_container <- rvest::html_node(item, 'time')
	    date_text <- rvest::html_text(date_container)

	    date_str <- substr(date_text, 52, 62)

	    #date <- as.Date(date_str)

	    folhaTreatLink(link, date_str)
	}	

	pagination <- rvest::html_nodes(folha_html, xpath='//*[@class="c-pagination"]')

	if(length(pagination) > 0){
		print (length(pagination))

		actual_page <- rvest::html_node(pagination, xpath='//*[@class="c-pagination__item is-active"]')

		print(rvest::html_text(actual_page))

		actual_page_index <- strtoi(rvest::html_text(actual_page))

		pages <- rvest::html_nodes(pagination, xpath='//*[@class="c-pagination__item"]')

		for(page in pages){
			next_page <- rvest::html_text(page)

			next_page_index <- strtoi(next_page)

			if(next_page_index == (actual_page_index+1)){
				print(paste("next page index: ",next_page_index))

				page_a_node <- rvest::html_node(page, 'a')

				next_page_href <- rvest::html_attr(page_a_node, 'href')

				print(paste("next page href: ", next_page_href))

				return (next_page_href)
			}
		}

	} else {
		print ("no pages left")
		return (NULL)
	}
}

folhaQuery = function(query_list){
	next_page <- folha_scraper('http://search.folha.uol.com.br/search', query_list)

	while(!is.null(next_page) && next_page != 'NA'){
		print("Going to next link: ")
		print(next_page)
		
		next_page <- folha_scraper(next_page)
	}	
}

folhaQueryListExample =  function(){
	query_list <- list('q'='terrorismo+Manhattan','periodo'='personalizado','sd'='31/10/2017','ed'='07/11/2017','site'='todos')
	return(query_list) 
}

