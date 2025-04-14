#!/usr/bin/env Rscript

# Script simplificado para fazer o deploy para shinyapps.io a partir do GitHub Actions
# Assume que o ambiente R (pacotes) já foi restaurado via renv pelo workflow

cat("=== Deploy para shinyapps.io (GitHub Actions) ===\n\n")

# Verificar e carregar rsconnect (deve ter sido instalado pelo renv::restore)
if (!requireNamespace("rsconnect", quietly = TRUE)) {
  stop("Erro crítico: Pacote 'rsconnect' não encontrado. Foi incluído no renv.lock e restaurado?")
}
library(rsconnect)

# Função para fazer o deploy do aplicativo
deploy_app <- function() {
  cat("Iniciando o deploy para shinyapps.io...\n")
  
  # Verificar se as variáveis de ambiente estão definidas
  token <- Sys.getenv("SHINYAPPS_TOKEN")
  secret <- Sys.getenv("SHINYAPPS_SECRET")
  
  if (token == "" || secret == "") {
    stop("Variáveis de ambiente SHINYAPPS_TOKEN e/ou SHINYAPPS_SECRET não definidas")
  }
  
  # Configurar as credenciais do shinyapps.io
  rsconnect::setAccountInfo(
    name = "observatorioportuario", # Confirme se este é o nome correto da sua conta
    token = token,
    secret = secret
  )
  
  # Verificar se a conta está configurada corretamente (Opcional, mas bom para debug)
  # accounts <- rsconnect::accounts()
  # if (nrow(accounts) == 0 || !any(accounts$name == "observatorioportuario")) {
  #   stop("Erro ao configurar credenciais do shinyapps.io: conta não encontrada")
  # }
  # cat("✓ Credenciais do shinyapps.io configuradas corretamente!\n")
  
  # Determinar arquivos para deploy (opcional - rsconnect geralmente detecta bem)
  # Se você precisar excluir especificamente a pasta 'data/' e o .json:
  # all_files <- list.files(recursive = TRUE, all.files = FALSE, no.. = TRUE)
  # files_to_deploy <- all_files[!grepl("^data/|^credencial_google\\.json$", all_files)]
  # app_files_arg <- files_to_deploy
  
  # Se puder confiar na detecção automática (exclui pastas como renv, .git, etc por padrão):
  app_files_arg <- NULL 
  
  # Listar os arquivos (se especificado manualmente)
  # if (!is.null(app_files_arg)) {
  #    cat("\nArquivos que serão incluídos no deploy (especificados manualmente):\n")
  #    cat(paste(" -", app_files_arg), sep = "\n")
  # } else {
  #    cat("\nUsando detecção automática de arquivos pelo rsconnect.\n")
  # }
  
  # Fazer o deploy do aplicativo
  cat("\nExecutando rsconnect::deployApp...\n")
  deployment <- rsconnect::deployApp(
    appName = "painel_caged_portuario", # Confirme se este nome está correto
    account = "observatorioportuario",
    forceUpdate = TRUE,
    launch.browser = FALSE,
    logLevel = "verbose", # Adiciona mais detalhes ao log do deploy
    appFiles = app_files_arg # Use NULL para detecção automática ou a lista filtrada
  )
  
  cat(paste0("✓ Deploy concluído! URL: ", deployment$url, "\n")) # Nota: deployApp não retorna URL diretamente
  # A URL geralmente é impressa no log pelo próprio rsconnect.
  return(TRUE)
}

# Executar o deploy com tryCatch
success <- tryCatch({
  deploy_app()
}, error = function(e) {
  cat(paste0("\n✗ Erro durante o deploy para shinyapps.io: ", e$message, "\n"))
  quit(status = 1) # Termina o script com erro para a Action falhar
})

# Resumo final (opcional)
# if (success) {
#   cat("\n✓ Processo de deploy finalizado com sucesso aparente.\n")
#   quit(status = 0)
# }

# Se chegou aqui e não saiu no tryCatch, algo pode estar errado, mas vamos assumir sucesso por enquanto
# O tryCatch já trata a falha. Se não houve erro, o script termina com status 0 (sucesso) por padrão.