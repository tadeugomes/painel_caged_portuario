# Definir repositório rápido (Posit Public CRAN)
options(repos = c(CRAN = "https://packagemanager.posit.co/cran/latest"))

# Evita erros de codificação em ambientes Linux/macOS
options(encoding = "UTF-8")

# Desativa uso automático do renv (caso tenha sido ativado antes)
if ("renv" %in% .packages(all.available = TRUE)) {
  if (renv::project() == getwd()) {
    tryCatch(
      renv::deactivate(),
      error = function(e) message("renv já está desativado.")
    )
  }
}

# Carrega rsconnect automaticamente se estiver disponível
if ("rsconnect" %in% rownames(installed.packages())) {
  suppressPackageStartupMessages(library(rsconnect))
}
