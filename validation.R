# # Comment for Testing in Skyline!
reportfile <- read.csv("C:/Users/chris/Documents/Skyline/DOTMA/Assay Validation summary.csv")
check_box_ap <- 1
check_box_selectp <- 1
check_box_selecti <- 1
check_box_carry <- 1
check_box_runqc <- 1
check_box_stabiauto <- 1
check_box_stabibench <- 1
check_box_stabift <- 1

#### Packages ####
library(dplyr)
library(stringr)
library(tidyr)
library(purrr)
library(openxlsx)

#### Command line processing for Argument Collector ####

options (echo = FALSE)
debug <- FALSE

# set up for command line processing (if needed)
# arguments are specified positionally (since there are no optional arguments) and ...
arguments <- commandArgs(trailingOnly=TRUE)
if (length (arguments) != 17){
  # expected arguments not present -- error
  stop ("USAGE: R --slave --no-save --args '<checkbox><textbox><combobox>'")
}
for (i in 1:17) {
  arg <- arguments [i]
  # remove leading and trailing blanks
  arg <- gsub("^ *", "", arg)
  arg <- gsub(" *$", "", arg)
  # remove any embedded quotation marks
  arg <- gsub("['\'\"]", "", arg)
  args <- list()
  #report file is brought in as an argument, this is specified in 02_validation.properties
  if (i==1) reportfile <- arg
  if (i==8) check_box_ap <- as.numeric (arg)
  if (i==9) check_box_selectp <- as.numeric (arg)
  if (i==10) check_box_selecti <- as.numeric (arg)
  if (i==11) check_box_carry <- as.numeric (arg)
  if (i==12) check_box_runqc <- as.numeric (arg)
  if (i==13) check_box_stabiauto <- as.numeric (arg)
  if (i==14) check_box_stabibench <- as.numeric (arg)
  if (i==15) check_box_stabift <- as.numeric (arg)
  if (i==16) textbox_path1 <- gsub("\\\\", "/", toString(arg))
  if (i==17) textbox_path2 <- gsub("\\\\", "/", toString(arg))
}
  
#All data processing done below
{
  if(check_box_ap == 0)
    cat("\r check_box_ap was not checked.")
  if(check_box_ap == 1)
    cat("\r check_box_ap was checked.")
  if(check_box_selectp == 0)
    cat("\r check_box_selectp was not checked.")
  if(check_box_selectp == 1)
    cat("\r check_box_selectp was checked.")
  if(check_box_selecti == 0)
    cat("\r check_box_selecti was not checked.")
  if(check_box_selecti == 1)
    cat("\r check_box_selecti was checked.")
  if(check_box_carry == 0)
    cat("\r check_box_carry was not checked.")
  if(check_box_carry == 1)
    cat("\r check_box_carry was checked.")
  if(check_box_runqc == 0)
    cat("\r check_box_runqc was not checked.")
  if(check_box_runqc == 1)
    cat("\r check_box_runqc was checked.")
  if(check_box_stabiauto == 0)
    cat("\r check_box_stabiauto was not checked.")
  if(check_box_stabiauto == 1)
    cat("\r check_box_stabiauto was checked.")
  if(check_box_stabibench == 0)
    cat("\r check_box_stabibench was not checked.")
  if(check_box_stabibench == 1)
    cat("\r check_box_stabibench was checked.")
  if(check_box_stabift == 0)
    cat("\r check_box_stabift was not checked.\r")
  if(check_box_stabift == 1)
    cat("\r check_box_stabift was checked.\r")
  
  cat("\rFile path: ", textbox_path1,"\r")
  
  cat("\rFile path: ", textbox_path2,"\r")
}

#### Functions ####
header <- function(wb, sheet, cols){
  
  openxlsx::mergeCells(wb, sheet, cols = 1:cols, rows = 1)
  openxlsx::mergeCells(wb, sheet, cols = 2:cols, rows = 2)
  openxlsx::mergeCells(wb, sheet, cols = 2:cols, rows = 3)
  
  openxlsx::setRowHeights(wb, sheet, rows = 1:2, heights = 30)
  openxlsx::setRowHeights(wb, sheet, rows = 3:5, heights = 11.25)
  
  openxlsx::setColWidths(wb, sheet, cols = 1, widths = 31)
  
  grey <-  openxlsx::createStyle(fgFill = "#D9D9D9", textDecoration = "bold",
                                 halign = "center", valign = "center")
  blue <-  openxlsx::createStyle(fgFill = "#D9E1F2", textDecoration = "bold",
                                 halign = "center", valign = "center")
  
  openxlsx::addStyle(wb, sheet, style = grey, gridExpand = TRUE, rows = 1,  cols = 1:cols)
  openxlsx::addStyle(wb, sheet, style = blue, gridExpand = TRUE, rows = 2,  cols = 1:cols)
  openxlsx::addStyle(wb, sheet, style = grey, gridExpand = TRUE, rows = 3,  cols = 1:cols)
}

add_raw_data_sheet <- function(wb, sheet, data){
  
  openxlsx::addWorksheet(wb, sheet)
  
  header(wb, sheet, ncol(data))

  openxlsx::writeData(wb, sheet, "Raw data", startRow = 1, startCol = 1)
  openxlsx::writeData(wb, sheet, paste(analyte, "Validierung"), startRow = 2, startCol = 1)
  openxlsx::writeData(wb, sheet, paste(analyte, "/ [Matrix]"), startRow = 2, startCol = 2)
  openxlsx::writeData(wb, sheet, "Project Code", startRow = 3, startCol = 1)
  openxlsx::writeData(wb, sheet, "Analyte / Matrix", startRow = 3, startCol = 2)
  
  openxlsx::writeData(wb, sheet, data, startRow = 7, startCol = 1)
  
}

add_cal_curve_sheet <- function(wb, sheet, data){
  
  openxlsx::addWorksheet(wb, sheet)
  
  n_cal <- data %>% 
    filter(str_detect(SampleGroup, "Cal"),
           Sample.Type == "Standard",
           Exclude.From.Calibration == FALSE) %>%
    pull(SampleGroup) %>% 
    unique() %>% 
    length()
  
  analyte <- data %>% pull(Molecule.Name) %>% unique()
  
  header(wb, sheet, n_cal + 2)
  
  openxlsx::writeData(wb, sheet, "Calibration Curve", startRow = 1, startCol = 1)
  openxlsx::writeData(wb, sheet, paste(analyte, "Validierung"), startRow = 2, startCol = 1)
  openxlsx::writeData(wb, sheet, paste(analyte, "/ [Matrix]"), startRow = 2, startCol = 2)
  openxlsx::writeData(wb, sheet, "Project Code", startRow = 3, startCol = 1)
  openxlsx::writeData(wb, sheet, "Analyte / Matrix", startRow = 3, startCol = 2)
  
}

#### Report ####

is_area <- reportfile %>% 
  filter(Standard.Type == "Surrogate Standard") %>% 
  select(Sample.Name, Total.Area.IS = Total.Area)

data <- reportfile %>% 
  filter(Standard.Type == "") %>% 
  left_join(is_area, by = c("Sample.Name")) %>% 
  relocate(Total.Area.IS, .after = Total.Area) %>% 
  mutate(Exclude.From.Calibration = as.logical(Exclude.From.Calibration))

#####

wb <- createWorkbook()

add_raw_data_sheet(wb, "raw data", data)

add_cal_curve_sheet(wb, "Calibration Curve", data)

openXL(wb)



