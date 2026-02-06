# Pharmaverse/Admiral Integration Demo (Simplified Version)
# Senior Shiny Developer Portfolio Project
# Demonstrates CDISC concepts with available packages

# Check and load required packages
required_packages <- c(
  "shiny", "shinydashboard", "DT", "plotly", "dplyr", "tidyr", "ggplot2", 
  "lubridate", "shinycssloaders", "shinyWidgets", "readr", "jsonlite"
)

missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]

if (length(missing_packages) > 0) {
  stop(
    "Missing required packages. Please install them using:\n\n",
    "install.packages(c('", paste(missing_packages, collapse = "', '"), "'))\n\n",
    "Note: admiral package requires R >= 4.3.0. This demo shows CDISC concepts with base R."
  )
}

# Load all packages
invisible(lapply(required_packages, library, character.only = TRUE))

# Installation helper function (for user convenience)
install_pharmaverse_demo_packages <- function() {
  cat("Installing required packages for Pharmaverse Demo (Simplified)...\n")
  
  # Install CRAN packages
  install.packages(required_packages, dependencies = TRUE)
  
  cat("All packages installed successfully!\n")
  cat("Note: For full admiral functionality, please upgrade to R >= 4.3.0\n")
  cat("You can now run the app: shiny::runApp()\n")
}

# Generate CDISC-compliant data using base R
generate_cdisc_data <- function() {
  # Demographics (DM) - CDISC SDTM structure
  dm <- data.frame(
    STUDYID = "STUDY001",
    SITEID = sample(paste0("SITE", sprintf("%02d", 1:10)), 100, replace = TRUE),
    USUBJID = paste0("SUBJ", sprintf("%04d", 1:100)),
    SUBJID = paste0("SUBJ", sprintf("%03d", 1:100)),
    BRTHDTC = sample(seq(as.Date("1970-01-01"), as.Date("1995-12-31"), by = "day"), 100, replace = TRUE),
    AGE = sample(18:75, 100, replace = TRUE),
    AGEU = "YEARS",
    SEX = sample(c("M", "F"), 100, replace = TRUE),
    RACE = sample(c("WHITE", "BLACK", "ASIAN", "HISPANIC"), 100, replace = TRUE),
    ETHNIC = sample(c("HISPANIC OR LATINO", "NOT HISPANIC OR LATINO"), 100, replace = TRUE),
    COUNTRY = "USA",
    ARMCD = sample(c("SCR", "PLA"), 100, replace = TRUE),
    ARM = ifelse(sample(c("SCR", "PLA"), 100, replace = TRUE) == "SCR", "Screening", "Placebo"),
    stringsAsFactors = FALSE
  )
  
  # Vital Signs (VS) - CDISC SDTM structure
  vs <- expand.grid(
    USUBJID = dm$USUBJID,
    VISIT = c("SCREENING", "BASELINE", "WEEK 2", "WEEK 4", "WEEK 8"),
    VSTESTCD = c("SYSBP", "DIABP", "PULSE", "TEMP", "WEIGHT", "HEIGHT")
  ) %>%
    mutate(
      STUDYID = "STUDY001",
      VSSEQ = row_number(),
      VSTEST = case_when(
        VSTESTCD == "SYSBP" ~ "Systolic Blood Pressure",
        VSTESTCD == "DIABP" ~ "Diastolic Blood Pressure",
        VSTESTCD == "PULSE" ~ "Pulse Rate",
        VSTESTCD == "TEMP" ~ "Temperature",
        VSTESTCD == "WEIGHT" ~ "Weight",
        VSTESTCD == "HEIGHT" ~ "Height"
      ),
      VSORRES = case_when(
        VSTESTCD == "SYSBP" ~ round(rnorm(n(), 120, 15), 1),
        VSTESTCD == "DIABP" ~ round(rnorm(n(), 80, 10), 1),
        VSTESTCD == "PULSE" ~ round(rnorm(n(), 72, 12), 0),
        VSTESTCD == "TEMP" ~ round(rnorm(n(), 98.6, 0.8), 1),
        VSTESTCD == "WEIGHT" ~ round(rnorm(n(), 70, 15), 1),
        VSTESTCD == "HEIGHT" ~ round(rnorm(n(), 170, 10), 1)
      ),
      VSORRESU = case_when(
        VSTESTCD %in% c("SYSBP", "DIABP") ~ "mmHg",
        VSTESTCD == "PULSE" ~ "bpm",
        VSTESTCD == "TEMP" ~ "F",
        VSTESTCD %in% c("WEIGHT", "HEIGHT") ~ "kg"
      ),
      VISITNUM = case_when(
        VISIT == "SCREENING" ~ 1,
        VISIT == "BASELINE" ~ 2,
        VISIT == "WEEK 2" ~ 3,
        VISIT == "WEEK 4" ~ 4,
        VISIT == "WEEK 8" ~ 5
      ),
      VSDTC = as.Date("2023-01-01") + sample(0:200, n(), replace = TRUE)
    ) %>%
    left_join(dm %>% select(USUBJID, ARMCD), by = "USUBJID")
  
  # Adverse Events (AE) - CDISC SDTM structure
  ae <- data.frame(
    STUDYID = "STUDY001",
    USUBJID = sample(dm$USUBJID, 50, replace = TRUE),
    AESEQ = 1:50,
    AETERM = sample(c("Headache", "Nausea", "Fatigue", "Dizziness", "Rash"), 50, replace = TRUE),
    AESEV = sample(c("MILD", "MODERATE", "SEVERE"), 50, replace = TRUE, prob = c(0.6, 0.3, 0.1)),
    AEREL = sample(c("RELATED", "NOT RELATED"), 50, replace = TRUE, prob = c(0.3, 0.7)),
    AEACN = sample(c("DOSE NOT INTERRUPT", "DOSE INTERRUPTED", "DRUG WITHDRAWN"), 50, replace = TRUE, prob = c(0.7, 0.2, 0.1)),
    AESTDTC = as.Date("2023-01-01") + sample(0:180, 50, replace = TRUE),
    AEENDTC = as.Date("2023-01-01") + sample(1:200, 50, replace = TRUE),
    stringsAsFactors = FALSE
  ) %>%
    left_join(dm %>% select(USUBJID, ARMCD), by = "USUBJID")
  
  # Create ADaM datasets (simplified)
  # Analysis Dataset for Demographics (ADSL)
  adsl <- dm %>%
    mutate(
      TRTSDT = as.Date("2023-01-01") + sample(0:30, n(), replace = TRUE),
      TRTEDT = TRTSDT + sample(7:180, n(), replace = TRUE),
      TRTDURD = as.numeric(TRTEDT - TRTSDT),
      RACEGR1 = case_when(
        RACE == "WHITE" ~ "WHITE",
        RACE == "BLACK" ~ "BLACK",
        RACE %in% c("ASIAN", "HISPANIC") ~ "OTHER",
        TRUE ~ "OTHER"
      )
    )
  
  # Analysis Dataset for Vital Signs (ADVS)
  advs <- vs %>%
    filter(VISIT %in% c("BASELINE", "WEEK 4", "WEEK 8")) %>%
    left_join(dm %>% select(USUBJID, AGE, SEX, ARMCD), by = "USUBJID") %>%
    mutate(
      PARAMCD = VSTESTCD,
      PARAM = VSTEST,
      AVAL = VSORRES,
      AVALC = as.character(round(AVAL, 2)),
      CHG = case_when(
        VISIT == "BASELINE" ~ NA_real_,
        TRUE ~ AVAL - lag(AVAL, default = first(AVAL))
      ),
      PCHG = case_when(
        VISIT == "BASELINE" ~ NA_real_,
        TRUE ~ (AVAL - lag(AVAL, default = first(AVAL))) / lag(AVAL, default = first(AVAL)) * 100
      )
    ) %>%
    arrange(USUBJID, VISITNUM, PARAMCD)
  
  return(list(
    dm = dm,
    vs = vs,
    ae = ae,
    adsl = adsl,
    advs = advs
  ))
}

# Generate sample data
clinical_data <- generate_cdisc_data()

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "Pharmaverse CDISC Demo"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("SDTM Data", tabName = "sdtm", icon = icon("database")),
      menuItem("ADaM Data", tabName = "adam", icon = icon("chart-bar")),
      menuItem("Analysis", tabName = "analysis", icon = icon("line-chart")),
      menuItem("About Pharmaverse", tabName = "about", icon = icon("info-circle"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Overview tab
      tabItem(tabName = "overview",
        fluidRow(
          box(
            title = "CDISC Standards Demonstration", status = "primary", solidHeader = TRUE,
            width = 12,
            h4("This app demonstrates CDISC SDTM and ADaM data structures"),
            p("Note: This is a simplified version using base R. For full Pharmaverse functionality, upgrade to R >= 4.3.0"),
            br(),
            h5("Available Datasets:"),
            tags$ul(
              tags$li("DM - Demographics"),
              tags$li("VS - Vital Signs"),
              tags$li("AE - Adverse Events"),
              tags$li("ADSL - Analysis Dataset Demographics"),
              tags$li("ADVS - Analysis Dataset Vital Signs")
            )
          )
        ),
        fluidRow(
          box(
            title = "Data Summary", status = "info", solidHeader = TRUE,
            width = 6,
            h4("Subject Summary"),
            paste("Total Subjects:", nrow(clinical_data$dm)),
            paste("Total Vital Signs Records:", nrow(clinical_data$vs)),
            paste("Total Adverse Events:", nrow(clinical_data$ae))
          ),
          box(
            title = "Pharmaverse Info", status = "warning", solidHeader = TRUE,
            width = 6,
            h4("About Pharmaverse"),
            p("Pharmaverse is an open-source ecosystem for pharmaceutical R programming."),
            p("For full admiral functionality, please upgrade to R >= 4.3.0"),
            a("Visit Pharmaverse", href = "https://pharmaverse.org", target = "_blank")
          )
        )
      ),
      
      # SDTM Data tab
      tabItem(tabName = "sdtm",
        fluidRow(
          tabBox(
            title = "SDTM Datasets", width = 12,
            tabPanel("Demographics (DM)",
              DT::dataTableOutput("dm_table")
            ),
            tabPanel("Vital Signs (VS)",
              DT::dataTableOutput("vs_table")
            ),
            tabPanel("Adverse Events (AE)",
              DT::dataTableOutput("ae_table")
            )
          )
        )
      ),
      
      # ADaM Data tab
      tabItem(tabName = "adam",
        fluidRow(
          tabBox(
            title = "ADaM Datasets", width = 12,
            tabPanel("ADSL - Demographics",
              DT::dataTableOutput("adsl_table")
            ),
            tabPanel("ADVS - Vital Signs",
              DT::dataTableOutput("advs_table")
            )
          )
        )
      ),
      
      # Analysis tab
      tabItem(tabName = "analysis",
        fluidRow(
          box(
            title = "Vital Signs Analysis", status = "primary", solidHeader = TRUE,
            width = 12,
            plotly::plotlyOutput("vs_plot")
          )
        ),
        fluidRow(
          box(
            title = "Adverse Events Summary", status = "warning", solidHeader = TRUE,
            width = 6,
            plotly::plotlyOutput("ae_plot")
          ),
          box(
            title = "Demographics Distribution", status = "info", solidHeader = TRUE,
            width = 6,
            plotly::plotlyOutput("demo_plot")
          )
        )
      ),
      
      # About Pharmaverse tab
      tabItem(tabName = "about",
        fluidRow(
          box(
            title = "Pharmaverse Ecosystem", status = "success", solidHeader = TRUE,
            width = 12,
            h4("Pharmaverse Components"),
            tags$ul(
              tags$li("admiral - ADaM creation and validation"),
              tags$li("metacore - Metadata management"),
              tags$li("xport - SAS file integration"),
              tags$li("formods - Formatted outputs")
            ),
            br(),
            h4("Benefits"),
            tags$ul(
              tags$li("Standardized clinical programming"),
              tags$li("Regulatory compliance"),
              tags$li("Open-source collaboration"),
              tags$li("Reduced development time")
            ),
            br(),
            h4("Current Status"),
            p("This demo uses base R to show CDISC concepts. For full Pharmaverse functionality:"),
            tags$ul(
              tags$li("Upgrade to R >= 4.3.0"),
              tags$li("Install: install.packages('admiral', repos = 'https://pharmaverse.r-universe.dev')"),
              tags$li("Use the full app.R file")
            )
          )
        )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # SDTM Tables
  output$dm_table <- DT::renderDataTable({
    DT::datatable(clinical_data$dm, options = list(pageLength = 10))
  })
  
  output$vs_table <- DT::renderDataTable({
    DT::datatable(clinical_data$vs, options = list(pageLength = 10))
  })
  
  output$ae_table <- DT::renderDataTable({
    DT::datatable(clinical_data$ae, options = list(pageLength = 10))
  })
  
  # ADaM Tables
  output$adsl_table <- DT::renderDataTable({
    DT::datatable(clinical_data$adsl, options = list(pageLength = 10))
  })
  
  output$advs_table <- DT::renderDataTable({
    DT::datatable(clinical_data$advs, options = list(pageLength = 10))
  })
  
  # Analysis plots
  output$vs_plot <- plotly::renderPlotly({
    # Vital signs over time
    vs_summary <- clinical_data$advs %>%
      filter(PARAMCD == "SYSBP") %>%
      group_by(VISIT) %>%
      summarise(
        mean_val = mean(AVAL, na.rm = TRUE),
        sd_val = sd(AVAL, na.rm = TRUE),
        n = n()
      )
    
    p <- ggplot(vs_summary, aes(x = VISIT, y = mean_val, fill = VISIT)) +
      geom_bar(stat = "identity") +
      geom_errorbar(aes(ymin = mean_val - sd_val, ymax = mean_val + sd_val), width = 0.2) +
      labs(title = "Systolic Blood Pressure Over Time",
           x = "Visit", y = "Mean SBP (mmHg)") +
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$ae_plot <- plotly::renderPlotly({
    # Adverse events by severity
    ae_summary <- clinical_data$ae %>%
      group_by(AESEV) %>%
      summarise(count = n())
    
    p <- ggplot(ae_summary, aes(x = AESEV, y = count, fill = AESEV)) +
      geom_col() +
      labs(title = "Adverse Events by Severity",
           x = "Severity", y = "Count") +
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$demo_plot <- plotly::renderPlotly({
    # Age distribution
    p <- ggplot(clinical_data$dm, aes(x = AGE, fill = SEX)) +
      geom_histogram(bins = 20, alpha = 0.7) +
      facet_wrap(~SEX) +
      labs(title = "Age Distribution by Sex",
           x = "Age", y = "Count") +
      theme_minimal()
    
    ggplotly(p)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
