sayHello <- function(){
   cat(commandArgs(trailingOnly=TRUE)[3])
}

sayHello()