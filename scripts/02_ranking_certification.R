# -----------------------------------------------------------------------------
# SCRIPT 02: Ranking Calculation and Certification System
# Author: Diego Antunes
# Project: Sports tabletop Games Analysis
# Description: Calculates the 'Sports on the Table' or 'Esporte na Mesa' score and assigns
#              Q1-Q4 certification badges based on ranking position.
# -----------------------------------------------------------------------------

# 1. Load Libraries
library(tidyverse)
library(readxl)
library(janitor)

# 2. Load and Clean Data
raw_data <- read_excel("data/df_em_ranking.xlsx") %>% 
  clean_names() %>%
  # --- Clean data---
  filter(!is.na(game_name)) %>%       # Remove NA game names
  filter(!is.na(sport_category)) %>%  # Remove games without category
  filter(game_name != "")             # Remove empty game names

# 3. Algorithm: Calculate Score and Assign Quartiles
certified_games <- raw_data %>%
  mutate(
    # A. Calculate Composite Score (Average of 3 key metrics)
    final_score = (mda_rate + sports_immersion_rate + replayability) / 3
  ) %>%
  
  # B. Sort by Score (Descending) to establish the Ranking
  arrange(desc(final_score)) %>%
  
  # C. Add Rank Position Index
  mutate(rank_position = row_number()) %>%
  
  # D. Apply Certification Logic (The "Seals")
  mutate(
    certification_seal = case_when(
      rank_position <= 25  ~ "Q1 - Gold (Top 25)",
      rank_position <= 50  ~ "Q2 - Silver (26-50)",
      rank_position <= 75  ~ "Q3 - Bronze (51-75)",
      rank_position <= 100 ~ "Q4 - Honorable Mention (76-100)",
      TRUE                 ~ "Not Ranked (Outside Top 100)"
    )
  )

# 4. Define Color Palette for Visualizations (Branding)
# We store this vector to use in all future plots for consistency
seal_colors <- c(
  "Q1 - Gold (Top 25)"      = "#FFD700",  # Gold
  "Q2 - Silver (26-50)"        = "#C0C0C0",  # Silver/Light Grey
  "Q3 - Bronze (51-75)"      = "#CD7F32",  # Bronze
  "Q4 - Honorable Mention (76-100)"     = "#4DAF4A",  # Green
  "Not Ranked (Outside Top 100)" = "#95a5a6" # Grey
)

# 5. Quick Verification
# Check the top 10 games to see if logic holds
print(head(certified_games %>% select(game_name, final_score, certification_seal), 10))

# 6. Save Processed Data
# Saving as .RDS preserves column types (factors, numbers) better than CSV
saveRDS(certified_games, "data/processed_ranked_games.rds")
message("Ranking and certification process completed. Data saved to 'data/processed_ranked_games.rds'.")

#List games with solo mode
solo_games <- certified_games %>%
  filter(solo_mode == TRUE) %>%
  select(game_name, final_score, certification_seal, sport_category)

print(solo_games)
view(solo_games)
write_csv(solo_games, "data/solo_mode_games.csv")
message("List of solo mode games saved to 'data/solo_mode_games.csv'.")
# =============================================================================
