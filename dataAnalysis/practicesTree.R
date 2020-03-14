library("purrr")
library("rpart")
library("caret")

set.seed(42)

inputs <- read_rds( path="./treeInputs.Rds" )

data <- inputs$df

practicesList <- inputs$practices

treeModel <- rpart( Antioxidants ~ ., data %>% select( one_of( !!!practicesList, 'Antioxidants' ) ) )

## predict( treeModel, data[3,] )

dataAntiox <- data %>% select( one_of( !!!practicesList, 'Antioxidants', 'Type' ) ) %>% filter( !is.na( Antioxidants ) )


trainParametrization <- trainControl(
  method = "repeatedcv",
  number = 100,
  repeats = 3
)

fittedAntiox <- train(
  Antioxidants ~ none + certified_organic + biologique + biodynamic + local + nospray + non_gmo + hydroponic + Non_GMO + greenhouse + irrigation + biological_amendments + Type,
  data = dataAntiox,
  method = "rpart1SE",
  trControl = trainParametrization
)

## fittedAntiox

write_rds(x=fittedAntiox, path = "./antioxidantsTree.Rds")


dataPoly <- data %>% select( one_of( !!!practicesList, 'Polyphenols', 'Type' ) ) %>% filter( !is.na( Polyphenols ) )

fittedPoly <- train(
  Polyphenols ~ none + certified_organic + biologique + biodynamic + local + nospray + non_gmo + hydroponic + Non_GMO + greenhouse + irrigation + biological_amendments + Type,
  data = dataPoly,
  method = "rpart1SE",
  trControl = trainParametrization
)

## fittedPoly

write_rds(x=fittedPoly, path = "./polyphenolsTree.Rds")

dataFlavor <- data %>% select( one_of( !!!practicesList, 'Flavor0to5', 'Type' ) ) %>% filter( !is.na( Flavor0to5 ) )

fittedFlavor <- train(
  Flavor0to5 ~ none + certified_organic + biologique + biodynamic + local + nospray + non_gmo + hydroponic + Non_GMO + greenhouse + irrigation + biological_amendments + Type,
  data = dataFlavor,
  method = "rpart1SE",
  trControl = trainParametrization
)

## fittedFlavor

write_rds(x=fittedPoly, path = "./flavorsTree.Rds")

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
