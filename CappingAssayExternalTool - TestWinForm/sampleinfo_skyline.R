library(dplyr)
library(purrr)
library(stringr)
library(tidyr)
library(openxlsx)

#### Import data ####
# Read sample data from order forms
sample_information <- read.csv(list.files(Sys.getenv("temp"), 
                                          pattern = "CappingAssay_02_Sample_info__via_Skyline_Capping_assay_sample_info",
                                          full.names = TRUE),
                               check.names = FALSE) %>%
  filter(SampleName != "")

write.xlsx(sample_information, "sample info.xlsx", rowNames = FALSE)

if(length(list.files(pattern = "sample info")) != 0){
  message("Extraction done! Find your file here: ", getwd())
} else {
  warning("Extraction failed! sample info.csv could not be created.")
}
  