# -----------------------------------------------------------------------------
# SCRIPT 06: MACHINE LEARNING INSIGHTS (BILINGUAL EDITION - HIGH RES)
# Author: Diego Antunes
# Project: GOAT Tabletop Sports
# Goals: 
#   1. Regression: Determine drivers of Replayability (Supervised).
#   2. Clustering: Compare AI grouping vs Manual Ranking (Unsupervised).
#   3. Output: Bilingual plots for International/Brazilian community.
# -----------------------------------------------------------------------------

library(tidyverse)
library(broom)       # Tidy statistical summaries
library(cluster)     # K-Means algorithm
library(factoextra)  # Cluster visualization
library(ggrepel)     # Non-overlapping labels

# 1. LOAD & PREP DATA
# -----------------------------------------------------------------------------
if(!file.exists("data/processed_ranked_games.rds")) stop("Data not found!")
ranked_data <- readRDS("data/processed_ranked_games.rds")

# Prepare data for ML (Handle Factors and NA)
dados_ml <- ranked_data %>%
  filter(!is.na(replayability)) %>%
  mutate(
    sport_category = as.factor(sport_category),
    # Logic: If 'solo_mode' exists in Excel, use it. If not, assume 0.
    has_solo = if("solo_mode" %in% names(.)) as.factor(solo_mode) else as.factor(0)
  )

message("--- DATA LOADED & PREPPED ---")

# =============================================================================
# PART 1: REGRESSION ANALYSIS (DRIVERS OF REPLAYABILITY)
# =============================================================================

message("Running Regression Analysis...")

# Model: Replayability explained by MDA, Immersion, Year, Category, and Solo Mode
modelo_completo <- lm(replayability ~ mda_rate + sports_immersion_rate + 
                        publication_year + sport_category + has_solo, 
                      data = dados_ml)

# Tidy Results & Clean Term Names for Plotting
resultados <- tidy(modelo_completo, conf.int = TRUE) %>%
  filter(term != "(Intercept)") %>%
  mutate(
    term_clean = case_when(
      term == "mda_rate" ~ "Design Quality (MDA)",
      term == "sports_immersion_rate" ~ "Immersion / Imersão",
      term == "publication_year" ~ "Year / Ano",
      term == "has_solo1" ~ "Solo Mode / Modo Solo",
      grepl("sport_category", term) ~ paste("Cat:", gsub("sport_category", "", term)),
      TRUE ~ term
    )
  ) %>%
  arrange(desc(estimate))

# --- PLOT 1: FOREST PLOT (BILINGUAL) ---
p_regressao <- ggplot(resultados, aes(x = estimate, y = reorder(term_clean, estimate))) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.2, color = "gray60") +
  geom_point(aes(color = estimate > 0), size = 4) +
  scale_color_manual(values = c("#E74C3C", "#27AE60")) + # Red/Green
  labs(
    title = "Drivers of Replayability / Fatores de Rejogabilidade",
    subtitle = "Analysis of variables influencing the desire to play again.\nAnálise das variáveis que influenciam a vontade de jogar.",
    x = "Impact on Score / Impacto na Nota (Estimate)",
    y = "Variables / Variáveis",
    caption = "Confidence Interval 95% / Intervalo de Confiança 95%"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold"),
    plot.subtitle = element_text(color = "gray40", size = 10)
  )

# Salvar (High Res)
ggsave("plots/06_ml_regression_drivers.png", 
       plot = p_regressao, 
       device = ragg::agg_png, width = 10, height = 7, dpi = 300, bg = "white")

message("Plot 1 Saved (High Res): plots/06_ml_regression_drivers.png")


# =============================================================================
# PART 2: CLUSTERING (MAN VS MACHINE)
# =============================================================================

message("Running Clustering Analysis...")

# Prepare numeric data for K-Means
dados_cluster_raw <- ranked_data %>%
  select(game_name, mda_rate, sports_immersion_rate, replayability) %>%
  column_to_rownames("game_name")

dados_scaled <- scale(dados_cluster_raw)

# K-Means (k=4 to match Quartiles)
set.seed(123)
km_res <- kmeans(dados_scaled, centers = 4, nstart = 25)

# PCA for Visualization (Reduce to 2D)
pca_coords <- as.data.frame(prcomp(dados_scaled)$x) %>% 
  select(PC1, PC2) %>%
  mutate(game_name = rownames(.))

# Merge everything for plotting
plot_data <- ranked_data %>%
  inner_join(pca_coords, by = "game_name") %>%
  mutate(cluster_k = as.factor(km_res$cluster))

# IDENTIFY THE "ELITE" CLUSTER AUTOMATICALLY
# The cluster with the highest average Final Score
cluster_elite_id <- plot_data %>%
  group_by(cluster_k) %>%
  summarise(media = mean(final_score)) %>%
  arrange(desc(media)) %>%
  slice(1) %>%
  pull(cluster_k)

# IDENTIFY "HIDDEN GEMS" (The Injusticed Ones)
# Logic: Machine says Elite (Cluster), Human says Q2 (Silver)
hidden_gems <- plot_data %>%
  filter(cluster_k == cluster_elite_id) %>%
  filter(grepl("Q2", certification_seal) | grepl("Silver", certification_seal)) # Check both naming conventions

# --- PLOT 2: CLUSTER MAP (BILINGUAL) ---
p_cluster <- ggplot(plot_data, aes(x = PC1, y = PC2)) +
  
  # Background Areas (Machine Learning View)
  stat_ellipse(aes(fill = cluster_k), geom = "polygon", alpha = 0.1, show.legend = FALSE) +
  
  # Points (Human Ranking View)
  geom_point(aes(color = certification_seal, shape = certification_seal), size = 3.5, alpha = 0.8) +
  
  # Labels ONLY for Hidden Gems
  geom_label_repel(data = hidden_gems, aes(label = game_name), 
                   box.padding = 0.5, size = 3.5, fontface = "bold", 
                   color = "#d35400", fill = "white", segment.color = "grey50") +
  
  # Colors match the Official Seal (Updated to match Script 01 names)
  scale_color_manual(values = c(
    "Q1 - Gold (Top 25)"            = "#D4AF37",
    "Q2 - Silver (26-50)"           = "#A0A0A0",
    "Q3 - Bronze (51-75)"           = "#CD7F32",
    "Q4 - Honorable Mention (76-100)"      = "#4DAF4A",
    "Not Ranked (Outside Top 100)" = "#95a5a6"
  )) +
  
  # Labels
  labs(
    title = "Man vs. Machine: Ranking Validation / Validação do Ranking",
    subtitle = "Background: AI Clusters | Points: Manual Ranking (Q1-Q4)\nHighlighted: 'Hidden Gems' (Rated Q2 by Human, classified as Elite by AI)",
    x = "Dimension 1 (Quality/Qualidade)",
    y = "Dimension 2 (Style/Estilo)",
    color = "Seal / Selo",
    shape = "Seal / Selo"
  ) +
  
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "bottom",
    legend.box = "vertical",
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(color = "gray40", size = 11)
  )

# Salvar (High Res)
ggsave("plots/06_ml_clusters_validation.png", 
       plot = p_cluster, 
       device = ragg::agg_png, width = 12, height = 9, dpi = 300, bg = "white")

message("Plot 2 Saved (High Res): plots/06_ml_clusters_validation.png")

message("--- MACHINE LEARNING PIPELINE COMPLETE ---")
