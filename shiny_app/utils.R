library(stringr)

source('./scripts/transform_shap.R')

results_dir <- file.path('.', 'results')
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

