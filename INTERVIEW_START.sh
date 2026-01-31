#!/bin/bash
# Interview Demo Quick Start Script

echo "🚀 Senior Shiny Developer Interview Demo"
echo "=========================================="
echo "Starting portfolio applications for interview..."
echo ""

# Kill any existing R processes
echo "🔄 Cleaning up existing processes..."
pkill -f R 2>/dev/null
sleep 2

echo "📱 Starting Applications..."
echo ""

# Clinical Data Viewer (Primary Demo)
echo "1. Clinical Data Viewer - http://127.0.0.1:3839"
echo "   ✅ Senior Shiny Development | CDISC SDTM/ADaM | Clinical Data Analysis"
R -e "shiny::runApp('ShinyApps/ClinicalDataViewer/', port=3839, host='127.0.0.1', launch.browser=FALSE)" &
sleep 3

# Regulatory Tracker
echo "2. Regulatory Tracker - http://127.0.0.1:3840"
echo "   ✅ Data Pipelines | Workflow Automation | Regulatory Submissions"
R -e "shiny::runApp('ShinyApps/RegulatoryTracker/', port=3840, host='127.0.0.1', launch.browser=FALSE)" &
sleep 3

# SAS to R Workflow
echo "3. SAS to R Workflow - http://127.0.0.1:3841"
echo "   ✅ SAS Experience | CDISC Knowledge | R Migration"
R -e "shiny::runApp('ShinyApps/SAS2RWorkflow/', port=3841, host='127.0.0.1', launch.browser=FALSE)" &
sleep 3

# HPC Dashboard
echo "4. HPC Dashboard - http://127.0.0.1:3842"
echo "   ✅ HPC/Linux | Data Engineering | Large-Scale Processing"
R -e "shiny::runApp('ShinyApps/HPCDashboard/', port=3842, host='127.0.0.1', launch.browser=FALSE)" &
sleep 3

echo ""
echo "🎯 INTERVIEW READY!"
echo "=========================================="
echo "Primary Demos (Required Qualifications):"
echo "📊 Clinical Data Viewer: http://127.0.0.1:3839"
echo "📋 Regulatory Tracker: http://127.0.0.1:3840"
echo "🔄 SAS to R Workflow: http://127.0.0.1:3841"
echo "⚡ HPC Dashboard: http://127.0.0.1:3842"
echo ""
echo "GitHub Portfolio: https://github.com/justin-mbca/ML"
echo "Interview Guide: INTERVIEW_DEMO_GUIDE.md"
echo ""
echo "📱 Quick Demo Commands:"
echo "   • Open browser to http://127.0.0.1:3839 (Clinical Data Viewer)"
echo "   • Navigate through tabs to see different features"
echo "   • Try interactive filters and visualizations"
echo "   • Check documentation in each app"
echo ""
echo "🛑 To stop all apps: pkill -f R"
echo "🔍 To check status: ps aux | grep R"
echo ""
echo "Good luck with your interview! 🚀"
