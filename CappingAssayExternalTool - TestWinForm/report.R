#### Packages ####
library(dplyr)
library(purrr)
library(stringr)
library(tidyr)
library(openxlsx)

#####################################
#### Command line processing for Argument Collector ####

options (echo = FALSE)
debug <- FALSE

# set up for command line processing (if needed)
# arguments are specified positionally (since there are no optional arguments) and ...
arguments <- commandArgs(trailingOnly=TRUE)
if (length (arguments) != 9){
  # expected arguments not present -- error
  stop ("USAGE: R --slave --no-save --args '<checkbox><textbox><combobox>'")
}
for (i in 1:9) {
  arg <- arguments [i]
  # remove leading and trailing blanks
  arg <- gsub("^ *", "", arg)
  arg <- gsub(" *$", "", arg)
  # remove any embedded quotation marks
  arg <- gsub("['\'\"]", "", arg)
  args <- list()
  #report file is brought in as an argument, this is specified in 02_validation.properties
  if (i==1) reportfile <- arg
  if (i==8) text_box_path_sample_info <- gsub("\\\\", "/", toString(arg))
  if (i==9) text_box_path_results_temp <- gsub("\\\\", "/", toString(arg))
}

#All data processing done below
{
  cat("\rFile path: ", reportfile,"\r")
  
  cat("\rFile path: ", text_box_path_sample_info,"\r")
  
  cat("\rFile path: ", text_box_path_results_temp,"\r")
}
#####################################

#### Functions ####

##### QC fun #####
# Old fun without helper-fun adjust_nrow()
qc <- function(data, analyte){
  
  parse_inj <- function(strings){
    
    extract_tail <- function(string){
      stringr::str_extract(string, "([^_]+)$")
    }
    
    strings %>% sapply(extract_tail) %>% unlist()
    
  }
  
  measurement <- function(data, which = c('first', 'last', 'all'),
                          analyte = c('b-S-ARCA', 'Dinucleotide', 'ATP pos', 'GTP pos')) {
    
    if(!which %in% c('first', 'last', 'all')) {
      stop('Please choose `first` or `last` measurement.')
    }
    if(!analyte %in% c('b-S-ARCA', 'Dinucleotide', 'ATP pos', 'GTP pos')) {
      stop('Please choose a valid analyte name.')
    }
    
    switch(which,
           'first' = 
             data %>% 
             filter(Molecule == analyte) %>% 
             top_n(-3, wt = Injection),
           'last' = 
             data %>% 
             filter(Molecule == analyte) %>% 
             top_n(3, wt = Injection),
           'all' = 
             data %>% 
             filter(Molecule == analyte),
           stop('Please choose `first`, `last` or `all` measurement.')
    )
  }
  
  qc_0_2 <- data %>% 
    dplyr::filter(stringr::str_detect(Replicate, "QC"),
                  stringr::str_detect(Replicate, "QC 0.2 µM")) %>% 
    dplyr::mutate(Injection = parse_inj(Replicate),
                  CalculatedConcentration = ifelse(ExcludeFromCalibration == TRUE, NA, CalculatedConcentration))
  
  qc_2_0 <- data %>% 
    dplyr::filter(stringr::str_detect(Replicate, "QC"),
                  stringr::str_detect(Replicate, "QC 2 µM")) %>% 
    dplyr::mutate(Injection = parse_inj(Replicate),
                  CalculatedConcentration = ifelse(ExcludeFromCalibration == TRUE, NA, CalculatedConcentration))
  
  qc_4_0 <- data %>% 
    dplyr::filter(stringr::str_detect(Replicate, "QC"),
                  stringr::str_detect(Replicate, "QC 4 µM")) %>% 
    dplyr::mutate(Injection = parse_inj(Replicate),
                  CalculatedConcentration = ifelse(ExcludeFromCalibration == TRUE, NA, CalculatedConcentration))
  
  suppressWarnings(
    first <- list(qc_0_2, qc_2_0, qc_4_0) %>% 
      purrr::map(~ measurement(., "first", analyte)) %>% 
      purrr::reduce(merge, all = TRUE, sort = FALSE) %>% 
      dplyr::select(SampleName, CalculatedConcentration) %>% 
      tidyr::pivot_wider(names_from = "SampleName",
                         values_from = "CalculatedConcentration") %>% 
      tidyr::unnest(cols = c(`QC 0.2 µM`, `QC 2 µM`, `QC 4 µM`))
  )
  
  suppressWarnings(
    last <- list(qc_0_2, qc_2_0, qc_4_0) %>% 
      purrr::map(~ measurement(., "last", analyte)) %>% 
      purrr::reduce(merge, all = TRUE, sort = FALSE) %>% 
      dplyr::select(SampleName, CalculatedConcentration) %>% 
      tidyr::pivot_wider(names_from = "SampleName",
                         values_from = "CalculatedConcentration") %>% 
      tidyr::unnest(cols = c(`QC 0.2 µM`, `QC 2 µM`, `QC 4 µM`))
  )
  
  suppressWarnings(
    all <- list(qc_0_2, qc_2_0, qc_4_0) %>% 
      purrr::map(~ measurement(., "all", analyte)) %>% 
      purrr::reduce(merge, all = TRUE, sort = FALSE) %>% 
      dplyr::select(SampleName, CalculatedConcentration) %>% 
      tidyr::pivot_wider(names_from = "SampleName",
                         values_from = "CalculatedConcentration") %>% 
      tidyr::unnest(cols = c(`QC 0.2 µM`, `QC 2 µM`, `QC 4 µM`))
  )
  
  qc_list <- list(first, last, all)
  names(qc_list) <- c("first", "last", "all")
  qc_list
}

# New fun with adjusted length of dataframes(in case one QC level differs)
qc <- function(data, analyte){
  
  parse_inj <- function(strings){
    
    extract_tail <- function(string){
      stringr::str_extract(string, "([^_]+)$")
    }
    
    strings %>% sapply(extract_tail) %>% unlist()
    
  }
  
  measurement <- function(data, which = c('first', 'last', 'all'),
                          analyte = c('b-S-ARCA', 'Dinucleotide', 'ATP pos', 'GTP pos')) {
    
    if(!which %in% c('first', 'last', 'all')) {
      stop('Please choose `first` or `last` measurement.')
    }
    if(!analyte %in% c('b-S-ARCA', 'Dinucleotide', 'ATP pos', 'GTP pos')) {
      stop('Please choose a valid analyte name.')
    }
    
    switch(which,
           'first' = 
             data %>% 
             filter(Molecule == analyte) %>% 
             top_n(-3, wt = Injection),
           'last' = 
             data %>% 
             filter(Molecule == analyte) %>% 
             top_n(3, wt = Injection),
           'all' = 
             data %>% 
             filter(Molecule == analyte),
           stop('Please choose `first`, `last` or `all` measurement.')
    )
  }
  
  adjust_nrow <- function(data, max_nrow){
    
    if(max_nrow != nrow(data)){
      
      data[(nrow(data) + 1):(nrow(data) + (max_nrow - nrow(data))), ] = data$SampleName %>% unique
      
    }
    
    data
  }
  
  qc_0_2 <- data %>% 
    dplyr::filter(stringr::str_detect(Replicate, "QC"),
                  stringr::str_detect(Replicate, "QC 0.2 µM")) %>% 
    dplyr::mutate(Injection = parse_inj(Replicate),
                  CalculatedConcentration = ifelse(ExcludeFromCalibration == TRUE, NA, CalculatedConcentration))
  
  qc_2_0 <- data %>% 
    dplyr::filter(stringr::str_detect(Replicate, "QC"),
                  stringr::str_detect(Replicate, "QC 2 µM")) %>% 
    dplyr::mutate(Injection = parse_inj(Replicate),
                  CalculatedConcentration = ifelse(ExcludeFromCalibration == TRUE, NA, CalculatedConcentration))
  
  qc_4_0 <- data %>% 
    dplyr::filter(stringr::str_detect(Replicate, "QC"),
                  stringr::str_detect(Replicate, "QC 4 µM")) %>% 
    dplyr::mutate(Injection = parse_inj(Replicate),
                  CalculatedConcentration = ifelse(ExcludeFromCalibration == TRUE, NA, CalculatedConcentration))
  
  
  max_nrow <- list(qc_0_2, qc_2_0, qc_4_0) %>% 
    purrr::map(~ measurement(., "all", analyte) %>% nrow) %>% 
    unlist() %>% 
    max()
  
  suppressWarnings(
    first <- list(qc_0_2, qc_2_0, qc_4_0) %>% 
      purrr::map(~ measurement(., "first", analyte)) %>% 
      purrr::reduce(merge, all = TRUE, sort = FALSE) %>% 
      dplyr::select(SampleName, CalculatedConcentration) %>% 
      tidyr::pivot_wider(names_from = "SampleName",
                         values_from = "CalculatedConcentration") %>% 
      tidyr::unnest(cols = c(`QC 0.2 µM`, `QC 2 µM`, `QC 4 µM`))
  )
  
  suppressWarnings(
    last <- list(qc_0_2, qc_2_0, qc_4_0) %>% 
      purrr::map(~ measurement(., "last", analyte)) %>% 
      purrr::reduce(merge, all = TRUE, sort = FALSE) %>% 
      dplyr::select(SampleName, CalculatedConcentration) %>% 
      tidyr::pivot_wider(names_from = "SampleName",
                         values_from = "CalculatedConcentration") %>% 
      tidyr::unnest(cols = c(`QC 0.2 µM`, `QC 2 µM`, `QC 4 µM`))
  )
  
  suppressWarnings(
    all <- list(qc_0_2, qc_2_0, qc_4_0) %>% 
      purrr::map(~ measurement(., "all", analyte)) %>% 
      purrr::map(~ adjust_nrow(., max_nrow)) %>% 
      purrr::reduce(merge, all = TRUE, sort = FALSE) %>% 
      dplyr::select(SampleName, CalculatedConcentration) %>% 
      dplyr::mutate(CalculatedConcentration = as.numeric(CalculatedConcentration)) %>% 
      tidyr::pivot_wider(names_from = "SampleName",
                         values_from = "CalculatedConcentration") %>% 
      tidyr::unnest(cols = c(`QC 0.2 µM`, `QC 2 µM`, `QC 4 µM`))
  )
  
  qc_list <- list(first, last, all)
  names(qc_list) <- c("first", "last", "all")
  qc_list
}

write_data_qc <- function(data, analyte, col_info, col_data){
  
  average_formula <- function(col_data, start_row, data_rows){
    
    col_index <- c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", 
                   "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")
    
    #QC 0.2
    openxlsx::writeFormula(wb, "QCs", x = paste0('=AVERAGE(',
                                                 col_index[col_data],
                                                 start_row - nrow(data_rows),
                                                 ':',
                                                 col_index[col_data],
                                                 start_row - 1, 
                                                 ')'), 
                           startRow = start_row, startCol = col_data)
    #QC 2.0
    openxlsx::writeFormula(wb, "QCs", x = paste0('=AVERAGE('
                                                 ,col_index[col_data+1], 
                                                 start_row - nrow(data_rows),
                                                 ':',
                                                 col_index[col_data+1], 
                                                 start_row - 1,
                                                 ')'), 
                           startRow = start_row, startCol = col_data+1)
    #QC 4.0
    openxlsx::writeFormula(wb, "QCs", x = paste0('=AVERAGE('
                                                 ,col_index[col_data+2], 
                                                 start_row - nrow(data_rows),
                                                 ':',
                                                 col_index[col_data+2], 
                                                 start_row - 1,
                                                 ')'), 
                           startRow = start_row, startCol = col_data+2)
  }
  
  stability_formula <- function(col_data, start_row, start_row_avg_first, start_row_avg_last){
    
    col_index <- c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", 
                   "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")
    
    #QC 0.2
    openxlsx::writeFormula(wb, "QCs", x = paste0('=(',
                                                 col_index[col_data],
                                                 start_row_avg_last,
                                                 '*100/',
                                                 col_index[col_data],
                                                 start_row_avg_first, 
                                                 ')-100'), 
                           startRow = start_row, startCol = col_data)
    #QC 2.0
    openxlsx::writeFormula(wb, "QCs", x = paste0('=(',
                                                 col_index[col_data+1],
                                                 start_row_avg_last,
                                                 '*100/',
                                                 col_index[col_data+1],
                                                 start_row_avg_first, 
                                                 ')-100'), 
                           startRow = start_row, startCol = col_data+1)
    #QC 4.0
    openxlsx::writeFormula(wb, "QCs", x = paste0('=(',
                                                 col_index[col_data+2],
                                                 start_row_avg_last,
                                                 '*100/',
                                                 col_index[col_data+2],
                                                 start_row_avg_first, 
                                                 ')-100'), 
                           startRow = start_row, startCol = col_data+2)
  }
  
  sd_formula <- function(col_data, start_row, data_rows){
    
    col_index <- c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", 
                   "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")
    
    #QC 0.2
    openxlsx::writeFormula(wb, "QCs", x = paste0('=STDEV(',
                                                 col_index[col_data],
                                                 start_row - nrow(data_rows)-1,
                                                 ':',
                                                 col_index[col_data],
                                                 start_row - 2, 
                                                 ')'), 
                           startRow = start_row, startCol = col_data)
    #QC 2.0
    openxlsx::writeFormula(wb, "QCs", x = paste0('=STDEV('
                                                 ,col_index[col_data+1], 
                                                 start_row - nrow(data_rows)-1,
                                                 ':',
                                                 col_index[col_data+1], 
                                                 start_row - 2,
                                                 ')'), 
                           startRow = start_row, startCol = col_data+1)
    #QC 4.0
    openxlsx::writeFormula(wb, "QCs", x = paste0('=STDEV('
                                                 ,col_index[col_data+2], 
                                                 start_row - nrow(data_rows)-1,
                                                 ':',
                                                 col_index[col_data+2], 
                                                 start_row - 2,
                                                 ')'), 
                           startRow = start_row, startCol = col_data+2)
  }
  
  rsd_formula <- function(col_data, start_row, start_row_avg, start_row_sd){
    
    col_index <- c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", 
                   "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")
    
    #QC 0.2
    openxlsx::writeFormula(wb, "QCs", x = paste0('=(',
                                                 col_index[col_data],
                                                 start_row_sd,
                                                 '/',
                                                 col_index[col_data],
                                                 start_row_avg, 
                                                 ')*100'), 
                           startRow = start_row, startCol = col_data)
    #QC 2.0
    openxlsx::writeFormula(wb, "QCs", x = paste0('=(',
                                                 col_index[col_data+1],
                                                 start_row_sd,
                                                 '/',
                                                 col_index[col_data+1],
                                                 start_row_avg, 
                                                 ')*100'), 
                           startRow = start_row, startCol = col_data+1)
    #QC 4.0
    openxlsx::writeFormula(wb, "QCs", x = paste0('=(',
                                                 col_index[col_data+2],
                                                 start_row_sd,
                                                 '/',
                                                 col_index[col_data+2],
                                                 start_row_avg, 
                                                 ')*100'), 
                           startRow = start_row, startCol = col_data+2)
  }
  
  openxlsx::writeData(wb, "QCs", analyte, startRow = 2, startCol = col_info)
  openxlsx::writeData(wb, "QCs", "measurement before samples", startRow = 4, startCol = col_info)
  openxlsx::writeData(wb, "QCs", "last measurement", startRow = 10, startCol =  col_info)
  openxlsx::writeData(wb, "QCs", "Stability [%]", startRow = 18, startCol =  col_info)
  openxlsx::writeData(wb, "QCs", "Quality control samples", startRow = 21, col_info)
  openxlsx::writeData(wb, "QCs", "Mean", startRow = 24+nrow(qc_data[[analyte]]$all), col_info)
  openxlsx::writeData(wb, "QCs", "SD", startRow = 25+nrow(qc_data[[analyte]]$all), col_info)
  openxlsx::writeData(wb, "QCs", "RSD", startRow = 26+nrow(qc_data[[analyte]]$all), col_info)
  
  if(length(data[[analyte]]$first) > 0){
    openxlsx::writeData(wb, "QCs", data[[analyte]]$first, startRow = 4, startCol = col_data)
    average_formula(col_data, start_row = 8, data[[analyte]]$first)
    openxlsx::writeData(wb, "QCs", data[[analyte]]$last, startRow = 10, startCol = col_data)
    average_formula(col_data, start_row = 14, data[[analyte]]$last)
    stability_formula(col_data, start_row = 18, 8, 14)
    openxlsx::writeData(wb, "QCs", data[[analyte]]$all, startRow = 23, startCol = col_data)
    average_formula(col_data, start_row = 24+nrow(qc_data[[analyte]]$all), data[[analyte]]$all)
    sd_formula(col_data, start_row = 25+nrow(qc_data[[analyte]]$all), data[[analyte]]$all)
    rsd_formula(col_data, 
                start_row = 26+nrow(qc_data[[analyte]]$all),
                start_row_avg = 24+nrow(qc_data[[analyte]]$all), 
                start_row_sd = 25+nrow(qc_data[[analyte]]$all))
  }
  
}

longest_df <- function(qcdata){  

  position_of_longest <- names(qcdata) %>% 
    purrr::map(~ nrow(qcdata[[.]]$all)) %>% 
    which.max()
  
  qcdata[[position_of_longest]]$all
}

##### LOQ fun #####
loq <- function(data){
  
  filter_loqs <- function(loq_data, analyte){
    
    loqs <- data %>% 
      filter(Molecule == analyte,
             SampleType == "Standard",
             ExcludeFromCalibration != TRUE) %>% 
      group_by(Molecule) %>% 
      summarise(LLOQ = min(AnalyteConcentration),
                ULOQ = max(AnalyteConcentration)) %>% 
      mutate(Molecule = "concentration nominal value (ng/ml)") %>% 
      rename(!!as.character(analyte) := Molecule)
    
    lloq <- filter(loq_data, Molecule == analyte,
                   AnalyteConcentration == LLOQ) %>% 
      ungroup() %>% 
      select(LLOQ = CalculatedConcentration)
    
    uloq <- filter(loq_data, Molecule == analyte,
                   AnalyteConcentration == ULOQ) %>% 
      ungroup() %>% 
      select(ULOQ = CalculatedConcentration)
    
    list(loqs = loqs, lloq = lloq, uloq = uloq)
  }
  
  loqs <- data %>% 
    filter(SampleType == "Standard",
           ExcludeFromCalibration != TRUE) %>% 
    group_by(Molecule) %>% 
    summarise(LLOQ = min(AnalyteConcentration),
              ULOQ = max(AnalyteConcentration))
  
  loq_data <- data %>% 
    filter(SampleType == "Standard",
           ExcludeFromCalibration != TRUE) %>% 
    left_join(loqs, by = c("Molecule")) %>% 
    group_by(Molecule) %>% 
    filter(AnalyteConcentration %in% c(LLOQ, ULOQ))
  
  analytes <- data$Molecule %>% unique()
  
  loq_list <- analytes %>% 
    purrr::map(~ filter_loqs(loq_data, .))
  
  names(loq_list) <- analytes
  
  return(loq_list)
  
}

write_data_loq <- function(data, analyte, start_row, col_info, col_data){
  
  average_formula <- function(col_data, start_row){
    
    col_index <- c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", 
                   "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")
    
    #LLOQ
    openxlsx::writeFormula(wb, "QCs", x = paste0('=AVERAGE(',
                                                 col_index[col_data - 1],
                                                 start_row + 4,
                                                 ':',
                                                 col_index[col_data - 1],
                                                 start_row + 9, 
                                                 ')'), 
                           startRow = start_row + 10, startCol = col_data - 1)
    #ULOQ
    openxlsx::writeFormula(wb, "QCs", x = paste0('=AVERAGE('
                                                 ,col_index[col_data], 
                                                 start_row + 4,
                                                 ':',
                                                 col_index[col_data], 
                                                 start_row + 9,
                                                 ')'), 
                           startRow = start_row + 10, startCol = col_data)
  }
  
  re_formula <- function(col_data, start_row, data_rows){
    
    col_index <- c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", 
                   "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")
    
    #LLOQ
    openxlsx::writeFormula(wb, "QCs", x = paste0("=(",
                                                 col_index[col_data - 1],
                                                 start_row + 10,
                                                 "-",
                                                 col_index[col_data - 1],
                                                 start_row + 3, 
                                                 ")/",
                                                 col_index[col_data - 1],
                                                 start_row + 3, 
                                                 "*100"), 
                           startRow = start_row + 11, startCol = col_data - 1)
    #ULOQ
    openxlsx::writeFormula(wb, "QCs", x = paste0("=(",
                                                 col_index[col_data],
                                                 start_row + 10,
                                                 "-",
                                                 col_index[col_data],
                                                 start_row + 3, 
                                                 ")/",
                                                 col_index[col_data],
                                                 start_row + 3, 
                                                 "*100"), 
                           startRow = start_row + 11, startCol = col_data)
  }
  
  openxlsx::writeData(wb, "QCs", "sample concentration (ng/ml)", startRow = start_row + 5, startCol =  col_info)
  openxlsx::writeData(wb, "QCs", "Mean", startRow = start_row + 10, startCol =  col_info)
  openxlsx::writeData(wb, "QCs", "% RE", startRow = start_row + 11, col_info)
  
  
  if(length(data[[analyte]]$lloq) > 0){
    
    openxlsx::writeData(wb, "QCs", loq_data[[analyte]]$lloq, startRow = start_row + 3, startCol = col_info + 1)
    openxlsx::writeData(wb, "QCs", loq_data[[analyte]]$uloq, startRow = start_row + 3, startCol = col_info + 2)
    openxlsx::writeData(wb, "QCs", loq_data[[analyte]]$loqs, startRow = start_row + 2, startCol = col_info)
    average_formula(col_data, start_row = loq_startrow)
    re_formula(col_data, start_row = loq_startrow)
    
  }
  
  # Styling
  OutsideBorders <-
    function(wb_,
             sheet_,
             rows_,
             cols_,
             border_col = "black",
             border_thickness = "medium",
             cell_color = NULL) {
      left_col = min(cols_)
      right_col = max(cols_)
      top_row = min(rows_)
      bottom_row = max(rows_)
      
      sub_rows <- list(c(bottom_row:top_row),
                       c(bottom_row:top_row),
                       top_row,
                       bottom_row)
      
      sub_cols <- list(left_col,
                       right_col,
                       c(left_col:right_col),
                       c(left_col:right_col))
      
      directions <- list("Left", "Right", "Top", "Bottom")
      
      mapply(function(r_, c_, d) {
        temp_style <- createStyle(numFmt = "0.00",
                                  border = d,
                                  borderColour = border_col,
                                  borderStyle = border_thickness,
                                  fgFill = cell_color)
        addStyle(
          wb_,
          sheet_,
          style = temp_style,
          rows = r_,
          cols = c_,
          gridExpand = TRUE,
          stack = TRUE
        )
        
      }, sub_rows, sub_cols, directions)
    }
  
  addStyle(wb, "QCs", style = createStyle(fgFill = "#92D050"), 
           gridExpand = TRUE, stack = TRUE,
           rows = start_row + 2,
           cols = col_info)
  
  OutsideBorders(wb, "QCs", (start_row + 2):(start_row + 3), cell_color = "#FFFF99",
                 cols_ = (col_info + 1):(col_info + 1), border_thickness = "thin")
  OutsideBorders(wb, "QCs", (start_row + 2):(start_row + 3), cell_color = "#FFFF99",
                 cols_ = (col_info + 2):(col_info + 2), border_thickness = "thin")
  OutsideBorders(wb, "QCs", (start_row + 4):(start_row + 9), cell_color = "#DDDCD0",
                 cols_ = (col_info + 1):(col_info + 1), border_thickness = "thin")
  OutsideBorders(wb, "QCs", (start_row + 4):(start_row + 9), cell_color = "#DDDCD0",
                 cols_ = (col_info + 2):(col_info + 2), border_thickness = "thin")
  OutsideBorders(wb, "QCs", (start_row + 10):(start_row + 10), cell_color = "#C0C0C0",
                 cols_ = (col_info + 1):(col_info + 1), border_thickness = "thin")
  OutsideBorders(wb, "QCs", (start_row + 10):(start_row + 10), cell_color = "#C0C0C0",
                 cols_ = (col_info + 2):(col_info + 2), border_thickness = "thin")
  OutsideBorders(wb, "QCs", (start_row + 11):(start_row + 11), 
                 cols_ = (col_info + 1):(col_info + 1), border_thickness = "thin")
  OutsideBorders(wb, "QCs", (start_row + 11):(start_row + 11), 
                 cols_ = (col_info + 2):(col_info + 2), border_thickness = "thin")
  
  OutsideBorders(wb, "QCs", (start_row + 2):(start_row + 11), cols_ = col_info:col_data)
  
}

##### cal curve fun #####
cal_curve <- function(area_ratio, cal_data, analyte){
  
  slope <- cal_data %>% 
    filter(Molecule == analyte) %>% 
    pull(Slope) %>% 
    unique()
  
  intercept <- cal_data %>% 
    filter(Molecule == analyte) %>% 
    pull(Intercept) %>% 
    unique()
  
  (as.numeric(area_ratio) - as.numeric(intercept)) / as.numeric(slope)
}

#### Import data ####

##### Skyline results #####

#skyline_report <- "CappingAssay_04_Report__Fill_out_results_file_Capping_assay_summary.csv"

suppressWarnings(
  data <- read.csv(reportfile #list.files(Sys.getenv("temp"), pattern = skyline_report, full.names = TRUE)
                   ) %>%
    mutate(Replicate = str_remove(Replicate, "Â"),
           SampleGroup = str_remove(SampleGroup, "Â"),
           Molecule = forcats::as_factor(Molecule),
           CalculatedConcentration = as.numeric(CalculatedConcentration),
           CalculatedConcentration = ifelse(CalculatedConcentration < 0, 0, CalculatedConcentration),
           RatioToStandard = as.numeric(RatioToStandard),
           ExcludeFromCalibration = as.logical(ExcludeFromCalibration),
           TotalAreaLight = as.numeric(light.TotalArea),
           TotalAreaHeavy = as.numeric(heavy.TotalArea)) %>% 
    select(-light.TotalArea, -heavy.TotalArea) %>% 
    rename(SampleName = SampleGroup) %>%
    relocate(c(TotalAreaLight, TotalAreaHeavy), .before = CalculatedConcentration)
)

suppressWarnings(
  data <- data %>% 
    mutate(CalculatedConcentration = ifelse(str_detect(Molecule, "CC113|CC-AU"),
                                            cal_curve(NormalizedArea, data, "Dinucleotide"),
                                            CalculatedConcentration))
)

##### Sample info #####

# sample_information <- read.xlsx("sample info.xlsx", sep.names = " ") %>% 
#   dplyr::distinct()
sample_information <- read.xlsx(text_box_path_sample_info,
                                sheet = "Zusammenfassung", sep.names = " ") %>% 
  dplyr::rename(SampleName = 'Sample Name',
                CapType = 'Cap Type') %>% 
  dplyr::distinct()

#### Results ####
sample_results <- data %>% 
  filter(!str_detect(SampleName, "Cal"),
         !str_detect(SampleName, "QC"),
         !str_detect(SampleName, "spiked"),
         !str_detect(SampleName, "Blank")) %>% 
  group_by(Molecule, SampleName) %>% 
  summarise(`MeanConcentration [µM]` = mean(CalculatedConcentration), 
            .groups = "drop") %>% 
  left_join(sample_information, by = "SampleName")

# Check if samples from sample_info.xlsx fits to samples from Skyline and vice versa
if(length(setdiff(sample_information$SampleName, sample_results$SampleName)) > 0){

  warning(paste0("This sample cannot be found in the Skyline report and does not appear in the results: ",
                 "\n",
                 setdiff(sample_information$SampleName, sample_results$SampleName),
                "\n"))
}

if(length(setdiff(sample_results$SampleName, sample_information$SampleName)) > 0){

  error_msg <- simpleError("'sample_info.xlsx' and Skyline document do not match!")

  tryCatch(stop(error_msg),
           finally = writeLines(
             paste0("This sample cannot be found in 'sample_info.xlsx', but appears in the Skyline document. ",
                    "Please add sample information to Excel sheet or remove this sample from Skyline document: ",
                    "\n",
                    setdiff(sample_results$SampleName, sample_information$SampleName),
                    "\n")))
}


if(any(str_detect(sample_results$CapType, "CleanCap413|CC413"))){

  sample_results_cc413 <- sample_results %>% 
    filter(str_detect(CapType, "CleanCap413|CC413"), 
           Molecule %in% c("Dinucleotide", "ATP pos", "GTP pos")) %>% 
    pivot_wider(names_from = Molecule, 
                values_from = `MeanConcentration [µM]`) %>%
    mutate("Sum Dinucl. + ATP + GTP [uM]" = Dinucleotide + `ATP pos` + `GTP pos`,
           "Capping [%]" = Dinucleotide * 100 / `Sum Dinucl. + ATP + GTP [uM]`) %>% 
    relocate(`GTP pos`, .before = `ATP pos`)

} else {
  sample_results_cc413 <- data.frame()
}

if(any(str_detect(sample_results$CapType, "D1"))){

  sample_results_d1 <- sample_results %>% 
    filter(CapType == "D1") %>% 
    filter(Molecule %in% c("b-S-ARCA", "GTP pos")) %>% 
    pivot_wider(names_from = Molecule, 
                values_from = `MeanConcentration [µM]`) %>%
    mutate("Sum beta-s-ARCA + GTP [uM]" = `b-S-ARCA` + `GTP pos`,
           "Capping [%]" = `b-S-ARCA` * 100 / `Sum beta-s-ARCA + GTP [uM]`,
           `ATP pos`= "") %>% 
    relocate(`ATP pos`, .before = `Sum beta-s-ARCA + GTP [uM]`)
    

} else {
  sample_results_d1 <- data.frame()
}

if(any(str_detect(sample_results$CapType, "CleanCap113|CC113"))){
  
  sample_results_cc113 <- sample_results %>% 
    filter(str_detect(CapType, "CleanCap113|CC113"), 
           Molecule %in% c("CC113", "ATP pos", "GTP pos")) %>% 
    pivot_wider(names_from = Molecule, 
                values_from = `MeanConcentration [µM]`) %>%
    mutate("Sum CC113 + ATP + GTP [uM]" = CC113 + `ATP pos` + `GTP pos`,
           "Capping [%]" = CC113 * 100 / `Sum CC113 + ATP + GTP [uM]`) %>% 
    relocate(c(CC113, `GTP pos`), .before = `ATP pos`)
  
} else {
  sample_results_cc113 <- data.frame()
}

if(any(str_detect(sample_results$CapType, "AU-Cap|CC-AU"))){
  
  sample_results_ccau <- sample_results %>%
    filter(str_detect(CapType, "AU-Cap|CC-AU"),
           Molecule %in% c("CC-AU", "ATP pos", "GTP pos")) %>%
    pivot_wider(names_from = Molecule,
                values_from = `MeanConcentration [µM]`) %>%
    mutate("Sum CC-AU + ATP + GTP [uM]" = `CC-AU` + `ATP pos` + `GTP pos`,
           "Capping [%]" = `CC-AU` * 100 / `Sum CC-AU + ATP + GTP [uM]`) %>% 
    relocate(c(`CC-AU`, `GTP pos`), .before = `ATP pos`)
  
} else {
  sample_results_ccau <- data.frame()
}

##### Results Excel sheet #####

wb <- loadWorkbook(
  # if(length(str_subset(list.files(".", pattern = ".xlsx", full.names = TRUE), "Capping-Assay_results")) == 0){
  #   str_subset(list.files("..", pattern = ".xlsx", full.names = TRUE), "Capping-Assay_results")
  # } else {
  #   str_subset(list.files(".", pattern = ".xlsx", full.names = TRUE), "Capping-Assay_results")
  # }
  text_box_path_results_temp
)

  rawdata_style <- createStyle(textDecoration = "Bold", border = "TopBottomLeftRight", 
                               wrapText = TRUE, valign = "top", numFmt = "0.00")

  addStyle(wb, "results", style = createStyle(numFmt = "0.0"), gridExpand = TRUE,
           rows = 1:400, cols = ncol(sample_results_d1))
  
  class(data$Accuracy) <- "percentage"
  options(openxlsx.numFmt = "0.00")
  
  # Results sheet----
  writeData(wb, "results", sample_results_d1, startCol = 1, startRow = 2, 
            rowNames = FALSE, headerStyle = rawdata_style, borders = "columns")
  writeData(wb, "results", sample_results_cc413, startCol = 1, 
            startRow = nrow(sample_results_d1) + 4, rowNames = FALSE, 
            headerStyle = rawdata_style, borders = "columns")
  writeData(wb, "results", sample_results_cc113, startCol = 1, 
            startRow = nrow(sample_results_d1) + nrow(sample_results_cc413) + 6, rowNames = FALSE, 
            headerStyle = rawdata_style, borders = "columns")
  writeData(wb, "results", sample_results_ccau, startCol = 1, 
            startRow = nrow(sample_results_d1) + nrow(sample_results_cc413) + nrow(sample_results_cc113) + 6, rowNames = FALSE, 
            headerStyle = rawdata_style, borders = "columns")

  
  # Raw data sheets----
  writeData(wb, "raw data beta-S-ARCA", filter(data, Molecule == "b-S-ARCA"), 
            startCol = 1, startRow = 33, rowNames = FALSE, 
            headerStyle = rawdata_style, borders = "columns", withFilter = TRUE)
  writeData(wb, "raw data dinucl.", filter(data, Molecule == "Dinucleotide"), 
            startCol = 1, startRow = 33, rowNames = FALSE, 
            headerStyle = rawdata_style, borders = "columns", withFilter = TRUE)
  writeData(wb, "raw data ATP", filter(data, Molecule == "ATP pos"), 
            startCol = 1, startRow = 33, rowNames = FALSE, 
            headerStyle = rawdata_style, borders = "columns", withFilter = TRUE)
  writeData(wb, "raw data GTP", filter(data, Molecule == "GTP pos"), 
            startCol = 1, startRow = 33, rowNames = FALSE, 
            headerStyle = rawdata_style, borders = "columns", withFilter = TRUE)
  
  if(any(str_detect(sample_results$CapType, "CleanCap113|CC113"))){
    
    addWorksheet(wb, "raw data CC113")
    
    writeData(wb, "raw data CC113", filter(data, Molecule == "CC113"), 
              startCol = 1, startRow = 33, rowNames = FALSE, 
              headerStyle = rawdata_style, borders = "columns", withFilter = TRUE)
    
  }
  
  if(any(str_detect(sample_results$CapType, "AU-Cap|CC-AU"))){
    
    addWorksheet(wb, "raw data CC-AU")
    
    writeData(wb, "raw data CC-AU", filter(data, Molecule == "CC-AU"), 
              startCol = 1, startRow = 33, rowNames = FALSE, 
              headerStyle = rawdata_style, borders = "columns", withFilter = TRUE)
    
  }


#### Recovery ####

data <- replace(data, is.na(data), 0)
if(any(is.na(data$CalculatedConcentration))){
  
  stop(
    paste("Remove NA: ", 
          filter(data, is.na(data$CalculatedConcentration)) %>% 
            pull(Molecule),
          " -> ",
          filter(data, is.na(data$CalculatedConcentration)) %>% 
            pull(Replicate),
          " // "
    )
  )
  
}

recov_data_filter <- data %>% 
  filter(str_detect(Replicate, "spiked")) %>% 
  mutate(SampleName_spiked = str_remove(SampleName, "_spiked"))

recovery_results <- data %>% 
  mutate(SampleName_spiked = str_remove(SampleName, "_spiked")) %>% 
  filter(SampleName_spiked %in% recov_data_filter$SampleName_spiked,
         Molecule %in% c("b-S-ARCA", "Dinucleotide", "ATP pos", "GTP pos"),
         !str_detect(SampleName, "Cal"),
         !str_detect(SampleName, "QC")) %>% 
  group_by(Molecule, SampleName) %>% 
  summarise(`MeanConcentration [µM]` = mean(CalculatedConcentration), 
            .groups = "drop") %>% 
  left_join(sample_information, by = "SampleName") %>% 
  pivot_wider(names_from = Molecule,
              values_from = `MeanConcentration [µM]`) %>% 
  mutate(RNA = paste0(CapType, "; ", `Amount Cap [mM]`, "mM", "; ", `RNA Length [nt]`, " nt"),
         RNA = ifelse(str_detect(SampleName, "spiked"), "", RNA)) %>% 
  select(-`Amount Cap [mM]`, -`CapType`, -`RNA Length [nt]`, -`Amount RNA [µg]`) %>% 
  relocate(RNA, .after = last_col())

# Recovery sheet----
writeData(wb, 3, recovery_results, 
          startCol = 2, startRow = 3, colNames = FALSE, rowNames = FALSE)

#### QC ####

analytes <- data %>%
  filter(Molecule %in% c('b-S-ARCA', 'Dinucleotide', 'ATP pos', 'GTP pos')) %>%
  pull(Molecule) %>% 
  unique()

qc_data <- map(analytes, ~ qc(data, .))

names(qc_data) <- analytes

loq_data <- loq(data)

# QC sheet----

#### QC Excel styling ####

options(openxlsx.numFmt = "0.00")
general_style <-  createStyle(fgFill = "#92D050")
border_style <- createStyle(border = "left", borderStyle = "double")
qc_style <- createStyle(numFmt = "0.00", fgFill = "#DDDCD0")
avg_style <- createStyle(numFmt = "0.00", border = "top", borderStyle = "double")

all_length <- 23 + nrow(longest_df(qc_data))
border_length <- 21 + nrow(longest_df(qc_data)) + 4 + 4
loq_startrow <- nrow(longest_df(qc_data)) + 31

addStyle(wb, "QCs", style = border_style, gridExpand = TRUE,
         rows = 2:border_length, 
         cols = c(1, 7, 13, 19))

addStyle(wb, "QCs", style = qc_style, gridExpand = TRUE,
         rows = c(5:7, 11:13, 24:all_length), 
         cols = c(3:5, 9:11, 15:17, 21:23))

addStyle(wb, "QCs", style = avg_style, gridExpand = TRUE,
         rows = c(8, 14, 18, all_length+1), 
         cols = c(3:5, 9:11, 15:17, 21:23))

addStyle(wb, "QCs", style = general_style, gridExpand = TRUE,
         rows = 2, 
         cols = c(1, 7, 13, 19))

addStyle(wb, "QCs", style = createStyle(numFmt = "0.00"), gridExpand = TRUE,
         rows = c(25+nrow(longest_df(qc_data)), 
                  26+nrow(longest_df(qc_data))),
         cols = c(3:5, 9:11, 15:17, 21:23))

#### QC Excel data ####
# QC
writeData(wb, "QCs", "Stability over the measuring period")
map2(analytes, c(1, 7, 13, 19),
     ~ write_data_qc(qc_data, .x, col_info = .y, col_data = .y + 2))

# LOQ
writeData(wb, "QCs", "Calculation of the relative measurement error (%RE)", startRow = loq_startrow)
invisible(
  map2(analytes, c(3, 9, 15, 21),
     ~ write_data_loq(loq_data, .x, start_row = loq_startrow, col_info = .y, col_data = .y + 2))
)

#### Save Excel workbook ####

getwd()
saveWorkbook(wb, 
             paste0(openxlsx::readWorkbook(wb, sheet = 1, rows = 3)[2] %>% colnames(), 
                    "_Capping-Assay_results",
                    format(Sys.time(), "_%Y-%m-%d_%H-%M-%S"),
                    ".xlsx"), 
             overwrite = TRUE)

recent_file <- file.info(list.files(pattern = "Capping-Assay_results"))
openXL(rownames(recent_file)[which.max(recent_file$mtime)])

message("Extraction done! Find your file here: ", getwd())
warnings()