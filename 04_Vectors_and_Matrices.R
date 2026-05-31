# ==============================================================================
# Lab 04: Data Containers - Vectors and Matrices
# ==============================================================================
# Focus: Vector types, sequence generation, repetition vectors, matrix creation,
# column-binding, row-binding, and dimension naming in R.
# ==============================================================================

# 1. Vector Operations
num_vec <- c(1, 2, 3, 4, 5)
char_vec <- c("abs", "brake", "tyre")
log_vec <- c(TRUE, FALSE, FALSE, TRUE)

# Generating sequences
seq_vec <- 1:10
print(seq_vec)

# Repetition vector
rep_vec <- rep(2, 10)
print(rep_vec)

# 2. Matrix Operations
# Creating a 4x2 matrix
m <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8), nrow = 4, ncol = 2)
print("=== 4x2 Matrix ===")
print(m)

# Creating a matrix from a repeated vector
m1 <- matrix(rep_vec, nrow = 2, ncol = 5)
print("=== 2x5 Replicated Matrix ===")
print(m1)

# 3. Binding Vectors into Matrices
a <- c(1, 2, 3)
b <- c(4, 5, 6)

# Column bind (vectors become columns)
m2 <- cbind(a, b)   
print("=== Column-bound Matrix (cbind) ===")
print(m2)

# Row bind (vectors become rows)
m3 <- rbind(a, b)  
print("=== Row-bound Matrix (rbind) ===")
print(m3)

# 4. Naming Dimensions of Matrices
rownames(m3) <- c("Student1", "Student2")
colnames(m3) <- c("Col1", "Col2", "Col3")
print("=== Named Matrix ===")
print(m3)

# Defining matrix names as a list (dimension names descriptor)
dim_names_list <- list(
  c("Student1", "Student2"),
  c("1", "2", "3")
)
dimnames(m3) <- dim_names_list
print("=== Custom Dimnames Matrix ===")
print(m3)
