# -----------------------------------------------------------------------------
# SCRIPT 05 (V2): Report Generation (Com busca por Esporte)
# Author: Diego Antunes
# Project: GOAT Tabletop Sports
# -----------------------------------------------------------------------------

library(tidyverse)
library(writexl)
library(reactable)

# 1. Carregar os dados já processados
ranked_data <- readRDS("data/processed_ranked_games.rds")

# =============================================================================
# PREPARAÇÃO DOS DADOS
# =============================================================================

tabela_para_excel <- ranked_data %>%
  select(
    Ranking = rank_position,
    Jogo = game_name,
    Esportes = sports,          # <--- ADICIONADO AQUI!
    Categoria = sport_category,
    Selo = certification_seal,
    Nota_Final = final_score,
    MDA = mda_rate,
    Imersao = sports_immersion_rate,
    Rejogabilidade = replayability,
    Ano = publication_year
  )

# =============================================================================
# OPÇÃO A: EXCEL (Salva o arquivo atualizado)
# =============================================================================
write_xlsx(tabela_para_excel, "LISTA_OFICIAL_COM_RANKING.xlsx")
message("Excel atualizado! Agora inclui a coluna de Esportes.")

# =============================================================================
# TABELA INTERATIVA BILÍNGUE (EN/PT)
# =============================================================================

tabela_interativa <- reactable(
  tabela_para_excel,
  searchable = TRUE,
  striped = TRUE,
  highlight = TRUE,
  defaultPageSize = 15,
  
  # name for add two languages
  columns = list(
    
    # 1. Ranking
    Ranking = colDef(
      name = "Rank (Posição)", 
      maxWidth = 80, 
      align = "center", 
      style = list(fontWeight = "bold")
    ),
    
    # 2. Nome do Jogo (Game name)
    Jogo = colDef(
      name = "Game (Jogo)", 
      minWidth = 150, 
      style = list(fontWeight = "bold")
    ),
    
    # 3. Esportes (Sports)
    Esportes = colDef(
      name = "Sport (Esporte)",
      minWidth = 140, 
      style = list(color = "#555", fontStyle = "italic")
    ),
    
    # 4. Categoria (Sport Category)
    Categoria = colDef(
      name = "Category (Taxonomia)",
      minWidth = 130
    ),
    
    # 5. Nota Final (Final Score)
    Nota_Final = colDef(
      name = "Final Score (Nota)", 
      maxWidth = 100,
      style = function(value) {
        if (is.na(value)) return(list(color = "gray"))
        color <- if (value >= 8.5) "#D4AF37" else if (value >= 7) "#4DAF4A" else "black"
        list(color = color, fontWeight = "bold")
      },
      format = colFormat(digits = 1)
    ),
    
    # 6. Technical Scores
    MDA = colDef(name = "MDA (Design)", maxWidth = 70),
    Imersao = colDef(name = "Immersion (Imersão)", maxWidth = 90),
    Rejogabilidade = colDef(name = "Replay (Rejog.)", maxWidth = 80),
    Ano = colDef(name = "Year (Ano)", maxWidth = 70),
    
    # 7. Selo de Certificação (seals)
    Selo = colDef(
      name = "Seal (Selo GOAT)",
      minWidth = 140,
      style = function(value) {
        if (is.na(value)) return(list(color = "gray"))
        color <- case_when(
          grepl("Q1", value) ~ "#D4AF37",
          grepl("Q2", value) ~ "#A0A0A0",
          grepl("Q3", value) ~ "#CD7F32",
          grepl("Q4", value) ~ "#4DAF4A",
          TRUE ~ "gray"
        )
        list(color = color, fontWeight = "bold")
      }
    )
  ),
  theme = reactableTheme(
    headerStyle = list(
      backgroundColor = "#2c3e50", 
      color = "white",
      fontSize = "14px", # Letra um pouco menor para caber os dois idiomas
      textTransform = "uppercase"
    ),
    inputStyle = list(width = "100%")
  )
)


# Exibir
tabela_interativa

# Adicionar no final do Script 05
library(htmlwidgets)

# Salvar a tabela como um arquivo HTML na sua pasta do projeto
saveWidget(tabela_interativa, "ranking_esporte_na_mesa.html", selfcontained = TRUE)

message("Arquivo HTML gerado com sucesso! Verifique sua pasta.")
