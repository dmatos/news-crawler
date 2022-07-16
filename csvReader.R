setwd('/home/dmatos/workspace2/aulas_R_web_scraping/aulas_csv')

dados <- read.csv('dados.csv', sep=';')

head(dados)

nrow(dados)

ncol(dados)

dados$Data.do.Decreto <- as.Date(dados$Data.do.Decreto , format="%d/%m/%Y")

dados_ltjuly2016 <-dados$Data.do.Decreto < as.Date('01/07/2016', format='%d/%m/%Y')

dados_gtejuly2016 <-dados$Data.do.Decreto >= as.Date('01/07/2016', format='%d/%m/%Y')

dados2 <- dados[dados_gtejuly2016,]

dados3 <- dados[dados$Data.do.Decreto < as.Date('30/06/2016', format='%d/%m/%Y'),]

estiagem <- dados2[dados2$Desastre == 'ESTIAGEM', ]

table(dados$Município)

tipo_desastre <- factor(t(dados['Desastre']))

tabela <- table(tipo_desastre)

total <- sum(tabela)

for(i in names(tabela)){
	print(i)
	print(tabela[[i]])
	percentual <- tabela[[i]] / total 
	print(percentual)
}