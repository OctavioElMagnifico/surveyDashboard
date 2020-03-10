#! Rscript
## tabla <- read.csv(file=Sys.getenv("OUTPUT_FILE"),header = T)
## tabla <- tabla[,-1]

entrada <- commandArgs(trailingOnly = TRUE)

print( entrada[1] )
