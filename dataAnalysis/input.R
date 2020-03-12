library("tidyverse")
df <- read_csv("~/D3/surveyDashboard/dataAnalysis/rfc 2020 data (viz).csv")
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
  Taste0to5 = "Overall Taste (0-5 scale)"
  )

df <- rename( df, !!!toRename )

variablesList <- colnames(df)

soilVariables <- c( 39:90 )
cropVariables <- c( 21:37 )

chemicalVariables <- c( soilVariables, cropVariables )

practicesList <- df %>% select( FarmPractices ) %>% map( ~strsplit( split="[;,\\s]", x = .x, perl=TRUE) ) %>% flatten() %>% flatten() %>% unique() %>% reduce( ~append(.x,.y) ) 

farmersList <- df %>% select( Farmer ) %>% unique() %>% unlist() %>% unname()

productsList <- df %>% select( Type ) %>% unlist() %>% unique()



isSubstring <- function( string, substring ) {
  index  <- grep( x=string, pattern=substring )
  if ( length( index ) == 0 ) {
    return( FALSE )
  }
  else {
    return( TRUE )
  }
}

isIrrigating <- function(x) {
  isSubstring( substring="irrigation", string =x )
}

filter( df, FarmPractices == 'other' )


hasPractice <- function( practice, data ) {
  filtering <- function( x ) {
    isSubstring( string=practice, substring=x )
  }
  BoolColumn <- map( data$FarmPractices, filtering )
  return( which( BoolColumn == TRUE ) )
}

hasPractice( df, practice = 'irrigation' )

buyerVariables <- c( "State", "Source", "ID",  "Type", "FarmPractices", "StoreName", "Farmer", "Polyphenols", "Antioxidants","Flavor0to5" , "ShippingTimehrs", "TotalTimehrs", "MaturityDays", "Sweetness0to5", "Flavor0to5", "Taste0to5" )

## Apparently, if the provider isn't named, you can be sure the product comes from a farm.
## No Row has both
filter( df, is.na(StoreName) == is.na(Farmer) && is.na(Farmer) == TRUE  )
## They are predominantly unnamed farms
filter( df, is.na(StoreName) == is.na(Farmer) ) %>% select( Source ) %>% unique()
filter( df, is.na(StoreName) == is.na(Farmer)  ) %>% group_by( Source ) %>% summarize( n() )


## Obtainment of buyer's data table
buyersTable <- df %>% select( one_of( !!!buyerVariables ) ) %>% filter( !is.na( Antioxidants ), !is.na(Polyphenols) )

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
    output <- paste0( Source, 'Unnamed' )
  } else {
    output <- 'unnamed'
  }
  return( output )
}


## na.omit() usefull omits any component containing a NA in a df.

sourceName <- pmap_chr( buyersTable %>% select( StoreName, Farmer, Source), sourceNameColumn  )
sourceClass <- pmap_chr( buyersTable %>% select( StoreName, Farmer, Source), sourceClass  )

buyersTable$sourceName <- sourceName
buyersTable$sourceClass <- sourceClass

write_csv( x=buyersTable, path='buyersTable.csv' )

## La función recibe dos factores y algunos condicionantes y nos da un ANOVA para ver si algún dato se destaca. Do your own research!
