import joblib
import pandas as pd
from data_loader import load_and_clean_data
from preprocessing import create_targets, feature_engineering, split_and_scale
from models import get_classification_models, get_regression_models, run_kmeans_elbow
from evaluation import evaluate_classification, evaluate_regression

def train_and_save_pipeline():
    print("Starting ML Pipeline Training...")
    
    # 1. Load Data
    df = load_and_clean_data("googl_daily_prices.csv")
    
    # 2. Preprocessing & Targets
    df = create_targets(df)
    df = feature_engineering(df)
    
    # Selected features for models
    features = ['Open', 'High', 'Low', 'Close', 'Volume', 'SMA_20', 'EMA_20']
    
    # 3. Time-Series Splitting
    (X_train, X_val, X_test, 
     y_train_reg, y_val_reg, y_test_reg, 
     y_train_cls, y_val_cls, y_test_cls, 
     scaler, train_df, val_df, test_df) = split_and_scale(df, features)
    
    # 4. Train Classification Models
    cls_models = get_classification_models()
    cls_results, best_cls_name, best_cls_model = evaluate_classification(
        cls_models, X_train, y_train_cls, X_val, y_val_cls
    )
    
    # 5. Train Regression Models
    reg_models = get_regression_models()
    reg_results, best_reg_name, best_reg_model = evaluate_regression(
        reg_models, X_train, y_train_reg, X_val, y_val_reg
    )
    
    # 6. Clustering (KMeans Elbow)
    ks, inertias = run_kmeans_elbow(X_train, max_k=10)
    
    # Save EVERYTHING in a single joblib payload for instant UI loading
    payload = {
        'model': best_cls_model,
        'scaler': scaler,
        'features': features,
        'cls_results': cls_results,
        'best_cls_name': best_cls_name,
        'reg_results': reg_results,
        'best_reg_name': best_reg_name,
        'best_reg_model': best_reg_model,
        'ks': list(ks),
        'inertias': inertias,
        'X_train': X_train,
        'X_val': X_val,
        'y_val_cls': y_val_cls,
        'X_test': X_test,
        'y_test_reg': y_test_reg,
        'historical_df': df  # Save preprocessed historical data for the history tab trend visualization
    }
    
    joblib.dump(payload, "best_cls_model.joblib")
    print("Training complete! Model and all evaluation metrics saved to best_cls_model.joblib.")
    return payload

if __name__ == "__main__":
    train_and_save_pipeline()
