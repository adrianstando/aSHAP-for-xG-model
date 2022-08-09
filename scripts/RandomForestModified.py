from skranger.ensemble import RangerForestClassifier
from sklearn.utils.multiclass import check_classification_targets
import numpy as np

class RangerForestClassifierModified(RangerForestClassifier):
    def __init__(self, enable_tree_details = True, n_estimators = 100):
        super(RangerForestClassifierModified, self).__init__(enable_tree_details = enable_tree_details, n_estimators = n_estimators)

    def fit(
        self,
        X,
        y,
        dictionary_trained_parameters,
        sample_weight=None,
        class_weights=None,
        split_select_weights=None,
        always_split_features=None,
        categorical_features=None,
    ):
        self.tree_type_ = 9  # tree_type, TREE_PROBABILITY enables predict_proba

        # Check input
        X, y = self._validate_data(X, y)
        check_classification_targets(y)

        # Check the init parameters
        self._validate_parameters(X, y, sample_weight)

        # Map classes to indices
        y = np.copy(y)
        self.classes_, y = np.unique(y, return_inverse=True)
        self.n_classes_ = len(self.classes_)

        if class_weights is None:
            class_weights = {}
        else:
            try:
                class_weights = {
                    idx: class_weights[k] for idx, k in enumerate(self.classes_)
                }
            except KeyError:
                raise ValueError(
                    "class weights must have a weight for each class"
                ) from None

        # Set X info
        self.feature_names_ = [str(c).encode() for c in range(X.shape[1])]
        self._check_n_features(X, reset=True)

        # Check weights
        sample_weight, use_sample_weight = self._check_sample_weight(sample_weight, X)
        (
            always_split_features,
            use_always_split_features,
        ) = self._check_always_split_features(always_split_features)

        (
            categorical_features,
            use_categorical_features,
        ) = self._check_categorical_features(categorical_features)

        (
            split_select_weights,
            use_split_select_weights,
        ) = self._check_split_select_weights(split_select_weights)

        # Fit the forest
        self.ranger_forest_ = dictionary_trained_parameters
        self.ranger_class_order_ = np.argsort(
            np.array(self.ranger_forest_["forest"]["class_values"]).astype(int)
        )

        if self.enable_tree_details:
            sample_weight = sample_weight if len(sample_weight) > 0 else np.ones(len(X))
            terminal_node_forest = self._get_terminal_node_forest(X)
            terminal_nodes = np.atleast_2d(terminal_node_forest["predictions"]).astype(
                int
            )
            self._set_leaf_samples(terminal_nodes)
            self._set_node_values(y, sample_weight)
            self._set_n_classes()
        return self 
