# ==============================================================================
# Lab 08: Exploratory Data Analysis (Diabetes Dataset)
# ==============================================================================
# Focus: ggplot2 mapping, histogram bins, color scales, bivariate relations, 
# linear smooths, and median missing data imputation on clinical attributes.
# ==============================================================================

# Ensure missing libraries are installed dynamically
required_libs <- c("ggplot2", "dplyr", "readr")
missing_libs <- required_libs[!(required_libs %in% installed.packages()[,"Package"])]
if (length(missing_libs)) install.packages(missing_libs, dependencies = TRUE)

library(readr)
library(ggplot2)
library(dplyr)

# BUG FIXED: Replaced absolute path "C:/Users/LENOVO/Downloads/diabetes.csv" 
# with the local relative path "diabetes.csv" so the code is fully reproducible.
if (file.exists("diabetes.csv")) {
  Diabetes_Data <- read_csv("diabetes.csv")
  
  head(Diabetes_Data)
  str(Diabetes_Data)
  
  # 1. Plotting Distributions
  # Cholesterol distribution
  ggplot(Diabetes_Data, aes(x = chol)) + 
    geom_histogram(binwidth = 10, fill = "skyblue", color = "blue") +
    labs(title = "Distribution of Cholesterol", x = "Cholesterol", y = "Count") +
    theme_minimal()
  
  # Stabilized Glucose distribution
  ggplot(Diabetes_Data, aes(x = stab.glu)) +
    geom_histogram(binwidth = 10, fill = "darkred", color = "pink") +
    labs(title = "Distribution of Stabilized Glucose", x = "Glucose", y = "Count") +
    theme_minimal()
  
  # 2. Bivariate Comparisons
  # Plot Cholesterol vs Stabilized Glucose colored by Diagnosis
  ggplot(Diabetes_Data, aes(x = chol, y = stab.glu, colour = diagnosis)) +
    geom_point(alpha = 0.5) + 
    geom_smooth(method = "lm", se = FALSE, color = "red") +
    labs(title = "Comparison: Cholesterol vs Stabilized Glucose",
         x = "Cholesterol", y = "Stabilized Glucose") +
    theme_minimal()
  
  # Simple scatter plot colored by diagnosis
  ggplot(Diabetes_Data, aes(x = chol, y = stab.glu, colour = diagnosis)) +
    geom_point(alpha = 0.5) +
    theme_minimal()
  
  # 3. Missing Data Cleaning & Imputation
  print("=== Missing values count before imputation ===")
  print(colSums(is.na(Diabetes_Data)))
  
  # Omit rows where diagnosis target itself is NA
  diabetes_clean <- Diabetes_Data[!is.na(Diabetes_Data$diagnosis), ]
  
  # Identify numeric columns for median imputation
  numeric_cols <- c("chol", "stab.glu", "hdl", "ratio", "glyhb", "age", "height",
                    "weight", "bp.1s", "bp.1d", "bp.2s", "bp.2d", "waist", "hip", 
                    "time.ppn")
  
  # Impute NAs with column medians
    for (col in numeric_cols) {
        if (any(is.na(diabetes_clean[[col]]))) {
            med_val <- median(diabetes_clean[[col]], na.rm = TRUE)
            diabetes_clean[[col]][is.na(diabetes_clean[[col]])] <- med_val
        }
    }
  
  print("=== Missing values count after imputation ===")
  print(colSums(is.na(diabetes_clean)))
} else {
  print("Warning: diabetes.csv not found in working directory.")
}
