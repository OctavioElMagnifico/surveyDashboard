#! /usr/bin/env Rscript
## library("rpart")
## library("readr")

## fittedFlavor <- read_rds( path = "./dataAnalysis/flavorsTree.Rds" )

fittedFlavor <- readRDS( file = "./dataAnalysis/flavorsTree.Rds" )
fittedPoly <- readRDS( file = "./dataAnalysis/polyphenolsTree.Rds" )
fittedAntiox <- readRDS( file = "./dataAnalysis/antioxidantsTree.Rds" )

## modelRow <- read_csv( "../output/treeModelRow.csv" )

modelRow <- read.csv( file = "./output/treeModelRow.csv" )

treePredict <- function( newdata ) {

  output <- c(
    polyphenols = predict( fittedPoly, newdata ),
    antioxidants = predict( fittedAntiox, newdata ),
    flavor = predict( fittedFlavor, newdata )
  )

  return( output )
}

input <- commandArgs(trailingOnly=TRUE)

## entradaEj <- list( "certified_organic", "irrigation" )
## input <- entradaEj

newDataRow <- modelRow
for ( variable in input ) {
  newDataRow[1,variable] <- 1
}

referenceLevels <- modelRow
referenceLevels[1,'none'] <- 1

newDataRow$Type <- 'grape'
grapePredicted <- treePredict( newDataRow )
newDataRow$Type <- 'kale'
kalePredicted <- treePredict( newDataRow )
newDataRow$Type <- 'lettuce'
lettucePredicted <- treePredict( newDataRow )



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

referenceTable <- read.csv( file = './output/fruitsReference.csv')

output$relative <- output$value / referenceTable$value

write.csv( x=output, file=Sys.getenv("OUTPUT_FILE") )

## Getting the reference levels:



## referenceLevels <- modelRow
## referenceLevels[1,'none'] <- 1

## referenceLevels[1,'Type'] <- 'grape'
## grapePredicted <- treePredict( referenceLevels )
## referenceLevels[1,'Type'] <- 'kale'
## kalePredicted <- treePredict( referenceLevels )
## referenceLevels[1,'Type'] <- 'lettuce'
## lettucePredicted <- treePredict( referenceLevels )

## Be carefull with the Id column.

## valueColumn <- c( kalePredicted, grapePredicted, lettucePredicted )
## referenceLevelsTable <- data.frame(
##   id = idColumn + length(idColumn),
##   fruit = fruitsColumn,
##   parameter = parameterColumn,
##   value = valueColumn,
##   relative = rep(1)
## )

## output
## referenceLevelsTable


## write_csv( x=referenceLevelsTable, path="../output/fruitsReference.csv" )
