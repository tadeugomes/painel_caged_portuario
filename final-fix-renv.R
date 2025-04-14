# Script to ensure shiny and tidyverse are installed and saved in renv

# Load renv
library(renv)

# Initialize renv if needed
if (!file.exists("renv.lock") || length(renv::dependencies()) == 0) {
  cat("Initializing renv...\n")
  renv::init(force = TRUE)
}

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

# Create a snapshot with all packages
cat("Creating renv snapshot with all packages...\n")
renv::snapshot(type = "all", confirm = FALSE)

# Print a message indicating completion
cat("All packages have been verified and saved to renv.\n")
