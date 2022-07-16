#BUSCANDO RESULTADOS DE UMA PESQUISA NA PÁGINA DA FOLHA

library(rvest)
library(RCurl) 
library(RSelenium)
library(stringi)

start_date = NULL
end_date = NULL

emolTreatLink = function(url, date){
	print(date)
	print(paste("url:", url))

	url <- toString(url)

	print(is.character(url))

	request <- httr::GET(url)

	#print(paste("request", request))

	content <- httr::content(request, 'raw')

	#print(paste("content", content))

	html <- xml2::read_html(content) 

	#print(paste("html", html))

	url <- gsub('/', '_', url)

	url <- gsub(':', '_', url)

	date <- gsub('/', '_', date)

	filename <- paste(paste('emol/', date, sep=''), url, sep='-')

	items <- rvest::html_nodes(html, xpath='//*[@id="cuDetalle_cuTexto_textoNoticia"]')

	text <- ' '

	for(item in items){
		temp_txt <- stri_enc_tonative(rvest::html_text(item))
		text <- paste(text, temp_txt)
	}

	write(text, file=filename)
}

emolQueryListExample =  function(){
	query_list <- list('query'='elecciones+presidenciales')
	return(query_list) 
}

emolProcessor = function(item, fecha){
	print("function processor")


	print(paste("start_date", start_date))
	print(paste("end_date", end_date))


	html_text <- item$findElement(using = 'xpath', '//*[@id="LinkNoticia"]')$getElementAttribute('href')
	fecha_txt <- fecha$findElement(using = 'xpath', '//span[@class="bus_txt_fuente"]')$getElementAttribute('outerHTML')


	fecha_start <- regexpr('</a>', fecha_txt) + 7

	fecha_end <-fecha_start + 9
	
	fecha_str <- substr(fecha_txt, fecha_start, fecha_end)

	if(regexpr(':', fecha_str) >= 1) fecha_str <- Sys.Date()

	print(paste("fecha antes de format", fecha_str))

	realDate <- as.Date(fecha_str, format='%d/%m/%Y')
	realDate <- format(realDate, '%d/%m/%Y')

	print(paste('FECHA(date)', realDate))
	
	

	
			final_pos <- regexpr('.html', html_text)

			if(final_pos > 0){

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
			    		emolTreatLink(link, realDate)			    		
			    	}			    	
			    }
			    else if(!is.null(end_date) && is.null(start_date)){
			    	if(as.Date(realDate, format='%d/%m/%Y') <= as.Date(end_date, format='%d/%m/%Y')){
			    		print('END')
			    		emolTreatLink(link, realDate)
			    	}			    	
			    }
			    else if(!is.null(end_date) && !is.null(start_date)){	
					if(as.Date(realDate, format='%d/%m/%Y') >= as.Date(start_date, format='%d/%m/%Y')){
						if(as.Date(realDate, format='%d/%m/%Y') <= as.Date(end_date, format='%d/%m/%Y')){
							print('BOTH')
							emolTreatLink(link, realDate)
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
			    	emolTreatLink(link, realDate)			    	
			    }	    
			}
	

	print("processor end")
}

emolQuery2 = function(query_list, start_date_input=NULL, end_date_input=NULL, limit = 0){
	
	start_date = as.Date(start_date_input, format='%d/%m/%Y')
	end_date = as.Date(end_date_input, format='%d/%m/%Y')

	if(is.null(start_date) && is.null(end_date) && limit == 0){
		limit <- 10
	} else if(limit==0){
		limit <- Inf
	}

	rD <- rsDriver(port=4555L, browser='chrome')
	remDr <- rD[['client']]

	remDr$navigate(paste('https://www.emol.com/buscador/?', paste(paste(names(query_list), '=', sep='' ),query_list, collapse='&', sep=''), sep=''))

	Sys.sleep(5)

	items <- remDr$findElements(using='css selector', '#LinkNoticia')
	fechas <- remDr$findElements(using='css selector', '.bus_txt_fuente')

	items_and_fechas <- rbind(items, fechas)

	#print(paste("items:", items))

	#print(paste("fechas: ", fechas))

	mapply(emolProcessor, items, fechas)


	paginacion <- remDr$findElement(using='css selector', '.next')

	#print(paginacion)

	pages_counter <- 0
	while(!is.null(paginacion) && pages_counter < limit){

		#print(paste("paginacion: ", paginacion))

		paginacion$clickElement()
		

		Sys.sleep(5)

		items <- remDr$findElements(using='css selector', '#LinkNoticia')
		fechas <- remDr$findElements(using='css selector', '.bus_txt_fuente')
	

		#print(paste("items:", items))
		#print(paste("fechas: ", fechas))

		mapply(emolProcessor, items, fechas)

		pages_counter <- pages_counter + 1


	} 
}	
