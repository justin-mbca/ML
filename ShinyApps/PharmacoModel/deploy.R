# Deploy PharmacoModel Dashboard
# Usage: source("deploy.R")

library(rsconnect)

cat("Deploying PharmacoModel Dashboard...\n")

setwd("/Users/justin/ML/ShinyApps/PharmacoModel")
rsconnect::deployApp(appName = "pharmacomodel_dashboard")

cat("Done!\n")
