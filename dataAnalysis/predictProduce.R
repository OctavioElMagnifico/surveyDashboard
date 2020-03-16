#! /usr/bin/env Rscript
library("rpart")
setwd("../dataAnalysys/")
fittedFlavor <- read_rds( path = "flavorsTree.Rds" )
fittedPoly <- read_rds( path = "polyphenolsTree.Rds" )
fittedAntiox <- read_rds( path = "antioxidantsTree.Rds" )

treePredict <- function( newdata ) {

  output <- list(
    polyphenols = predict( fittedPoly, newdata ),
    antioxidants = predict( fittedAntiox, newdata ),
    flavor = predict( fittedFlavor, newdata )
  )

  return( output )
}
