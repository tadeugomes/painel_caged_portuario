# Script to update packages and save to renv

# Load renv
library(renv)

# Update all packages
renv::update()

# Save the updated package state to renv
renv::snapshot(confirm = FALSE)

# Print a message indicating completion
cat("All packages have been updated and saved to renv.\n")
