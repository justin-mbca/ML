# Clinical Trial Management Suite
# Combines: Clinical Data Viewer, PharmacoModel, Regulatory Tracker, GxP Compliance
# Senior Shiny Developer Portfolio - Merged Application

library(shiny)
library(shinydashboard)
library(plotly)
library(DT)
library(dplyr)
library(tidyr)
library(ggplot2)

# ============================================================================
# DATA GENERATION FUNCTIONS
# ============================================================================

# Generate Clinical Data (CDISC-like)
generate_clinical_data <- function() {
  set.seed(123)
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
  
  vs <- data.frame(
    STUDYID = rep("STUDY001", 500),
    SUBJID = sample(dm$SUBJID, 500, replace = TRUE),
    VISIT = sample(c("Baseline", "Week 4", "Week 8"), 500, replace = TRUE),
    VSTESTCD = rep(c("SYSBP", "DIABP", "PULSE", "TEMP", "WEIGHT"), 100),
    VSORRES = c(
      rnorm(100, 120, 15), rnorm(100, 80, 10),
      rnorm(100, 72, 10), rnorm(100, 98.6, 0.5),
      rnorm(100, 70, 10)
    ),
    stringsAsFactors = FALSE
  )
  
  list(dm = dm, vs = vs)
}

# Generate PK Data
generate_pk_data <- function() {
  set.seed(123)
  n_subj <- 50
  subjects <- data.frame(
    SUBJID = paste0("SUBJ", sprintf("%03d", 1:n_subj)),
    ARM = sample(c("Low Dose", "Medium Dose", "High Dose"), n_subj, replace = TRUE),
    WEIGHT = rnorm(n_subj, 70, 10),
    stringsAsFactors = FALSE
  )
  
  dose_map <- c("Low Dose" = 50, "Medium Dose" = 100, "High Dose" = 200)
  subjects$DOSE <- dose_map[subjects$ARM]
  
  time_points <- c(0, 0.5, 1, 2, 4, 6, 8, 12, 24)
  pk_data <- data.frame()
  
  for(i in 1:n_subj) {
    subj <- subjects[i, ]
    ka <- 0.8
    ke <- 0.1
    vd <- 50
    
    for(t in time_points) {
      if(t == 0) {
        conc <- 0
      } else {
        conc <- (subj$DOSE * ka) / (vd * (ka - ke)) * (exp(-ke * t) - exp(-ka * t))
        conc <- conc * (1 + rnorm(1, 0, 0.1))
      }
      
      pk_data <- rbind(pk_data, data.frame(
        SUBJID = subj$SUBJID,
        TIME = t,
        CONC = max(conc, 0),
        ARM = subj$ARM,
        DOSE = subj$DOSE
      ))
    }
  }
  
  list(subjects = subjects, pk_data = pk_data)
}

# Generate Regulatory Data
generate_regulatory_data <- function() {
  data.frame(
    Module = c("Module 1", "Module 2", "Module 3", "Module 4", "Module 5"),
    Description = c("Administrative", "Summaries", "Quality", "Nonclinical", "Clinical"),
    Status = sample(c("Complete", "In Progress", "Pending"), 5, replace = TRUE),
    Progress = sample(60:100, 5),
    Due_Date = seq(as.Date("2026-03-01"), by = "month", length.out = 5),
    stringsAsFactors = FALSE
  )
}

# Generate GxP Compliance Data
generate_gxp_data <- function() {
  data.frame(
    System = rep(c("LIMS", "ELN", "EDMS", "QMS"), 3),
    Check = rep(c("Audit Trail", "Access Control", "Data Integrity"), each = 4),
    Status = sample(c("Pass", "Pass", "Pass", "Fail"), 12, replace = TRUE),
    Last_Check = seq(as.Date("2026-01-01"), by = "week", length.out = 12),
    stringsAsFactors = FALSE
  )
}

# ============================================================================
# UI
# ============================================================================

ui <- dashboardPage(
  dashboardHeader(title = "Clinical Trial Management Suite"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("Clinical Data Viewer", tabName = "clinical", icon = icon("table")),
      menuItem("PK/PD Analysis", tabName = "pkpd", icon = icon("line-chart")),
      menuItem("Regulatory Tracking", tabName = "regulatory", icon = icon("file-text")),
      menuItem("GxP Compliance", tabName = "gxp", icon = icon("check-circle"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Overview Tab
      tabItem(tabName = "overview",
        h2("Clinical Trial Management Suite"),
        fluidRow(
          valueBoxOutput("totalSubjects"),
          valueBoxOutput("activeStudies"),
          valueBoxOutput("complianceRate")
        ),
        fluidRow(
          box(title = "Suite Components", width = 12, solidHeader = TRUE, status = "primary",
              tags$ul(
                tags$li(tags$b("Clinical Data Viewer:"), "CDISC SDTM/ADaM dataset visualization"),
                tags$li(tags$b("PK/PD Analysis:"), "Pharmacokinetic modeling and simulation"),
                tags$li(tags$b("Regulatory Tracking:"), "Submission pipeline management"),
                tags$li(tags$b("GxP Compliance:"), "Quality and compliance monitoring")
              )
          )
        )
      ),
      
      # Clinical Data Viewer Tab
      tabItem(tabName = "clinical",
        h2("Clinical Data Viewer (CDISC SDTM)"),
        fluidRow(
          box(title = "Demographics (DM)", width = 12,
              DTOutput("dmTable"))
        ),
        fluidRow(
          box(title = "Vital Signs Distribution", width = 6,
              plotlyOutput("vsPlot")),
          box(title = "Subject Summary", width = 6,
              DTOutput("subjectSummary"))
        )
      ),
      
      # PK/PD Analysis Tab
      tabItem(tabName = "pkpd",
        h2("Pharmacokinetic Analysis"),
        fluidRow(
          box(title = "Concentration-Time Profiles", width = 12,
              plotlyOutput("pkPlot", height = "400px"))
        ),
        fluidRow(
          box(title = "PK Parameters by Subject", width = 12,
              DTOutput("pkParamsTable"))
        )
      ),
      
      # Regulatory Tracking Tab
      tabItem(tabName = "regulatory",
        h2("Regulatory Submission Tracking"),
        fluidRow(
          box(title = "Submission Modules", width = 12,
              DTOutput("regulatoryTable"))
        ),
        fluidRow(
          box(title = "Module Progress", width = 12,
              plotlyOutput("progressPlot"))
        )
      ),
      
      # GxP Compliance Tab
      tabItem(tabName = "gxp",
        h2("GxP Compliance Monitor"),
        fluidRow(
          valueBoxOutput("passRate"),
          valueBoxOutput("totalChecks"),
          valueBoxOutput("lastAudit")
        ),
        fluidRow(
          box(title = "Compliance Checks", width = 12,
              DTOutput("gxpTable"))
        ),
        fluidRow(
          box(title = "Compliance by System", width = 12,
              plotlyOutput("gxpPlot"))
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
  clinical_data <- reactiveVal(generate_clinical_data())
  pk_data <- reactiveVal(generate_pk_data())
  regulatory_data <- reactiveVal(generate_regulatory_data())
  gxp_data <- reactiveVal(generate_gxp_data())
  
  # Overview Value Boxes
  output$totalSubjects <- renderValueBox({
    valueBox(
      value = nrow(clinical_data()$dm),
      subtitle = "Total Subjects",
      icon = icon("users"),
      color = "blue"
    )
  })
  
  output$activeStudies <- renderValueBox({
    valueBox(
      value = length(unique(clinical_data()$dm$STUDYID)),
      subtitle = "Active Studies",
      icon = icon("flask"),
      color = "green"
    )
  })
  
  output$complianceRate <- renderValueBox({
    pass_rate <- round(mean(gxp_data()$Status == "Pass") * 100, 1)
    valueBox(
      value = paste0(pass_rate, "%"),
      subtitle = "Compliance Rate",
      icon = icon("check"),
      color = if(pass_rate >= 90) "green" else "yellow"
    )
  })
  
  # Clinical Data Viewer Outputs
  output$dmTable <- renderDT({
    datatable(clinical_data()$dm, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  output$vsPlot <- renderPlotly({
    vs_data <- clinical_data()$vs %>%
      filter(VSTESTCD == "SYSBP")
    
    p <- ggplot(vs_data, aes(x = VISIT, y = VSORRES)) +
      geom_boxplot(fill = "steelblue", alpha = 0.7) +
      labs(title = "Systolic BP by Visit", x = "Visit", y = "SBP (mmHg)") +
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$subjectSummary <- renderDT({
    summary_data <- clinical_data()$dm %>%
      group_by(ARM, SEX) %>%
      summarise(
        N = n(),
        Mean_Age = round(mean(AGE), 1),
        .groups = "drop"
      )
    
    datatable(summary_data, options = list(dom = 't'))
  })
  
  # PK/PD Outputs
  output$pkPlot <- renderPlotly({
    pk <- pk_data()$pk_data
    
    pk_summary <- pk %>%
      group_by(ARM, TIME) %>%
      summarise(
        mean_conc = mean(CONC),
        sd_conc = sd(CONC),
        .groups = "drop"
      )
    
    p <- ggplot(pk_summary, aes(x = TIME, y = mean_conc, color = ARM)) +
      geom_line(size = 1.2) +
      geom_ribbon(aes(ymin = mean_conc - sd_conc, ymax = mean_conc + sd_conc, fill = ARM), alpha = 0.2) +
      scale_y_log10() +
      labs(title = "Mean Concentration-Time Profiles",
           x = "Time (hours)", y = "Concentration (ng/mL, log scale)") +
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$pkParamsTable <- renderDT({
    pk <- pk_data()$pk_data
    
    pk_params <- pk %>%
      filter(TIME > 0, CONC > 0) %>%
      group_by(SUBJID, ARM) %>%
      summarise(
        Cmax = round(max(CONC), 2),
        Tmax = TIME[which.max(CONC)],
        AUC = round(sum(CONC * diff(c(0, TIME))), 2),
        .groups = "drop"
      )
    
    datatable(pk_params, options = list(pageLength = 10))
  })
  
  # Regulatory Outputs
  output$regulatoryTable <- renderDT({
    datatable(regulatory_data(), options = list(dom = 't'))
  })
  
  output$progressPlot <- renderPlotly({
    p <- ggplot(regulatory_data(), aes(x = Module, y = Progress, fill = Status)) +
      geom_bar(stat = "identity") +
      geom_text(aes(label = paste0(Progress, "%")), vjust = -0.5) +
      labs(title = "Module Completion Progress", y = "Progress (%)") +
      theme_minimal() +
      ylim(0, 110)
    
    ggplotly(p)
  })
  
  # GxP Compliance Outputs
  output$passRate <- renderValueBox({
    pass_rate <- round(mean(gxp_data()$Status == "Pass") * 100, 1)
    valueBox(
      value = paste0(pass_rate, "%"),
      subtitle = "Pass Rate",
      icon = icon("check-circle"),
      color = if(pass_rate >= 90) "green" else "red"
    )
  })
  
  output$totalChecks <- renderValueBox({
    valueBox(
      value = nrow(gxp_data()),
      subtitle = "Total Checks",
      icon = icon("list"),
      color = "blue"
    )
  })
  
  output$lastAudit <- renderValueBox({
    valueBox(
      value = as.character(max(gxp_data()$Last_Check)),
      subtitle = "Last Audit",
      icon = icon("calendar"),
      color = "purple"
    )
  })
  
  output$gxpTable <- renderDT({
    datatable(gxp_data(), options = list(pageLength = 10))
  })
  
  output$gxpPlot <- renderPlotly({
    gxp_summary <- gxp_data() %>%
      group_by(System, Status) %>%
      summarise(Count = n(), .groups = "drop")
    
    p <- ggplot(gxp_summary, aes(x = System, y = Count, fill = Status)) +
      geom_bar(stat = "identity", position = "dodge") +
      labs(title = "Compliance Status by System") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p)
  })
}

# Run the app
shinyApp(ui, server)
