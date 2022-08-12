import os
import pandas as pd

def create_task_directory(path):   
    if not os.path.exists(path):
        os.makedirs(path)
    else:
        print("The folder already exists")
        

def calculate_shap_values(explainer, X):
    out = explainer.shap_values(X)
    out = pd.DataFrame(out[1])
    out.columns = X.columns
    return out


def calculate_shap_values_and_save(path, explainer, X, return_shaps = False):
    create_task_directory(path)
    
    out = calculate_shap_values(explainer, X)
    out.to_csv(os.path.join(path, 'shaps.csv'))
    
    if return_shaps:
        return out
    

def calculate_y_hat_save(path, model, X):   
    y_hat_subset = pd.DataFrame(model.predict(X)[:, 1])
    y_hat_subset.to_csv(os.path.join(path, 'y_hat.csv'))
    

def extract_preprocessed__calculate__save(main_dir, task_hierarchy, explainer, subset, df_preprocessed, target = None):
    indexes = None
    if len(subset.shape) == 1:
        indexes = subset.name
        subset = pd.DataFrame(subset)
    else:
        indexes = subset.index
        
    path = os.path.join(main_dir, os.path.join(*task_hierarchy))
    
    X = df_preprocessed.loc[list(indexes)]
    
    if target is not None:
        pd.DataFrame(X[target]).to_csv(os.path.join(path, 'y.csv'))
        X = X.copy()
        X = X.drop(target, axis=1)
        
    X.to_csv(os.path.join(path, 'X_subset_preprocessed.csv'))
    subset.to_csv(os.path.join(path, 'X_subset_original.csv'))
    
    calculate_shap_values_and_save(path, explainer, X, return_shaps = False)
    calculate_y_hat_save(path, explainer.model, X)
    