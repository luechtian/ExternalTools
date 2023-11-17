library(dplyr)
library(stringr)
library(tidyr)
library(openxlsx)

#### Import data ####

skyline_report <- "CappingAssay_03_Fortification_Capping_assay_summary"

data <- read.csv(list.files(Sys.getenv("temp"), 
                            pattern = skyline_report,
                            full.names = TRUE))

suppressWarnings(
  data <- data %>%
    mutate(Replicate = str_remove(Replicate, "Â"),
           SampleGroup = str_remove(SampleGroup, "Â"),
           SpikeFactor = as.numeric(SpikeFactor),
           CalculatedConcentration = as.numeric(CalculatedConcentration))
)

#
data <- replace(data, is.na(data), 0)


#### FORTIFICATION ####
data_spiked <- data %>% 
  filter(str_detect(Replicate, "spiked")) %>% 
  mutate(SampleName = str_remove(SampleGroup, "_spiked")) %>% 
  rename(SpikedConcentration = CalculatedConcentration) %>% 
  group_by(Molecule, SampleGroup, SampleName, SpikeFactor) %>% 
  summarise(MeanSpikedConcentration = mean(SpikedConcentration), .groups = "drop")

data_unspiked <- data %>% 
  filter(data$SampleGroup %in% data_spiked$SampleName) %>% 
  select(Molecule,
         SampleName = SampleGroup,
         SampleConcentration = CalculatedConcentration) %>% 
  group_by(Molecule, SampleName) %>% 
  summarise(MeanSampleConcentration = mean(SampleConcentration), .groups = "drop")

fortification <- left_join(data_spiked, data_unspiked, by = c("Molecule", "SampleName")) %>%
  mutate(AccuracyFortification = 
           ((MeanSpikedConcentration - MeanSampleConcentration * 0.9) / SpikeFactor) * 100)

fortification_table <- fortification %>% 
  select(Molecule, SampleName, AccuracyFortification) %>% 
  tidyr::pivot_wider(names_from = Molecule,
                     values_from = AccuracyFortification) %>% 
  select(SampleName, `b-S-ARCA`, Dinucleotide ,`ATP pos`, `GTP pos`)

if(any(is.na(fortification$SpikeFactor))){stop("Spike factors are missing!")}

#options(digits = 2)
#write.xlsx(fortification_table, "fortification.xlsx", rowNames = FALSE)

getwd()
fortification_table

