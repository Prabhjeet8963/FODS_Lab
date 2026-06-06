#  Heya!! Welcome to my R-Data Science Repo!!

This repository is my personal collection of 12 R Lab scripts from my Data Science class. I have cleaned, debugged, and organized them sequentially from the absolute basics of arithmetic to more complex predictive machine learning models. 
Each script is fully self-contained, completely documented, and configured with relative dataset paths so it runs out-of-the-box on any laptop!

---

## What's in this Repo?
 --> A sequential roadmap of the Labs i attended in Sem 4:

*   **`01_Arithmetic_Basics.R`**: Vector creation, basic statistical functions, and exploring the built-in `mtcars` dataset.
*   **`02_Control_Flow_Loops.R`**: Loop structures (`for`, `while`, `repeat`) and handling conditional flow statements.
*   **`03_Dataframes_and_Functions.R`**: Cleaning tables, custom column-wise mean imputation, and writing custom functions.
*   **`04_Vectors_and_Matrices.R`**: Dimensions, repetition arrays, row-binding, and column-binding operations.
*   **`05_Trigonometric_Computations.R`**: Looping calculations over sin/cos ranges and implementing manual unique item search algorithms.
*   **`06_Descriptive_Stats_mtcars.R`**: Summarizing mileage statistics, filtering row slices, and scatter charts.
*   **`07_Outlier_Analysis_ComputerData.R`**: Outlier inspection on the **Computer Data** dataset and capping values using IQR boundaries.
*   **`08_Exploratory_Analysis_Diabetes.R`**: Rending glucose distributions and applying median missing value imputations to **Diabetes** records.
*   **`09_Quarterly_Sales_Groceries.R`**: Classifying grocery transaction dates into seasonal quarter blocks and analyzing top items.
*   **`10_Hypothesis_Testing_mtcars.R`**: Conducting statistical tests (one/two-sample independent Welch's t-tests, Chi-squared, and Fisher's).
*   **`11_Grocery_Basket_Analysis.R`**: Visualizing transaction sales volume, product frequencies, and peak purchase days in **Groceries** log.
*   **`12_Predictive_Modeling_Forests.R`**: Training Random Forest Classification on the `iris` dataset and Random Forest Regression on `mtcars`.
---

## Python Project: Google Stock Price Predictor (MLOps & Streamlit)

Located in the `Google_Stock_Predictor/` subdirectory, this is a Streamlit application that predicts Google stock trends using live Yahoo Finance feeds, logs predictions to a SQLite database, and automatically validates its own accuracy against real-world closing prices.

### Project Files
*   **`app.py`**: Main dashboard interface, SQLite prediction logger, and outcome validator.
*   **`train.py`**: Offline pipeline to compare models, train, and export artifacts.
*   **`preprocessing.py` & `data_loader.py`**: Feature engineering (SMA/EMA) and CSV loaders.
*   **`models.py` & `evaluation.py`**: ML algorithm configurations and evaluation diagnostics.

### Attached CSV Datasets
*   **`diabetes.csv`**: Demographics and clinical metrics for 403 subjects.
*   **`Computer_Data.csv`**: Components and sales listing price of 6,259 computers.
*   **`Groceries_dataset.csv`**: Shopping history log containing 38,765 items.

---

## How to Run these Scripts

1.  Set your working directory in your R console to this folder:
    ```R
    setwd("/path/to/this/folder")
    ```
2.  Source any script to run the analysis automatically:
    ```R
    source("08_Exploratory_Analysis_Diabetes.R")
    ```
3.  Any required libraries (such as `ggplot2`, `randomForest`, `reshape2`, `factoextra`, `dplyr`) will be installed automatically if your system does not already have them.

---

