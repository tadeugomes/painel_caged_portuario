#!/usr/bin/env Rscript

# Script para fazer o deploy do aplicativo para o shinyapps.io a partir do GitHub Actions
# Este script assume que o ambiente já foi restaurado via renv pelo workflow do GitHub Actions

cat("=== Executando script de preparação do ambiente ===\n")
prepare_result <- tryCatch({
  source("github-action-prepare.R")
  TRUE
}, error = function(e) {
  cat(paste0("Erro ao executar o script de preparação: ", e$message, "\n"))
  FALSE
})

if (!prepare_result) {
  cat("✗ A preparação do ambiente falhou. Abortando o deploy.\n")
  quit(status = 1)
}

# Carregar pacotes necessários (assumindo que já estão instalados via renv)
library(rsconnect)
library(shiny)
library(tidyverse)

# Função para fazer o deploy do aplicativo
deploy_app <- function() {
  cat("Iniciando o deploy para shinyapps.io...\n")
  
  # Verificar se as variáveis de ambiente estão definidas
  token <- Sys.getenv("SHINYAPPS_TOKEN")
  secret <- Sys.getenv("SHINYAPPS_SECRET")
  
  if (token == "" || secret == "") {
    cat("✗ Variáveis de ambiente SHINYAPPS_TOKEN e/ou SHINYAPPS_SECRET não definidas\n")
    cat("  Defina-as usando Sys.setenv() ou execute este script no GitHub Actions\n")
    return(FALSE)
  }
  
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
      
      # Listar os arquivos que serão incluídos no deploy
      cat("\nArquivos que serão incluídos no deploy:\n")
      all_files <- list.files(recursive = TRUE, all.files = FALSE)
      
      # Filtrar arquivos para excluir apenas a pasta data e arquivos de credenciais
      files_to_deploy <- all_files[!grepl("^data/|^credencial_google\\.json$|^gc-key\\.json$|^.*-auth\\.json$", all_files)]
      cat(paste(" -", files_to_deploy), sep = "\n")
      
      # Fazer o deploy do aplicativo
      cat("\nIniciando o deploy...\n")
      deployment <- rsconnect::deployApp(
        appName = "painel_caged_portuario",
        account = "observatorioportuario",
        forceUpdate = TRUE,
        launch.browser = FALSE,
        appFiles = files_to_deploy  # Especificar quais arquivos incluir
      )
      
      cat(paste0("✓ Deploy concluído com sucesso! URL: ", deployment$url, "\n"))
      return(TRUE)
    } else {
      cat("✗ Erro ao testar credenciais do shinyapps.io: conta não encontrada\n")
      return(FALSE)
    }
  }, error = function(e) {
    cat(paste0("✗ Erro ao fazer deploy para shinyapps.io: ", e$message, "\n"))
    return(FALSE)
  })
}

# Executar o deploy
cat("=== Deploy para shinyapps.io ===\n\n")
success <- deploy_app()

cat("\n=== Resumo ===\n")
cat(paste0("Deploy: ", ifelse(success, "✓ OK", "✗ Falha"), "\n"))

if (success) {
  cat("\n✓ O aplicativo foi implantado com sucesso!\n")
  quit(status = 0)
} else {
  cat("\n✗ Houve um problema durante o deploy.\n")
  cat("  Verifique as mensagens de erro acima e corrija os problemas antes de tentar novamente.\n")
  quit(status = 1)
}
