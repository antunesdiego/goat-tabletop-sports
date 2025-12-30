# -----------------------------------------------------------------------------
# 01_load_data.R
# Purpose: Import and clean the Sports Board Games dataset
# -----------------------------------------------------------------------------

# 1. Load necessary libraries
library(tidyverse) # Includes ggplot2, dplyr, etc.
library(readxl)    # Specifically for reading Excel files
library(janitor)   # For cleaning column names automatically

# 2. Import the data
sports_db <- read_excel("data/df_em_ranking.xlsx") %>% 
  clean_names() # Converts "Game Name" to "game_name" (snake_case)

# 3. Quick Inspection
# Check the structure (columns and types)
glimpse(sports_db)

# Check the first few rows
head(sports_db)

# 4. First Analysis (Sanity Check)
# Let's count how many games you have per category
sports_db %>% 
  count(sport_category, sort = TRUE)
