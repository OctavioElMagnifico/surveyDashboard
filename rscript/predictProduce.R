#! /usr/bin/env Rscript
library("rpart")
library("readr")

## fittedFlavor <- read_rds( path = "./dataAnalysis/flavorsTree.Rds" )

fittedFlavor <- read_rds( path = "./dataAnalysis/flavorsTree.Rds" )
fittedPoly <- read_rds( path = "./dataAnalysis/polyphenolsTree.Rds" )
fittedAntiox <- read_rds( path = "./dataAnalysis/antioxidantsTree.Rds" )

## modelRow <- read_csv( "../output/treeModelRow.csv" )

modelRow <- read_csv( "./output/treeModelRow.csv" )

treePredict <- function( newdata ) {

  output <- c(
    polyphenols = predict( fittedPoly, newdata ),
    antioxidants = predict( fittedAntiox, newdata ),
    flavor = predict( fittedFlavor, newdata )
  )

  return( output )
}

entrada <- commandArgs(trailingOnly=TRUE)

entradaEj <- list( "none", "certified_organic" )

newDataRow <- modelRow
for ( variable in entrada ) {
  newDataRow[1,variable] <- TRUE
}

newDataRow[1,'Type'] <- 'grape'
grapePredicted <- treePredict( newDataRow )
newDataRow[1,'Type'] <- 'kale'
kalePredicted <- treePredict( newDataRow )
newDataRow[1,'Type'] <- 'lettuce'
lettucePredicted <- treePredict( newDataRow )

fruitsColumn <- c( rep( 'kale', 3 ), rep( 'grape', 3 ), rep( 'lettuce', 3 ) )
parameterColumn <- c( rep( c( 'antioxidants', 'polyphenols', 'flavor' ) , 3 ) )
idColumn <- 1:9
valueColumn <- c( kalePredicted, grapePredicted, lettucePredicted )

output <- data.frame(
  id = idColumn,
  fruit = fruitsColumn,
  parameter = parameterColumn,
  value = valueColumn
)

write_csv( x=output, path=Sys.getenv("OUTPUT_FILE") )
