#!/usr/bin/env Rscript

# Script to prepare the environment for GitHub Actions deployment
# This script ensures that tidyverse and all required packages are installed
# and properly captured in the renv lockfile

# Print header
cat("=== GitHub Actions Environment Preparation ===\n\n")

# Set CRAN repository
cat("Setting CRAN repository...\n")
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Check if renv is available
if (!requireNamespace("renv", quietly = TRUE)) {
  cat("Installing renv package...\n")
  install.packages("renv")
}

# Load renv
library(renv)

# Initialize renv if needed
if (!file.exists("renv.lock")) {
  cat("Initializing renv...\n")
  renv::init(force = TRUE)
}

# Function to install a package and verify installation
install_and_verify <- function(package_name) {
  cat(paste0("Processing package: ", package_name, "...\n"))
  
  # Check if package is installed
  if (!requireNamespace(package_name, quietly = TRUE)) {
    cat(paste0("Installing ", package_name, "...\n"))
    install.packages(package_name)
    
    # Verify installation
    if (!requireNamespace(package_name, quietly = TRUE)) {
      stop(paste0("Failed to install ", package_name, ". Aborting."))
    }
    cat(paste0("Successfully installed ", package_name, ".\n"))
  } else {
    cat(paste0(package_name, " is already installed.\n"))
  }
  
  # Load the package to ensure it works
  cat(paste0("Loading ", package_name, "...\n"))
  library(package_name, character.only = TRUE)
  cat(paste0("Successfully loaded ", package_name, ".\n"))
  
  # Return TRUE if successful
  return(TRUE)
}

# Install and verify tidyverse
cat("\n=== Installing and verifying tidyverse ===\n")
tidyverse_ok <- install_and_verify("tidyverse")

# Install and verify other essential packages
cat("\n=== Installing and verifying other essential packages ===\n")
essential_packages <- c("shiny", "rsconnect")
all_ok <- TRUE

for (pkg in essential_packages) {
  pkg_ok <- tryCatch({
    install_and_verify(pkg)
  }, error = function(e) {
    cat(paste0("Error processing ", pkg, ": ", e$message, "\n"))
    return(FALSE)
  })
  
  all_ok <- all_ok && pkg_ok
}

# Create a snapshot with specific focus on tidyverse
cat("\n=== Creating renv snapshot ===\n")
cat("Creating snapshot with focus on tidyverse...\n")
snapshot_result <- tryCatch({
  renv::snapshot(packages = c("tidyverse", essential_packages), confirm = FALSE)
  TRUE
}, error = function(e) {
  cat(paste0("Error creating snapshot: ", e$message, "\n"))
  FALSE
})

# Create a full snapshot as a backup approach
if (!snapshot_result) {
  cat("Trying full snapshot as a backup approach...\n")
  snapshot_result <- tryCatch({
    renv::snapshot(confirm = FALSE)
    TRUE
  }, error = function(e) {
    cat(paste0("Error creating full snapshot: ", e$message, "\n"))
    FALSE
  })
}

# Verify tidyverse is in the lockfile
cat("\n=== Verifying renv lockfile ===\n")
lockfile_ok <- tryCatch({
  lockfile <- renv::lockfile_read("renv.lock")
  packages <- names(lockfile$Packages)
  
  if ("tidyverse" %in% packages) {
    cat("✓ tidyverse is present in the renv lockfile.\n")
    TRUE
  } else {
    cat("✗ tidyverse is NOT present in the renv lockfile!\n")
    FALSE
  }
}, error = function(e) {
  cat(paste0("Error reading lockfile: ", e$message, "\n"))
  FALSE
})

# Final status report
cat("\n=== Environment Preparation Status ===\n")
cat(paste0("tidyverse installation: ", ifelse(tidyverse_ok, "✓ OK", "✗ Failed"), "\n"))
cat(paste0("Essential packages: ", ifelse(all_ok, "✓ OK", "✗ Some failed"), "\n"))
cat(paste0("renv snapshot: ", ifelse(snapshot_result, "✓ OK", "✗ Failed"), "\n"))
cat(paste0("Lockfile verification: ", ifelse(lockfile_ok, "✓ OK", "✗ Failed"), "\n"))

# Overall status
overall_status <- tidyverse_ok && all_ok && snapshot_result && lockfile_ok

cat("\n=== Overall Status ===\n")
if (overall_status) {
  cat("✓ Environment preparation completed successfully!\n")
  cat("  The environment is ready for deployment.\n")
  quit(status = 0)
} else {
  cat("✗ Environment preparation failed!\n")
  cat("  Please check the logs above for details.\n")
  quit(status = 1)
}
