# Código completo para o aplicativo Shiny

# Configuração inicial de logs
options(shiny.trace=TRUE)
options(shiny.fullstacktrace=TRUE)
options(shiny.error=function() {
  cat(file=stderr(), paste0("ERRO em ", Sys.time(), ":\n"))
  traceback(2)
})

# Verificação de arquivos e diretórios
cat("Verificando diretório de trabalho:", getwd(), "\n")
cat("Listando arquivos no diretório atual:\n")
print(list.files())
cat("Verificando pasta data:\n")
print(list.files("data"))

options(repos = c(
  CRAN = "https://packagemanager.posit.co/cran/latest"
))

# Carregar pacotes com verificação
for(pkg in c('shiny', 'shinydashboard', 'tidyr', 'dplyr', 'ggplot2', 'readr', 
             'purrr', 'tibble', 'stringr', 'forcats', 'highcharter', 'jsonlite',
             'RColorBrewer', 'DT', 'lubridate', 'igraph')) {
  cat("Carregando pacote:", pkg, "\n")
  library(pkg, character.only = TRUE)
}



# Captura de erros de inicialização
tryCatch({
  source("caged-baixar-dados.R")
  cat("[INFO] caged-baixar-dados.R carregado com sucesso\n")
}, error = function(e) {
  cat("[ERRO] Falha ao carregar caged-baixar-dados.R:\n", conditionMessage(e), "\n")
})

tryCatch({
  geojson_url <- "https://code.highcharts.com/mapdata/countries/br/br-all.geo.json"
  br_map <- fromJSON(geojson_url, simplifyVector = FALSE)
  cat("[INFO] GeoJSON carregado com sucesso\n")
}, error = function(e) {
  cat("[ERRO] Falha ao carregar GeoJSON:\n", conditionMessage(e), "\n")
})



# Criação de funções permanece fora
criar_crosstable_generalizado <- function(data, var1, var2) {
  data %>%
    group_by(!!sym(var1), !!sym(var2)) %>%
    tally() %>%
    spread(!!sym(var2), n, fill = 0)
}

get_data <- function(mes) {
  df_resumo %>%
    filter(data_mes == mes) %>%
    arrange(desc(saldo_somado)) %>%
    slice(1:20) %>%
    select(sigla_uf, saldo_somado)
}

get_data_mapa <- function(mes) {
  df_resumo %>%
    filter(data_mes == mes) %>%
    arrange(desc(saldo_somado)) %>%
    select(sigla_uf, saldo_somado) %>%
    mutate(sigla_uf = toupper(sigla_uf))
}

# Função para converter mês para português
mes_em_portugues <- function(data) {
  meses_pt <- c("janeiro", "fevereiro", "março", "abril", "maio", "junho", 
                "julho", "agosto", "setembro", "outubro", "novembro", "dezembro")
  mes_num <- as.integer(format(data, "%m"))
  mes_pt <- meses_pt[mes_num]
  ano <- format(data, "%Y")
  return(paste(mes_pt, "de", ano))
}

# Selecionar o último valor disponível para o mês
mes_selecionado <- df_resumo %>%
  summarise(ultimo_mes = max(data_mes, na.rm = TRUE)) %>%
  pull(ultimo_mes)

# Função para criar gráfico
create_chart <- function(mes) {
  dados <- get_data(as.Date(paste0(mes, "-01")))
  
  highchart() %>%
    hc_chart(type = "bar") %>%
    hc_title(text = "") %>%
    hc_subtitle(text = paste("Dados para:", mes)) %>%
    hc_xAxis(
      categories = dados$sigla_uf,
      labels = list(
        style = list(
          fontSize = "9px"  # Define o tamanho da fonte das labels do eixo X
        )
      )
    ) %>%
    hc_yAxis(title = list(text = "")) %>%
    hc_add_series(name = "", data = dados$saldo_somado)
}

ui <- dashboardPage(
  dashboardHeader(
    title = tags$div(
      tags$strong("Mercado de Trabalho Portuário", class = "title-text"),
      style = "text-align: center; padding-right: 20px;"
    ),
    titleWidth = NULL
  ),
  dashboardSidebar(
    tags$div(
      tags$img(src = "img/logo.png", height = "50px", width = "200px"),  
      style = "text-align: center; padding: 10px;"
    ),
    sidebarMenu(
      menuItem("Movimentações e saldos", tabName = "evolucao", icon = icon("line-chart")),
      menuItem("Salário e ocupações", tabName = "distribuicao", icon = icon("bar-chart")),
      selectInput("uf_selecionada", "Selecione a UF:",
                  choices = unique(df_tres$sigla_uf), 
                  selected = "MA")  # "MA" é o valor selecionado por padrão
    ),
    
    # Adicionando a caixa de texto
    tags$div(
      "O painel tem como finalidade apresentar os dados oficiais do mercado de trabalho no setor portuário, apresentado informações que possam apoiar o processo decisório.

Para uma melhor experiência, abra o painel no seu computador.",
      style = "
      
        color: #ffffff;              /* Cor do texto */
        background-color: #00000000; /* Fundo transparente */
        padding: 10px;               /* Espaçamento interno */
        white-space: pre-wrap;       /* Habilitar quebra de linha */
        font-size: 14px;             /* Tamanho da fonte */
        text-align: justify;         /* Justifica o texto */
      "
    ),
    # Adicionando as imagens
    tags$div(
      tags$h4("Realização", style = "text-align: center;"),  # Título da imagem
      tags$img(src = "img/labportos.jpeg", height = "80px"),  # Ajuste o caminho da imagem
      style = "text-align: center; padding-bottom: 10px;"
    ),
    
    tags$div(
      tags$h4("Financiamento", style = "text-align: center;"),  # Título da imagem
      tags$img(src = "img/logo_itaqui.jpeg", height = "80px"),  # Ajuste o caminho da imagem
      style = "text-align: center; padding-bottom: 10px;"
    )
  ),
  dashboardBody(
    # Adicionando o título da aba do navegador
    tags$head(
      tags$title("Mercado de Trabalho Portuário")
    ),
    tabItems(
      # Primeira Aba: Gráfico de Linhas, Gráfico de Barras, Mapa, Título e ValueBoxes
      tabItem(tabName = "evolucao",
              fluidRow(
                tags$h3(paste("Movimentações do emprego formal em", mes_em_portugues(mes_selecionado)), 
                    style = "text-align: center; margin-bottom: 20px;")
              ),
              fluidRow(
                valueBoxOutput("saldoPaisBox"),
                valueBoxOutput("saldoVariacaoBox"),
                valueBoxOutput("saldoVariacaoTrimestralBox")
              ),
              fluidRow(
                box(title = "Evolução das movimentações de emprego no estado", width = 12, highchartOutput("lineplot"), 
                    solidHeader = TRUE,
                    status = "primary")
              ),
              fluidRow(
                column(2,
                       box(width = NULL,
                           selectInput("mes_selecionado", "Selecione o mês:", 
                                       choices = format(seq.Date(from = min(df_resumo$data_mes), 
                                                                 to = max(df_resumo$data_mes), 
                                                                 by = "month"), "%Y-%m"),
                                       selected = format(max(df_resumo$data_mes), "%Y-%m")))
                ),
                column(5, 
                       box(title = "Saldo por Unidade Federativa", width = NULL, highchartOutput("barchart"), 
                           solidHeader = TRUE,
                           status = "primary")
                ),
                column(5, 
                       box(title = "Mapa do saldo de empregos", width = NULL, highchartOutput("mapa"),
                           solidHeader = TRUE,
                           status = "primary")
                )
              ),
              # Novo fluidRow para os gráficos de sexo lado a lado
              fluidRow(
                column(6,
                       box(title = "Movimentação de vínculos por sexo no MA", width = NULL, 
                           solidHeader = TRUE,
                           status = "primary",
                           plotOutput("grafico_movimentacao_sexo_ma", height = "400px")
                       )
                ),
                column(6,
                       box(title = "Movimentação de vínculos por sexo no Brasil", width = NULL, 
                           solidHeader = TRUE,
                           status = "primary",
                           plotOutput("grafico_movimentacao_sexo_br", height = "400px")
                       )
                )
              ),
              # Novo fluidRow para o gráfico de movimentação por região
              fluidRow(
                column(12,
                       box(title = "Movimentação de vínculos por região", width = NULL, 
                           solidHeader = TRUE,
                           status = "primary",
                           plotOutput("grafico_movimentacao_regiao", height = "400px")
                       )
                )
              ),
              # Novo fluidRow para o gráfico de movimentações por grau de escolaridade
              fluidRow(
                column(12,
                       box(title = "Movimentações por grau de escolaridade no país", width = NULL, 
                           solidHeader = TRUE,
                           status = "primary",
                           plotOutput("grafico_movimentacao_escolaridade", height = "400px")
                       )
                )
              ),
              # Novo fluidRow para o gráfico de movimentações por grau de escolaridade no Maranhão
              fluidRow(
                column(12,
                       box(title = "Movimentações por grau de escolaridade no Maranhão", width = NULL, 
                           solidHeader = TRUE,
                           status = "primary",
                           plotOutput("grafico_movimentacao_escolaridade_ma", height = "400px")
                       )
                )
              )
      ),
      # Segunda Aba: Tabelas Interativas
      tabItem(tabName = "distribuicao",
              fluidRow(
                valueBoxOutput("outroBox1"),
                valueBoxOutput("outroBox2")
              ),
              # Primeiro boxplot:
              fluidRow(
                box(title = "Mediana Salarial por estado",
                    solidHeader = TRUE,
                    status = "primary",
                    width = 12, plotOutput("boxplot_salario_uf")) 
              ),
              # Segundo boxplot:
              fluidRow(
                box(title = "Mediana salarial por região", 
                    solidHeader = TRUE,
                    status = "primary",
                    width = 12, plotOutput("boxplot_salario_regiao")) 
              ),
              # Tabelas:
              fluidRow(
                box(title = "Estados com maior saldo por ocupação (CBO)",
                    solidHeader = TRUE,
                    status = "primary",
                    width = 6, DTOutput("tabela_interativa_cbo")),
                box(title = "Estados com maior saldo por atividade Econômica (CNAE Subclasse)",
                    solidHeader = TRUE,
                    status = "primary",
                    width = 6, DTOutput("tabela_interativa_cnae"))
              ),
              # Novo fluidRow para os gráficos de saldo positivo e negativo, lado a lado
              fluidRow(
                column(6,
                       box(title = "10 ocupações com saldo positivo no mês no Maranhão", width = NULL, 
                           solidHeader = TRUE,
                           status = "primary",
                           plotOutput("grafico_saldo_positivo_ma", height = "400px")
                       )
                ),
                column(6,
                       box(title = "10 ocupações com saldo negativo no mês no Maranhão", width = NULL, 
                           solidHeader = TRUE,
                           status = "primary",
                           plotOutput("grafico_saldo_negativo_ma", height = "400px")
                       )
                )
              )
      )
    )
  ),
  
  skin = "blue"
)

# --- Lógica do Servidor ---
server <- function(input, output) {
  
  # Renderização do gráfico de saldo_movimentacao por regiao
  output$grafico_movimentacao_regiao <- renderPlot({
    ultimo_dado %>%
      group_by(regiao) %>%
      count(saldo_movimentacao) %>% 
      ggplot(aes(x = regiao, y = n, fill = saldo_movimentacao)) +
      geom_bar(stat = "identity") +
      geom_text(aes(label = n), 
                position = position_stack(vjust = 0.5), # Posição no centro da barra
                size = 5, # Tamanho do texto
                color = "black")+
      labs(
        title = "",
        x = "",
        y = "",
        fill = "" # Mantém os rótulos de título e eixos vazios
      ) +
      scale_fill_manual(
        values = c("Admitidos" = "#87CEFA", "Desligados" = "#FF6347") # Cores personalizadas
      ) +
      theme_minimal() + # Estilo de tema minimalista
      theme(text = element_text(size = 12), # Tamanho do texto geral
        axis.text.x = element_text(size = 12), # Tamanho do texto do eixo X
        axis.text.y = element_text(size = 12), # Tamanho do texto do eixo Y
        legend.position = "bottom" # Posiciona a legenda na parte inferior do gráfico
  )
    })
  
  # Renderização do gráfico de saldo_movimentacao por sexo no Brasil
  output$grafico_movimentacao_sexo_br <- renderPlot({
    ultimo_dado %>%
      group_by(sexo) %>%
      count(saldo_movimentacao) %>% 
      ggplot(aes(x = sexo, y = n, fill = saldo_movimentacao)) +
      geom_bar(stat = "identity") +
      geom_text(aes(label = n), 
                position = position_stack(vjust = 0.5), # Posição no centro da barra
                size = 5, # Tamanho do texto
                color = "black") + # Cor do texto
      labs(
        title = "",
        x = "",
        y = "",
        fill = "" # Mantém os rótulos de título e eixos vazios
      ) +
      scale_fill_manual(
        values = c("Admitidos" = "#87CEFA", "Desligados" = "#FF6347") # Cores personalizadas
      ) +
      theme_minimal() + # Estilo de tema minimalista
      theme(text = element_text(size = 12), # Tamanho do texto geral
            axis.text.x = element_text(size = 12), # Tamanho do texto do eixo X
            axis.text.y = element_text(size = 12), # Tamanho do texto do eixo Y
            legend.position = "bottom" # Posiciona a legenda na parte inferior do gráfico
      )
  })
  # Renderização do gráfico de movimentações por grau de escolaridade no país
  output$grafico_movimentacao_escolaridade <- renderPlot({
    ultimo_dado %>%
      group_by(grau_instrucao) %>%
      count(saldo_movimentacao) %>% 
      ggplot(aes(x = grau_instrucao, y = n, fill = saldo_movimentacao)) +
      geom_bar(stat = "identity", position = position_dodge(width = 0.8)) + # Barras lado a lado
      coord_flip() + # Inverte os eixos para melhor visualização
      geom_text(aes(label = n), 
                position = position_dodge(width = 0.8), # Ajusta a posição do texto para barras lado a lado
                vjust = 0.5, # Ajusta a posição vertical do texto
                hjust = -0.5,
                size = 5, # Tamanho do texto
                color = "black") + # Cor do texto
      labs(
        title = "",
        x = "",
        y = "",
        fill = "" # Mantém os rótulos de título e eixos vazios
      ) +
      scale_fill_manual(
        values = c("Admitidos" = "#87CEFA", "Desligados" = "#FF6347") # Cores personalizadas
      ) +
      theme_minimal() + # Estilo de tema minimalista
      theme(text = element_text(size = 12), # Tamanho do texto geral
            axis.text.x = element_text(size = 12), # Tamanho do texto do eixo X
            axis.text.y = element_text(size = 12), # Tamanho do texto do eixo Y
            legend.position = "bottom" # Posiciona a legenda na parte inferior do gráfico
      )
  })
  
  # Renderização do gráfico de movimentações por grau de escolaridade no Maranhão
  output$grafico_movimentacao_escolaridade_ma <- renderPlot({
    ultimo_dado %>%
      filter(sigla_uf == "MA") %>%
      group_by(grau_instrucao) %>%
      count(saldo_movimentacao) %>%
      ggplot(aes(x = grau_instrucao, y = n, fill = saldo_movimentacao)) +
      geom_bar(stat = "identity") +
      coord_flip() + 
      geom_text(aes(label = n), 
                position = position_stack(vjust = 0.5), # Posição no centro da barra
                size = 5, # Tamanho do texto
                color = "black") + # Cor do texto
      labs(
        title = "",
        x = "",
        y = "",
        fill = "" # Mantém os rótulos de título e eixos vazios
      ) +
      scale_fill_manual(
        values = c("Admitidos" = "#87CEFA", "Desligados" = "#FF6347") # Cores personalizadas
      ) +
      theme_minimal() + # Estilo de tema minimalista
      theme(text = element_text(size = 12), # Tamanho do texto geral
            axis.text.x = element_text(size = 12), # Tamanho do texto do eixo X
            axis.text.y = element_text(size = 12), # Tamanho do texto do eixo Y
            legend.position = "bottom" # Posiciona a legenda na parte inferior do gráfico
      )
  })
  # Renderização do gráfico de saldo positivo no Maranhão
  output$grafico_saldo_positivo_ma <- renderPlot({
    top_10_cbo <- ultimo_dado %>%
      filter(sigla_uf == "MA") %>%
      group_by(cbo_2002, saldo_movimentacao) %>%
      summarise(contagem = n(), .groups = 'drop') %>%
      spread(key = saldo_movimentacao, value = contagem, fill = 0) %>%
      mutate(saldo = Admitidos - Desligados) %>%
      ungroup() %>%
      arrange(desc(saldo)) %>%
      slice(1:10)
    
    top_10_plot_data <- ultimo_dado %>%
      filter(cbo_2002 %in% top_10_cbo$cbo_2002) %>%
      group_by(cbo_2002) %>%
      count(saldo_movimentacao)
    
    ggplot(top_10_plot_data, aes(x = reorder(cbo_2002, n), y = n, fill = saldo_movimentacao)) +
      geom_bar(stat = "identity", position = position_dodge(width = 0.8)) + 
      coord_flip() + 
      geom_text(aes(label = n), 
                position = position_dodge(width = 0.8), 
                vjust = 0.5, 
                size = 5, 
                color = "black") + 
      theme_minimal()+ 
      labs(
        title = "",
        x = "",
        y = "",
        fill = "" # Mantém os rótulos de título e eixos vazios
      ) +
      scale_fill_manual(
        values = c("Admitidos" = "#87CEFA", "Desligados" = "#FF6347") # Cores personalizadas
      ) +
      theme_minimal() + # Estilo de tema minimalista
      theme(text = element_text(size = 12), # Tamanho do texto geral
            axis.text.x = element_text(size = 12), # Tamanho do texto do eixo X
            axis.text.y = element_text(size = 12), # Tamanho do texto do eixo Y
            legend.position = "bottom" # Posiciona a legenda na parte inferior do gráfico
      )
  })
  
  # Renderização do gráfico de saldo negativo no Maranhão
  output$grafico_saldo_negativo_ma <- renderPlot({
    bottom_10_cbo <- ultimo_dado %>%
      filter(sigla_uf == "MA") %>%
      group_by(cbo_2002, saldo_movimentacao) %>%
      summarise(contagem = n(), .groups = 'drop') %>%
      spread(key = saldo_movimentacao, value = contagem, fill = 0) %>%
      mutate(saldo = Admitidos - Desligados) %>%
      ungroup() %>%
      arrange(saldo) %>%
      slice(1:10)
    
    bottom_10_plot_data <- ultimo_dado %>%
      filter(cbo_2002 %in% bottom_10_cbo$cbo_2002) %>%
      group_by(cbo_2002) %>%
      count(saldo_movimentacao)
    
    ggplot(bottom_10_plot_data, aes(x = reorder(cbo_2002, n), y = n, fill = saldo_movimentacao)) +
      geom_bar(stat = "identity", position = position_dodge(width = 0.8)) + 
      coord_flip() + 
      geom_text(aes(label = n), 
                position = position_dodge(width = 0.8), 
                vjust = 0.5, 
                size = 5, 
                color = "black")+
      labs(
        title = "",
        x = "",
        y = "",
        fill = "" # Mantém os rótulos de título e eixos vazios
      ) +
      scale_fill_manual(
        values = c("Admitidos" = "#87CEFA", "Desligados" = "#FF6347") # Cores personalizadas
      ) +
      theme_minimal() + # Estilo de tema minimalista
      theme(text = element_text(size = 12), # Tamanho do texto geral
            axis.text.x = element_text(size = 12), # Tamanho do texto do eixo X
            axis.text.y = element_text(size = 12), # Tamanho do texto do eixo Y
            legend.position = "bottom" # Posiciona a legenda na parte inferior do gráfico
      )
  })
  
  output$saldoPaisBox <- renderValueBox({
    saldo_uf <- df_variacao %>%
      filter(sigla_uf == input$uf_selecionada & data_mes == max(data_mes)) %>%
      pull(saldo_somado)
    
    valueBox(
      value = saldo_uf, 
      subtitle = paste("Saldo em", input$uf_selecionada), 
      icon = icon("chart-line"),
      color = "blue"
    )
  })
  
  output$saldoVariacaoBox <- renderValueBox({
    variacao_anual <- df_variacao %>%
      filter(sigla_uf == input$uf_selecionada & data_mes == max(data_mes)) %>%
      summarise(total_variacao = sum(percentual_variacao, na.rm = TRUE))
    
    valueBox(
      value = paste0(variacao_anual$total_variacao, "%"), 
      subtitle = paste("Variação Anual",input$uf_selecionada),
      icon = icon("chart-line"),
      color = "purple"
    )
  })
  
  output$saldoVariacaoTrimestralBox <- renderValueBox({
    variacao_trimestral <- df_variacao %>%
      filter(sigla_uf == input$uf_selecionada & data_mes == max(data_mes)) %>%
      summarise(total_variacao = sum(variacao_trimestral, na.rm = TRUE)) %>%
      pull(total_variacao)
    
    valueBox(
      value = paste0(variacao_trimestral, "%"), 
      subtitle = paste("Variação Trimestral", input$uf_selecionada),
      icon = icon("chart-bar"),
      color = "green"
    )
  })
  
  dados_filtrados_barplot <- reactive({
    ultimo_dado %>%
      filter(sigla_uf == input$uf_selecionada) %>%
      select(sigla_uf, saldo_movimentacao, sexo, indicador_trabalho_parcial, indicador_trabalho_intermitente)
  })
  
  dados_filtrados_lineplot <- reactive({
    df_tres %>%
      filter(sigla_uf == input$uf_selecionada)
  })
  
  dados_salario_uf <- reactive({
    ultimo_dado %>%
      filter(sigla_uf == input$uf_selecionada)
  })
  
  tabela_cruzada <- reactive({
    variavel <- "saldo_movimentacao"
    
    criar_crosstable_generalizado(dados_filtrados_barplot(), variavel, "sexo")
  })
  
  # Renderização do gráfico de saldo por sexo no MA
  output$grafico_movimentacao_sexo_ma <- renderPlot({
    ultimo_dado %>%
      filter(sigla_uf == "MA") %>%
      group_by(sexo) %>%
      count(saldo_movimentacao) %>%
      ggplot(aes(x = sexo, y = n, fill = saldo_movimentacao)) +
      geom_bar(stat = "identity") +
      geom_text(aes(label = n), 
                position = position_stack(vjust = 0.5), # Posição no centro da barra
                size = 5, # Tamanho do texto da legenda
                color = "black") + # Cor do texto
      labs(
        title = "",
        x = "",
        y = "",
        fill = "" # Mantém os rótulos de título e eixos vazios
      ) +
      scale_fill_manual(
        values = c("Admitidos" = "#87CEFA", "Desligados" = "#FF6347") # Cores personalizadas
      ) +
      theme_minimal() + # Estilo de tema minimalista
      theme(text = element_text(size = 12), # Tamanho do texto geral
            axis.text.x = element_text(size = 12), # Tamanho do texto do eixo X
            axis.text.y = element_text(size = 12), # Tamanho do texto do eixo Y
            legend.position = "bottom" # Posiciona a legenda na parte inferior do gráfico
      )
  })
  output$lineplot <- renderHighchart({
    df_tres <- dados_filtrados_lineplot()
    
    dados_ma_agrupado_2 <- df_tres %>%
      group_by(data, saldo_movimentacao) %>%
      summarise(contagem = n(), .groups = 'drop') %>%
      pivot_wider(names_from = saldo_movimentacao, values_from = contagem, values_fill = list(contagem = 0)) %>%
      mutate(saldo = coalesce(Admitidos, 0) - coalesce(Desligados, 0))
    
    highchart() %>%
      hc_title(text = paste("Evolução Mensal de Admitidos, Desligados e Saldo em", input$uf_selecionada)) %>%
      hc_xAxis(type = "datetime", title = list(text = "Mês/Ano")) %>%
      hc_yAxis(title = list(text = "Quantidade")) %>%
      
      hc_add_series(data = dados_ma_agrupado_2, type = "line", 
                    hcaes(x = data, y = Admitidos), name = "Admitidos", 
                    color = "#73BCD9", lineWidth = 2) %>%
      
      hc_add_series(data = dados_ma_agrupado_2, type = "line", 
                    hcaes(x = data, y = Desligados), name = "Desligados", 
                    color = "#ff7f0e", lineWidth = 2) %>%
      
      hc_add_series(data = dados_ma_agrupado_2, type = "line", 
                    hcaes(x = data, y = saldo), name = "Saldo", 
                    color = "#2ca02c", dashStyle = "Dash", lineWidth = 2) %>%
      
      hc_tooltip(shared = TRUE, crosshairs = TRUE, 
                 pointFormat = "<b>{series.name}: {point.y}</b><br/>") %>%
      
      hc_legend(title = list(text = "Tipo de Movimentação")) %>%
      hc_chart(zoomType = "x") %>%
      hc_exporting(enabled = TRUE)
  })
  
  output$barchart <- renderHighchart({
    mes_selecionado <- input$mes_selecionado
    create_chart(mes_selecionado)
  })
  
  output$mapa <- renderHighchart({
    dados_estados <- get_data_mapa(as.Date(paste0(input$mes_selecionado, "-01")))
    
    n_cores <- 9  
    paleta_cores <- colorRampPalette(brewer.pal(n_cores, "Blues"))(10)
    
    valor_min <- min(dados_estados$saldo_somado, na.rm = TRUE)
    valor_max <- max(dados_estados$saldo_somado, na.rm = TRUE)
    
    highchart(type = "map") %>%
      hc_add_series_map(br_map, dados_estados, value = "saldo_somado", joinBy = c("hc-a2", "sigla_uf")) %>%
      hc_subtitle(text = paste("Dados para:", input$mes_selecionado)) %>%
      hc_colorAxis(
        min = valor_min,
        max = valor_max,
        type = "linear",
        stops = color_stops(n = 100, colors = paleta_cores),
        lineColor = "#FFFFFF",
        minColor = "#A2E4F2",
        maxColor = "#0D0D0D"
      ) %>%
      hc_legend(
        enabled = TRUE,
        layout = "vertical",
        align = "right",
        verticalAlign = "middle"
      ) %>%
      hc_mapNavigation(enabled = TRUE) %>%
      hc_tooltip(
        formatter = JS("function() {
          return '<b>' + this.point.name + '</b><br>' +
                 'Saldo: ' + Highcharts.numberFormat(this.point.value, 0);
        }")
      )
  })
  
  output$tabela_interativa_cbo <- renderDT({
    tabela_top10_cbo <- ultimo_dado %>%
      group_by(sigla_uf, cbo_2002) %>%
      summarise(
        admitidos = sum(saldo_movimentacao == "Admitidos"),
        desligados = sum(saldo_movimentacao == "Desligados"),
        saldo = admitidos - desligados) %>%
      arrange(desc(saldo)) %>%
      top_n(10, saldo)
    
    datatable(tabela_top10_cbo, options = list(pageLength = 10, autoWidth = TRUE), 
              colnames = c("UF", "Ocupação", "Admitidos", "Desligados", "Saldo"))
  })
  
  output$tabela_interativa_cnae <- renderDT({
    tabela_top10_cnae <- ultimo_dado %>%
      group_by(sigla_uf, cnae_2_subclasse) %>%
      summarise(
        admitidos = sum(saldo_movimentacao == "Admitidos"),
        desligados = sum(saldo_movimentacao == "Desligados"),
        saldo = admitidos - desligados) %>%
      arrange(desc(saldo)) %>%
      top_n(10, saldo)
    
    datatable(tabela_top10_cnae, options = list(pageLength = 10, autoWidth = TRUE), 
              colnames = c("UF", "Atividade Econômica", "Admitidos", "Desligados", "Saldo"))
  })
  
  output$boxplot_salario_uf <- renderPlot({
    dados <- dados_salario_uf()
    
    # Cálculos estatísticos
    quartis <- quantile(dados$salario_mensal, probs = c(0.25, 0.75), na.rm = TRUE)
    IQR <- quartis[2] - quartis[1]
    limite_inferior <- quartis[1] - 1.5 * IQR
    limite_superior <- quartis[2] + 1.5 * IQR
    
    # Filtragem dos dados
    dados_sem_outliers_extremos_UF <- dados %>%
      filter(salario_mensal >= limite_inferior & salario_mensal <= limite_superior) %>%
      na.omit()
    
    # Cálculo das medianas
    medianas <- dados_sem_outliers_extremos_UF %>%
      group_by(regiao, saldo_movimentacao) %>%
      summarise(mediana_salario = median(salario_mensal, na.rm = TRUE))
    
    # Criação do gráfico
    ggplot(dados_sem_outliers_extremos_UF, aes(x = saldo_movimentacao, y = salario_mensal, fill = regiao)) +
      geom_boxplot() +
      geom_text(
        data = medianas,
        aes(
          label = format(mediana_salario, digits = 2, big.mark = ".", decimal.mark = ","),
          y = mediana_salario
        ),
        position = position_dodge(width = 0.75),
        vjust = -2.5,
        color = "black",
        size = 5
      ) +
      labs(
        title = paste("Mediana do salário mensal em", input$uf_selecionada),
        x = "",
        y = "Mediana do salário mensal (R$)"
      ) +
      theme_minimal() +
      theme(
        axis.text.x = element_text(angle = 1, hjust = 0.5, size = 12),
        legend.position = "none",
        axis.text.y = element_text(size = 12), # Tamanho do texto do eixo Y
        
      )
  })
  
 
    output$boxplot_salario_regiao <- renderPlot({
    salario_regiao <- ultimo_dado
    
    quartis <- quantile(salario_regiao$salario_mensal, probs = c(0.25, 0.75), na.rm = TRUE)
    IQR <- quartis[2] - quartis[1]
    
    limite_inferior <- quartis[1] - 1.5 * IQR
    limite_superior <- quartis[2] + 1.5 * IQR
    
    dados_sem_outliers_extremos_regiao <- salario_regiao %>%
      filter(salario_mensal >= limite_inferior & salario_mensal <= limite_superior)
    
    dados_sem_outliers_extremos_regiao <- na.omit(dados_sem_outliers_extremos_regiao)
    
    medianas <- dados_sem_outliers_extremos_regiao %>%
      group_by(regiao, saldo_movimentacao) %>%
      summarise(mediana_salario = median(salario_mensal, na.rm = TRUE))
    
    ggplot(dados_sem_outliers_extremos_regiao, aes(x = saldo_movimentacao, y = salario_mensal, fill = regiao)) +
      geom_boxplot() +
      geom_text(data = medianas, aes(label = format(mediana_salario, digits = 2, big.mark = ".", decimal.mark = ","), y = mediana_salario),
                position = position_dodge(width = 0.75),
                vjust = -2.5,
                color = "black",
                size = 5) +
      facet_wrap(~regiao, scales = "free_x") +
      labs(title = "",
           x = "",
           y = "Mediana do salário mensal (R$)") +
      theme_minimal() +
      theme(
        axis.text.y = element_text(size = 12), # Tamanho do texto do eixo Y
        axis.text.x = element_text(angle = 1, hjust = 0.5, size = 12),
            legend.position = "none")
  })
}

# Executa o aplicativo Shiny
shinyApp(ui = ui, server = server)
