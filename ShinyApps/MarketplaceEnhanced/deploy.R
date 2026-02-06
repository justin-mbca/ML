# Deploy Marketplace Enhanced
# Usage: source("deploy.R")

library(rsconnect)

cat("Deploying Marketplace Enhanced...\n")

setwd("/Users/justin/ML/ShinyApps/MarketplaceEnhanced")
rsconnect::deployApp(appName = "marketplace_enhanced")

cat("Done!\n")
