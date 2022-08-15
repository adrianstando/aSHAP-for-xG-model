library(DT)
library(tidyr)
library(iBreakDown)
library(ggplot2)

source('./scripts/aSHAP.R')
source('./scripts/transform_shap.R')


results_dir <- './results'
nice_print <- function(x) {
  x <- str_remove(x, results_dir)
  x <- str_replace_all(x, '[\\//]', '-')
  if (str_starts(x, "-")) {
    x <- str_sub(x, start = 2L)
  }
  x
}


server <- function(input, output) {
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
      p <- plot(aSHAP, max_features = length(input$variables_show), subtitle = nice_print(input$task))
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
      
      out <- raw_to_aggregated(shaps, intercept, y_hat, columns, output_transform$label)
      
      path <-
        ifelse(
          input$dataset_type == 'original',
          'X_subset_original.csv',
          'X_subset_preprocessed.csv'
        )
      X <- read.csv(file.path(input$task, path))[, -1]
      rownames(X) <- 1:nrow(X)
      X <- X[row, ]
      
      out$variable <- lapply(out$variable, function(x){
        if(x %in% c('prediction', 'intercept')){
          x
        } else {
          paste0(as.character(x), " = ", X[,as.character(x)])
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
  
}