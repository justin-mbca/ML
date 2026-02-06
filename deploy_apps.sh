#!/bin/bash
# Deploy all Shiny apps to ShinyApps.io

echo "Deploying all Shiny apps..."

apps=(
  "ClinicalDataViewer:clinical-data-viewer"
  "PharmacoModel:pharmacomodel-dashboard"
  "RegulatoryTracker:regulatory-tracker"
  "GxPCompliance:gxp-compliance-monitor"
  "SAS2RWorkflow:sas-to-r-workflow"
  "PharmaverseDemo:pharmaverse-integration"
  "HPCDashboard:hpc-dashboard"
  "LLMAnalytics:llm-analytics"
  "MarketplaceEnhanced:marketplace-enhanced"
)

for app_info in "${apps[@]}"; do
  IFS=':' read -r app_dir app_name <<< "$app_info"
  
  echo ""
  echo "==========================================="
  echo "Deploying $app_name from $app_dir"
  echo "==========================================="
  
  cd "/Users/justin/ML/ShinyApps/$app_dir"
  
  Rscript << EOFR
library(rsconnect)
cat("Deploying $app_name...\n")
rsconnect::deployApp(appName = "$app_name")
cat("✓ $app_name deployed\n")
EOFR
  
  if [ $? -eq 0 ]; then
    echo "✓ $app_name deployed successfully"
  else
    echo "✗ Failed to deploy $app_name"
  fi
done

echo ""
echo "==========================================="
echo "Deployment complete!"
echo "==========================================="
echo "View your apps at: https://www.shinyapps.io/admin"
