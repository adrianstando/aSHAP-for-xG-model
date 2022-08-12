library(DT)

source('./scripts/aSHAP.R')
source('./scripts/transform_shap.R')

server <- function(input, output) {
  output$aSHAP <- renderPlot({
    output_transform <-
      readRDS(file.path(input$task, 'shaps_transformed.RDS'))
    
    variables <- input$variables_show
    if (!is.null(input$variables_hide)) {
      variables <- c(variables, input$variables_hide)
    }
    
    aSHAP <- create_shap_aggreated_object(output_transform[[1]],
                                          output_transform[[2]],
                                          output_transform[[3]],
                                          order_variables = variables)
    p <- plot(aSHAP, max_features = length(input$variables_show))
    p
  })
  
  
  output$table <- renderDT({
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
    X
  },
  selection = 'single',
  options = list(dom = 'tp', pageLength = 5))
  
  output$SHAP <- renderPlot({
    input$table_rows_selected
  })
  
}
