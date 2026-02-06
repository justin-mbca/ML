library(rsconnect)
cat("Deploying Clinical Trial Management Suite...\n")
rsconnect::deployApp(appName = "clinical-trial-suite")
cat("✓ Done!\n")
