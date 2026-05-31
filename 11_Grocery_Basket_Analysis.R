git push -u origin main# ==============================================================================
# Lab 11: Grocery Transactions and Market Basket Explorations
# ==============================================================================
# Focus: Transaction parsing, quarterly aggregation, daily transaction rates, 
# daily item frequencies, and data profiling plots.
# ==============================================================================

# BUG FIXED: Replaced blocking interactive "file.choose()" command with direct relative loading.
if (file.exists("Groceries_dataset.csv")) {
  gd <- read.csv("Groceries_dataset.csv")
  
  # Trim column header whitespaces
  names(gd) <- trimws(names(gd))
  
  gd$Date <- as.Date(gd$Date, format = "%d-%m-%Y")
  
  # Extract Months and standard Quarters (ceiling of month / 3)
  gd$Month <- as.numeric(format(gd$Date, "%m"))
  gd$Quarter <- paste0("Q", ceiling(gd$Month / 3))
  
  # 1. Product Frequencies
  product_freq <- table(gd$itemDescription)
  print("=== Product Frequency Head ===")
  print(head(product_freq))
  
  freq_df <- as.data.frame(product_freq)
  colnames(freq_df) <- c("Product", "Frequency")
  print("=== Top Product Frequencies ===")
  print(head(freq_df))
  
  # Visualizing frequencies
  hist(product_freq,
       main = "Histogram of Product Frequency",
       xlab = "Frequency",
       ylab = "Number of Products",
       col = "skyblue")
  
  # Bar plot of frequencies (shows product counts)
  barplot(head(sort(product_freq, decreasing = TRUE), 10),
          main = "Top 10 Products by Frequency",
          xlab = "Products",
          ylab = "Frequency",
          las = 2,
          col = "lightgreen")
  
  # 2. Transaction Presence-Absence Matrix
  # Generates date-product matrix representation
  one_matrix <- table(gd$Date, gd$itemDescription)
  one_matrix[one_matrix > 0] <- 1
  print("=== Presence-Absence Matrix Head ===")
  print(head(one_matrix[, 1:5]))
  
  # 3. Aggregating Top Product Per Quarter
  items <- unique(gd$itemDescription)
  quarters <- unique(gd$Quarter)
  
  result <- data.frame(Quarter = character(),
                       Max_Item = character(),
                       Max_Count = numeric(),
                       stringsAsFactors = FALSE)
  
  print("Extracting quarterly top sales...")
    for (q in quarters) {
        max_count <- 0
        max_item <- ""
        
        # Filter quarter transaction subset
        temp_data <- gd[gd$Quarter == q, ]
        
        for (item in items) {
            count <- sum(temp_data$itemDescription == item)
            if (count > max_count) {
                max_count <- count
                max_item <- item
            }
        }
        
        result <- rbind(result,
                        data.frame(Quarter = q,
                                   Max_Item = max_item,
                                   Max_Count = max_count))
    }
  
  print("=== Quarterly Top Selling Products ===")
  print(result)
  
  # 4. Daily Transactions Profiling
  items_per_day <- table(gd$Date)
  print("=== Items Sold Per Day (Sample) ===")
  print(head(items_per_day))
  
  hist(items_per_day,
       main = "Histogram of Items Sold Per Day",
       xlab = "Items Sold",
       ylab = "Number of Days",
       col = "orange")
  
  max_items_day <- max(items_per_day)
  max_items_date <- names(items_per_day)[which.max(items_per_day)]
  
  cat("\nMaximum items sold on a single date:\n")
  print(data.frame(Date = max_items_date, Items_Sold = max_items_day))
  
  # 5. Peak Product Identification inside loops
  max_item_single_day <- ""
  max_count_single_day <- 0
  max_day <- ""
  
  dates <- unique(gd$Date)
  
  print("Profiling peak daily sales...")
    for (d in dates) {
        temp <- gd[gd$Date == d, ]
        freq <- table(temp$itemDescription)
        
        if (length(freq) > 0 && max(freq) > max_count_single_day) {
            max_count_single_day <- max(freq)
            max_item_single_day <- names(freq)[which.max(freq)]
            max_day <- d
        }
    }
  
  cat("\nItem with highest frequency sold in a single day:\n")
  print(data.frame(Date = as.Date(max_day, origin = "1970-01-01"),
                   Item = max_item_single_day,
                   Frequency = max_count_single_day))
  
  # Visualizing item frequencies on peak sales day
  single_day_data <- gd[gd$Date == max_day, ]
  single_day_freq <- table(single_day_data$itemDescription)
  
  hist(single_day_freq,
       main = "Histogram of Item Frequency (Highest Sales Day)",
       xlab = "Frequency",
       ylab = "Number of Items",
       col = "red")
  
  # Top 10 items on the highest sales day
  barplot(head(sort(single_day_freq, decreasing = TRUE), 10),
          main = "Top Items (Highest Sales Day)",
          xlab = "Items",
          ylab = "Frequency",
          las = 2,
          col = "cyan")
} else {
  print("Warning: Groceries_dataset.csv not found in working directory.")
}
