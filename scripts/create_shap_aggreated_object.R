library(stringr)

create_shap_aggreated_object <- function(task_path, label, order_variables = NULL){
    mean_prediction <- readRDS('./model/mean_prediction.RDS')
    mean_prediction_subset <- readRDS(paste0(task_path, '/mean_subset_prediction.RDS'))
    raw_shaps <- readRDS(paste0(task_path, '/raw_shaps.RDS'))

    if(is.null(order_variables)){
        order_variables <- unique(raw_shaps$variable_name)
        order_variables <- order_variables[1:(length(order_variables)-2)]
        order_variables <- as.character(order_variables)
    }
    
    aggr <- raw_to_aggregated(raw_shaps, mean_prediction, mean_prediction_subset, order_variables, label)
    aSHAP <- list(aggregated = aggr, raw = raw_shaps)
    class(aSHAP) <- c('shap_aggregated', class(aSHAP))
    class(aSHAP) <- c('predict_parts', class(aSHAP))
    aSHAP
}

create_shap_aggreated_objects_for_all_tasks <- function(main_dir, label, order_variables = NULL){
    dir_list <- list.dirs(main_dir)
    dir_list <- dir_list[2:length(dir_list)]
    for(task_path in dir_list){
        aSHAP <- create_shap_aggreated_object(task_path, label, order_variables)
        saveRDS(aSHAP, paste0(task_path, '/aSHAP_object.RDS'))
    }
}

create_aSHAP_plots_for_all_tasks <- function(main_dir, ..., scale=1, bg=NULL, width = NA, height = NA, units = "cm", plot_filename_addition = NULL){
    dir_list <- list.dirs(main_dir)
    dir_list <- dir_list[2:length(dir_list)]
    for(task_path in dir_list){
        aSHAP <- readRDS(paste0(task_path, '/aSHAP_object.RDS'))
        subtitle <- str_remove(task_path, paste0(main_dir, '/'))
        plot(aSHAP, subtitle = subtitle, ...)
        ggsave(paste0(task_path, "/", subtitle, "-plot", ifelse(is.null(plot_filename_addition), "", paste0("-", plot_filename_addition)), ".png"), scale=scale, bg=bg, width=width, height=height, units=units)
    }
}



