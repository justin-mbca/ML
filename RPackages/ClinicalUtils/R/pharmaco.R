#' Pharmacometric Analysis Functions
#'
#' This file contains functions for pharmacokinetic/pharmacodynamic analysis,
#' population modeling, and clinical trial simulation.
#'
#' @author Justin Zhang
#' @keywords pharmacokinetic pharmacodynamic PK PD modeling

#' One-Compartment Pharmacokinetic Model
#'
#' @param time Numeric vector of time points
#' @param dose Numeric dose amount
#' @param ka Absorption rate constant
#' @param ke Elimination rate constant
#' @param vd Volume of distribution
#'
#' @return Numeric vector of concentrations
#' @export
pk_one_compartment <- function(time, dose, ka, ke, vd) {
  # One-compartment model with first-order absorption
  concentration <- (dose * ka) / (vd * (ka - ke)) * (exp(-ke * time) - exp(-ka * time))
  concentration[time < 0] <- 0
  return(concentration)
}

#' Two-Compartment Pharmacokinetic Model
#'
#' @param time Numeric vector of time points
#' @param dose Numeric dose amount
#' @param ka Absorption rate constant
#' @param ke Elimination rate constant
#' @param vd Volume of distribution (central)
#' @param v2 Volume of distribution (peripheral)
#' @param q12 Intercompartmental clearance
#'
#' @return Numeric vector of concentrations
#' @export
pk_two_compartment <- function(time, dose, ka, ke, vd, v2, q12) {
  # Two-compartment model with first-order absorption
  lambda1 <- (ke + q12/vd + q12/v2 + sqrt((ke + q12/vd + q12/v2)^2 - 4*ke*q12/v2)) / 2
  lambda2 <- (ke + q12/vd + q12/v2 - sqrt((ke + q12/vd + q12/v2)^2 - 4*ke*q12/v2)) / 2
  
  A <- dose * ka * (lambda1 - ke) / (vd * (lambda1 - lambda2) * (ka - lambda1))
  B <- dose * ka * (ke - lambda2) / (vd * (lambda1 - lambda2) * (ka - lambda2))
  
  concentration <- A * exp(-lambda1 * time) + B * exp(-lambda2 * time)
  concentration[time < 0] <- 0
  return(concentration)
}

#' Calculate Pharmacokinetic Parameters
#'
#' @param time Numeric vector of time points
#' @param concentration Numeric vector of concentrations
#' @param dose Numeric dose amount
#' @param method Character string specifying calculation method ("trapezoidal" or "linear")
#'
#' @return List containing PK parameters
#' @export
calculate_pk_parameters <- function(time, concentration, dose, method = "trapezoidal") {
  
  # Remove zero or negative concentrations
  valid_idx <- concentration > 0 & time >= 0
  time <- time[valid_idx]
  concentration <- concentration[valid_idx]
  
  if (length(time) < 2) {
    stop("Need at least 2 valid concentration-time points")
  }
  
  # Sort by time
  ord <- order(time)
  time <- time[ord]
  concentration <- concentration[ord]
  
  # Calculate Cmax and Tmax
  cmax <- max(concentration)
  tmax <- time[which.max(concentration)]
  
  # Calculate AUC using trapezoidal rule
  if (method == "trapezoidal") {
    auc <- sum((concentration[-1] + concentration[-length(concentration)]) / 2 * 
               diff(time))
  } else {
    auc <- sum(concentration[-1] * diff(time))
  }
  
  # Calculate elimination rate constant from terminal phase
  # Use last 3-4 points for terminal phase estimation
  n_terminal <- min(4, length(time))
  terminal_idx <- (length(time) - n_terminal + 1):length(time)
  
  if (length(terminal_idx) >= 2) {
    log_conc <- log(concentration[terminal_idx])
    terminal_time <- time[terminal_idx]
    
    # Linear regression on log-transformed concentrations
    lm_fit <- lm(log_conc ~ terminal_time)
    ke <- -coef(lm_fit)[2]
    half_life <- log(2) / ke
    
    # Calculate clearance and volume of distribution
    if (auc > 0) {
      clearance <- dose / auc
      vd <- clearance / ke
    } else {
      clearance <- NA
      vd <- NA
    }
  } else {
    ke <- NA
    half_life <- NA
    clearance <- NA
    vd <- NA
  }
  
  # Calculate additional parameters
  if (!is.na(cmax) && !is.na(auc)) {
    cav <- auc / max(time)
    if (!is.na(vd)) {
      c0 <- dose / vd
    } else {
      c0 <- NA
    }
  } else {
    cav <- NA
    c0 <- NA
  }
  
  return(list(
    cmax = cmax,
    tmax = tmax,
    auc = auc,
    ke = ke,
    half_life = half_life,
    clearance = clearance,
    vd = vd,
    cav = cav,
    c0 = c0
  ))
}

#' Emax Pharmacodynamic Model
#'
#' @param concentration Numeric vector of concentrations
#' @param emax Maximum effect
#' @param ec50 Concentration producing 50% of maximum effect
#' @param baseline Baseline effect (default = 0)
#' @param hill Hill coefficient (default = 1)
#'
#' @return Numeric vector of effects
#' @export
pd_emax_model <- function(concentration, emax, ec50, baseline = 0, hill = 1) {
  effect <- baseline + (emax * concentration^hill) / (ec50^hill + concentration^hill)
  return(effect)
}

#' Indirect Response Model
#'
#' @param time Numeric vector of time points
#' @param concentration Numeric vector of concentrations
#' @param kin Zero-order production rate
#' @param kout First-order loss rate
#' @param emax Maximum inhibition/stimulation
#' @param ec50 Concentration for 50% effect
#' @param inhibition Logical, TRUE for inhibition model, FALSE for stimulation
#'
#' @return Numeric vector of effects
#' @export
pd_indirect_response <- function(time, concentration, kin, kout, emax, ec50, inhibition = TRUE) {
  
  effect <- numeric(length(time))
  baseline <- kin / kout
  
  for (i in seq_along(time)) {
    if (i == 1) {
      effect[i] <- baseline
    } else {
      dt <- time[i] - time[i-1]
      conc <- concentration[i]
      
      if (inhibition) {
        # Inhibition model
        mod_factor <- 1 - (emax * conc) / (ec50 + conc)
      } else {
        # Stimulation model
        mod_factor <- 1 + (emax * conc) / (ec50 + conc)
      }
      
      # Simple Euler integration
      effect[i] <- effect[i-1] + dt * (kin * mod_factor - kout * effect[i-1])
    }
  }
  
  return(effect)
}

#' Population PK Parameter Estimation
#'
#' @param data Data frame with concentration-time data
#' @param subject_col Character string specifying subject ID column
#' @param time_col Character string specifying time column
#' @param conc_col Character string specifying concentration column
#' @param dose_col Character string specifying dose column
#'
#' @return List containing population PK parameters
#' @export
population_pk_analysis <- function(data, subject_col = "USUBJID", 
                                  time_col = "TIME", conc_col = "CONC", 
                                  dose_col = "DOSE") {
  
  subjects <- unique(data[[subject_col]])
  n_subjects <- length(subjects)
  
  # Calculate individual PK parameters
  individual_params <- data.frame()
  
  for (subject in subjects) {
    subj_data <- data[data[[subject_col]] == subject, ]
    time <- subj_data[[time_col]]
    concentration <- subj_data[[conc_col]]
    dose <- unique(subj_data[[dose_col]])
    
    if (length(dose) > 1) {
      dose <- dose[1]  # Use first dose if multiple
    }
    
    tryCatch({
      params <- calculate_pk_parameters(time, concentration, dose)
      
      individual_params <- rbind(individual_params, data.frame(
        USUBJID = subject,
        DOSE = dose,
        Cmax = params$cmax,
        Tmax = params$tmax,
        AUC = params$auc,
        Half_life = params$half_life,
        CL = params$clearance,
        Vd = params$vd
      ))
    }, error = function(e) {
      warning("Could not calculate parameters for subject ", subject)
    })
  }
  
  if (nrow(individual_params) == 0) {
    stop("No individual parameters could be calculated")
  }
  
  # Calculate population statistics
  pop_stats <- list(
    n_subjects = nrow(individual_params),
    
    # Geometric means and CVs for log-normal parameters
    clearance = list(
      geometric_mean = exp(mean(log(individual_params$CL), na.rm = TRUE)),
      geometric_cv = sqrt(var(log(individual_params$CL), na.rm = TRUE)),
      median = median(individual_params$CL, na.rm = TRUE),
      range = range(individual_params$CL, na.rm = TRUE)
    ),
    
    volume = list(
      geometric_mean = exp(mean(log(individual_params$Vd), na.rm = TRUE)),
      geometric_cv = sqrt(var(log(individual_params$Vd), na.rm = TRUE)),
      median = median(individual_params$Vd, na.rm = TRUE),
      range = range(individual_params$Vd, na.rm = TRUE)
    ),
    
    half_life = list(
      geometric_mean = exp(mean(log(individual_params$Half_life), na.rm = TRUE)),
      geometric_cv = sqrt(var(log(individual_params$Half_life), na.rm = TRUE)),
      median = median(individual_params$Half_life, na.rm = TRUE),
      range = range(individual_params$Half_life, na.rm = TRUE)
    )
  )
  
  return(list(
    individual_parameters = individual_params,
    population_statistics = pop_stats
  ))
}

#' Dose Optimization Simulation
#'
#' @param base_params List containing base PK parameters
#' @param target_exposure Target exposure metric (AUC or Cmax)
#' @param target_value Target value for exposure metric
#' @param dose_range Numeric vector of doses to test
#' @param n_simulations Number of Monte Carlo simulations
#'
#' @return Data frame with simulation results
#' @export
dose_optimization <- function(base_params, target_exposure = "AUC", target_value, 
                             dose_range = seq(25, 500, 25), n_simulations = 1000) {
  
  simulation_results <- data.frame()
  
  for (dose in dose_range) {
    # Simulate multiple subjects with parameter variability
    cl_sim <- rlnorm(n_simulations, log(base_params$clearance), 0.3)
    vd_sim <- rlnorm(n_simulations, log(base_params$volume), 0.2)
    
    # Calculate exposure for each simulation
    if (target_exposure == "AUC") {
      auc_sim <- dose / cl_sim
      exposure_metric <- auc_sim
    } else if (target_exposure == "Cmax") {
      # Simplified Cmax calculation
      ke_sim <- cl_sim / vd_sim
      ka_sim <- rlnorm(n_simulations, log(0.8), 0.3)
      tmax_sim <- log(ka_sim / ke_sim) / (ka_sim - ke_sim)
      cmax_sim <- (dose * ka_sim) / (vd_sim * (ka_sim - ke_sim)) * 
                  (exp(-ke_sim * tmax_sim) - exp(-ka_sim * tmax_sim))
      exposure_metric <- cmax_sim
    }
    
    # Calculate probability of achieving target
    prob_target <- mean(exposure_metric >= target_value, na.rm = TRUE)
    
    # Calculate summary statistics
    summary_stats <- list(
      dose = dose,
      n_simulations = n_simulations,
      mean_exposure = mean(exposure_metric, na.rm = TRUE),
      median_exposure = median(exposure_metric, na.rm = TRUE),
      cv_exposure = sd(exposure_metric, na.rm = TRUE) / mean(exposure_metric, na.rm = TRUE),
      prob_achieving_target = prob_target,
      p25_exposure = quantile(exposure_metric, 0.25, na.rm = TRUE),
      p75_exposure = quantile(exposure_metric, 0.75, na.rm = TRUE)
    )
    
    simulation_results <- rbind(simulation_results, 
                               as.data.frame(summary_stats))
  }
  
  return(simulation_results)
}

#' Visual Predictive Check
#'
#' @param observed_data Data frame with observed data
#' @param simulated_data Data frame with simulated data
#' @param time_col Character string specifying time column
#' @param conc_col Character string specifying concentration column
#' @param subject_col Character string specifying subject column
#'
#' @return ggplot object for VPC
#' @export
vpc_plot <- function(observed_data, simulated_data, time_col = "TIME", 
                    conc_col = "CONC", subject_col = "USUBJID") {
  
  # Calculate observed percentiles
  observed_stats <- observed_data %>%
    group_by(!!sym(time_col)) %>%
    summarise(
      obs_median = median(!!sym(conc_col), na.rm = TRUE),
      obs_p5 = quantile(!!sym(conc_col), 0.05, na.rm = TRUE),
      obs_p95 = quantile(!!sym(conc_col), 0.95, na.rm = TRUE),
      n_obs = n()
    ) %>%
    ungroup()
  
  # Calculate simulated percentiles
  simulated_stats <- simulated_data %>%
    group_by(!!sym(time_col)) %>%
    summarise(
      sim_median = median(!!sym(conc_col), na.rm = TRUE),
      sim_p5 = quantile(!!sym(conc_col), 0.05, na.rm = TRUE),
      sim_p95 = quantile(!!sym(conc_col), 0.95, na.rm = TRUE),
      n_sim = n()
    ) %>%
    ungroup()
  
  # Combine for plotting
  plot_data <- observed_stats %>%
    left_join(simulated_stats, by = time_col) %>%
    pivot_longer(cols = c(obs_median, obs_p5, obs_p95, sim_median, sim_p5, sim_p95),
                 names_to = c("source", "percentile"), 
                 names_pattern = "(.+)_(.+)",
                 values_to = "concentration")
  
  # Create VPC plot
  vpc <- ggplot(plot_data, aes(x = !!sym(time_col), y = concentration, 
                               color = source, linetype = percentile)) +
    geom_line(size = 1.2) +
    geom_ribbon(data = filter(plot_data, source == "sim", percentile %in% c("p5", "p95")),
                aes(ymin = ifelse(percentile == "p5", concentration, NA),
                    ymax = ifelse(percentile == "p95", concentration, NA)),
                fill = "lightblue", alpha = 0.3) +
    scale_color_manual(values = c("obs" = "black", "sim" = "blue")) +
    scale_linetype_manual(values = c("median" = "solid", "p5" = "dashed", "p95" = "dashed")) +
    labs(title = "Visual Predictive Check",
         x = "Time", y = "Concentration",
         color = "Source", linetype = "Percentile") +
    theme_minimal() +
    theme(legend.position = "bottom")
  
  return(vpc)
}

#' Generate Pharmacometric Report
#'
#' @param pk_data Data frame with PK data
#' @param pd_data Data frame with PD data (optional)
#' @param pop_params List with population parameters
#' @param output_format Character string specifying output format
#'
#' @return Path to generated report file
#' @export
generate_pharmaco_report <- function(pk_data, pd_data = NULL, pop_params = NULL, 
                                   output_format = "html") {
  
  # Create temporary Rmd file
  rmd_content <- '
---
title: "Pharmacometric Analysis Report"
date: "`r Sys.Date()`"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = FALSE, warning = FALSE, message = FALSE)
library(ggplot2)
library(DT)
library(knitr)
```

## Executive Summary

This report presents the pharmacokinetic and pharmacodynamic analysis results for the clinical study.

## Study Overview

```{r study-overview}
cat("Study ID: STUDY001")
cat("Number of Subjects:", length(unique(pk_data$USUBJID)))
cat("Total PK Samples:", nrow(pk_data))
```

## Pharmacokinetic Results

### Individual PK Parameters

```{r pk-params-table}
if (!is.null(pop_params$individual_parameters)) {
  DT::datatable(pop_params$individual_parameters, 
                options = list(pageLength = 10, scrollX = TRUE))
}
```

### Population Statistics

```{r pop-stats}
if (!is.null(pop_params$population_statistics)) {
  cat("Clearance (L/h):")
  cat("  Geometric Mean:", round(pop_params$population_statistics$clearance$geometric_mean, 2))
  cat("  Geometric CV:", round(pop_params$population_statistics$clearance$geometric_cv * 100, 1), "%")
  
  cat("Volume of Distribution (L):")
  cat("  Geometric Mean:", round(pop_params$population_statistics$volume$geometric_mean, 2))
  cat("  Geometric CV:", round(pop_params$population_statistics$volume$geometric_cv * 100, 1), "%")
}
```

## Concentration-Time Profiles

```{r pk-profiles}
ggplot(pk_data, aes(x = TIME, y = CONC, group = USUBJID)) +
  geom_line(alpha = 0.3) +
  stat_summary(fun = mean, geom = "line", size = 1.5, color = "red") +
  scale_y_log10() +
  labs(title = "Concentration-Time Profiles",
       x = "Time (hours)", y = "Concentration (ng/mL)") +
  theme_minimal()
```

## Conclusions

The pharmacokinetic analysis shows [conclusions based on results].
'
  
  # Write Rmd file
  rmd_file <- tempfile(fileext = ".Rmd")
  writeLines(rmd_content, rmd_file)
  
  # Render report
  output_file <- tempfile(fileext = paste0(".", output_format))
  rmarkdown::render(rmd_file, output_file = output_file, quiet = TRUE)
  
  # Clean up
  file.remove(rmd_file)
  
  return(output_file)
}
