#####scraping#####

#comando para determinar o diretório de trabalho
setwd('/home/dmatos/workspace2/aulas_R/aulas_R_web_scraping/')

#comando para carregar o script 
source("nytimes_scrap.R")
#comando para carregar o tamplate da query
queryListParams <-nytimesQueryListExample()
#comando para o que eu procurar como se estivesse no site

query_en <- 'COP+climate+change+conference'

queryListParams$query<-query_en

#comando para definição de data de início do objeto pesquisado
#oglobo$sf<-'1'
#comando para definição de data de término do objeto pesquisado
#oglobo$np<-'1'
#comando para realizar a busca no site da folha com os valores acima 
start_date<-'20191202'
end_date<-'20191214'

queryListParams['sort'] = 'newest'
queryListParams$startDate <- start_date
queryListParams$endDate <- end_date

nytimesQuery2(queryListParams)


#######mining#######

source('search_keywords.R')

#keywords_list <- list('Venezuela')
#keywords_list <- list('Syria')
#keywords_list <- list('Yemen')
keywords_list <- list('Southern Sudan')


resultado <-search_keywords(keywords_list, 'nytimes')

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
