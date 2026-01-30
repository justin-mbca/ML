# GxP Compliance Monitoring Dashboard
# Senior Shiny Developer Portfolio Project
# Demonstrates GxP compliance tracking and quality management systems

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
library(knitr)
library(rmarkdown)

# Generate GxP compliance data
generate_gxp_data <- function() {
  # Compliance areas
  compliance_areas <- data.frame(
    AREA_ID = paste0("AREA", sprintf("%02d", 1:10)),
    AREA_NAME = c(
      "Data Integrity", "Document Control", "Change Management", 
      "Training Records", "Validation", "Audit Trail",
      "Electronic Signatures", "Security", "Backup & Recovery", "Quality Management"
    ),
    CATEGORY = c("Data", "Documentation", "Process", "Personnel", "System", 
                "Audit", "Security", "Security", "Infrastructure", "Quality"),
    PRIORITY = sample(c("High", "Medium", "Low"), 10, replace = TRUE, prob = c(0.3, 0.5, 0.2)),
    COMPLIANCE_SCORE = sample(60:100, 10, replace = TRUE),
    LAST_ASSESSMENT = Sys.Date() - sample(1:90, 10, replace = TRUE),
    ASSESSOR = sample(c("QA Manager", "Compliance Officer", "Auditor"), 10, replace = TRUE)
  )
  
  # Compliance findings
  findings <- data.frame(
    FINDING_ID = paste0("FIND", sprintf("%05d", 1:50)),
    AREA_ID = sample(compliance_areas$AREA_ID, 50, replace = TRUE),
    FINDING_TYPE = sample(c("Observation", "Deviation", "Non-conformance", "CAPA"), 50, replace = TRUE),
    SEVERITY = sample(c("Critical", "Major", "Minor", "Informational"), 50, replace = TRUE, prob = c(0.1, 0.2, 0.4, 0.3)),
    STATUS = sample(c("Open", "In Progress", "Closed", "Verified"), 50, replace = TRUE, prob = c(0.2, 0.3, 0.4, 0.1)),
    DESCRIPTION = paste0("Compliance finding ", 1:50),
    ROOT_CAUSE = sample(c("Procedure Gap", "Training Issue", "System Limitation", "Human Error", "Process Deviation"), 50, replace = TRUE),
    DISCOVERY_DATE = Sys.Date() - sample(1:365, 50, replace = TRUE),
    DUE_DATE = Sys.Date() + sample(-30:180, 50, replace = TRUE),
    RESPONSIBLE = sample(c("QA Manager", "Department Head", "System Owner", "Process Owner"), 50, replace = TRUE)
  )
  
  # Audit records
  audits <- data.frame(
    AUDIT_ID = paste0("AUDIT", sprintf("%04d", 1:20)),
    AUDIT_TYPE = sample(c("Internal", "External", "Regulatory", "Supplier"), 20, replace = TRUE),
    AUDIT_NAME = paste0("Audit ", 1:20),
    STATUS = sample(c("Scheduled", "In Progress", "Completed", "Follow-up Required"), 20, replace = TRUE),
    SCHEDULED_DATE = Sys.Date() + sample(-30:180, 20, replace = TRUE),
    ACTUAL_DATE = Sys.Date() + sample(-60:365, 20, replace = TRUE),
    AUDITOR = sample(c("Internal Auditor", "External Auditor", "Regulatory Inspector"), 20, replace = TRUE),
    SCORE = sample(60:100, 20, replace = TRUE),
    FINDINGS_COUNT = sample(0:10, 20, replace = TRUE)
  )
  
  # Training records
  training <- data.frame(
    TRAINING_ID = paste0("TRN", sprintf("%04d", 1:100)),
    EMPLOYEE_ID = paste0("EMP", sprintf("%04d", sample(1000:2000, 100, replace = TRUE))),
    COURSE_NAME = sample(c("GxP Fundamentals", "Data Integrity", "SOP Training", "Quality Systems", "Regulatory Compliance"), 100, replace = TRUE),
    COMPLETION_DATE = Sys.Date() - sample(1:730, 100, replace = TRUE),
    STATUS = sample(c("Completed", "In Progress", "Overdue"), 100, replace = TRUE, prob = c(0.8, 0.15, 0.05)),
    SCORE = sample(70:100, 100, replace = TRUE),
    EXPIRY_DATE = Sys.Date() + sample(30:1095, 100, replace = TRUE),
    INSTRUCTOR = sample(c("QA Trainer", "External Trainer", "Department Trainer"), 100, replace = TRUE)
  )
  
  # SOP documents
  sops <- data.frame(
    SOP_ID = paste0("SOP", sprintf("%03d", 1:30)),
    SOP_TITLE = paste0("SOP ", 1:30, " - ", sample(c("Data Management", "Quality Control", "Documentation", "Validation", "Security"), 30, replace = TRUE)),
    VERSION = sample(1:5, 30, replace = TRUE),
    STATUS = sample(c("Active", "Draft", "Under Review", "Obsolete"), 30, replace = TRUE, prob = c(0.6, 0.2, 0.15, 0.05)),
    EFFECTIVE_DATE = Sys.Date() - sample(1:1095, 30, replace = TRUE),
    REVIEW_DATE = Sys.Date() + sample(1:365, 30, replace = TRUE),
    OWNER = sample(c("QA Manager", "Department Head", "Process Owner"), 30, replace = TRUE),
    APPROVED_BY = sample(c("QA Director", "Compliance Officer", "Senior Management"), 30, replace = TRUE)
  )
  
  list(
    compliance_areas = compliance_areas,
    findings = findings,
    audits = audits,
    training = training,
    sops = sops
  )
}

# Calculate compliance metrics
calculate_compliance_metrics <- function(data) {
  findings <- data$findings
  audits <- data$audits
  training <- data$training
  sops <- data$sops
  
  # Overall metrics
  total_findings <- nrow(findings)
  open_findings <- sum(findings$STATUS == "Open")
  critical_findings <- sum(findings$SEVERITY == "Critical" & findings$STATUS != "Closed")
  overdue_findings <- sum(findings$DUE_DATE < Sys.Date() & findings$STATUS != "Closed")
  
  # Audit metrics
  avg_audit_score <- mean(audits$SCORE, na.rm = TRUE)
  pending_audits <- sum(audits$STATUS %in% c("Scheduled", "In Progress"))
  
  # Training metrics
  training_completion <- mean(training$STATUS == "Completed", na.rm = TRUE) * 100
  overdue_training <- sum(training$STATUS == "Overdue")
  
  # SOP metrics
  active_sops <- sum(sops$STATUS == "Active")
  overdue_reviews <- sum(sops$REVIEW_DATE < Sys.Date() & sops$STATUS == "Active")
  
  list(
    total_findings = total_findings,
    open_findings = open_findings,
    critical_findings = critical_findings,
    overdue_findings = overdue_findings,
    avg_audit_score = avg_audit_score,
    pending_audits = pending_audits,
    training_completion = training_completion,
    overdue_training = overdue_training,
    active_sops = active_sops,
    overdue_reviews = overdue_reviews
  )
}

# Generate compliance report
generate_compliance_report <- function(data, metrics) {
  report_content <- paste0(
    "# GxP Compliance Report\n\n",
    "Generated on: ", Sys.Date(), "\n\n",
    "## Executive Summary\n\n",
    "- Total Findings: ", metrics$total_findings, "\n",
    "- Open Findings: ", metrics$open_findings, "\n",
    "- Critical Findings: ", metrics$critical_findings, "\n",
    "- Average Audit Score: ", round(metrics$avg_audit_score, 1), "\n",
    "- Training Completion: ", round(metrics$training_completion, 1), "%\n\n",
    "## Key Metrics\n\n",
    "### Findings Status\n",
    "- Open: ", metrics$open_findings, "\n",
    "- Overdue: ", metrics$overdue_findings, "\n",
    "- Critical: ", metrics$critical_findings, "\n\n",
    "### Audit Performance\n",
    "- Average Score: ", round(metrics$avg_audit_score, 1), "\n",
    "- Pending Audits: ", metrics$pending_audits, "\n\n",
    "### Training Status\n",
    "- Completion Rate: ", round(metrics$training_completion, 1), "%\n",
    "- Overdue Training: ", metrics$overdue_training, "\n\n",
    "### SOP Status\n",
    "- Active SOPs: ", metrics$active_sops, "\n",
    "- Overdue Reviews: ", metrics$overdue_reviews, "\n\n",
    "## Recommendations\n\n",
    "1. Address critical findings immediately\n",
    "2. Update overdue training records\n",
    "3. Schedule overdue SOP reviews\n",
    "4. Prepare for pending audits\n"
  )
  
  return(report_content)
}

# UI
ui <- dashboardPage(
  dashboardHeader(
    title = "GxP Compliance",
    titleWidth = 300,
    dropdownMenu(type = "messages",
                 messageItem("Critical Finding", "New critical finding in Data Integrity", "2024-01-30"),
                 messageItem("Audit Scheduled", "Regulatory audit scheduled for next week", "2024-01-29")),
    dropdownMenu(type = "notifications",
                 notificationItem("Overdue Items", "5 overdue compliance items", icon = icon("exclamation-triangle")),
                 notificationItem("Training Due", "10 training sessions overdue", icon = icon("graduation-cap")))
  ),
  
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Compliance Areas", tabName = "areas", icon = icon("shield-alt")),
      menuItem("Findings", tabName = "findings", icon = icon("search")),
      menuItem("Audits", tabName = "audits", icon = icon("clipboard-check")),
      menuItem("Training", tabName = "training", icon = icon("graduation-cap")),
      menuItem("SOPs", tabName = "sops", icon = icon("file-alt")),
      menuItem("Reports", tabName = "reports", icon = icon("chart-line")),
      menuItem("Alerts", tabName = "alerts", icon = icon("bell")),
      menuItem("Settings", tabName = "settings", icon = icon("cog"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Dashboard Tab
      tabItem(tabName = "dashboard",
        fluidRow(
          box(
            title = "Compliance Overview", status = "primary", solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(3, valueBoxOutput("complianceScore")),
              column(3, valueBoxOutput("openFindings")),
              column(3, valueBoxOutput("criticalItems")),
              column(3, valueBoxOutput("trainingCompletion"))
            )
          )
        ),
        fluidRow(
          box(
            title = "Compliance Trends", status = "info", solidHeader = TRUE,
            width = 6,
            plotOutput("complianceTrendPlot")
          ),
          box(
            title = "Findings by Severity", status = "warning", solidHeader = TRUE,
            width = 6,
            plotOutput("findingsSeverityPlot")
          )
        ),
        fluidRow(
          box(
            title = "Upcoming Deadlines", status = "danger", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("upcomingDeadlines")
          )
        )
      ),
      
      # Compliance Areas Tab
      tabItem(tabName = "areas",
        fluidRow(
          box(
            title = "Compliance Areas", status = "primary", solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(3,
                selectInput("areaCategory", "Category:",
                           choices = c("All", "Data", "Documentation", "Process", "Personnel", "System"),
                           selected = "All")
              ),
              column(3,
                selectInput("areaPriority", "Priority:",
                           choices = c("All", "High", "Medium", "Low"),
                           selected = "All")
              ),
              column(3,
                actionButton("refreshAreas", "Refresh Areas", class = "btn-primary")
              ),
              column(3,
                actionButton("addAssessment", "Add Assessment", class = "btn-success")
              )
            )
          )
        ),
        fluidRow(
          box(
            title = "Compliance Scores", status = "info", solidHeader = TRUE,
            width = 12,
            plotOutput("complianceScoresPlot")
          )
        ),
        fluidRow(
          box(
            title = "Area Details", status = "warning", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("areasTable")
          )
        )
      ),
      
      # Findings Tab
      tabItem(tabName = "findings",
        fluidRow(
          box(
            title = "Compliance Findings", status = "primary", solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(2,
                selectInput("findingType", "Type:",
                           choices = c("All", "Observation", "Deviation", "Non-conformance", "CAPA"),
                           selected = "All")
              ),
              column(2,
                selectInput("findingSeverity", "Severity:",
                           choices = c("All", "Critical", "Major", "Minor", "Informational"),
                           selected = "All")
              ),
              column(2,
                selectInput("findingStatus", "Status:",
                           choices = c("All", "Open", "In Progress", "Closed", "Verified"),
                           selected = "All")
              ),
              column(2,
                actionButton("addFinding", "Add Finding", class = "btn-warning")
              ),
              column(2,
                actionButton("exportFindings", "Export Findings", class = "btn-info")
              ),
              column(2,
                actionButton("generateCAPA", "Generate CAPA", class = "btn-danger")
              )
            )
          )
        ),
        fluidRow(
          box(
            title = "Findings Timeline", status = "info", solidHeader = TRUE,
            width = 12,
            plotOutput("findingsTimelinePlot")
          )
        ),
        fluidRow(
          box(
            title = "Findings List", status = "warning", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("findingsTable")
          )
        )
      ),
      
      # Audits Tab
      tabItem(tabName = "audits",
        fluidRow(
          box(
            title = "Audit Management", status = "primary", solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(3,
                selectInput("auditType", "Type:",
                           choices = c("All", "Internal", "External", "Regulatory", "Supplier"),
                           selected = "All")
              ),
              column(3,
                selectInput("auditStatus", "Status:",
                           choices = c("All", "Scheduled", "In Progress", "Completed", "Follow-up Required"),
                           selected = "All")
              ),
              column(3,
                actionButton("scheduleAudit", "Schedule Audit", class = "btn-primary")
              ),
              column(3,
                actionButton("generateAuditReport", "Generate Report", class = "btn-success")
              )
            )
          )
        ),
        fluidRow(
          box(
            title = "Audit Performance", status = "info", solidHeader = TRUE,
            width = 6,
            plotOutput("auditPerformancePlot")
          ),
          box(
            title = "Audit Findings", status = "warning", solidHeader = TRUE,
            width = 6,
            plotOutput("auditFindingsPlot")
          )
        ),
        fluidRow(
          box(
            title = "Audit Schedule", status = "info", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("auditsTable")
          )
        )
      ),
      
      # Training Tab
      tabItem(tabName = "training",
        fluidRow(
          box(
            title = "Training Management", status = "primary", solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(3,
                selectInput("trainingCourse", "Course:",
                           choices = c("All", "GxP Fundamentals", "Data Integrity", "SOP Training", "Quality Systems"),
                           selected = "All")
              ),
              column(3,
                selectInput("trainingStatus", "Status:",
                           choices = c("All", "Completed", "In Progress", "Overdue"),
                           selected = "All")
              ),
              column(3,
                actionButton("assignTraining", "Assign Training", class = "btn-primary")
              ),
              column(3,
                actionButton("trainingReport", "Training Report", class = "btn-info")
              )
            )
          )
        ),
        fluidRow(
          box(
            title = "Training Completion", status = "info", solidHeader = TRUE,
            width = 6,
            plotOutput("trainingCompletionPlot")
          ),
          box(
            title = "Upcoming Training", status = "warning", solidHeader = TRUE,
            width = 6,
            DT::dataTableOutput("upcomingTraining")
          )
        )
      ),
      
      # SOPs Tab
      tabItem(tabName = "sops",
        fluidRow(
          box(
            title = "SOP Management", status = "primary", solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(3,
                selectInput("sopStatus", "Status:",
                           choices = c("All", "Active", "Draft", "Under Review", "Obsolete"),
                           selected = "All")
              ),
              column(3,
                actionButton("createSOP", "Create SOP", class = "btn-primary")
              ),
              column(3,
                actionButton("reviewSOPs", "Review SOPs", class = "btn-warning")
              ),
              column(3,
                actionButton("sopReport", "SOP Report", class = "btn-info")
              )
            )
          )
        ),
        fluidRow(
          box(
            title = "SOP Status Overview", status = "info", solidHeader = TRUE,
            width = 12,
            plotOutput("sopStatusPlot")
          )
        ),
        fluidRow(
          box(
            title = "SOP Documents", status = "warning", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("sopsTable")
          )
        )
      ),
      
      # Reports Tab
      tabItem(tabName = "reports",
        fluidRow(
          box(
            title = "Compliance Reports", status = "primary", solidHeader = TRUE,
            width = 12,
            h4("Generate Reports"),
            fluidRow(
              column(4,
                selectInput("reportType", "Report Type:",
                           choices = c("Executive Summary", "Detailed Compliance", "Audit Summary", "Training Status"),
                           selected = "Executive Summary")
              ),
              column(4,
                dateRangeInput("reportDate", "Date Range:", start = Sys.Date() - 30, end = Sys.Date())
              ),
              column(4,
                actionButton("generateReportBtn", "Generate Report", class = "btn-primary")
              )
            )
          )
        ),
        fluidRow(
          box(
            title = "Report Output", status = "info", solidHeader = TRUE,
            width = 12,
            htmlOutput("reportOutput")
          )
        )
      ),
      
      # Alerts Tab
      tabItem(tabName = "alerts",
        fluidRow(
          box(
            title = "Compliance Alerts", status = "danger", solidHeader = TRUE,
            width = 12,
            h4("Active Alerts"),
            DT::dataTableOutput("alertsTable")
          )
        )
      ),
      
      # Settings Tab
      tabItem(tabName = "settings",
        fluidRow(
          box(
            title = "Compliance Settings", status = "primary", solidHeader = TRUE,
            width = 12,
            h4("Alert Settings"),
            checkboxInput("criticalAlerts", "Critical Finding Alerts", TRUE),
            checkboxInput("overdueAlerts", "Overdue Item Alerts", TRUE),
            checkboxInput("auditAlerts", "Audit Reminder Alerts", TRUE),
            checkboxInput("trainingAlerts", "Training Due Alerts", TRUE),
            br(),
            h4("Threshold Settings"),
            numericInput("complianceThreshold", "Compliance Score Threshold:", value = 85, min = 0, max = 100),
            numericInput("findingThreshold", "Finding Response Threshold (days):", value = 30, min = 1, max = 365),
            br(),
            actionButton("saveSettings", "Save Settings", class = "btn-success")
          )
        )
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Generate data
  gxp_data <- reactiveVal(generate_gxp_data())
  metrics <- reactive(calculate_compliance_metrics(gxp_data()))
  
  # Dashboard outputs
  output$complianceScore <- renderValueBox({
    score <- mean(gxp_data()$compliance_areas$COMPLIANCE_SCORE)
    color <- ifelse(score >= 90, "green", ifelse(score >= 75, "yellow", "red"))
    
    valueBox(
      value = paste0(round(score, 1), "%"),
      subtitle = "Overall Compliance",
      icon = icon("shield-alt"),
      color = color
    )
  })
  
  output$openFindings <- renderValueBox({
    valueBox(
      value = metrics()$open_findings,
      subtitle = "Open Findings",
      icon = icon("search"),
      color = ifelse(metrics()$open_findings > 10, "red", ifelse(metrics()$open_findings > 5, "yellow", "green"))
    )
  })
  
  output$criticalItems <- renderValueBox({
    critical_count <- metrics()$critical_findings + metrics()$overdue_findings
    
    valueBox(
      value = critical_count,
      subtitle = "Critical Items",
      icon = icon("exclamation-triangle"),
      color = ifelse(critical_count > 5, "red", ifelse(critical_count > 2, "yellow", "green"))
    )
  })
  
  output$trainingCompletion <- renderValueBox({
    valueBox(
      value = paste0(round(metrics()$training_completion, 1), "%"),
      subtitle = "Training Completion",
      icon = icon("graduation-cap"),
      color = ifelse(metrics()$training_completion >= 95, "green", ifelse(metrics()$training_completion >= 85, "yellow", "red"))
    )
  })
  
  # Compliance trend plot
  output$complianceTrendPlot <- renderPlot({
    # Simulate trend data
    dates <- Sys.Date() - seq(0, 365, by = 30)
    scores <- cumsum(rnorm(length(dates), 0.5, 2)) + 80
    scores <- pmax(pmin(scores, 100), 60)
    
    trend_data <- data.frame(Date = dates, Score = scores)
    
    ggplot(trend_data, aes(x = Date, y = Score)) +
      geom_line(color = "blue", size = 1.5) +
      geom_point(color = "blue", size = 2) +
      geom_hline(yintercept = 85, linetype = "dashed", color = "red") +
      scale_y_continuous(limits = c(60, 100)) +
      labs(title = "Compliance Score Trend",
           x = "Date", y = "Compliance Score (%)") +
      theme_minimal()
  })
  
  # Findings severity plot
  output$findingsSeverityPlot <- renderPlot({
    findings <- gxp_data()$findings
    severity_counts <- findings %>% count(SEVERITY)
    
    ggplot(severity_counts, aes(x = SEVERITY, y = n, fill = SEVERITY)) +
      geom_col() +
      geom_text(aes(label = n), vjust = -0.5) +
      labs(title = "Findings by Severity",
           x = "Severity", y = "Count") +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  # Upcoming deadlines
  output$upcomingDeadlines <- DT::renderDataTable({
    findings <- gxp_data()$findings
    today <- Sys.Date()
    
    upcoming <- findings %>%
      filter(STATUS != "Closed", DUE_DATE >= today) %>%
      mutate(Days_Until_Due = as.numeric(DUE_DATE - today)) %>%
      arrange(DUE_DATE) %>%
      select(FINDING_ID, DESCRIPTION, SEVERITY, DUE_DATE, Days_Until_Due, RESPONSIBLE) %>%
      head(10)
    
    DT::datatable(upcoming, options = list(pageLength = 10))
  })
  
  # Compliance scores plot
  output$complianceScoresPlot <- renderPlot({
    areas <- gxp_data()$compliance_areas
    
    if (input$areaCategory != "All") {
      areas <- areas %>% filter(CATEGORY == input$areaCategory)
    }
    
    if (input$areaPriority != "All") {
      areas <- areas %>% filter(PRIORITY == input$areaPriority)
    }
    
    ggplot(areas, aes(x = reorder(AREA_NAME, COMPLIANCE_SCORE), y = COMPLIANCE_SCORE, fill = PRIORITY)) +
      geom_col() +
      coord_flip() +
      scale_fill_brewer(type = "qual", palette = "Set1") +
      labs(title = "Compliance Scores by Area",
           x = "Compliance Area", y = "Score (%)") +
      theme_minimal()
  })
  
  # Areas table
  output$areasTable <- DT::renderDataTable({
    areas <- gxp_data()$compliance_areas
    
    if (input$areaCategory != "All") {
      areas <- areas %>% filter(CATEGORY == input$areaCategory)
    }
    
    if (input$areaPriority != "All") {
      areas <- areas %>% filter(PRIORITY == input$areaPriority)
    }
    
    DT::datatable(areas, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  # Findings timeline plot
  output$findingsTimelinePlot <- renderPlot({
    findings <- gxp_data()$findings
    
    timeline_data <- findings %>%
      count(DISCOVERY_DATE) %>%
      arrange(DISCOVERY_DATE)
    
    ggplot(timeline_data, aes(x = DISCOVERY_DATE, y = n)) +
      geom_line(color = "blue") +
      geom_point(color = "blue", size = 2) +
      labs(title = "Findings Discovery Timeline",
           x = "Date", y = "Number of Findings") +
      theme_minimal()
  })
  
  # Findings table
  output$findingsTable <- DT::renderDataTable({
    findings <- gxp_data()$findings
    
    if (input$findingType != "All") {
      findings <- findings %>% filter(FINDING_TYPE == input$findingType)
    }
    
    if (input$findingSeverity != "All") {
      findings <- findings %>% filter(SEVERITY == input$findingSeverity)
    }
    
    if (input$findingStatus != "All") {
      findings <- findings %>% filter(STATUS == input$findingStatus)
    }
    
    DT::datatable(findings, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  # Audit performance plot
  output$auditPerformancePlot <- renderPlot({
    audits <- gxp_data()$audits
    
    if (input$auditType != "All") {
      audits <- audits %>% filter(AUDIT_TYPE == input$auditType)
    }
    
    ggplot(audits, aes(x = AUDIT_TYPE, y = SCORE, fill = AUDIT_TYPE)) +
      geom_boxplot() +
      labs(title = "Audit Performance by Type",
           x = "Audit Type", y = "Score") +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  # Audit findings plot
  output$auditFindingsPlot <- renderPlot({
    audits <- gxp_data()$audits
    
    if (input$auditType != "All") {
      audits <- audits %>% filter(AUDIT_TYPE == input$auditType)
    }
    
    ggplot(audits, aes(x = AUDIT_TYPE, y = FINDINGS_COUNT, fill = AUDIT_TYPE)) +
      geom_col() +
      labs(title = "Findings Count by Audit Type",
           x = "Audit Type", y = "Number of Findings") +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  # Audits table
  output$auditsTable <- DT::renderDataTable({
    audits <- gxp_data()$audits
    
    if (input$auditType != "All") {
      audits <- audits %>% filter(AUDIT_TYPE == input$auditType)
    }
    
    if (input$auditStatus != "All") {
      audits <- audits %>% filter(STATUS == input$auditStatus)
    }
    
    DT::datatable(audits, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  # Training completion plot
  output$trainingCompletionPlot <- renderPlot({
    training <- gxp_data()$training
    
    if (input$trainingCourse != "All") {
      training <- training %>% filter(COURSE_NAME == input$trainingCourse)
    }
    
    completion_data <- training %>%
      count(COURSE_NAME, STATUS) %>%
      group_by(COURSE_NAME) %>%
      mutate(total = sum(n), percent = n / total * 100) %>%
      filter(STATUS == "Completed")
    
    ggplot(completion_data, aes(x = COURSE_NAME, y = percent, fill = COURSE_NAME)) +
      geom_col() +
      coord_flip() +
      labs(title = "Training Completion by Course",
           x = "Course", y = "Completion Rate (%)") +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  # Upcoming training
  output$upcomingTraining <- DT::renderDataTable({
    training <- gxp_data()$training
    
    upcoming <- training %>%
      filter(STATUS == "In Progress") %>%
      select(TRAINING_ID, EMPLOYEE_ID, COURSE_NAME, COMPLETION_DATE, INSTRUCTOR) %>%
      head(10)
    
    DT::datatable(upcoming, options = list(pageLength = 10))
  })
  
  # SOP status plot
  output$sopStatusPlot <- renderPlot({
    sops <- gxp_data()$sops
    
    if (input$sopStatus != "All") {
      sops <- sops %>% filter(STATUS == input$sopStatus)
    }
    
    status_counts <- sops %>% count(STATUS)
    
    ggplot(status_counts, aes(x = STATUS, y = n, fill = STATUS)) +
      geom_col() +
      geom_text(aes(label = n), vjust = -0.5) +
      labs(title = "SOP Status Distribution",
           x = "Status", y = "Count") +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  # SOPs table
  output$sopsTable <- DT::renderDataTable({
    sops <- gxp_data()$sops
    
    if (input$sopStatus != "All") {
      sops <- sops %>% filter(STATUS == input$sopStatus)
    }
    
    DT::datatable(sops, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  # Report generation
  output$reportOutput <- renderText({
    if (input$generateReportBtn > 0) {
      report_content <- generate_compliance_report(gxp_data(), metrics())
      # Convert markdown to HTML (simplified)
      html_content <- gsub("\n", "<br>", report_content)
      html_content <- gsub("# (.*)", "<h3>\\1</h3>", html_content)
      html_content <- gsub("## (.*)", "<h4>\\1</h4>", html_content)
      html_content <- gsub("- (.*)", "<li>\\1</li>", html_content)
      html_content <- paste0("<ul>", html_content, "</ul>")
      html_content <- gsub("<ul><li>", "<ul><li>", html_content)
      
      HTML(html_content)
    }
  })
  
  # Alerts table
  output$alertsTable <- DT::renderDataTable({
    alerts <- data.frame(
      Alert_ID = paste0("ALT", sprintf("%04d", 1:10)),
      Type = c("Critical Finding", "Overdue Training", "SOP Review Due", "Audit Scheduled", "Compliance Score Low"),
      Description = c("Critical finding in Data Integrity area", "5 training sessions overdue", "3 SOPs require review", "Regulatory audit in 2 weeks", "Compliance score below threshold"),
      Priority = c("High", "Medium", "Medium", "High", "High"),
      Due_Date = Sys.Date() + c(1, 3, 7, 14, 2),
      Status = c("Open", "Open", "Open", "Scheduled", "Open")
    )
    
    DT::datatable(alerts, options = list(pageLength = 10))
  })
}

# Run the app
shinyApp(ui, server)
