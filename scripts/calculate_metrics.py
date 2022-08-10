from sklearn.metrics import accuracy_score, balanced_accuracy_score, f1_score, precision_score, recall_score, roc_auc_score
import pandas as pd

def calculate_metrics(model, X, y):
    y_hat = model.predict(X)
    y_hat_proba = model.predict_proba(X)[:, 1]

    accuracy = accuracy_score(y, y_hat)
    balanced_accuracy = balanced_accuracy_score(y, y_hat)
    f1 = f1_score(y, y_hat)
    precision = precision_score(y, y_hat)
    recall = recall_score(y, y_hat)
    roc_auc = roc_auc_score(y, y_hat_proba)

    return pd.DataFrame({
        'accuracy' : accuracy,
        'balanced_accuracy' : balanced_accuracy,
        'f1' : f1,
        'precision' : precision,
        'recall' : recall,
        'roc_auc' : roc_auc
    }, index=[0])