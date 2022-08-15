library(dplyr)
library(tidyr)
library(stringr)
library(iBreakDown)
library(ggplot2)
source('./scripts/aSHAP.R')

task_directories <- function(results_dir){
  out <- c()
  
  dir_list <- list.dirs(results_dir)
  
  if(length(dir_list) > 1){
    dir_list <- dir_list[2:length(dir_list)]
    for(path in dir_list){
      if(!(length(dir(path)) == 0)){
        if(all(c('shaps.csv', 'y_hat.csv') %in% dir(path))){
          out <- c(path, out)
        }
      }
    }
  }
  
  out
}

transform_shap <- function(data_dir, task_path, label){
    shaps <- read.csv(file.path(task_path, 'shaps.csv'))[,-1]
    
    shaps <- shaps %>%
        pivot_longer(cols = colnames(shaps), 
                   names_to = "variable_name", 
                   values_to = "contribution") %>%
        arrange(variable_name)
    
    y_hat <- as.data.frame(read.csv(file.path(data_dir, 'y_hat.csv'))[,-1])
    colnames(y_hat) <- c("contribution")
    y_hat$variable_name <- 'intercept'
    
    y_hat_subset <- as.data.frame(read.csv(file.path(task_path, 'y_hat.csv'))[,-1])
    colnames(y_hat_subset) <- c("contribution")
    y_hat_subset$variable_name <- 'prediction'

    shaps <- as.data.frame(shaps)
    shaps <- rbind(shaps, y_hat)
    shaps <- rbind(shaps, y_hat_subset)

    shaps$variable_name <- factor(shaps$variable_name)
    shaps$label <- label

    list(label = label,
         shaps = shaps, 
         y_hat_full = mean(y_hat$contribution),
         y_hat_subset = mean(y_hat_subset$contribution))
}

create_shap_aggreated_object <- function(raw_shaps, mean_prediction, mean_prediction_subset, 
                                         order_variables = NULL,
                                         order_by_default_function = FALSE,
                                         explainer = NULL, new_data = NULL, predict_function = NULL){
  
  label <- raw_shaps$label[1]
  
  if(is.null(order_variables)){ #default order from dataset
    order_variables <- unique(raw_shaps$variable_name)
    order_variables <- order_variables[1:(length(order_variables)-2)]
    order_variables <- as.character(order_variables)
  } else if(order_by_default_function){
    order_variables <- calculate_order(explainer, mean_prediction, new_data, predict_function)
  }
  
  aggr <- raw_to_aggregated(raw_shaps, 
                            mean_prediction, mean_prediction_subset, 
                            order_variables, label)
  aSHAP <- list(aggregated = aggr, raw = raw_shaps)
  class(aSHAP) <- c('shap_aggregated', class(aSHAP))
  class(aSHAP) <- c('predict_parts', class(aSHAP))
  aSHAP
}

transform_all_tasks <- function(data_dir, results_dir, label, order_variables = NULL){
    dir_list <- task_directories(results_dir)
    for(task_path in dir_list){
        output_transform <- transform_shap(data_dir, task_path, label)
        aSHAP <- create_shap_aggreated_object(output_transform$shaps, 
                                              output_transform$y_hat_full, 
                                              output_transform$y_hat_subset, 
                                              order_variables = order_variables)
        saveRDS(aSHAP, file.path(task_path, 'aSHAP_object.RDS'))
        saveRDS(output_transform, file.path(task_path, 'shaps_transformed.RDS'))
    }
}

create_aSHAP_plots_for_all_tasks <- function(results_dir, ..., scale=1, bg=NULL, width = NA, height = NA, units = "cm", plot_filename_addition = NULL){
  dir_list <- task_directories(results_dir)
  for(task_path in dir_list){
    aSHAP <- readRDS(file.path(task_path, 'aSHAP_object.RDS'))
    
    subtitle <- str_remove(task_path, results_dir)
    subtitle <- str_replace_all(subtitle, '[\\//]', '-')
    if(str_starts(subtitle, "-")){
      subtitle <- str_sub(subtitle, start = 2L)
    }
    
    plot(aSHAP, subtitle = subtitle, ...)
    ggsave(file.path(task_path, 
                     paste0(subtitle,
                            "-plot", 
                            ifelse(is.null(plot_filename_addition), "", paste0("-", plot_filename_addition)), 
                            ".png")
                     ),
           scale=scale, bg=bg, width=width, height=height, units=units)
  }
}
