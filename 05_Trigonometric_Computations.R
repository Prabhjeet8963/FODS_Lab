# ==============================================================================
# Lab 05: Trigonometric Iterations and Custom Unique Operations
# ==============================================================================
# Focus: Trigonometric functions (sin, cos), loop accumulators, and manual 
# algorithm implementation of unique list checks in R.
# ==============================================================================

# 1. Simple Unique Checking
x <- 1:20
x1 <- sin(x)
x2 <- cos(x)
x4 <- unique(x1)
length(x4)

# 2. Accumulated Loops for Trigonometric Calculations
p <- -100:100
s <- c()
C <- c()

# BUG FIXED: The original code contained "C <- c(t, cos(x))" which appended R's 
# built-in transpose function 't' instead of vector 'C'. Fixed to 'C <- c(C, cos(x))'.
  for (val in p) {
      s <- c(s, sin(val))
      C <- c(C, cos(val))
  }

# 3. Finding unique sine values manually (custom logic)
u_s <- c()
  for (val in s) {
      if (!(val %in% u_s)) {
          u_s <- c(u_s, val)
      }
  }

# 4. Finding unique cosine values manually (custom logic)
u_c <- c()
  for (val in C) {
      if (!(val %in% u_c)) {
          u_c <- c(u_c, val)
      }
  }

# 5. Output Verification Log
print(paste("Total sin values:", length(s)))
print(paste("Unique sin values:", length(u_s)))

print(paste("Total cos values:", length(C)))
print(paste("Unique cos values:", length(u_c)))
