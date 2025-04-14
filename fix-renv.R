# Script to ensure shiny and tidyverse are installed and saved in renv

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

# Create a snapshot with specific packages to ensure they're in the lockfile
cat("Creating renv snapshot with shiny and tidyverse...\n")
renv::snapshot(packages = c("shiny", "tidyverse"), confirm = FALSE)

# Print a message indicating completion
cat("Packages have been verified and saved to renv.\n")
