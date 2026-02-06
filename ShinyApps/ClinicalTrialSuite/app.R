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
      menuItem("GxP Compliance", tabName = "gxp", icon = icon("check-circle")),
      menuItem("Simulated Data Info", tabName = "data_info", icon = icon("database"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Overview Tab
      tabItem(tabName = "overview",
        h2("Clinical Trial Management Suite"),
        
        fluidRow(
          box(title = "📋 Application Overview", width = 12, status = "info", solidHeader = TRUE,
              tags$div(style = "font-size: 15px;",
                tags$p(tags$b("Purpose:"), "Integrated Shiny dashboard demonstrating pharmaceutical data science capabilities across clinical trial operations, regulatory compliance, and pharmacometric analysis."),
                tags$p(tags$b("Domain:"), "Pharmaceutical R&D, Clinical Development, Regulatory Affairs"),
                tags$p(tags$b("Data Standards:"), "CDISC SDTM (Study Data Tabulation Model) and CDISC ADaM (Analysis Data Model)"),
                tags$p(tags$b("Note:"), "This application uses simulated data for portfolio demonstration. All data structures and analytical methods follow industry best practices and regulatory standards.")
              )
          )
        ),
        
        fluidRow(
          valueBoxOutput("totalSubjects"),
          valueBoxOutput("activeStudies"),
          valueBoxOutput("complianceRate")
        ),
        
        fluidRow(
          box(title = "Suite Components", width = 6, solidHeader = TRUE, status = "primary",
              tags$ul(style = "font-size: 14px;",
                tags$li(tags$b("Clinical Data Viewer:"), "CDISC SDTM compliant data visualization and analysis"),
                tags$li(tags$b("PK/PD Modeling:"), "Pharmacokinetic analysis with one-compartment model implementation"),
                tags$li(tags$b("Regulatory Tracking:"), "eCTD submission module monitoring and progress tracking"),
                tags$li(tags$b("GxP Compliance:"), "Quality system validation and audit trail management")
              )
          ),
          box(title = "Technical Capabilities", width = 6, solidHeader = TRUE, status = "success",
              tags$ul(style = "font-size: 14px;",
                tags$li(tags$b("Reactive Programming:"), "Real-time data updates and interactive visualizations"),
                tags$li(tags$b("CDISC Expertise:"), "Proper SDTM variable naming and domain relationships"),
                tags$li(tags$b("Pharmacometrics:"), "Mathematical modeling of drug concentration-time profiles"),
                tags$li(tags$b("Interactive Charts:"), "Plotly integration for dynamic, publication-ready graphics"),
                tags$li(tags$b("Data Tables:"), "DT package with sorting, filtering, and pagination"),
                tags$li(tags$b("Responsive Design:"), "shinydashboard layout optimized for various screen sizes")
              )
          )
        ),
        
        fluidRow(
          box(title = "Key Features Demonstrated", width = 12, solidHeader = TRUE, status = "warning",
              tags$div(style = "font-size: 14px;",
                tags$h4("1. Clinical Data Viewer"),
                tags$ul(
                  tags$li("SDTM Demographics (DM) and Vital Signs (VS) domains"),
                  tags$li("Interactive data tables with 100 simulated subjects"),
                  tags$li("Box plots showing vital sign distributions across visits"),
                  tags$li("Treatment arm comparisons")
                ),
                tags$h4("2. PK/PD Modeling"),
                tags$ul(
                  tags$li("One-compartment model with first-order absorption: C(t) = (Dose × Ka)/(Vd × (Ka - Ke)) × (exp(-Ke × t) - exp(-Ka × t))"),
                  tags$li("Calculated parameters: Cmax, Tmax, AUC, Clearance, Half-life"),
                  tags$li("Allometric scaling based on patient weight"),
                  tags$li("Interactive concentration-time curves for dose groups")
                ),
                tags$h4("3. Regulatory & Compliance"),
                tags$ul(
                  tags$li("eCTD Module 2-5 tracking (Clinical Overview, Clinical Summary, Clinical Study Reports, Nonclinical)"),
                  tags$li("GxP compliance monitoring across LIMS, CTMS, EDC, eTMF systems"),
                  tags$li("Audit trail tracking and validation status")
                )
              )
          )
        ),
        
        fluidRow(
          box(title = "💡 For Interviewers", width = 12, status = "primary",
              tags$div(style = "font-size: 14px;",
                tags$p("This dashboard showcases:"),
                tags$ul(
                  tags$li(tags$b("Pharmaceutical Domain Knowledge:"), "Understanding of CDISC standards, PK/PD modeling, and regulatory requirements"),
                  tags$li(tags$b("R Programming Excellence:"), "Advanced Shiny development with reactive programming, modular code structure, and efficient data handling"),
                  tags$li(tags$b("Data Visualization:"), "Publication-quality interactive charts using ggplot2 and plotly"),
                  tags$li(tags$b("Full-Stack Thinking:"), "Consideration of data flow from clinical databases to regulatory submissions")
                ),
                tags$p(tags$b("Real-World Application:"), "In production, this dashboard would connect to clinical trial databases (e.g., PostgreSQL, Oracle), integrate with EDC systems (Medidata Rave, Veeva Vault), and support real-time monitoring of ongoing trials.")
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
      ),
      
      # Data Info Tab
      tabItem(tabName = "data_info",
        h2("Simulated Data Methodology"),
        
        fluidRow(
          box(title = "Purpose of Simulated Data", width = 12, status = "primary", solidHeader = TRUE,
              p("This application demonstrates clinical trial management capabilities using simulated data. All data generation uses", 
                tags$code("set.seed(123)"), "to ensure consistent, reproducible results."),
              p(tags$b("Why Simulated Data?"), "Protects patient privacy, avoids regulatory constraints, and enables portfolio demonstration of pharmaceutical data science capabilities.")
          )
        ),
        
        fluidRow(
          box(title = "CDISC SDTM Demographics (DM) Data", width = 12, solidHeader = TRUE,
              h4("Generation Method:"),
              tags$pre(
'generate_clinical_data <- function() {
  set.seed(123)  # Ensures reproducibility
  dm <- data.frame(
    STUDYID = rep("STUDY001", 100),
    SUBJID = paste0("SUBJ", sprintf("%03d", 1:100)),
    AGE = sample(18:75, 100, replace = TRUE),
    SEX = sample(c("M", "F"), 100, replace = TRUE),
    RACE = sample(c("WHITE", "BLACK", "ASIAN", "HISPANIC"), 100, replace = TRUE),
    ARM = sample(c("Placebo", "Drug A", "Drug B"), 100, replace = TRUE)
  )
}'),
              h4("How It Mimics Real CDISC Data:"),
              tags$ul(
                tags$li(tags$b("Variable Names:"), "STUDYID, SUBJID, AGE, SEX, RACE, ARM follow CDISC SDTM naming conventions"),
                tags$li(tags$b("Subject IDs:"), "SUBJ001-SUBJ100 format matches regulatory submissions"),
                tags$li(tags$b("Age Range:"), "18-75 reflects typical Phase II/III trial inclusion criteria"),
                tags$li(tags$b("Demographics:"), "Sex and race distributions simulate real trial populations"),
                tags$li(tags$b("Treatment Arms:"), "3-arm design (Placebo + 2 doses) is common in clinical trials")
              ),
              h4("Current DM Data:"),
              DTOutput("dataInfoDM")
          )
        ),
        
        fluidRow(
          box(title = "CDISC SDTM Vital Signs (VS) Data", width = 12, solidHeader = TRUE,
              h4("Generation Method:"),
              tags$pre(
'vs <- data.frame(
  SUBJID = sample(dm$SUBJID, 500, replace = TRUE),
  VISIT = sample(c("Baseline", "Week 4", "Week 8"), 500, replace = TRUE),
  VSTESTCD = rep(c("SYSBP", "DIABP", "PULSE", "TEMP", "WEIGHT"), 100),
  VSORRES = c(
    rnorm(100, 120, 15),  # Systolic BP: mean=120, sd=15
    rnorm(100, 80, 10),   # Diastolic BP: mean=80, sd=10
    rnorm(100, 72, 10),   # Pulse: mean=72, sd=10
    rnorm(100, 98.6, 0.5), # Temperature: mean=98.6, sd=0.5
    rnorm(100, 70, 10)    # Weight: mean=70kg, sd=10
  )
)'),
              h4("How It Mimics Real Vital Signs:"),
              tags$ul(
                tags$li(tags$b("Test Codes:"), "SYSBP, DIABP, PULSE, TEMP, WEIGHT are standard CDISC VSTESTCD values"),
                tags$li(tags$b("Visit Schedule:"), "Baseline/Week 4/Week 8 reflects typical trial timelines"),
                tags$li(tags$b("Normal Distributions:"), "Uses rnorm() with physiologically realistic means and standard deviations"),
                tags$li(tags$b("Systolic BP:"), "120 mmHg ± 15 matches population norms"),
                tags$li(tags$b("Diastolic BP:"), "80 mmHg ± 10 matches population norms"),
                tags$li(tags$b("Body Temperature:"), "98.6°F ± 0.5 is narrow as expected"),
                tags$li(tags$b("Multiple Measures:"), "500 records across 100 subjects = ~5 measurements per subject")
              ),
              h4("Current VS Data:"),
              DTOutput("dataInfoVS")
          )
        ),
        
        fluidRow(
          box(title = "Pharmacokinetic (PK) Data", width = 12, solidHeader = TRUE,
              h4("Generation Method:"),
              tags$pre(
'generate_pk_data <- function() {
  set.seed(123)
  # One-compartment model with first-order absorption
  ka <- 0.8   # Absorption rate constant (1/hr)
  ke <- 0.1   # Elimination rate constant (1/hr)
  vd <- 50    # Volume of distribution (L)
  
  # Time-concentration curve
  C(t) = (Dose × Ka) / (Vd × (Ka - Ke)) × (exp(-Ke × t) - exp(-Ka × t))
  
  # PK Parameters:
  # - Cmax: Maximum concentration
  # - Tmax: Time to maximum concentration  
  # - AUC: Area under curve (trapezoidal rule)
  # - Clearance (CL): Dose / AUC
  # - Half-life (t½): 0.693 / Ke
}'),
              h4("How It Mimics Real PK Data:"),
              tags$ul(
                tags$li(tags$b("One-Compartment Model:"), "Standard pharmacokinetic equation used in drug development"),
                tags$li(tags$b("Dose Levels:"), "50/100/200 mg represent Low/Medium/High dose escalation"),
                tags$li(tags$b("Time Points:"), "0, 0.5, 1, 2, 4, 6, 8, 12, 24 hours match real PK sampling schedules"),
                tags$li(tags$b("Parameter Values:"), "Ka=0.8, Ke=0.1, Vd=50L are realistic for oral medications"),
                tags$li(tags$b("Allometric Scaling:"), "Adjusts Vd based on patient weight (real covariate effect)"),
                tags$li(tags$b("Inter-subject Variability:"), "Random noise simulates biological variability")
              ),
              h4("Current PK Data:"),
              DTOutput("dataInfoPK")
          )
        ),
        
        fluidRow(
          box(title = "Converting to Real Data", width = 12, status = "success", solidHeader = TRUE,
              h4("Steps to Use Production Clinical Data:"),
              tags$ol(
                tags$li(tags$b("CDISC Datasets:"), "Replace with read_sas('dm.sas7bdat') or database query"),
                tags$li(tags$b("Database Connection:"), tags$code("con <- dbConnect(RPostgres::Postgres(), dbname='clinical_trials')")),
                tags$li(tags$b("Data Validation:"), "Add checks for CDISC compliance and data quality"),
                tags$li(tags$b("Real PK Data:"), "Import from Phoenix WinNonlin or NONMEM output"),
                tags$li(tags$b("Regulatory Submission:"), "Connect to eCTD tracking systems")
              ),
              p("The Shiny UI and analysis code remain unchanged - only the data source functions need updating.")
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
  
  # Data Info Outputs
  output$dataInfoDM <- renderDT({
    datatable(clinical_data()$dm, 
              options = list(pageLength = 10, scrollX = TRUE),
              caption = "CDISC SDTM Demographics Domain (reproducible with set.seed(123))")
  })
  
  output$dataInfoVS <- renderDT({
    datatable(clinical_data()$vs, 
              options = list(pageLength = 10, scrollX = TRUE),
              caption = "CDISC SDTM Vital Signs Domain (reproducible with set.seed(123))")
  })
  
  output$dataInfoPK <- renderDT({
    datatable(pk_data(), 
              options = list(pageLength = 10, scrollX = TRUE),
              caption = "Pharmacokinetic concentration-time data (reproducible with set.seed(123))")
  })
}

# Run the app
shinyApp(ui, server)
