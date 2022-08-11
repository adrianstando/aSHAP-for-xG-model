# aSHAP for xG model

## Project description

The project proposes a new XAI (eXplainable Artificial Intelligence) tool to analyse and explain model using aSHAP (aggregated SHapley Additive exPlanations) to describe a set of observations at once.

This repository contains codes for football xG (eXpected Goals) model analysis with aSHAP. The project was created during summer internship at MI2 DataLab.

## Run the codes locally

1. To install `R` and `Python` you have to run a script from the project's main directory: 
```console
./create_environment_scripts/install_R_Python
```
2. To install all the necessary libraries and to create `Python` virtual environment you have to run a script from the project's main directory:
```console
./create_environment_scripts/create_environment
```
3. To open `jupyterlab` run in a command line from the project's main directory:

```console
source ./virtualenv/bin/activate

jupyter lab
```
4. Remember that some notebooks are written in `R` and some are in `Python`; remember to choose a proper kernel in a notebook. Information about notebook's language is always on the top of the notebook.
