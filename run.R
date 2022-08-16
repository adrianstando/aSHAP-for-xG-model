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
