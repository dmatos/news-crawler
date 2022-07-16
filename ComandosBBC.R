#####scraping#####

#comando para determinar o diretório de trabalho
setwd('/home/dmatos/workspace2/aulas_R/aulas_R_web_scraping/')

install.packages('lubridate')

#comando para carregar o script 
source("bbc_scrap.R")
#comando para carregar o tamplate da query
queryListParams <-bbcQueryListExample()
#comando para o que eu procurar como se estivesse no site

#Pesquisa2
#query_pt <- 'palestina'
#query_pt <- 'faixa+de+gaza'
#query_pt <- 'cisjordânia'
#query_pt <- 'palestinos'
#Pesquisa3
#query_pt <- 'pandemia+comunicação+de+riscos'
#Pesquisa4
#Pesquisa1
query_pt <- 'oriente+médio+migração'
#query_pt <- 'oriente+médio+refugio'
#query_pt <- 'oriente+médio+refugiados'
#query_pt <- 'oriente+médio+imigrantes'
#query_pt <- 'oriente+médio+migrantes'
#query_pt <- 'oriente+médio+deslocamentos+forçados'

queryListParams$q<-query_pt
#comando para realizar a busca no site da folha com os valores acima 
start_date<-'01/01/2019'
end_date<-'30/06/2021'
queryListParams$sd <- start_date
queryListParams$ed <- end_date

bbcQuery(queryListParams, start_date = start_date, end_date = end_date)
print('terminou busca para ')
print(query_pt)
print(start_date)
print(end_date)


#######mining#######

source('search_keywords.R')

keywords_list_pt <- list('terrorismo','ataque','terrorista','jihadista','atentado','parlamento','britânico','inglês','londres','Westminster')

keywords_list_en <- list('terrorism','attack','terrorist','jihadist','parliament','british','london','Westminster')

resultado <-search_keywords(keywords_list_en, 'bbc')

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