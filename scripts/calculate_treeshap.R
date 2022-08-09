calculate_treeshap <- function(model, subset, dir_name, target = NULL){
    if (file.exists(dir_name)) {
    cat("The folder already exists")
    } else {
    dir.create(dir_name)
    }

    write.csv(subset, paste0(dir_name, '/subset.csv'))

    shaps <- NULL
    if(is.null(target)){
        shaps <- treeshap(model, subset, verbose = 0)
    } else {
        shaps <- treeshap(model, subset[,!(colnames(subset) %in% target)], verbose = 0)
    }

    saveRDS(shaps, paste0(dir_name, '/treeshap_output.RDS'))
    write.csv(shaps$shaps, paste0(dir_name, '/treeshap_shaps.csv'))
}