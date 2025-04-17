# Actualiza MASS para a versão mais recente disponível no CRAN


renv::status()

install.packages("MASS", version = "7.3-64")   # instala último release compatível
renv::snapshot(confirm = FALSE)                # grava 7.3‑64 e o campo "Repository"

