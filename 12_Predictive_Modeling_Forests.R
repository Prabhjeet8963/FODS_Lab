# ==============================================================================
# Lab 12: Predictive Modeling and Random Forests(Classification prediction)
# ==============================================================================
# Focus: Statistical comparisons, simple linear regressions, data visualization,
# unsupervised K-Means/hierarchical clustering, and Random Forest classification/regression.
# ==============================================================================

install.packages(c("ggplot2", "corrplot", "factoextra", "datasets", "reshape2"))
# Load libraries
library(ggplot2)
library(corrplot)
library(factoextra)
manual_mpg <- mtcars$mpg[mtcars$am == 1]

# One-sample t-test (two-tailed)
t_test_result <- t.test(manual_mpg, mu = 22)
print(t_test_result)
auto_mpg <- mtcars$mpg[mtcars$am == 0]
manual_mpg <- mtcars$mpg[mtcars$am == 1]
t_test_two <- t.test(auto_mpg, manual_mpg)
print(t_test_two)

# Visualize with boxplot
boxplot(mpg ~ am, data = mtcars, col = c("red", "blue"),
        names = c("Automatic", "Manual"),
        ylab = "Miles per Gallon", main = "MPG by Transmission Type")
gear_am_table <- table(mtcars$gear, mtcars$am)
colnames(gear_am_table) <- c("Auto", "Manual")
print(gear_am_table)

# Chi-squared test
chisq_result <- chisq.test(gear_am_table)
print(chisq_result)
fisher.test(gear_am_table)
model <- lm(mpg ~ hp, data = mtcars)
summary(model)

# Make predictions
new_hp <- data.frame(hp = c(100, 150, 200))
pred_mpg <- predict(model, newdata = new_hp)
pred_mpg

# Visualise regression line
ggplot(mtcars, aes(x = hp, y = mpg)) +
  geom_point(color = "darkgreen", size = 3) +
  geom_smooth(method = "lm", se = TRUE, color = "red") +
  labs(title = "Linear Regression: mpg ~ hp", x = "Horsepower", y = "Miles per Gallon") +
  theme_minimal()
data("mtcars")

# Load libraries
library(ggplot2)
library(corrplot)
library(factoextra)
manual_mpg <- mtcars$mpg[mtcars$am == 1]
t_test_result <- t.test(manual_mpg, mu = 22)
print(t_test_result)
auto_mpg <- mtcars$mpg[mtcars$am == 0]
manual_mpg <- mtcars$mpg[mtcars$am == 1]
# Two-sample t-test (var.equal = FALSE is Welch's test)
t_test_two <- t.test(auto_mpg, manual_mpg)
print(t_test_two)
# Visualize with boxplot
boxplot(mpg ~ am, data = mtcars, col = c("red", "blue"),
        names = c("Automatic", "Manual"),
        ylab = "Miles per Gallon", main = "MPG by Transmission Type")
boxplot(mpg ~ gear, data = mtcars, col = c("red", "blue", "cyan"),
        names = c("3", "4", "5"),
        ylab = "Miles per Gallon", main = "MPG by Gear Type")
gear_am_table <- table(mtcars$gear, mtcars$am)
colnames(gear_am_table) <- c("Auto", "Manual")
print(gear_am_table)
chisq_result <- chisq.test(gear_am_table)
print(chisq_result)


#Simple Linear Regression

#Goal: Model the relationship between one predictor (X) and one response (Y).

#Example: Predict car fuel efficiency (mpg) from engine horsepower (hp).

model <- lm(mpg ~ hp, data = mtcars)
summary(model)

# Coefficients: mpg = 30.0989 - 0.0682 * hp
# Interpretation: Each hp increase reduces mpg by 0.07 units.

# Make predictions
new_hp <- data.frame(hp = c(100, 150, 200))
pred_mpg <- predict(model, newdata = new_hp)
pred_mpg

# Visualise regression line
ggplot(mtcars, aes(x = hp, y = mpg)) +
  geom_point(color = "darkgreen", size = 3) +
  geom_smooth(method = "lm", se = TRUE, color = "red") +
  labs(title = "Linear Regression: mpg ~ hp", x = "Horsepower", y = "Miles per Gallon") +
  theme_minimal()

#Bar Chart
# We will use ggplot2 for elegant graphics. Data: iris (flower measurements) and mtcars.

#Purpose: Compare categorical aggregates.
avg_sepal <- aggregate(Sepal.Length ~ Species, data = iris, FUN = mean)

ggplot(avg_sepal, aes(x = Species, y = Sepal.Length, fill = Species)) +
  geom_bar(stat = "identity") +
  labs(title = "Mean Sepal Length by Species", y = "Sepal Length (cm)") +
  theme_minimal() +
  scale_fill_brewer(palette = "Set2")

#Line Graph

#Purpose: Show trends over an ordered variable (e.g., time, sorted values).

mtcars_sorted <- mtcars[order(mtcars$hp), ]
mtcars_sorted$index <- 1:nrow(mtcars_sorted)

ggplot(mtcars_sorted, aes(x = index, y = mpg)) +
  geom_line(color = "blue", size = 1) +
  geom_point(color = "red") +
  labs(title = "MPG Trend with Increasing Horsepower", x = "Car Index (sorted by hp)", y = "MPG") +
  theme_bw()

#Heatmap

#Purpose: Visualize correlation matrix or matrix of values.

# Correlation matrix of numeric variables in mtcars
cor_matrix <- cor(mtcars[, c("mpg", "disp", "hp", "wt", "qsec")])

# Heatmap using corrplot
corrplot(cor_matrix, method = "color", type = "upper", 
         tl.col = "black", tl.srt = 45, addCoef.col = "black")

# Alternatively with ggplot2 (more flexible)
library(reshape2)
melted_cor <- melt(cor_matrix)
ggplot(melted_cor, aes(x = Var1, y = Var2, fill = value)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0) +
  labs(title = "Correlation Heatmap") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Clustering Algorithms

# K‑Means Clustering

# Goal: Partition data into k distinct, non‑overlapping groups.

# Example: Cluster iris flowers based on sepal length and width (excluding species labels).

# Select features
iris_features <- iris[, c("Sepal.Length", "Sepal.Width")]

# Scale the data (important for k-means)
iris_scaled <- scale(iris_features)

# Determine optimal number of clusters using Elbow method
wss <- sapply(1:10, function(k) {
  kmeans(iris_scaled, centers = k, nstart = 25)$tot.withinss
})

# Plot elbow
plot(1:10, wss, type = "b", pch = 19, frame = FALSE,
     xlab = "Number of clusters K", ylab = "Total within-clusters sum of squares")
# Elbow at K = 3

# Apply k-means with k=3
set.seed(123)
kmeans_result <- kmeans(iris_scaled, centers = 3, nstart = 25)
table(kmeans_result$cluster, iris$Species)  # Compare with true labels

# Visualise clusters
fviz_cluster(kmeans_result, data = iris_scaled,
             palette = c("#2E9FDF", "#00AFBB", "#E7B800"),
             geom = "point", ellipse.type = "convex",
             ggtheme = theme_bw())

# Hierarchical Clustering

# Goal: Build a tree of clusters (dendrogram) without pre‑specifying k.

# Compute distance matrix (Euclidean)
dist_matrix <- dist(iris_scaled, method = "euclidean")

# Perform hierarchical clustering using Ward's method
hc <- hclust(dist_matrix, method = "ward.D2")

# Plot dendrogram
plot(hc, main = "Dendrogram of Iris Data", xlab = "", sub = "", cex = 0.6)

# Cut tree into 3 clusters
clusters_hc <- cutree(hc, k = 3)
table(clusters_hc, iris$Species)

# Add rectangle around clusters
rect.hclust(hc, k = 3, border = 2:4)


# Build a regression model of mpg on wt (weight). Predict mpg for a 3,000 lb car

model_wt <- lm(mpg ~ wt, data = mtcars)
summary(model_wt)

# Prediction for 3000 lb (wt is in 1000 lbs, so wt = 3)
new_car <- data.frame(wt = 3)
predict(model_wt, new_car)


# Rando Forest Model
# Install only once
install.packages("randomForest")

# Load the package
library(randomForest)
library(ggplot2)   # for optional plots

# Classification with Iris Data (20 minutes)

# Goal: Predict species of iris flower from sepal/petal measurements.

# Train the model

set.seed(123)  # for reproducibility

# Train random forest classifier
rf_class <- randomForest(Species ~ ., 
                         data = iris, 
                         ntree = 500,        # number of trees
                         mtry = 2,           # try 2 variables at each split
                         importance = TRUE)  # compute variable importance

# Print model summary
print(rf_class)

# Predict on the same data
predictions <- predict(rf_class, iris)

# Confusion matrix
table(Predicted = predictions, Actual = iris$Species)

# Calculate accuracy
accuracy <- sum(predictions == iris$Species) / nrow(iris)
print(paste("Accuracy:", round(accuracy, 4)))

# Extract importance scores
importance(rf_class)

# Plot variable importance
varImpPlot(rf_class, main = "Variable Importance for Iris Species")

## Regression with mtcars Data (20 minutes)

#Goal: Predict miles per gallon (mpg) from car attributes (hp, wt, cyl, etc.).

# Train regression random forest

set.seed(456)

# Regression forest (mpg is numeric)
rf_reg <- randomForest(mpg ~ ., 
                       data = mtcars, 
                       ntree = 500,
                       mtry = 3,          # default for regression: p/3 ≈ 3
                       importance = TRUE)

print(rf_reg)

# Predict & evaluate

# Predict on training set
pred_mpg <- predict(rf_reg, mtcars)

# Calculate RMSE (Root Mean Squared Error)
rmse <- sqrt(mean((mtcars$mpg - pred_mpg)^2))
print(paste("RMSE:", round(rmse, 2)))

# Plot actual vs predicted
plot(mtcars$mpg, pred_mpg, 
     xlab = "Actual MPG", ylab = "Predicted MPG",
     main = "Random Forest Regression: Actual vs Predicted")
abline(0, 1, col = "red", lwd = 2)

# Variable importance for regression

varImpPlot(rf_reg, main = "Variable Importance for MPG Prediction")

# Parameter Tuning

tune_mtry <- tuneRF(x = iris[, -5],           # predictors
                    y = iris[, 5],            # response
                    ntreeTry = 100,
                    stepFactor = 1.5,
                    improve = 0.01,
                    trace = TRUE)

# Best mtry is the one with lowest OOB error
print(tune_mtry)
