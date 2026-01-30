# HPC/Linux Data Processing Dashboard
# Senior Shiny Developer Portfolio Project
# Demonstrates high-performance computing and Linux environment integration

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
library(processx)
library(fs)

# Simulate HPC system data
generate_hpc_data <- function() {
  # Cluster nodes
  nodes <- data.frame(
    NODE_ID = paste0("node", sprintf("%03d", 1:20)),
    NODE_TYPE = sample(c("Compute", "Login", "Storage", "GPU"), 20, replace = TRUE, prob = c(0.6, 0.15, 0.15, 0.1)),
    STATUS = sample(c("Available", "Busy", "Maintenance", "Offline"), 20, replace = TRUE, prob = c(0.5, 0.3, 0.15, 0.05)),
    CPU_CORES = sample(c(16, 32, 64, 128), 20, replace = TRUE),
    MEMORY_GB = sample(c(64, 128, 256, 512), 20, replace = TRUE),
    CPU_USAGE = sample(0:100, 20, replace = TRUE),
    MEMORY_USAGE = sample(0:100, 20, replace = TRUE),
    LOAD_AVERAGE = runif(20, 0, 10),
    UPTIME_DAYS = sample(1:365, 20, replace = TRUE),
    LAST_UPDATE = Sys.time() - sample(0:3600, 20, replace = TRUE)
  )
  
  # Jobs
  jobs <- data.frame(
    JOB_ID = paste0("job", sprintf("%06d", sample(100000:999999, 50))),
    USER = sample(c("jsmith", "jdoe", "mjohnson", "swilson", "tbrown", "admin"), 50, replace = TRUE),
    NODE_ID = sample(nodes$NODE_ID, 50, replace = TRUE),
    JOB_NAME = paste0("analysis_", sample(1:100, 50)),
    STATUS = sample(c("Running", "Queued", "Completed", "Failed", "Held"), 50, replace = TRUE, prob = c(0.3, 0.2, 0.3, 0.1, 0.1)),
    PRIORITY = sample(c("High", "Medium", "Low"), 50, replace = TRUE, prob = c(0.2, 0.6, 0.2)),
    SUBMIT_TIME = Sys.time() - sample(0:86400*7, 50, replace = TRUE),
    START_TIME = Sys.time() - sample(0:86400*3, 50, replace = TRUE),
    WALLTIME_LIMIT = sample(c(3600, 7200, 14400, 28800, 86400), 50, replace = TRUE),
    WALLTIME_USED = sample(0:86400, 50, replace = TRUE),
    CPU_CORES_USED = sample(1:32, 50, replace = TRUE),
    MEMORY_USED_GB = sample(1:64, 50, replace = TRUE),
    PARTITION = sample(c("short", "medium", "long", "gpu"), 50, replace = TRUE, prob = c(0.3, 0.3, 0.3, 0.1))
  )
  
  # Update job times based on status
  jobs <- jobs %>%
    mutate(
      START_TIME = ifelse(STATUS == "Running", START_TIME, NA),
      WALLTIME_USED = ifelse(STATUS == "Queued", 0, WALLTIME_USED),
      COMPLETION_TIME = ifelse(STATUS == "Completed", START_TIME + WALLTIME_USED, NA)
    )
  
  # Storage systems
  storage <- data.frame(
    STORAGE_ID = paste0("storage", sprintf("%02d", 1:5)),
    STORAGE_TYPE = c("Lustre", "NFS", "Local SSD", "Tape Archive", "Cloud"),
    TOTAL_CAPACITY_TB = c(500, 100, 10, 1000, 2000),
    USED_CAPACITY_TB = c(350, 80, 8, 200, 500),
    AVAILABLE_CAPACITY_TB = c(150, 20, 2, 800, 1500),
    USAGE_PERCENT = c(70, 80, 80, 20, 25),
    IOPS = c(100000, 50000, 200000, 1000, 50000),
    THROUGHPUT_MBPS = c(10000, 5000, 2000, 100, 8000),
    STATUS = c("Healthy", "Healthy", "Healthy", "Maintenance", "Healthy")
  )
  
  # Network metrics
  network <- data.frame(
    TIMESTAMP = Sys.time() - seq(0, 3600, by = 60),
    INBOUND_GBPS = runif(61, 0.5, 2.0),
    OUTBOUND_GBPS = runif(61, 0.3, 1.5),
    PACKET_LOSS = runif(61, 0, 0.01),
    LATENCY_MS = runif(61, 0.1, 5.0),
    CONNECTIONS = sample(1000:5000, 61, replace = TRUE)
  )
  
  list(nodes = nodes, jobs = jobs, storage = storage, network = network)
}

# System monitoring functions
get_system_metrics <- function() {
  # Simulate system metrics
  list(
    cpu_usage = sample(0:100, 1),
    memory_usage = sample(0:100, 1),
    disk_usage = sample(0:100, 1),
    load_average = runif(1, 0, 10),
    uptime = sample(1:365, 1),
    processes = sample(100:500, 1),
    connections = sample(1000:5000, 1)
  )
}

# Execute Linux command simulation
execute_linux_command <- function(command) {
  # Simulate command execution
  if (command == "ls") {
    "file1.txt\nfile2.csv\nanalysis.R\nreport.html"
  } else if (command == "ps aux") {
    "USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND\njsmith    1234  2.5  1.2 123456 12345 ?        S    10:00   0:05 R analysis.R\njdoe      5678  1.0  0.8  98765  9876 ?        S    09:30   0:02 python script.py"
  } else if (command == "df -h") {
    "Filesystem      Size  Used Avail Use% Mounted on\n/dev/sda1        100G   50G   50G  50% /\n/dev/sdb1        500G  350G  150G  70% /data"
  } else if (command == "free -h") {
    "              total        used        free      shared  buff/cache   available\nMem:           125G         45G         60G       1.2G        20G         78G\nSwap:          8.0G          0B        8.0G"
  } else {
    paste("Command executed:", command)
  }
}

# UI
ui <- dashboardPage(
  dashboardHeader(
    title = "HPC Dashboard",
    titleWidth = 300,
    dropdownMenu(type = "messages",
                 messageItem("System Alert", "Node node003 is offline", "2024-01-30"),
                 messageItem("Job Complete", "job123456 completed successfully", "2024-01-30")),
    dropdownMenu(type = "notifications",
                 notificationItem("High Load", "CPU usage above 80%", icon = icon("exclamation-triangle")),
                 notificationItem("Storage Warning", "Storage at 85% capacity", icon = icon("database")))
  ),
  
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("Nodes", tabName = "nodes", icon = icon("server")),
      menuItem("Jobs", tabName = "jobs", icon = icon("tasks")),
      menuItem("Storage", tabName = "storage", icon = icon("database")),
      menuItem("Network", tabName = "network", icon = icon("network-wired")),
      menuItem("Terminal", tabName = "terminal", icon = icon("terminal")),
      menuItem("Performance", tabName = "performance", icon = icon("tachometer-alt")),
      menuItem("Logs", tabName = "logs", icon = icon("file-alt")),
      menuItem("Settings", tabName = "settings", icon = icon("cog"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Overview Tab
      tabItem(tabName = "overview",
        fluidRow(
          box(
            title = "System Overview", status = "primary", solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(3, valueBoxOutput("totalNodes")),
              column(3, valueBoxOutput("activeJobs")),
              column(3, valueBoxOutput("cpuUsage")),
              column(3, valueBoxOutput("memoryUsage"))
            )
          )
        ),
        fluidRow(
          box(
            title = "Cluster Status", status = "info", solidHeader = TRUE,
            width = 6,
            plotOutput("clusterStatusPlot")
          ),
          box(
            title = "Resource Utilization", status = "warning", solidHeader = TRUE,
            width = 6,
            plotOutput("resourceUtilizationPlot")
          )
        )
      ),
      
      # Nodes Tab
      tabItem(tabName = "nodes",
        fluidRow(
          box(
            title = "Node Management", status = "primary", solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(3,
                selectInput("nodeType", "Node Type:", 
                           choices = c("All", "Compute", "Login", "Storage", "GPU"),
                           selected = "All")
              ),
              column(3,
                selectInput("nodeStatus", "Status:",
                           choices = c("All", "Available", "Busy", "Maintenance", "Offline"),
                           selected = "All")
              ),
              column(3,
                actionButton("refreshNodes", "Refresh Nodes", class = "btn-primary")
              ),
              column(3,
                actionButton("addNode", "Add Node", class = "btn-success")
              )
            )
          )
        ),
        fluidRow(
          box(
            title = "Node Details", status = "info", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("nodesTable")
          )
        )
      ),
      
      # Jobs Tab
      tabItem(tabName = "jobs",
        fluidRow(
          box(
            title = "Job Queue", status = "primary", solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(2,
                selectInput("jobStatus", "Status:",
                           choices = c("All", "Running", "Queued", "Completed", "Failed", "Held"),
                           selected = "All")
              ),
              column(2,
                selectInput("jobUser", "User:",
                           choices = c("All", "jsmith", "jdoe", "mjohnson", "swilson", "tbrown"),
                           selected = "All")
              ),
              column(2,
                selectInput("jobPartition", "Partition:",
                           choices = c("All", "short", "medium", "long", "gpu"),
                           selected = "All")
              ),
              column(2,
                actionButton("submitJob", "Submit Job", class = "btn-success")
              ),
              column(2,
                actionButton("cancelJob", "Cancel Job", class = "btn-danger")
              ),
              column(2,
                actionButton("holdJob", "Hold Job", class = "btn-warning")
              )
            )
          )
        ),
        fluidRow(
          box(
            title = "Job Statistics", status = "info", solidHeader = TRUE,
            width = 6,
            plotOutput("jobStatsPlot")
          ),
          box(
            title = "Queue Status", status = "warning", solidHeader = TRUE,
            width = 6,
            plotOutput("queueStatusPlot")
          )
        ),
        fluidRow(
          box(
            title = "Job List", status = "info", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("jobsTable")
          )
        )
      ),
      
      # Storage Tab
      tabItem(tabName = "storage",
        fluidRow(
          box(
            title = "Storage Systems", status = "primary", solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(3,
                actionButton("refreshStorage", "Refresh Storage", class = "btn-primary")
              ),
              column(3,
                actionButton("cleanupStorage", "Cleanup Storage", class = "btn-warning")
              ),
              column(3,
                actionButton("backupStorage", "Backup Storage", class = "btn-info")
              ),
              column(3,
                actionButton("expandStorage", "Expand Storage", class = "btn-success")
              )
            )
          )
        ),
        fluidRow(
          box(
            title = "Storage Usage", status = "info", solidHeader = TRUE,
            width = 12,
            plotOutput("storageUsagePlot", height = "400px")
          )
        ),
        fluidRow(
          box(
            title = "Storage Details", status = "warning", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("storageTable")
          )
        )
      ),
      
      # Network Tab
      tabItem(tabName = "network",
        fluidRow(
          box(
            title = "Network Performance", status = "primary", solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(6,
                plotOutput("networkThroughputPlot")
              ),
              column(6,
                plotOutput("networkLatencyPlot")
              )
            )
          )
        ),
        fluidRow(
          box(
            title = "Network Statistics", status = "info", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("networkTable")
          )
        )
      ),
      
      # Terminal Tab
      tabItem(tabName = "terminal",
        fluidRow(
          box(
            title = "Linux Terminal", status = "primary", solidHeader = TRUE,
            width = 12,
            div(style = "background-color: black; color: white; padding: 10px; font-family: monospace; height: 400px; overflow-y: auto;",
                verbatimTextOutput("terminalOutput", placeholder = TRUE)
            ),
            textInput("terminalCommand", "Command:", placeholder = "Enter Linux command..."),
            fluidRow(
              column(6,
                actionButton("executeCommand", "Execute", class = "btn-primary")
              ),
              column(6,
                actionButton("clearTerminal", "Clear", class = "btn-secondary")
              )
            )
          )
        )
      ),
      
      # Performance Tab
      tabItem(tabName = "performance",
        fluidRow(
          box(
            title = "System Performance", status = "primary", solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(6,
                plotOutput("cpuPerformancePlot")
              ),
              column(6,
                plotOutput("memoryPerformancePlot")
              )
            )
          )
        ),
        fluidRow(
          box(
            title = "Performance Metrics", status = "info", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("performanceTable")
          )
        )
      ),
      
      # Logs Tab
      tabItem(tabName = "logs",
        fluidRow(
          box(
            title = "System Logs", status = "primary", solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(3,
                selectInput("logLevel", "Log Level:",
                           choices = c("All", "ERROR", "WARNING", "INFO", "DEBUG"),
                           selected = "All")
              ),
              column(3,
                selectInput("logSource", "Source:",
                           choices = c("All", "System", "Jobs", "Network", "Storage"),
                           selected = "All")
              ),
              column(3,
                dateInput("logDate", "Date:", value = Sys.Date())
              ),
              column(3,
                actionButton("refreshLogs", "Refresh Logs", class = "btn-primary")
              )
            )
          )
        ),
        fluidRow(
          box(
            title = "Log Entries", status = "info", solidHeader = TRUE,
            width = 12,
            DT::dataTableOutput("logsTable")
          )
        )
      ),
      
      # Settings Tab
      tabItem(tabName = "settings",
        fluidRow(
          box(
            title = "System Settings", status = "primary", solidHeader = TRUE,
            width = 12,
            h4("Cluster Configuration"),
            numericInput("maxJobs", "Max Concurrent Jobs:", value = 100, min = 1, max = 1000),
            numericInput("defaultWalltime", "Default Walltime (hours):", value = 24, min = 1, max = 168),
            numericInput("maxMemory", "Max Memory per Job (GB):", value = 128, min = 1, max = 1024),
            br(),
            h4("Monitoring Settings"),
            checkboxInput("enableAlerts", "Enable System Alerts", TRUE),
            checkboxInput("enableAutoScaling", "Enable Auto Scaling", TRUE),
            checkboxInput("enableLoadBalancing", "Enable Load Balancing", TRUE),
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
  hpc_data <- reactiveVal(generate_hpc_data())
  system_metrics <- reactiveVal(get_system_metrics())
  terminal_history <- reactiveVal(character())
  
  # Auto-refresh data
  observe({
    invalidateLater(5000, session)  # Refresh every 5 seconds
    system_metrics(get_system_metrics())
  })
  
  # Overview outputs
  output$totalNodes <- renderValueBox({
    nodes <- hpc_data()$nodes
    available_nodes <- sum(nodes$STATUS == "Available")
    
    valueBox(
      value = paste0(available_nodes, "/", nrow(nodes)),
      subtitle = "Available/Total Nodes",
      icon = icon("server"),
      color = "blue"
    )
  })
  
  output$activeJobs <- renderValueBox({
    jobs <- hpc_data()$jobs
    running_jobs <- sum(jobs$STATUS == "Running")
    
    valueBox(
      value = running_jobs,
      subtitle = "Running Jobs",
      icon = icon("tasks"),
      color = "green"
    )
  })
  
  output$cpuUsage <- renderValueBox({
    cpu_usage <- system_metrics()$cpu_usage
    
    color <- ifelse(cpu_usage > 80, "red", ifelse(cpu_usage > 60, "yellow", "green"))
    
    valueBox(
      value = paste0(cpu_usage, "%"),
      subtitle = "CPU Usage",
      icon = icon("microchip"),
      color = color
    )
  })
  
  output$memoryUsage <- renderValueBox({
    memory_usage <- system_metrics()$memory_usage
    
    color <- ifelse(memory_usage > 80, "red", ifelse(memory_usage > 60, "yellow", "green"))
    
    valueBox(
      value = paste0(memory_usage, "%"),
      subtitle = "Memory Usage",
      icon = icon("memory"),
      color = color
    )
  })
  
  # Cluster status plot
  output$clusterStatusPlot <- renderPlot({
    nodes <- hpc_data()$nodes
    status_counts <- nodes %>% count(STATUS)
    
    ggplot(status_counts, aes(x = STATUS, y = n, fill = STATUS)) +
      geom_col() +
      geom_text(aes(label = n), vjust = -0.5) +
      labs(title = "Cluster Node Status",
           x = "Status", y = "Number of Nodes") +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  # Resource utilization plot
  output$resourceUtilizationPlot <- renderPlot({
    nodes <- hpc_data()$nodes
    
    ggplot(nodes, aes(x = CPU_USAGE, y = MEMORY_USAGE)) +
      geom_point(aes(color = NODE_TYPE, size = CPU_CORES), alpha = 0.7) +
      scale_color_brewer(type = "qual", palette = "Set1") +
      labs(title = "Resource Utilization by Node",
           x = "CPU Usage (%)", y = "Memory Usage (%)",
           color = "Node Type", size = "CPU Cores") +
      theme_minimal()
  })
  
  # Nodes table
  output$nodesTable <- DT::renderDataTable({
    nodes <- hpc_data()$nodes
    
    if (input$nodeType != "All") {
      nodes <- nodes %>% filter(NODE_TYPE == input$nodeType)
    }
    
    if (input$nodeStatus != "All") {
      nodes <- nodes %>% filter(STATUS == input$nodeStatus)
    }
    
    DT::datatable(nodes, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  # Job statistics plot
  output$jobStatsPlot <- renderPlot({
    jobs <- hpc_data()$jobs
    status_counts <- jobs %>% count(STATUS)
    
    ggplot(status_counts, aes(x = STATUS, y = n, fill = STATUS)) +
      geom_col() +
      geom_text(aes(label = n), vjust = -0.5) +
      labs(title = "Job Status Distribution",
           x = "Status", y = "Number of Jobs") +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  # Queue status plot
  output$queueStatusPlot <- renderPlot({
    jobs <- hpc_data()$jobs
    queue_counts <- jobs %>% count(PARTITION)
    
    ggplot(queue_counts, aes(x = PARTITION, y = n, fill = PARTITION)) +
      geom_col() +
      geom_text(aes(label = n), vjust = -0.5) +
      labs(title = "Jobs by Partition",
           x = "Partition", y = "Number of Jobs") +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  # Jobs table
  output$jobsTable <- DT::renderDataTable({
    jobs <- hpc_data()$jobs
    
    if (input$jobStatus != "All") {
      jobs <- jobs %>% filter(STATUS == input$jobStatus)
    }
    
    if (input$jobUser != "All") {
      jobs <- jobs %>% filter(USER == input$jobUser)
    }
    
    if (input$jobPartition != "All") {
      jobs <- jobs %>% filter(PARTITION == input$jobPartition)
    }
    
    DT::datatable(jobs, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  # Storage usage plot
  output$storageUsagePlot <- renderPlot({
    storage <- hpc_data()$storage
    
    ggplot(storage, aes(x = STORAGE_ID, y = USAGE_PERCENT, fill = STORAGE_TYPE)) +
      geom_col() +
      geom_text(aes(label = paste0(USAGE_PERCENT, "%")), vjust = -0.5) +
      labs(title = "Storage Usage by System",
           x = "Storage System", y = "Usage (%)") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # Storage table
  output$storageTable <- DT::renderDataTable({
    storage <- hpc_data()$storage
    DT::datatable(storage, options = list(pageLength = 10))
  })
  
  # Network throughput plot
  output$networkThroughputPlot <- renderPlot({
    network <- hpc_data()$network
    
    ggplot(network, aes(x = TIMESTAMP)) +
      geom_line(aes(y = INBOUND_GBPS, color = "Inbound")) +
      geom_line(aes(y = OUTBOUND_GBPS, color = "Outbound")) +
      scale_color_manual(values = c("Inbound" = "blue", "Outbound" = "red")) +
      labs(title = "Network Throughput",
           x = "Time", y = "Throughput (Gbps)", color = "Direction") +
      theme_minimal()
  })
  
  # Network latency plot
  output$networkLatencyPlot <- renderPlot({
    network <- hpc_data()$network
    
    ggplot(network, aes(x = TIMESTAMP, y = LATENCY_MS)) +
      geom_line(color = "orange") +
      labs(title = "Network Latency",
           x = "Time", y = "Latency (ms)") +
      theme_minimal()
  })
  
  # Network table
  output$networkTable <- DT::renderDataTable({
    network <- hpc_data()$network
    recent_network <- tail(network, 10)
    DT::datatable(recent_network, options = list(pageLength = 10))
  })
  
  # Terminal functionality
  output$terminalOutput <- renderText({
    history <- terminal_history()
    if (length(history) > 0) {
      paste(history, collapse = "\n")
    } else {
      "Welcome to HPC Terminal\nType 'help' for available commands"
    }
  })
  
  observeEvent(input$executeCommand, {
    command <- input$terminalCommand
    if (command != "") {
      # Add command to history
      current_history <- terminal_history()
      new_history <- c(current_history, paste("$", command))
      
      # Execute command (simulated)
      output_text <- execute_linux_command(command)
      new_history <- c(new_history, output_text)
      
      terminal_history(new_history)
      updateTextInput(session, "terminalCommand", value = "")
    }
  })
  
  observeEvent(input$clearTerminal, {
    terminal_history(character())
  })
  
  # Performance plots
  output$cpuPerformancePlot <- renderPlot({
    # Simulate CPU performance over time
    time_points <- Sys.time() - seq(0, 3600, by = 60)
    cpu_data <- data.frame(
      Time = time_points,
      CPU_Usage = runif(length(time_points), 20, 90)
    )
    
    ggplot(cpu_data, aes(x = Time, y = CPU_Usage)) +
      geom_line(color = "blue") +
      geom_hline(yintercept = 80, linetype = "dashed", color = "red") +
      labs(title = "CPU Performance Over Time",
           x = "Time", y = "CPU Usage (%)") +
      theme_minimal()
  })
  
  output$memoryPerformancePlot <- renderPlot({
    # Simulate memory performance over time
    time_points <- Sys.time() - seq(0, 3600, by = 60)
    memory_data <- data.frame(
      Time = time_points,
      Memory_Usage = runif(length(time_points), 30, 80)
    )
    
    ggplot(memory_data, aes(x = Time, y = Memory_Usage)) +
      geom_line(color = "green") +
      geom_hline(yintercept = 85, linetype = "dashed", color = "red") +
      labs(title = "Memory Performance Over Time",
           x = "Time", y = "Memory Usage (%)") +
      theme_minimal()
  })
  
  # Performance table
  output$performanceTable <- DT::renderDataTable({
    performance_data <- data.frame(
      Metric = c("CPU Usage", "Memory Usage", "Disk Usage", "Load Average", "Processes", "Connections"),
      Current = c(system_metrics()$cpu_usage, system_metrics()$memory_usage, 
                  system_metrics()$disk_usage, system_metrics()$load_average,
                  system_metrics()$processes, system_metrics()$connections),
      Average = c(65, 60, 55, 2.5, 250, 3000),
      Peak = c(95, 90, 85, 8.0, 500, 5000),
      Status = c("Normal", "Normal", "Warning", "Normal", "Normal", "Normal")
    )
    
    DT::datatable(performance_data, options = list(pageLength = 10))
  })
  
  # Logs table
  output$logsTable <- DT::renderDataTable({
    # Generate sample log entries
    log_entries <- data.frame(
      Timestamp = Sys.time() - sample(0:86400, 50, replace = TRUE),
      Level = sample(c("ERROR", "WARNING", "INFO", "DEBUG"), 50, replace = TRUE, prob = c(0.1, 0.2, 0.5, 0.2)),
      Source = sample(c("System", "Jobs", "Network", "Storage"), 50, replace = TRUE),
      Message = paste0("Log message ", 1:50)
    )
    
    if (input$logLevel != "All") {
      log_entries <- log_entries %>% filter(Level == input$logLevel)
    }
    
    if (input$logSource != "All") {
      log_entries <- log_entries %>% filter(Source == input$logSource)
    }
    
    DT::datatable(log_entries, options = list(pageLength = 10))
  })
}

# Run the app
shinyApp(ui, server)
