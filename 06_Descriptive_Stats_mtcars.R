# ==============================================================================
# Lab 06: Descriptive Statistics and Plotting on mtcars
# ==============================================================================
# Focus: Descriptive statistical indicators (mean, sd, range), logical counting,
# data-frame row filtering, and base R graphical charts (histograms, scatter).
# ==============================================================================

# Load mtcars dataset
data(mtcars)
# View(mtcars)
head(mtcars)
tail(mtcars)
colnames(mtcars)
rownames(mtcars)

# 1. Base Summaries
min(mtcars$mpg)
max(mtcars$mpg)
max(mtcars)
max(mtcars$wt)
min(mtcars$wt)

mean(mtcars$mpg)
median(mtcars$mpg)
var(mtcars$mpg)
sd(mtcars$mpg)
range(mtcars$mpg)

# 2. Logical Counting and Summing
sum(mtcars$mpg > 20 & mtcars$hp > 100)
sum(mtcars$cyl == 4)
sum(mtcars$cyl == 6)
sum(mtcars$cyl == 8)

mean(mtcars$hp)
sum(mtcars$hp <= 100)
range(mtcars$hp)
sd(mtcars$hp)

sum(mtcars$am == 1)
sum(mtcars$am == 0)

table(mtcars$am)
max(mtcars$gear)
table(mtcars$gear)

# 3. Filtering and Slicing mtcars
print("=== Cars with MPG > 20 and HP > 100 ===")
  for (i in 1:nrow(mtcars)) {
      if (mtcars$mpg[i] > 20 & mtcars$hp[i] > 100) {
          print(rownames(mtcars)[i])
      }
  }

# BUG FIXED: Added the missing trailing comma inside the matrix indexing slice bracket.
# R requires df[row_filter, ] to slice rows. Without the comma, it throws a subsetting crash.
filtered_cars <- mtcars[mtcars$mpg > 20 & mtcars$hp < 150 | mtcars$cyl == 6, ]
print("=== Filtered Row-Slices ===")
print(head(filtered_cars))

# 4. Exploratory Visualizations
# Histograms
hist(mtcars$mpg)
hist(mtcars$am)
hist(mtcars$hp)

# Styled Histogram
hist(mtcars$mpg,
     breaks = 10,
     border = "black",
     col = "cyan",
     main = "Distribution of mileage",
     ylab = "number of cars",
     xlab = "Mileage of the cars")

# Scatter plots
plot(mtcars$wt, mtcars$mpg,
     main = "Cars weight vs mileage",
     xlab = "Weight of the car (1000 lbs)",
     ylab = "Mileage of the car (mpg)",
     col = "pink",
     pch = 19)

# Plot mpg vs am
plot(mtcars$am, mtcars$mpg,
     main = "MPG vs Transmission",
     xlab = "Transmission (0=Auto, 1=Manual)",
     ylab = "MPG")
