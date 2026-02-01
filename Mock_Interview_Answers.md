# Mock Interview Questions & Answers

## 📚 **R Programming Questions**

### **1. What's the difference between `==` and `===` in R?**
**Answer:** `==` is the equality operator for element-wise comparison. `===` doesn't exist in base R (that's JavaScript). For exact equality in R, use `identical()` or `all.equal()` for floating-point tolerance.

```r
c(1, 2, 3) == c(1, 2, 4)  # TRUE, TRUE, FALSE
identical(c(1, 2, 3), c(1, 2, 3))  # TRUE
all.equal(0.1 + 0.2, 0.3)  # TRUE (with tolerance)
```

### **2. How would you handle memory issues with large datasets?**
**Answer:** Multiple strategies:
- Use `data.table` instead of `data.frame`
- Process data in chunks
- Use database connections (`DBI`, `RSQLite`)
- Remove unused objects and call `gc()`
- Use memory-efficient packages (`vroom`, `arrow`)
- Monitor usage with `object.size()` and `gc(verbose = TRUE)`

```r
library(data.table)
dt <- data.table(large_data)  # More memory efficient

# Process in chunks
read_large_in_chunks <- function(file, chunk_size = 10000) {
  # Read and process data in manageable pieces
}
```

### **3. Explain the difference between `lapply` and `sapply`.**
**Answer:** Both apply functions over lists, but differ in output:
- `lapply`: Always returns a list (predictable)
- `sapply`: Simplifies to vector/matrix when possible (convenient)
- `vapply`: Explicit output type (safe)

```r
lapply(list(1:3, 4:6), mean)  # Returns list
sapply(list(1:3, 4:6), mean)  # Returns named vector
vapply(list(1:3, 4:6), mean, numeric(1))  # Safe numeric output
```

### **4. What is S3 vs S4 object systems in R?**
**Answer:** Two object-oriented systems:
- **S3**: Simple, informal, dynamic, faster
- **S4**: Formal, strict, static, supports multiple inheritance

```r
# S3 - Simple
obj <- list(x = 1)
class(obj) <- "myclass"

# S4 - Formal
library(methods)
setClass("MyClass", slots = list(x = "numeric"))
obj <- new("MyClass", x = 1)
```

### **5. How do you optimize R code for performance?**
**Answer:** Key strategies:
- Vectorization instead of loops
- Use efficient packages (`data.table`, `Rcpp`)
- Pre-allocate memory
- Parallel processing (`parallel`, `future`)
- Profile with `profvis`
- Use appropriate data structures (factors)

```r
# Vectorized (fast)
result <- (1:1000000)^2

# Parallel processing
library(parallel)
cl <- makeCluster(detectCores() - 1)
parLapply(cl, 1:1000, function(x) x^2)
stopCluster(cl)
```

---

## 📦 **Package Development Questions**

### **1. What goes into a DESCRIPTION file?**
**Answer:** Package metadata including:
- Package name, version, title
- Author/maintainer information
- Description, license
- Dependencies (Depends, Imports, Suggests)
- URLs, bug reports

```r
Package: ClinicalUtils
Version: 0.1.0
Title: Clinical Data Analysis Utilities
Author: Justin Zhang
Description: Tools for clinical data analysis
License: MIT
Imports: dplyr (>= 1.0.0), ggplot2
Suggests: testthat, knitr
```

### **2. How do you handle dependencies in R packages?**
**Answer:** Through DESCRIPTION and NAMESPACE:
- **Depends**: Loaded automatically (use sparingly)
- **Imports**: Available but not loaded by default
- **Suggests**: Optional for examples/tests
- Use `importFrom` for specific functions
- Use `::` for occasional function calls

### **3. What's the difference between `@import` and `@importFrom`?**
**Answer:** 
- `@import`: Imports entire package namespace
- `@importFrom`: Imports specific functions (preferred)
- `@export`: Makes our functions available to users

```r
#' @importFrom dplyr filter mutate select
#' @export
my_function <- function() {
  data %>% filter(condition)
}
```

### **4. How do you write unit tests for R packages?**
**Answer:** Use `testthat` framework:
- Unit tests for individual functions
- Integration tests for workflows
- Edge cases and error handling
- Performance tests

```r
library(testthat)

test_that("function works correctly", {
  expect_no_error(my_function(valid_input))
  expect_error(my_function(invalid_input))
  expect_equal(my_function(1, 2), 3)
})
```

### **5. What's the process for submitting to CRAN?**
**Answer:** Multi-step process:
1. Create package with `devtools::create()`
2. Add functions, documentation, tests
3. Run `devtools::check()` (no ERRORs/WARNINGs)
4. Add documentation with `devtools::document()`
5. Test with `devtools::test()`
6. Build package with `devtools::build()`
7. Submit via CRAN web form
8. Address maintainer feedback

---

## 🌐 **Shiny Development Questions**

### **1. What are reactive expressions and when would you use them?**
**Answer:** Cached computations that only re-run when dependencies change. Use for expensive calculations that don't need to run every time.

```r
# Reactive expression - caches expensive computation
filtered_data <- reactive({
  input$dataset  # Dependency
  expensive_processing()  # Only runs when input changes
})

# Use in outputs
output$plot <- renderPlot({
  plot(filtered_data())  # Uses cached result
})
```

### **2. How do you optimize a slow Shiny app?**
**Answer:** Multiple optimization strategies:
- Use reactive expressions for caching
- Implement debouncing for frequent inputs
- Use server-side data tables
- Load data asynchronously
- Profile with `profvis`
- Use modules for organization

```r
# Debounce frequent inputs
text_input <- debounce(reactive({ input$text }), 1000)

# Server-side data tables
output$table <- DT::renderDataTable({
  DT::datatable(large_data, options = list(server = TRUE))
})

# Async data loading
data_loader <- reactive({
  future({ read_large_dataset(input$file) })
})
```

### **3. What are Shiny modules and why are they useful?**
**Answer:** Reusable UI/server components that avoid naming conflicts and improve code organization.

```r
# Module UI
inputModuleUI <- function(id) {
  ns <- NS(id)
  textInput(ns("text"), "Enter text")
}

# Module Server
inputModuleServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    return(reactive({ input$text }))
  })
}

# Usage
ui <- fluidPage(inputModuleUI("module1"))
server <- function(input, output, session) {
  text1 <- inputModuleServer("module1")
}
```

### **4. How do you handle user authentication in Shiny?**
**Answer:** Multiple approaches:
- Use `shinymanager` for basic auth
- Implement custom session management
- Use OAuth with `shinyauthr`
- LDAP/Active Directory integration
- Database-backed authentication

```r
library(shinymanager)

# Basic authentication
ui <- secure_app(fluidPage(...))
server <- function(input, output, session) {
  auth_server(
    check_credentials = check_credentials("admin", "password")
  )
}
```

### **5. What's the difference between `observe` and `observeEvent`?**
**Answer:**
- `observe`: Runs whenever any dependency changes (general side effects)
- `observeEvent`: Runs only when specific event occurs (button clicks, etc.)

```r
# observe - runs whenever input$text changes
observe({
  print(input$text)
})

# observeEvent - runs only when button clicked
observeEvent(input$button, {
  # Code to run when button clicked
  save_data()
})
```

---

## 🏥 **Clinical Data Analysis Questions**

### **1. What are CDISC standards and why are they important?**
**Answer:** CDISC (Clinical Data Interchange Standards Consortium) provides standardized formats for clinical trial data:
- **SDTM**: Study Data Tabulation Model (raw data)
- **ADaM**: Analysis Data Model (analysis-ready data)
- **Importance**: Regulatory compliance, data exchange, reproducibility
- **Benefits**: Standardization, efficiency, regulatory acceptance

### **2. How would you validate SDTM dataset structure?**
**Answer:** Multi-level validation:
- Required columns presence
- Data type checking
- Value constraints
- Relationship validation
- CDISC compliance rules

```r
validate_sdtm <- function(data, domain) {
  # Check required columns
  required_cols <- get_required_columns(domain)
  missing_cols <- setdiff(required_cols, names(data))
  
  # Check data types
  validate_data_types(data, domain)
  
  # Check value constraints
  validate_values(data, domain)
  
  return(validation_report)
}
```

### **3. What's the difference between SDTM and ADaM?**
**Answer:**
- **SDTM**: Raw collected data, observational level
- **ADaM**: Analysis datasets, derived variables, analysis-ready
- **SDTM**: One record per observation
- **ADaM**: One record per subject per analysis timepoint
- **ADaM**: Contains derived variables, flags, analysis parameters

### **4. How do you handle missing clinical data?**
**Answer:** Context-dependent approach:
- **Assess missingness pattern** (MCAR, MAR, MNAR)
- **Document missing reasons** in SDTM
- **Imputation strategies** (mean, median, multiple imputation)
- **Sensitivity analyses** for missing data impact
- **Regulatory documentation** of handling approach

### **5. What are common data quality checks for clinical trials?**
**Answer:** Essential quality checks:
- **Range checks** (age, dates, vital signs)
- **Consistency checks** (dates, relationships)
- **Uniqueness checks** (subject IDs, record IDs)
- **Completeness checks** (required fields)
- **Format validation** (dates, codes)
- **Cross-dataset validation** (DM vs AE vs VS)

```r
quality_checks <- function(data) {
  list(
    range_check = validate_ranges(data),
    consistency_check = validate_relationships(data),
    uniqueness_check = check_duplicates(data),
    completeness_check = check_required_fields(data)
  )
}
```

---

## 🎯 **Communication & Problem-Solving Questions**

### **1. How do you explain complex R code to non-technical stakeholders?**
**Answer:** Structure explanation:
1. **Business problem**: "We need to analyze patient demographics"
2. **Approach**: "I'm grouping patients by age and calculating averages"
3. **Code explanation**: Show with comments
4. **Results interpretation**: "This shows 60% of patients are 31-50"
5. **Business impact**: "This helps us understand our trial population"

### **2. How do you approach debugging R code?**
**Answer:** Systematic approach:
1. **Reproduce the issue** with minimal example
2. **Isolate the problem** by testing components
3. **Use debugging tools**: `debug()`, `browser()`, `traceback()`
4. **Check data**: `str()`, `class()`, `summary()`
5. **Validate assumptions**: `assertthat::assert_that()`
6. **Document solution** for future reference

### **3. How do you handle conflicting requirements from stakeholders?**
**Answer:** Collaborative approach:
1. **Understand requirements** from all parties
2. **Identify conflicts** and underlying needs
3. **Propose solutions** that address core concerns
4. **Document trade-offs** clearly
5. **Get consensus** on final approach
6. **Implement and validate** solution

### **4. How do you stay current with R ecosystem?**
**Answer:** Continuous learning:
- **R-bloggers** and **R Weekly** newsletters
- **Twitter** R community (#rstats)
- **Conferences**: useR!, RStudio Conference
- **GitHub**: Follow key R developers
- **CRAN Task Views**: Track package developments
- **Practice**: Implement new techniques in projects

### **5. How do you estimate development time for R projects?**
**Answer:** Realistic estimation:
1. **Break down** into small tasks
2. **Estimate each task** individually
3. **Add buffer** for unknown issues (25-50%)
4. **Consider dependencies** and risks
5. **Track progress** and update estimates
6. **Communicate early** about delays

---

## 🚀 **Portfolio Discussion Questions**

### **1. Walk me through your Clinical Data Viewer app.**
**Answer:** Structure explanation:
1. **Problem**: Need to visualize CDISC clinical trial data
2. **Solution**: Interactive Shiny dashboard with SDTM/ADaM datasets
3. **Architecture**: Modular design with reactive programming
4. **Features**: Data tables, plots, export, validation
5. **Technologies**: Shiny, plotly, DT, dplyr, CDISC standards
6. **Impact**: Demonstrates clinical domain expertise and Shiny skills

### **2. What was the most challenging technical problem you solved?**
**Answer:** STAR method:
- **Situation**: Performance issues with large clinical datasets
- **Task**: Optimize Shiny app loading time from 30s to <3s
- **Action**: Implemented data.table, reactive caching, async loading
- **Result**: 90% performance improvement, better user experience

### **3. How do you ensure code quality in your projects?**
**Answer:** Quality practices:
- **Code review**: Self-review and peer review
- **Testing**: Unit tests with testthat
- **Documentation**: Comprehensive roxygen2 docs
- **Style consistency**: lintr, styler packages
- **Version control**: Git with meaningful commits
- **CI/CD**: Automated testing on changes

### **4. How do you handle production deployment of Shiny apps?**
**Answer:** Production considerations:
- **Environment management**: Docker containers
- **Scaling**: Shiny Server Pro, Posit Connect
- **Monitoring**: Logging, error tracking
- **Security**: Authentication, data protection
- **Performance**: Caching, optimization
- **Maintenance**: Updates, backup strategies

### **5. What makes you a good fit for this Senior Shiny Developer role?**
**Answer:** Highlight relevant experience:
- **Technical expertise**: R, Shiny, package development
- **Domain knowledge**: Clinical data, CDISC standards
- **Portfolio evidence**: 10 production apps, documentation
- **Problem-solving**: Performance optimization, debugging
- **Communication**: Clear documentation, stakeholder management
- **Leadership**: Best practices, code review, mentoring
