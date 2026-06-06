# Google Stock Price Predictor (MLOps & Streamlit)

A production-ready Machine Learning Operations (MLOps) pipeline for real-time stock price trend prediction using **Streamlit** and a local **SQLite** database. This project was developed as a case study for applying data science concepts on real-world data feeds (Yahoo Finance).

---
## Repository File Directory

Here is a quick summary of the files included in the project:

- **[app.py](app.py)**: The main dashboard application; hosts the graphical interface, manages SQLite database connection, and lazy-evaluates pending predictions.
- **[train.py](train.py)**: Offline training pipeline script; downloads raw historical data, compares classification and regression algorithms, and saves the best model artifacts.
- **[data_loader.py](data_loader.py)**: Data loading utility; handles CSV ingestion, column renaming, date sorting, and removing null observations.
- **[preprocessing.py](preprocessing.py)**: Preprocessing module; engineers technical indicators (SMA_20, EMA_20), creates classification/regression targets, and scales features.
- **[models.py](models.py)**: Machine learning model definition; dictionary lists of classification and regression algorithms, and KMeans elbow calculations.
- **[evaluation.py](evaluation.py)**: Offline evaluation library; metrics tracking (Precision, Recall, F1, MSE, R2), and saves joblib binaries.
- **[googl_daily_prices.csv](googl_daily_prices.csv)**: Historical daily price dataset of Google Stock (Open, High, Low, Close, Volume) used for training.
- **[requirements.txt](requirements.txt)**: Python package dependency file listing all libraries required to run this project.

*(Note: Heavy, auto-generated binary artifacts like `best_cls_model.joblib` and runtime logs like `predictions.db` have been cleaned from the directory. The application automatically initializes the database and self-heals by running the training pipeline to generate the model on its first startup).*

---

## Dashboard Page Structure (Tabs)

The application is structured into four functional tabs, allowing you to walk through the entire MLOps process from inference to live-tracking:

### 1. Real-Time Predictor
This tab fetches near real-time daily stock metrics for Google (`GOOGL`) from Yahoo Finance, computes the 20-day moving averages (`SMA_20` and `EMA_20`), scales indicators, and prompts the saved model for inference.
- **Inference Results**: Displays whether the next trading close is predicted to go **UP** or **DOWN**, along with the classifier's internal confidence percentage.
- **SQLite Logging**: Automatically logs the features, predicted direction, and prediction confidence into `predictions.db` under a `Pending` status.

### 2. Real-World MLOps Dashboard
A live production tracker showing the actual reliability of your predictions over time.
- **Lazy Resolution**: Every time you load this page, the system scans the SQLite database for past predicted dates that have closed, queries Yahoo Finance for their actual close prices, and sets the prediction status to `Correct` or `Incorrect`.
- **Live Metrics**: Automatically displays total predictions, pending target dates, and **Real-World Hit Rate (Accuracy)**.
- **Visual Trends**: Plots a rolling accuracy curve over time and generates breakdown charts of prediction outcomes.

### 3. Model Comparisons & Diagnostics
This page focuses on offline model validation and explainability.
- **Algorithm Comparison**: Renders comparison dataframes containing performance metrics (Accuracy, Precision, Recall, F1, ROC-AUC, MSE, R2) for all trained classifiers and regressors.
- **Dynamic Diagnostics**: Displays interactive Confusion Matrices, ROC Curves, Regression Fit plots, and KMeans Elbow curves.
- **Explainable AI**: Generates a SHAP (SHapley Additive exPlanations) plot to visualize feature importance and illustrate *why* the model makes its decisions.
- **Retraining Panel**: Provides an offline retraining button to trigger the pipeline (`train.py`) and update model parameters on new data directly from the browser.

### 4. Historical Trends
Allows exploratory data analysis on the raw CSV data.
- **Technical Chart**: Draws historical price trend lines overlayed with Simple and Exponential 20-day Moving Averages.
- **Data Browser**: Injects an interactive table to inspect the raw CSV dataset values.

---

## Setup & Execution

### 1. Ingest Dependencies
Ensure you have all standard libraries downloaded:
```bash
pip install -r requirements.txt
```
### 2. Boot the Dashboard
Launch the app. Since the model file (`best_cls_model.joblib`) is not checked into Git, the application will automatically run the training pipeline first to build it, and then initialize the SQLite logs database:
```bash
python -m streamlit run app.py
```
