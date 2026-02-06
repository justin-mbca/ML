# Pharmacometric Modeling Dashboard - Simplified Version
# Removes deSolve and nlme dependencies for better deployment compatibility

library(shiny)
library(shinydashboard)
library(plotly)
library(DT)
library(dplyr)
library(tidyr)
library(ggplot2)

# Pharmacokinetic Model Functions (simplified, no ODE solver)
pk_model <- function(t, dose, ka, ke, vd) {
  # One-compartment model with first-order absorption
  if (t <= 0) return(0)
  c <- (dose * ka) / (vd * (ka - ke)) * (exp(-ke * t) - exp(-ka * t))
  return(max(c, 0))
}

# Generate simulated clinical trial data
generate_pkpd_data <- function() {
  set.seed(123)  # For reproducibility
  
  # Subject characteristics
  n_subj <- 50
  subjects <- data.frame(
    SUBJID = paste0("SUBJ", sprintf("%03d", 1:n_subj)),
    WEIGHT = rnorm(n_subj, 70, 10),
    AGE = rnorm(n_subj, 45, 12),
    SEX = sample(c("M", "F"), n_subj, replace = TRUE),
    CRCL = rnorm(n_subj, 90, 20),
    ARM = sample(c("Low Dose", "Medium Dose", "High Dose", "Placebo"), n_subj, replace = TRUE)
  )
  
  # Dosing regimen
  dose_map <- c("Placebo" = 0, "Low Dose" = 50, "Medium Dose" = 100, "High Dose" = 200)
  subjects$DOSE <- dose_map[subjects$ARM]
  
  # PK parameters
  subjects$CL <- 2.5 * (subjects$WEIGHT/70)^0.75 * (subjects$CRCL/90)^0.5
  subjects$Vd <- 50 * (subjects$WEIGHT/70)
  subjects$Ka <- rnorm(n_subj, 0.8, 0.2)
  subjects$Ke <- subjects$CL / subjects$Vd
  
  # Time points
  time_points <- c(0, 0.5, 1, 2, 4, 6, 8, 12, 24, 48, 72)
  
  # Generate concentration data
  pk_data <- data.frame()
  
  for(i in 1:n_subj) {
    subj <- subjects[i, ]
    
    for(t in time_points) {
      conc <- pk_model(t, subj$DOSE, subj$Ka, subj$Ke, subj$Vd)
      conc_obs <- conc * (1 + rnorm(1, 0, 0.1))
      
      pk_data <- rbind(pk_data, data.frame(
        SUBJID = subj$SUBJID,
        TIME = t,
        CONC = max(conc_obs, 0),
        DOSE = subj$DOSE,
        ARM = subj$ARM,
        WEIGHT = subj$WEIGHT
      ))
    }
  }
  
  list(subjects = subjects, pk_data = pk_data)
}

# UI
ui <- dashboardPage(
  dashboardHeader(title = "PharmacoModel Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("PK Analysis", tabName = "pk", icon = icon("line-chart")),
      menuItem("Documentation", tabName = "docs", icon = icon("book"))
    )
  ),
  dashboardBody(
    tabItems(
      # Overview
      tabItem(tabName = "overview",
        h2("Pharmacometric Modeling Dashboard"),
        fluidRow(
          valueBoxOutput("totalSubjects"),
          valueBoxOutput("doseGroups"),
          valueBoxOutput("timePoints")
        ),
        fluidRow(
          box(title = "Subject Demographics", width = 12, solidHeader = TRUE,
              plotlyOutput("demoPlot"))
        )
      ),
      
      # PK Analysis
      tabItem(tabName = "pk",
        h2("Pharmacokinetic Analysis"),
        fluidRow(
          box(title = "Concentration-Time Profiles", width = 12,
              plotlyOutput("pkPlot", height = "500px"))
        ),
        fluidRow(
          box(title = "PK Parameters", width = 12,
              DTOutput("pkParamsTable"))
        )
      ),
      
      # Documentation
      tabItem(tabName = "docs",
        h2("Documentation"),
        box(width = 12,
            h3("Pharmacokinetic Model"),
            p("This dashboard demonstrates PK/PD modeling capabilities for clinical trial analysis."),
            h4("Features:"),
            tags$ul(
              tags$li("One-compartment PK model with first-order absorption"),
              tags$li("Population PK analysis with covariate effects"),
              tags$li("Interactive visualizations"),
              tags$li("Parameter estimation and simulation")
            ),
            h4("Model:"),
            p("C(t) = (Dose × Ka) / (Vd × (Ka - Ke)) × (exp(-Ke × t) - exp(-Ka × t))"),
            p("where Ka = absorption rate, Ke = elimination rate, Vd = volume of distribution")
        )
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Generate data
  study_data <- reactiveVal(generate_pkpd_data())
  
  # Overview outputs
  output$totalSubjects <- renderValueBox({
    valueBox(
      value = nrow(study_data()$subjects),
      subtitle = "Total Subjects",
      icon = icon("users"),
      color = "blue"
    )
  })
  
  output$doseGroups <- renderValueBox({
    valueBox(
      value = length(unique(study_data()$subjects$ARM)),
      subtitle = "Dose Groups",
      icon = icon("flask"),
      color = "green"
    )
  })
  
  output$timePoints <- renderValueBox({
    valueBox(
      value = length(unique(study_data()$pk_data$TIME)),
      subtitle = "Time Points",
      icon = icon("clock"),
      color = "orange"
    )
  })
  
  output$demoPlot <- renderPlotly({
    subjects <- study_data()$subjects
    
    p <- ggplot(subjects, aes(x = WEIGHT, y = AGE, color = ARM)) +
      geom_point(size = 3, alpha = 0.7) +
      labs(title = "Subject Demographics", x = "Weight (kg)", y = "Age (years)") +
      theme_minimal()
    
    ggplotly(p)
  })
  
  # PK Analysis
  output$pkPlot <- renderPlotly({
    pk_data <- study_data()$pk_data
    
    pk_summary <- pk_data %>%
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
    pk_data <- study_data()$pk_data
    subjects <- study_data()$subjects
    
    pk_params <- pk_data %>%
      filter(TIME > 0, CONC > 0) %>%
      group_by(SUBJID) %>%
      summarise(
        Cmax = max(CONC),
        Tmax = TIME[which.max(CONC)],
        AUC = sum(CONC * diff(c(0, TIME))),
        .groups = "drop"
      ) %>%
      left_join(subjects %>% select(SUBJID, ARM, WEIGHT, AGE), by = "SUBJID")
    
    datatable(pk_params, options = list(pageLength = 10, scrollX = TRUE))
  })
}

# Run the app
shinyApp(ui, server)
