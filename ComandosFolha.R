#####scraping#####

#comando para determinar o diretório de trabalho
setwd('/home/dmatos/workspace2/aulas_R/aulas_R_web_scraping/')

#instalar pacotes caso não sejam encontrados
install.packages('curl')
install.packages('RCurl')
install.packages('rvest')

#comando para carregar o script 
source("folha_scrap.R")

#comando para carregar o tamplate da query
queryListParams <-folhaQueryListExample()

#comando para definição de data de início do objeto pesquisado
#oglobo$sf<-'1'
#comando para definição de data de término do objeto pesquisado
#oglobo$np<-'1'


#comando para o que eu procurar como se estivesse no site
query_pt <- 'jornalistas+moral+injury'
#query_pt <- 'siria+estado+islamico'
queryListParams$q<-query_pt

#comando para realizar a busca no site da folha com os valores acima 
start_date<-'01/06/2021'
end_date<-'30/06/2022'

queryListParams$sd <- start_date
queryListParams$ed <- end_date
  
folhaQuery(queryListParams)

print('terminou busca para ')
print(query_pt)
print(start_date)
print(end_date)

#######mining#######

source('search_keywords.R')

keywords_list_pt <- list('Turquia migração')

resultado <-search_keywords(keywords_list_pt, 'folha')

print('resultado')

print(resultado)

print(sum(unlist(resultado)))