from sklearn.base import TransformerMixin, BaseEstimator
from sklearn.preprocessing import LabelEncoder
import numpy as np

class Transformer(BaseEstimator, TransformerMixin):
    def __init__(self):
        self.le_situation = LabelEncoder()
        self.le_shotType = LabelEncoder()
        self.le_lastAction = LabelEncoder()
        self.le_h_a = LabelEncoder()
        return

    def fit(self, X, y = None):
        self.le_situation.fit(X['situation'])
        self.le_shotType.fit(X['shotType'])
        self.le_lastAction.fit(X['lastAction'])
        self.le_h_a.fit(X['h_a'])
        return self
    
    def transform(self, X, y = None):
        X = X.copy()
        X['distanceToGoal'] = np.sqrt((105 - (X['X'] * 105)) ** 2 + (32.5 - (X['Y'] * 68)) ** 2)
        X['angleToGoal'] = np.abs(np.arctan((7.32 * (105 - (X['X'] * 105))) / ((105 - (X['X'] * 105)) ** 2 + (32.5 - (X['Y'] * 68)) ** 2 - (7.32 / 2) ** 2)) * 180 / np.pi)
        X = X[['minute', 'h_a', 'situation', 'shotType', 'lastAction', 'distanceToGoal', 'angleToGoal']]
        X['situation'] = self.le_situation.transform(X['situation'])
        X['shotType'] = self.le_shotType.transform(X['shotType'])
        X['lastAction'] = self.le_lastAction.transform(X['lastAction'])
        X['h_a'] = self.le_h_a.transform(X['h_a'])
        return X
