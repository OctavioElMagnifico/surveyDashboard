#! /usr/bin/env Rscript
set.seed(42)

entrada <- commandArgs(trailingOnly = TRUE)

if ( entrada[1] == TRUE ) {

            tabla <- data.frame(
            sampleID = seq(1:100),
            carbohydratesReported = rexp( n=100, rate=0.85 ),
            isOrganic = rbinom(n=100,size=1,prob=0.5),
            saturatedFatsReported = ( rnorm(n=100, mean=0.8,sd=3) )^2,
            saturatedFatsMeasured = ( rnorm(n=100, mean=1.1,sd=2) )^2,
            district = sample(x=c('missisipi','kentucky','maryland'),size=100,replace=TRUE)
            )

            carbohydratesMeasured <- c()

            for ( i in tabla[,2]) {
            carbohydratesMeasured <- c( carbohydratesMeasured, i * 2 + rnorm(n=1,mean=0,sd=0.3) )
                                    }

            tabla$carbohydratesMeasured <- carbohydratesMeasured

            model <- lm(  carbohydratesMeasured ~ ( carbohydratesReported + saturatedFatsReported + saturatedFatsMeasured  ) * isOrganic , tabla )
            analisys <- anova(model)

            pValues <- analisys$'Pr(>F)'

            tabla$fittedByOrganic <- model$fitted.values

            modelDist <- lm(  carbohydratesMeasured ~ ( carbohydratesReported + saturatedFatsReported + saturatedFatsMeasured  ) * district , tabla )

            tabla$fittedByDistrict <- modelDist$fitted.values

            write.csv( x=tabla, file=Sys.getenv("OUTPUT_FILE") )

}
