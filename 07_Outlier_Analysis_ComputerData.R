# ==============================================================================
# Lab 07: Outlier Analysis and Price Correlations (Computer Data)
# ==============================================================================
# Focus: Real-world CSV loading, scatter plots, correlation/covariance matrices,
# missing data imputation, and outlier capping using Interquartile Range (IQR).
# ==============================================================================

# 1. Load Computer Data Dataset
# Relative path is used to ensure code runs correctly in any environment
if (file.exists("Computer_Data.csv")) {
  df <- read.csv("Computer_Data.csv")
  
  variable_types <- data.frame(
    Variable_Name = names(df),
    Data_Type = sapply(df, class)
  )
  print("=== Variable Data Types ===")
  print(variable_types)
  
  print("=== Numerical Summary ===")
  print(summary(df[, c("price", "speed", "hd", "ram", "screen", "ads")]))
  
  # 2. Histograms of Computer Characteristics
  hist(df$price)
  print(paste("Mean Price:", mean(df$price)))
  print(paste("Median Price:", median(df$price)))
  
  hist(df$speed)
  hist(df$hd)
  hist(df$ram)
  
  # 3. Scatter Plots and Linear Relations
  plot(df$speed, df$price,
       main = "Price vs Speed",
       xlab = "Speed (MHz)",
       ylab = "Price",
       col = "black")
  
  print(paste("Correlation (Price vs Speed):", cor(df$price, df$speed)))
  print(paste("Covariance (Price vs Speed):", cov(df$price, df$speed)))
  
  plot(df$hd, df$price,
       main = "Price vs Hard Disk Size",
       xlab = "Hard Disk (MB)",
       ylab = "Price",
       pch = 19,
       col = "darkgreen")
  
  print(paste("Correlation (Price vs HD):", cor(df$price, df$hd)))
  print(paste("Covariance (Price vs HD):", cov(df$price, df$hd)))
  
  plot(df$ram, df$price,
       main = "Price vs RAM",
       xlab = "RAM (MB)",
       ylab = "Price",
       pch = 19,
       col = "pink")
  
  print(paste("Correlation (Price vs RAM):", cor(df$price, df$ram)))
  print(paste("Covariance (Price vs RAM):", cov(df$price, df$ram)))
  
  # Boxplot comparing CD-ROM vs No CD-ROM
  boxplot(price ~ cd,
          data = df,
          main = "Price Comparison: CD-ROM vs No CD-ROM",
          xlab = "CD-ROM",
          ylab = "Price",
          col = c("pink", "lightblue"))
  
  print("=== Mean Price by CD status ===")
  print(aggregate(price ~ cd, data = df, mean))
  
  # 4. Statistical Questions and Subsets
  # Q1: Typical Price
  print(paste("Typical Price (Mean):", mean(df$price)))
  print(paste("Typical Price (Median):", median(df$price)))
  print(paste("Min Price:", min(df$price)))
  print(paste("Max Price:", max(df$price)))
  
  # Q2: Computers with high speed and large hard drive
  avg_speed <- mean(df$speed)
  avg_hd <- mean(df$hd)
  
  fast_large <- df[df$speed > avg_speed & df$hd > avg_hd, ]
  
  print("=== Stats for Fast/Large Computers ===")
  print(paste("Mean Price:", mean(fast_large$price)))
  print(paste("Median Price:", median(fast_large$price)))
  print(paste("Count of Fast/Large Computers:", nrow(fast_large)))
  
  # Q3: Correlations
  print(paste("Cor (Price vs Speed):", cor(df$price, df$speed)))
  print(paste("Cor (Price vs HD):", cor(df$price, df$hd)))
  print(paste("Cor (Price vs RAM):", cor(df$price, df$ram)))
  
  # 5. Outlier Detection and Capping on Price
  # BUG FIXED: The original code attempted to inject NAs and fix outliers on "Computer_Data",
  # which is undefined because the dataset was loaded as variable "df". We replaced 
  # "Computer_Data" with "df" and "colSum" with standard "colSums".
  
  # Introduce NAs in RAM for demonstration
  df$ram[1:5] <- NA
  print("=== Columns with NA (Null counts) ===")
  print(colSums(is.na(df)))
  
  # Boxplot of prices to inspect outliers
  boxplot(df$price, main = "Box plot of Price", ylab = "Price")
  
  # Calculate IQR thresholds
  Q1 <- quantile(df$price, 0.25)
  Q3 <- quantile(df$price, 0.75)
  IQR_val <- Q3 - Q1
  lower_bound <- Q1 - 1.5 * IQR_val
  upper_bound <- Q3 + 1.5 * IQR_val
  
  outliers_list <- df$price[df$price < lower_bound | df$price > upper_bound]
  print(paste("Total outliers detected:", length(outliers_list)))
  
  # Cap outliers to upper/lower boundaries (Winsorization)
  df$price[df$price < lower_bound] <- lower_bound
  df$price[df$price > upper_bound] <- upper_bound
  print("Outliers capped successfully!")
} else {
  print("Warning: Computer_Data.csv not found in working directory.")
}
