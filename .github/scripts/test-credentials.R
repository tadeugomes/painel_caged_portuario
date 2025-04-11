#!/usr/bin/env Rscript

# Script para testar as credenciais do Google Cloud e shinyapps.io a partir do GitHub Actions
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
check_and_install("basedosdados")
check_and_install("rsconnect")

# Função para testar as credenciais do Google Cloud
test_google_cloud <- function() {
  cat("Testando credenciais do Google Cloud...\n")
  
  # Verificar se o arquivo de credenciais existe
  if (!file.exists("google-credentials.json")) {
    cat("✗ Arquivo de credenciais do Google Cloud não encontrado\n")
    return(FALSE)
  }
  
  # Configurar as credenciais do Google Cloud
  Sys.setenv(GOOGLE_APPLICATION_CREDENTIALS = "google-credentials.json")
  
  tryCatch({
    # Tentar configurar o projeto no Google Cloud
    basedosdados::set_billing_id("observatorio-portuario")
    
    # Tentar executar uma consulta simples
    query <- "SELECT 1 as test"
    result <- basedosdados::read_sql(query)
    
    if (nrow(result) > 0) {
      cat("✓ Credenciais do Google Cloud configuradas corretamente!\n")
      return(TRUE)
    } else {
      cat("✗ Erro ao testar credenciais do Google Cloud: resultado vazio\n")
      return(FALSE)
    }
  }, error = function(e) {
    cat(paste0("✗ Erro ao testar credenciais do Google Cloud: ", e$message, "\n"))
    return(FALSE)
  })
}

# Função para testar as credenciais do shinyapps.io
test_shinyapps <- function() {
  cat("Testando credenciais do shinyapps.io...\n")
  
  # Verificar se as variáveis de ambiente estão definidas
  token <- Sys.getenv("SHINYAPPS_TOKEN")
  secret <- Sys.getenv("SHINYAPPS_SECRET")
  
  if (token == "" || secret == "") {
    cat("✗ Variáveis de ambiente SHINYAPPS_TOKEN e/ou SHINYAPPS_SECRET não definidas\n")
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
      cat("   Detalhes da conta:\n")
      print(accounts)
      return(TRUE)
    } else {
      cat("✗ Erro ao testar credenciais do shinyapps.io: conta não encontrada\n")
      return(FALSE)
    }
  }, error = function(e) {
    cat(paste0("✗ Erro ao testar credenciais do shinyapps.io: ", e$message, "\n"))
    return(FALSE)
  })
}

# Executar os testes
cat("=== Teste de Credenciais (GitHub Actions) ===\n\n")

gc_success <- test_google_cloud()
cat("\n")
shiny_success <- test_shinyapps()

cat("\n=== Resumo ===\n")
cat(paste0("Google Cloud: ", ifelse(gc_success, "✓ OK", "✗ Falha"), "\n"))
cat(paste0("shinyapps.io: ", ifelse(shiny_success, "✓ OK", "✗ Falha"), "\n"))

if (gc_success && shiny_success) {
  cat("\n✓ Todas as credenciais estão configuradas corretamente!\n")
  cat("  O workflow do GitHub Actions deve funcionar sem problemas.\n")
  # Retornar código de sucesso para o GitHub Actions
  quit(status = 0)
} else {
  cat("\n✗ Algumas credenciais não estão configuradas corretamente.\n")
  cat("  Verifique as mensagens de erro acima e corrija os problemas antes de executar o workflow.\n")
  # Retornar código de erro para o GitHub Actions
  quit(status = 1)
}
