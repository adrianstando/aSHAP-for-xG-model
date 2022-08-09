transform_shap <- function(task_path, label, y_hat, model){
    shaps <- read.csv(paste0(task_path, '/treeshap_shaps.csv'))
    shaps <- shaps[,-1]

    shaps <- shaps %>%
         pivot_longer(cols = colnames(shaps), names_to = "variable_name", values_to = "contribution") %>%
         arrange(variable_name)
    
    shaps <- as.data.frame(shaps)

    shaps <- rbind(shaps, y_hat)

    y_hat_subset <- predict(model, read.csv(paste0(task_path, '/subset.csv')))$predict
    y_hat_subset <- data.frame(variable_name = 'prediction', contribution = y_hat_subset)
    shaps <- rbind(shaps, y_hat_subset)

    shaps$variable_name <- factor(shaps$variable_name)
    shaps$label <- label

    list(shaps = shaps, mean_subset = mean(y_hat_subset$contribution))
}

transform_all_tasks <- function(main_dir, label, y_hat, model){
    dir_list <- list.dirs(main_dir)
    dir_list <- dir_list[2:length(dir_list)]
    for(task_path in dir_list){
        output_transform <- transform_shap(task_path, label, y_hat, model)
        saveRDS(output_transform[[1]], paste0(task_path, '/raw_shaps.RDS'))
        saveRDS(output_transform[[2]], paste0(task_path, '/mean_subset_prediction.RDS'))
    }
}