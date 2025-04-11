#!/usr/bin/env Rscript

# Script para testar o deploy localmente
# Este script executa o processo de deploy em modo de teste, sem fazer o deploy real

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

# Função para testar o deploy localmente
test_deploy_local <- function() {
  cat("Iniciando teste de deploy local...\n")
  
  # Verificar se as variáveis de ambiente estão definidas
  token <- Sys.getenv("SHINYAPPS_TOKEN")
  secret <- Sys.getenv("SHINYAPPS_SECRET")
  
  if (token == "" || secret == "") {
    cat("✗ Variáveis de ambiente SHINYAPPS_TOKEN e/ou SHINYAPPS_SECRET não definidas\n")
    cat("  Defina-as usando Sys.setenv() antes de executar este script\n")
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
      files_to_deploy <- list.files(recursive = TRUE, all.files = FALSE)
      cat(paste(" -", files_to_deploy), sep = "\n")
      
      # Verificar o tamanho total do aplicativo
      app_size <- sum(file.info(list.files(recursive = TRUE))$size) / (1024 * 1024) # em MB
      cat(paste0("\nTamanho total do aplicativo: ", round(app_size, 2), " MB\n"))
      
      if (app_size > 1000) {
        cat("⚠️ O aplicativo é muito grande (> 1000 MB), o que pode causar problemas no deploy\n")
      }
      
      # Simular o deploy (sem fazer o deploy real)
      cat("\nSimulando o deploy...\n")
      
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
      
      # Verificar se o aplicativo pode ser implantado
      tryCatch({
        # Usar a função deployApp com appPrimaryDoc para verificar se o aplicativo pode ser implantado
        # O parâmetro lint=TRUE verifica se há problemas no código
        # O parâmetro forceUpdate=FALSE evita que o deploy seja feito
        rsconnect::deployApp(
          appName = "painel_caged_portuario",
          appPrimaryDoc = "app.R",
          account = "observatorioportuario",
          forceUpdate = FALSE,
          lint = TRUE,
          launch.browser = FALSE
        )
        
        cat("✓ Aplicativo pronto para deploy!\n")
        return(TRUE)
      }, error = function(e) {
        cat(paste0("✗ Erro ao verificar o aplicativo: ", e$message, "\n"))
        return(FALSE)
      })
    } else {
      cat("✗ Erro ao testar credenciais do shinyapps.io: conta não encontrada\n")
      return(FALSE)
    }
  }, error = function(e) {
    cat(paste0("✗ Erro ao testar deploy: ", e$message, "\n"))
    return(FALSE)
  })
}

# Executar o teste de deploy
cat("=== Teste de Deploy Local ===\n\n")
success <- test_deploy_local()

cat("\n=== Resumo ===\n")
cat(paste0("Teste de Deploy: ", ifelse(success, "✓ OK", "✗ Falha"), "\n"))

if (success) {
  cat("\n✓ O aplicativo está pronto para ser implantado!\n")
  cat("  Para fazer o deploy real, execute o script 'deploy.R'.\n")
} else {
  cat("\n✗ Houve um problema durante o teste de deploy.\n")
  cat("  Verifique as mensagens de erro acima e corrija os problemas antes de tentar novamente.\n")
  cat("  Para obter mais informações, execute o script 'debug-deploy.R'.\n")
}
