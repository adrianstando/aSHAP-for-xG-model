# install packages for heroku
list.of.packages <- c('shiny', 'DT', 'tidyr', 'iBreakDown', 'ggplot2', 'sortable', 'stringr', 'dplyr', 'tidyr')
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(shiny)

port <- Sys.getenv('PORT')

if(port == ""){
  port <- 8000
}

shiny::runApp(
  appDir = './shiny_app',
  host = '0.0.0.0',
  port = as.numeric(port)
)
