library("tidyverse")
df <- read_csv("~/D3/surveyDashboard/dataAnalysis/rfc 2020 data (viz).csv")

df <- rename( df, FarmPractices = contains('Practices')  )


practicesList <- df %>% select( FarmPractices ) %>% map( ~strsplit( split="[;,\\s]", x = .x, perl=TRUE) ) %>% flatten() %>% flatten() %>% unique() %>% reduce( ~append(.x,.y) ) 
practicesList

farmersList <- df %>% select( Farmer ) %>% unique() %>% unlist() %>% unname()
farmersList

df %>% filter( !is.na( Antioxidants ), !is.na(Polyphenols) )


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

antioxMeans <- list()

antioxMeans <- for ( i in farmersList ) {
                 mean <- df %>% filter( !is.na(Antioxidants) ) %>% filter( Farmer == i ) %>% select( Antioxidants ) %>% colMeans() %>% unlist()
                 append(vac, mean)
}
antioxMeans
