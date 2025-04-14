#!/usr/bin/env Rscript

# Script to test the tidyverse installation fix locally
# This script will verify that tidyverse is properly installed and captured in the renv lockfile

# Print header
cat("=== Testing tidyverse Installation Fix ===\n\n")

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

# Check if tidyverse is installed
cat("\n=== Checking tidyverse installation ===\n")
if (requireNamespace("tidyverse", quietly = TRUE)) {
  tidyverse_version <- packageVersion("tidyverse")
  cat(paste0("✓ tidyverse (version ", tidyverse_version, ") is installed\n"))
  
  # Try loading tidyverse to ensure it works
  tryCatch({
    library(tidyverse)
    cat("✓ tidyverse loaded successfully\n")
  }, error = function(e) {
    cat(paste0("✗ Error loading tidyverse: ", e$message, "\n"))
  })
} else {
  cat("✗ tidyverse is NOT installed\n")
  
  # Ask if user wants to install tidyverse
  cat("\nWould you like to install tidyverse now? (y/n): ")
  answer <- readline()
  
  if (tolower(answer) == "y") {
    cat("Installing tidyverse...\n")
    install.packages("tidyverse")
    
    # Check if installation was successful
    if (requireNamespace("tidyverse", quietly = TRUE)) {
      tidyverse_version <- packageVersion("tidyverse")
      cat(paste0("✓ tidyverse (version ", tidyverse_version, ") installed successfully\n"))
    } else {
      cat("✗ Failed to install tidyverse\n")
    }
  }
}

# Check if tidyverse is in the renv lockfile
cat("\n=== Checking renv lockfile ===\n")
if (file.exists("renv.lock")) {
  tryCatch({
    lockfile <- renv::lockfile_read("renv.lock")
    packages <- names(lockfile$Packages)
    
    if ("tidyverse" %in% packages) {
      tidyverse_info <- lockfile$Packages$tidyverse
      cat("✓ tidyverse is present in the renv lockfile\n")
      cat(paste0("  Version: ", tidyverse_info$Version, "\n"))
      cat(paste0("  Source: ", tidyverse_info$Repository, "\n"))
    } else {
      cat("✗ tidyverse is NOT present in the renv lockfile\n")
      
      # Ask if user wants to add tidyverse to the lockfile
      cat("\nWould you like to add tidyverse to the renv lockfile? (y/n): ")
      answer <- readline()
      
      if (tolower(answer) == "y") {
        cat("Adding tidyverse to the renv lockfile...\n")
        renv::snapshot(packages = "tidyverse", confirm = FALSE)
        
        # Verify tidyverse was added to the lockfile
        lockfile <- renv::lockfile_read("renv.lock")
        packages <- names(lockfile$Packages)
        
        if ("tidyverse" %in% packages) {
          tidyverse_info <- lockfile$Packages$tidyverse
          cat("✓ tidyverse was successfully added to the renv lockfile\n")
          cat(paste0("  Version: ", tidyverse_info$Version, "\n"))
          cat(paste0("  Source: ", tidyverse_info$Repository, "\n"))
        } else {
          cat("✗ Failed to add tidyverse to the renv lockfile\n")
        }
      }
    }
  }, error = function(e) {
    cat(paste0("✗ Error reading lockfile: ", e$message, "\n"))
  })
} else {
  cat("✗ renv.lock file does not exist\n")
  
  # Ask if user wants to initialize renv
  cat("\nWould you like to initialize renv and create a lockfile? (y/n): ")
  answer <- readline()
  
  if (tolower(answer) == "y") {
    cat("Initializing renv...\n")
    renv::init(force = TRUE)
    
    # Check if tidyverse is installed and add it to the lockfile
    if (requireNamespace("tidyverse", quietly = TRUE)) {
      cat("Adding tidyverse to the renv lockfile...\n")
      renv::snapshot(packages = "tidyverse", confirm = FALSE)
      
      # Verify tidyverse was added to the lockfile
      if (file.exists("renv.lock")) {
        lockfile <- renv::lockfile_read("renv.lock")
        packages <- names(lockfile$Packages)
        
        if ("tidyverse" %in% packages) {
          tidyverse_info <- lockfile$Packages$tidyverse
          cat("✓ tidyverse was successfully added to the renv lockfile\n")
          cat(paste0("  Version: ", tidyverse_info$Version, "\n"))
          cat(paste0("  Source: ", tidyverse_info$Repository, "\n"))
        } else {
          cat("✗ Failed to add tidyverse to the renv lockfile\n")
        }
      } else {
        cat("✗ Failed to create renv.lock file\n")
      }
    } else {
      cat("✗ tidyverse is not installed, cannot add to lockfile\n")
    }
  }
}

# Final summary
cat("\n=== Summary ===\n")
tidyverse_installed <- requireNamespace("tidyverse", quietly = TRUE)
tidyverse_in_lockfile <- FALSE

if (file.exists("renv.lock")) {
  tryCatch({
    lockfile <- renv::lockfile_read("renv.lock")
    packages <- names(lockfile$Packages)
    tidyverse_in_lockfile <- "tidyverse" %in% packages
  }, error = function(e) {
    tidyverse_in_lockfile <- FALSE
  })
}

cat(paste0("tidyverse installed: ", ifelse(tidyverse_installed, "✓ Yes", "✗ No"), "\n"))
cat(paste0("tidyverse in renv lockfile: ", ifelse(tidyverse_in_lockfile, "✓ Yes", "✗ No"), "\n"))

if (tidyverse_installed && tidyverse_in_lockfile) {
  cat("\n✓ Your environment is correctly set up for deployment!\n")
  cat("  You can now run the github-action-deploy.R script to test deployment.\n")
} else {
  cat("\n✗ Your environment is not correctly set up for deployment.\n")
  cat("  Please run the github-action-prepare.R script to fix the issues.\n")
}
