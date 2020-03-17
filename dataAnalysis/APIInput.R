library("tidyverse")
library("jsonlite")

df <- fromJSON("https://app.our-sci.net/api/survey/result/json/2019-sample-collection-survey") %>% as.tibble()

df <- read_csv( "./rfc 2020 data (viz).csv", col_types = columnSpecification)

## Ideas: form list of factors and continuous variables, input one to show a pie of amount by factor and total NA and to allow to see each variable's mean, median, normality test, number of NAs and numer of data X SD away from the mean.
