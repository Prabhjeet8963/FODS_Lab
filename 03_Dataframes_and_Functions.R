# ==============================================================================
# Lab 03: Dataframes, Missing Data Imputation, and Custom Functions
# ==============================================================================
# Focus: Data frame handling, column-specific imputation of NA values with 
# column means, and basic custom function creation in R.
# ==============================================================================

# 1. Creating a Data Frame with Missing Values (NA)
c1 <- c(1, 2, 3, NA, 5)
c2 <- c(NA, 2, 3, 4, 5)
c3 <- c(1, 2, NA, 4, NA)

df_data <- data.frame(c1, c2, c3)
print("=== Original Data Frame with NAs ===")
print(df_data)

names(df_data)
# View(df_data) # Interactive data viewer
str(df_data)

# 2. Imputing Missing Values dynamically
# BUG FIXED: The original script replaced all column missing values with c1's mean.
# We corrected the logic so that each column is imputed with its own column mean.
  for (col in names(df_data)) {
      col_mean <- mean(df_data[[col]], na.rm = TRUE)
      df_data[[col]][is.na(df_data[[col]])] <- col_mean
  }

print("=== Cleaned Data Frame (Imputed with Column Means) ===")
print(df_data)

# Testing is.na()
a1 <- c(1, 2, 3, NA, 5)
is.na(a1)

# 3. Custom Functions
# Function without parameters
  say_hello <- function() {
      print("Hello")
  }
say_hello()

# Function with a parameter returning a value
  square_num <- function(x) {
      return(x^2)
  }
print(paste("Square of 4 is:", square_num(4)))
