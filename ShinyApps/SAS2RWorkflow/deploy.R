# Deploy SAS to R Workflow
# Usage: source("deploy.R")

library(rsconnect)

cat("Deploying SAS to R Workflow...\n")

setwd("/Users/justin/ML/ShinyApps/SAS2RWorkflow")
rsconnect::deployApp(appName = "sas_to_r_workflow")

cat("Done!\n")
