Ola! Bem vindo ao meu programa preditor de precos baseado nos dataset de um site de alugueis! Como estaremos trabalhando com R (ate o momento domino muito pouco o Python, embora esteja estudando atualmente, me sinto mais confortavel para utiliza-lo), sera necessario realizar breves modificacoes no codigo antes de utiliza-lo. Assim, faremos:

0- O programa para modelagem a ser aberto e o rentPricesModel.R - abra-o no programa de interesse (VSCode, Rstudio, etc)

1- Bibliotecas! Antes de mais nada e necessario possuir as seguintes bibliotecas instaladas (Caso voce nao tenha, o comando necessario sera - install.packages(c("dplyr", "xgboost"))

library(dplyr)
library(xgboost)

2- Otimo, tudo certo :). Agora teremos que acrescentar, na linha 7, o working directory (em portugues, diretorio de trabalho) que nada mais e que a pasta no computador que o R ira "trabalhar". No meu caso, o meu seria: 
"C:/Users/.../Bernardo/INDICUS PROJECT"

Caso nao consiga, basta abrir o explorador de arquivos copiar e colar. Atencao: muitas vezes as barras sao invertidas, teste e caso nao funcione, faca a inversao das barras :)

3- Bom, agora e preciso fazer a leitura do arquivo com o dataset. Para isso sera necessario mudar o arquivo na linha 12 do codigo, na funcao read.csv(). No meu caso, seria:
read.csv(file="datasetRentPrices.csv", header=TRUE, sep=",", stringsAsFactors = FALSE)

Basta colocar o nome do arquivo.csv dentro das aspas " " e devera funcionar! Atente-se tambem ao separador "," caso esteja usando outro arquivo que nao o disponivel nesse repositorio.

4- Agora e so rodar o codigo. O console devera abrir e te pedir informacoes relativas ao imovel de consulta! 
Lembrando que: as entradas devem ser feitas SEM aspas simples ou duplas, o programa ja identifica numeros e caracteres (strings); na opcao "room type" as entradas devem ser, obrigatoriamente, Entire room/apt, Private room ou Shared room, sem aspas e com o espacamento e maiusculas corretas; no campo data, a data sera YYYY-MM-DD.

Exemplo de saida:

The suggested price is:  225.0338 
The stated price was of:  225 
Difference of:  -0.03378296

Obrigado!
:)
