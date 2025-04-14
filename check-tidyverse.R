# Script to check if tidyverse is installed and add it if needed

# Load renv
library(renv)

# Check if tidyverse is installed
if (!requireNamespace("tidyverse", quietly = TRUE)) {
  cat("Installing tidyverse package...\n")
  install.packages("tidyverse")
  
  # Save the updated package state to renv
  renv::snapshot(confirm = FALSE)
  
  cat("tidyverse package has been installed and saved to renv.\n")
} else {
  cat("tidyverse package is already installed.\n")
  
  # Make sure it's in the lockfile
  renv::snapshot(packages = "tidyverse", confirm = FALSE)
  
  cat("Ensured tidyverse is in the renv lockfile.\n")
}

# Print a message indicating completion
cat("Verification complete.\n")
