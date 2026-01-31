#!/bin/bash
# Script to start all Shiny apps for visualization

echo "Starting R Shiny Apps Portfolio..."
echo "=========================================="

# Clinical Data Viewer
echo "1. Clinical Data Viewer: http://127.0.0.1:3839"
R -e "shiny::runApp('ShinyApps/ClinicalDataViewer/', port=3839, host='127.0.0.1', launch.browser=FALSE)" &
sleep 2

# PharmacoModel Dashboard
echo "2. PharmacoModel Dashboard: http://127.0.0.1:3840"
R -e "shiny::runApp('ShinyApps/PharmacoModel/', port=3840, host='127.0.0.1', launch.browser=FALSE)" &
sleep 2

# Regulatory Tracker
echo "3. Regulatory Tracker: http://127.0.0.1:3841"
R -e "shiny::runApp('ShinyApps/RegulatoryTracker/', port=3841, host='127.0.0.1', launch.browser=FALSE)" &
sleep 2

# SAS to R Workflow
echo "4. SAS to R Workflow: http://127.0.0.1:3842"
R -e "shiny::runApp('ShinyApps/SAS2RWorkflow/', port=3842, host='127.0.0.1', launch.browser=FALSE)" &
sleep 2

# HPC Dashboard
echo "5. HPC Dashboard: http://127.0.0.1:3843"
R -e "shiny::runApp('ShinyApps/HPCDashboard/', port=3843, host='127.0.0.1', launch.browser=FALSE)" &
sleep 2

# Pharmaverse Integration
echo "6. Pharmaverse Integration: http://127.0.0.1:3844"
R -e "shiny::runApp('ShinyApps/PharmaverseDemo/', port=3844, host='127.0.0.1', launch.browser=FALSE)" &
sleep 2

# GxP Compliance Monitor
echo "7. GxP Compliance Monitor: http://127.0.0.1:3845"
R -e "shiny::runApp('ShinyApps/GxPCompliance/', port=3845, host='127.0.0.1', launch.browser=FALSE)" &
sleep 2

# LLM Analytics
echo "8. LLM Analytics: http://127.0.0.1:3846"
R -e "shiny::runApp('ShinyApps/LLMAnalytics/', port=3846, host='127.0.0.1', launch.browser=FALSE)" &
sleep 2

echo "=========================================="
echo "All apps started! Access them at:"
echo "http://127.0.0.1:3839 - Clinical Data Viewer"
echo "http://127.0.0.1:3840 - PharmacoModel Dashboard"
echo "http://127.0.0.1:3841 - Regulatory Tracker"
echo "http://127.0.0.1:3842 - SAS to R Workflow"
echo "http://127.0.0.1:3843 - HPC Dashboard"
echo "http://127.0.0.1:3844 - Pharmaverse Integration"
echo "http://127.0.0.1:3845 - GxP Compliance Monitor"
echo "http://127.0.0.1:3846 - LLM Analytics"
echo ""
echo "To stop all apps: pkill -f R"
echo "To check running apps: ps aux | grep R"
