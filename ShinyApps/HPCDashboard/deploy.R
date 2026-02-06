# Deploy HPC Dashboard
# Usage: source("deploy.R")

library(rsconnect)

cat("Deploying HPC Dashboard...\n")

setwd("/Users/justin/ML/ShinyApps/HPCDashboard")
rsconnect::deployApp(appName = "hpc_dashboard")

cat("Done!\n")
