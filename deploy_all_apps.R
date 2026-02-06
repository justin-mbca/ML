# Deploy All Shiny Apps to ShinyApps.io
# Run this script in R to deploy all 9 apps

library(rsconnect)

# List of apps to deploy
apps <- list(
  list(path = "ShinyApps/RegulatoryTracker", name = "regulatory-tracker"),
  list(path = "ShinyApps/GxPCompliance", name = "gxp-compliance-monitor"),
  list(path = "ShinyApps/SAS2RWorkflow", name = "sas-to-r-workflow"),
  list(path = "ShinyApps/PharmaverseDemo", name = "pharmaverse-integration"),
  list(path = "ShinyApps/HPCDashboard", name = "hpc-dashboard"),
  list(path = "ShinyApps/LLMAnalytics", name = "llm-analytics"),
  list(path = "ShinyApps/MarketplaceEnhanced", name = "marketplace-enhanced")
)

# Deploy each app
cat("Starting deployment of all Shiny apps...\n\n")

for (i in seq_along(apps)) {
  app <- apps[[i]]
  cat(sprintf("[%d/%d] Deploying %s from %s\n", i, length(apps), app$name, app$path))
  
  tryCatch({
    # Set working directory
    setwd(app$path)
    
    # Deploy the app
    rsconnect::deployApp(appName = app$name)
    
    cat(sprintf("✓ %s deployed successfully!\n\n", app$name))
    
    # Go back to root
    setwd("../..")
  }, error = function(e) {
    cat(sprintf("✗ Error deploying %s: %s\n\n", app$name, e$message))
    setwd("../..")
  })
}

cat("Deployment complete!\n")
cat("View your apps at: https://www.shinyapps.io/admin\n")
