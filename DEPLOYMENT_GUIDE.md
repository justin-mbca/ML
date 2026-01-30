# R Shiny Apps Deployment Guide

## Overview
This guide covers multiple deployment strategies for your Senior Shiny Developer portfolio applications, from local development to enterprise production environments.

## 🚀 Deployment Options

### 1. Local Development
**Best for**: Development, testing, demonstrations

```r
# Run individual apps locally
shiny::runApp("ShinyApps/ClinicalDataViewer/")
shiny::runApp("ShinyApps/PharmacoModel/")
shiny::runApp("ShinyApps/RegulatoryTracker/")
```

**Advantages**:
- Quick setup and testing
- Easy debugging
- No infrastructure costs
- Full control over environment

**Configuration**:
```r
# Set working directory
setwd("/Users/justin/ML")

# Run with custom port
shiny::runApp("ShinyApps/ClinicalDataViewer/", 
              port = 3838, 
              host = "0.0.0.0",
              launch.browser = TRUE)
```

### 2. Shiny Server (Open Source)
**Best for**: Small teams, internal deployments, prototyping

#### Installation (Ubuntu/Debian)
```bash
# Install R
sudo apt-get update
sudo apt-get install r-base r-base-dev

# Install Shiny Server
sudo apt-get install gdebi-core
wget https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-1.5.20.1002-amd64.deb
sudo gdebi shiny-server-1.5.20.1002-amd64.deb
```

#### Configuration
```bash
# Edit configuration file
sudo nano /etc/shiny-server/shiny-server.conf

# Key settings:
run_as shiny;
server {
  listen 3838;
  location / {
    site_dir /srv/shiny-server/;
    log_dir /var/log/shiny-server;
    directory_index on;
  }
}
```

#### Deploy Apps
```bash
# Copy apps to server directory
sudo cp -r ShinyApps/* /srv/shiny-server/
sudo chown -R shiny:shiny /srv/shiny-server/*

# Restart server
sudo systemctl restart shiny-server
```

### 3. Posit Connect (Recommended for Enterprise)
**Best for**: Production, enterprise deployments, regulated environments

#### Setup
1. **Create Posit Connect Account**
   - Cloud: https://posit.cloud
   - On-premise: Install Posit Connect

2. **Configure Authentication**
   - SSO integration
   - LDAP/Active Directory
   - OAuth providers

#### Deploy via RStudio IDE
```r
# Install rsconnect package
install.packages("rsconnect")

# Configure connection
rsconnect::setAccountInfo(
  name = "posit-connect",
  token = "your-api-token",
  server = "your-posit-connect-server"
)

# Deploy app
rsconnect::deployApp(
  appDir = "ShinyApps/ClinicalDataViewer/",
  appName = "clinical-data-viewer",
  account = "posit-connect"
)
```

#### Deploy via Command Line
```bash
# Using rsconnect CLI
rsconnect deploy \
  --app-dir ShinyApps/ClinicalDataViewer/ \
  --name clinical-data-viewer \
  --account posit-connect
```

#### Configuration for Clinical Apps
```yaml
# _app.yml (in app directory)
name: Clinical Data Viewer
title: Clinical Data Viewer
description: CDISC SDTM/ADaM dataset visualization

bundle:
  description: Clinical trial data analysis application
  tags: [clinical, cdisc, regulatory]

environment:
  - R_VERSION: 4.2.0
  - SHINY_SERVER_VERSION: 1.5.20

resources:
  - memory: 2GB
  - cpu: 2

schedule:
  - cron: "0 2 * * *"  # Daily restart at 2 AM
```

### 4. Docker Deployment
**Best for**: Containerized deployments, reproducible environments

#### Create Dockerfile
```dockerfile
# Dockerfile for Clinical Data Viewer
FROM rocker/shiny:4.2.0

# System dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# R packages
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'DT', 'plotly', 'dplyr', 'ggplot2'))"

# Copy app
COPY ShinyApps/ClinicalDataViewer/ /srv/shiny-server/ClinicalDataViewer/

# Expose port
EXPOSE 3838

# Run Shiny
CMD ["/usr/bin/shiny-server"]
```

#### Build and Run
```bash
# Build image
docker build -t clinical-data-viewer .

# Run container
docker run -d -p 3838:3838 clinical-data-viewer
```

#### Docker Compose for Multiple Apps
```yaml
# docker-compose.yml
version: '3.8'
services:
  clinical-viewer:
    build: .
    ports:
      - "3838:3838"
    environment:
      - SHINY_PORT=3838
    volumes:
      - ./ShinyApps/ClinicalDataViewer:/srv/shiny-server/ClinicalDataViewer

  pharmaco-model:
    image: clinical-data-viewer
    ports:
      - "3839:3838"
    volumes:
      - ./ShinyApps/PharmacoModel:/srv/shiny-server/PharmacoModel
```

### 5. Cloud Deployment Options

#### AWS
```bash
# Using AWS EC2 with Shiny Server
# 1. Launch EC2 instance (Ubuntu 20.04)
# 2. Install Shiny Server (see above)
# 3. Configure security groups (port 3838)
# 4. Deploy apps
```

#### Google Cloud Platform
```bash
# Using Google Cloud Run
# 1. Containerize app with Docker
# 2. Push to Google Container Registry
# 3. Deploy to Cloud Run

gcloud builds submit --tag gcr.io/PROJECT-ID/clinical-viewer
gcloud run deploy clinical-viewer --image gcr.io/PROJECT-ID/clinical-viewer --platform managed
```

#### Microsoft Azure
```bash
# Using Azure Container Instances
az container create \
  --resource-group my-resource-group \
  --name clinical-viewer \
  --image clinical-viewer:latest \
  --ports 3838 \
  --dns-name-label clinical-viewer-unique
```

## 🔧 Configuration for Clinical Applications

### Security Configuration
```r
# Add authentication to apps
library(shinymanager)

# In app UI
ui <- dashboardPage(
  # ... existing UI code
  auth_ui(
    login_ui(
      id = "auth",
      credentials = data.frame(
        user = c("admin", "analyst", "reviewer"),
        password = c("admin123", "analyst123", "reviewer123"),
        stringsAsFactors = FALSE
      )
    )
  )
)

# In server
server <- function(input, output, session) {
  auth_server(
    login_server(
      id = "auth",
      credentials = data.frame(
        user = c("admin", "analyst", "reviewer"),
        password = c("admin123", "analyst123", "reviewer123"),
        stringsAsFactors = FALSE
      )
    )
  )
  
  # Rest of server code
}
```

### Database Integration
```r
# Database configuration for clinical data
library(pool)
library(DBI)

# Create connection pool
pool <- dbPool(
  drv = RPostgreSQL::PostgreSQL(),
  dbname = "clinical_trials",
  host = "localhost",
  port = 5432,
  user = Sys.getenv("DB_USER"),
  password = Sys.getenv("DB_PASSWORD"),
  minSize = 1,
  maxSize = 10
)

# Use in app
server <- function(input, output, session) {
  data <- reactive({
    dbGetQuery(pool, "SELECT * FROM clinical_data WHERE study_id = 'STUDY001'")
  })
  
  # Close pool on app exit
  session$onEnded(function() {
    poolClose(pool)
  })
}
```

### Logging and Monitoring
```r
# Add logging to apps
library(log4r)

# Create logger
logger <- create.logger()
setLevel(logger, "INFO")
setFile(logger, "app.log")

# Use in server
server <- function(input, output, session) {
  observe({
    info(logger, paste("App accessed by user:", session$user))
  })
  
  # Log errors
  tryCatch({
    # Your app code
  }, error = function(e) {
    error(logger, paste("Error:", e$message))
  })
}
```

## 📊 Performance Optimization

### Caching
```r
library(shiny)
library(promises)
library(future)

# Enable async processing
plan(multisession)

# Cache expensive computations
cache_data <- memoise::memoise(function() {
  # Expensive data processing
  Sys.sleep(2)
  return(iris)
})

server <- function(input, output, session) {
  # Use cached data
  output$plot <- renderPlot({
    data <- cache_data()
    ggplot(data, aes(Sepal.Length, Sepal.Width)) + geom_point()
  })
}
```

### Resource Management
```r
# Limit concurrent connections
options(shiny.maxRequestSize = 30 * 1024^2)  # 30MB
options(shiny.reactlog = TRUE)  # Enable reactlog
options(shiny.trace = TRUE)  # Enable trace

# Memory management
server <- function(input, output, session) {
  # Clean up reactive values
  observe({
    invalidateLater(10000)  # Clear cache every 10 seconds
    rm(list = ls(envir = .GlobalEnv), envir = .GlobalEnv)
  })
}
```

## 🔒 Security Best Practices

### Input Validation
```r
# Validate all inputs
server <- function(input, output, session) {
  validated_input <- reactive({
    req(input$text_input)
    
    # Sanitize input
    text <- gsub("[^A-Za-z0-9 ]", "", input$text_input)
    
    if (nchar(text) > 1000) {
      stop("Input too long")
    }
    
    return(text)
  })
}
```

### Environment Variables
```r
# Use environment variables for sensitive data
db_config <- list(
  host = Sys.getenv("DB_HOST"),
  port = as.numeric(Sys.getenv("DB_PORT")),
  user = Sys.getenv("DB_USER"),
  password = Sys.getenv("DB_PASSWORD")
)
```

### HTTPS Configuration
```r
# Force HTTPS in production
if (Sys.getenv("SHINY_SERVER_MODE") == "production") {
  # Redirect to HTTPS
  tags$head(
    tags$script("
      if (window.location.protocol !== 'https:') {
        window.location.href = 'https:' + window.location.href.substring(window.location.protocol.length);
      }
    ")
  )
}
```

## 📱 Mobile Optimization

### Responsive Design
```css
/* Add to www/custom.css */
@media (max-width: 768px) {
  .main-header {
    font-size: 14px;
  }
  
  .content {
    padding: 10px;
  }
  
  .box {
    margin-bottom: 10px;
  }
}
```

### Touch-Friendly Interface
```r
# Use larger buttons for mobile
actionButton("submit", "Submit", 
             class = "btn-primary btn-lg",
             width = "100%")
```

## 🚀 CI/CD Pipeline

### GitHub Actions
```yaml
# .github/workflows/deploy.yml
name: Deploy Shiny App

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup R
      uses: r-lib/actions/setup-r@v2
      with:
        r-version: '4.2.0'
    
    - name: Install dependencies
      run: |
        install.packages(c("shiny", "rsconnect"))
      shell: Rscript {0}
    
    - name: Deploy to Posit Connect
      env:
        CONNECT_API_KEY: ${{ secrets.CONNECT_API_KEY }}
      run: |
        rsconnect::deployApp(
          appDir = "ShinyApps/ClinicalDataViewer/",
          appName = "clinical-data-viewer",
          server = Sys.getenv("CONNECT_SERVER"),
          account = Sys.getenv("CONNECT_ACCOUNT"),
          key = Sys.getenv("CONNECT_API_KEY")
        )
      shell: Rscript {0}
```

## 📈 Monitoring and Maintenance

### Health Checks
```r
# Add health check endpoint
server <- function(input, output, session) {
  output$health_check <- renderText({
    list(
      status = "healthy",
      timestamp = Sys.time(),
      version = "1.0.0"
    )
  })
}
```

### Performance Monitoring
```r
library(shinycssloaders)

# Add loading indicators
output$plot <- renderPlot({
  withSpinner({
    # Your plotting code
    ggplot(data, aes(x, y)) + geom_point()
  })
})
```

## 🎯 Deployment Checklist

### Pre-Deployment
- [ ] Test all functionality locally
- [ ] Validate data security
- [ ] Check performance under load
- [ ] Verify responsive design
- [ ] Test error handling

### Production Deployment
- [ ] Configure HTTPS
- [ ] Set up authentication
- [ ] Enable logging
- [ ] Configure monitoring
- [ ] Set up backup procedures

### Post-Deployment
- [ ] Monitor performance
- [ ] Check error logs
- [ ] Validate user access
- [ ] Test all features
- [ ] Document deployment

## 📞 Support and Maintenance

### Regular Maintenance Tasks
- Update R packages monthly
- Review security logs weekly
- Monitor performance metrics
- Backup application data
- Test disaster recovery procedures

### Troubleshooting Common Issues
- **Memory errors**: Increase memory allocation, optimize code
- **Slow performance**: Implement caching, optimize queries
- **Authentication issues**: Check user credentials, permissions
- **Database connection**: Verify credentials, network connectivity

This deployment guide provides comprehensive options for taking your Senior Shiny Developer portfolio from local development to enterprise production environments.
