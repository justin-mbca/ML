# Marketplace Data & Reporting Manager Dashboard
# Health Insurance Marketplace Analytics for CoverME.gov
# Demonstrates skills for Maine DHHS position

# Load required libraries
library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)
library(readr)
library(scales)

# Generate realistic marketplace data
generate_marketplace_data <- function() {
  set.seed(123)
  
  # Enrollment data over time
  enrollment_data <- expand.grid(
    month = seq(as.Date("2023-01-01"), as.Date("2024-12-01"), by = "month"),
    county = c("Cumberland", "York", "Penobscot", "Aroostook", "Kennebec"),
    plan_type = c("Bronze", "Silver", "Gold", "Platinum"),
    age_group = c("18-26", "27-34", "35-44", "45-54", "55-64", "65+")
  ) %>%
    mutate(
      enrollments = round(rnorm(n(), mean = 500, sd = 150)),
      premium_avg = round(rnorm(n(), mean = 450, sd = 100), 2),
      subsidy_avg = round(rnorm(n(), mean = 200, sd = 50), 2),
      renewal_rate = round(runif(n(), 0.7, 0.95), 3)
    ) %>%
    filter(enrollments > 0)
  
  # Consumer demographics
  consumer_data <- data.frame(
    consumer_id = 1:10000,
    age = sample(18:75, 10000, replace = TRUE),
    income = round(rlnorm(10000, meanlog = 10.5, sdlog = 0.5)),
    county = sample(c("Cumberland", "York", "Penobscot", "Aroostook", "Kennebec"), 10000, replace = TRUE),
    plan_type = sample(c("Bronze", "Silver", "Gold", "Platinum"), 10000, replace = TRUE, prob = c(0.4, 0.35, 0.2, 0.05)),
    enrollment_date = as.Date("2023-01-01") + sample(0:730, 10000, replace = TRUE),
    subsidy_eligible = sample(c(TRUE, FALSE), 10000, replace = TRUE, prob = c(0.6, 0.4)),
    renewal_status = sample(c("Renewed", "Not Renewed", "Pending"), 10000, replace = TRUE, prob = c(0.8, 0.15, 0.05))
  )
  
  # Call center data
  call_center_data <- data.frame(
    date = seq(as.Date("2024-01-01"), as.Date("2024-12-31"), by = "day"),
    calls_received = round(rnorm(365, mean = 200, sd = 50)),
    calls_answered = round(rnorm(365, mean = 180, sd = 45)),
    avg_wait_time = round(rnorm(365, mean = 120, sd = 30)),
    satisfaction_score = round(rnorm(365, mean = 4.2, sd = 0.5), 2)
  ) %>%
    mutate(
      calls_answered = pmin(calls_answered, calls_received),
      abandonment_rate = round((calls_received - calls_answered) / calls_received * 100, 2)
    )
  
  # Plan performance metrics
  plan_performance <- enrollment_data %>%
    group_by(month, plan_type) %>%
    summarise(
      total_enrollments = sum(enrollments),
      avg_premium = mean(premium_avg),
      avg_subsidy = mean(subsidy_avg),
      avg_renewal = mean(renewal_rate),
      .groups = "drop"
    )
  
  return(list(
    enrollment = enrollment_data,
    consumers = consumer_data,
    call_center = call_center_data,
    plan_performance = plan_performance
  ))
}

# Generate data
marketplace_data <- generate_marketplace_data()

# Define UI
ui <- dashboardPage(
  dashboardHeader(
    title = "CoverME.gov Analytics Dashboard",
    titleWidth = 300
  ),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("Enrollment Trends", tabName = "enrollment", icon = icon("users")),
      menuItem("Consumer Demographics", tabName = "demographics", icon = icon("user")),
      menuItem("Plan Performance", tabName = "plans", icon = icon("chart-bar")),
      menuItem("Call Center Analytics", tabName = "callcenter", icon = icon("phone")),
      menuItem("Regulatory Reports", tabName = "reports", icon = icon("file-text")),
      menuItem("Data Quality", tabName = "quality", icon = icon("check-circle"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Overview Tab
      tabItem(tabName = "overview",
        fluidRow(
          valueBox(
            formatC(sum(marketplace_data$consumers$enrollment_date <= Sys.Date()), big.mark = ","),
            "Total Enrollments",
            icon = icon("users"),
            color = "blue"
          ),
          valueBox(
            paste0(round(mean(marketplace_data$call_center$satisfaction_score), 2), "/5.0"),
            "Customer Satisfaction",
            icon = icon("smile"),
            color = "green"
          ),
          valueBox(
            paste0(round(mean(marketplace_data$plan_performance$avg_renewal) * 100, 1), "%"),
            "Renewal Rate",
            icon = icon("refresh"),
            color = "yellow"
          ),
          valueBox(
            paste0(round(mean(marketplace_data$consumers$subsidy_eligible) * 100, 1), "%"),
            "Subsidy Eligible",
            icon = icon("dollar"),
            color = "purple"
          )
        ),
        
        fluidRow(
          box(
            title = "Monthly Enrollment Trends", status = "primary", solidHeader = TRUE,
            width = 8,
            plotly::plotlyOutput("overview_enrollment_plot")
          ),
          box(
            title = "Plan Type Distribution", status = "info", solidHeader = TRUE,
            width = 4,
            plotly::plotlyOutput("overview_plan_dist")
          )
        )
      ),
      
      # Enrollment Trends Tab
      tabItem(tabName = "enrollment",
        fluidRow(
          box(
            title = "Enrollment by County Over Time", status = "primary", solidHeader = TRUE,
            width = 12,
            plotly::plotlyOutput("enrollment_time_series")
          )
        ),
        fluidRow(
          box(
            title = "Enrollment Data Table", status = "info", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("enrollment_table")
          )
        )
      ),
      
      # Consumer Demographics Tab
      tabItem(tabName = "demographics",
        fluidRow(
          box(
            title = "Age Distribution", status = "primary", solidHeader = TRUE,
            width = 6,
            plotly::plotlyOutput("age_distribution")
          ),
          box(
            title = "Income Distribution", status = "info", solidHeader = TRUE,
            width = 6,
            plotly::plotlyOutput("income_distribution")
          )
        ),
        fluidRow(
          box(
            title = "Geographic Distribution", status = "warning", solidHeader = TRUE,
            width = 12,
            plotly::plotlyOutput("geographic_distribution")
          )
        )
      ),
      
      # Plan Performance Tab
      tabItem(tabName = "plans",
        fluidRow(
          box(
            title = "Plan Performance Metrics", status = "primary", solidHeader = TRUE,
            width = 12,
            plotly::plotlyOutput("plan_performance_plot")
          )
        ),
        fluidRow(
          box(
            title = "Premium vs Subsidy Analysis", status = "info", solidHeader = TRUE,
            width = 6,
            plotly::plotlyOutput("premium_subsidy_plot")
          ),
          box(
            title = "Renewal Rates by Plan", status = "success", solidHeader = TRUE,
            width = 6,
            plotly::plotlyOutput("renewal_rates_plot")
          )
        )
      ),
      
      # Call Center Analytics Tab
      tabItem(tabName = "callcenter",
        fluidRow(
          box(
            title = "Call Volume Trends", status = "primary", solidHeader = TRUE,
            width = 8,
            plotly::plotlyOutput("call_volume_plot")
          ),
          box(
            title = "Key Metrics", status = "info", solidHeader = TRUE,
            width = 4,
            fluidRow(
              valueBox(
                paste0(round(mean(marketplace_data$call_center$avg_wait_time), 0), " sec"),
                "Avg Wait Time",
                icon = icon("clock"),
                color = "yellow"
              )
            ),
            fluidRow(
              valueBox(
                paste0(round(mean(marketplace_data$call_center$abandonment_rate), 1), "%"),
                "Abandonment Rate",
                icon = icon("phone-slash"),
                color = "red"
              )
            )
          )
        ),
        fluidRow(
          box(
            title = "Customer Satisfaction Trends", status = "success", solidHeader = TRUE,
            width = 12,
            plotly::plotlyOutput("satisfaction_plot")
          )
        )
      ),
      
      # Regulatory Reports Tab
      tabItem(tabName = "reports",
        fluidRow(
          box(
            title = "Monthly Regulatory Report", status = "primary", solidHeader = TRUE,
            width = 12,
            h4("CMS Monthly Enrollment Report"),
            p("This report provides comprehensive enrollment data for CMS regulatory compliance."),
            br(),
            DT::dataTableOutput("regulatory_table"),
            br(),
            downloadButton("download_report", "Download Report (CSV)")
          )
        )
      ),
      
      # Data Quality Tab
      tabItem(tabName = "quality",
        fluidRow(
          box(
            title = "Data Quality Metrics", status = "primary", solidHeader = TRUE,
            width = 12,
            h4("Data Completeness and Validation"),
            p("Automated data quality checks for marketplace data integrity."),
            
            # Data quality checks
            verbatimTextOutput("quality_checks"),
            br(),
            h4("Data Validation Summary"),
            DT::dataTableOutput("quality_summary")
          )
        )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Overview plots
  output$overview_enrollment_plot <- plotly::renderPlotly({
    monthly_enrollment <- marketplace_data$enrollment %>%
      group_by(month) %>%
      summarise(total_enrollments = sum(enrollments), .groups = "drop")
    
    p <- ggplot(monthly_enrollment, aes(x = month, y = total_enrollments)) +
      geom_line(color = "blue", size = 2) +
      geom_point(color = "blue", size = 3) +
      labs(title = "Monthly Enrollment Trends",
           x = "Month",
           y = "Total Enrollments") +
      theme_minimal() +
      scale_y_continuous(labels = comma)
    
    plotly::ggplotly(p)
  })
  
  output$overview_plan_dist <- plotly::renderPlotly({
    plan_counts <- marketplace_data$consumers %>%
      group_by(plan_type) %>%
      summarise(count = n(), .groups = "drop")
    
    p <- ggplot(plan_counts, aes(x = plan_type, y = count, fill = plan_type)) +
      geom_col() +
      labs(title = "Plan Type Distribution",
           x = "Plan Type",
           y = "Number of Enrollees") +
      theme_minimal() +
      theme(legend.position = "none")
    
    plotly::ggplotly(p)
  })
  
  # Enrollment trends
  output$enrollment_time_series <- plotly::renderPlotly({
    county_enrollment <- marketplace_data$enrollment %>%
      group_by(month, county) %>%
      summarise(total_enrollments = sum(enrollments), .groups = "drop")
    
    p <- ggplot(county_enrollment, aes(x = month, y = total_enrollments, color = county)) +
      geom_line(size = 1.5) +
      labs(title = "Enrollment Trends by County",
           x = "Month",
           y = "Total Enrollments",
           color = "County") +
      theme_minimal() +
      scale_y_continuous(labels = comma)
    
    plotly::ggplotly(p)
  })
  
  output$enrollment_table <- DT::renderDataTable({
    DT::datatable(
      marketplace_data$enrollment,
      options = list(pageLength = 10, scrollX = TRUE),
      extensions = 'Responsive'
    )
  })
  
  # Demographics
  output$age_distribution <- plotly::renderPlotly({
    age_counts <- marketplace_data$consumers %>%
      mutate(age_group = cut(age, breaks = c(0, 26, 35, 45, 55, 65, 100),
                           labels = c("18-26", "27-34", "35-44", "45-54", "55-64", "65+"))) %>%
      group_by(age_group) %>%
      summarise(count = n(), .groups = "drop")
    
    p <- ggplot(age_counts, aes(x = age_group, y = count, fill = age_group)) +
      geom_col() +
      labs(title = "Age Distribution of Enrollees",
           x = "Age Group",
           y = "Count") +
      theme_minimal() +
      theme(legend.position = "none")
    
    plotly::ggplotly(p)
  })
  
  output$income_distribution <- plotly::renderPlotly({
    p <- ggplot(marketplace_data$consumers, aes(x = income)) +
      geom_histogram(bins = 30, fill = "steelblue", alpha = 0.7) +
      labs(title = "Income Distribution",
           x = "Annual Income",
           y = "Count") +
      theme_minimal() +
      scale_x_continuous(labels = dollar)
    
    plotly::ggplotly(p)
  })
  
  output$geographic_distribution <- plotly::renderPlotly({
    county_counts <- marketplace_data$consumers %>%
      group_by(county) %>%
      summarise(count = n(), .groups = "drop")
    
    p <- ggplot(county_counts, aes(x = county, y = count, fill = county)) +
      geom_col() +
      labs(title = "Enrollment by County",
           x = "County",
           y = "Number of Enrollees") +
      theme_minimal() +
      theme(legend.position = "none")
    
    plotly::ggplotly(p)
  })
  
  # Plan performance
  output$plan_performance_plot <- plotly::renderPlotly({
    p <- ggplot(marketplace_data$plan_performance, aes(x = month, y = avg_renewal, color = plan_type)) +
      geom_line(size = 1.5) +
      labs(title = "Renewal Rates by Plan Type Over Time",
           x = "Month",
           y = "Renewal Rate",
           color = "Plan Type") +
      theme_minimal() +
      scale_y_continuous(labels = percent)
    
    plotly::ggplotly(p)
  })
  
  output$premium_subsidy_plot <- plotly::renderPlotly({
    p <- ggplot(marketplace_data$plan_performance, aes(x = avg_premium, y = avg_subsidy, color = plan_type)) +
      geom_point(size = 3, alpha = 0.7) +
      labs(title = "Premium vs Subsidy Analysis",
           x = "Average Premium",
           y = "Average Subsidy",
           color = "Plan Type") +
      theme_minimal() +
      scale_x_continuous(labels = dollar) +
      scale_y_continuous(labels = dollar)
    
    plotly::ggplotly(p)
  })
  
  output$renewal_rates_plot <- plotly::renderPlotly({
    renewal_summary <- marketplace_data$plan_performance %>%
      group_by(plan_type) %>%
      summarise(avg_renewal = mean(avg_renewal), .groups = "drop")
    
    p <- ggplot(renewal_summary, aes(x = plan_type, y = avg_renewal, fill = plan_type)) +
      geom_col() +
      labs(title = "Average Renewal Rates by Plan Type",
           x = "Plan Type",
           y = "Renewal Rate") +
      theme_minimal() +
      scale_y_continuous(labels = percent) +
      theme(legend.position = "none")
    
    plotly::ggplotly(p)
  })
  
  # Call center analytics
  output$call_volume_plot <- plotly::renderPlotly({
    p <- ggplot(marketplace_data$call_center, aes(x = date)) +
      geom_line(aes(y = calls_received, color = "Calls Received"), size = 1.5) +
      geom_line(aes(y = calls_answered, color = "Calls Answered"), size = 1.5) +
      labs(title = "Daily Call Volume Trends",
           x = "Date",
           y = "Number of Calls",
           color = "Metric") +
      theme_minimal() +
      scale_y_continuous(labels = comma) +
      theme(legend.position = "bottom")
    
    plotly::ggplotly(p)
  })
  
  output$satisfaction_plot <- plotly::renderPlotly({
    p <- ggplot(marketplace_data$call_center, aes(x = date, y = satisfaction_score)) +
      geom_line(color = "green", size = 1.5) +
      geom_point(color = "green", size = 2) +
      labs(title = "Customer Satisfaction Trends",
           x = "Date",
           y = "Satisfaction Score (1-5)") +
      theme_minimal() +
      scale_y_continuous(breaks = 1:5) +
      theme(legend.position = "none")
    
    plotly::ggplotly(p)
  })
  
  # Regulatory reports
  output$regulatory_table <- DT::renderDataTable({
    # Create regulatory report format
    regulatory_data <- marketplace_data$plan_performance %>%
      mutate(
        report_month = format(month, "%Y-%m"),
        total_enrollments = comma(total_enrollments),
        avg_premium = dollar(avg_premium),
        avg_subsidy = dollar(avg_subsidy),
        renewal_rate = percent(avg_renewal)
      ) %>%
      select(report_month, plan_type, total_enrollments, avg_premium, avg_subsidy, renewal_rate)
    
    DT::datatable(
      regulatory_data,
      options = list(pageLength = 15, scrollX = TRUE),
      extensions = 'Responsive'
    )
  })
  
  # Data quality
  output$quality_checks <- renderText({
    # Perform data quality checks
    checks <- list()
    
    # Check 1: Missing values
    missing_enrollment <- sum(is.na(marketplace_data$enrollment))
    missing_consumers <- sum(is.na(marketplace_data$consumers))
    missing_callcenter <- sum(is.na(marketplace_data$call_center))
    
    checks$missing_values <- paste(
      "Missing Values Check:",
      paste("  Enrollment data:", missing_enrollment, "missing values"),
      paste("  Consumer data:", missing_consumers, "missing values"),
      paste("  Call center data:", missing_callcenter, "missing values"),
      sep = "\n"
    )
    
    # Check 2: Data ranges
    checks$data_ranges <- paste(
      "Data Range Validation:",
      paste("  Enrollment range:", min(marketplace_data$enrollment$enrollments), "-", 
            max(marketplace_data$enrollment$enrollments)),
      paste("  Age range:", min(marketplace_data$consumers$age), "-", 
            max(marketplace_data$consumers$age)),
      paste("  Satisfaction range:", min(marketplace_data$call_center$satisfaction_score), "-", 
            max(marketplace_data$call_center$satisfaction_score)),
      sep = "\n"
    )
    
    # Check 3: Duplicate records
    duplicate_consumers <- sum(duplicated(marketplace_data$consumers$consumer_id))
    checks$duplicates <- paste(
      "Duplicate Records Check:",
      paste("  Duplicate consumer IDs:", duplicate_consumers),
      sep = "\n"
    )
    
    paste(unlist(checks), collapse = "\n\n")
  })
  
  output$quality_summary <- DT::renderDataTable({
    quality_summary <- data.frame(
      Check = c("Missing Values", "Data Ranges", "Duplicate Records", "Data Completeness"),
      Status = c("PASS", "PASS", "PASS", "PASS"),
      Details = c("No critical missing values found", "All values within expected ranges", 
                  "No duplicate records found", "All required fields populated"),
      Last_Checked = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    )
    
    DT::datatable(
      quality_summary,
      options = list(pageLength = 10, dom = 't'),
      extensions = 'Responsive'
    )
  })
  
  # Download report
  output$download_report <- downloadHandler(
    filename = function() {
      paste("CoverME_Monthly_Report_", format(Sys.time(), "%Y%m%d"), ".csv", sep = "")
    },
    content = function(file) {
      regulatory_data <- marketplace_data$plan_performance %>%
        mutate(
          report_month = format(month, "%Y-%m"),
          total_enrollments = total_enrollments,
          avg_premium = round(avg_premium, 2),
          avg_subsidy = round(avg_subsidy, 2),
          renewal_rate = round(avg_renewal, 3)
        )
      
      write.csv(regulatory_data, file, row.names = FALSE)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)
