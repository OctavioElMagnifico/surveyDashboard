#! Rscript
set.seed(42)
tabla <- data.frame(
  sampleID = seq(1:100),
  carbohydratesReported = rexp( n=100, rate=0.85 ),
  carbohydratesMeasured = ( rnorm( n=100, mean=1, sd=2) )^2,
  isOrganic = rbinom(n=100,size=1,prob=0.5),
  saturatedFatsReported = ( rnorm(n=100, mean=0.8,sd=3) )^2,
  saturatedFatsMeasured = ( rnorm(n=100, mean=1.1,sd=2) )^2,
  district = sample(x=c('missisipi','kentucky','maryland'),size=100,replace=TRUE)
  )

write.csv( x=tabla, file="./compositions.csv" )
