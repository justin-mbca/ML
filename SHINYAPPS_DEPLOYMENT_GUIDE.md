# ShinyApps.io Deployment Guide

## Quick Start: Deploy Your R Shiny Apps to ShinyApps.io

### Step 1: Create ShinyApps.io Account
1. Go to [shinyapps.io](https://www.shinyapps.io)
2. Sign up for a free account
3. Note your username

### Step 2: Install rsconnect Package
Run this in R:
```r
install.packages("rsconnect")
library(rsconnect)
```

### Step 3: Authorize Your Account
1. In your [ShinyApps.io dashboard](https://www.shinyapps.io/admin), go to **Account → Tokens**
2. Click **Show** to reveal your token
3. Run this in R (replace with your actual token):

```r
rsconnect::setAccountInfo(
  account   = "your-username",
  token     = "your-token-here",
  secret    = "your-secret-here"
)
```

### Step 4: Deploy Each App
Navigate to each app directory and deploy:

```r
setwd("/Users/justin/ML/ShinyApps/ClinicalDataViewer")
rsconnect::deployApp()
```

**Repeat for each app:**
- `ClinicalDataViewer`
- `PharmacoModel`
- `RegulatoryTracker`
- `GxPCompliance`
- `SAS2RWorkflow`
- `PharmaverseDemo`
- `HPCDashboard`
- `LLMAnalytics`
- `MarketplaceEnhanced`

### Step 5: Manage Apps
- View deployed apps: https://www.shinyapps.io/admin
- Share URLs with others
- Monitor usage and logs in your dashboard

## Dependencies
rsconnect will automatically detect and bundle required packages from your app.R files based on:
- library() calls
- require() calls

Your apps use: shiny, shinydashboard, DT, plotly, dplyr, ggplot2, etc. - all standard packages that deploy smoothly.

## Free Tier Limits
- 5 apps maximum
- 25 hours/month runtime
- Automatic sleep after 15 mins of inactivity

**Upgrade** to paid plans for more apps and runtime hours.

## Troubleshooting

### Missing Packages
If deployment fails due to missing packages, install them locally first:
```r
install.packages("package-name")
```

### Local Testing
Before deploying, test locally:
```r
setwd("/Users/justin/ML/ShinyApps/ClinicalDataViewer")
shiny::runApp()
```

### Deployment Size
Apps over 1GB will fail. Check:
```bash
du -sh /Users/justin/ML/ShinyApps/*/
```

## Updating Apps
To update a deployed app, modify app.R and redeploy:
```r
rsconnect::deployApp()
```

ShinyApps.io will version your deployment and make updates instantly.

---

**Next Steps:**
1. Sign up at shinyapps.io
2. Get your token/secret
3. Run the authorization code in R
4. Deploy your apps!
