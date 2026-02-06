# Data Integration & Processing Hub
# Combines: SAS to R Workflow, Pharmaverse Integration, HPC Dashboard, LLM Analytics
# Senior Shiny Developer Portfolio - Merged Application

library(shiny)
library(shinydashboard)
library(plotly)
library(DT)
library(dplyr)
library(ggplot2)

# ============================================================================
# DATA GENERATION FUNCTIONS
# ============================================================================

# Generate SAS Migration Data
generate_sas_data <- function() {
  set.seed(123)
  data.frame(
    SAS_Program = c("dm_analysis.sas", "vs_tables.sas", "ae_summary.sas", "efficacy_plots.sas", "lab_shifts.sas"),
    R_Script = c("dm_analysis.R", "vs_tables.R", "ae_summary.R", "efficacy_plots.R", "lab_shifts.R"),
    Status = sample(c("Completed", "In Progress", "Pending"), 5, replace = TRUE),
    Validation = sample(c("Pass", "Pass", "Pending"), 5, replace = TRUE),
    Lines_SAS = sample(100:500, 5),
    Lines_R = sample(80:400, 5),
    stringsAsFactors = FALSE
  )
}

# Generate Pharmaverse Data
generate_pharmaverse_data <- function() {
  set.seed(456)
  data.frame(
    Dataset = c("ADSL", "ADAE", "ADLB", "ADVS", "ADTTE"),
    Package = c("admiral", "admiral", "admiral", "admiral", "admiral"),
    Records = sample(100:1000, 5),
    Variables = sample(20:50, 5),
    Status = rep("Validated", 5),
    stringsAsFactors = FALSE
  )
}

# Generate HPC Metrics
generate_hpc_data <- function() {
  set.seed(789)
  data.frame(
    Node = paste0("node", 1:8),
    CPU_Usage = sample(30:90, 8),
    Memory_Usage = sample(40:85, 8),
    GPU_Usage = sample(0:100, 8),
    Jobs_Running = sample(1:10, 8),
    Status = sample(c("Active", "Active", "Active", "Idle"), 8, replace = TRUE),
    stringsAsFactors = FALSE
  )
}

# ============================================================================
# LLM INTEGRATION PLACEHOLDERS
# TODO: Replace these functions with real LLM API calls
# See instructions in the "LLM Setup" tab for integration details
# ============================================================================

# Placeholder: Analyze document with LLM
analyze_document_llm <- function(document_text, api_key = NULL) {
  # TODO: Replace with real LLM API call
  # Example for OpenAI GPT-4:
  # library(httr)
  # library(jsonlite)
  # 
  # response <- POST(
  #   url = "https://api.openai.com/v1/chat/completions",
  #   add_headers(Authorization = paste("Bearer", api_key)),
  #   body = toJSON(list(
  #     model = "gpt-4",
  #     messages = list(list(role = "user", content = paste(
  #       "Analyze this clinical document and extract:",
  #       "1. Sentiment (Positive/Neutral/Negative)",
  #       "2. Key medical terms",
  #       "3. Document category",
  #       document_text
  #     )))
  #   ), auto_unbox = TRUE),
  #   content_type_json()
  # )
  # 
  # result <- content(response)
  # return(result$choices[[1]]$message$content)
  
  # MOCK RESPONSE (remove when implementing real API)
  set.seed(999)
  list(
    sentiment = sample(c("Positive", "Neutral", "Negative"), 1),
    key_terms = sample(5:20, 1),
    category = sample(c("Protocol", "CSR", "SAP", "ICF"), 1)
  )
}

# Placeholder: Batch process documents
process_documents_batch <- function(documents, use_real_llm = FALSE) {
  # TODO: Set use_real_llm = TRUE after configuring API keys
  
  if (use_real_llm) {
    # Real LLM processing would go here
    # api_key <- Sys.getenv("OPENAI_API_KEY")  # Or ANTHROPIC_API_KEY, etc.
    # results <- lapply(documents, function(doc) {
    #   analyze_document_llm(doc, api_key)
    # })
    stop("Real LLM integration not yet configured. See LLM Setup tab for instructions.")
  }
  
  # Mock data for demonstration
  data.frame(
    Document = paste0("Protocol_", 1:10),
    Category = sample(c("Protocol", "CSR", "SAP", "ICF"), 10, replace = TRUE),
    Text_Length = sample(1000:5000, 10),
    Sentiment = sample(c("Positive", "Neutral", "Negative"), 10, replace = TRUE),
    Key_Terms = sample(5:20, 10),
    Analyzed = rep("Mock Data", 10),
    stringsAsFactors = FALSE
  )
}

# Generate LLM Analytics Data (currently using mock data)
generate_llm_data <- function() {
  process_documents_batch(NULL, use_real_llm = FALSE)
}

# ============================================================================
# UI
# ============================================================================

ui <- dashboardPage(
  dashboardHeader(title = "Data Integration & Processing Hub"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("SAS to R Migration", tabName = "sas", icon = icon("exchange")),
      menuItem("Pharmaverse Integration", tabName = "pharmaverse", icon = icon("cubes")),
      menuItem("HPC Dashboard", tabName = "hpc", icon = icon("server")),
      menuItem("LLM Analytics", tabName = "llm", icon = icon("brain")),
      menuItem("LLM Setup Guide", tabName = "llm_setup", icon = icon("book")),
      menuItem("Simulated Data Info", tabName = "data_info", icon = icon("database"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Overview Tab
      tabItem(tabName = "overview",
        h2("Data Integration & Processing Hub"),
        fluidRow(
          valueBoxOutput("totalProjects"),
          valueBoxOutput("migrationProgress"),
          valueBoxOutput("hpcUtilization")
        ),
        fluidRow(
          box(title = "Hub Components", width = 12, solidHeader = TRUE, status = "primary",
              tags$ul(
                tags$li(tags$b("SAS to R Migration:"), "Legacy SAS code migration and validation"),
                tags$li(tags$b("Pharmaverse Integration:"), "Admiral package and CDISC ADaM datasets"),
                tags$li(tags$b("HPC Dashboard:"), "High-performance computing cluster monitoring"),
                tags$li(tags$b("LLM Analytics:"), "AI-powered clinical document analysis")
              )
          )
        )
      ),
      
      # SAS Migration Tab
      tabItem(tabName = "sas",
        h2("SAS to R Workflow Migration"),
        fluidRow(
          box(title = "Migration Status", width = 12,
              DTOutput("sasTable"))
        ),
        fluidRow(
          box(title = "Code Efficiency Comparison", width = 12,
              plotlyOutput("sasEfficiencyPlot"))
        )
      ),
      
      # Pharmaverse Tab
      tabItem(tabName = "pharmaverse",
        h2("Pharmaverse ADaM Integration"),
        fluidRow(
          box(title = "CDISC ADaM Datasets", width = 12,
              DTOutput("pharmaverseTable"))
        ),
        fluidRow(
          box(title = "Dataset Records", width = 6,
              plotlyOutput("adamRecordsPlot")),
          box(title = "Dataset Variables", width = 6,
              plotlyOutput("adamVariablesPlot"))
        )
      ),
      
      # HPC Dashboard Tab
      tabItem(tabName = "hpc",
        h2("HPC Cluster Monitor"),
        fluidRow(
          valueBoxOutput("activeNodes"),
          valueBoxOutput("avgCPU"),
          valueBoxOutput("totalJobs")
        ),
        fluidRow(
          box(title = "Node Status", width = 12,
              DTOutput("hpcTable"))
        ),
        fluidRow(
          box(title = "Resource Utilization", width = 12,
              plotlyOutput("hpcUtilizationPlot"))
        )
      ),
      
      # LLM Analytics Tab
      tabItem(tabName = "llm",
        h2("LLM-Powered Document Analytics"),
        fluidRow(
          box(title = "⚠️ Currently Using Mock Data", width = 12, status = "warning",
              p("This tab demonstrates LLM analytics capabilities with simulated data."),
              p("See the 'LLM Setup Guide' tab for instructions on integrating real LLM models.")
          )
        ),
        fluidRow(
          box(title = "Document Analysis", width = 12,
              DTOutput("llmTable"))
        ),
        fluidRow(
          box(title = "Document Categories", width = 6,
              plotlyOutput("llmCategoryPlot")),
          box(title = "Sentiment Analysis", width = 6,
              plotlyOutput("llmSentimentPlot"))
        )
      ),
      
      # LLM Setup Guide Tab
      tabItem(tabName = "llm_setup",
        h2("LLM Integration Setup Guide"),
        
        fluidRow(
          box(title = "Overview", width = 12, status = "primary", solidHeader = TRUE,
              p("This app includes placeholder functions for LLM integration. Follow these steps to connect real LLM models for document analysis.")
          )
        ),
        
        fluidRow(
          box(title = "Option 1: OpenAI GPT-4 (Recommended)", width = 12, solidHeader = TRUE,
              h4("Setup Steps:"),
              tags$ol(
                tags$li("Get API key from", tags$a(href = "https://platform.openai.com/api-keys", "OpenAI Platform", target = "_blank")),
                tags$li("Install required R package:", tags$code("install.packages(c('httr', 'jsonlite'))")),
                tags$li("Set environment variable:", tags$code("Sys.setenv(OPENAI_API_KEY = 'your-key-here')")),
                tags$li("In app.R, change", tags$code("use_real_llm = FALSE"), "to", tags$code("use_real_llm = TRUE"))
              ),
              h4("Example Code:"),
              tags$pre(
'library(httr)
library(jsonlite)

analyze_with_openai <- function(text, api_key) {
  response <- POST(
    url = "https://api.openai.com/v1/chat/completions",
    add_headers(Authorization = paste("Bearer", api_key)),
    body = toJSON(list(
      model = "gpt-4",
      messages = list(list(
        role = "user", 
        content = paste("Analyze this clinical document:", text)
      ))
    ), auto_unbox = TRUE),
    content_type_json()
  )
  return(content(response))
}')
          )
        ),
        
        fluidRow(
          box(title = "Option 2: Anthropic Claude", width = 12, solidHeader = TRUE,
              h4("Setup Steps:"),
              tags$ol(
                tags$li("Get API key from", tags$a(href = "https://console.anthropic.com/", "Anthropic Console", target = "_blank")),
                tags$li("Install package:", tags$code("install.packages('httr')")),
                tags$li("Set environment variable:", tags$code("Sys.setenv(ANTHROPIC_API_KEY = 'your-key-here')"))
              ),
              h4("Example Code:"),
              tags$pre(
'analyze_with_claude <- function(text, api_key) {
  response <- POST(
    url = "https://api.anthropic.com/v1/messages",
    add_headers(
      "x-api-key" = api_key,
      "anthropic-version" = "2023-06-01"
    ),
    body = toJSON(list(
      model = "claude-3-sonnet-20240229",
      messages = list(list(
        role = "user",
        content = paste("Analyze:", text)
      )),
      max_tokens = 1024
    ), auto_unbox = TRUE),
    content_type_json()
  )
  return(content(response))
}')
          )
        ),
        
        fluidRow(
          box(title = "Option 3: Local LLM (Ollama)", width = 12, solidHeader = TRUE,
              h4("Setup Steps:"),
              tags$ol(
                tags$li("Install", tags$a(href = "https://ollama.ai/", "Ollama", target = "_blank")),
                tags$li("Pull a model:", tags$code("ollama pull llama2")),
                tags$li("Run locally - no API key needed!")
              ),
              h4("Example Code:"),
              tags$pre(
'analyze_with_ollama <- function(text) {
  response <- POST(
    url = "http://localhost:11434/api/generate",
    body = toJSON(list(
      model = "llama2",
      prompt = paste("Analyze this document:", text)
    ), auto_unbox = TRUE),
    content_type_json()
  )
  return(content(response))
}')
          )
        ),
        
        fluidRow(
          box(title = "Option 4: R Text Analysis (No LLM Required)", width = 12, solidHeader = TRUE,
              h4("Use R packages for basic NLP:"),
              tags$pre(
'install.packages(c("tidytext", "textdata", "syuzhet"))

library(tidytext)
library(syuzhet)

# Sentiment analysis
sentiment <- get_sentiment(document_text, method = "syuzhet")

# Topic modeling
library(topicmodels)
dtm <- DocumentTermMatrix(corpus)
lda_model <- LDA(dtm, k = 5)')
          )
        ),
        
        fluidRow(
          box(title = "Implementation Checklist", width = 12, status = "info", solidHeader = TRUE,
              tags$ol(
                tags$li("Choose your LLM provider (OpenAI, Anthropic, Ollama, or R packages)"),
                tags$li("Obtain API keys (if using cloud provider)"),
                tags$li("Update the", tags$code("analyze_document_llm()"), "function in app.R"),
                tags$li("Set", tags$code("use_real_llm = TRUE"), "in", tags$code("process_documents_batch()")),
                tags$li("Add error handling and rate limiting"),
                tags$li("Test with sample documents"),
                tags$li("Deploy to production")
              )
          )
        ),
        
        fluidRow(
          box(title = "Cost Considerations", width = 12, status = "warning",
              tags$ul(
                tags$li(tags$b("OpenAI GPT-4:"), "$0.03 per 1K input tokens, $0.06 per 1K output tokens"),
                tags$li(tags$b("Anthropic Claude:"), "$0.015 per 1K input tokens, $0.075 per 1K output tokens"),
                tags$li(tags$b("Ollama (Local):"), "Free! Runs on your hardware"),
                tags$li(tags$b("R Packages:"), "Free! Limited capabilities")
              )
          )
        )
      ),
      
      # Data Info Tab
      tabItem(tabName = "data_info",
        h2("Simulated Data Methodology"),
        
        fluidRow(
          box(title = "Purpose of Simulated Data", width = 12, status = "primary", solidHeader = TRUE,
              p("This application uses simulated data for demonstration and portfolio purposes. All data generation uses", 
                tags$code("set.seed()"), "to ensure consistent results across runs."),
              p(tags$b("Why Simulated Data?"), "Allows demonstration of advanced analytics capabilities while maintaining data privacy and avoiding regulatory constraints.")
          )
        ),
        
        fluidRow(
          box(title = "SAS Migration Data", width = 12, solidHeader = TRUE,
              h4("Generation Method:"),
              tags$pre(
'generate_sas_data <- function() {
  set.seed(123)  # Ensures reproducibility
  data.frame(
    SAS_Program = c("dm_analysis.sas", "vs_tables.sas", ...),
    R_Script = c("dm_analysis.R", "vs_tables.R", ...),
    Status = sample(c("Completed", "In Progress", "Pending"), 5, replace = TRUE),
    Lines_SAS = sample(100:500, 5),  # Realistic code lengths
    Lines_R = sample(80:400, 5)      # R typically 20% shorter
  )
}'),
              h4("How It Mimics Real Data:"),
              tags$ul(
                tags$li("Program names follow actual SAS/R naming conventions (dm_analysis, vs_tables)"),
                tags$li("Line counts reflect realistic code complexity (100-500 lines)"),
                tags$li("R code is typically 20% shorter than equivalent SAS (efficiency gain)"),
                tags$li("Status tracking mirrors real migration project workflows")
              ),
              h4("Current Data:"),
              DTOutput("dataInfoSAS")
          )
        ),
        
        fluidRow(
          box(title = "Pharmaverse ADaM Data", width = 12, solidHeader = TRUE,
              h4("Generation Method:"),
              tags$pre(
'generate_pharmaverse_data <- function() {
  set.seed(456)
  data.frame(
    Dataset = c("ADSL", "ADAE", "ADLB", "ADVS", "ADTTE"),  # Standard CDISC ADaM datasets
    Package = c("admiral", "admiral", ...),
    Records = sample(100:1000, 5),     # Typical trial sizes
    Variables = sample(20:50, 5)       # Standard variable counts
  )
}'),
              h4("How It Mimics Real Data:"),
              tags$ul(
                tags$li(tags$b("ADSL:"), "Subject-Level Analysis Dataset - baseline demographics"),
                tags$li(tags$b("ADAE:"), "Adverse Events Analysis Dataset - safety monitoring"),
                tags$li(tags$b("ADLB:"), "Laboratory Results Analysis Dataset - biomarkers"),
                tags$li(tags$b("ADVS:"), "Vital Signs Analysis Dataset - physiological measures"),
                tags$li(tags$b("ADTTE:"), "Time-to-Event Analysis Dataset - survival analysis"),
                tags$li("Record counts (100-1000) match typical Phase II/III trial sizes"),
                tags$li("Variable counts (20-50) align with CDISC ADaM standards")
              ),
              h4("Current Data:"),
              DTOutput("dataInfoPharmaverse")
          )
        ),
        
        fluidRow(
          box(title = "HPC Cluster Metrics", width = 12, solidHeader = TRUE,
              h4("Generation Method:"),
              tags$pre(
'generate_hpc_data <- function() {
  set.seed(789)
  data.frame(
    Node = paste0("node", 1:8),
    CPU_Usage = sample(30:90, 8),      # Realistic CPU loads
    Memory_Usage = sample(40:85, 8),   # Realistic memory usage
    GPU_Usage = sample(0:100, 8),      # Variable GPU utilization
    Jobs_Running = sample(1:10, 8)     # Concurrent job counts
  )
}'),
              h4("How It Mimics Real Data:"),
              tags$ul(
                tags$li("8-node cluster mimics typical pharma HPC infrastructure"),
                tags$li("CPU usage (30-90%) reflects realistic workload patterns"),
                tags$li("Memory usage (40-85%) avoids edge cases (too low/high)"),
                tags$li("GPU usage variability shows mixed CPU/GPU workloads"),
                tags$li("Jobs per node (1-10) matches real scheduler behavior")
              ),
              h4("Current Data:"),
              DTOutput("dataInfoHPC")
          )
        ),
        
        fluidRow(
          box(title = "LLM Document Analysis", width = 12, solidHeader = TRUE,
              h4("Generation Method:"),
              tags$pre(
'analyze_document_llm <- function(document_text, api_key = NULL) {
  set.seed(999)
  list(
    sentiment = sample(c("Positive", "Neutral", "Negative"), 1),
    key_terms = sample(5:20, 1),
    category = sample(c("Protocol", "CSR", "SAP", "ICF"), 1)
  )
}'),
              h4("How It Mimics Real Data:"),
              tags$ul(
                tags$li(tags$b("Document Categories:"), "Protocol, CSR (Clinical Study Report), SAP (Statistical Analysis Plan), ICF (Informed Consent)"),
                tags$li(tags$b("Sentiment:"), "Positive/Neutral/Negative reflects document tone"),
                tags$li(tags$b("Key Terms:"), "5-20 terms matches typical clinical document complexity"),
                tags$li("Currently MOCK - no real LLM API calls"),
                tags$li("Architecture ready for OpenAI, Anthropic, or Ollama integration")
              ),
              h4("Current Data:"),
              DTOutput("dataInfoLLM")
          )
        ),
        
        fluidRow(
          box(title = "Converting to Real Data", width = 12, status = "success", solidHeader = TRUE,
              h4("Steps to Use Production Data:"),
              tags$ol(
                tags$li(tags$b("SAS Migration:"), "Replace with read_excel('migration_tracker.xlsx')"),
                tags$li(tags$b("Pharmaverse:"), "Use actual admiral package outputs from SDTM"),
                tags$li(tags$b("HPC Metrics:"), "Connect via SSH to cluster and parse squeue/sinfo"),
                tags$li(tags$b("LLM Analytics:"), "Add API keys and set use_real_llm = TRUE")
              ),
              p("The current data generation functions can be completely replaced with database queries, API calls, or file reads without changing any UI code.")
          )
        )
      )
    )
  )
)

# ============================================================================
# SERVER
# ============================================================================

server <- function(input, output, session) {
  
  # Generate all data
  sas_data <- reactiveVal(generate_sas_data())
  pharmaverse_data <- reactiveVal(generate_pharmaverse_data())
  hpc_data <- reactiveVal(generate_hpc_data())
  llm_data <- reactiveVal(generate_llm_data())
  
  # Overview Value Boxes
  output$totalProjects <- renderValueBox({
    valueBox(
      value = nrow(sas_data()),
      subtitle = "Migration Projects",
      icon = icon("project-diagram"),
      color = "blue"
    )
  })
  
  output$migrationProgress <- renderValueBox({
    completed <- sum(sas_data()$Status == "Completed")
    total <- nrow(sas_data())
    pct <- round(completed / total * 100)
    
    valueBox(
      value = paste0(pct, "%"),
      subtitle = "Migration Complete",
      icon = icon("tasks"),
      color = if(pct >= 80) "green" else "yellow"
    )
  })
  
  output$hpcUtilization <- renderValueBox({
    avg_cpu <- round(mean(hpc_data()$CPU_Usage))
    
    valueBox(
      value = paste0(avg_cpu, "%"),
      subtitle = "Avg CPU Usage",
      icon = icon("microchip"),
      color = if(avg_cpu < 80) "green" else "red"
    )
  })
  
  # SAS Migration Outputs
  output$sasTable <- renderDT({
    datatable(sas_data(), options = list(pageLength = 10, scrollX = TRUE))
  })
  
  output$sasEfficiencyPlot <- renderPlotly({
    data <- sas_data() %>%
      select(SAS_Program, Lines_SAS, Lines_R) %>%
      tidyr::pivot_longer(cols = c(Lines_SAS, Lines_R), names_to = "Language", values_to = "Lines")
    
    p <- ggplot(data, aes(x = SAS_Program, y = Lines, fill = Language)) +
      geom_bar(stat = "identity", position = "dodge") +
      labs(title = "Code Lines: SAS vs R", x = "Program", y = "Lines of Code") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p)
  })
  
  # Pharmaverse Outputs
  output$pharmaverseTable <- renderDT({
    datatable(pharmaverse_data(), options = list(dom = 't'))
  })
  
  output$adamRecordsPlot <- renderPlotly({
    p <- ggplot(pharmaverse_data(), aes(x = Dataset, y = Records, fill = Dataset)) +
      geom_bar(stat = "identity", show.legend = FALSE) +
      labs(title = "ADaM Dataset Records") +
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$adamVariablesPlot <- renderPlotly({
    p <- ggplot(pharmaverse_data(), aes(x = Dataset, y = Variables, fill = Dataset)) +
      geom_bar(stat = "identity", show.legend = FALSE) +
      labs(title = "ADaM Dataset Variables") +
      theme_minimal()
    
    ggplotly(p)
  })
  
  # HPC Outputs
  output$activeNodes <- renderValueBox({
    active <- sum(hpc_data()$Status == "Active")
    
    valueBox(
      value = active,
      subtitle = "Active Nodes",
      icon = icon("server"),
      color = "green"
    )
  })
  
  output$avgCPU <- renderValueBox({
    valueBox(
      value = paste0(round(mean(hpc_data()$CPU_Usage)), "%"),
      subtitle = "Avg CPU",
      icon = icon("microchip"),
      color = "blue"
    )
  })
  
  output$totalJobs <- renderValueBox({
    valueBox(
      value = sum(hpc_data()$Jobs_Running),
      subtitle = "Running Jobs",
      icon = icon("tasks"),
      color = "purple"
    )
  })
  
  output$hpcTable <- renderDT({
    datatable(hpc_data(), options = list(dom = 't'))
  })
  
  output$hpcUtilizationPlot <- renderPlotly({
    data <- hpc_data() %>%
      select(Node, CPU_Usage, Memory_Usage, GPU_Usage) %>%
      tidyr::pivot_longer(cols = c(CPU_Usage, Memory_Usage, GPU_Usage), 
                         names_to = "Resource", values_to = "Usage")
    
    p <- ggplot(data, aes(x = Node, y = Usage, fill = Resource)) +
      geom_bar(stat = "identity", position = "dodge") +
      labs(title = "HPC Resource Utilization", y = "Usage (%)") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p)
  })
  
  # LLM Outputs
  output$llmTable <- renderDT({
    datatable(llm_data(), options = list(pageLength = 10))
  })
  
  output$llmCategoryPlot <- renderPlotly({
    category_counts <- llm_data() %>%
      group_by(Category) %>%
      summarise(Count = n(), .groups = "drop")
    
    plot_ly(category_counts, labels = ~Category, values = ~Count, type = 'pie') %>%
      layout(title = "Document Categories")
  })
  
  output$llmSentimentPlot <- renderPlotly({
    sentiment_counts <- llm_data() %>%
      group_by(Sentiment) %>%
      summarise(Count = n(), .groups = "drop")
    
    p <- ggplot(sentiment_counts, aes(x = Sentiment, y = Count, fill = Sentiment)) +
      geom_bar(stat = "identity") +
      labs(title = "Sentiment Distribution") +
      theme_minimal()
    
    ggplotly(p)
  })
  
  # Data Info Outputs
  output$dataInfoSAS <- renderDT({
    datatable(sas_data(), 
              options = list(pageLength = 5, scrollX = TRUE),
              caption = "Current SAS migration tracking data (reproducible with set.seed(123))")
  })
  
  output$dataInfoPharmaverse <- renderDT({
    datatable(pharmaverse_data(), 
              options = list(pageLength = 5, scrollX = TRUE),
              caption = "Current Pharmaverse ADaM datasets (reproducible with set.seed(456))")
  })
  
  output$dataInfoHPC <- renderDT({
    datatable(hpc_data(), 
              options = list(pageLength = 8, scrollX = TRUE),
              caption = "Current HPC cluster metrics (reproducible with set.seed(789))")
  })
  
  output$dataInfoLLM <- renderDT({
    datatable(llm_data(), 
              options = list(pageLength = 10, scrollX = TRUE),
              caption = "Current LLM document analysis results (reproducible with set.seed(999))")
  })
}

# Run the app
shinyApp(ui, server)
