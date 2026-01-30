# Clinical Data Viewer - CDISC SDTM/ADaM Visualization App (Fixed Version)
# Senior Shiny Developer Portfolio Project
# Demonstrates clinical trial data analysis with CDISC standards

library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(dplyr)
library(ggplot2)

# Generate sample clinical data (simplified to avoid NSE issues)
generate_clinical_data <- function() {
  # Demographics (DM)
  dm <- data.frame(
    STUDYID = rep("STUDY001", 100),
    SITEID = sample(paste0("SITE", sprintf("%02d", 1:10)), 100, replace = TRUE),
    SUBJID = paste0("SUBJ", sprintf("%03d", 1:100)),
    AGE = sample(18:75, 100, replace = TRUE),
    SEX = sample(c("M", "F"), 100, replace = TRUE),
    RACE = sample(c("WHITE", "BLACK", "ASIAN", "HISPANIC"), 100, replace = TRUE),
    ARM = sample(c("Placebo", "Drug A", "Drug B"), 100, replace = TRUE),
    stringsAsFactors = FALSE
  )
  
  # Vital Signs (VS)
  vs <- data.frame(
    STUDYID = rep("STUDY001", 500),
    SUBJID = sample(dm$SUBJID, 500, replace = TRUE),
    VISIT = sample(c("Baseline", "Week 4", "Week 8"), 500, replace = TRUE),
    PARAM = sample(c("Systolic BP", "Diastolic BP", "Heart Rate"), 500, replace = TRUE),
    VALUE = c(
      rnorm(167, 120, 15),    # Systolic BP
      rnorm(167, 80, 10),     # Diastolic BP
      rnorm(166, 70, 10)      # Heart Rate
    ),
    UNIT = c(
      rep("mmHg", 167),
      rep("mmHg", 167),
      rep("bpm", 166)
    ),
    stringsAsFactors = FALSE
  )
  
  # Adverse Events (AE)
  ae <- data.frame(
    STUDYID = rep("STUDY001", 150),
    SUBJID = sample(dm$SUBJID, 150, replace = TRUE),
    AETERM = sample(c("Headache", "Nausea", "Fatigue", "Dizziness"), 150, replace = TRUE),
    SEVERITY = sample(c("MILD", "MODERATE", "SEVERE"), 150, replace = TRUE, prob = c(0.6, 0.3, 0.1)),
    RELATED = sample(c("YES", "NO"), 150, replace = TRUE, prob = c(0.4, 0.6)),
    stringsAsFactors = FALSE
  )
  
  list(dm = dm, vs = vs, ae = ae)
}

# UI
ui <- dashboardPage(
  dashboardHeader(
    title = "Clinical Data Viewer",
    titleWidth = 300
  ),
  
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Demographics", tabName = "demographics", icon = icon("users")),
      menuItem("Vital Signs", tabName = "vitals", icon = icon("heartbeat")),
      menuItem("Adverse Events", tabName = "adverse", icon = icon("exclamation-triangle")),
      menuItem("Data Explorer", tabName = "explorer", icon = icon("search"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Dashboard Tab
      tabItem(tabName = "dashboard",
        fluidRow(
          box(
            title = "Study Overview", status = "primary", solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(3, valueBoxOutput("totalSubjects")),
              column(3, valueBoxOutput("totalSites")),
              column(3, valueBoxOutput("totalAEs")),
              column(3, valueBoxOutput("avgAge"))
            )
          )
        ),
        fluidRow(
          box(
            title = "Subject Distribution", status = "info", solidHeader = TRUE,
            width = 6,
            plotOutput("siteDistPlot")
          ),
          box(
            title = "Adverse Events by Severity", status = "warning", solidHeader = TRUE,
            width = 6,
            plotOutput("aeSeverityPlot")
          )
        )
      ),
      
      # Demographics Tab
      tabItem(tabName = "demographics",
        fluidRow(
          box(
            title = "Demographics Summary", status = "primary", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("demogTable")
          )
        ),
        fluidRow(
          box(
            title = "Age Distribution", status = "info", solidHeader = TRUE,
            width = 6,
            plotOutput("ageDistPlot")
          ),
          box(
            title = "Gender Distribution", status = "info", solidHeader = TRUE,
            width = 6,
            plotOutput("genderDistPlot")
          )
        )
      ),
      
      # Vital Signs Tab
      tabItem(tabName = "vitals",
        fluidRow(
          box(
            title = "Vital Signs Parameters", status = "primary", solidHeader = TRUE,
            width = 12,
            selectInput("vsParam", "Select Parameter:", 
                       choices = c("Systolic BP", "Diastolic BP", "Heart Rate"),
                       selected = "Systolic BP"),
            plotOutput("vsTimePlot", height = "400px")
          )
        ),
        fluidRow(
          box(
            title = "Change from Baseline", status = "info", solidHeader = TRUE,
            width = 12,
            plotOutput("vsChangePlot", height = "400px")
          )
        )
      ),
      
      # Adverse Events Tab
      tabItem(tabName = "adverse",
        fluidRow(
          box(
            title = "Adverse Events Summary", status = "warning", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("aeTable")
          )
        ),
        fluidRow(
          box(
            title = "AEs by Category", status = "info", solidHeader = TRUE,
            width = 6,
            plotOutput("aeCategoryPlot")
          ),
          box(
            title = "AEs by Relationship", status = "info", solidHeader = TRUE,
            width = 6,
            plotOutput("aeRelPlot")
          )
        )
      ),
      
      # Data Explorer Tab
      tabItem(tabName = "explorer",
        fluidRow(
          box(
            title = "Data Explorer", status = "primary", solidHeader = TRUE,
            width = 12,
            selectInput("dataset", "Select Dataset:", 
                       choices = c("Demographics", "Vital Signs", "Adverse Events"),
                       selected = "Demographics"),
            DT::dataTableOutput("explorerTable")
          )
        )
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Generate data
  clinical_data <- reactiveVal(generate_clinical_data())
  
  # Dashboard outputs
  output$totalSubjects <- renderValueBox({
    valueBox(
      value = nrow(clinical_data()$dm),
      subtitle = "Total Subjects",
      icon = icon("users"),
      color = "blue"
    )
  })
  
  output$totalSites <- renderValueBox({
    valueBox(
      value = length(unique(clinical_data()$dm$SITEID)),
      subtitle = "Total Sites",
      icon = icon("hospital"),
      color = "green"
    )
  })
  
  output$totalAEs <- renderValueBox({
    valueBox(
      value = nrow(clinical_data()$ae),
      subtitle = "Total AEs",
      icon = icon("exclamation-triangle"),
      color = "yellow"
    )
  })
  
  output$avgAge <- renderValueBox({
    valueBox(
      value = round(mean(clinical_data()$dm$AGE), 1),
      subtitle = "Average Age",
      icon = icon("calendar"),
      color = "purple"
    )
  })
  
  # Site distribution plot
  output$siteDistPlot <- renderPlot({
    dm <- clinical_data()$dm
    ggplot(dm, aes(x = SITEID, fill = ARM)) +
      geom_bar() +
      labs(title = "Subject Distribution by Site and Treatment Arm",
           x = "Site ID", y = "Number of Subjects") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # AE severity plot
  output$aeSeverityPlot <- renderPlot({
    ae <- clinical_data()$ae
    ggplot(ae, aes(x = SEVERITY, fill = SEVERITY)) +
      geom_bar() +
      labs(title = "Adverse Events by Severity",
           x = "Severity", y = "Count") +
      theme_minimal()
  })
  
  # Demographics table
  output$demogTable <- DT::renderDataTable({
    dm <- clinical_data()$dm
    DT::datatable(dm, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  # Age distribution
  output$ageDistPlot <- renderPlot({
    dm <- clinical_data()$dm
    ggplot(dm, aes(x = AGE, fill = SEX)) +
      geom_histogram(bins = 15, alpha = 0.7) +
      labs(title = "Age Distribution by Gender",
           x = "Age", y = "Count") +
      theme_minimal()
  })
  
  # Gender distribution
  output$genderDistPlot <- renderPlot({
    dm <- clinical_data()$dm
    ggplot(dm, aes(x = SEX, fill = SEX)) +
      geom_bar() +
      labs(title = "Gender Distribution",
           x = "Gender", y = "Count") +
      theme_minimal()
  })
  
  # Vital signs time plot
  output$vsTimePlot <- renderPlot({
    vs <- clinical_data()$vs
    param_map <- c("Systolic BP" = "Systolic BP", "Diastolic BP" = "Diastolic BP", "Heart Rate" = "Heart Rate")
    
    vs_filtered <- vs[vs$PARAM == input$vsParam, ]
    
    ggplot(vs_filtered, aes(x = VISIT, y = VALUE, group = SUBJID)) +
      geom_line(alpha = 0.3) +
      stat_summary(fun = mean, geom = "line", color = "red", size = 1.5) +
      stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2, color = "red") +
      labs(title = paste(input$vsParam, "Over Time"),
           x = "Visit", y = "Value") +
      theme_minimal()
  })
  
  # Vital signs change from baseline
  output$vsChangePlot <- renderPlot({
    vs <- clinical_data()$vs
    param_map <- c("Systolic BP" = "Systolic BP", "Diastolic BP" = "Diastolic BP", "Heart Rate" = "Heart Rate")
    
    vs_filtered <- vs[vs$PARAM == input$vsParam & vs$VISIT != "Baseline", ]
    
    if (nrow(vs_filtered) > 0) {
      ggplot(vs_filtered, aes(x = VISIT, y = VALUE, fill = VISIT)) +
        geom_boxplot() +
        labs(title = paste("Change from Baseline -", input$vsParam),
             x = "Visit", y = "Value") +
        theme_minimal()
    } else {
      ggplot() + geom_blank() + theme_void() +
        ggtitle("No data available for change from baseline")
    }
  })
  
  # AE table
  output$aeTable <- DT::renderDataTable({
    ae <- clinical_data()$ae
    DT::datatable(ae, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  # AE category plot
  output$aeCategoryPlot <- renderPlot({
    ae <- clinical_data()$ae
    ggplot(ae, aes(x = AETERM, fill = AETERM)) +
      geom_bar() +
      coord_flip() +
      labs(title = "Adverse Events by Category",
           x = "Adverse Event", y = "Count") +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  # AE relationship plot
  output$aeRelPlot <- renderPlot({
    ae <- clinical_data()$ae
    ggplot(ae, aes(x = RELATED, fill = RELATED)) +
      geom_bar() +
      labs(title = "Adverse Events by Relationship to Study Drug",
           x = "Related", y = "Count") +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  # Data explorer
  output$explorerTable <- DT::renderDataTable({
    data_choice <- input$dataset
    data <- switch(data_choice,
      "Demographics" = clinical_data()$dm,
      "Vital Signs" = clinical_data()$vs,
      "Adverse Events" = clinical_data()$ae
    )
    DT::datatable(data, options = list(pageLength = 10, scrollX = TRUE))
  })
}

# Run the app
shinyApp(ui, server)
