import functools
import pickle5 as pickle
import pandas as pd
import numpy as np
import dalex as dx
import os
from scripts.calculate_SHAP import extract_preprocessed__calculate__save
import sys


print = functools.partial(print, flush=True)

print('Hello Python!')

with open('./model/model.pickle', 'rb') as fp:
    model = pickle.load(fp) 
    
print('Model loaded!')

df_preprocessed = pd.read_csv('./data/data_preprocessed.csv', index_col=0)
df_raw = pd.read_csv('./data/raw_data.csv', index_col=0)

X_preprocessed = df_preprocessed.drop('status', axis=1)

y_preprocessed = df_preprocessed.status

print('Data loaded!')

explainer = dx.Explainer(model, X_preprocessed, y_preprocessed)

print('Explainer created!')

path = './results'

if not os.path.exists(path):
    os.makedirs(path)
else:
    print("The folder already exists")

subset = df_raw[np.logical_and(df_raw.league == 'Bundesliga', df_raw.season == 2021)]

print('Subset extracted!')

np.random.seed(42)

number_of_tasks = int(sys.argv[1])
task_id = int(sys.argv[2])
nrows = subset.shape[0]
n_per_task = int(nrows / number_of_tasks)

if task_id != number_of_tasks: subset = subset.head(n_per_task * task_id).tail(n_per_task)
else: subset = subset.tail(nrows - n_per_task * (task_id - 1))

extract_preprocessed__calculate__save(
    main_dir = './results', 
    task_hierarchy = ['bundesliga', 'all_teams','season2021', str(task_id)],
    explainer = explainer, 
    subset = subset, 
    df_preprocessed = df_preprocessed,
    target = 'status',
    verbose = True
)

from datetime import datetime

print('Task finished!')
print(f"{datetime.now().strftime('%d/%m/%Y %H:%M:%S')}")
 
