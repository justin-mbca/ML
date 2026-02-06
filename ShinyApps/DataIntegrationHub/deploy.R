library(rsconnect)
cat("Deploying Data Integration & Processing Hub...\n")
rsconnect::deployApp(appName = "data-integration-hub")
cat("✓ Done!\n")
