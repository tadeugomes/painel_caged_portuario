#!/usr/bin/env Rscript

# Script para fazer o deploy do aplicativo para o shinyapps.io a partir do GitHub Actions
# Este script é chamado pelo workflow do GitHub Actions

# Definir repositório CRAN antes de instalar pacotes
options(repos = c(CRAN = "https://cloud.r-project.org"))

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

# Função para fazer o deploy do aplicativo
deploy_app <- function() {
  cat("Iniciando o deploy para shinyapps.io a partir do GitHub Actions...\n")
  
  # Verificar se as variáveis de ambiente estão definidas
  token <- Sys.getenv("SHINYAPPS_TOKEN")
  secret <- Sys.getenv("SHINYAPPS_SECRET")
  
  if (token == "" || secret == "") {
    stop("Variáveis de ambiente SHINYAPPS_TOKEN e/ou SHINYAPPS_SECRET não definidas")
  }
  
  # Configurar as credenciais do shinyapps.io
  rsconnect::setAccountInfo(
    name = "observatorioportuario",
    token = token,
    secret = secret
  )
  
  # Verificar se a conta está configurada corretamente
  accounts <- rsconnect::accounts()
  
  if (nrow(accounts) == 0 || !any(accounts$name == "observatorioportuario")) {
    stop("Erro ao configurar credenciais do shinyapps.io: conta não encontrada")
  }
  
  cat("✓ Credenciais do shinyapps.io configuradas corretamente!\n")
  
  # Obter lista de todos os arquivos no diretório
  all_files <- list.files(recursive = TRUE, all.files = FALSE)
  
  # Filtrar arquivos para excluir a pasta data e credencial_google.json
  files_to_deploy <- all_files[!grepl("^data/|^credencial_google\\.json$", all_files)]
  
  # Listar os arquivos que serão incluídos no deploy
  cat("\nArquivos que serão incluídos no deploy:\n")
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
}

# Executar o deploy
cat("=== Deploy para shinyapps.io (GitHub Actions) ===\n\n")
success <- tryCatch({
  deploy_app()
}, error = function(e) {
  cat(paste0("✗ Erro ao fazer deploy para shinyapps.io: ", e$message, "\n"))
  # Retornar código de erro para o GitHub Actions
  quit(status = 1)
})

cat("\n=== Resumo ===\n")
cat(paste0("Deploy: ", ifelse(success, "✓ OK", "✗ Falha"), "\n"))

if (success) {
  cat("\n✓ O aplicativo foi implantado com sucesso!\n")
  # Retornar código de sucesso para o GitHub Actions
  quit(status = 0)
} else {
  cat("\n✗ Houve um problema durante o deploy.\n")
  cat("  Verifique as mensagens de erro acima e corrija os problemas antes de tentar novamente.\n")
  # Retornar código de erro para o GitHub Actions
  quit(status = 1)
}
