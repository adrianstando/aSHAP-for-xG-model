library(shiny)
library(sortable)
library(stringr)
library(DT)

setwd('./..')

source('./scripts/transform_shap.R')
source('./shiny_app/utils.R')

ui <- fluidPage(
  titlePanel("aSHAP for xG model"),
  
  fluidRow(
    column(
      4,
      selectInput(
        inputId = "task",
        label = "Select task:",
        choices = tasks
      ),
      radioButtons(
        inputId = "filtering_method",
        label = "Select feature filtering option: ",
        choices = c('custom', 'default'),
        selected = 'custom'
      ),
      conditionalPanel(condition = "input.filtering_method == 'default'",
                       numericInput(
                         inputId = 'number_of_variables_default',
                         label = "Select number of features to be shown: ",
                         value = as.integer(0.6 * length(variables)),
                         min = 0,
                         max = length(variables),
                         step = 1),
                       actionButton("expand", "Expand the plot")
      )
                       
    ),
    column(
      8,
      conditionalPanel(condition = "input.filtering_method == 'custom'",
                       fluidPage(
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
    )
  ),
  tabsetPanel(tabPanel("aSHAP",
                       fluidPage(
                         radioButtons(
                           inputId = "show_boxplot",
                           label = "Show boxplots on the plot:",
                           choices = c('Yes' = TRUE, 'No' = FALSE),
                           selected = TRUE
                         ),
                         plotOutput(outputId = "aSHAP"))
                       ),
              tabPanel(
                "SHAP", fluidPage(
                  uiOutput('dynamic_dataset_selection'),
                  textOutput('choose_text'),
                  DTOutput('table'),
                  plotOutput(outputId = "one_SHAP")
                )
              ),
              tabPanel(
                "Dependence scatter plot", fluidPage(
                  uiOutput('dynamic_column_selection'),
                  radioButtons(
                    inputId = "show_points",
                    label = "Show points on the plots of categorical variables:",
                    choices = c('Yes' = TRUE, 'No' = FALSE),
                    selected = TRUE
                  ),
                  plotOutput(outputId = "aSHAP_col_value")
                )
              ))
)
