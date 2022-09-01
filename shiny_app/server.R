library(DT)
library(tidyr)
library(iBreakDown)
library(ggplot2)

source('./scripts/aSHAP.R')
source('./scripts/transform_shap.R')
source('./shiny_app/utils.R')

server <- function(input, output, session) {
  output$aSHAP <- renderPlot({
    p <- NULL
    
    if(file.exists(file.path(input$task, 'shaps_transformed.RDS'))){
      output_transform <-
        readRDS(file.path(input$task, 'shaps_transformed.RDS'))
      
      variables <- input$variables_show
      if (!is.null(input$variables_hide)) {
        variables <- c(variables, input$variables_hide)
      }
      
      aSHAP <- create_shap_aggreated_object(output_transform$shaps,
                                            output_transform$y_hat_full,
                                            output_transform$y_hat_subset,
                                            order_variables = variables)
      p <- plot(aSHAP, 
                max_features = ifelse(
                  input$filtering_method == 'custom', 
                  length(input$variables_show), 
                  input$number_of_variables_default),
                subtitle = nice_print(input$task), 
                use_default_filter = ifelse(
                  input$filtering_method == 'custom', 
                  FALSE, 
                  TRUE),
                add_boxplots = input$show_boxplot)
    } else {
      p <- ggplot() + theme_void()
    }
    
    p
  })
  
  
  output$table <- renderDT({
    X <- NULL
    
    if(isTruthy(input$dataset_type)){
      if((!(is.null(input$dataset_type)) | !(input$dataset_type == ''))){
        path <-
          ifelse(
            input$dataset_type == 'original',
            'X_subset_original.csv',
            'X_subset_preprocessed.csv'
          )
        
        X <- read.csv(file.path(input$task, path))[, -1]
        
        if (file.exists(file.path(input$task, 'y.csv'))) {
          y <- read.csv(file.path(input$task, 'y.csv'))[, -1]
          X$TARGET <- y
        }
        
        y <- read.csv(file.path(input$task, 'y_hat.csv'))[, -1]
        X$PREDICTION <- round(y, 3)
      } else {
        X <- data.frame()
      }
    } else {
      X <- data.frame()
    }
    
    X
  },
  selection = 'single',
  options = list(dom = 'tp', pageLength = 5))
  
  output$SHAP <- renderPlot({
    input$table_rows_selected
  })
  
  output$one_SHAP <- renderPlot({
    row <- input$table_rows_selected
    
    p <- NULL
    
    if(!(is.null(row))){
      y_hat <- read.csv(file.path(input$task, 'y_hat.csv'))[row, 2]
      
      shaps <- read.csv(file.path(input$task, 'shaps.csv'))[row, -1]
      columns <- colnames(shaps)
      
      shaps <- as.data.frame(shaps %>% pivot_longer(colnames(shaps)))
      colnames(shaps) <- c('variable_name', 'contribution')
      
      output_transform <-
        readRDS(file.path(input$task, 'shaps_transformed.RDS'))
      
      shaps$label <- output_transform$label
      intercept <- output_transform$y_hat_full
      
      variables <- input$variables_show
      if (!is.null(input$variables_hide)) {
        variables <- c(variables, input$variables_hide)
      }
      
      out <- raw_to_aggregated(shaps, intercept, y_hat, variables, output_transform$label)
      out <- select_only_k_features(list(out, data.frame()), 
                                    k = ifelse(
                                      input$filtering_method == 'custom', 
                                      length(input$variables_show), 
                                      input$number_of_variables_default), 
                                    use_default_filter = ifelse(
                                      input$filtering_method == 'custom', 
                                      FALSE, 
                                      TRUE))[[1]]
      
      path <- ifelse(
        file.exists(file.path(input$task, 'X_subset_preprocessed.csv')),
        'X_subset_preprocessed.csv',
        'X_subset_original.csv'
      )
      X <- read.csv(file.path(input$task, path))[, -1]
      rownames(X) <- 1:nrow(X)
      X <- X[row, ]
      
      out$variable <- lapply(out$variable, function(x){
        # from iBreakDown
        nice_format <- function(x) {
          if (is.numeric(x)) {
            as.character(signif(x, 4))
          } else if ("tbl" %in% class(x)) {
            as.character(x[[1]])
          } else {
            as.character(x)
          }
        }
        
        if(x %in% c('prediction', 'intercept')){
          x
        } else if(!(x %in% input$variables_show)){
          x
        } else {
          paste0(as.character(x), " = ", nice_format(X[,as.character(x)]))
        }
      })
      
      class(out) <- c('break_down', class(out))
      
      p <- plot(out, subtitle = paste(
        nice_print(input$task), paste('--- observation:', as.character(row))))
    } else {
      p <- ggplot() + theme_void()
    }
    
    p
  })
  
  output$dynamic_dataset_selection <- renderUI({
    selectInput(
      inputId = "dataset_type",
      label = "Select dataset to be shown:",
      choices = if (file.exists(file.path(input$task, 'X_subset_original.csv'))){
        if(file.exists(file.path(input$task, 'X_subset_preprocessed.csv'))) {
          c('original', 'preprocessed')
        } else {
          c('original')
        }
      } else {
        if(file.exists(file.path(input$task, 'X_subset_preprocessed.csv'))) {
          c('preprocessed')
        } else {
          c('')
        }
      })
    
  })

  output$choose_text <- renderText({'Click on a row to see a plot'})
  
  observeEvent(input$expand,{
    if(input$filtering_method == 'default'){
      updateNumericInput(session, 'number_of_variables_default', value = length(variables))
    }
  })
  
}
