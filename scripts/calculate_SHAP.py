import os
import pandas as pd
from datetime import datetime

# to make Python print logs immediately
import functools
print = functools.partial(print, flush = True)


def create_task_directory(path):   
    if not os.path.exists(path):
        os.makedirs(path)
    else:
        print("The folder already exists")
        

def calculate_shap_values(explainer, X, B, verbose = False, processes = 1):   
    out = []
    full = []
    
    if verbose:
        print('Starting calculating SHAP')
    
    for index, row in X.iterrows():
        if verbose:
            print(f'Calculating SHAP for observation: {index}, {datetime.now().strftime("%d/%m/%Y %H:%M:%S")}')
            
        out_tmp = explainer.predict_parts(row, type='shap', B=B, processes = processes)
        out_tmp = pd.DataFrame(out_tmp.result)
        
        out_tmp1 = out_tmp[out_tmp.B != 0][['contribution', 'variable_name', 'B']]
        out_tmp = out_tmp[out_tmp.B == 0][['contribution', 'variable_name', 'B']]
        
        out_tmp = out_tmp.pivot(index='B', columns="variable_name", values="contribution").reset_index()
        out_tmp.columns.rename('', inplace = True)
        out_tmp = out_tmp.iloc[: , 1:]
        
        out_tmp1 = out_tmp1.pivot(index='B', columns="variable_name", values="contribution").reset_index()
        out_tmp1.columns.rename('', inplace = True)
        out_tmp1 = out_tmp1.iloc[: , 1:]
        
        out.append(out_tmp)
        full.append(out_tmp1)
    
    out = pd.concat(out).reset_index(drop = True)
    full = pd.concat(full).reset_index(drop = True)
    return (out, full)


def calculate_shap_values_and_save(path, explainer, X, B, return_shaps = False, verbose = False, processes = 1):
    out = calculate_shap_values(explainer, X, B, verbose, processes = processes)
    
    shaps = out[0]
    full_shaps = out[1]
    
    shaps.to_csv(os.path.join(path, 'shaps.csv'))
    full_shaps.to_csv(os.path.join(path, 'full_shaps.csv'))
    
    if return_shaps:
        return out[0]
    

def calculate_y_hat_save(path, model, X):   
    y_hat_subset = pd.DataFrame(model.predict_proba(X)[:, 1])
    y_hat_subset.to_csv(os.path.join(path, 'y_hat.csv'))
    

def extract_preprocessed__calculate__save(main_dir, task_hierarchy, explainer, subset, df_preprocessed, target = None, B = 15, verbose = False, processes = 1):
    indexes = None
    if len(subset.shape) == 1:
        indexes = subset.name
        subset = pd.DataFrame(subset)
    else:
        indexes = subset.index
        
    path = os.path.join(main_dir, os.path.join(*task_hierarchy))
    create_task_directory(path)
    
    X = df_preprocessed.loc[list(indexes)]
    
    if target is not None:
        pd.DataFrame(X[target]).to_csv(os.path.join(path, 'y.csv'))
        X = X.copy()
        X = X.drop(target, axis=1)
        
    X.to_csv(os.path.join(path, 'X_subset_preprocessed.csv'))
    subset.to_csv(os.path.join(path, 'X_subset_original.csv'))
    
    calculate_shap_values_and_save(path, explainer, X, B, return_shaps = False, verbose = verbose, processes = processes)
    calculate_y_hat_save(path, explainer.model, X)
    
