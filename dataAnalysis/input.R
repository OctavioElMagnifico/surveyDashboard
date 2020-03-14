library("tidyverse")


columnSpecification <- cols(
    `ID` = col_character(),
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
toRename <- list(
  FarmPractices = 'Farm Practices',
  StoreName = 'Store Name',
  StoreBrand = 'Store Brand',
  Flavor0to5 = 'Flavor (0-5 scale)',
  ShippingTimehrs = "Shipping time hrs",
  TotalTimehrs = "Total time hrs",
  MaturityDays = "Maturity days",
  Sweetness0to5 ="Sweetness (0-5 scale)",
  Flavor0to5 = "Flavor (0-5 scale)",
  Taste0to5 = "Overall Taste (0-5 scale)",
  SoilOrganicMatter0to10cmPercentage = "Soil 0-10cm Organic Matter %",
  SoilOrganicMatter10to20cmPercentage = "Soil 10-20cm Organic Matter %"
  )
df <- rename( df, !!!toRename )

## Clasifications of different variables

variablesList <- colnames(df)

soilIndexes <- c( 39:90 )
soilVariables <- variablesList[soilIndexes]


cropIndexes <- c( 21:37 )
cropVariables <- variablesList[ cropIndexes ]

chemicalVariables <- c( soilVariables, cropVariables )

soilQualityVariables <- c( 'SoilOrganicMatter0to10cmPercentage', 'SoilOrganicMatter10to20cmPercentage' )

practicesList <- df %>% select( FarmPractices ) %>% map( ~strsplit( split="[;,\\s]", x = .x, perl=TRUE) ) %>% flatten() %>% flatten() %>% unique() %>% reduce( ~append(.x,.y) ) %>% na.omit()



farmersList <- df %>% select( Farmer ) %>% unique() %>% unlist() %>% unname()

productsList <- df %>% select( Type ) %>% unlist() %>% unique()

## Decoupling of 'Farm Practices' variable to get an actual variable for every practice.

isSubstring <- function( string, substring ) {
  index  <- grep( x=string, pattern=substring )
  if ( length( index ) == 0 ) {
    return( FALSE )
  }
  else {
    return( TRUE )
  }
}

individualFarmPracticesColumns <- tibble(.rows=nrow(df))
for ( i in practicesList ) {
  individualFarmPracticesColumns[,i] <- map_lgl( df$FarmPractices, ~isSubstring( substring='i', string = .x )  )
}
individualFarmPracticesColumns

df <- bind_cols( df, individualFarmPracticesColumns )


## The basic data frame df is ready.

buyerVariables <- c( "State", "Source", "ID",  "Type", "FarmPractices", "StoreName", "Farmer", "Polyphenols", "Antioxidants","Flavor0to5" , "ShippingTimehrs", "TotalTimehrs", "MaturityDays", "Sweetness0to5", "Flavor0to5", "Taste0to5" , practicesList, soilQualityVariables)

## Apparently, if the provider isn't named, you can be sure the product comes from a farm.
## No Row has both

## filter( df, is.na(StoreName) == is.na(Farmer) && is.na(Farmer) == TRUE  )

## They are predominantly unnamed farms

## filter( df, is.na(StoreName) == is.na(Farmer) ) %>% select( Source ) %>% unique()

analysisOfSourceColumn <- filter( df, is.na(StoreName) == is.na(Farmer)  ) %>% group_by( Source ) %>% summarize( n() )

## Obtainment of buyer's data table
buyersTable <- df %>% select( one_of( !!!buyerVariables ) ) %>% filter( !is.na( Antioxidants ), !is.na(Polyphenols) )

## We want to have a variable that tells us where does the product come from, wether it is a certain farmer, a certain store or other. In another column we'll store this provider's name or a unidentified indicator.

sourceNameColumn <- function( Farmer, StoreName, Source ) {
  noFarmer <- is.na(Farmer)
  noStore <- is.na( StoreName )
  output <- NA
  if ( noFarmer == FALSE ) {
    output <- Farmer
  } else if ( noStore == FALSE ) {
    output <- StoreName
  } else if ( !is.na( Source ) ) {
  output <- paste0( Source, 'Unnamed' )
  } else {
    output <- 'noData'
  }
  return( output )
 }

sourceClass <- function( Farmer, StoreName, Source ) {
  noFarmer <- is.na(Farmer)
  noStore <- is.na( StoreName )
  output <- NA
  if ( noFarmer == FALSE ) {
    output <- 'farmer'
  } else if ( noStore == FALSE ) {
    output <- 'namedStore'
  } else if ( !is.na( Source ) ) {
    output <- Source
  } else {
    output <- 'unnamed'
  }
  return( output )
}

reprocessed <- c( 'Farmer', 'StoreName', 'Source')


## na.omit() usefull omits any component containing a NA in a df.

sourceName <- pmap_chr( buyersTable %>% select( StoreName, Farmer, Source), sourceNameColumn  )
sourceClass <- pmap_chr( buyersTable %>% select( StoreName, Farmer, Source), sourceClass  )

buyersTable$sourceName <- sourceName
buyersTable$sourceClass <- sourceClass

## We remove reprocessed columns in order to get a lighter csv.

buyersCSV <- buyersTable %>% select( -one_of( reprocessed ) ) %>% filter( !is.na( Flavor0to5 ), !is.na( organic ), !is.na( State ), !is.na( Type ), !is.na(SoilOrganicMatter0to10cmPercentage), !is.na( SoilOrganicMatter10to20cmPercentage ) )



write_csv( x=buyersCSV, path='../output/buyers.csv' )


## Ideas to try

## La función recibe dos factores y algunos condicionantes y nos da un ANOVA para ver si algún dato se destaca. Do your own research!


## Treemap CVS

library('rpart')
treeModel <- rpart( Polyphenols ~ sourceClass + Type, buyersTable )

cat1 <- ( buyersTable$sourceClass ) %>% unique()
cat1

cat2 <-  ( buyersTable$Type ) %>% unique()


cat1Col <- c()
for ( i in cat1 ) {
  cat1Col <- c( cat1Col, rep( x=i, times = length( cat2 ) ) )
}
cat1Col

cat2Col <-  rep( x=cat2, times= length( cat1 ) )



hierarchyTree <-  tibble(
  sourceClass = cat1Col,
  Type  = cat2Col
)

treeModel <- rpart( Polyphenols ~ sourceClass + Type, buyersTable )

## predict( treeModel, newdata = list( Type = 'kale', sourceClass = 'farmer' ) )
## predict( treeModel, newdata = hierarchyTree[1,] )

hierarchyTree <- mutate( hierarchyTree, polyphenols = predict( treeModel, newdata = list( Type = Type, sourceClass = sourceClass ) ) )

hierarchyCSV <- hierarchyTree %>% rename( parentId = 'sourceClass' , 'id' = Type, 'size' =  polyphenols )

hierarchyCSV <- select( hierarchyCSV, id, parentId, size )

hierarchyCSV <- add_row( hierarchyCSV, parentId = rep('source', length(cat1) ), id = cat1, size = "", .before = 1  ) %>%  add_row( parentId = "", id = 'source', size = "", .before = 1  )

write_csv( x = hierarchyCSV, path='../output/hierarchy.csv' )
