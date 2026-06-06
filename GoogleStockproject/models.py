from sklearn.linear_model import LogisticRegression, LinearRegression, Lasso
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.naive_bayes import GaussianNB
from sklearn.cluster import KMeans

def get_classification_models():
    """
    Return a dictionary of classification models to compare.
    """
    return {
        'Logistic Regression': LogisticRegression(random_state=42),
        'KNN': KNeighborsClassifier(),
        'SVM': SVC(probability=True, random_state=42),
        'Decision Tree': DecisionTreeClassifier(random_state=42),
        'Random Forest': RandomForestClassifier(random_state=42),
        'Naive Bayes': GaussianNB()
    }

def get_regression_models():
    """
    Return a dictionary of regression models to compare.
    """
    return {
        'Linear Regression': LinearRegression(),
        'Lasso': Lasso(random_state=42)
    }

def run_kmeans_elbow(X_train, max_k=10):
    """
    Run KMeans clustering for k=1 to max_k to use the Elbow Method.
    """
    inertias = []
    ks = range(1, max_k + 1)
    for k in ks:
        kmeans = KMeans(n_clusters=k, random_state=42, n_init=10)
        kmeans.fit(X_train)
        inertias.append(kmeans.inertia_)
    return ks, inertias
