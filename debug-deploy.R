#!/usr/bin/env Rscript

# Script para depurar problemas de deploy para o shinyapps.io
# Este script fornece informações detalhadas sobre o ambiente e o processo de deploy

# Função para verificar se um pacote está instalado e instalá-lo se necessário
check_and_install <- function(package_name) {
  if (!requireNamespace(package_name, quietly = TRUE)) {
    cat(paste0("Instalando pacote: ", package_name, "\n"))
    install.packages(package_name)
  }
  library(package_name, character.only = TRUE)
}

# Verificar e instalar pacotes necessários
check_and_install("rsconnect")

# Função para imprimir informações do sistema
print_system_info <- function() {
  cat("=== Informações do Sistema ===\n")
  cat(paste0("R version: ", R.version.string, "\n"))
  cat(paste0("Platform: ", R.version$platform, "\n"))
  cat(paste0("OS: ", Sys.info()["sysname"], " ", Sys.info()["release"], "\n"))
  cat(paste0("Working directory: ", getwd(), "\n"))
  cat("\n")
}

# Função para listar os arquivos no diretório atual
print_files_info <- function() {
  cat("=== Arquivos no Diretório ===\n")
  files <- list.files(recursive = TRUE, all.files = TRUE)
  cat(paste(" -", files), sep = "\n")
  cat("\n")
}

# Função para verificar as credenciais do shinyapps.io
check_shinyapps_credentials <- function() {
  cat("=== Verificação de Credenciais do shinyapps.io ===\n")
  
  # Verificar se as variáveis de ambiente estão definidas
  token <- Sys.getenv("SHINYAPPS_TOKEN")
  secret <- Sys.getenv("SHINYAPPS_SECRET")
  
  if (token == "") {
    cat("✗ Variável de ambiente SHINYAPPS_TOKEN não definida\n")
  } else {
    cat("✓ Variável de ambiente SHINYAPPS_TOKEN definida\n")
    cat(paste0("   Comprimento do token: ", nchar(token), " caracteres\n"))
  }
  
  if (secret == "") {
    cat("✗ Variável de ambiente SHINYAPPS_SECRET não definida\n")
  } else {
    cat("✓ Variável de ambiente SHINYAPPS_SECRET definida\n")
    cat(paste0("   Comprimento do secret: ", nchar(secret), " caracteres\n"))
  }
  
  if (token != "" && secret != "") {
    tryCatch({
      # Configurar as credenciais do shinyapps.io
      rsconnect::setAccountInfo(
        name = "observatorioportuario",
        token = token,
        secret = secret
      )
      
      # Verificar se a conta está configurada corretamente
      accounts <- rsconnect::accounts()
      
      if (nrow(accounts) > 0 && any(accounts$name == "observatorioportuario")) {
        cat("✓ Credenciais do shinyapps.io configuradas corretamente!\n")
        cat("   Detalhes da conta:\n")
        print(accounts)
      } else {
        cat("✗ Erro ao configurar credenciais do shinyapps.io: conta não encontrada\n")
      }
    }, error = function(e) {
      cat(paste0("✗ Erro ao configurar credenciais do shinyapps.io: ", e$message, "\n"))
    })
  }
  
  cat("\n")
}

# Função para verificar as dependências do aplicativo
check_app_dependencies <- function() {
  cat("=== Verificação de Dependências do Aplicativo ===\n")
  
  # Lista de pacotes necessários para o aplicativo
  required_packages <- c("shiny", "shinydashboard", "tidyr", "tidyverse", "highcharter", 
                         "jsonlite", "RColorBrewer", "DT", "basedosdados", "rsconnect", "lubridate")
  
  # Verificar cada pacote
  for (pkg in required_packages) {
    if (requireNamespace(pkg, quietly = TRUE)) {
      pkg_version <- packageVersion(pkg)
      cat(paste0("✓ ", pkg, " (versão ", pkg_version, ") está instalado\n"))
    } else {
      cat(paste0("✗ ", pkg, " não está instalado\n"))
    }
  }
  
  cat("\n")
}

# Função para verificar a estrutura do aplicativo
check_app_structure <- function() {
  cat("=== Verificação da Estrutura do Aplicativo ===\n")
  
  # Verificar arquivos essenciais
  essential_files <- c("app.R", "caged-baixar-dados.R", "data/df.rds", "data/cbo2002.csv")
  
  for (file in essential_files) {
    if (file.exists(file)) {
      file_info <- file.info(file)
      cat(paste0("✓ ", file, " existe (", file.size(file), " bytes, modificado em ", 
                 format(file_info$mtime, "%Y-%m-%d %H:%M:%S"), ")\n"))
    } else {
      cat(paste0("✗ ", file, " não existe\n"))
    }
  }
  
  cat("\n")
}

# Função para simular o processo de deploy
simulate_deploy <- function() {
  cat("=== Simulação do Processo de Deploy ===\n")
  
  tryCatch({
    # Verificar se o aplicativo pode ser implantado
    app_dir <- getwd()
    cat(paste0("Verificando o diretório do aplicativo: ", app_dir, "\n"))
    
    # Verificar se o diretório contém um aplicativo Shiny válido
    if (!file.exists("app.R") && !file.exists("server.R") && !file.exists("ui.R")) {
      cat("✗ Nenhum arquivo de aplicativo Shiny válido encontrado (app.R, server.R, ui.R)\n")
    } else {
      cat("✓ Arquivos de aplicativo Shiny válidos encontrados\n")
      
      # Verificar se o aplicativo pode ser carregado
      tryCatch({
        # Tentar carregar o aplicativo (sem executá-lo)
        if (file.exists("app.R")) {
          env <- new.env()
          source("app.R", local = env)
          if (exists("ui", envir = env) && exists("server", envir = env)) {
            cat("✓ Aplicativo Shiny carregado com sucesso\n")
          } else {
            cat("✗ Aplicativo Shiny não define 'ui' e 'server' corretamente\n")
          }
        }
      }, error = function(e) {
        cat(paste0("✗ Erro ao carregar o aplicativo: ", e$message, "\n"))
      })
      
      # Verificar o tamanho total do aplicativo
      app_size <- sum(file.info(list.files(recursive = TRUE))$size) / (1024 * 1024) # em MB
      cat(paste0("Tamanho total do aplicativo: ", round(app_size, 2), " MB\n"))
      
      if (app_size > 1000) {
        cat("⚠️ O aplicativo é muito grande (> 1000 MB), o que pode causar problemas no deploy\n")
      }
    }
  }, error = function(e) {
    cat(paste0("✗ Erro durante a simulação de deploy: ", e$message, "\n"))
  })
  
  cat("\n")
}

# Executar todas as verificações
cat("=== Depuração de Deploy para shinyapps.io ===\n\n")

print_system_info()
check_shinyapps_credentials()
check_app_dependencies()
check_app_structure()
print_files_info()
simulate_deploy()

cat("=== Conclusão ===\n")
cat("Verifique as informações acima para identificar possíveis problemas no processo de deploy.\n")
cat("Se necessário, corrija os problemas identificados e tente novamente.\n")
