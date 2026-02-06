library(rsconnect)

apps <- list(
  list(path = "ShinyApps/RegulatoryTracker", name = "regulatory-tracker"),
  list(path = "ShinyApps/GxPCompliance", name = "gxp-compliance-monitor"),
  list(path = "ShinyApps/SAS2RWorkflow", name = "sas-to-r-workflow"),
  list(path = "ShinyApps/PharmaverseDemo", name = "pharmaverse-integration"),
  list(path = "ShinyApps/HPCDashboard", name = "hpc-dashboard"),
  list(path = "ShinyApps/LLMAnalytics", name = "llm-analytics"),
  list(path = "ShinyApps/MarketplaceEnhanced", name = "marketplace-enhanced")
)

cat("Starting deployment of remaining 7 apps...\n\n")

for (i in seq_along(apps)) {
  app <- apps[[i]]
  cat(sprintf("[%d/7] Deploying %s from %s\n", i, app$name, app$path))
  
  tryCatch({
    setwd(paste0("/Users/justin/ML/", app$path))
    rsconnect::deployApp(appName = app$name)
    cat(sprintf("✓ %s deployed successfully!\n\n", app$name))
    setwd("/Users/justin/ML")
  }, error = function(e) {
    cat(sprintf("✗ Error deploying %s: %s\n\n", app$name, e$message))
    setwd("/Users/justin/ML")
  })
}

cat("Deployment complete!\n")
cat("View your apps at: https://www.shinyapps.io/admin\n")
