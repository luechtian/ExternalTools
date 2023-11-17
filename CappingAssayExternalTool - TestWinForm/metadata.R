library(dplyr)
library(stringr)
library(tidyr)
library(openxlsx)
library(purrr)

#### Functions ####
parse_conc <- function(string){
  
  string <- stringr::str_remove(string, "Cal-")
  string <- stringr::str_remove(string, "QC ")
  string <- stringr::str_split(string, " ")
  string <- unlist(purrr::map(string, 1))
  string <- stringr::str_replace(string, ",", ".")
  string <- suppressWarnings(as.numeric(string))
  
  
}

parse_samplegroup <- function(string){
  
  remove_tail <- function(string){
    
    string_vector <- stringr::str_split(string, "_")[[1]] %>% .[-length(.)]
    
    paste(string_vector, collapse = "_")
  }
  
  # remove_tail-function is not vectorised. This means the tail of the first element in a vector
  # is taken for the str_remove-function for all other elements in the same vector
  # With map() this behaviour can be bypassed, so each element has its own string-tail.
  
  string <- stringr::str_replace(string, ",", ".")
  
  purrr::map(string, remove_tail) %>% 
    unlist()
  
}

#### Import data ####
metadata <- read.csv(list.files(Sys.getenv("temp"), 
                                pattern = "CappingAssay_01_Metadata_Capping_assay_metadata.csv",
                                full.names = TRUE),
                     check.names = FALSE) %>%
  tibble()

metadata <- metadata %>%
  mutate(Replicate = str_remove(Replicate, "Â"),
         SampleType = if_else(str_detect(Replicate, "Cal") == TRUE, "Standard", SampleType),
         SampleType = if_else(str_detect(Replicate, "QC") == TRUE, "Quality Control", SampleType),
         SampleType = if_else(str_detect(Replicate, "Blank") == TRUE, "Solvent", SampleType),
         SampleGroup = parse_samplegroup(Replicate),
         `AnalyteConcentration` = parse_conc(Replicate),
         SpikeFactor = if_else(str_detect(Replicate, "spiked") == TRUE, 2.5, 0),)

write.xlsx(metadata, paste0(format(Sys.time(), "%Y-%m-%d_%H-%M-%S_"),
                            "CappingAssay_metadata.xlsx"))


recent_file <- file.info(list.files(pattern = "CappingAssay_metadata"))
openXL(rownames(recent_file)[which.max(recent_file$mtime)])

message("Extraction done! Find your file here: ", getwd())