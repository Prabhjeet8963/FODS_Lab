# ==============================================================================
# Lab 10: Hypothesis Testing and Statistical Inference Basics
# ==============================================================================
# Focus: One-sample t-test, Two-sample independent Welch's t-test, Boxplot 
# visual comparisons, and Chi-squared testing of categorical variables on mtcars.
# ==============================================================================

# Ensure missing packages are installed dynamically
required_packages <- c("ggplot2", "corrplot", "factoextra", "datasets")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if (length(new_packages)) {
  install.packages(new_packages, dependencies = TRUE)
}

library(ggplot2)
library(corrplot)
library(factoextra)

data(mtcars)
head(mtcars)

# 1. One-Sample t-Test
# Question: Is the average MPG of manual cars different from 22?
manual_mpg <- mtcars$mpg[mtcars$am == 1]
t_test_result <- t.test(manual_mpg, mu = 22)

print("=== One-Sample t-Test Results ===")
print(t_test_result)

# 2. Two-Sample Independent t-Test
# Question: Compare MPG between automatic (am = 0) and manual (am = 1) cars.
auto_mpg <- mtcars$mpg[mtcars$am == 0]
manual_mpg <- mtcars$mpg[mtcars$am == 1]

# Two-sample t-test (var.equal = FALSE performs Welch's t-test by default)
t_test_two <- t.test(auto_mpg, manual_mpg)

print("=== Two-Sample t-Test (Welch) Results ===")
print(t_test_two)

# 3. Visual Comparisons using Boxplots
# Visualizing Mileage across Transmission type (am)
boxplot(mpg ~ am, data = mtcars, col = c("cyan", "pink"),
        names = c("Automatic", "Manual"),
        ylab = "Miles per Gallon", main = "MPG by Transmission Type")

# Visualizing Mileage across Gear type
boxplot(mpg ~ gear, data = mtcars,
        col = c("lightblue", "lightgreen", "lightpink"),
        names = c("3 Gears", "4 Gears", "5 Gears"),
        ylab = "Miles per Gallon",
        main = "MPG by Number of Gears")

# 4. Categorical Association Testing
# Create a contingency table comparing number of Gears vs Transmission type
gear_am_table <- table(mtcars$gear, mtcars$am)
colnames(gear_am_table) <- c("Auto", "Manual")
rownames(gear_am_table) <- c("3 Gears", "4 Gears", "5 Gears")

print("=== Contingency Table: Gears vs Transmission ===")
print(gear_am_table)

# Chi-squared test of independence
chisq_result <- chisq.test(gear_am_table)

print("=== Chi-Squared Test Results ===")
print(chisq_result)
