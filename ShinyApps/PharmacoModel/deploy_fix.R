library(rsconnect)
cat("Deploying pharmacomodel-dashboard...\n")
rsconnect::deployApp(appName = "pharmacomodel-dashboard")
cat("✓ Done!\n")
