library(rvest)

g1_scraper = function(next_url, query_list=NULL){

	g1_request <- httr::GET(next_url)

	if(!is.null(query_list)){
		g1_request <- httr::GET(next_url, 
			query = query_list)
	}

	print(httr::http_status(g1_request))

	g1_content <- httr::content(g1_request, 'raw')

	g1_html <- xml2::read_html(g1_content)

	#list of news
	items <- rvest::html_nodes(g1_html, xpath = '//*[@class="widget widget--card widget--info"]')

	print(paste("# of results on this page: ", length(items)))

	for(item in items){
	    item_node <- rvest::html_node(item, 'a')
	    link <- rvest::html_attr(item_node, 'href')
	    print(link)
	}	

	pagination <- rvest::html_nodes(g1_html, xpath='//*[@class="pagination widget"]')

	if(length(pagination) > 0){
		print (length(pagination))

		page_a_node <- rvest::html_node(pagination, 'a')

		next_page_href <-  paste('https://g1.globo.com/busca/',rvest::html_attr(page_a_node, 'href'))

		print(paste("next page href: ", next_page_href))

		return (next_page_href)
			
	} else {
		print ("no pages left")
		return (NULL)
	}
}


# Argument are a query_list like the g1QueryListExample
# Multiple keywords must be separated by "+" simbol in a sigle string, i.e., "terrorismo+França"
# g1 query doesn't accept date limits
g1Query = function(query_list, limit=20){

	print("running g1Query")

	next_page <- g1_scraper('https://g1.globo.com/busca/', query_list)

	counter <- 1

	while(!is.null(next_page) && next_page != 'NA' && counter < limit){
		print(counter)
		print("Going to next link : ")
		print(next_page)
		
		next_page <- g1_scraper(next_page)

		counter <- counter + 1
	}	
}

g1QueryListExample =  function(){
	query_list <- list('q'='terrorismo', 'order'='recent')
	return(query_list) 
}