#BUSCANDO RESULTADOS DE UMA PESQUISA NA PÁGINA DA FOLHA

library(rvest)
library(RCurl) 
library(RSelenium)
library(stringi)
library(readr)

start_date = NULL
end_date = NULL

rD <- rsDriver(port=4556L, browser='chrome')
remDr <- rD[['client']]

elespectadorTreatLink = function(url, date){
	print('treating link')
	print(date)
	print(paste("url:", url))

	url <- toString(url)

	print(is.character(url))

	originalHandle <- unlist(remDr$getWindowHandles())

	print(originalHandle)

	remDr$executeScript("window.open();", args = list(url))

	print("pause of 5 secs")
	Sys.sleep(5)

	allHandles <- remDr$getWindowHandles()

	print("allHandles")
	print(allHandles)

	newHandle <- unlist(allHandles[!allHandles %in% originalHandle])

	print(paste("newHandle", newHandle))

	remDr$switchToWindow(newHandle)

	remDr$navigate(url)

	#print(paste("request", request))

	content <- remDr$findElements(using='tag', 'p')

	#print(paste("content", content))

	url <- gsub('/', '_', url)

	url <- gsub(':', '_', url)

	date <- gsub('/', '_', date)

	filename <- paste(paste('elespectador/', date, sep=''), url, sep='-')

	text <- ' '

	for(item in content){
		print('item: ')
		print(item)
		temp_txt <- item$getElementAttribute("outerHTML")
		text <- paste(text, temp_txt)
	}

	write(text, file=filename)

	remDr$closeWindow()
	remDr$switchToWindow(originalHandle)
	
}

elespectadorQueryListExample =  function(){
	query_list <- list('elecciones','presidenciales')
	return(query_list) 
}

elespectadorProcessor = function(item, fecha){
	print("function processor")


	print(paste("start_date", start_date))
	print(paste("end_date", end_date))


	
	fecha_txt <- fecha$findElement(using = 'css selector', '.node-post-date')$getElementAttribute('outerHTML')

	html_text <- item$findElement(using = 'css selector', 'a')$getElementAttribute('href')

	fecha_start <- regexpr('>', fecha_txt) + 1

	fecha_end <- regexpr('</div>', fecha_txt) - 1
	
	fecha_str <- substr(fecha_txt, fecha_start, fecha_end)

	fecha_end <-  regexpr('-', fecha_str) - 2

	fecha_str <-  substr(fecha_str, 1, fecha_end)

	fecha_str2 <- paste(substr(fecha_str, 1, fecha_end-5), '.', sep='')
	fecha_str <- paste(fecha_str2, substr(fecha_str, fecha_end-4, fecha_end), sep='')

	print(paste("fecha antes de format", fecha_str))

	realDate <- parse_date(fecha_str, '%d %b %Y', locale=locale('es'))
	#realDate <- format(realDate, '%d/%m/%Y')

	print(paste('FECHA(date)', realDate))
	print(html_text)


				link <- html_text

				print(paste("link:", link))

				
				print(paste('REAL DATE', realDate))

			    if(is.na(realDate)){
			    	print("DATE is na")
			    	realDate <- Sys.Date()
			    } else {
			    	print("DATE is OK")
			    }

			    if(!is.null(start_date) && is.null(end_date)){
			    	if(as.Date(realDate, format='%d/%m/%Y') >= as.Date(start_date, format='%d/%m/%Y')){
			    		print('START')
			    		elespectadorTreatLink(link, realDate)			    		
			    	}			    	
			    }
			    else if(!is.null(end_date) && is.null(start_date)){
			    	if(as.Date(realDate, format='%d/%m/%Y') <= as.Date(end_date, format='%d/%m/%Y')){
			    		print('END')
			    		elespectadorTreatLink(link, realDate)
			    	}			    	
			    }
			    else if(!is.null(end_date) && !is.null(start_date)){	
					if(as.Date(realDate, format='%d/%m/%Y') >= as.Date(start_date, format='%d/%m/%Y')){
						if(as.Date(realDate, format='%d/%m/%Y') <= as.Date(end_date, format='%d/%m/%Y')){
							print('BOTH')
							elespectadorTreatLink(link, realDate)
						} else {
							print("realDate is greater than end_date")
							print(as.Date(realDate, format='%d/%m/%Y'))
							print(as.Date(end_date, format='%d/%m/%Y'))							
						}
					} else {
						print("realDate is lesser than start_date")
					}					
			    }
			    else if(!is.null(start_date) && realDate <= start_date){
			    	print("deu NULL")
			    	return(NULL)
			    }
			    else {
			    	print('NEITHER')
			    	elespectadorTreatLink(link, realDate)			    	
			    }	    
			
	

	print("processor end")
}

elespectadorQuery2 = function(query_list, start_date_input=NULL, end_date_input=NULL, limit = 0){
	
	start_date = as.Date(start_date_input, format='%d/%m/%Y')
	end_date = as.Date(end_date_input, format='%d/%m/%Y')

	if(is.null(start_date) && is.null(end_date) && limit == 0){
		limit <- 10
	} else if(limit==0){
		limit <- Inf
	}	

	remDr$navigate(paste('https://www.elespectador.com/search/', paste(query_list, collapse=' ', sep=' '), sep = ''))

	Sys.sleep(5)

	items <- remDr$findElements(using='css selector', 'h3>a')
	fechas <- remDr$findElements(using='css selector', '.node-post-date')

	items_and_fechas <- rbind(items, fechas)

	#print(paste("items:", items))

	#print(paste("fechas: ", fechas))

	mapply(elespectadorProcessor, items, fechas)

	#print(paginacion)

	pages_counter <- 2
	while(pages_counter < limit){

		#print(paste("paginacion: ", paginacion))

		next_search_page <- paste('https://www.elespectador.com/search/', paste(query_list, collapse=' ', sep=' '), sep = '')
		next_search_page <- paste(next_search_page, paste("?page=",pages_counter))
		remDr$navigate(next_search_page)
		

		Sys.sleep(5)

		items <- remDr$findElements(using='css selector', 'h3>a')
		fechas <- remDr$findElements(using='css selector', '.node-post-date')

		#print(paste("items:", items))
		#print(paste("fechas: ", fechas))

		mapply(elespectadorProcessor, items, fechas)

		pages_counter <- pages_counter + 1


	} 
}	
