library(DT)
library(tidyr)
library(iBreakDown)
library(ggplot2)
library(shapviz)

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
      
      if(input$aSHAP_plot_type == 'DALEX - break down' || 
         input$aSHAP_plot_type == 'DALEX - break down with boxplot'){
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
                  add_boxplots = input$aSHAP_plot_type == 'DALEX - break down with boxplot')
        p <- p + theme(axis.text.y=element_text(size=14), 
                       title=element_text(size=15), 
                       axis.text.x=element_text(size=14))
      } else if(input$aSHAP_plot_type == 'shapviz - waterfall plot'){
        aSHAP <- select_only_k_features(list(aSHAP$aggregated, data.frame()), 
                                        k = ifelse(
                                          input$filtering_method == 'custom', 
                                          length(input$variables_show), 
                                          input$number_of_variables_default), 
                                        use_default_filter = ifelse(
                                          input$filtering_method == 'custom', 
                                          FALSE, 
                                          TRUE))[[1]]
        class(aSHAP) <- c('break_down', 'predict_parts', 'data.frame')
        obj <- shapviz(aSHAP)
        p <- sv_waterfall(obj)
      } else if(input$aSHAP_plot_type == 'shapviz - force plot'){
        aSHAP <- select_only_k_features(list(aSHAP$aggregated, data.frame()), 
                                        k = ifelse(
                                          input$filtering_method == 'custom', 
                                          length(input$variables_show), 
                                          input$number_of_variables_default), 
                                        use_default_filter = ifelse(
                                          input$filtering_method == 'custom', 
                                          FALSE, 
                                          TRUE))[[1]]
        class(aSHAP) <- c('break_down', 'predict_parts', 'data.frame')
        obj <- shapviz(aSHAP)
        p <- sv_force(obj)
      }
      
    } else {
      p <- ggplot() + theme_void()
    }
    
    p
  })
    

  output$aSHAP_col_value <- renderPlot({
    p <- NULL
    
    if(file.exists(file.path(input$task, 'shaps_transformed.RDS'))){
        
      column <- input$selected_column_name
      
      level_vectors <- readRDS(file.path("data", "level_vector.RDS"))
        
      column_vals <- 
        read.csv(file.path(input$task, 'X_subset_preprocessed.csv'))[,column]
      
      transform_values <- column %in% names(level_vectors)
      if(length(transform_values) == 0){
        transform_values <- FALSE
      }
      if(transform_values){
        column_vals <- lapply(column_vals, FUN=function(x){unname(unlist(level_vectors[column]))[x]})
        column_vals <- unlist(column_vals)
      }
        
      ashaps <-
        read.csv(file.path(input$task, 'shaps.csv'))[,column]
        
      df <- data.frame(
          c1 = ashaps,
          c2 = column_vals
      )
    
      if(length(colnames(df)) == 2){
        colnames(df) <- c('SHAP', column)
        
        if(transform_values){
          p <- ggplot(df, aes_string(x=column, y='SHAP')) + 
            geom_boxplot(fill='#4c72b0', color='black') +
            theme_bw()
          if(input$show_points){
            p <- p + geom_jitter(alpha=0.6)
          }
        } else {
          p <- ggplot(df, aes_string(x=column, y='SHAP')) + 
            geom_point(col='#4c72b0') + 
            theme_bw()
        }
        p <- p +
          ggtitle(paste0("SHAP Dependence Scatter Plot for ", column, " variable"))
      } else {
          p <- ggplot() + theme_void()
      }
      
    } else {
      p <- ggplot() + theme_void()
    }
    
    p <- p + theme(axis.text.y=element_text(size=14), title=element_text(size=15), axis.text.x=element_text(size=14))
    
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
      
      level_vectors <- readRDS(file.path("data", "level_vector.RDS"))
      transform_values <- intersect(names(level_vectors), colnames(X))
      
      var <- out$variable
      
      out$variable <- lapply(var, function(x){
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
          
          val <- if(x %in% transform_values){
            unname(unlist(level_vectors[x]))[X[,as.character(x)]]
          } else {
            X[,as.character(x)]
          }
          
          paste0(as.character(x), " = ", nice_format(val))
        }
      })
      
      out$variable_value <- lapply(var, function(x){
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
        
        if(x %in% c('prediction', 'intercept', '')){
          ''
        } else {
          val <- if(x %in% transform_values){
            unname(unlist(level_vectors[x]))[X[,as.character(x)]]
          } else {
            X[,as.character(x)]
          }
          nice_format(val)
        }
      })
      print(out)
      
      class(out) <- c('break_down', 'predict_parts', class(out))
      
      plot_type <- input$one_SHAP_plot_type
      if(plot_type == 'DALEX - break down'){
        p <- plot(out, subtitle = paste(
        nice_print(input$task), paste('--- observation:', as.character(row))))
      } else if(plot_type == 'shapviz - waterfall plot'){
        obj <- shapviz(out)
        p <- sv_waterfall(obj)
      } else if(plot_type == 'shapviz - force plot'){
        obj <- shapviz(out)
        p <- sv_force(obj)
      }
      
    } else {
      p <- ggplot() + theme_void()
    }
    
    p <- p + theme(axis.text.y=element_text(size=14), title=element_text(size=15), axis.text.x=element_text(size=14))
    
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
    
  output$dynamic_column_selection <- renderUI({
    selectInput(
      inputId = "selected_column_name",
      label = "Select column to be shown:",
      choices = colnames(read.csv(file.path(input$task, 'X_subset_preprocessed.csv'))[,-1]))
  })

  output$choose_text <- renderText({'Click on a row to see a plot'})
  
  observeEvent(input$expand,{
    if(input$filtering_method == 'default'){
      updateNumericInput(session, 'number_of_variables_default', value = length(variables))
    }
  })
  
}
