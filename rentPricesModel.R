library(dplyr)
library(xgboost)

# Substituir aqui "" o diretorio que ira conter os dados.
# Exemplo: setwd("C:/.../Bernardo/INDICUS PROJECT)

setwd("")

# Leitura dos dados. Substituir em file="" o nome do arquivo .csv utilizado
# Exemplo: read.csv(file="datasetRentPrices.csv" ...)

Prices_data <- read.csv(file=" .csv", header=TRUE, sep=",", stringsAsFactors = FALSE)

# A proxima etapa consiste em transformar os valores NA em zero, ja que resultam
# de uma divisao por zero.

Prices_data$reviews_por_mes <- replace(Prices_data$reviews_por_mes, is.na(Prices_data$reviews_por_mes), 0)

# Aqui, transformamos a variavel "Tipo de Quarto" em uma numerica e removemos as 6 primeiras colunas
# uma vez q nao sao uteis para a matriz de correlacao a ser feita a seguir.

uniquerooms <- unique(Prices_data$room_type)

pricesData2 <- Prices_data %>%
  mutate(
    room_type = case_when(
      room_type == "Entire home/apt" ~ 1,
      room_type == "Private room" ~ 0,
      room_type == "Shared room" ~ -1,
      TRUE ~ NA_real_
    )
  ) %>%
  select(where(is.numeric), -ultima_review, -id, -host_id, -calculado_host_listings_count)

### Modelo de Previsao ###

### Data Slicing ###

set.seed(123) #seed pra que seja sempre o mesmo
indexI <- sample(1:nrow(pricesData2), size=nrow(pricesData2))
trainDataset <- pricesData2[indexI[1:(round(0.8*nrow(pricesData2)))], ]
testDataset <- pricesData2[indexI[((round(0.8*nrow(pricesData2))) + 1):nrow(pricesData2)], ]

## XGBOOST Modelo de Regressao Selecionado Final ##

featuresXGB <- c("latitude", "longitude", "room_type", "minimo_noites", "numero_de_reviews")
targetXGB <- "price"

# 
trainXGBdata <- model.matrix(~ . - 1, data = trainDataset[, c(featuresXGB,targetXGB)])
testXGBdata <- model.matrix(~ . - 1, data = testDataset[, c(featuresXGB,targetXGB)])

#Matriz XGB
dtrain <- xgb.DMatrix(data = trainXGBdata, label = trainXGBdata[, targetXGB])
dtest <- xgb.DMatrix(data = testXGBdata, label = testXGBdata[, targetXGB])

params <- list(
  objective = "reg:squarederror",  
  booster = "gbtree",              
  eval_metric = "rmse"
)

xgbTeste1 <- xgboost(params = params, data = dtrain, nrounds = 100)
xgbPredictions1 <- predict(xgbTeste1, dtest)
xgbMAE1 <- mean(abs(xgbPredictions1 - testXGBdata[, targetXGB]))
xgbMSE1 <- mean((xgbPredictions1 - testXGBdata[, targetXGB])^2)
xgbMAPE1 <- mean(abs(xgbPredictions1 - testXGBdata[, targetXGB]) / testXGBdata[, targetXGB]) * 100
XGBValuation <- data.frame(xgbPredictions1)

##
while(TRUE){
  condition <- readline(prompt="To get a suggested renting price enter Y, or N to exit: ")
  if (condition=="Y"){
    newID <- as.numeric(readline(prompt = "Enter id: "))
    newNome <- readline(prompt = "Enter Ad Name: ")
    newHostName <- readline(prompt= "Enter Host Name: ")
    newHostId <- as.numeric(readline(prompt = "Enter host id: "))
    newBairroG <- readline(prompt = "Enter bairro group: ")
    newBairro <- readline(prompt = "Enter bairro: ")
    newLatitude <- as.numeric(readline(prompt = "Enter latitude: "))
    newLongitude <- as.numeric(readline(prompt = "Enter longitude: "))
    newRoomType <- readline(prompt = "Enter room type: ")
    if (newRoomType == "Entire home/apt"){
      newRoomType <- 1
    }
    else{
      newRoomType <- 0
    }
    newPrice <- as.numeric(readline(prompt = "Enter price: "))
    newMinimo <- as.numeric(readline(prompt = "Enter minimo de noites: "))
    newReviews <- as.numeric(readline(prompt = "Enter number of reviews: "))
    newLastReview <- as.Date(readline(prompt = "Enter last review date: "))
    newReviewsMes <- as.numeric(readline(prompt = "Enter number or reviews/mes: "))
    newHostListings <- as.numeric(readline(prompt = "Enter host listings: "))
    newDisponibilidade <- as.numeric(readline(prompt = "Enter disponibilidade 365: "))
    
    newDF <- data.frame(
      latitude = newLatitude,
      longitude = newLongitude,
      room_type = newRoomType,
      price = newPrice,
      minimo_noites = newMinimo,
      numero_de_reviews = newReviews,
      ultima_review = newLastReview,
      reviews_por_mes = newReviewsMes,
      disponibilidade_365 = newDisponibilidade
    )
    
    newXGBtestdata <- model.matrix(~ . - 1, data = newDF[, c(featuresXGB,targetXGB)])
    newDtest <- xgb.DMatrix(data = newXGBtestdata, label = newXGBtestdata[, targetXGB])
    newXGBPredictions <- predict(xgbTeste1, newDtest)
    newXGBValuation <- data.frame(newXGBPredictions)
    differencePrice <- newDF$price - newXGBValuation$newXGBPredictions
    cat(
      "The suggested price is: ",
      newXGBValuation$newXGBPredictions,
      "\nThe stated price was of: ",
      newDF$price,
      "\nDifference of: ",
      differencePrice
    )
  }
  else if (condition=="N"){
    break
  }
  else {
    cat("I did not understand. Try again.\n")
  }
}