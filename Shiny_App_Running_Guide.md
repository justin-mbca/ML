# Complete Guide to Running Shiny Apps

## 🚀 **Quick Start Methods**

### **1. Run Individual App (Easiest)**
```bash
# Navigate to your project directory
cd /Users/justin/ML

# Run specific app
R -e "shiny::runApp('ShinyApps/ClinicalDataViewer/')"
```

### **2. Use Your Automated Script**
```bash
cd /Users/justin/ML
./INTERVIEW_START.sh
```

### **3. Run from RStudio**
```r
# In RStudio console
setwd("/Users/justin/ML/ShinyApps/ClinicalDataViewer/")
shiny::runApp()
```

---

## 📱 **Different Running Methods**

### **🎯 Method 1: Basic Local Run**

#### **Command Line:**
```bash
# Basic run (default port 3838)
cd /Users/justin/ML
R -e "shiny::runApp('ShinyApps/ClinicalDataViewer/')"

# With custom port
R -e "shiny::runApp('ShinyApps/ClinicalDataViewer/', port=8501)"

# With browser auto-open
R -e "shiny::runApp('ShinyApps/ClinicalDataViewer/', launch.browser=TRUE)"

# Background run (keeps terminal available)
R -e "shiny::runApp('ShinyApps/ClinicalDataViewer/', port=8501)" &
```

#### **R Console:**
```r
# Set working directory
setwd("/Users/justin/ML/ShinyApps/ClinicalDataViewer/")

# Run app
shiny::runApp()

# With options
shiny::runApp(
  port = 8501,
  host = "127.0.0.1",
  launch.browser = TRUE
)
```

### **🎯 Method 2: Run Multiple Apps**

#### **Using Your Script:**
```bash
cd /Users/justin/ML
./INTERVIEW_START.sh
```

#### **Manual Multiple Runs:**
```bash
# Clinical Data Viewer
R -e "shiny::runApp('ShinyApps/ClinicalDataViewer/', port=3839)" &

# Regulatory Tracker
R -e "shiny::runApp('ShinyApps/RegulatoryTracker/', port=3840)" &

# SAS to R Workflow
R -e "shiny::runApp('ShinyApps/SAS2RWorkflow/', port=3841)" &

# HPC Dashboard
R -e "shiny::runApp('ShinyApps/HPCDashboard/', port=3842)" &
```

### **🎯 Method 3: RStudio IDE**

#### **Steps:**
1. **Open RStudio**
2. **Set Working Directory**:
   - Go to `Session > Set Working Directory > Choose Directory`
   - Navigate to `/Users/justin/ML/ShinyApps/ClinicalDataViewer/`
3. **Run App**:
   - Click "Run App" button (top right)
   - OR use `shiny::runApp()` in console

#### **Keyboard Shortcuts:**
- **Ctrl/Cmd + Enter**: Run current line/selection
- **Ctrl/Cmd + Shift + Enter**: Run current document
- **Ctrl/Cmd + 1**: Jump to console
- **Ctrl/Cmd + 2**: Jump to source

---

## 🔧 **Advanced Running Options**

### **🚀 Method 4: Custom Configuration**

#### **App with Custom Settings:**
```r
shiny::runApp(
  appDir = "ShinyApps/ClinicalDataViewer/",
  port = 8501,
  host = "0.0.0.0",  # Allow external access
  launch.browser = TRUE,
  display.mode = "normal",
  worker.id = NULL,
  reload.on.change = TRUE,
  quiet = FALSE
)
```

#### **Global Options:**
```r
# Set global Shiny options
options(
  shiny.port = 8501,
  shiny.host = "127.0.0.1",
  shiny.launch.browser = TRUE,
  shiny.autoreload = TRUE
)

# Now simple runApp() uses these defaults
shiny::runApp("ShinyApps/ClinicalDataViewer/")
```

### **🚀 Method 5: Docker Deployment**

#### **Dockerfile:**
```dockerfile
FROM rocker/shiny:4.2.0

# Install required packages
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'DT', 'plotly', 'dplyr', 'ggplot2'))"

# Copy app
COPY ShinyApps/ClinicalDataViewer/ /srv/shiny-server/ClinicalDataViewer/

# Expose port
EXPOSE 3838

# Run Shiny
CMD ["/usr/bin/shiny-server"]
```

#### **Build and Run:**
```bash
# Build image
docker build -t clinical-viewer .

# Run container
docker run -d -p 3838:3838 clinical-viewer
```

---

## 🌐 **Production Deployment**

### **🎯 Method 6: Posit Connect**

#### **Setup:**
```r
# Install rsconnect
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

#### **Command Line:**
```bash
# Deploy using rsconnect CLI
rsconnect deploy \
  --app-dir ShinyApps/ClinicalDataViewer/ \
  --name clinical-data-viewer \
  --account posit-connect
```

### **🎯 Method 7: Shiny Server**

#### **Installation (Ubuntu):**
```bash
# Install R
sudo apt-get update
sudo apt-get install r-base r-base-dev

# Install Shiny Server
sudo apt-get install gdebi-core
wget https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-1.5.20.1002-amd64.deb
sudo gdebi shiny-server-1.5.20.1002-amd64.deb

# Copy apps
sudo cp -r ShinyApps/* /srv/shiny-server/
sudo chown -R shiny:shiny /srv/shiny-server/

# Restart server
sudo systemctl restart shiny-server
```

#### **Access:**
- **URL**: `http://your-server:3838/ClinicalDataViewer/`
- **Admin**: `http://your-server:3838/`

---

## 🛠️ **Troubleshooting Common Issues**

### **🔧 Port Already in Use**

#### **Find Process Using Port:**
```bash
# Find process using port 3838
lsof -ti:3838

# Kill process
kill -9 [process-id]

# Or kill all R processes
pkill -f R
```

#### **Use Different Port:**
```bash
R -e "shiny::runApp('ShinyApps/ClinicalDataViewer/', port=8501)"
```

### **🔧 Package Not Found**

#### **Install Missing Packages:**
```r
# Set CRAN mirror
options(repos = c(CRAN = 'https://cran.rstudio.com/'))

# Install required packages
packages <- c('shiny', 'shinydashboard', 'DT', 'plotly', 'dplyr', 'ggplot2')
for(pkg in packages) {
  if(!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg)
  }
}
```

#### **Install from Command Line:**
```bash
R -e "options(repos = c(CRAN = 'https://cran.rstudio.com/')); install.packages(c('shiny', 'shinydashboard', 'DT', 'plotly', 'dplyr', 'ggplot2'))"
```

### **🔧 Permission Issues**

#### **File Permissions:**
```bash
# Make scripts executable
chmod +x INTERVIEW_START.sh
chmod +x START_APPS.sh

# Check file permissions
ls -la *.sh
```

### **🔧 R Version Issues**

#### **Check R Version:**
```bash
R --version
```

#### **Update Packages:**
```r
# Update all packages
update.packages()

# Update specific package
install.packages("shiny", repos = "https://cran.rstudio.com/")
```

---

## 📱 **Accessing Your Apps**

### **🌐 Local Access URLs**

#### **Single App:**
- **Default**: `http://127.0.0.1:3838`
- **Custom Port**: `http://127.0.0.1:8501`

#### **Multiple Apps (Your Script):**
- **Clinical Data Viewer**: `http://127.0.0.1:3839`
- **Regulatory Tracker**: `http://127.0.0.1:3840`
- **SAS to R Workflow**: `http://127.0.0.1:3841`
- **HPC Dashboard**: `http://127.0.0.1:3842`

### **🌐 External Access**

#### **Allow External Connections:**
```r
shiny::runApp(
  appDir = "ShinyApps/ClinicalDataViewer/",
  host = "0.0.0.0",  # Allow external access
  port = 8501
)
```

#### **Access from Other Devices:**
- **Find your IP**: `ifconfig` or `ip addr`
- **Access**: `http://your-ip:8501`

---

## 🎯 **Best Practices**

### **🚀 Development Workflow**

#### **1. Development Mode:**
```r
# Enable auto-reload
shiny::runApp(reload.on.change = TRUE)

# Enable reactlog for debugging
shiny::reactlog::reactlog_enable()
```

#### **2. Production Mode:**
```r
# Disable auto-reload
shiny::runApp(reload.on.change = FALSE)

# Set production mode
options(shiny.reactlog = FALSE)
```

### **🚀 Performance Optimization**

#### **Caching:**
```r
# Cache expensive computations
library(memoise)

expensive_function <- memoise(function(input) {
  # Expensive computation
  Sys.sleep(2)
  return(result)
})
```

#### **Async Processing:**
```r
library(promises)
library(future)
plan(multisession)

# Async reactive
output$plot <- renderPlot({
  future({
    # Heavy computation
    create_plot()
  })
})
```

---

## 📊 **Quick Reference Commands**

### **🎯 Essential Commands:**
```bash
# Run single app
cd /Users/justin/ML && R -e "shiny::runApp('ShinyApps/ClinicalDataViewer/')"

# Run multiple apps
cd /Users/justin/ML && ./INTERVIEW_START.sh

# Kill all R processes
pkill -f R

# Check running apps
ps aux | grep R

# Find port usage
lsof -i :3838
```

### **🎯 R Console Commands:**
```r
# Basic run
shiny::runApp()

# Custom port
shiny::runApp(port = 8501)

# External access
shiny::runApp(host = "0.0.0.0")

# Production mode
shiny::runApp(reload.on.change = FALSE)
```

---

## 🎯 **Your Portfolio Apps Quick Start**

### **🚀 Easiest Method:**
```bash
cd /Users/justin/ML
./INTERVIEW_START.sh
```

### **🚀 Individual Apps:**
```bash
# Clinical Data Viewer
R -e "shiny::runApp('ShinyApps/ClinicalDataViewer/', port=3839, launch.browser=TRUE)"

# Regulatory Tracker  
R -e "shiny::runApp('ShinyApps/RegulatoryTracker/', port=3840, launch.browser=TRUE)"

# SAS to R Workflow
R -e "shiny::runApp('ShinyApps/SAS2RWorkflow/', port=3841, launch.browser=TRUE)"

# HPC Dashboard
R -e "shiny::runApp('ShinyApps/HPCDashboard/', port=3842, launch.browser=TRUE)"
```

### **🎯 Access URLs:**
- **Clinical Data Viewer**: http://127.0.0.1:3839
- **Regulatory Tracker**: http://127.0.0.1:3840  
- **SAS to R Workflow**: http://127.0.0.1:3841
- **HPC Dashboard**: http://127.0.0.1:3842

Choose the method that works best for you - the automated script is easiest for interviews, while individual commands give you more control!
