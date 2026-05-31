# ==============================================================================
# Lab 02: Control Flow, Loops, and Iterations in R
# ==============================================================================
# Focus: String manipulation, loops (for, while, repeat), conditionals (if/else),
# and user-input processing.
# ==============================================================================

# 1. String Manipulation
first_name <- "Tanmay"
last_name <- "Bhatt"

paste(first_name, last_name)

extension <- "@ddn.upes.ac.in"

# 2. Simple For Loops
  for (i in 1:6) {
      print(i)
  }

# Vector iteration
names_list <- c("tanmay", "Bhatt", "Singh")
  for (n in names_list) {
      print(paste("Hello", n))
  }

  for (i in names_list) {
      print(i)
  }

# Storing computation in a vector dynamically
squares <- c()
  for (i in 1:5) {
      squares[i] <- i^2
  }
print(squares)

# 3. While Loops
i <- 1
  while (i <= 2) {
      print(i)
      i <- i + 1
  }

# Summing elements of a vector with a for loop
num <- c(1, 2, 3, 4, 4, 5)
sum_val <- 0
  for (i in 1:length(num)) {
      print(num[i])
      sum_val <- sum_val + num[i]
  }
print(sum_val)

# Summing elements of a vector with a while loop
num <- c(1, 2, 3, 4, 4, 5)
sum_val <- 0
i <- 1
  while (i <= length(num)) {
      sum_val <- sum_val + num[i]
      i <- i + 1
  }
print(sum_val)

# Simple counter loop
count <- 1
  while (count <= 5) {
      print(count)
      count <- count + 1
  }

# 4. Repeat Loops & Break Statements
x <- 1
  repeat {
      print(x)
      x <- x + 1
      if (x > 100) {
          break
      }
  }

# Note on Loop Control:
# In the loop below, x starts at 1, increments to 2.
# Since x is not equal to 7, the code falls to the 'else' block and breaks instantly.
# This serves as a demonstration of conditional termination.
x <- 1
  while (x <= 100) {
      print(x)
      x <- x + 1
      if (x == 7) {
          next
      } else {
          break
      }
  }

# 5. Interactive User Input (readline)
# Prompts user for input and validates if age is between 1 and 100.
# Note: In non-interactive environments (like automated tests), readline() may return NA.
if (interactive()) {
    repeat {
        x <- as.numeric(readline("Enter your age: "))
        
        if (!is.na(x) && x >= 1 && x <= 100) {
            print(paste("Your age is", x))
            break
        } else {
            print("Invalid input. Please re-enter.")
        }
    }
} else {
    print("Skipping interactive age prompt (running in non-interactive mode).")
}

# 6. Combined Conditionals with Next
  for (i in 1:20) {
      if (i %% 2 == 0) {
          print(i)
          next
      }
      print(paste("Hello", i))
  }
