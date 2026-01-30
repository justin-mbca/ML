# Clinical Data Viewer - CDISC SDTM/ADaM Visualization App
# Senior Shiny Developer Portfolio Project
# Demonstrates clinical trial data analysis with CDISC standards

library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(readr)
library(dplyr)
library(tidyr)
library(lubridate)
library(ggplot2)
library(shinycssloaders)
library(shinyWidgets)

# Simulated CDISC SDTM/ADaM datasets
generate_sdtm_data <- function() {
  # Demographics (DM)
  dm <- data.frame(
    STUDYID = rep("STUDY001", 100),
    SITEID = sample(paste0("SITE", sprintf("%02d", 1:10)), 100, replace = TRUE),
    SUBJID = paste0("SUBJ", sprintf("%03d", 1:100)),
    BRTHDTC = sample(seq(as.Date("1970-01-01"), as.Date("1995-12-31"), by = "day"), 100),
    AGE = sample(18:75, 100, replace = TRUE),
    AGEU = rep("YEARS", 100),
    SEX = sample(c("M", "F"), 100, replace = TRUE),
    RACE = sample(c("WHITE", "BLACK", "ASIAN", "HISPANIC"), 100, replace = TRUE),
    ETHNIC = sample(c("HISPANIC OR LATINO", "NOT HISPANIC OR LATINO"), 100, replace = TRUE),
    COUNTRY = rep("USA", 100),
    ARMCD = sample(c("SCR", "PLA"), 100, replace = TRUE),
    stringsAsFactors = FALSE
  )
  
  # Add ARM column after ARMCD is created
  dm$ARM <- ifelse(dm$ARMCD == "SCR", "Screening", "Placebo")
  
  # Vital Signs (VS)
  vs <- data.frame(
    STUDYID = rep("STUDY001", 500),
    SITEID = sample(paste0("SITE", sprintf("%02d", 1:10)), 500, replace = TRUE),
    SUBJID = sample(paste0("SUBJ", sprintf("%03d", 1:100)), 500, replace = TRUE),
    VSTESTCD = rep(c("SYSBP", "DIABP", "PULSE", "TEMP", "RESP", "WEIGHT", "HEIGHT"), each = 71),
    VSTEST = rep(c("Systolic Blood Pressure", "Diastolic Blood Pressure", "Pulse Rate", 
                   "Temperature", "Respiratory Rate", "Weight", "Height"), each = 71),
    VSORRES = c(
      rnorm(71, 120, 15),    # SYSBP
      rnorm(71, 80, 10),     # DIABP
      rnorm(71, 70, 10),     # PULSE
      rnorm(71, 98.6, 1),    # TEMP
      rnorm(71, 16, 2),      # RESP
      rnorm(71, 70, 15),     # WEIGHT
      rnorm(71, 170, 10)     # HEIGHT
    ),
    VSORRESU = rep(c("mmHg", "mmHg", "bpm", "F", "bpm", "kg", "cm"), each = 71),
    VISITNUM = sample(1:5, 500, replace = TRUE),
    VISIT = sample(c("Screening", "Baseline", "Week 2", "Week 4", "Week 8"), 500, replace = TRUE),
    VSDTC = sample(seq(as.Date("2023-01-01"), as.Date("2023-12-31"), by = "day"), 500, replace = TRUE),
    stringsAsFactors = FALSE
  )
  
  # Adverse Events (AE)
  ae <- data.frame(
    STUDYID = rep("STUDY001", 150),
    SITEID = sample(paste0("SITE", sprintf("%02d", 1:10)), 150, replace = TRUE),
    SUBJID = sample(paste0("SUBJ", sprintf("%03d", 1:100)), 150, replace = TRUE),
    AETERM = sample(c("Headache", "Nausea", "Fatigue", "Dizziness", "Rash", "Cough", "Fever"), 150, replace = TRUE),
    AEBODSYS = sample(c("Nervous system", "Gastrointestinal", "General disorders", 
                       "Skin and subcutaneous tissue", "Respiratory", "Infections"), 150, replace = TRUE),
    AESEV = sample(c("MILD", "MODERATE", "SEVERE"), 150, replace = TRUE, prob = c(0.6, 0.3, 0.1)),
    AEREL = sample(c("RELATED", "NOT RELATED", "RELATED"), 150, replace = TRUE, prob = c(0.4, 0.2, 0.4)),
    AEACN = sample(c("DOSE NOT CHANGED", "DOSE REDUCED", "DRUG WITHDRAWN"), 150, replace = TRUE, prob = c(0.7, 0.2, 0.1)),
    AESTDTC = sample(seq(as.Date("2023-01-01"), as.Date("2023-12-31"), by = "day"), 150, replace = TRUE),
    AEENDTC = sample(seq(as.Date("2023-01-01"), as.Date("2023-12-31"), by = "day"), 150, replace = TRUE),
    stringsAsFactors = FALSE
  )
  
  list(dm = dm, vs = vs, ae = ae)
}

# Generate ADaM dataset
generate_adam_data <- function(dm, vs) {
  # Analysis Dataset for Demographics (ADSL)
  adsl <- dm %>%
    mutate(
      TRTSDT = as.Date("2023-01-01") + sample(0:30, nrow(dm), replace = TRUE),
      TRTEDT = TRTSDT + sample(7:180, nrow(dm), replace = TRUE),
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
    filter(VISIT %in% c("Baseline", "Week 4", "Week 8")) %>%
    left_join(dm %>% select(SUBJID, AGE, SEX, ARMCD), by = "SUBJID") %>%
    mutate(
      PARAMCD = VSTESTCD,
      PARAM = VSTEST,
      AVAL = VSORRES,
      AVALC = as.character(round(AVAL, 2)),
      CHG = case_when(
        VISIT == "Baseline" ~ NA_real_,
        TRUE ~ AVAL - lag(AVAL, default = first(AVAL))
      ),
      PCHG = case_when(
        VISIT == "Baseline" ~ NA_real_,
        TRUE ~ (AVAL - lag(AVAL, default = first(AVAL))) / lag(AVAL, default = first(AVAL)) * 100
      )
    ) %>%
    arrange(SUBJID, VISITNUM, PARAMCD)
  
  list(adsl = adsl, advs = advs)
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
      menuItem("Data Explorer", tabName = "explorer", icon = icon("search")),
      menuItem("Export", tabName = "export", icon = icon("download")),
      menuItem("About", tabName = "about", icon = icon("info-circle"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Dashboard Tab
      tabItem(tabName = "dashboard",
        fluidRow(
          box(
            title = "Study Overview", status = "primary", solidHeader = TRUE,
            width = 12, collapsible = TRUE,
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
            title = "Subject Distribution by Site", status = "info", solidHeader = TRUE,
            width = 6, plotOutput("siteDistPlot")
          ),
          box(
            title = "Adverse Events by Severity", status = "warning", solidHeader = TRUE,
            width = 6, plotOutput("aeSeverityPlot")
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
            width = 6, plotOutput("ageDistPlot")
          ),
          box(
            title = "Gender Distribution", status = "info", solidHeader = TRUE,
            width = 6, plotOutput("genderDistPlot")
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
                       choices = c("Systolic BP", "Diastolic BP", "Pulse", "Temperature", "Weight", "Height")),
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
            title = "AEs by System Organ Class", status = "info", solidHeader = TRUE,
            width = 6, plotOutput("aeSOCPlot")
          ),
          box(
            title = "AEs by Relationship", status = "info", solidHeader = TRUE,
            width = 6, plotOutput("aeRelPlot")
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
                       choices = c("Demographics (DM)", "Vital Signs (VS)", "Adverse Events (AE)",
                                  "Analysis Demographics (ADSL)", "Analysis Vital Signs (ADVS)")),
            DT::dataTableOutput("explorerTable")
          )
        )
      ),
      
      # Export Tab
      tabItem(tabName = "export",
        fluidRow(
          box(
            title = "Export Data", status = "success", solidHeader = TRUE,
            width = 12,
            p("Export processed datasets for regulatory submission."),
            selectInput("exportDataset", "Select Dataset to Export:", 
                       choices = c("ADSL", "ADVS", "Custom Summary")),
            downloadButton("downloadData", "Download CSV"),
            downloadButton("downloadReport", "Generate Report")
          )
        )
      ),
      
      # About Tab
      tabItem(tabName = "about",
        fluidRow(
          box(
            title = "About Clinical Data Viewer", status = "info", solidHeader = TRUE,
            width = 12,
            includeMarkdown("about.md")
          )
        )
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Generate data
  sdtm_data <- reactiveVal(generate_sdtm_data())
  adam_data <- reactive({
    data <- sdtm_data()
    generate_adam_data(data$dm, data$vs)
  })
  
  # Dashboard outputs
  output$totalSubjects <- renderValueBox({
    valueBox(
      value = nrow(sdtm_data()$dm),
      subtitle = "Total Subjects",
      icon = icon("users"),
      color = "blue"
    )
  })
  
  output$totalSites <- renderValueBox({
    valueBox(
      value = length(unique(sdtm_data()$dm$SITEID)),
      subtitle = "Total Sites",
      icon = icon("hospital"),
      color = "green"
    )
  })
  
  output$totalAEs <- renderValueBox({
    valueBox(
      value = nrow(sdtm_data()$ae),
      subtitle = "Total AEs",
      icon = icon("exclamation-triangle"),
      color = "yellow"
    )
  })
  
  output$avgAge <- renderValueBox({
    valueBox(
      value = round(mean(sdtm_data()$dm$AGE), 1),
      subtitle = "Average Age",
      icon = icon("calendar"),
      color = "purple"
    )
  })
  
  # Site distribution plot
  output$siteDistPlot <- renderPlot({
    dm <- sdtm_data()$dm
    ggplot(dm, aes(x = SITEID, fill = ARM)) +
      geom_bar() +
      labs(title = "Subject Distribution by Site and Treatment Arm",
           x = "Site ID", y = "Number of Subjects") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # AE severity plot
  output$aeSeverityPlot <- renderPlot({
    ae <- sdtm_data()$ae
    ggplot(ae, aes(x = AESEV, fill = AESEV)) +
      geom_bar() +
      labs(title = "Adverse Events by Severity",
           x = "Severity", y = "Count") +
      theme_minimal()
  })
  
  # Demographics table
  output$demogTable <- DT::renderDataTable({
    dm <- sdtm_data()$dm
    DT::datatable(dm, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  # Age distribution
  output$ageDistPlot <- renderPlot({
    dm <- sdtm_data()$dm
    ggplot(dm, aes(x = AGE, fill = SEX)) +
      geom_histogram(bins = 15, alpha = 0.7) +
      labs(title = "Age Distribution by Gender",
           x = "Age", y = "Count") +
      theme_minimal()
  })
  
  # Gender distribution
  output$genderDistPlot <- renderPlot({
    dm <- sdtm_data()$dm
    ggplot(dm, aes(x = SEX, fill = SEX)) +
      geom_bar() +
      labs(title = "Gender Distribution",
           x = "Gender", y = "Count") +
      theme_minimal()
  })
  
  # Vital signs time plot
  output$vsTimePlot <- renderPlot({
    vs <- sdtm_data()$vs
    param_map <- c("Systolic BP" = "SYSBP", "Diastolic BP" = "DIABP", 
                   "Pulse" = "PULSE", "Temperature" = "TEMP",
                   "Weight" = "WEIGHT", "Height" = "HEIGHT")
    
    selected_param <- param_map[[input$vsParam]]
    vs_filtered <- vs %>% filter(VSTESTCD == selected_param)
    
    ggplot(vs_filtered, aes(x = VISIT, y = VSORRES, group = SUBJID)) +
      geom_line(alpha = 0.3) +
      stat_summary(fun = mean, geom = "line", color = "red", size = 1.5) +
      stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2, color = "red") +
      labs(title = paste(input$vsParam, "Over Time"),
           x = "Visit", y = "Value") +
      theme_minimal()
  })
  
  # Vital signs change from baseline
  output$vsChangePlot <- renderPlot({
    advs <- adam_data()$advs
    param_map <- c("Systolic BP" = "SYSBP", "Diastolic BP" = "DIABP", 
                   "Pulse" = "PULSE", "Temperature" = "TEMP",
                   "Weight" = "WEIGHT", "Height" = "HEIGHT")
    
    selected_param <- param_map[[input$vsParam]]
    advs_filtered <- advs %>% filter(PARAMCD == selected_param, !is.na(CHG))
    
    ggplot(advs_filtered, aes(x = VISIT, y = CHG, fill = ARMCD)) +
      geom_boxplot() +
      labs(title = paste("Change from Baseline -", input$vsParam),
           x = "Visit", y = "Change from Baseline") +
      theme_minimal()
  })
  
  # AE table
  output$aeTable <- DT::renderDataTable({
    ae <- sdtm_data()$ae
    DT::datatable(ae, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  # AE by SOC plot
  output$aeSOCPlot <- renderPlot({
    ae <- sdtm_data()$ae
    ggplot(ae, aes(x = AEBODSYS, fill = AEBODSYS)) +
      geom_bar() +
      coord_flip() +
      labs(title = "Adverse Events by System Organ Class",
           x = "System Organ Class", y = "Count") +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  # AE relationship plot
  output$aeRelPlot <- renderPlot({
    ae <- sdtm_data()$ae
    ggplot(ae, aes(x = AEREL, fill = AEREL)) +
      geom_bar() +
      labs(title = "Adverse Events by Relationship to Study Drug",
           x = "Relationship", y = "Count") +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  # Data explorer
  output$explorerTable <- DT::renderDataTable({
    data_choice <- input$dataset
    data <- switch(data_choice,
      "Demographics (DM)" = sdtm_data()$dm,
      "Vital Signs (VS)" = sdtm_data()$vs,
      "Adverse Events (AE)" = sdtm_data()$ae,
      "Analysis Demographics (ADSL)" = adam_data()$adsl,
      "Analysis Vital Signs (ADVS)" = adam_data()$advs
    )
    DT::datatable(data, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  # Export functionality
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0(input$exportDataset, "_", Sys.Date(), ".csv")
    },
    content = function(file) {
      data <- switch(input$exportDataset,
        "ADSL" = adam_data()$adsl,
        "ADVS" = adam_data()$advs,
        "Custom Summary" = {
          # Create custom summary for regulatory submission
          dm <- sdtm_data()$dm
          ae <- sdtm_data()$ae
          summary_df <- data.frame(
            METRIC = c("Total Subjects", "Total Sites", "Total AEs", "Mean Age", "Male %", "Female %"),
            VALUE = c(
              nrow(dm),
              length(unique(dm$SITEID)),
              nrow(ae),
              round(mean(dm$AGE), 1),
              round(mean(dm$SEX == "M") * 100, 1),
              round(mean(dm$SEX == "F") * 100, 1)
            )
          )
          summary_df
        }
      )
      write.csv(data, file, row.names = FALSE)
    }
  )
  
  output$downloadReport <- downloadHandler(
    filename = function() {
      paste0("Clinical_Report_", Sys.Date(), ".html")
    },
    content = function(file) {
      # Generate HTML report
      rmarkdown::render("report_template.Rmd", output_file = file)
    }
  )
}

# Run the app
shinyApp(ui, server)
