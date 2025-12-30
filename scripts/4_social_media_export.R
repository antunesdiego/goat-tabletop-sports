# -----------------------------------------------------------------------------
# SCRIPT 04: Instagram & Social Media Exports (High Res)
# Author: Diego Antunes
# Project: GOAT Tabletop Sports
# Focus: Mobile-first visualization (Big fonts, 4:5 and 9:16 ratios)
# -----------------------------------------------------------------------------

library(tidyverse)
library(ggrepel)
library(janitor)

# 1. Carregar Dados
if(!file.exists("data/processed_ranked_games.rds")) stop("Data not found! Run Script 01 first.")
ranked_data <- readRDS("data/processed_ranked_games.rds")

# 2. Definições de Design para Mobile (INSTA THEME)
# No celular, tudo precisa ser maior e mais grosso
insta_theme <- theme_classic(base_size = 14) + # Fonte base maior
  theme(
    plot.title = element_text(face = "bold", size = 22, hjust = 0.5), # Título centralizado
    plot.subtitle = element_text(size = 14, hjust = 0.5, color = "gray40"),
    legend.position = "bottom",
    legend.text = element_text(size = 11),
    axis.title = element_text(face = "bold", size = 12),
    axis.text = element_text(size = 12, face = "bold"),
    panel.background = element_rect(fill = "#FAFAFA", color = NA), # Fundo quase branco (confortável)
    plot.background = element_rect(fill = "#FAFAFA", color = NA),
    legend.background = element_rect(fill = "#FAFAFA", color = NA)
  )

# Cores Oficiais
seal_colors <- c(
  "Q1 - Gold (Top 25)"            = "#D4AF37",
  "Q2 - Silver (26-50)"           = "#A0A0A0",
  "Q3 - Bronze (51-75)"           = "#CD7F32",
  "Q4 - Honorable Mention (76-100)"      = "#4DAF4A",
  "Not Ranked (Outside Top 100)" = "#95a5a6"
)

# =============================================================================
# POST 1: FEED PORTRAIT (4:5 Ratio)
# O Gráfico de Matriz (GOAT Matrix) otimizado para Feed
# =============================================================================

# Vamos filtrar para Top 30 para não poluir a tela pequena do celular
mobile_matrix <- ggplot(ranked_data %>% filter(rank_position <= 30), 
                        aes(x = sports_immersion_rate, y = replayability)) +
  
  # Quadrantes
  geom_vline(xintercept = 7.5, linetype = "dashed", color = "gray80") +
  geom_hline(yintercept = 7.5, linetype = "dashed", color = "gray80") +
  
  # Rótulo de Zona (Simplificado para mobile)
  annotate("text", x = 9.8, y = 9.8, label = "GOAT ZONE", 
           color = "#D4AF37", fontface = "bold", hjust = 1, size = 6) +
  
  # Pontos (Um pouco maiores para ver no celular)
  geom_point(aes(color = certification_seal, size = mda_rate), alpha = 0.9) +
  
  # Rótulos dos Jogos (Texto maior e com fundo branco)
  geom_text_repel(aes(label = paste0("#", rank_position, " ", game_name)), 
                  size = 4, # Fonte grande para ler no feed
                  fontface = "bold", 
                  box.padding = 0.5, 
                  max.overlaps = 50,
                  bg.color = "white", # Contorno branco para ler melhor
                  bg.r = 0.15) +
  
  scale_color_manual(values = seal_colors) +
  scale_size_continuous(range = c(4, 10), guide = "none") + # Removemos a legenda de tamanho
  
  scale_x_continuous(limits = c(5, 10), breaks = seq(5, 10, 1)) +
  scale_y_continuous(limits = c(5, 10), breaks = seq(5, 10, 1)) +
  
  labs(
    title = "GOAT Tabletop Sports Games",
    subtitle = "Analysis: Replayability (Y) vs Immersion (X)",
    x = "Theme / Immersion ->",
    y = "Willingness to Play ->",
    color = "" # Sem título na legenda para economizar espaço
  ) +
  insta_theme +
  theme(legend.box.spacing = unit(0.2, "cm")) # Legenda mais colada

# Salvar em 4:5 (High Res)
ggsave("plots/instagram_feed_matrix.png", 
       plot = mobile_matrix, 
       device = ragg::agg_png, width = 8, height = 10, dpi = 300, bg = "#FAFAFA")


# =============================================================================
# POST 2: STORIES (9:16 Ratio)
# Top 10 Lista Vertical - Perfeito para Stories
# =============================================================================

mobile_top10 <- ranked_data %>%
  slice_head(n = 10) %>% # Apenas Top 10 cabe bem no Stories
  ggplot(aes(x = reorder(game_name, final_score), y = final_score)) +
  
  geom_col(aes(fill = sport_category), width = 0.7) +
  
  # Nota dentro da barra
  geom_text(aes(label = round(final_score, 1)), 
            hjust = 1.5, color = "white", fontface = "bold", size = 7) +
  
  # Posição (#1, #2...) na base da barra
  geom_text(aes(y = 0.1, label = paste0("#", rank_position)), 
            hjust = 0, color = "white", fontface = "bold", size = 6) +
  
  coord_flip() +
  scale_y_continuous(expand = c(0,0), limits = c(0, 10.5)) +
  
  labs(
    title = "TOP 10\nSPORTS GAMES", # Quebra de linha para impacto vertical
    subtitle = "The GOAT Collection",
    x = "", y = "",
    fill = "Sport Category"
  ) +
  insta_theme +
  theme(
    axis.text.y = element_text(size = 16, face = "bold", color = "black"), # Nomes grandes
    axis.text.x = element_blank(), # Remove números do eixo X
    axis.ticks = element_blank(),
    panel.grid = element_blank(), # Limpa tudo
    legend.position = "top",
    legend.title = element_blank(),
    plot.margin = margin(t = 20, r = 10, b = 20, l = 10) # Margens para não cortar no celular
  )

# Salvar em 9:16 (High Res)
ggsave("plots/instagram_stories_top10.png", 
       plot = mobile_top10, 
       device = ragg::agg_png, width = 9, height = 16, dpi = 300, bg = "#FAFAFA")


# =============================================================================
# POST 3: CARROSSEL POR CATEGORIA (Loop Automático)
# Gera uma imagem 4:5 para cada categoria de esporte (Top 5)
# =============================================================================

# Lista de Categorias válidas
lista_categorias <- ranked_data %>%
  filter(!is.na(sport_category), sport_category != "NA", sport_category != "") %>%
  pull(sport_category) %>%
  unique()

message("Generating Carousel Images...")

for (cat in lista_categorias) {
  
  # A. Preparar os dados DAQUELA categoria
  dados_cat <- ranked_data %>%
    filter(sport_category == cat) %>%
    arrange(desc(final_score)) %>%
    slice_head(n = 5) %>%
    mutate(rank_local = row_number()) # Rank 1, 2, 3 dentro da categoria
  
  if(nrow(dados_cat) > 0) {
    
    # B. Gerar o Gráfico
    p <- ggplot(dados_cat, aes(x = reorder(game_name, final_score), y = final_score)) +
      geom_col(fill = "#2c3e50", width = 0.6) +
      
      # Nota na ponta da barra
      geom_text(aes(label = round(final_score, 1)), 
                hjust = 1.4, color = "white", fontface = "bold", size = 8) +
      
      # Posição
      geom_text(aes(y = 0.1, label = paste0("#", rank_local)), 
                hjust = 0, color = "white", size = 6, fontface = "bold") +
      
      coord_flip() +
      scale_y_continuous(limits = c(0, 10.5)) +
      labs(
        title = toupper(cat),
        subtitle = "Top 5 Games (Category)",
        x = "", y = ""
      ) +
      insta_theme
    
    # C. Salvar (High Res)
    nome_arquivo <- paste0("plots/insta_cat_", janitor::make_clean_names(cat), ".png")
    
    ggsave(nome_arquivo, 
           plot = p, 
           device = ragg::agg_png, width = 8, height = 10, dpi = 300, bg = "#FAFAFA")
    
    message(paste("Saved:", cat))
  }
}

message("=== SOCIAL MEDIA EXPORTS COMPLETE ===")
