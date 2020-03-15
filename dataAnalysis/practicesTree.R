library("tidyverse")
library("rpart")
library("caret")
library("party")
library("gpls")

set.seed(42)

inputs <- read_rds( path="../dataAnalysis/treeInputs.Rds" )

data <- inputs$df

practicesList <- inputs$practices

treeModel <- rpart( Antioxidants ~ ., data %>% select( one_of( !!!practicesList, 'Antioxidants' ) ) )

## predict( treeModel, data[3,] )

dataAntiox <- data %>% select( one_of( !!!practicesList, 'Antioxidants', 'Type' ) ) %>% filter( !is.na( Antioxidants ) )

trainParametrization <- trainControl(
  method = "repeatedcv",
  number = 10,
  repeats = 3
)

fittedAntiox <- train(
  Antioxidants ~ none + certified_organic + biologique + biodynamic + local + nospray + non_gmo + hydroponic + Non_GMO + greenhouse + irrigation + biological_amendments + Type,
  data = dataAntiox,
  method = "lm",
  trControl = trainParametrization
)

## fittedAntiox

write_rds(x=fittedAntiox, path = "./antioxidantsTree.Rds", compress = "gz")


dataPoly <- data %>% select( one_of( !!!practicesList, 'Polyphenols', 'Type' ) ) %>% filter( !is.na( Polyphenols ) )

fittedPoly <- train(
  Polyphenols ~ none + certified_organic + biologique + biodynamic + local + nospray + non_gmo + hydroponic + Non_GMO + greenhouse + irrigation + biological_amendments + Type,
  data = dataPoly,
  method = "lm",
  trControl = trainParametrization
)

## fittedPoly

write_rds(x=fittedPoly, path = "./polyphenolsTree.Rds", compress = "gz")

dataFlavor <- data %>% select( one_of( !!!practicesList, 'Flavor0to5', 'Type' ) ) %>% filter( !is.na( Flavor0to5 ) )

fittedFlavor <- train(
  Flavor0to5 ~ none + certified_organic + biologique + biodynamic + local + nospray + non_gmo + hydroponic + Non_GMO + greenhouse + irrigation + biological_amendments + Type,
  data = dataFlavor,
  method = "lm",
  trControl = trainParametrization
)

## fittedFlavor

write_rds(x=fittedPoly, path = "./flavorsTree.Rds", compress = "gz")

## Varaibles to add: Soil conservation, taste, sweetness.

treePredict <- function( newdata ) {

output <- list(
  polyphenols = predict( fittedPoly, newdata ),
  antioxidants = predict( fittedAntiox, newdata ),
  flavor = predict( fittedFlavor, newdata )
  )

return( output )
}

## treePredict( data[3,] )

trainParametrization <- trainControl(
  method = "repeatedcv",
  number = 10,
  repeats = 3
)

dataCtree <- data %>% select( one_of( !!!practicesList, 'Flavor0to5', 'Antioxidants', 'Polyphenols', 'Type' ) ) %>% filter( !is.na( Flavor0to5 ), !is.na( Antioxidants ), !is.na( Polyphenols ) )

ctreeFlavor <- train(
  Flavor0to5 + Polyphenols + Antioxidants ~ none + certified_organic + biologique + biodynamic + local + nospray + non_gmo + hydroponic + Non_GMO + greenhouse + irrigation + biological_amendments + Type,
  data = dataCtree,
  method = "ctree",
  tuneGrid = expand.grid( mincriterion = c( seq(0.9, 0.99, length.out = 12) ) ),
  trControl = trainParametrization
)

## PLS

trainParametrization <- trainControl(
  method = "repeatedcv",
  number = 10,
  repeats = 3
)

dataCtree <- data %>% select( one_of( !!!practicesList, 'Flavor0to5', 'Antioxidants', 'Polyphenols', 'Type' ) ) %>% filter( !is.na( Flavor0to5 ), !is.na( Antioxidants ), !is.na( Polyphenols ) )

plsFlavor <- train(
  Flavor0to5 ~ none + certified_organic + biologique + biodynamic + local + nospray + non_gmo + hydroponic + Non_GMO + greenhouse + irrigation + biological_amendments + Type,
  data = dataCtree,
  method = "",
  trControl = trainParametrization
)



## Get means by fruit for normalization

## I went for the prediction with none as the only practice for coherency.


## data %>% filter( Type == 'kale' ) %>% select( one_of( 'Antioxidants'  ) ) %>% filter( !is.na(Antioxidants) ) %>% unlist() %>% mean()

## meanByFruit <- 
## data %>% filter( Type == 'kale' ) %>% select( one_of( 'Antioxidants'  ) ) %>% filter( !is.na(Antioxidants) ) %>% unlist() %>% mean()
