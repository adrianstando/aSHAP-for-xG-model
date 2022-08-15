library(shiny)
library(sortable)
library(stringr)
library(DT)

setwd('./..')

source('./scripts/transform_shap.R')
source('./shiny_app/utils.R')

ui <- fluidPage(
  titlePanel("aSHAP for xG model"),
  
  fluidRow(column(
    4,
    selectInput(
      inputId = "task",
      label = "Select task:",
      choices = tasks
    )
  ),
  column(
    8,
    tags$b("Select variables to show and put them in a desirable order"),
    bucket_list(
      header = NULL,
      group_name = "bucket_list_group",
      orientation = "horizontal",
      add_rank_list(
        text = "Variables to be shown",
        labels = variables,
        input_id = "variables_show"
      ),
      add_rank_list(
        text = "Variables to be hidden",
        labels = NULL,
        input_id = "variables_hide"
      )
    )
  ))
  ,
  tabsetPanel(tabPanel("aSHAP", 
                       plotOutput(outputId = "aSHAP")),
              tabPanel(
                "SHAP", fluidPage(
                  uiOutput('dynamic_dataset_selection'),
                  DTOutput('table'),
                  plotOutput(outputId = "one_SHAP")
                )
              ))
)
