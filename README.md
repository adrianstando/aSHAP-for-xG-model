# aSHAP for xG model

## Project description

The project proposes a new XAI (eXplainable Artificial Intelligence) tool to analyse and explain model using aSHAP (aggregated SHapley Additive exPlanations) to describe a set of observations at once.

This repository contains codes for football xG (eXpected Goals) model analysis with aSHAP. The project was created during summer internship at MI2 DataLab.

## Run the codes locally

**TO RUN ONLY THE APP SCROLL DOWN**

1. To install `R` and `Python`, you have to run a script from the project's main directory: 
```console
./create_environment_scripts/install_R_Python
```
2. To install all the necessary libraries and to create `Python` virtual environment, you have to run a script from the project's main directory:
```console
./create_environment_scripts/create_environment
```
3. To open `jupyterlab`, run in a command line from the project's main directory:

```console
source ./virtualenv/bin/activate

jupyter lab
```
4. Remember that some notebooks are written in `R` and some are in `Python`; remember to choose a proper kernel in a notebook. Information about notebook's language is always on the top of the notebook.

## aSHAP

`DALEX` package in `R` was extended with `aSHAP` implementation during summer internship (![repo link](https://github.com/adrianstando/DALEX-aggregated-SHAP-extension)). 

This project relies on the same implementation, but here the functions are available in a script, not as a part of `DALEX` package.

## Interactive visulisations

The app is available online: ![here](https://ashap-for-xg-model.herokuapp.com/). Because free heroku is used for this project, you will have to wait a few minutes after entering the website, since the project will have to be built.

## Run the app locally

You can use `shiny` app to explore results for different tasks. The app will create waterfall plots for both: aSHAP for a chosen task and SHAP for a chosen observation in a chosen task.

To install all libraries needed by the app, run in a command line from the project's main directory:
```console
Rscript ./init.R
```

To run the app, run in a command line from the project's main directory:

```console
Rscript ./run.R 
```

By default, the app shows results from `./results` directory. If you want to change the directory, set the `results_dir` variable in `./shiny_app/utils.R` file to a path of your desired directory.

