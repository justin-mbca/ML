# Python Integration for LLM Analytics Demo
# Senior Shiny Developer Portfolio Project
# Demonstrates Python integration with R for LLM-powered clinical data analytics

library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)
library(shinycssloaders)
library(shinyWidgets)
library(readr)
library(jsonlite)
library(reticulate)
library(knitr)
library(rmarkdown)

# Python integration setup
setup_python_environment <- function() {
  # Initialize reticulate for Python integration
  # Use find_python() instead of hardcoded path for better portability
  tryCatch({
    reticulate::use_python(reticulate::conda_python(), required = FALSE)
  }, error = function(e) {
    # Fall back to system python if conda not available
    tryCatch({
      reticulate::use_python(Sys.which("python3"), required = FALSE)
    }, error = function(e2) {
      warning("Python not available for LLM functionality")
    })
  })
  
  # Import Python modules (if available)
  tryCatch({
    np <- import("numpy")
    pd <- import("pandas")
    sklearn <- import("sklearn")
    transformers <- import("transformers")
    torch <- import("torch")
    
    return(list(
      numpy = np,
      pandas = pd,
      sklearn = sklearn,
      transformers = transformers,
      torch = torch,
      available = TRUE
    ))
  }, error = function(e) {
    return(list(available = FALSE, error = e$message))
  })
}

# Simulate LLM analytics functions
simulate_llm_analysis <- function(text_data, analysis_type) {
  # Simulate different LLM analyses
  
  if (analysis_type == "sentiment") {
    # Simulate sentiment analysis
    sentiments <- sample(c("Positive", "Negative", "Neutral"), length(text_data), 
                       replace = TRUE, prob = c(0.4, 0.2, 0.4))
    scores <- runif(length(text_data), 0, 1)
    
    return(data.frame(
      text = text_data,
      sentiment = sentiments,
      confidence = scores
    ))
    
  } else if (analysis_type == "entity_extraction") {
    # Simulate entity extraction
    entities <- list(
      "Drug Names" = c("Aspirin", "Lisinopril", "Metformin", "Atorvastatin"),
      "Conditions" = c("Hypertension", "Diabetes", "Hyperlipidemia", "Arthritis"),
      "Symptoms" = c("Headache", "Chest Pain", "Fatigue", "Nausea"),
      "Procedures" = c("Blood Test", "ECG", "MRI", "X-Ray")
    )
    
    results <- data.frame()
    for (i in seq_along(text_data)) {
      entity_type <- sample(names(entities), 1)
      entity <- sample(entities[[entity_type]], 1)
      
      results <- rbind(results, data.frame(
        text_id = i,
        text = text_data[i],
        entity_type = entity_type,
        entity = entity,
        confidence = runif(1, 0.7, 1.0)
      ))
    }
    
    return(results)
    
  } else if (analysis_type == "summarization") {
    # Simulate text summarization
    summaries <- paste0("Summary of text ", seq_along(text_data), ": ", 
                      sample(c("Key findings include...", "Analysis shows...", "Results indicate..."), 
                            length(text_data), replace = TRUE))
    
    return(data.frame(
      original_text = text_data,
      summary = summaries,
      compression_ratio = runif(length(text_data), 0.2, 0.5)
    ))
    
  } else if (analysis_type == "classification") {
    # Simulate text classification
    categories <- c("Adverse Event", "Efficacy", "Safety", "Quality", "Protocol")
    classifications <- sample(categories, length(text_data), replace = TRUE)
    
    return(data.frame(
      text = text_data,
      category = classifications,
      confidence = runif(length(text_data), 0.6, 1.0)
    ))
  }
}

# Generate clinical text data
generate_clinical_text_data <- function() {
  # Sample clinical notes and documents
  clinical_texts <- c(
    "Patient reports mild headache after taking medication. Blood pressure readings are within normal range.",
    "Laboratory results show elevated liver enzymes. Patient denies any alcohol consumption.",
    "ECG shows normal sinus rhythm. No acute ischemic changes observed.",
    "Patient complains of persistent cough and fever. Chest X-ray reveals bilateral infiltrates.",
    "Blood glucose levels are well controlled with current medication regimen.",
    "Patient experiences dizziness when standing up quickly. Orthostatic hypotension suspected.",
    "MRI scan shows no evidence of metastatic disease. Primary tumor appears contained.",
    "Complete blood count shows mild anemia. Iron supplementation recommended.",
    "Patient reports improvement in symptoms after dose adjustment. No adverse effects noted.",
    "Echocardiogram reveals preserved left ventricular function. No significant valvular disease.",
    "Colonoscopy findings show multiple polyps. Biopsy results pending.",
    "Patient demonstrates good medication adherence. No missed doses reported.",
    "Pulmonary function tests indicate mild obstructive pattern. Inhaler therapy continued.",
    "Renal function tests show stable creatinine levels. No acute kidney injury.",
    "Patient reports occasional palpitations. Holter monitor ordered for further evaluation.",
    "Dermatological examination reveals rash consistent with drug reaction. Medication changed.",
    "Bone density scan shows osteopenia. Calcium and vitamin D supplementation initiated.",
    "Patient reports improved sleep quality with new medication. No daytime drowsiness.",
    "Neurological examination shows no focal deficits. Cognitive function intact.",
    "Gastrointestinal symptoms resolved with dietary modifications. No further intervention needed."
  )
  
  return(clinical_texts)
}

# Simulate Python ML model integration
simulate_python_ml <- function(data, model_type) {
  # Simulate different ML models from Python
  
  if (model_type == "clustering") {
    # Simulate clustering analysis
    n_clusters <- 3
    cluster_assignments <- sample(1:n_clusters, nrow(data), replace = TRUE)
    
    return(data.frame(
      original_data = data,
      cluster = cluster_assignments,
      cluster_confidence = runif(nrow(data), 0.6, 1.0)
    ))
    
  } else if (model_type == "anomaly_detection") {
    # Simulate anomaly detection
    is_anomaly <- rbinom(nrow(data), 1, 0.1) == 1
    anomaly_scores <- runif(nrow(data), 0, 1)
    anomaly_scores[is_anomaly] <- anomaly_scores[is_anomaly] + 0.3
    
    return(data.frame(
      original_data = data,
      is_anomaly = is_anomaly,
      anomaly_score = pmin(anomaly_scores, 1.0)
    ))
    
  } else if (model_type == "prediction") {
    # Simulate predictive modeling
    predictions <- runif(nrow(data), 0, 1)
    predicted_class <- ifelse(predictions > 0.5, "Positive", "Negative")
    
    return(data.frame(
      original_data = data,
      prediction = predictions,
      predicted_class = predicted_class,
      confidence = abs(predictions - 0.5) * 2
    ))
  }
}

# UI
ui <- dashboardPage(
  dashboardHeader(
    title = "LLM Analytics",
    titleWidth = 300,
    dropdownMenu(type = "messages",
                 messageItem("Model Update", "New LLM model available", "2024-01-30"),
                 messageItem("Python Env", "Python environment updated", "2024-01-29"))
  ),
  
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("Text Analysis", tabName = "text_analysis", icon = icon("file-alt")),
      menuItem("Entity Extraction", tabName = "entity_extraction", icon = icon("tags")),
      menuItem("Sentiment Analysis", tabName = "sentiment", icon = icon("heart")),
      menuItem("Classification", tabName = "classification", icon = icon("folder")),
      menuItem("Summarization", tabName = "summarization", icon = icon("compress")),
      menuItem("ML Integration", tabName = "ml_integration", icon = icon("brain")),
      menuItem("Python Console", tabName = "python_console", icon = icon("terminal")),
      menuItem("Performance", tabName = "performance", icon = icon("tachometer-alt"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Overview Tab
      tabItem(tabName = "overview",
        fluidRow(
          box(
            title = "LLM Analytics Overview", status = "primary", solidHeader = TRUE,
            width = 12,
            includeMarkdown("llm_overview.md")
          )
        ),
        fluidRow(
          box(
            title = "Python Environment", status = "info", solidHeader = TRUE,
            width = 6,
            verbatimTextOutput("pythonStatus")
          ),
          box(
            title = "Available Models", status = "warning", solidHeader = TRUE,
            width = 6,
            verbatimTextOutput("availableModels")
          )
        )
      ),
      
      # Text Analysis Tab
      tabItem(tabName = "text_analysis",
        fluidRow(
          box(
            title = "Clinical Text Analysis", status = "primary", solidHeader = TRUE,
            width = 12,
            h4("Input Clinical Text"),
            textAreaInput("clinicalText", "Enter clinical text:", 
                         value = "Patient reports headache after medication. Blood pressure normal.",
                         height = "100px", width = "100%"),
            br(),
            actionButton("analyzeText", "Analyze Text", class = "btn-primary"),
            actionButton("loadSampleText", "Load Sample Text", class = "btn-secondary")
          )
        ),
        fluidRow(
          box(
            title = "Analysis Results", status = "info", solidHeader = TRUE,
            width = 12,
            verbatimTextOutput("textAnalysisResults")
          )
        )
      ),
      
      # Entity Extraction Tab
      tabItem(tabName = "entity_extraction",
        fluidRow(
          box(
            title = "Medical Entity Extraction", status = "primary", solidHeader = TRUE,
            width = 12,
            h4("Extract Medical Entities"),
            textAreaInput("entityText", "Enter text for entity extraction:",
                         value = "Patient prescribed Aspirin 100mg daily for hypertension. Reports headache.",
                         height = "100px"),
            br(),
            actionButton("extractEntities", "Extract Entities", class = "btn-primary"),
            actionButton("batchExtract", "Batch Process", class = "btn-info")
          )
        ),
        fluidRow(
          box(
            title = "Extracted Entities", status = "info", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("entitiesTable")
          )
        )
      ),
      
      # Sentiment Analysis Tab
      tabItem(tabName = "sentiment",
        fluidRow(
          box(
            title = "Sentiment Analysis", status = "primary", solidHeader = TRUE,
            width = 12,
            h4("Analyze Sentiment"),
            textAreaInput("sentimentText", "Enter text for sentiment analysis:",
                         value = "Patient reports feeling much better after treatment. No side effects.",
                         height = "100px"),
            br(),
            actionButton("analyzeSentiment", "Analyze Sentiment", class = "btn-primary")
          )
        ),
        fluidRow(
          box(
            title = "Sentiment Results", status = "info", solidHeader = TRUE,
            width = 6,
            verbatimTextOutput("sentimentResults")
          ),
          box(
            title = "Sentiment Distribution", status = "warning", solidHeader = TRUE,
            width = 6,
            plotOutput("sentimentPlot")
          )
        )
      ),
      
      # Classification Tab
      tabItem(tabName = "classification",
        fluidRow(
          box(
            title = "Text Classification", status = "primary", solidHeader = TRUE,
            width = 12,
            h4("Classify Clinical Text"),
            textAreaInput("classificationText", "Enter text for classification:",
                         value = "Patient experiences adverse reaction to medication. Rash and itching reported.",
                         height = "100px"),
            br(),
            actionButton("classifyText", "Classify Text", class = "btn-primary")
          )
        ),
        fluidRow(
          box(
            title = "Classification Results", status = "info", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("classificationResults")
          )
        )
      ),
      
      # Summarization Tab
      tabItem(tabName = "summarization",
        fluidRow(
          box(
            title = "Text Summarization", status = "primary", solidHeader = TRUE,
            width = 12,
            h4("Summarize Clinical Text"),
            textAreaInput("summarizationText", "Enter text for summarization:",
                         value = paste("Patient is a 55-year-old male with history of hypertension and diabetes.",
                                       "Presenting with chest pain and shortness of breath.",
                                       "ECG shows ST-segment elevation in leads V2-V4.",
                                       "Cardiac enzymes elevated.",
                                       "Diagnosed with acute myocardial infarction.",
                                       "Started on aspirin, heparin, and nitroglycerin.",
                                       "Referred for cardiac catheterization."),
                         height = "150px"),
            br(),
            actionButton("summarizeText", "Summarize Text", class = "btn-primary")
          )
        ),
        fluidRow(
          box(
            title = "Generated Summary", status = "info", solidHeader = TRUE,
            width = 12,
            verbatimTextOutput("summaryResults")
          )
        )
      ),
      
      # ML Integration Tab
      tabItem(tabName = "ml_integration",
        fluidRow(
          box(
            title = "Python ML Integration", status = "primary", solidHeader = TRUE,
            width = 12,
            h4("Machine Learning Models"),
            selectInput("mlModel", "Select ML Model:",
                       choices = c("Clustering", "Anomaly Detection", "Predictive Modeling"),
                       selected = "Clustering"),
            actionButton("runMLModel", "Run Model", class = "btn-primary"),
            actionButton("trainModel", "Train New Model", class = "btn-success")
          )
        ),
        fluidRow(
          box(
            title = "Model Results", status = "info", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("mlResults")
          )
        )
      ),
      
      # Python Console Tab
      tabItem(tabName = "python_console",
        fluidRow(
          box(
            title = "Python Console", status = "primary", solidHeader = TRUE,
            width = 12,
            div(style = "background-color: black; color: white; padding: 10px; font-family: monospace; height: 400px; overflow-y: auto;",
                verbatimTextOutput("pythonOutput", placeholder = TRUE)
            ),
            textInput("pythonCommand", "Python Command:", placeholder = "Enter Python code..."),
            fluidRow(
              column(6,
                actionButton("executePython", "Execute", class = "btn-primary")
              ),
              column(6,
                actionButton("clearPython", "Clear", class = "btn-secondary")
              )
            )
          )
        )
      ),
      
      # Performance Tab
      tabItem(tabName = "performance",
        fluidRow(
          box(
            title = "Performance Metrics", status = "primary", solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(6,
                plotOutput("performancePlot")
              ),
              column(6,
                DT::dataTableOutput("performanceTable")
              )
            )
          )
        )
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Initialize Python environment
  python_env <- reactiveVal(setup_python_environment())
  clinical_texts <- reactiveVal(generate_clinical_text_data())
  python_history <- reactiveVal(character())
  
  # Python status
  output$pythonStatus <- renderText({
    env <- python_env()
    if (env$available) {
      "Python Environment: Connected\nAvailable packages: numpy, pandas, sklearn, transformers, torch"
    } else {
      paste("Python Environment: Not Available\nError:", env$error)
    }
  })
  
  # Available models
  output$availableModels <- renderText({
    "Available LLM Models:\n- BioBERT (Biomedical text)\n- ClinicalBERT (Clinical notes)\n- MedBERT (Medical literature)\n- Custom fine-tuned models"
  })
  
  # Text analysis
  observeEvent(input$analyzeText, {
    text <- input$clinicalText
    if (text != "") {
      # Simulate LLM analysis
      analysis <- list(
        sentiment = "Positive",
        entities = c("medication", "blood pressure"),
        category = "Safety",
        confidence = 0.85,
        summary = "Patient reports mild headache but has normal blood pressure readings."
      )
      
      output$textAnalysisResults <- renderText({
        paste0(
          "Analysis Results:\n",
          "Sentiment: ", analysis$sentiment, "\n",
          "Entities: ", paste(analysis$entities, collapse = ", "), "\n",
          "Category: ", analysis$category, "\n",
          "Confidence: ", analysis$confidence, "\n",
          "Summary: ", analysis$summary
        )
      })
    }
  })
  
  # Load sample text
  observeEvent(input$loadSampleText, {
    texts <- clinical_texts()
    sample_text <- sample(texts, 1)
    updateTextAreaInput(session, "clinicalText", value = sample_text)
  })
  
  # Entity extraction
  observeEvent(input$extractEntities, {
    text <- input$entityText
    if (text != "") {
      entities <- simulate_llm_analysis(text, "entity_extraction")
      output$entitiesTable <- DT::renderDataTable({
        DT::datatable(entities, options = list(pageLength = 10))
      })
    }
  })
  
  # Sentiment analysis
  observeEvent(input$analyzeSentiment, {
    text <- input$sentimentText
    if (text != "") {
      sentiment_result <- simulate_llm_analysis(text, "sentiment")
      
      output$sentimentResults <- renderText({
        paste0(
          "Sentiment: ", sentiment_result$sentiment, "\n",
          "Confidence: ", round(sentiment_result$confidence, 3)
        )
      })
      
      # Create sentiment plot
      output$sentimentPlot <- renderPlot({
        plot_data <- data.frame(
          Sentiment = c("Positive", "Negative", "Neutral"),
          Score = c(0.7, 0.2, 0.1)
        )
        
        ggplot(plot_data, aes(x = Sentiment, y = Score, fill = Sentiment)) +
          geom_col() +
          labs(title = "Sentiment Analysis Results",
               x = "Sentiment", y = "Score") +
          theme_minimal()
      })
    }
  })
  
  # Text classification
  observeEvent(input$classifyText, {
    text <- input$classificationText
    if (text != "") {
      classification_result <- simulate_llm_analysis(text, "classification")
      output$classificationResults <- DT::renderDataTable({
        DT::datatable(classification_result, options = list(pageLength = 10))
      })
    }
  })
  
  # Text summarization
  observeEvent(input$summarizeText, {
    text <- input$summarizationText
    if (text != "") {
      summary_result <- simulate_llm_analysis(text, "summarization")
      output$summaryResults <- renderText({
        summary_result$summary
      })
    }
  })
  
  # ML integration
  observeEvent(input$runMLModel, {
    # Simulate ML model execution
    sample_data <- data.frame(
      id = 1:100,
      value = rnorm(100),
      category = sample(c("A", "B", "C"), 100, replace = TRUE)
    )
    
    ml_results <- simulate_python_ml(sample_data, input$mlModel)
    output$mlResults <- DT::renderDataTable({
      DT::datatable(ml_results, options = list(pageLength = 10))
    })
  })
  
  # Python console
  output$pythonOutput <- renderText({
    history <- python_history()
    if (length(history) > 0) {
      paste(history, collapse = "\n")
    } else {
      "Python Console Ready\n>>> "
    }
  })
  
  observeEvent(input$executePython, {
    command <- input$pythonCommand
    if (command != "") {
      # Add command to history
      current_history <- python_history()
      new_history <- c(current_history, paste(">>>", command))
      
      # Simulate Python execution
      if (command == "print('Hello World')") {
        output_text <- "Hello World"
      } else if (command == "import numpy as np") {
        output_text <- "Module 'numpy' imported successfully"
      } else if (command == "np.array([1,2,3])") {
        output_text <- "array([1, 2, 3])"
      } else {
        output_text <- paste("Executed:", command)
      }
      
      new_history <- c(new_history, output_text)
      python_history(new_history)
      updateTextInput(session, "pythonCommand", value = "")
    }
  })
  
  observeEvent(input$clearPython, {
    python_history(character())
  })
  
  # Performance metrics
  output$performancePlot <- renderPlot({
    # Simulate performance data
    performance_data <- data.frame(
      Model = c("BioBERT", "ClinicalBERT", "MedBERT", "Custom Model"),
      Accuracy = c(0.92, 0.89, 0.85, 0.94),
      Speed = c(1.2, 1.5, 1.0, 2.0)
    )
    
    ggplot(performance_data, aes(x = Model, y = Accuracy, fill = Model)) +
      geom_col() +
      labs(title = "Model Performance Comparison",
           x = "Model", y = "Accuracy") +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  output$performanceTable <- DT::renderDataTable({
    performance_data <- data.frame(
      Model = c("BioBERT", "ClinicalBERT", "MedBERT", "Custom Model"),
      Accuracy = c(0.92, 0.89, 0.85, 0.94),
      Precision = c(0.90, 0.87, 0.83, 0.93),
      Recall = c(0.91, 0.88, 0.84, 0.92),
      F1_Score = c(0.905, 0.875, 0.835, 0.925),
      Inference_Time = c(1.2, 1.5, 1.0, 2.0)
    )
    
    DT::datatable(performance_data, options = list(pageLength = 10))
  })
}

# Run the app
shinyApp(ui, server)
