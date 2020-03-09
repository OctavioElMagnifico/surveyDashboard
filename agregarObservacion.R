#! Rscript
set.seed(42)

tabla <- read.csv(file="compositions.csv",header = T)
tabla <- tabla[,-1]


ultimaID <- max( tabla$sampleID )

fila <- data.frame(
  sampleID = ultimaID + 1,
  carbohydratesReported = rexp( n=1, rate=0.85 ),
  carbohydratesMeasured = ( rnorm( n=1, mean=1, sd=2) )^2,
  isOrganic = rbinom(n=1,size=1,prob=0.5),
  saturatedFatsReported = ( rnorm(n=1, mean=0.8,sd=3) )^2,
  saturatedFatsMeasured = ( rnorm(n=1, mean=1.1,sd=2) )^2,
  district = sample(x=c('missisipi','kentucky','maryland'),size=1,replace=TRUE)
)

tabla2 <- rbind(tabla,fila)

write.csv( x=tabla2, file="./compositions.csv" )
