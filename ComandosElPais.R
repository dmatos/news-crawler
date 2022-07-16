#####scraping#####

#comando para determinar o diretório de trabalho
setwd('/home/dmatos/workspace2/aulas_R/aulas_R_web_scraping/')

#comando para carregar o script 
source("elpais_scrap.R")
#comando para carregar o tamplate da query
queryListParams <-elpaisQueryListExample()
#comando para o que eu procurar como se estivesse no site
#Pesquisa1
#query_pt <- 'oriente+médio+migração'
#query_pt <- 'oriente+médio+refugio'
#query_pt <- 'oriente+médio+refugiados'
#query_pt <- 'oriente+médio+imigrantes'
#query_pt <- 'oriente+médio+migrantes'
#query_pt <- 'oriente+médio+deslocamentos+forçados'

query_es <- 'crisis+humanitaria'

queryListParams$qt<-query_es

queryListParams$np <- 2

#comando para definição de data de início do objeto pesquisado
#oglobo$sf<-'1'
#comando para definição de data de término do objeto pesquisado
#oglobo$np<-'1'
#comando para realizar a busca no site da folha com os valores acima 
start_date<-'01/01/2016'
end_date<-'31/12/2017'

queryListParams$sd <- start_date
queryListParams$ed <- end_date
queryListParams$np <- 111

out <- tryCatch(
	{
		elpaisQuery2(queryListParams, start_date = start_date, end_date = end_date, limit=1000)
	}, error = function(cond){
		message(paste("last page reached"))
		return(cond)
	}
)
print(paste("tryCatch caught: ", out))

#######mining#######

source('search_keywords.R')

#keywords_list_pt <- list('Venezuela')
#keywords_list_pt <- list('Siria')
#keywords_list_pt <- list('Yemen')
keywords_list_pt <- list('Sudán del Sur')


resultado <-search_keywords(keywords_list_pt, 'elpais')

print('resultado')

print(resultado)

print(sum(unlist(resultado)))

#Burkina
#terrorismo+ataque+terrorista+jihadista+atentado+burkina+faso+ouagadougou
#terrorism+attack+terrorist+jihadist+urkina+faso+ouagadougou
#Data: 2/3/2018 a 2/4/2018
#Londres
#terrorismo+ataque+terrorista+jihadista+atentado+parlamento+britânico+inglês+londres+Westminster
#terrorism+attack+terrorist+jihadist+parliament+british+london+Westminster
#Data: 14/08/2018 a 14/09/2018