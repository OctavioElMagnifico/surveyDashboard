#! /usr/bin/env Rscript
library("rpart")

## fittedFlavor <- readRds( path = "flavorsTree.Rds" )
## fittedPoly <- readRds( path = "polyphenolsTree.Rds" )
## fittedAntiox <- readRds( path = "antioxidantsTree.Rds" )

## treePredict <- function( newdata ) {

##   output <- list(
##     polyphenols = predict( fittedPoly, newdata ),
##     antioxidants = predict( fittedAntiox, newdata ),
##     flavor = predict( fittedFlavor, newdata )
##   )

##   return( output )
## }

entrada <- commandArgs(trailingOnly=TRUE)

escupir <- entrada[1]

cat( escupir )

write.csv( x=escupir, file=Sys.getenv("OUTPUT_FILE") )
