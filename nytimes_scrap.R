#BUSCANDO RESULTADOS DE UMA PESQUISA NA PÁGINA DA FOLHA

library(rvest)
library(RCurl) 
library(RSelenium)

nytimesTreatLink = function(url){

	print(url)

	request <- httr::GET(url)

	content <- httr::content(request, 'raw')

	html <- xml2::read_html(content) 

	url <- gsub('/', '_', url)

	url <- gsub(':', '_', url)

	date_node <- rvest::html_node(html, 'time')

	date <- rvest::html_attr(date_node, 'datetime')

	filename <- paste(paste('nytimes/', date, sep=''), url, sep='-')

	items <- rvest::html_nodes(html, 'p')

	text <- ' '

	for(item in items){
		temp_txt <- rvest::html_text(item)
		text <- paste(text, temp_txt)
	}

	write(text, file=filename)
}

nytimesQueryListExample =  function(){
	query_list <- list('query'='violence','endDate'='20180713',
		'sort'='newest', 'startDate'='20180703')
	return(query_list) 
}

nytimesQuery2 = function(query_list){
	rD <- rsDriver(port=4567L, browser='chrome')
	remDr <- rD[['client']]

	remDr$navigate(paste('https://www.nytimes.com/search/?', paste(paste(names(query_list), '=', sep='' ),query_list, collapse='&', sep=''), sep=''))

	el <- try(remDr$findElement(using = 'xpath', '//*[@id="site-content"]/div/div[2]/div[2]/div/button'), silent=TRUE)
	print("EL:...")
	print(el)
	if(!is.null(el)) el$clickElement()

	print("FLAG")

	#all pagination is done by clicking a button
	#after that we have all links returned by the seach

	counter <- 1
	while(!is.null(el)){
		print(paste('Loading next page in 5 seconds. Page: ', counter))

		Sys.sleep(5)

		#print(regexpr('SHOW MORE',remDr$findElement(using = 'css selector', '.Search-main--17rHj')$getElementText()))
		el <- tryCatch({
		  print("trying to click")
		  el <- remDr$findElement(using = 'xpath', '//*[@id="site-content"]/div/div[2]/div[2]/div/button')
		}, error = function(cond){
		  print("a bad fail")
		  return(NULL)
		})
		if(!is.null(el)) {
		  print("clicking el")
		  try(el$clickElement(), silent=TRUE)
		}
		else print("el is null!!!")
			
		counter <- counter + 1
	}

	#now to the links
	links <- remDr$findElements(using = 'class name', 'css-1l4w6pd')

	print("Initializing scraping of the results...")

	#print(links)

	for(item in links){

		#print(item)
		#print(paste("ITEM ", item))
		
		html_text <- item$findElement(using = 'xpath', '/html/body/div[1]/main/div/div[2]/div[1]/ol/li[1]/div/div/a/h4')$getElementAttribute('innerHTML')

		href_pos <- regexpr('<a href=\\\"', html_text)

		if(href_pos > 0){

			href_pos <- href_pos + 9

			final_pos <- regexpr('.html', html_text)

			if(final_pos > 0){

				href <- paste('https://www.nytimes.com', substr(html_text, href_pos, final_pos+4), sep='')

				print(href)

				nytimesTreatLink(href)
			}		

		}

	}

}
