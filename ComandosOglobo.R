#####scraping#####

#comando para determinar o diretório de trabalho
setwd('/home/dmatos/workspace2/aulas_R/aulas_R_web_scraping/')

#comando para carregar o script 
source("oglobo_scrap.R")
#comando para carregar o tamplate da query
queryListParams <-ogloboQueryListExample()
#comando para o que eu procurar como se estivesse no site

#comando para o que eu procurar como se estivesse no site
query_pt <- 'venezuela+venezuelanos+migração'
queryListParams$q<-query_pt

#comando para realizar a busca no site da folha com os valores acima 
start_date<-'01/10/2016'
end_date<-'31/03/2017'
##
start_date<-'01/04/2018'
end_date<-'30/04/2018'
##
start_date<-'01/08/2018'
end_date<-'31/08/2018'
##
start_date<-'01/03/2020'
end_date<-'30/06/2021'

ogloboQuery(queryListParams, start_date, end_date,limit=100)
print('terminou busca para ')
print(query_pt)
print(start_date)
print(end_date)

#######mining#######


source('search_keywords.R')

keywords_list_pt <- list('Lula')

resultado <-search_keywords(keywords_list_pt, 'oglobo')

print('resultado')

print(resultado)

print(sum(unlist(resultado)))