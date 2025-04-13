#!/usr/bin/env Rscript

# Script para atualizar os dados do CAGED a partir do GitHub Actions
# Este script é chamado pelo workflow do GitHub Actions

# Função para verificar se um pacote está instalado e instalá-lo se necessário
check_and_install <- function(package_name) {
  if (!requireNamespace(package_name, quietly = TRUE)) {
    cat(paste0("Instalando pacote: ", package_name, "\n"))
    install.packages(package_name)
  }
  library(package_name, character.only = TRUE)
}

# Verificar e instalar pacotes necessários
required_packages <- c("basedosdados", "dplyr", "tidyr", "ggplot2", "readr", "purrr", "tibble", "stringr", "forcats", "lubridate")
for (pkg in required_packages) {
  check_and_install(pkg)
}

# Carregar os pacotes necessários
library(dplyr)
library(tidyr)
library(lubridate)
library(basedosdados)

# Função para atualizar os dados
update_data <- function() {
  cat("Iniciando a atualização dos dados do CAGED a partir do GitHub Actions...\n")
  
  # Verificar se a variável de ambiente está definida
  credentials_path <- Sys.getenv("GOOGLE_APPLICATION_CREDENTIALS")
  if (credentials_path == "") {
    stop("Variável de ambiente GOOGLE_APPLICATION_CREDENTIALS não definida")
  }
  
  # Verificar se o arquivo de credenciais existe
  if (!file.exists(credentials_path)) {
    stop(paste0("Arquivo de credenciais do Google Cloud não encontrado: ", credentials_path))
  }
  
  cat(paste0("✓ Usando arquivo de credenciais: ", credentials_path, "\n"))
  
  # Executar o script de atualização de dados
  cat("Executando o script caged-baixar-dados.R...\n")
  source("caged-baixar-dados.R")
  
  # Verificar se os dados foram atualizados
  if (!file.exists("data/df.rds")) {
    stop("Arquivo de dados não foi criado corretamente")
  }
  
  # Obter informações sobre o arquivo de dados
  file_info <- file.info("data/df.rds")
  file_size <- file.size("data/df.rds") / (1024 * 1024) # em MB
  
  cat(paste0("✓ Dados atualizados com sucesso!\n"))
  cat(paste0("  - Tamanho do arquivo: ", round(file_size, 2), " MB\n"))
  cat(paste0("  - Data de modificação: ", format(file_info$mtime, "%Y-%m-%d %H:%M:%S"), "\n"))
  
  return(TRUE)
}

# Executar a atualização de dados
cat("=== Atualização de Dados do CAGED (GitHub Actions) ===\n\n")
success <- tryCatch({
  update_data()
}, error = function(e) {
  cat(paste0("✗ Erro ao atualizar os dados: ", e$message, "\n"))
  # Retornar código de erro para o GitHub Actions
  quit(status = 1)
})

cat("\n=== Resumo ===\n")
cat(paste0("Atualização de Dados: ", ifelse(success, "✓ OK", "✗ Falha"), "\n"))

if (success) {
  cat("\n✓ Os dados foram atualizados com sucesso!\n")
  # Retornar código de sucesso para o GitHub Actions
  quit(status = 0)
} else {
  cat("\n✗ Houve um problema durante a atualização dos dados.\n")
  cat("  Verifique as mensagens de erro acima e corrija os problemas antes de tentar novamente.\n")
  # Retornar código de erro para o GitHub Actions
  quit(status = 1)
}
