# Script to specifically install tidyverse and save it to renv

# Load renv
library(renv)

# Install tidyverse
cat("Installing tidyverse package...\n")
install.packages("tidyverse")

# Save the updated package state to renv
cat("Saving tidyverse to renv lockfile...\n")
renv::snapshot(packages = "tidyverse", confirm = FALSE)

# Print a message indicating completion
cat("tidyverse package has been installed and saved to renv.\n")
