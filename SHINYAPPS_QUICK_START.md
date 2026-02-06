# Quick Start: Deploy to ShinyApps.io

## Prerequisites
Make sure you've completed these steps ONCE:

```r
# 1. Install rsconnect
install.packages("rsconnect")

# 2. Go to https://www.shinyapps.io/admin → Account → Tokens
# 3. Click "Show" and copy your credentials
# 4. Run this ONCE to authorize (paste your actual values):

rsconnect::setAccountInfo(
  account   = "your-username-here",
  token     = "your-token-here",
  secret    = "your-secret-here"
)
```

## Deploy All Apps at Once

```r
# From R Console, run:
source("/Users/justin/ML/deploy_all_apps.R")
```

This will deploy all 9 apps with one command!

## Deploy Individual App

```r
# From R Console:
source("/Users/justin/ML/ShinyApps/ClinicalDataViewer/deploy.R")
```

## Check Deployment Status

```r
# List all your deployed apps:
rsconnect::deployments()

# Or visit: https://www.shinyapps.io/admin
```

## Update a Deployed App

After making changes to an app, just redeploy:
```r
source("/Users/justin/ML/deploy_all_apps.R")
```

ShinyApps.io handles versioning and zero-downtime updates automatically.

---

**Need to change app names or deployment settings?**
Edit `deploy_all_apps.R` and modify the `apps` list at the top.
