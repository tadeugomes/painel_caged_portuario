source("renv/activate.R")
# Configurar mirror CRAN
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Habilitar o uso do renv
if (requireNamespace("renv", quietly = TRUE)) {
  Sys.setenv(RENV_CONFIG_AUTO_SNAPSHOT = "TRUE")
  Sys.setenv(RENV_CONFIG_AUTO_RESTORE = "TRUE")
}
