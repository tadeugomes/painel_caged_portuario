# GitHub Actions Deployment Fix

This document explains how to fix the issue with tidyverse package installation during GitHub Actions deployment.

## The Problem

When GitHub Actions tries to deploy the Shiny application to shinyapps.io, it encounters this error:

```
ℹ Capturing R dependencies
The following required packages are not installed:
- tidyverse
Packages must first be installed before renv can snapshot them.
```

This occurs because the tidyverse package is required by the application but is not being properly installed or captured in the renv lockfile during the GitHub Actions workflow.

## The Solution

Two new scripts have been created to address this issue:

1. `github-action-prepare.R`: Ensures that tidyverse and other essential packages are installed and properly captured in the renv lockfile.
2. `github-action-deploy.R`: Uses the preparation script before attempting deployment to shinyapps.io.

## How to Use These Scripts

### Option 1: Update Your GitHub Actions Workflow

Modify your GitHub Actions workflow file (`.github/workflows/your-workflow.yml`) to use the new scripts:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up R
        uses: r-lib/actions/setup-r@v2
        with:
          r-version: '4.2.0'
          
      - name: Install system dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y libcurl4-openssl-dev libssl-dev libxml2-dev
          
      - name: Install R dependencies and prepare environment
        run: |
          Rscript github-action-prepare.R
          
      - name: Deploy to shinyapps.io
        env:
          SHINYAPPS_TOKEN: ${{ secrets.SHINYAPPS_TOKEN }}
          SHINYAPPS_SECRET: ${{ secrets.SHINYAPPS_SECRET }}
        run: |
          Rscript github-action-deploy.R
```

### Option 2: Use the New Deploy Script Directly

If you prefer not to modify your workflow file, you can simply replace the call to your current deploy script with the new `github-action-deploy.R` script:

```yaml
- name: Deploy to shinyapps.io
  env:
    SHINYAPPS_TOKEN: ${{ secrets.SHINYAPPS_TOKEN }}
    SHINYAPPS_SECRET: ${{ secrets.SHINYAPPS_SECRET }}
  run: |
    Rscript github-action-deploy.R
```

## Testing the Fix Locally

### Option 1: Using the Test Script

A test script has been provided to help you verify that tidyverse is properly installed and captured in the renv lockfile:

```r
source("test-tidyverse-fix.R")
```

This interactive script will:
- Check if tidyverse is installed
- Verify if tidyverse is in the renv lockfile
- Offer to fix any issues that are found
- Provide a summary of the environment status

### Option 2: Manual Testing

You can also test the scripts manually before pushing to GitHub:

1. Make sure you have the required environment variables set:
   ```r
   Sys.setenv(SHINYAPPS_TOKEN = "your_token")
   Sys.setenv(SHINYAPPS_SECRET = "your_secret")
   ```

2. Run the preparation script:
   ```r
   source("github-action-prepare.R")
   ```

3. If the preparation is successful, run the deployment script:
   ```r
   source("github-action-deploy.R")
   ```

## How the Fix Works

The `github-action-prepare.R` script:

1. Ensures renv is installed and initialized
2. Installs tidyverse and verifies the installation
3. Installs other essential packages (shiny, rsconnect)
4. Creates an renv snapshot that specifically includes tidyverse
5. Verifies that tidyverse is present in the renv lockfile

The `github-action-deploy.R` script:

1. Runs the preparation script to ensure all dependencies are installed
2. Performs additional checks to ensure tidyverse is installed
3. Proceeds with the deployment to shinyapps.io

This approach ensures that tidyverse is properly installed and captured in the renv lockfile before the deployment process begins, which should resolve the error.
