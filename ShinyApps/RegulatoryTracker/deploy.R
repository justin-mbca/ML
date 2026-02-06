# Deploy Regulatory Tracker
# Usage: source("deploy.R")

library(rsconnect)

cat("Deploying Regulatory Tracker...\n")

setwd("/Users/justin/ML/ShinyApps/RegulatoryTracker")
rsconnect::deployApp(appName = "regulatory_tracker")

cat("Done!\n")
