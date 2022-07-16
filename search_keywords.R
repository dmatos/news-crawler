
search_keywords = function(keywords, path){
	
	files <- list.files(path)

	news_by_date <- list()

	for(f in files){
		date_end_pos <- regexpr('-http', f) - 1

		news_date <- substr(f, 0, date_end_pos)

		print(news_date)

		if(is.null(news_by_date[[news_date]])){
			news_by_date[[news_date]] <- 0
		}

		news_filepath <- file.path('.',path, f)

		print(paste('OPEN:', news_filepath))

		news_txt <- readLines(news_filepath)

		print(news_txt)

		print(news_by_date[[news_date]])

		for(w in keywords){
			for(n in news_txt){
				if(regexpr(w, n) > 0){
					print(paste('FOUND:', w))
					news_by_date[[news_date]] <- news_by_date[[news_date]] + 1
					break
				}
			}
		}
	}

	print(news_by_date)

}