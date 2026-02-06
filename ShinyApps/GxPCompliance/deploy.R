# Deploy GxP Compliance Monitor
# Usage: source("deploy.R")

library(rsconnect)

cat("Deploying GxP Compliance Monitor...\n")

setwd("/Users/justin/ML/ShinyApps/GxPCompliance")
rsconnect::deployApp(appName = "gxp_compliance_monitor")

cat("Done!\n")
