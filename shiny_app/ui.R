library(shiny)
library(sortable)
library(stringr)
library(DT)

setwd('./..')

source('./scripts/transform_shap.R')

results_dir <- './results'
tasks_dirs <- task_directories(results_dir)

tasks <- c()
variables <- c()

nice_print <- function(x) {
  x <- str_remove(x, results_dir)
  x <- str_replace_all(x, '[\\//]', '-')
  if (str_starts(x, "-")) {
    x <- str_sub(x, start = 2L)
  }
  x
}

if(!(is.null(tasks_dirs))){
  tasks_to_show <- lapply(tasks_dirs, nice_print)
  
  tasks <- setNames(tasks_dirs, tasks_to_show)
  
  variables <-
    colnames(read.csv(file.path(
      tasks_dirs[1], 'X_subset_preprocessed.csv'
    ))[, -1])
}

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
