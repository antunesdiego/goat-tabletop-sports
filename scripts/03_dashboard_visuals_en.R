# -----------------------------------------------------------------------------
# SCRIPT 03 (V5 - High Res): The GOAT Dashboard & Yearly Analysis
# Author: Diego Antunes
# Project: GOAT Tabletop Sports Analysis
# -----------------------------------------------------------------------------

library(tidyverse)
library(ggrepel)
library(scales) # formatting numbers if needed

# 1. Load processed ranked data
if(!file.exists("data/processed_ranked_games.rds")) stop("Data not found! Run Script 01 first.")
ranked_data <- readRDS("data/processed_ranked_games.rds")

# 2. Colors for Certification Seals (Consistent Branding)
seal_colors <- c(
  "Q1 - Gold (Top 25)"            = "#D4AF37",  # Gold
  "Q2 - Silver (26-50)"           = "#A0A0A0",  # Silver
  "Q3 - Bronze (51-75)"           = "#CD7F32",  # Bronze
  "Q4 - Honorable Mention (76-100)"      = "#4DAF4A",  # Verde
  "Not Ranked (Outside Top 100)" = "#95a5a6" # Cinza
)

# =============================================================================
# VISUAL 1: THE GOLD TOP 25 (Lollipop Ranking) - ENGLISH
# =============================================================================

top_25_plot <- ranked_data %>%
  slice_head(n = 25) %>% 
  ggplot(aes(x = reorder(game_name, final_score), y = final_score)) +
  geom_segment(aes(xend = game_name, yend = 0), color = "gray85", size = 0.8) +
  geom_point(aes(color = sport_category), size = 4.5) +
  geom_text(aes(label = round(final_score, 1)), 
            color = "black", size = 2.5, vjust = -1.2, fontface = "bold") +
  coord_flip() + 
  scale_y_continuous(limits = c(0, 10.5)) +
  labs(
    title = "The Gold Top 25: GOAT Sports Tabletop Games",
    subtitle = "Ranked by 'Tabletop Sports' Index",
    x = "", 
    y = "Final Score (0-10)",
    color = "Sport Category - Motor Praxeology\nTeaching Games for Urdestanding"
  ) +
  theme_classic() + # white clean background
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 16),
    axis.text.y = element_text(size = 10, face = "bold")
  )

# Salvar (High Res)
ggsave("plots/01_gold_25_ranking.png", 
       plot = top_25_plot, 
       device = ragg::agg_png, width = 10, height = 10, dpi = 300, bg = "white")

# =============================================================================
# VISUAL 1: Medalhas de Ouro: Melhores de todos os tempos - PORTUGUÊS
# =============================================================================

top_25ouro_plot <- ranked_data %>%
  slice_head(n = 25) %>% 
  ggplot(aes(x = reorder(game_name, final_score), y = final_score)) +
  geom_segment(aes(xend = game_name, yend = 0), color = "gray85", size = 0.8) +
  geom_point(aes(color = sport_category), size = 4.5) +
  geom_text(aes(label = round(final_score, 1)), 
            color = "black", size = 2.5, vjust = -1.2, fontface = "bold") +
  coord_flip() + 
  scale_y_continuous(limits = c(0, 10.5)) +
  labs(
    title = "Medalhas de Ouro Top 25: Melhores Jogos de Tabuleiro de Esporte",
    subtitle = "Ranqueados pelo Índice 'Esporte na Mesa'",
    x = "", 
    y = "Nota Final (0-10)",
    color = "Taxonomia dos esportes - Praxiologia Motriz\n Base Nacional Comum Curricular"
  ) +
  theme_classic() + 
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 16),
    axis.text.y = element_text(size = 10, face = "bold")
  )

# Salvar (High Res)
ggsave("plots/01_ouro_25_ranking.png", 
       plot = top_25ouro_plot, 
       device = ragg::agg_png, width = 10, height = 10, dpi = 300, bg = "white")


# =============================================================================
# VISUAL 2: THE GOAT MATRIX - ENGLISH
# =============================================================================

# Define cut offs for quadrants
cut_x <- 7.5 # sport imersion
cut_y <- 7.5 # Replayability

goat_matrix <- ggplot(ranked_data %>% filter(rank_position <= 50), 
                      aes(x = sports_immersion_rate, y = replayability)) +
  
  # 1. Define Quadrant Lines
  geom_vline(xintercept = cut_x, linetype = "longdash", color = "firebrick", alpha = 0.5) +
  geom_hline(yintercept = cut_y, linetype = "longdash", color = "firebrick", alpha = 0.5) +
  
  # 2. Quadrant Labels (identify each zone)
  annotate("text", x = 9.8, y = 9.8, label = "GOAT ZONE\n(Top Tier)", 
           color = "#D4AF37", fontface = "bold", hjust = 1.5, vjust = 0.2, alpha = 0.8) +
  annotate("text", x = 9.8, y = 5.2, label = "SIMULATION HEAVY\n(Good Theme, Lower Replay)", 
           color = "red", fontface = "italic", hjust = 1, vjust = 0, size = 3) +
  annotate("text", x = 5.2, y = 9.8, label = "ARCADE / ABSTRACT\n(Fun, but less Thematic)", 
           color = "blue", fontface = "italic", hjust = 0, vjust = 1, size = 3) +
  
  # 3. Points games
  geom_point(aes(color = certification_seal, size = mda_rate), alpha = 0.85) +
  
  # 4. Game labes (#rank_position: game_name)
  geom_text_repel(aes(label = paste0("#", rank_position, ": ", game_name)), 
                  size = 3, fontface = "bold", box.padding = 0.6, 
                  max.overlaps = 30, segment.color = "gray80") +
  
  # 5. Scales and Aesthetics
  scale_color_manual(values = seal_colors) +
  scale_size_continuous(range = c(2, 8), name = "Tech Quality (MDA)") +
  
  # fixed axis limits and breaks to maintain consistency square
  scale_x_continuous(limits = c(5, 10), breaks = seq(5, 10, 1)) +
  scale_y_continuous(limits = c(5, 10), breaks = seq(5, 10, 1)) +
  
  labs(
    title = "GOAT Tabletop Sports Games Landscape",
    subtitle = "Crossing Willingness to Play (Y) vs. Thematic Immersion (X)",
    x = "Sport Immersion (Theme) ->", 
    y = "Willingness to Play (BGG Scale) ->",
    color = "GOAT Certification",
    caption = "Bubble Size = Technical Design Quality (MDA)"
  ) +
  
  # 6. White Background
  theme_classic() + 
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 16, color = "#2c3e50"),
    axis.title = element_text(face = "bold"),
    axis.line = element_line(arrow = arrow(length = unit(0.3, "cm"), type = "closed"))
  )

# Salvar (High Res)
ggsave("plots/02_goat_matrix_white.png", 
       plot = goat_matrix, 
       device = ragg::agg_png, width = 11, height = 9, dpi = 300, bg = "white")

# =============================================================================
# VISUAL 2: Panorama dos Melhores (Quadrantes) - PORTUGUÊS
# =============================================================================

goat_matrix_pt <- ggplot(ranked_data %>% filter(rank_position <= 50), 
                         aes(x = sports_immersion_rate, y = replayability)) +
  
  # 1. Define as linhas do quadrante
  geom_vline(xintercept = cut_x, linetype = "longdash", color = "firebrick", alpha = 0.5) +
  geom_hline(yintercept = cut_y, linetype = "longdash", color = "firebrick", alpha = 0.5) +
  
  # 2. Rótulos dos quadrantes
  annotate("text", x = 9.8, y = 9.8, label = "Os melhores\n(Nível Superior)", 
           color = "#D4AF37", fontface = "bold", hjust = 1.5, vjust = 0.2, alpha = 0.8) +
  annotate("text", x = 9.8, y = 5.2, label = "Alta simulação\n(Bom tema, Baixa Rejog.)", 
           color = "red", fontface = "italic", hjust = 1, vjust = 0, size = 3) +
  annotate("text", x = 5.2, y = 9.8, label = "Arcade/Abstrato\n(Divertido, menos temático)", 
           color = "blue", fontface = "italic", hjust = 0, vjust = 1, size = 3) +
  
  # 3. Points games
  geom_point(aes(color = certification_seal, size = mda_rate), alpha = 0.85) +
  
  # 4. Game labes
  geom_text_repel(aes(label = paste0("#", rank_position, ": ", game_name)), 
                  size = 3, fontface = "bold", box.padding = 0.6, 
                  max.overlaps = 30, segment.color = "gray80") +
  
  # 5. Scales and Aesthetics
  scale_color_manual(values = seal_colors) +
  scale_size_continuous(range = c(2, 8), name = "Qualidade Técnica") +
  
  scale_x_continuous(limits = c(5, 10), breaks = seq(5, 10, 1)) +
  scale_y_continuous(limits = c(5, 10), breaks = seq(5, 10, 1)) +
  
  labs(
    title = "Panorama dos Melhores Jogos de Tabuleiro de Esporte",
    subtitle = "Disposição para jogar (Y) vs. Imersão temática (X)",
    x = "Imersão no Esporte (Tema) ->", 
    y = "Disposição para Jogar (Rank do BGG) ->",
    color = "Certificado GOAT",
    caption = "Tamanho do círculo = Qualidade Técnica (MDA)"
  ) +
  
  theme_classic() + 
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 16, color = "#2c3e50"),
    axis.title = element_text(face = "bold"),
    axis.line = element_line(arrow = arrow(length = unit(0.3, "cm"), type = "closed"))
  )

# Salvar (High Res)
ggsave("plots/02_goat_panorama_white.png", 
       plot = goat_matrix_pt, 
       device = ragg::agg_png, width = 11, height = 9, dpi = 300, bg = "white")


# =============================================================================
# VISUAL 3: GOAT OF THE YEAR (Yearly Snapshot)
# =============================================================================

target_year <- 2025 

# Filtrar dados
yearly_data <- ranked_data %>%
  filter(publication_year == target_year) %>%
  arrange(desc(final_score))

if(nrow(yearly_data) > 0) {
  
  yearly_plot <- ggplot(yearly_data, aes(x = reorder(game_name, final_score), y = final_score)) +
    geom_col(aes(fill = sport_category), width = 0.6) + 
    coord_flip() +
    scale_y_continuous(limits = c(0, 10)) +
    labs(
      title = paste("GOAT Awards:", target_year),
      subtitle = "Best Sports Board Games released this year",
      x = "", y = "Final Score",
      fill = "Category"
    ) +
    theme_classic() +
    theme(legend.position = "bottom")
  
  print(yearly_plot)
  
  # Salvar (High Res)
  ggsave(paste0("plots/03_goat_awards_", target_year, ".png"), 
         plot = yearly_plot, 
         device = ragg::agg_png, width = 8, height = 6, dpi = 300, bg = "white")
  
} else {
  message("Nenhum jogo encontrado para o ano de ", target_year)
}

# =============================================================================
# VISUAL 4: CATEGORY CHAMPIONS (Pedagogical Ranking) - ENGLISH
# =============================================================================

category_champs <- ranked_data %>%
  filter(!is.na(sport_category)) %>% 
  group_by(sport_category) %>%
  arrange(desc(final_score)) %>%
  slice_head(n = 5) %>% 
  ungroup()

plot_categories <- ggplot(category_champs, aes(x = reorder(game_name, final_score), y = final_score)) +
  geom_col(aes(fill = sport_category), show.legend = FALSE) +
  geom_text(aes(label = round(final_score, 1)), 
            hjust = -0.2, size = 3, fontface = "bold", color = "gray30") +
  facet_wrap(~sport_category, scales = "free_y", ncol = 2) +
  coord_flip() +
  scale_y_continuous(limits = c(0, 11)) + 
  
  labs(
    title = "Champions by Category (Taxonomy)",
    subtitle = "The 5 best games that represent each sports logic (TGFU)",
    x = "", y = "Final Grade (Sports on the Table)",
    caption = "Ranking divided by the internal logic of the sport",
  ) +
  theme_classic() +
  theme(
    strip.background = element_rect(fill = "#2c3e50"), 
    strip.text = element_text(color = "white", face = "bold"),
    axis.text.y = element_text(size = 9)
  )

# Salvar (High Res)
ggsave("plots/04_ranking_by_categories.png", 
       plot = plot_categories, 
       device = ragg::agg_png, width = 10, height = 12, dpi = 300, bg = "white")


# =============================================================================
# VISUAL 4: Campeões por Categorias - PORTUGUÊS
# =============================================================================

plot_categorias <- ggplot(category_champs, aes(x = reorder(game_name, final_score), y = final_score)) +
  geom_col(aes(fill = sport_category), show.legend = FALSE) +
  geom_text(aes(label = round(final_score, 1)), 
            hjust = -0.2, size = 3, fontface = "bold", color = "gray30") +
  facet_wrap(~sport_category, scales = "free_y", ncol = 2) +
  coord_flip() +
  scale_y_continuous(limits = c(0, 11)) + 
  
  labs(
    title = "Os Campeões por Categoria (Taxonomia)",
    subtitle = "Os 5 melhores jogos que representam cada lógica esportiva (BNCC)",
    x = "", y = "Nota Final (Esporte na Mesa)",
    caption = "Ranking separado pela lógica interna do esporte"
  ) +
  theme_classic() +
  theme(
    strip.background = element_rect(fill = "#2c3e50"), 
    strip.text = element_text(color = "white", face = "bold"),
    axis.text.y = element_text(size = 9)
  )

# Salvar (High Res)
ggsave("plots/04_ranking_por_categorias.png", 
       plot = plot_categorias, 
       device = ragg::agg_png, width = 10, height = 12, dpi = 300, bg = "white")

# =============================================================================
# VISUAL 5: SPORT SPECIFIC RANKING - ENGLISH
# =============================================================================

sport_stats <- ranked_data %>%
  separate_rows(sports, sep = ", ") %>% 
  group_by(sports) %>%
  summarise(
    media_nota = mean(final_score),
    melhor_jogo = game_name[which.max(final_score)], 
    qtd_jogos = n()
  ) %>%
  filter(qtd_jogos >= 2) %>% 
  arrange(desc(media_nota))

plot_sports <- ggplot(sport_stats, aes(x = reorder(sports, media_nota), y = media_nota)) +
  geom_col(fill = "steelblue", width = 0.7) +
  geom_text(aes(label = paste("Top:", melhor_jogo)), 
            hjust = 1.1, color = "white", fontface = "italic", size = 3) +
  coord_flip() +
  labs(
    title = "Performance by Sport",
    subtitle = "Average scores from each sport's games (min. 2 games)",
    x = "", y = "Average of the Final Grade"
  ) +
  theme_classic()

# Salvar (High Res)
ggsave("plots/05_analysi_by_sport.png", 
       plot = plot_sports, 
       device = ragg::agg_png, width = 8, height = 6, dpi = 300, bg = "white")

# =============================================================================
# VISUAL 5: Ranking por Modalidade - PORTUGUÊS
# =============================================================================

plot_esportes <- ggplot(sport_stats, aes(x = reorder(sports, media_nota), y = media_nota)) +
  geom_col(fill = "steelblue", width = 0.7) +
  geom_text(aes(label = paste("Top:", melhor_jogo)), 
            hjust = 1.1, color = "white", fontface = "italic", size = 3) +
  coord_flip() +
  labs(
    title = "Desempenho por Modalidade",
    subtitle = "Média das notas dos jogos de cada esporte (min. 2 jogos)",
    x = "", y = "Média da Nota Final"
  ) +
  theme_classic()

# Salvar (High Res)
ggsave("plots/05_analise_por_modalidade.png", 
       plot = plot_esportes, 
       device = ragg::agg_png, width = 8, height = 6, dpi = 300, bg = "white")

message("All Dashboard Plots saved with High Resolution (RAGG)!")
