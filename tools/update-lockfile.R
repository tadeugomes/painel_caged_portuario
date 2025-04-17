# Actualiza MASS para a versão mais recente disponível no CRAN
renv::install("MASS")          # instala o release actual (ex.: 7.3‑64)
renv::snapshot(confirm = FALSE) # re‑grava o renv.lock
