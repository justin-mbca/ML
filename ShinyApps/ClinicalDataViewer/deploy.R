# Deploy Individual App
# Usage: source("deploy_clinical_viewer.R")

library(rsconnect)

cat("Deploying Clinical Data Viewer...\n")

setwd("/Users/justin/ML/ShinyApps/ClinicalDataViewer")
rsconnect::deployApp(appName = "clinical-data-viewer")

cat("Done!\n")
