#! Rscript
tabla <- read.csv(file=Sys.getenv("OUTPUT_FILE"),header = T)
tabla <- tabla[,-1]


ultimaID <- max( tabla$sampleID  )

fila <- data.frame(
  sampleID = ultimaID + 1,
  carbohydratesReported = rexp( n=1, rate=0.85 ),
  isOrganic = rbinom(n=1,size=1,prob=0.5),
  saturatedFatsReported = ( rnorm(n=1, mean=0.8,sd=3) )^2,
  saturatedFatsMeasured = ( rnorm(n=1, mean=1.1,sd=2) )^2,
  district = sample(x=c('missisipi','kentucky','maryland'),size=1,replace=TRUE)
)

fila$carbohydratesMeasured <- 2 * fila$carbohydratesReported + rnorm(n=1,mean=0,sd=0.4)


model <- lm(  carbohydratesMeasured ~ ( carbohydratesReported + saturatedFatsReported + saturatedFatsMeasured  ) * isOrganic , tabla )
analisys <- anova(model)

pValues <- analisys$'Pr(>F)'

fila$fittedByOrganic <- predict(model, fila) 

modelDist <- lm(  carbohydratesMeasured ~ ( carbohydratesReported + saturatedFatsReported + saturatedFatsMeasured  ) * district , tabla )

fila$fittedByDistrict <- predict(modelDist, fila)

tabla2 <- rbind(tabla,fila)

write.csv( x=tabla2, file=Sys.getenv("OUTPUT_FILE") )
