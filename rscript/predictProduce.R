#! /usr/bin/env Rscript
library("rpart")
library("readr")

## fittedFlavor <- read_rds( path = "./dataAnalysis/flavorsTree.Rds" )
## fittedPoly <- read_rds( path = "./dataAnalysis/polyphenolsTree.Rds" )
## fittedAntiox <- read_rds( path = "./dataAnalysis/antioxidantsTree.Rds" )

## treePredict <- function( newdata ) {

##   output <- list(
##     polyphenols = predict( fittedPoly, newdata ),
##     antioxidants = predict( fittedAntiox, newdata ),
##     flavor = predict( fittedFlavor, newdata )
##   )

##   return( output )
## }

entrada <- commandArgs(trailingOnly=TRUE)

escupir <- entrada

cat( escupir )

write.csv( x=escupir, file=Sys.getenv("OUTPUT_FILE") )
