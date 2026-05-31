# ==============================================================================
# Lab 01: Arithmetic Basics, Functions, and Intro to mtcars
# ==============================================================================
# Focus: Fundamental arithmetic, vector operations, basic stats, and dataset 
# inspection in R.
# ==============================================================================

# Basic arithmetic demonstrations
5 - 3

a <- 10
b <- 4
a - b
a * b
a / b

print(a)
print("prabhu")

p <- 34 + 56
p

q <- 10 / 3
# Note: Write 'q' directly in the console to inspect the variable's value.

# Variable assignment note:
# '2 + 3 = x' is syntactically invalid. R uses 'x <- value' or 'x = value'.

# Vector creation and basic statistical functions
x <- c(10, 20, 30) 
x

y <- (12 + mean(x))
y

mean(x)
median(x)
var(x)
sum(y)

# Inspecting built-in datasets (mtcars)
data(mtcars)
# View(mtcars) # Opens interactive data viewer in RStudio
head(mtcars)
head(mtcars, 3)
str(mtcars)      
summary(mtcars)  

# Accessing columns
mtcars$mpg
z <- mtcars$mpg
mean(z)

# Custom loop to count missing values (NA) across all columns in mtcars
  for (col in colnames(mtcars)) {
      na_count <- sum(is.na(mtcars[[col]]))
      print(paste("Column:", col, "| NA values:", na_count))
  }
