# VS Code Shiny Development Setup Guide

## 🚀 **Quick Setup Overview**

VS Code is an excellent alternative to RStudio for Shiny development with better performance, extensions, and integration capabilities.

---

## 📦 **Step 1: Install VS Code**

### **Download and Install:**
1. **Download**: https://code.visualstudio.com/
2. **Install**: Follow installation instructions for your OS
3. **Launch**: Open VS Code

---

## 🔧 **Step 2: Install R Extension**

### **Primary R Extension:**
1. **Open Extensions**: `Ctrl+Shift+X` (or `Cmd+Shift+X` on Mac)
2. **Search**: "R"
3. **Install**: **R** by Yuki Ueda (REditorSupport)

#### **Alternative R Extensions:**
- **R** by Yuki Ueda (REditorSupport) - **Primary choice**
- **R LSP Client** by REditorSupport - Language Server Protocol
- **R Debugger** by REditorSupport - Debugging capabilities

---

## 🎯 **Step 3: Configure R Path**

### **Automatic Detection:**
VS Code usually detects R automatically. If not:

#### **Windows:**
```json
{
    "r.rterm.windows": "C:\\Program Files\\R\\R-4.2.2\\bin\\x64\\R.exe",
    "r.lsp.enabled": true,
    "r.lsp.args": ["--quiet", "--no-save"]
}
```

#### **macOS:**
```json
{
    "r.rterm.mac": "/usr/local/bin/R",
    "r.lsp.enabled": true,
    "r.lsp.args": ["--quiet", "--no-save"]
}
```

#### **Linux:**
```json
{
    "r.rterm.linux": "/usr/bin/R",
    "r.lsp.enabled": true,
    "r.lsp.args": ["--quiet", "--no-save"]
}
```

### **Access Settings:**
1. **Open Settings**: `Ctrl+,` (or `Cmd+,` on Mac)
2. **Search**: "r.rterm"
3. **Set Path**: Enter your R installation path

---

## 🎨 **Step 4: Install Shiny-Specific Extensions**

### **Essential Extensions for Shiny:**

#### **1. Shiny Extension**
- **Name**: Shiny
- **Publisher**: RStudio
- **Features**: Shiny app development support

#### **2. R Markdown**
- **Name**: R Markdown**
- **Publisher**: RStudio
- **Features**: RMD file support

#### **3. HTML/CSS Support**
- **Name**: HTML CSS Support**
- **Publisher**: ECMA
- **Features**: HTML/CSS syntax highlighting

#### **4. JavaScript Support**
- **Name**: JavaScript**
- **Publisher**: Microsoft
- **Features**: JavaScript syntax highlighting

#### **5. Live Preview**
- **Name**: Live Preview**
- **Publisher**: Microsoft
- **Features**: Live HTML preview

---

## 🛠️ **Step 5: Configure VS Code for Shiny**

### **Workspace Settings:**

#### **Create `.vscode/settings.json`:**
```json
{
    "r.rterm.windows": "C:\\Program Files\\R\\R-4.2.2\\bin\\x64\\R.exe",
    "r.rterm.mac": "/usr/local/bin/R",
    "r.rterm.linux": "/usr/bin/R",
    "r.lsp.enabled": true,
    "r.lsp.args": ["--quiet", "--no-save"],
    "r.lsp.diagnostics": true,
    "r.lsp.debug": true,
    "r.bracketedPaste": true,
    "r.session.watchers": [
        "~/.Rhistory",
        "~/.RData",
        "~/.Rprofile"
    ],
    "r.alwaysUseActiveTerminal": true,
    "r.source.encoding": "UTF-8",
    "r.plot.useHttpgd": true,
    "files.associations": {
        "*.Rmd": "rmd",
        "*.R": "r"
    },
    "emmet.includeLanguages": {
        "rmd": "html"
    }
}
```

---

## 🚀 **Step 6: Create Shiny Project Structure**

### **Project Setup:**

#### **1. Create Project Folder:**
```bash
mkdir /Users/justin/ML/ShinyVSCode
cd /Users/justin/ML/ShinyVSCode
```

#### **2. Create VS Code Workspace:**
```bash
# Create .vscode folder
mkdir .vscode

# Create settings.json
touch .vscode/settings.json

# Create launch.json for debugging
touch .vscode/launch.json
```

#### **3. Basic Shiny App Structure:**
```
ShinyVSCode/
├── app.R
├── www/
│   ├── custom.css
│   └── custom.js
├── data/
├── .vscode/
│   ├── settings.json
│   └── launch.json
└── README.md
```

---

## 🎯 **Step 7: Running Shiny Apps in VS Code**

### **Method 1: Using Terminal**

#### **Open Integrated Terminal:**
1. **Terminal**: `Ctrl+`` (backtick) or `Ctrl+Shift+``
2. **Navigate**: `cd /Users/justin/ML/ShinyApps/ClinicalDataViewer/`
3. **Run App**: 
```r
R
> shiny::runApp()
```

### **Method 2: Using Code Runner**

#### **Install Code Runner Extension:**
1. **Extensions**: `Ctrl+Shift+X`
2. **Search**: "Code Runner"
3. **Install**: Code Runner by Jun Han

#### **Configure for R:**
```json
{
    "code-runner.executorMap": {
        "r": "Rscript",
        "rmd": "Rscript -e \"rmarkdown::render('$fileName')\""
    },
    "code-runner.runInTerminal": true,
    "code-runner.saveFileBeforeRun": true
}
```

### **Method 3: Using Tasks**

#### **Create `.vscode/tasks.json`:**
```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Run Shiny App",
            "type": "shell",
            "command": "R",
            "args": ["-e", "shiny::runApp()"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Run Shiny App on Port 8501",
            "type": "shell",
            "command": "R",
            "args": ["-e", "shiny::runApp(port=8501, launch.browser=TRUE)"],
            "group": "build"
        }
    ]
}
```

#### **Run Tasks:**
1. **Command Palette**: `Ctrl+Shift+P`
2. **Search**: "Tasks: Run Task"
3. **Select**: "Run Shiny App"

---

## 🎨 **Step 8: Shiny Development Features**

### **Syntax Highlighting:**
- **R files**: `.R` extension
- **R Markdown**: `.Rmd` extension
- **Shiny UI**: HTML/CSS/JS support

### **Code Completion:**
- **R functions**: Auto-completion for base R and packages
- **Shiny functions**: `shiny::` functions completion
- **HTML tags**: UI component suggestions

### **Debugging:**
- **Breakpoints**: Set breakpoints in R code
- **Variable inspection**: View variable values
- **Console access**: Interactive R console

---

## 🚀 **Step 9: Advanced Features**

### **Live Preview for HTML:**
```json
{
    "livePreview.defaultPreviewPath": "/index.html",
    "livePreview.portNumber": 5500
}
```

### **Git Integration:**
- **Source Control**: Built-in Git support
- **Diff view**: Visual file differences
- **Commit**: Direct commit from VS Code

### **Multi-file Editing:**
- **Split editor**: View multiple files side-by-side
- **Tabs**: Easy navigation between files
- **Search**: Global search across project

---

## 🛠️ **Step 10: Shiny-Specific Shortcuts**

### **Essential Shortcuts:**

#### **General:**
- `Ctrl+P`: Quick file open
- `Ctrl+Shift+P`: Command palette
- `Ctrl+``: Toggle terminal
- `Ctrl+Shift+E`: Toggle explorer

#### **R Specific:**
- `Ctrl+Enter`: Run current line/selection
- `Ctrl+Alt+Enter`: Run current file
- `Ctrl+Shift+Enter`: Run all code

#### **Shiny Development:**
- `Ctrl+Shift+P` → "Tasks: Run Task" → "Run Shiny App"
- `Ctrl+Shift+P` → "R: Run Source"

---

## 🎯 **Step 11: Debugging Shiny Apps**

### **Setup Debugging:**

#### **Install R Debugger Extension:**
1. **Extensions**: Search "R Debugger"
2. **Install**: R Debugger by REditorSupport

#### **Create `.vscode/launch.json`:**
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug R File",
            "type": "R",
            "request": "launch",
            "program": "${file}",
            "debugMode": true,
            "args": []
        },
        {
            "name": "Debug Shiny App",
            "type": "R",
            "request": "launch",
            "program": "${workspaceFolder}/app.R",
            "debugMode": true,
            "args": [],
            "cwd": "${workspaceFolder}",
            "env": {
                "R_DEBUG": "1"
            }
        }
    ]
}
```

#### **Debug Shiny App:**
1. **Set breakpoints**: Click in gutter next to line numbers
2. **Start debugging**: `F5` or Run → Start Debugging
3. **Select configuration**: "Debug Shiny App"
4. **Debug**: Use debug toolbar (continue, step over, step into)

---

## 📱 **Step 12: Testing Your Setup**

### **Create Test Shiny App:**

#### **Create `test_app.R`:**
```r
# Test Shiny App for VS Code
library(shiny)

# Define UI
ui <- fluidPage(
  titlePanel("VS Code Shiny Test"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("obs", "Number of observations:", 1, 100, 50),
      actionButton("go", "Go!")
    ),
    mainPanel(
      plotOutput("distPlot"),
      verbatimTextOutput("summary")
    )
  )
)

# Define server logic
server <- function(input, output) {
  output$distPlot <- renderPlot({
    hist(rnorm(input$obs), main = "Random Numbers")
  })
  
  output$summary <- renderText({
    paste("Generated", input$obs, "random numbers")
  })
}

# Run the application
shinyApp(ui = ui, server = server)
```

#### **Run Test App:**
1. **Open**: `test_app.R` in VS Code
2. **Terminal**: `Ctrl+`` 
3. **Navigate**: `cd /path/to/your/project`
4. **Run**: `R` then `shiny::runApp()`

---

## 🚀 **Step 13: Productivity Tips**

### **Workspace Management:**
- **Multi-root workspaces**: Work on multiple projects
- **Folder structure**: Organize projects logically
- **Settings per project**: Project-specific configurations

### **Code Snippets:**
```json
{
    "Shiny App Template": {
        "prefix": "shiny-app",
        "body": [
            "library(shiny)",
            "",
            "# Define UI",
            "ui <- fluidPage(",
            "  titlePanel(\"${1:App Title}\"),",
            "  sidebarLayout(",
            "    sidebarPanel(",
            "      ${2:# UI inputs}",
            "    ),",
            "    mainPanel(",
            "      ${3:# UI outputs}",
            "    )",
            "  )",
            ")",
            "",
            "# Define server logic",
            "server <- function(input, output) {",
            "  ${4:# Server logic}",
            "}",
            "",
            "# Run the application",
            "shinyApp(ui = ui, server = server)"
        ],
        "description": "Create a basic Shiny app template"
    }
}
```

### **Recommended Themes:**
- **Material Theme**: Modern dark theme
- **One Dark Pro**: Popular dark theme
- **GitHub Light**: Clean light theme
- **Monokai**: Classic dark theme

---

## 🎯 **Step 14: Your Portfolio Apps in VS Code**

### **Open Your Portfolio:**
```bash
# Open your entire portfolio in VS Code
code /Users/justin/ML/
```

### **Navigate to Apps:**
1. **Explorer**: `Ctrl+Shift+E`
2. **Navigate**: `ShinyApps/ClinicalDataViewer/`
3. **Open**: `app.R`

### **Run Your Apps:**
1. **Terminal**: `Ctrl+``
2. **Navigate**: `cd ShinyApps/ClinicalDataViewer/`
3. **Run**: `R` then `shiny::runApp()`

---

## 🛠️ **Troubleshooting**

### **Common Issues:**

#### **R Not Found:**
```bash
# Check R installation
which R
R --version

# Update VS Code settings
"r.rterm.mac": "/usr/local/bin/R"  # Update path
```

#### **Extensions Not Working:**
1. **Reload VS Code**: `Ctrl+Shift+P` → "Developer: Reload Window"
2. **Check Extensions**: Ensure R extension is enabled
3. **Update Extensions**: Check for updates

#### **Shiny App Not Running:**
1. **Check Working Directory**: Ensure correct path
2. **Check Packages**: Install required packages
3. **Check Port**: Use different port if needed

---

## 📱 **Quick Start Summary**

### **One-Command Setup:**
```bash
# Install VS Code (if not installed)
# Install R extension from marketplace
# Open your portfolio
code /Users/justin/ML/

# Navigate to app and run
# Terminal → cd ShinyApps/ClinicalDataViewer/
# R → shiny::runApp()
```

### **Essential Extensions:**
1. **R** by Yuki Ueda
2. **R Debugger** by REditorSupport
3. **Code Runner** by Jun Han
4. **Live Preview** by Microsoft

### **Key Benefits:**
- **Better performance** than RStudio
- **More extensions** and customization
- **Better Git integration**
- **Multi-language support**
- **Modern interface**

VS Code provides a powerful, modern environment for Shiny development with excellent performance and extensibility!
