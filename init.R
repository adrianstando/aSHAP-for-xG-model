# install libraries for heroku

my_packages <- c('shiny', 'DT', 'tidyr', 'iBreakDown', 'ggplot2', 'sortable', 'stringr', 'dplyr', 'tidyr', 'DALEX', 'shapviz')
install_if_missing = function(p) {
  if (p %in% rownames(installed.packages()) == FALSE) {
    install.packages(p)
  }
}
invisible(sapply(my_packages, install_if_missing)) 