library("tidyverse")

columnSpecification <- cols(
    `Soil 0-10cm Organic Matter %` = col_double(),
    `Soil 0-10cm Total Organic Carbon %` = col_double(),
    `Soil 0-10cm pH` = col_double(),
    `Soil 0-10cm Soil Respiration` = col_double(),
    `Soil 0-10cm, Sodium (noisy)` = col_double(),
    `Soil 0-10cm, Magnesium (noisy)` = col_double(),
    `Soil 0-10cm, Aluminum` = col_double(),
    `Soil 0-10cm, Silicon %` = col_double(),
    `Soil 0-10cm, Phosphorous` = col_double(),
    `Soil 0-10cm, Sulfur` = col_double(),
    `Soil 0-10cm, Potassium` = col_double(),
    `Soil 0-10cm, Calcium` = col_double(),
    `Soil 0-10cm, Titanium` = col_double(),
    `Soil 0-10cm, Vanadium` = col_double(),
    `Soil 0-10cm, Chromium` = col_double(),
    `Soil 0-10cm, Manganese` = col_double(),
    `Soil 0-10cm, Iron` = col_double(),
    `Soil 0-10cm, Nickel` = col_double(),
    `Soil 0-10cm, Copper` = col_double(),
    `Soil 0-10cm, Zinc` = col_double(),
    `Soil 0-10cm, Arsenic` = col_double(),
    `Soil 0-10cm, Selenium` = col_double(),
    `Soil 0-10cm, Rubidium` = col_double(),
    `Soil 0-10cm, Strontium` = col_double(),
    `Soil 0-10cm, Molybdenum` = col_double(),
    `Soil 0-10cm, Lead` = col_double(),
    `Soil 10-20cm Organic Matter %` = col_double(),
    `Soil 10-20cm Total Organic Carbon %` = col_double(),
    `Soil 10-20cm pH` = col_double(),
    `Soil 10-20cm Soil Respiration` = col_double(),
    `Soil 10-20cm, Sodium (noisy)` = col_double(),
    `Soil 10-20cm, Magnesium (noisy)` = col_double(),
    `Soil 10-20cm, Aluminum` = col_double(),
    `Soil 10-20cm, Silicon %` = col_double(),
    `Soil 10-20cm, Phosphorous` = col_double(),
    `Soil 10-20cm, Sulfur` = col_double(),
    `Soil 10-20cm, Potassium` = col_double(),
    `Soil 10-20cm, Calcium` = col_double(),
    `Soil 10-20cm, Titanium` = col_double(),
    `Soil 10-20cm, Vanadium` = col_double(),
    `Soil 10-20cm, Chromium` = col_double(),
    `Soil 10-20cm, Manganese` = col_double(),
    `Soil 10-20cm, Iron` = col_double(),
    `Soil 10-20cm, Nickel` = col_double(),
    `Soil 10-20cm, Copper` = col_double(),
    `Soil 10-20cm, Zinc` = col_double(),
    `Soil 10-20cm, Arsenic` = col_double(),
    `Soil 10-20cm, Selenium` = col_double(),
    `Soil 10-20cm, Rubidium` = col_double(),
    `Soil 10-20cm, Strontium` = col_double(),
    `Soil 10-20cm, Molybdenum` = col_double(),
  `Soil 10-20cm, Lead` = col_double(),
  `Planting` = col_character()
)


df <- read_csv( "./rfc 2020 data (viz).csv", col_types = columnSpecification)

variablesList <- colnames(df)

chemicalMeasures <- c( 21:90 )

anovaData <- df[ ,-chemicalMeasures ]

statesList <- anovaData$State %>% unique
statesList

quant <- anovaData %>% group_by( State ) %>% summarize( population = n() ) %>% arrange( - population )
quant

state <- 'michigan'
product <- 'kale'

filteredData <- anovaData %>% filter( State == !!state ) %>% filter( Type == !!product )
filteredData

explained <- "Antioxidants"
factor1 <- "Store Name"
factor2 <- "Source"

formGenerated <- paste0( explained, '~', factor1,  '*' ,factor2,"\'" )
formGenerated

model <- lm( formula=formGenerated , filteredData )
model

summary( model )

model2 <- lm( Antioxidants ~ Source, filteredData )
model2

summary(model2)
