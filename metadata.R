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
  if ( length (arguments) != 17)
    # expected arguments not present -- error
    stop ("USAGE: R --slave --no-save --args '<checkbox><textbox><combobox>'") 
  for (i in 1:17) {
    arg <- arguments [i]
    # remove leading and trailing blanks
    arg <- gsub ("^ *", "", arg)
    arg <- gsub (" *$", "", arg)
    # remove any embedded quotation marks
    arg <- gsub ("['\'\"]", "", arg)
    #report file is brought in as an argument, this is specified in TestArgsCollector.properties
    if (i==1) reportfile <<- arg
    if (i==2) textbox_cal <<- toString(arg)
    if (i==3) textbox_qc <<- toString(arg)
    if (i==4) textbox_blank <<- toString(arg)
    if (i==5) textbox_dblank <<- toString(arg)
    if (i==6) textbox_solvent <<- toString(arg)
    if (i==7) textbox_run <<- toString(arg)
  }
  
  #All data processing done below

  cat("\rCal Box Content: ", textbox_cal,"\r")
  cat("\rQC Box Content: ", textbox_qc,"\r")
  cat("\rBlank Box Content: ", textbox_blank,"\r")
  cat("\rDouble Blank Box Content: ", textbox_dblank,"\r")
  cat("\rSolvent Box Content: ", textbox_solvent,"\r")
  cat("\rRun Box Content: ", textbox_run,"\r")


#### Functions ####
parse_conc <- function(string){
  
  string <- stringr::str_remove(string, "Cal ")
  string <- stringr::str_split(string, "_")
  string <- unlist(purrr::map(string, 1))
  string <- stringr::str_replace(string, ",", ".")
  string <- suppressWarnings(as.numeric(string))
  
  
}

parse_samplegroup <- function(string){
  
  remove_tail <- function(string){
    #string_tail <- stringr::str_split(string, "\\(")[[1]] %>% 
    #  tail(n = 1) %>% 
    #  paste0(" (", .)
    
    str_remove(string, " \\s*\\([^\\)]+\\)")
  }
  
  # remove_tail-function is not vectorised. This means the tail of the first element of a vector
  # will be picked for the str_remove-function for all other elements in the same vector.
  # With map() this behaviour can be bypassed, so each element has its own string-tail.
  
  purrr::map(string, remove_tail) %>% 
    unlist() 
  
}

#### Import data ####
metadata <- read.csv(reportfile, check.names = FALSE) %>% tibble()

metadata <- metadata %>%
  mutate(SampleGroup = parse_samplegroup(Replicate),
         `AnalyteConcentration` = parse_conc(Replicate),
         SampleType = if_else(str_detect(Replicate, textbox_cal) == TRUE, "Standard", SampleType),
         SampleType = if_else(str_detect(Replicate, textbox_qc) == TRUE, "Quality Control", SampleType),
         SampleType = if_else(str_detect(Replicate, textbox_blank) == TRUE, "Blank", SampleType),
         SampleType = if_else(str_detect(Replicate, textbox_dblank) == TRUE, "Double Blank", SampleType),
         SampleType = if_else(str_detect(Replicate, textbox_solvent) == TRUE, "Solvent", SampleType),
         Run = textbox_run
         )

write.xlsx(metadata, "metadata.xlsx")
getwd()