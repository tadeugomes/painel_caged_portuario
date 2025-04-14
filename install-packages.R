# Script to install shiny and tidyverse packages and save to renv

# Load renv
library(renv)

# Check if shiny is installed, if not install it
if (!requireNamespace("shiny", quietly = TRUE)) {
  cat("Installing shiny package...\n")
  install.packages("shiny")
} else {
  cat("shiny package is already installed.\n")
}

# Check if tidyverse is installed, if not install it
if (!requireNamespace("tidyverse", quietly = TRUE)) {
  cat("Installing tidyverse package...\n")
  install.packages("tidyverse")
} else {
  cat("tidyverse package is already installed.\n")
}

# Save the updated package state to renv
renv::snapshot(confirm = FALSE)

# Print a message indicating completion
cat("shiny and tidyverse packages have been verified and saved to renv.\n")
