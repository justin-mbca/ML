# Deploy Pharmaverse Integration Demo
# Usage: source("deploy.R")

library(rsconnect)

cat("Deploying Pharmaverse Integration...\n")

setwd("/Users/justin/ML/ShinyApps/PharmaverseDemo")
rsconnect::deployApp(appName = "pharmaverse_integration")

cat("Done!\n")
