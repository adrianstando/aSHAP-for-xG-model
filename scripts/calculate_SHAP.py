import os
import pandas as pd

def create_task_directory(path):   
    if not os.path.exists(path):
        os.makedirs(path)
    else:
        print("The folder already exists")
        

def calculate_shap_values(explainer, X):
    out = explainer.shap_values(X)
    out = out[1]
    out.columns = X.columns
    return out


def calculate_shap_values_and_save(main_dir, task_hierarchy, explainer, X, return_shaps = False):
    path = os.path.join(main_dir, os.path.join(*task_hierarchy))
    create_task_directory(path)
    
    out = calculate_shap_values(explainer, X)
    pd.to_csv(os.path.join(out, 'shaps.csv'))
    
    if return_shaps:
        return out
    

def extract_preprocessed__calculate__save(main_dir, task_hierarchy, explainer, subset, df_preprocessed):
    indexes = None
    if len(subset.shape) == 1:
        indexes = subset.name
    else:
        indexes = subset.index
        
    X = df_preprocessed.loc[list(indexes)]
    calculate_shap_values_and_save(main_dir, task_hierarchy, explainer, X, return_shaps = False)