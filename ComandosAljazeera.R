#####scraping#####

#comando para determinar o diretório de trabalho
setwd('/home/dmatos/workspace2/aulas_R/aulas_R_web_scraping/')

#comando para carregar o script 
source("aljazeera_scrap.R")
#comando para carregar o tamplate da query
queryListParams <-aljazeeraQueryListExample()
#comando para o que eu procurar como se estivesse no site

query_en <- 'humanitarian+crisis'

queryListParams$q<-query_en

#comando para definição de data de início do objeto pesquisado
#oglobo$sf<-'1'
#comando para definição de data de término do objeto pesquisado
#oglobo$np<-'1'
#comando para realizar a busca no site da folha com os valores acima 
start_date<-'01/01/2016'
end_date<-'31/12/2016'

queryListParams$sd <- start_date
queryListParams$ed <- end_date

aljazeeraQuery(queryListParams, start_date = start_date, end_date = end_date)


#######mining#######

source('search_keywords.R')

keywords_list_pt <- list('terrorismo','ataque','terrorista','jihadista','atentado','parlamento','britânico','inglês','londres','Westminster')

keywords_list_en <- list('terrorism','attack','terrorist','jihadist','parliament','british','london','Westminster')

resultado <-search_keywords(keywords_list_en, 'aljazeera')

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