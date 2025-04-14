source("renv/activate.R")
# Configurar mirror CRAN
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Desabilitar o uso do renv (se possível)
Sys.setenv(RENV_CONFIG_AUTO_SNAPSHOT = "FALSE")
Sys.setenv(RENV_CONFIG_AUTO_RESTORE = "FALSE")

# Ou configurar o renv para ignorar o tidyverse
if (requireNamespace("renv", quietly = TRUE)) {
  # Configurar renv para ignorar o tidyverse
  options(renv.settings.ignored.packages = c("tidyverse"))
}
