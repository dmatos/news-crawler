#BUSCANDO RESULTADOS DE UMA PESQUISA NA PÁGINA DA FOLHA

library(rvest)
library(RCurl) 
library(RSelenium)

elpaisTreatLink = function(url, date){
	print(date)
	print(url)

	request <- httr::GET(url)

	content <- httr::content(request, 'raw')

	html <- xml2::read_html(content) 

	url <- gsub('/', '_', url)

	url <- gsub(':', '_', url)

	filename <- paste(paste('elpais/', date, sep=''), url, sep='-')

	items <- rvest::html_nodes(html, 'p')

	text <- ' '

	for(item in items){
		temp_txt <- rvest::html_text(item)
		text <- paste(text, temp_txt)
	}

	write(text, file=filename)
}

elpaisQueryListExample =  function(){
	query_list <- list('qt'='terrorismo', 'sf'='1', 'np'='1')
	return(query_list) 
}

elpaisQuery2 = function(query_list, start_date=NULL, end_date=NULL, limit = 0){
	

	if(is.null(start_date) && is.null(end_date) && limit == 0){
		limit <- 10
	} else if(limit==0){
		limit <- Inf
	}

	rD <- rsDriver(port=4555L, browser='chrome')
	remDr <- rD[['client']]

	remDr$navigate('https://elpais.com/s/setAmerica.html')

	Sys.sleep(3)

	remDr$navigate(paste('https://elpais.com/buscador/?', paste(paste(names(query_list), '=', sep='' ),query_list, collapse='&', sep=''), sep=''))

	items <- remDr$findElements(using='css selector', '.article')

	for(item in items){

		fecha_txt <- item$findElement(using = 'xpath', '//span[@class="fecha"]')$getElementAttribute('innerHTML')
		print('FOUND FECHA')

		html_text <- item$findElement(using = 'xpath', '//a[@href]')$getElementAttribute('innerHTML')
		print('FOUND HREF')

		href_pos <- regexpr('<a href=\\\"', html_text)

		fecha_start <- regexpr('fecha\\">', fecha_txt) + 7

		fecha_end <- regexpr('</span>', substr(fecha_txt, fecha_start, fecha_start+30))

		fecha_str <- substr(fecha_txt, fecha_start, fecha_end+fecha_start-2)

		date <- as.Date(fecha_str, '%d/%m/%Y')

		print(paste('FECHA', fecha_str))

		if(href_pos > 0){		
			href_pos <- href_pos + 9

			final_pos <- regexpr('.html', html_text)

			if(final_pos > 0){

				link <- paste('https://elpais.com', substr(html_text, href_pos, final_pos+4), sep='')

				print(link)

				realDate <- as.Date(date, '%d/%m/%Y')

				print(paste('REAL DATE', realDate))

			    if(is.na(realDate)){
			    	print("DATE is na")
			    	realDate <- Sys.Date()
			    }

			    if(!is.null(start_date) && is.null(end_date)){
			    	if(realDate >= as.Date(start_date, '%d/%m/%Y')){
			    		print('START')
			    		elpaisTreatLink(link, realDate)			    		
			    	}			    	
			    }
			    else if(!is.null(end_date) && is.null(start_date)){
			    	if(realDate <= as.Date(end_date, '%d/%m/%Y')){
			    		print('END')
			    		elpaisTreatLink(link, realDate)
			    	}			    	
			    }
			    else if(!is.null(end_date) && !is.null(start_date)){
					if(realDate >= as.Date(start_date, '%d/%m/%Y')
						&& realDate <= as.Date(end_date, '%d/%m/%Y') ){
						print('BOTH')
						elpaisTreatLink(link, realDate)
					}					
			    }
			    else if(!is.null(start_date) && realDate <= as.Date(start_date, '%d/%m/%Y')){
			    	print("deu NULL")
			    	return(NULL)
			    }
			    else {
			    	print('NEITHER')
			    	elpaisTreatLink(link, realDate)			    	
			    }	    
			}
		} else {
			print(paste("href_pos", href_pos))
		}

	}

	paginacion <- remDr$findElements(using='css selector', '.paginacion .boton')

	print("paginando...")

	pages_counter <- query_list$np
	while(!is.null(paginacion) && pages_counter < limit){
		counter <- 0
		print(paste("pagination", pages_counter))
		for(b in paginacion){
			if(counter == 0){

				#print(paste("b: ", b))

				#b$clickElement()

		    query_list$np <- pages_counter
		    remDr$navigate(paste('https://elpais.com/buscador/?', paste(paste(names(query_list), '=', sep='' ),query_list, collapse='&', sep=''), sep=''))
		
				Sys.sleep(3)

				items <- remDr$findElements(using='css selector', '.article')

				for(item in items){

					fecha_txt <- item$findElement(using = 'xpath', '//span[@class="fecha"]')$getElementAttribute('innerHTML')
					print('FOUND FECHA')

					html_text <- item$findElement(using = 'xpath', '//a[@href]')$getElementAttribute('innerHTML')
					print('FOUND HREF')

					href_pos <- regexpr('<a href=\\\"', html_text)

					fecha_start <- regexpr('fecha\\">', fecha_txt) + 7

					fecha_end <- regexpr('</span>', substr(fecha_txt, fecha_start, fecha_start+30))

					fecha_str <- substr(fecha_txt, fecha_start, fecha_end+fecha_start-2)

					date <- as.Date(fecha_str, '%d/%m/%Y')

					print(paste('FECHA', fecha_str))

					if(href_pos > 0){		
						href_pos <- href_pos + 9

						final_pos <- regexpr('.html', html_text)

						if(final_pos > 0){

							link <- paste('https://elpais.com', substr(html_text, href_pos, final_pos+4), sep='')

							#print(link)

							realDate <- as.Date(date, '%d/%m/%Y')

						    if(is.na(realDate)){
						    	realDate <- Sys.Date()
						    }

						    if(!is.null(start_date) && is.null(end_date)){
						    	if(realDate > as.Date(start_date, '%d/%m/%Y')){
						    		elpaisTreatLink(link, realDate)
						    	}
						    	print('START')
						    }
						    else if(!is.null(end_date) && is.null(start_date)){
						    	if(realDate < as.Date(end_date, '%d/%m/%Y')){
						    		elpaisTreatLink(link, realDate)
						    	}
						    	print('END')
						    }
						    else if(!is.null(end_date) && !is.null(start_date)){
								if(realDate > as.Date(start_date, '%d/%m/%Y')
									&& realDate < as.Date(end_date, '%d/%m/%Y') ){
									elpaisTreatLink(link, realDate)
								}
								print('BOTH')
						    }
						    else if(!is.null(start_date) && realDate < as.Date(start_date, '%d/%m/%Y')){
						    	return(NULL)
						    }
						    else {
						    	elpaisTreatLink(link, realDate)
						    	print('NEITHER')
						    }	    
						}
					}

				}

			}
			else {
				break
			}
		}

		paginacion <- remDr$findElements(using='css selector', '.paginacion .boton')

		pages_counter <- pages_counter + 1

	}
	


}
