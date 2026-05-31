# ==============================================================================
# Lab 09: Customer Purchases and Quarterly Grocery Sales
# ==============================================================================
# Focus: Transaction processing, date conversions, seasonal quarter divisions,
# aggregate cross-tables, and top-seller extraction algorithms.
# ==============================================================================

if (file.exists("Groceries_dataset.csv")) {
  gd <- read.csv("Groceries_dataset.csv")
  gd$Date <- as.Date(gd$Date, format = "%d-%m-%Y")
  
  members <- unique(gd$Member_number)
  items <- unique(gd$itemDescription)
  
  print(paste("Unique Members count:", length(members)))
  print(paste("Unique Items count:", length(items)))
  
  # Initialize user purchase matrix
  gr <- matrix(0, nrow = length(members), ncol = length(items))
  
  # CRITICAL PERFORMANCE WARNING:
  # The nested loop below has a time complexity of O(members * items * transactions).
  # Iterations = 3,898 members * 167 items * 38,765 rows ≈ 25 billion iterations!
  # Running this in R will completely freeze your session.
  # 
  # THE VECTORIZED, INSTANT R ALTERNATIVE:
  # gr <- as.matrix(table(gd$Member_number, gd$itemDescription) > 0) + 0
  # 
  # For demonstration, we keep your classroom loop structure here, but we set it
  # to skip automatically or run only on a tiny sample to keep the script fast.
  
  run_nested_loops <- FALSE # Set to TRUE if you explicitly wish to test it
  if (run_nested_loops) {
      print("Running triply nested loop (warning: this will take very long)...")
      for (i in 1:min(length(members), 10)) { # Restricted to first 10 members for safety
          current_member <- members[i]
          for (j in 1:length(items)) {
              current_item <- items[j]
              for (k in 1:nrow(gd)) {
                  if (gd$Member_number[k] == current_member && gd$itemDescription[k] == current_item) {
                      gr[i, j] <- 1
                  }
              }
          }
      }
  } else {
      print("Applying optimized table mapping to build member-purchase matrix...")
      gr <- as.matrix(table(gd$Member_number, gd$itemDescription) > 0) + 0
      print("Member-purchase matrix initialized instantly!")
  }
  
  print("Matrix dimensions:")
  print(dim(gr))
  print("First 4 rows of purchase matrix:")
  print(head(gr, 4))
  
  # 2. Seasonality Analysis: Quarter Divisions
  gd$month <- format(gd$Date, "%m")
  gd$month <- as.numeric(gd$month)
  gd$quarter <- ""
  
  # Categorizes the 12 months into 3 seasonal blocks (4 months each)
    for (i in 1:nrow(gd)) {
        if (gd$month[i] >= 1 && gd$month[i] <= 4) {
            gd$quarter[i] <- "Q1"
        } else if (gd$month[i] >= 5 && gd$month[i] <= 8) {
            gd$quarter[i] <- "Q2"
        } else {
            gd$quarter[i] <- "Q3"
        }
    }
  
  print("=== Sales counts by Quarter-Blocks ===")
  print(table(gd$quarter))
  
  # Create a contingency table of sales: Quarter vs Product Description
  total_sales <- table(gd$quarter, gd$itemDescription)
  
  # 3. Finding the Top Item in each Quarter
  print("=== Top Selling Items Per Quarter ===")
    for (i in 1:nrow(total_sales)) {
        current_quarter <- rownames(total_sales)[i]
        sales_values <- total_sales[i, ]
        top_item <- names(which.max(sales_values))
        max_sale <- max(sales_values)
        
        # Print statement added to display computed top sales results
        print(paste("Quarter:", current_quarter, "| Top Product:", top_item, "| Total Sales:", max_sale))
    }
} else {
  print("Warning: Groceries_dataset.csv not found in working directory.")
}
