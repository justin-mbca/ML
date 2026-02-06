library(rsconnect)
cat("Deploying llm-analytics...\n")
rsconnect::deployApp(appName = "llm-analytics")
cat("✓ Done!\n")
