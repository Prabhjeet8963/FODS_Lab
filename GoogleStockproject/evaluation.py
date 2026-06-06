from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score
from sklearn.metrics import mean_squared_error, r2_score
import pandas as pd
import joblib

def evaluate_classification(models, X_train, y_train, X_val, y_val):
    """
    Train and evaluate classification models on validation set.
    """
    results = []
    trained_models = {}
    
    for name, model in models.items():
        model.fit(X_train, y_train) 
        preds = model.predict(X_val)
        
        # Determine probabilities for ROC-AUC
        if hasattr(model, "predict_proba"):
            probs = model.predict_proba(X_val)[:, 1]
        else:
            probs = preds
            
        acc = accuracy_score(y_val, preds)
        prec = precision_score(y_val, preds, zero_division=0)
        rec = recall_score(y_val, preds, zero_division=0)
        f1 = f1_score(y_val, preds, zero_division=0)
        try:
            roc_auc = roc_auc_score(y_val, probs)
        except ValueError:
            roc_auc = 0.5
            
        results.append({
            'Model': name,
            'Accuracy': acc,
            'Precision': prec,
            'Recall': rec,
            'F1-score': f1,
            'ROC-AUC': roc_auc
        })
        trained_models[name] = model
        
    results_df = pd.DataFrame(results).sort_values('Accuracy', ascending=False)
    
    # Identify BEST model automatically by highest Accuracy
    best_model_name = results_df.iloc[0]['Model']
    best_model = trained_models[best_model_name]
    
    return results_df, best_model_name, best_model

def evaluate_regression(models, X_train, y_train, X_val, y_val):
    """
    Train and evaluate regression models on validation set.
    """
    results = []
    trained_models = {}
    
    for name, model in models.items():
        model.fit(X_train, y_train)
        preds = model.predict(X_val)
        
        mse = mean_squared_error(y_val, preds)
        r2 = r2_score(y_val, preds)
        
        results.append({
            'Model': name,
            'MSE': mse,
            'R2 score': r2
        })
        trained_models[name] = model
        
    results_df = pd.DataFrame(results).sort_values('R2 score', ascending=False)
    
    # Identify BEST model automatically by highest R2 score
    best_model_name = results_df.iloc[0]['Model']
    best_model = trained_models[best_model_name]
    
    return results_df, best_model_name, best_model

def save_best_model(model, scaler, features, filename="best_model.joblib"):
    """
    Save the best model and required preprocessing metadata using joblib.
    """
    payload = {
        'model': model,
        'scaler': scaler,
        'features': features
    }
    joblib.dump(payload, filename)
