#!/usr/bin/env Rscript

# Script para fazer o deploy do aplicativo para o shinyapps.io
# Este script pode ser executado localmente ou pelo GitHub Actions

# Definir repositório CRAN antes de instalar pacotes
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Desabilitar o uso do renv (se possível)
Sys.setenv(RENV_CONFIG_AUTO_SNAPSHOT = "FALSE")
Sys.setenv(RENV_CONFIG_AUTO_RESTORE = "FALSE")

# Configurar renv para ignorar o tidyverse (se renv estiver disponível)
if (requireNamespace("renv", quietly = TRUE)) {
  options(renv.settings.ignored.packages = c("tidyverse"))
}

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
      
      # Filtrar arquivos para excluir a pasta data e credencial_google.json
      files_to_deploy <- all_files[!grepl("^data/|^credencial_google\\.json$", all_files)]
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
} else {
  cat("\n✗ Houve um problema durante o deploy.\n")
  cat("  Verifique as mensagens de erro acima e corrija os problemas antes de tentar novamente.\n")
}
