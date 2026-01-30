#' CDISC SDTM/ADaM Data Processing Utilities
#'
#' This file contains functions for processing CDISC SDTM and ADaM datasets
#' according to regulatory standards and best practices.
#'
#' @author Justin Zhang
#' @keywords CDISC SDTM ADaM clinical data

#' Validate CDISC SDTM Dataset Structure
#'
#' @param data A data frame containing SDTM data
#' @param domain Character string specifying the SDTM domain (e.g., "DM", "AE", "VS")
#' @param strict Logical indicating whether to perform strict validation
#'
#' @return A list containing validation results and any issues found
#' @export
#'
#' @examples
#' \dontrun{
#' dm_data <- read_sas("dm.sas7bdat")
#' validation <- validate_sdtm(dm_data, "DM")
#' }
validate_sdtm <- function(data, domain, strict = TRUE) {
  
  # Define required variables for each domain
  required_vars <- list(
    DM = c("STUDYID", "DOMAIN", "USUBJID", "SUBJID", "SITEID", "BRTHDTC", "AGE", "AGEU", "SEX"),
    AE = c("STUDYID", "DOMAIN", "USUBJID", "AESEQ", "AETERM", "AEBODSYS", "AESEV", "AEREL"),
    VS = c("STUDYID", "DOMAIN", "USUBJID", "VSSEQ", "VSTESTCD", "VSTEST", "VSORRES", "VSORRESU"),
    EX = c("STUDYID", "DOMAIN", "USUBJID", "EXSEQ", "EXTRT", "EXDOSE", "EXDOSU", "EXDOSFRM")
  )
  
  # Define variable formats and labels
  var_specs <- list(
    STUDYID = list(type = "character", length = 12, label = "Study Identifier"),
    USUBJID = list(type = "character", length = 40, label = "Unique Subject Identifier"),
    SUBJID = list(type = "character", length = 20, label = "Subject Identifier"),
    SITEID = list(type = "character", length = 12, label = "Study Site Identifier"),
    BRTHDTC = list(type = "character", format = "ISO8601", label = "Date/Time of Birth"),
    AGE = list(type = "numeric", range = c(0, 150), label = "Age"),
    AGEU = list(type = "character", values = c("YEARS", "MONTHS", "DAYS"), label = "Age Units"),
    SEX = list(type = "character", values = c("M", "F", "U", "UNDIFFERENTIATED"), label = "Sex")
  )
  
  validation_results <- list(
    domain = domain,
    total_records = nrow(data),
    validation_date = Sys.Date(),
    issues = list(),
    warnings = list(),
    passed = TRUE
  )
  
  # Check required variables
  if (domain %in% names(required_vars)) {
    missing_vars <- setdiff(required_vars[[domain]], names(data))
    if (length(missing_vars) > 0) {
      validation_results$issues <- append(validation_results$issues, 
                                         list(paste("Missing required variables:", paste(missing_vars, collapse = ", "))))
      validation_results$passed <- FALSE
    }
  }
  
  # Check variable formats
  for (var in names(data)) {
    if (var %in% names(var_specs)) {
      spec <- var_specs[[var]]
      
      # Check data type
      if (spec$type == "numeric" && !is.numeric(data[[var]])) {
        validation_results$issues <- append(validation_results$issues,
                                           list(paste("Variable", var, "should be numeric")))
        validation_results$passed <- FALSE
      }
      
      # Check allowed values
      if ("values" %in% names(spec)) {
        invalid_values <- setdiff(unique(data[[var]]), spec$values)
        invalid_values <- invalid_values[!is.na(invalid_values)]
        if (length(invalid_values) > 0) {
          validation_results$issues <- append(validation_results$issues,
                                             list(paste("Invalid values in", var, ":", paste(invalid_values, collapse = ", "))))
          validation_results$passed <- FALSE
        }
      }
      
      # Check numeric ranges
      if (spec$type == "numeric" && "range" %in% names(spec)) {
        out_of_range <- data[[var]] < spec$range[1] | data[[var]] > spec$range[2]
        if (any(out_of_range, na.rm = TRUE)) {
          validation_results$warnings <- append(validation_results$warnings,
                                              list(paste("Values out of range in", var)))
        }
      }
    }
  }
  
  # Check for duplicate records
  if ("USUBJID" %in% names(data)) {
    if (domain == "DM") {
      dup_usubjid <- data$USUBJID[duplicated(data$USUBJID)]
      if (length(dup_usubjid) > 0) {
        validation_results$issues <- append(validation_results$issues,
                                           list(paste("Duplicate USUBJID in DM domain:", paste(dup_usubjid, collapse = ", "))))
        validation_results$passed <- FALSE
      }
    }
  }
  
  # Check date formats
  date_vars <- names(data)[grepl("DTC$", names(data))]
  for (date_var in date_vars) {
    if (date_var %in% names(data)) {
      invalid_dates <- !grepl("^\\d{4}-\\d{2}-\\d{2}(T\\d{2}:\\d{2})?$", data[[date_var]]) & !is.na(data[[date_var]])
      if (any(invalid_dates)) {
        validation_results$warnings <- append(validation_results$warnings,
                                            list(paste("Invalid date format in", date_var)))
      }
    }
  }
  
  class(validation_results) <- "sdtm_validation"
  return(validation_results)
}

#' Print method for SDTM validation results
#' @param x An sdtm_validation object
#' @param ... Additional arguments passed to print method
#' @export
print.sdtm_validation <- function(x, ...) {
  cat("CDISC SDTM Validation Results\n")
  cat("=============================\n")
  cat("Domain:", x$domain, "\n")
  cat("Total Records:", x$total_records, "\n")
  cat("Validation Date:", x$validation_date, "\n")
  cat("Status:", ifelse(x$passed, "PASSED", "FAILED"), "\n\n")
  
  if (length(x$issues) > 0) {
    cat("Issues Found:\n")
    for (issue in x$issues) {
      cat("- ", issue, "\n")
    }
    cat("\n")
  }
  
  if (length(x$warnings) > 0) {
    cat("Warnings:\n")
    for (warning in x$warnings) {
      cat("- ", warning, "\n")
    }
  }
}

#' Convert SDTM to ADaM Dataset
#'
#' @param sdtm_data List containing SDTM datasets
#' @param target_adam Character string specifying target ADaM dataset
#' @param metadata List containing metadata and mapping rules
#'
#' @return A data frame containing the ADaM dataset
#' @export
#'
#' @examples
#' \dontrun{
#' sdtm_list <- list(DM = dm_data, VS = vs_data, AE = ae_data)
#' adsl <- sdtm_to_adam(sdtm_list, "ADSL")
#' }
sdtm_to_adam <- function(sdtm_data, target_adam, metadata = NULL) {
  
  if (target_adam == "ADSL") {
    # Create Subject-Level Analysis Dataset
    if (!"DM" %in% names(sdtm_data)) {
      stop("DM dataset required for ADSL creation")
    }
    
    dm <- sdtm_data$DM
    
    adsl <- dm %>%
      select(STUDYID, USUBJID, SUBJID, SITEID, BRTHDTC, AGE, AGEU, SEX, RACE, ETHNIC, COUNTRY) %>%
      mutate(
        # Add treatment variables
        TRTSDT = as.Date("2023-01-01"),  # Should come from EX or DS dataset
        TRTEDT = as.Date("2023-12-31"),  # Should come from EX or DS dataset
        TRTDURD = as.numeric(TRTEDT - TRTSDT),
        
        # Add derived variables
        AGEGR1 = case_when(
          AGE < 18 ~ "<18",
          AGE >= 18 & AGE < 40 ~ "18-39",
          AGE >= 40 & AGE < 65 ~ "40-64",
          AGE >= 65 ~ "65+",
          TRUE <- NA_character_
        ),
        
        RACEGR1 = case_when(
          RACE == "WHITE" ~ "WHITE",
          RACE == "BLACK" ~ "BLACK",
          RACE %in% c("ASIAN", "HISPANIC", "NATIVE HAWAIIAN", "AMERICAN INDIAN") ~ "OTHER",
          TRUE <- NA_character_
        ),
        
        # Add analysis flags
        SAF01FL = "Y",  # Safety population flag
        EFF01FL = "Y"   # Efficacy population flag
      )
    
    # Add treatment arm information from EX dataset if available
    if ("EX" %in% names(sdtm_data)) {
      ex <- sdtm_data$EX
      treatment_info <- ex %>%
        group_by(USUBJID) %>%
        summarise(
          ARMCD = first(EXTRT),
          ARM = first(EXTRT)  # Should be mapped to readable names
        ) %>%
        ungroup()
      
      adsl <- adsl %>%
        left_join(treatment_info, by = "USUBJID")
    }
    
    return(adsl)
    
  } else if (target_adam == "ADVS") {
    # Create Analysis Dataset for Vital Signs
    if (!all(c("DM", "VS") %in% names(sdtm_data))) {
      stop("DM and VS datasets required for ADVS creation")
    }
    
    dm <- sdtm_data$DM
    vs <- sdtm_data$VS
    
    advs <- vs %>%
      left_join(dm %>% select(USUBJID, AGE, SEX, ARMCD), by = "USUBJID") %>%
      mutate(
        # Add analysis variables
        PARAMCD = VSTESTCD,
        PARAM = VSTEST,
        AVAL = VSORRES,
        AVALC = as.character(round(AVAL, 2)),
        
        # Add visit information
        VISITNUM = case_when(
          VISIT == "SCREENING" ~ 1,
          VISIT == "BASELINE" ~ 2,
          VISIT == "WEEK 2" ~ 3,
          VISIT == "WEEK 4" ~ 4,
          VISIT == "WEEK 8" ~ 5,
          VISIT == "WEEK 12" ~ 6,
          TRUE <- NA_real_
        ),
        
        # Add analysis flags
        ANL01FL = "Y"  # Analysis flag
      ) %>%
      arrange(USUBJID, VISITNUM, PARAMCD)
    
    return(advs)
    
  } else if (target_adam == "ADAE") {
    # Create Analysis Dataset for Adverse Events
    if (!all(c("DM", "AE") %in% names(sdtm_data))) {
      stop("DM and AE datasets required for ADAE creation")
    }
    
    dm <- sdtm_data$DM
    ae <- sdtm_data$AE
    
    adae <- ae %>%
      left_join(dm %>% select(USUBJID, AGE, SEX, ARMCD), by = "USUBJID") %>%
      mutate(
        # Add analysis variables
        AERELN = case_when(
          AEREL == "RELATED" ~ 1,
          AEREL == "NOT RELATED" ~ 0,
          TRUE <- NA_integer_
        ),
        
        AESEVN = case_when(
          AESEV == "MILD" ~ 1,
          AESEV == "MODERATE" ~ 2,
          AESEV == "SEVERE" ~ 3,
          TRUE <- NA_integer_
        ),
        
        # Add analysis flags
        ANL01FL = "Y",  # Safety analysis flag
        SAFFL = "Y"      # Safety population flag
      ) %>%
      arrange(USUBJID, AESEQ)
    
    return(adae)
  } else {
    stop("Unsupported ADaM dataset: ", target_adam)
  }
}

#' Generate Define-XML Metadata
#'
#' @param data A data frame containing clinical data
#' @param dataset_name Character string specifying dataset name
#' @param study_metadata List containing study-level metadata
#'
#' @return A character string containing Define-XML structure
#' @export
generate_define_xml <- function(data, dataset_name, study_metadata = NULL) {
  
  # Define-XML template
  define_xml <- paste0(
    '<?xml version="1.0" encoding="UTF-8"?>\n',
    '<ODM xmlns="http://www.cdisc.org/ns/odm" xmlns:xmlns="http://www.w3.org/2001/XMLSchema-instance">\n',
    '  <Study OID="', study_metadata$study_oid, '">\n',
    '    <GlobalVariables>\n',
    '      <StudyName>', study_metadata$study_name, '</StudyName>\n',
    '      <StudyDescription>', study_metadata$study_description, '</StudyDescription>\n',
    '      <ProtocolName>', study_metadata$protocol_name, '</ProtocolName>\n',
    '    </GlobalVariables>\n',
    '    <MetaDataVersion OID="MDV.', dataset_name, '" Name="', dataset_name, '">\n'
  )
  
  # Add variable definitions
  for (i in seq_along(names(data))) {
    var_name <- names(data)[i]
    var_data <- data[[i]]
    
    define_xml <- paste0(define_xml,
      '      <ItemDef OID="IT.', var_name, '" Name="', var_name, '" DataType="', 
      class(var_data)[1], '">\n',
      '        <Description>\n',
      '          <TranslatedText>', var_name, '</TranslatedText>\n',
      '        </Description>\n',
      '      </ItemDef>\n'
    )
  }
  
  # Close Define-XML
  define_xml <- paste0(define_xml,
    '    </MetaDataVersion>\n',
    '  </Study>\n',
    '</ODM>'
  )
  
  return(define_xml)
}

#' Apply CDISC Controlled Terminology
#'
#' @param data A data frame containing clinical data
#' @param codelist_mapping Named list mapping variables to CDISC codelists
#'
#' @return A data frame with controlled terminology applied
#' @export
apply_controlled_terminology <- function(data, codelist_mapping) {
  
  # Define standard CDISC codelists
  standard_codelists <- list(
    SEX = c("M" = "Male", "F" = "Female", "U" = "Unknown"),
    AESEV = c("MILD" = "Mild", "MODERATE" = "Moderate", "SEVERE" = "Severe"),
    AEREL = c("RELATED" = "Related", "NOT RELATED" = "Not Related", "POSSIBLY RELATED" = "Possibly Related"),
    RACE = c("WHITE" = "White", "BLACK" = "Black or African American", "ASIAN" = "Asian", 
             "HISPANIC" = "Hispanic or Latino", "AMERICAN INDIAN" = "American Indian or Alaska Native",
             "NATIVE HAWAIIAN" = "Native Hawaiian or Other Pacific Islander")
  )
  
  # Apply codelists
  data_modified <- data
  
  for (var in names(codelist_mapping)) {
    if (var %in% names(data_modified)) {
      codelist <- codelist_mapping[[var]]
      if (is.character(codelist)) {
        # Use standard codelist
        if (var %in% names(standard_codelists)) {
          codelist <- standard_codelists[[var]]
        }
      }
      
      # Create decoded variable
      decoded_var <- paste0(var, "DEC")
      data_modified[[decoded_var]] <- data_modified[[var]]
      
      # Apply mapping
      for (code in names(codelist)) {
        data_modified[[decoded_var]][data_modified[[var]] == code] <- codelist[[code]]
      }
    }
  }
  
  return(data_modified)
}

#' Create Study Data Review Guide (SDRG) Template
#'
#' @param study_metadata List containing study metadata
#' @param datasets List containing dataset information
#'
#' @return A character string containing SDRG content
#' @export
create_sdrg_template <- function(study_metadata, datasets) {
  
  sdrg_content <- paste0(
    "# Study Data Review Guide\n\n",
    "## Study Information\n",
    "- Study Name: ", study_metadata$study_name, "\n",
    "- Protocol: ", study_metadata$protocol_name, "\n",
    "- Sponsor: ", study_metadata$sponsor, "\n",
    "- Study Phase: ", study_metadata$phase, "\n",
    "- Indication: ", study_metadata$indication, "\n\n",
    
    "## Dataset Overview\n\n"
  )
  
  # Add dataset information
  for (dataset_name in names(datasets)) {
    dataset_info <- datasets[[dataset_name]]
    
    sdrg_content <- paste0(sdrg_content,
      "### ", dataset_name, "\n",
      "- Description: ", dataset_info$description, "\n",
      "- Records: ", dataset_info$n_records, "\n",
      "- Variables: ", dataset_info$n_variables, "\n",
      "- Purpose: ", dataset_info$purpose, "\n\n"
    )
  }
  
  sdrg_content <- paste0(sdrg_content,
    "## Review Notes\n\n",
    "This document provides guidance for reviewing the clinical study data.\n",
    "Please refer to the Statistical Analysis Plan for detailed methodology.\n\n",
    
    "## Data Quality Checks\n",
    "- All datasets have been validated against CDISC standards\n",
    "- Missing data has been documented and coded appropriately\n",
    "- Outliers have been reviewed and documented\n",
    "- Consistency checks have been performed across datasets\n"
  )
  
  return(sdrg_content)
}
