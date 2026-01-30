# Regulatory Submission Pipeline Tracker
# Senior Shiny Developer Portfolio Project
# Demonstrates regulatory submission workflow management and compliance tracking

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

# Generate sample regulatory submission data
generate_regulatory_data <- function() {
  # Studies
  studies <- data.frame(
    STUDY_ID = c("STUDY001", "STUDY002", "STUDY003", "STUDY004", "STUDY005"),
    STUDY_NAME = c("Phase I PK Study", "Phase II Efficacy Trial", "Phase III Pivotal Study", 
                   "Bioequivalence Study", "Post-Marketing Surveillance"),
    STUDY_PHASE = c("I", "II", "III", "BE", "IV"),
    INDICATION = c("Hypertension", "Diabetes", "Oncology", "Generic", "Cardiovascular"),
    SPONSOR = c("PharmaCorp", "BioTech Inc", "MediCo", "GenericCo", "PharmaCorp"),
    CRO = c("CRO-A", "CRO-B", "CRO-A", "CRO-C", "CRO-B"),
    START_DATE = as.Date(c("2023-01-15", "2023-03-01", "2023-06-01", "2023-08-01", "2023-10-01")),
    PLANNED_COMPLETION = as.Date(c("2023-12-31", "2024-06-30", "2025-12-31", "2024-02-28", "2026-12-31")),
    STATUS = c("Completed", "In Progress", "In Progress", "Completed", "Planning"),
    stringsAsFactors = FALSE
  )
  
  # Submission packages
  submissions <- data.frame(
    SUBMISSION_ID = paste0("SUB", sprintf("%03d", 1:15)),
    STUDY_ID = rep(studies$STUDY_ID, each = 3),
    SUBMISSION_TYPE = rep(c("IND", "NDA", "BLA", "ANDA", "PAS"), each = 3),
    SUBMISSION_NAME = c(
      "Initial IND Application", "IND Safety Report", "IND Annual Report",
      "NDA Module 1", "NDA Module 2", "NDA Module 3-5",
      "BLA CMC", "BLA Clinical", "BLA Nonclinical",
      "ANDA Bioequivalence", "ANDA CMC", "ANDA Labeling",
      "PAS Protocol", "PAS Interim", "PAS Final"
    ),
    TARGET_AGENCY = rep(c("FDA", "FDA", "FDA", "FDA", "FDA"), each = 3),
    TARGET_DATE = as.Date(c(
      "2023-11-15", "2024-01-15", "2024-11-15",
      "2024-08-01", "2024-09-01", "2024-10-01",
      "2025-08-01", "2025-09-01", "2025-10-01",
      "2024-01-15", "2024-01-30", "2024-02-15",
      "2023-12-01", "2024-06-01", "2024-12-01"
    )),
    ACTUAL_DATE = as.Date(c(
      "2023-11-20", NA, NA,
      NA, NA, NA,
      NA, NA, NA,
      "2024-01-20", "2024-02-05", NA,
      "2023-12-05", NA, NA
    )),
    STATUS = c(
      "Submitted", "Pending", "Pending",
      "In Progress", "In Progress", "In Progress",
      "In Progress", "In Progress", "In Progress",
      "Submitted", "Submitted", "Pending",
      "Submitted", "In Progress", "Pending"
    ),
    PRIORITY = c("High", "Medium", "Low", "High", "High", "High", 
                 "High", "High", "High", "Medium", "Medium", "Low",
                 "High", "Medium", "Low"),
    stringsAsFactors = FALSE
  )
  
  # Tasks
  tasks <- data.frame(
    TASK_ID = paste0("TASK", sprintf("%04d", 1:50)),
    SUBMISSION_ID = rep(submissions$SUBMISSION_ID, times = c(3, 3, 3, 4, 4, 4, 4, 4, 4, 3, 3, 4, 3, 3, 3)),
    TASK_NAME = c(
      # IND tasks
      "Protocol Development", "Data Analysis", "Report Writing",
      "Safety Review", "AE Coding", "Narrative Writing",
      "Annual Report", "Data Update", "Submission Preparation",
      # NDA tasks
      "Module 1 Cover Letter", "Module 2 Summaries", "Module 3 CMC", "Module 4 Nonclinical", "Module 5 Clinical",
      "Statistical Analysis", "Data Integration", "Quality Review", "Final Assembly",
      # BLA tasks
      "CMC Documentation", "Manufacturing Data", "Quality Control",
      "Clinical Study Reports", "Efficacy Analysis", "Safety Analysis",
      "Nonclinical Studies", "Toxicology Reports", "Pharmacology Data",
      # ANDA tasks
      "Bioequivalence Analysis", "Statistical Review", "Comparability Assessment",
      "Chemistry Review", "Manufacturing Process", "Labeling Review",
      # PAS tasks
      "Protocol Amendment", "Site Selection", "Patient Recruitment",
      "Interim Analysis", "DSMB Review", "Final Analysis", "Report Generation"
    ),
    TASK_TYPE = rep(c("Development", "Analysis", "Writing", "Review", "Submission"), each = 10),
    ASSIGNED_TO = sample(c("John Smith", "Jane Doe", "Mike Johnson", "Sarah Wilson", "Tom Brown"), 50, replace = TRUE),
    START_DATE = as.Date("2023-01-01") + sample(0:365, 50, replace = TRUE),
    DUE_DATE = as.Date("2023-01-01") + sample(30:400, 50, replace = TRUE),
    COMPLETION_DATE = as.Date(c(
      rep(NA, 20), as.Date("2023-11-01") + sample(0:60, 15, replace = TRUE), rep(NA, 15)
    )),
    STATUS = c(
      rep("Completed", 15), rep("In Progress", 20), rep("Not Started", 15)
    ),
    PERCENT_COMPLETE = c(
      rep(100, 15), sample(30:90, 20, replace = TRUE), rep(0, 15)
    ),
    stringsAsFactors = FALSE
  )
  
  # Documents
  documents <- data.frame(
    DOC_ID = paste0("DOC", sprintf("%05d", 1:100)),
    TASK_ID = sample(tasks$TASK_ID, 100, replace = TRUE),
    DOC_NAME = paste0("Document_", 1:100),
    DOC_TYPE = sample(c("Protocol", "Report", "Analysis", "Letter", "Form", "Dataset"), 100, replace = TRUE),
    VERSION = sample(1:5, 100, replace = TRUE),
    STATUS = sample(c("Draft", "Review", "Approved", "Final"), 100, replace = TRUE, prob = c(0.3, 0.3, 0.2, 0.2)),
    CREATION_DATE = as.Date("2023-01-01") + sample(0:365, 100, replace = TRUE),
    LAST_MODIFIED = as.Date("2023-01-01") + sample(0:365, 100, replace = TRUE),
    FILE_SIZE = sample(100:10000, 100, replace = TRUE),
    stringsAsFactors = FALSE
  )
  
  list(studies = studies, submissions = submissions, tasks = tasks, documents = documents)
}

# Calculate submission metrics
calculate_submission_metrics <- function(data) {
  submissions <- data$submissions
  tasks <- data$tasks
  
  # Overall metrics
  total_submissions <- nrow(submissions)
  submitted_submissions <- sum(submissions$STATUS == "Submitted", na.rm = TRUE)
  pending_submissions <- sum(submissions$STATUS == "Pending", na.rm = TRUE)
  in_progress_submissions <- sum(submissions$STATUS == "In Progress", na.rm = TRUE)
  
  # Timeline metrics
  on_time_submissions <- sum(
    !is.na(submissions$ACTUAL_DATE) & 
    submissions$ACTUAL_DATE <= submissions$TARGET_DATE, 
    na.rm = TRUE
  )
  
  # Task metrics
  total_tasks <- nrow(tasks)
  completed_tasks <- sum(tasks$STATUS == "Completed", na.rm = TRUE)
  overall_progress <- mean(tasks$PERCENT_COMPLETE, na.rm = TRUE)
  
  # Overdue tasks
  today <- Sys.Date()
  overdue_tasks <- sum(tasks$DUE_DATE < today & tasks$STATUS != "Completed", na.rm = TRUE)
  
  list(
    total_submissions = total_submissions,
    submitted_submissions = submitted_submissions,
    pending_submissions = pending_submissions,
    in_progress_submissions = in_progress_submissions,
    on_time_submissions = on_time_submissions,
    total_tasks = total_tasks,
    completed_tasks = completed_tasks,
    overall_progress = overall_progress,
    overdue_tasks = overdue_tasks
  )
}

# UI
ui <- dashboardPage(
  dashboardHeader(
    title = "Regulatory Tracker",
    titleWidth = 300,
    dropdownMenu(type = "messages", 
                 messageItem("System Update", "New validation rules added", "2024-01-30"),
                 messageItem("Deadline Alert", "NDA submission due in 2 weeks", "2024-01-29")),
    dropdownMenu(type = "notifications",
                 notificationItem("High Priority", "3 submissions overdue", icon = icon("exclamation-triangle")),
                 notificationItem("Review Required", "5 documents pending review", icon = icon("file-alt"))),
    dropdownMenu(type = "tasks",
                 taskItem("Protocol Review", "40%", icon = icon("clipboard")),
                 taskItem("Data Analysis", "75%", icon = icon("chart-bar")))
  ),
  
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Studies", tabName = "studies", icon = icon("flask")),
      menuItem("Submissions", tabName = "submissions", icon = icon("file-alt")),
      menuItem("Tasks", tabName = "tasks", icon = icon("tasks")),
      menuItem("Documents", tabName = "documents", icon = icon("folder")),
      menuItem("Timeline", tabName = "timeline", icon = icon("calendar")),
      menuItem("Quality Control", tabName = "quality", icon = icon("check-circle")),
      menuItem("Reports", tabName = "reports", icon = icon("chart-line")),
      menuItem("Settings", tabName = "settings", icon = icon("cog"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Dashboard Tab
      tabItem(tabName = "dashboard",
        fluidRow(
          box(
            title = "Submission Overview", status = "primary", solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(3, valueBoxOutput("totalSubmissions")),
              column(3, valueBoxOutput("submittedSubmissions")),
              column(3, valueBoxOutput("onTimeSubmissions")),
              column(3, valueBoxOutput("overdueTasks"))
            )
          )
        ),
        fluidRow(
          box(
            title = "Submission Status", status = "info", solidHeader = TRUE,
            width = 6,
            plotOutput("submissionStatusPlot")
          ),
          box(
            title = "Task Progress", status = "warning", solidHeader = TRUE,
            width = 6,
            plotOutput("taskProgressPlot")
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
      
      # Studies Tab
      tabItem(tabName = "studies",
        fluidRow(
          box(
            title = "Study Management", status = "primary", solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(3,
                selectInput("studyFilter", "Filter by Phase:", 
                           choices = c("All", "I", "II", "III", "BE", "IV"),
                           selected = "All")
              ),
              column(3,
                selectInput("statusFilter", "Filter by Status:",
                           choices = c("All", "In Progress", "Completed", "Planning"),
                           selected = "All")
              ),
              column(3,
                actionButton("addStudy", "Add Study", class = "btn-success")
              ),
              column(3,
                actionButton("exportStudies", "Export Studies", class = "btn-info")
              )
            )
          )
        ),
        fluidRow(
          box(
            title = "Study List", status = "info", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("studiesTable")
          )
        )
      ),
      
      # Submissions Tab
      tabItem(tabName = "submissions",
        fluidRow(
          box(
            title = "Submission Pipeline", status = "primary", solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(3,
                selectInput("submissionType", "Filter by Type:",
                           choices = c("All", "IND", "NDA", "BLA", "ANDA", "PAS"),
                           selected = "All")
              ),
              column(3,
                selectInput("submissionStatus", "Filter by Status:",
                           choices = c("All", "Submitted", "In Progress", "Pending"),
                           selected = "All")
              ),
              column(3,
                selectInput("submissionPriority", "Filter by Priority:",
                           choices = c("All", "High", "Medium", "Low"),
                           selected = "All")
              ),
              column(3,
                actionButton("addSubmission", "Add Submission", class = "btn-success")
              )
            )
          )
        ),
        fluidRow(
          box(
            title = "Submission Timeline", status = "info", solidHeader = TRUE,
            width = 12,
            plotOutput("submissionTimeline", height = "400px")
          )
        ),
        fluidRow(
          box(
            title = "Submission Details", status = "warning", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("submissionsTable")
          )
        )
      ),
      
      # Tasks Tab
      tabItem(tabName = "tasks",
        fluidRow(
          box(
            title = "Task Management", status = "primary", solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(2,
                selectInput("taskAssignee", "Assignee:",
                           choices = c("All", "John Smith", "Jane Doe", "Mike Johnson", "Sarah Wilson", "Tom Brown"),
                           selected = "All")
              ),
              column(2,
                selectInput("taskStatus", "Status:",
                           choices = c("All", "Completed", "In Progress", "Not Started"),
                           selected = "All")
              ),
              column(2,
                selectInput("taskType", "Type:",
                           choices = c("All", "Development", "Analysis", "Writing", "Review", "Submission"),
                           selected = "All")
              ),
              column(2,
                dateInput("taskDueDate", "Due Date:", value = NULL)
              ),
              column(2,
                actionButton("addTask", "Add Task", class = "btn-success")
              ),
              column(2,
                actionButton("exportTasks", "Export Tasks", class = "btn-info")
              )
            )
          )
        ),
        fluidRow(
          box(
            title = "Task Board", status = "info", solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(4,
                h4("Not Started"),
                div(style = "height: 400px; overflow-y: auto; border: 1px solid #ddd; padding: 10px;",
                    uiOutput("notStartedTasks"))
              ),
              column(4,
                h4("In Progress"),
                div(style = "height: 400px; overflow-y: auto; border: 1px solid #ddd; padding: 10px;",
                    uiOutput("inProgressTasks"))
              ),
              column(4,
                h4("Completed"),
                div(style = "height: 400px; overflow-y: auto; border: 1px solid #ddd; padding: 10px;",
                    uiOutput("completedTasks"))
              )
            )
          )
        )
      ),
      
      # Documents Tab
      tabItem(tabName = "documents",
        fluidRow(
          box(
            title = "Document Repository", status = "primary", solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(3,
                selectInput("docType", "Document Type:",
                           choices = c("All", "Protocol", "Report", "Analysis", "Letter", "Form", "Dataset"),
                           selected = "All")
              ),
              column(3,
                selectInput("docStatus", "Status:",
                           choices = c("All", "Draft", "Review", "Approved", "Final"),
                           selected = "All")
              ),
              column(3,
                actionButton("uploadDoc", "Upload Document", class = "btn-success")
              ),
              column(3,
                actionButton("generateReport", "Generate Report", class = "btn-info")
              )
            )
          )
        ),
        fluidRow(
          box(
            title = "Document Library", status = "info", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("documentsTable")
          )
        )
      ),
      
      # Timeline Tab
      tabItem(tabName = "timeline",
        fluidRow(
          box(
            title = "Regulatory Timeline", status = "primary", solidHeader = TRUE,
            width = 12,
            plotlyOutput("ganttChart", height = "600px")
          )
        )
      ),
      
      # Quality Control Tab
      tabItem(tabName = "quality",
        fluidRow(
          box(
            title = "Quality Metrics", status = "primary", solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(6,
                h4("Document Quality"),
                plotOutput("docQualityPlot")
              ),
              column(6,
                h4("Task Completion Rate"),
                plotOutput("completionRatePlot")
              )
            )
          )
        ),
        fluidRow(
          box(
            title = "Validation Results", status = "info", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("validationTable")
          )
        )
      ),
      
      # Reports Tab
      tabItem(tabName = "reports",
        fluidRow(
          box(
            title = "Submission Reports", status = "primary", solidHeader = TRUE,
            width = 12,
            h4("Generate Reports"),
            fluidRow(
              column(4,
                selectInput("reportType", "Report Type:",
                           choices = c("Weekly Summary", "Monthly Dashboard", "Submission Status", "Task Performance"),
                           selected = "Weekly Summary")
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
      
      # Settings Tab
      tabItem(tabName = "settings",
        fluidRow(
          box(
            title = "System Settings", status = "primary", solidHeader = TRUE,
            width = 12,
            h4("Notification Settings"),
            checkboxInput("emailNotifications", "Email Notifications", TRUE),
            checkboxInput("deadlineAlerts", "Deadline Alerts", TRUE),
            checkboxInput("statusUpdates", "Status Updates", TRUE),
            br(),
            h4("User Preferences"),
            selectInput("defaultView", "Default View:",
                       choices = c("Dashboard", "Tasks", "Submissions"),
                       selected = "Dashboard"),
            numericInput("itemsPerPage", "Items per Page:", value = 10, min = 5, max = 50),
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
  regulatory_data <- reactiveVal(generate_regulatory_data())
  metrics <- reactive(calculate_submission_metrics(regulatory_data()))
  
  # Dashboard outputs
  output$totalSubmissions <- renderValueBox({
    valueBox(
      value = metrics()$total_submissions,
      subtitle = "Total Submissions",
      icon = icon("file-alt"),
      color = "blue"
    )
  })
  
  output$submittedSubmissions <- renderValueBox({
    valueBox(
      value = metrics()$submitted_submissions,
      subtitle = "Submitted",
      icon = icon("check-circle"),
      color = "green"
    )
  })
  
  output$onTimeSubmissions <- renderValueBox({
    valueBox(
      value = metrics()$on_time_submissions,
      subtitle = "On Time",
      icon = icon("clock"),
      color = "yellow"
    )
  })
  
  output$overdueTasks <- renderValueBox({
    valueBox(
      value = metrics()$overdue_tasks,
      subtitle = "Overdue Tasks",
      icon = icon("exclamation-triangle"),
      color = "red"
    )
  })
  
  # Submission status plot
  output$submissionStatusPlot <- renderPlot({
    submissions <- regulatory_data()$submissions
    status_counts <- submissions %>% count(STATUS)
    
    ggplot(status_counts, aes(x = STATUS, y = n, fill = STATUS)) +
      geom_col() +
      geom_text(aes(label = n), vjust = -0.5) +
      labs(title = "Submission Status Distribution",
           x = "Status", y = "Count") +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  # Task progress plot
  output$taskProgressPlot <- renderPlot({
    tasks <- regulatory_data()$tasks
    status_counts <- tasks %>% count(STATUS)
    
    ggplot(status_counts, aes(x = STATUS, y = n, fill = STATUS)) +
      geom_col() +
      geom_text(aes(label = n), vjust = -0.5) +
      labs(title = "Task Status Distribution",
           x = "Status", y = "Count") +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  # Upcoming deadlines
  output$upcomingDeadlines <- DT::renderDataTable({
    submissions <- regulatory_data()$submissions
    today <- Sys.Date()
    
    upcoming <- submissions %>%
      filter(STATUS != "Submitted", TARGET_DATE >= today) %>%
      mutate(Days_Until_Due = as.numeric(TARGET_DATE - today)) %>%
      arrange(TARGET_DATE) %>%
      select(SUBMISSION_ID, SUBMISSION_NAME, TARGET_DATE, Days_Until_Due, STATUS, PRIORITY) %>%
      head(10)
    
    DT::datatable(upcoming, options = list(pageLength = 10))
  })
  
  # Studies table
  output$studiesTable <- DT::renderDataTable({
    studies <- regulatory_data()$studies
    
    if (input$studyFilter != "All") {
      studies <- studies %>% filter(STUDY_PHASE == input$studyFilter)
    }
    
    if (input$statusFilter != "All") {
      studies <- studies %>% filter(STATUS == input$statusFilter)
    }
    
    DT::datatable(studies, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  # Submission timeline
  output$submissionTimeline <- renderPlot({
    submissions <- regulatory_data()$submissions
    
    # Create timeline data
    timeline_data <- submissions %>%
      select(SUBMISSION_ID, SUBMISSION_NAME, TARGET_DATE, ACTUAL_DATE, STATUS) %>%
      pivot_longer(cols = c(TARGET_DATE, ACTUAL_DATE), 
                   names_to = "Date_Type", 
                   values_to = "Date") %>%
      filter(!is.na(Date))
    
    ggplot(timeline_data, aes(x = Date, y = SUBMISSION_NAME, color = Date_Type)) +
      geom_point(size = 3) +
      geom_line(aes(group = SUBMISSION_ID), alpha = 0.3) +
      scale_color_manual(values = c("TARGET_DATE" = "blue", "ACTUAL_DATE" = "red")) +
      labs(title = "Submission Timeline",
           x = "Date", y = "Submission") +
      theme_minimal()
  })
  
  # Submissions table
  output$submissionsTable <- DT::renderDataTable({
    submissions <- regulatory_data()$submissions
    
    if (input$submissionType != "All") {
      submissions <- submissions %>% filter(SUBMISSION_TYPE == input$submissionType)
    }
    
    if (input$submissionStatus != "All") {
      submissions <- submissions %>% filter(STATUS == input$submissionStatus)
    }
    
    if (input$submissionPriority != "All") {
      submissions <- submissions %>% filter(PRIORITY == input$submissionPriority)
    }
    
    DT::datatable(submissions, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  # Task board outputs
  output$notStartedTasks <- renderUI({
    tasks <- regulatory_data()$tasks
    
    if (input$taskStatus != "All") {
      tasks <- tasks %>% filter(STATUS == input$taskStatus)
    }
    
    not_started <- tasks %>% filter(STATUS == "Not Started")
    
    if (nrow(not_started) > 0) {
      lapply(1:nrow(not_started), function(i) {
        div(class = "well",
            h5(not_started$TASK_NAME[i]),
            p("Assigned to:", not_started$ASSIGNED_TO[i]),
            p("Due:", not_started$DUE_DATE[i]),
            progressBar(not_started$PERCENT_COMPLETE[i], "info")
        )
      })
    } else {
      p("No tasks in this category")
    }
  })
  
  output$inProgressTasks <- renderUI({
    tasks <- regulatory_data()$tasks
    
    if (input$taskStatus != "All") {
      tasks <- tasks %>% filter(STATUS == input$taskStatus)
    }
    
    in_progress <- tasks %>% filter(STATUS == "In Progress")
    
    if (nrow(in_progress) > 0) {
      lapply(1:nrow(in_progress), function(i) {
        div(class = "well",
            h5(in_progress$TASK_NAME[i]),
            p("Assigned to:", in_progress$ASSIGNED_TO[i]),
            p("Due:", in_progress$DUE_DATE[i]),
            progressBar(in_progress$PERCENT_COMPLETE[i], "warning")
        )
      })
    } else {
      p("No tasks in this category")
    }
  })
  
  output$completedTasks <- renderUI({
    tasks <- regulatory_data()$tasks
    
    if (input$taskStatus != "All") {
      tasks <- tasks %>% filter(STATUS == input$taskStatus)
    }
    
    completed <- tasks %>% filter(STATUS == "Completed")
    
    if (nrow(completed) > 0) {
      lapply(1:nrow(completed), function(i) {
        div(class = "well",
            h5(completed$TASK_NAME[i]),
            p("Assigned to:", completed$ASSIGNED_TO[i]),
            p("Completed:", completed$COMPLETION_DATE[i]),
            progressBar(completed$PERCENT_COMPLETE[i], "success")
        )
      })
    } else {
      p("No tasks in this category")
    }
  })
  
  # Documents table
  output$documentsTable <- DT::renderDataTable({
    documents <- regulatory_data()$documents
    
    if (input$docType != "All") {
      documents <- documents %>% filter(DOC_TYPE == input$docType)
    }
    
    if (input$docStatus != "All") {
      documents <- documents %>% filter(STATUS == input$docStatus)
    }
    
    DT::datatable(documents, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  # Gantt chart
  output$ganttChart <- renderPlotly({
    submissions <- regulatory_data()$submissions
    tasks <- regulatory_data()$tasks
    
    # Create Gantt chart data
    gantt_data <- tasks %>%
      select(TASK_ID, TASK_NAME, START_DATE, DUE_DATE, STATUS) %>%
      mutate(
        START_DATE = as.Date(START_DATE),
        DUE_DATE = as.Date(DUE_DATE)
      )
    
    p <- plot_ly() %>%
      add_trace(data = gantt_data,
               x = gantt_data$START_DATE, 
               xend = gantt_data$DUE_DATE,
               y = gantt_data$TASK_NAME,
               type = 'scatter',
               mode = 'lines',
               line = list(width = 20),
               color = gantt_data$STATUS,
               colors = c("Completed" = "green", "In Progress" = "orange", "Not Started" = "red")) %>%
      layout(title = "Regulatory Submission Gantt Chart",
             xaxis = list(title = "Date"),
             yaxis = list(title = "Tasks"),
             showlegend = TRUE)
    
    p
  })
  
  # Quality plots
  output$docQualityPlot <- renderPlot({
    documents <- regulatory_data()$documents
    doc_counts <- documents %>% count(STATUS)
    
    ggplot(doc_counts, aes(x = STATUS, y = n, fill = STATUS)) +
      geom_col() +
      labs(title = "Document Quality Status",
           x = "Status", y = "Count") +
      theme_minimal()
  })
  
  output$completionRatePlot <- renderPlot({
    tasks <- regulatory_data()$tasks
    completion_by_assignee <- tasks %>%
      group_by(ASSIGNED_TO) %>%
      summarise(completion_rate = mean(PERCENT_COMPLETE, na.rm = TRUE)) %>%
      arrange(desc(completion_rate))
    
    ggplot(completion_by_assignee, aes(x = reorder(ASSIGNED_TO, completion_rate), y = completion_rate)) +
      geom_col(fill = "steelblue") +
      coord_flip() +
      labs(title = "Task Completion Rate by Assignee",
           x = "Assignee", y = "Completion Rate (%)") +
      theme_minimal()
  })
  
  # Validation table
  output$validationTable <- DT::renderDataTable({
    validation_data <- data.frame(
      Validation_Check = c("Document Completeness", "Data Consistency", "Format Compliance", 
                          "Sign-off Required", "QA Review"),
      Status = c("Passed", "Failed", "Passed", "Pending", "Passed"),
      Last_Run = as.Date(c("2024-01-30", "2024-01-29", "2024-01-30", "2024-01-28", "2024-01-30")),
      Issues_Found = c(0, 3, 0, 1, 0)
    )
    
    DT::datatable(validation_data, options = list(pageLength = 10))
  })
  
  # Report generation
  output$reportOutput <- renderText({
    if (input$generateReportBtn > 0) {
      paste("Report generated:", input$reportType, "for", input$reportDate)
    }
  })
}

# Run the app
shinyApp(ui, server)
