library(dplyr)
library(purrr)
library(stringr)
library(tidyr)
library(openxlsx)

read_xlsx <- function(data){
  openxlsx::read.xlsx(data, sheet = 1, cols = c(2:13), rows = c(13,16:100), sep.names = " ") %>% 
    dplyr::mutate(dplyr::across(tidyselect::everything(), as.character))
}

#### Import data ####

# Read sample data from order forms
path_to_orderforms <- paste0(Sys.getenv("Onedrive"),
                             "\\Routinemessungen\\Order Forms - Capping Assay")

order_forms_raw <- list.files(path_to_orderforms, full.names = TRUE) %>% 
  map_df(read_xlsx) %>% 
  filter(`Sample name (CAP Unit internal number)` != "SER_CA_YYYYMMDD_xxx_nn") %>% 
  mutate(`Type of CAP` = ifelse(`Type of CAP` == "other CAP", Comments, `Type of CAP`))

sample_information <- order_forms_raw %>% 
  select(SampleName       = 1,
         RNA              = 2,
         `AmountCap [mM]` = 10,
         CapType          = 9,
         `RNALength [nt]` = 5,
         `AmountRNA [ug]` = 12
  )

write.xlsx(sample_information, "sample info.xlsx", rowNames = FALSE)

if(length(list.files(pattern = "sample info")) != 0){
  message("Extraction done! Find your file here: ", getwd())
} else {
  warning("Extraction failed! sample info.csv could not be created.")
}



  
