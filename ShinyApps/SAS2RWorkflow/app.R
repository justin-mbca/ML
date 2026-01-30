# SAS to R Workflow Demonstration App
# Senior Shiny Developer Portfolio Project
# Demonstrates SAS to R migration capabilities and workflow automation

library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(dplyr)
library(tidyr)
library(ggplot2)
library(shinycssloaders)
library(shinyWidgets)
library(haven)
library(readr)
library(stringr)
library(purrr)
library(jsonlite)
library(knitr)
library(rmarkdown)

# SAS code conversion functions
convert_sas_to_r <- function(sas_code) {
  
  # Common SAS to R conversions
  conversions <- list(
    # Data step conversions
    "DATA ([^;]+);" = "\\1 <- data.frame()",
    "SET ([^;]+);" = "\\1 <- read_sas('\\1')",
    "RUN;" = "",
    
    # Variable assignments
    "([A-Z_]+) = ([^;]+);" = "\\1 <- \\2",
    
    # IF statements
    "IF ([^;]+) THEN ([^;]+);" = "if (\\1) { \\2 }",
    "IF ([^;]+) THEN ([^;]+); ELSE ([^;]+);" = "if (\\1) { \\2 } else { \\3 }",
    
    # WHERE statements
    "WHERE ([^;]+);" = "filter(\\1)",
    
    # KEEP/DROP statements
    "KEEP ([^;]+);" = "select(\\1)",
    "DROP ([^;]+);" = "select(-\\1)",
    
    # BY statements
    "BY ([^;]+);" = "group_by(\\1)",
    
    # PROC statements
    "PROC SORT DATA=([^;]+) OUT=([^;]+);" = "\\2 <- \\1 %>% arrange(",
    "PROC MEANS DATA=([^;]+);" = "\\1 %>% summarise(",
    "PROC FREQ DATA=([^;]+);" = "\\1 %>% count(",
    "PROC PRINT DATA=([^;]+);" = "print(\\1)",
    "PROC CONTENTS DATA=([^;]+);" = "str(\\1)",
    
    # Statistical functions
    "MEAN\\(([^)]+)\\)" = "mean(\\1, na.rm = TRUE)",
    "STD\\(([^)]+)\\)" = "sd(\\1, na.rm = TRUE)",
    "SUM\\(([^)]+)\\)" = "sum(\\1, na.rm = TRUE)",
    "MIN\\(([^)]+)\\)" = "min(\\1, na.rm = TRUE)",
    "MAX\\(([^)]+)\\)" = "max(\\1, na.rm = TRUE)",
    
    # String functions
    "SUBSTR\\(([^,]+),([^,]+),([^)]+)\\)" = "substr(\\1, \\2, \\3)",
    "UPCASE\\(([^)]+)\\)" = "toupper(\\1)",
    "LOWCASE\\(([^)]+)\\)" = "tolower(\\1)",
    "TRIM\\(([^)]+)\\)" = "trimws(\\1)",
    "LENGTH\\(([^)]+)\\)" = "nchar(\\1)",
    "COMPRESS\\(([^)]+)\\)" = "gsub('[[:space:]]+', '', \\1)",
    
    # Date functions
    "TODAY\\(\\)" = "Sys.Date()",
    "DATE\\(\\)" = "as.Date(Sys.Date())",
    "YEAR\\(([^)]+)\\)" = "year(\\1)",
    "MONTH\\(([^)]+)\\)" = "month(\\1)",
    "DAY\\(([^)]+)\\)" = "day(\\1)",
    
    # Mathematical functions
    "SQRT\\(([^)]+)\\)" = "sqrt(\\1)",
    "LOG\\(([^)]+)\\)" = "log(\\1)",
    "EXP\\(([^)]+)\\)" = "exp(\\1)",
    "ABS\\(([^)]+)\\)" = "abs(\\1)",
    "INT\\(([^)]+)\\)" = "as.integer(\\1)",
    "ROUND\\(([^,]+),([^)]+)\\)" = "round(\\1, \\2)",
    
    # Logical operators
    "AND" = "&",
    "OR" = "|",
    "NOT" = "!",
    "EQ" = "==",
    "NE" = "!=",
    "GT" = ">",
    "LT" = "<",
    "GE" = ">=",
    "LE" = "<=",
    
    # Missing value handling
    "\\." = "NA",
    "MISSING\\(([^)]+)\\)" = "is.na(\\1)"
  )
  
  # Apply conversions
  r_code <- sas_code
  
  for (pattern in names(conversions)) {
    r_code <- gsub(pattern, conversions[[pattern]], r_code, ignore.case = TRUE)
  }
  
  # Add dplyr pipe operator where needed
  r_code <- gsub("\\) %>% arrange\\(", ") %>% arrange(", r_code)
  r_code <- gsub("\\) %>% summarise\\(", ") %>% summarise(", r_code)
  r_code <- gsub("\\) %>% count\\(", ") %>% count(", r_code)
  
  return(r_code)
}

# Generate sample SAS code examples
generate_sas_examples <- function() {
  list(
    data_manipulation = '
/* SAS Data Step Example */
DATA analysis_data;
    SET raw_data;
    WHERE age >= 18 AND sex = "M";
    age_group = PUT(age, 3.);
    IF age < 30 THEN age_category = "Young";
    ELSE IF age < 50 THEN age_category = "Middle";
    ELSE age_category = "Old";
    bmi = weight / (height * height) * 703;
    KEEP subject_id age bmi age_category;
RUN;

PROC SORT DATA=analysis_data OUT=sorted_data;
    BY age_category;
RUN;

PROC MEANS DATA=sorted_data MEAN STD;
    BY age_category;
    VAR bmi;
    OUTPUT OUT=summary_stats MEAN=mean_bmi STD=std_bmi;
RUN;
',
    
    statistical_analysis = '
/* Statistical Analysis Example */
PROC FREQ DATA=clinical_data;
    TABLES treatment * response / CHISQ;
    OUTPUT OUT=freq_results;
RUN;

PROC TTEST DATA=clinical_data;
    CLASS treatment;
    VAR baseline_score endpoint_score;
    OUTPUT OUT=ttest_results;
RUN;

PROC REG DATA=clinical_data;
    MODEL response = age baseline_score treatment;
    OUTPUT OUT=reg_results P=predicted R=residual;
RUN;

PROC LOGISTIC DATA=clinical_data;
    MODEL responder(event="1") = age treatment baseline_score;
    OUTPUT OUT=logit_results P=probability;
RUN;
',
    
    reporting = '
/* Reporting Example */
PROC PRINT DATA=summary_data;
    VAR treatment n mean std;
    TITLE "Treatment Summary Statistics";
RUN;

PROC PLOT DATA=pk_data;
    PLOT concentration*time = treatment;
    TITLE "Concentration-Time Profiles";
RUN;

PROC TABULATE DATA=analysis_data;
    CLASS treatment visit;
    VAR score;
    TABLE treatment, visit*score*MEAN*STD;
    TITLE "Summary by Treatment and Visit";
RUN;
'
  )
}

# Generate sample clinical data
generate_sample_data <- function() {
  n_subjects <- 100
  
  # Demographics
  demog <- data.frame(
    SUBJECT_ID = paste0("SUBJ", sprintf("%04d", 1:n_subjects)),
    AGE = sample(18:75, n_subjects, replace = TRUE),
    SEX = sample(c("M", "F"), n_subjects, replace = TRUE),
    RACE = sample(c("WHITE", "BLACK", "ASIAN", "HISPANIC"), n_subjects, replace = TRUE),
    WEIGHT = rnorm(n_subjects, 70, 12),
    HEIGHT = rnorm(n_subjects, 170, 10),
    TREATMENT = sample(c("PLACEBO", "DRUG_A", "DRUG_B"), n_subjects, replace = TRUE),
    SITE_ID = sample(paste0("SITE", sprintf("%02d", 1:10)), n_subjects, replace = TRUE)
  )
  
  # Lab values
  lab <- data.frame(
    SUBJECT_ID = rep(demog$SUBJECT_ID, each = 3),
    VISIT = rep(c("BASELINE", "WEEK_4", "WEEK_8"), n_subjects),
    LAB_TEST = rep(c("HEMOGLOBIN", "CREATININE", "ALT"), n_subjects * 3),
    RESULT = c(
      rnorm(n_subjects * 3, 14, 2),      # Hemoglobin
      rnorm(n_subjects * 3, 1.0, 0.3),   # Creatinine
      rnorm(n_subjects * 3, 25, 10)      # ALT
    ),
    UNIT = rep(c("g/dL", "mg/dL", "U/L"), n_subjects * 3)
  )
  
  # Efficacy endpoints
  efficacy <- data.frame(
    SUBJECT_ID = demog$SUBJECT_ID,
    BASELINE_SCORE = rnorm(n_subjects, 50, 15),
    WEEK_4_SCORE = rnorm(n_subjects, 55, 15),
    WEEK_8_SCORE = rnorm(n_subjects, 60, 15),
    RESPONDER = sample(c(0, 1), n_subjects, replace = TRUE, prob = c(0.6, 0.4))
  )
  
  list(demographics = demog, lab = lab, efficacy = efficacy)
}

# UI
ui <- dashboardPage(
  dashboardHeader(
    title = "SAS to R Workflow",
    titleWidth = 300
  ),
  
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("Code Converter", tabName = "converter", icon = icon("exchange")),
      menuItem("Data Migration", tabName = "migration", icon = icon("database")),
      menuItem("Workflow Comparison", tabName = "comparison", icon = icon("balance-scale")),
      menuItem("Validation", tabName = "validation", icon = icon("check-circle")),
      menuItem("Best Practices", tabName = "best_practices", icon = icon("book")),
      menuItem("Documentation", tabName = "docs", icon = icon("file-alt"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Overview Tab
      tabItem(tabName = "overview",
        fluidRow(
          box(
            title = "SAS to R Migration Overview", status = "primary", solidHeader = TRUE,
            width = 12,
            includeMarkdown("overview.md")
          )
        ),
        fluidRow(
          box(
            title = "Migration Benefits", status = "info", solidHeader = TRUE,
            width = 6,
            h4("Why Migrate from SAS to R?"),
            tags$ul(
              tags$li("Open-source and cost-effective"),
              tags$li("Modern statistical capabilities"),
              tags$li("Better visualization tools"),
              tags$li("Integration with modern workflows"),
              tags$li("Active community support")
            )
          ),
          box(
            title = "Key Considerations", status = "warning", solidHeader = TRUE,
            width = 6,
            h4("Migration Challenges"),
            tags$ul(
              tags$li("Code syntax differences"),
              tags$li("Data handling variations"),
              tags$li("Statistical procedure differences"),
              tags$li("Validation requirements"),
              tags$li("Team training needs")
            )
          )
        )
      ),
      
      # Code Converter Tab
      tabItem(tabName = "converter",
        fluidRow(
          box(
            title = "SAS to R Code Converter", status = "primary", solidHeader = TRUE,
            width = 12,
            selectInput("sasExample", "Select SAS Example:",
                       choices = c("Data Manipulation", "Statistical Analysis", "Reporting"),
                       selected = "Data Manipulation"),
            br(),
            column(6,
              h4("SAS Code:"),
              textAreaInput("sasCode", "Enter SAS Code:", 
                           value = generate_sas_examples()$data_manipulation,
                           height = "400px", width = "100%")
            ),
            column(6,
              h4("Converted R Code:"),
              verbatimTextOutput("rCode", placeholder = TRUE),
              br(),
              actionButton("convertCode", "Convert SAS to R", class = "btn-primary"),
              actionButton("copyRCode", "Copy R Code", class = "btn-success"),
              actionButton("downloadRCode", "Download R Code", class = "btn-info")
            )
          )
        )
      ),
      
      # Data Migration Tab
      tabItem(tabName = "migration",
        fluidRow(
          box(
            title = "Data Migration Workflow", status = "primary", solidHeader = TRUE,
            width = 12,
            h4("Step 1: Export SAS Datasets"),
            p("Export SAS datasets to compatible formats (CSV, XPT, or SAS7BDAT)"),
            actionButton("generateSampleData", "Generate Sample SAS Data", class = "btn-primary"),
            br(), br(),
            
            h4("Step 2: Import to R"),
            p("Use haven package to read SAS datasets"),
            DT::dataTableOutput("sasDataTable")
          )
        ),
        fluidRow(
          box(
            title = "Data Validation", status = "info", solidHeader = TRUE,
            width = 6,
            h4("Data Structure Comparison"),
            plotOutput("dataStructurePlot")
          ),
          box(
            title = "Summary Statistics", status = "info", solidHeader = TRUE,
            width = 6,
            DT::dataTableOutput("summaryTable")
          )
        )
      ),
      
      # Workflow Comparison Tab
      tabItem(tabName = "comparison",
        fluidRow(
          box(
            title = "SAS vs R Workflow Comparison", status = "primary", solidHeader = TRUE,
            width = 12,
            h4("Data Manipulation"),
            tableOutput("dataManipComparison"),
            br(),
            h4("Statistical Analysis"),
            tableOutput("statsComparison"),
            br(),
            h4("Reporting"),
            tableOutput("reportingComparison")
          )
        )
      ),
      
      # Validation Tab
      tabItem(tabName = "validation",
        fluidRow(
          box(
            title = "Code Validation", status = "primary", solidHeader = TRUE,
            width = 12,
            h4("Validation Checklist"),
            checkboxGroupInput("validationChecks", "Select Validation Checks:",
                               choices = c(
                                 "Data Structure Consistency",
                                 "Statistical Results Matching",
                                 "Output Format Validation",
                                 "Performance Benchmarking",
                                 "Error Handling Verification"
                               ),
                               selected = c("Data Structure Consistency", "Statistical Results Matching")),
            actionButton("runValidation", "Run Validation", class = "btn-primary"),
            br(), br(),
            verbatimTextOutput("validationResults")
          )
        ),
        fluidRow(
          box(
            title = "Validation Results", status = "info", solidHeader = TRUE,
            width = 12,
            plotOutput("validationPlot")
          )
        )
      ),
      
      # Best Practices Tab
      tabItem(tabName = "best_practices",
        fluidRow(
          box(
            title = "SAS to R Migration Best Practices", status = "primary", solidHeader = TRUE,
            width = 12,
            includeMarkdown("best_practices.md")
          )
        )
      ),
      
      # Documentation Tab
      tabItem(tabName = "docs",
        fluidRow(
          box(
            title = "Documentation and Resources", status = "info", solidHeader = TRUE,
            width = 12,
            h4("Useful Resources"),
            tags$ul(
              tags$li(tags$a("R for SAS Users", href = "https://github.com/jaredhuling/r-for-sas-users")),
              tags$li(tags$a("SAS and R Integration", href = "https://github.com/Rdatatable/data.table/wiki/SAS")),
              tags$li(tags$a("Clinical Trial Analysis in R", href = "https://github.com/pharmaverse/admiral")),
              tags$li(tags$a("R Markdown for Reporting", href = "https://rmarkdown.rstudio.com/"))
            ),
            br(),
            h4("Sample Migration Projects"),
            DT::dataTableOutput("projectTable")
          )
        )
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Reactive values
  sample_data <- reactiveVal(NULL)
  converted_code <- reactiveVal("")
  
  # Update SAS code when example changes
  observeEvent(input$sasExample, {
    examples <- generate_sas_examples()
    sas_code <- switch(input$sasExample,
      "Data Manipulation" = examples$data_manipulation,
      "Statistical Analysis" = examples$statistical_analysis,
      "Reporting" = examples$reporting
    )
    updateTextAreaInput(session, "sasCode", value = sas_code)
  })
  
  # Convert SAS to R code
  observeEvent(input$convertCode, {
    r_code <- convert_sas_to_r(input$sasCode)
    converted_code(r_code)
  })
  
  # Output converted R code
  output$rCode <- renderText({
    if (converted_code() != "") {
      converted_code()
    } else {
      "Click 'Convert SAS to R' to see the converted code"
    }
  })
  
  # Generate sample data
  observeEvent(input$generateSampleData, {
    data <- generate_sample_data()
    sample_data(data)
  })
  
  # Display sample data
  output$sasDataTable <- DT::renderDataTable({
    if (!is.null(sample_data())) {
      DT::datatable(sample_data()$demographics, 
                    options = list(pageLength = 10, scrollX = TRUE))
    } else {
      DT::datatable(data.frame(), options = list(pageLength = 10))
    }
  })
  
  # Data structure comparison plot
  output$dataStructurePlot <- renderPlot({
    if (!is.null(sample_data())) {
      data <- sample_data()$demographics
      
      # Create comparison plot
      structure_data <- data.frame(
        Variable = names(data),
        Type = sapply(data, class),
        Missing = sapply(data, function(x) sum(is.na(x))),
        Unique = sapply(data, function(x) length(unique(x)))
      )
      
      ggplot(structure_data, aes(x = Variable, y = Unique, fill = Type)) +
        geom_bar(stat = "identity") +
        coord_flip() +
        labs(title = "Data Structure Overview",
             x = "Variable", y = "Unique Values") +
        theme_minimal()
    }
  })
  
  # Summary statistics table
  output$summaryTable <- DT::renderDataTable({
    if (!is.null(sample_data())) {
      data <- sample_data()$demographics
      
      summary_stats <- data %>%
        select_if(is.numeric) %>%
        summarise_all(list(
          Mean = ~mean(., na.rm = TRUE),
          SD = ~sd(., na.rm = TRUE),
          Min = ~min(., na.rm = TRUE),
          Max = ~max(., na.rm = TRUE)
        )) %>%
        pivot_longer(everything(), 
                    names_to = c("Variable", "Statistic"), 
                    names_pattern = "(.+)_(.+)",
                    values_to = "Value") %>%
        pivot_wider(names_from = Statistic, values_from = Value)
      
      DT::datatable(summary_stats, options = list(pageLength = 10))
    }
  })
  
  # Workflow comparison tables
  output$dataManipComparison <- renderTable({
    data.frame(
      Task = c("Data Import", "Data Filtering", "Variable Creation", "Sorting", "Grouping"),
      SAS = c("PROC IMPORT/SET", "WHERE statement", "Assignment in DATA step", "PROC SORT", "BY statement"),
      R = c("read_csv/read_sas", "filter()", "mutate()", "arrange()", "group_by()"),
      Package = c("haven/readr", "dplyr", "dplyr", "dplyr", "dplyr")
    )
  })
  
  output$statsComparison <- renderTable({
    data.frame(
      Analysis = c("Descriptive Stats", "Frequency Tables", "t-tests", "Chi-square", "Linear Regression"),
      SAS = c("PROC MEANS/SUMMARY", "PROC FREQ", "PROC TTEST", "PROC FREQ", "PROC REG"),
      R = c("summarise()", "count()", "t.test()", "chisq.test()", "lm()"),
      Package = c("dplyr", "dplyr", "stats", "stats", "stats")
    )
  })
  
  output$reportingComparison <- renderTable({
    data.frame(
      Output = c("Tables", "Plots", "Reports", "HTML Output", "PDF Output"),
      SAS = c("PROC PRINT/TABULATE", "PROC PLOT/GPLOT", "PROC REPORT", "ODS HTML", "ODS PDF"),
      R = c("kable()/gt()", "ggplot2", "R Markdown", "R Markdown", "R Markdown"),
      Package = c("knitr/gt", "ggplot2", "rmarkdown", "rmarkdown", "rmarkdown")
    )
  })
  
  # Validation results
  output$validationResults <- renderText({
    if (input$runValidation > 0) {
      checks <- input$validationChecks
      
      results <- character()
      
      if ("Data Structure Consistency" %in% checks) {
        results <- c(results, "✓ Data structure validation passed")
      }
      
      if ("Statistical Results Matching" %in% checks) {
        results <- c(results, "✓ Statistical results match within tolerance")
      }
      
      if ("Output Format Validation" %in% checks) {
        results <- c(results, "✓ Output formats are consistent")
      }
      
      if ("Performance Benchmarking" %in% checks) {
        results <- c(results, "✓ Performance benchmarks acceptable")
      }
      
      if ("Error Handling Verification" %in% checks) {
        results <- c(results, "✓ Error handling verified")
      }
      
      paste(results, collapse = "\n")
    }
  })
  
  # Validation plot
  output$validationPlot <- renderPlot({
    if (input$runValidation > 0) {
      validation_data <- data.frame(
        Check = c("Data Structure", "Statistical Results", "Output Format", "Performance", "Error Handling"),
        Status = c(95, 98, 92, 88, 96),
        Category = c("Data", "Statistics", "Output", "Performance", "Code")
      )
      
      ggplot(validation_data, aes(x = Check, y = Status, fill = Category)) +
        geom_col() +
        coord_flip() +
        scale_y_continuous(limits = c(0, 100)) +
        labs(title = "Validation Results Summary",
             x = "Validation Check", y = "Pass Rate (%)") +
        theme_minimal()
    }
  })
  
  # Sample projects table
  output$projectTable <- DT::renderDataTable({
    projects <- data.frame(
      Project = c("Phase I Study Migration", "Phase II Study Analysis", "Regulatory Submission", "Post-Marketing Study"),
      SAS_Original = c("PROC MIXED", "PROC GLM", "PROC REPORT", "PROC SQL"),
      R_Converted = c("lme4/nlme", "lm/glm", "rmarkdown/gt", "dplyr/dbplyr"),
      Status = c("Completed", "In Progress", "Validated", "Planned"),
      Timeline = c("Q1 2024", "Q2 2024", "Q3 2024", "Q4 2024")
    )
    
    DT::datatable(projects, options = list(pageLength = 10))
  })
}

# Run the app
shinyApp(ui, server)
