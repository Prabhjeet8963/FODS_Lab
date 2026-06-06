import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler

def create_targets(df):
    """
    Create regression and classification targets for the dataset.
    """
    df = df.copy()
    
    # Target 1: Regression -> next_day_close
    df['next_day_close'] = df['Close'].shift(-1)
    
    # Target 2: Classification -> up/down (1 if next day close > today close, else 0)
    df['target_class'] = (df['next_day_close'] > df['Close']).astype(int)
    
    df.dropna(inplace=True)
    return df

def feature_engineering(df):
    """
    Add moving averages (SMA/EMA) for features and visualization.
    """
    df = df.copy()
    df['SMA_20'] = df['Close'].rolling(window=20).mean()
    df['EMA_20'] = df['Close'].ewm(span=20, adjust=False).mean()
    
    df.dropna(inplace=True)
    return df

def split_and_scale(df, features):
    """
    Time-series split: 60% Train, 20% Validation, 20% Test.
    NO random shuffling. Apply StandardScaler to features.
    """
    n = len(df)
    train_end = int(n * 0.6)
    val_end = int(n * 0.8)
    
    # Chronological Split
    train_df = df.iloc[:train_end]
    val_df = df.iloc[train_end:val_end]
    test_df = df.iloc[val_end:]
    
    scaler = StandardScaler()
    
    # Fit scaler on training data only
    X_train = scaler.fit_transform(train_df[features])
    X_val = scaler.transform(val_df[features])
    X_test = scaler.transform(test_df[features])
    
    y_train_reg = train_df['next_day_close'].values
    y_val_reg = val_df['next_day_close'].values
    y_test_reg = test_df['next_day_close'].values
    
    y_train_cls = train_df['target_class'].values
    y_val_cls = val_df['target_class'].values
    y_test_cls = test_df['target_class'].values
    
    return (X_train, X_val, X_test, 
            y_train_reg, y_val_reg, y_test_reg, 
            y_train_cls, y_val_cls, y_test_cls, 
            scaler, train_df, val_df, test_df)
