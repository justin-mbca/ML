# Deploy LLM Analytics
# Usage: source("deploy.R")

library(rsconnect)

cat("Deploying LLM Analytics...\n")

setwd("/Users/justin/ML/ShinyApps/LLMAnalytics")
rsconnect::deployApp(appName = "llm_analytics")

cat("Done!\n")
