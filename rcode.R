#### A01 Maps of AEDC ####


# 1 Set seed and WD -------------------------------------------------------

set.seed(1234)
WD <- getwd()


# 2 Install and Lib Packages ----------------------------------------------

library(tidyverse)
library(spdep)

library(ggpubr)


# 3 Read Maps and Data ----------------------------------------------------

dat <- read_csv("Input/data_AEDC.csv") 
SA3_ASGS16 <- st_read("Input/ASGS16/SA3_2016_AUST.shp")


# 4 Data Cleaning ---------------------------------------------------------

dat_map <- SA3_ASGS16 %>%
  full_join(dat) %>%
  filter(state == "NSW",
         model == "M4") %>%
  group_by(variable) %>%
  mutate(vulnerable_rate_model_cat = factor(ntile(vulnerable_rate_model, 10)))

# 5 Maps ------------------------------------------------------------------

Variable_List <- tibble(Vaiable = c("Health", "Social",
                                    "Emotional", "Language", 
                                    "Communication"),
                        FullName = c("Physical Health & Wellbeing",
                                     "Social Competence",
                                     "Emotional Maturity",
                                     "Language & Cognitive Skills",
                                     "Communication Skills & General Knowledge"))

FUN_Mapping <- function(Variable, FullName){
  
  p1 <- dat_map %>%
    filter(variable == Variable) %>%
    ggplot() +
    geom_sf(aes(fill = vulnerable_rate_model_cat),
            color = "black") +
    scale_fill_brewer(palette = "RdYlGn",
                      direction = -1,
                      na.value = "grey") + 
    labs(title = "New South Wales",
         fill = "Vulnerability Levels (Deciles)") +
    theme_void() +
    theme(plot.title = element_text(hjust = 0.5,
                                    size = 12))
  
  p2 <- dat_map %>%
    filter(variable == Variable,
           GCC_NAME16 == "Greater Sydney") %>%
    ggplot() +
    geom_sf(aes(fill = vulnerable_rate_model_cat),
            color = "black") +
    scale_fill_brewer(palette = "RdYlGn",
                      direction = -1,
                      na.value = "grey") + 
    labs(title = "Greater Sydney",
         fill = "Vulnerability Levels (Deciles)") +
    theme_void() +
    theme(plot.title = element_text(hjust = 0.5,
                                    size = 12))
  
  map <- ggarrange(plotlist = list(p1, p2),
                   ncol = 2,
                   common.legend = TRUE, legend = "bottom") %>%
    annotate_figure(top = text_grob(str_c("Child Developmental Vulnerability by SA3 in 2018",
                                          "\n", FullName), 
                                    face = "bold",
                                    hjust = 0.5,
                                    size = 14))
  return(map)
}

for (i in 1:5) {
  FUN_Mapping(Variable_List$Vaiable[i], Variable_List$FullName[i]) %>%
    ggsave(filename = str_c("Output/Map_", Variable_List$Vaiable[i], ".png"),
           .,
           height = 12, width = 16, units = "cm")
}


# 6 Additional maps for Data of Indigenous --------------------------------

p1 <- dat_map %>%
  filter(variable == "Health") %>%
  mutate(indig_ratio = indig_yes / (indig_yes + indig_no),
         indig_ratio_cat = factor(ntile(indig_ratio,10))) %>%
  ggplot() +
  geom_sf(aes(fill = indig_ratio_cat),
          color = "black") +
  scale_fill_brewer(palette = "RdYlGn",
                    direction = -1,
                    na.value = "grey") + 
  labs(title = "New South Wales",
       fill = "Proportion (5 Quantiles)") +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5,
                                  size = 12))

p2 <- dat_map %>%
  filter(variable == "Health",
         GCC_NAME16 == "Greater Sydney") %>%
  mutate(indig_ratio = indig_yes / (indig_yes + indig_no),
         indig_ratio_cat = factor(ntile(indig_ratio,5))) %>%
  ggplot() +
  geom_sf(aes(fill = indig_ratio_cat),
          color = "black") +
  scale_fill_brewer(palette = "RdYlGn",
                    direction = -1,
                    na.value = "grey") + 
  labs(title = "Greater Sydney",
       fill = "Proportion (5 Quantiles)") +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5,
                                  size = 12))

ggarrange(plotlist = list(p1, p2),
          ncol = 2,
          common.legend = TRUE, legend = "bottom") %>%
  annotate_figure(top = text_grob(str_c("Indigenous Population",
                                        "\n",  "by SA3 in 2016"), 
                                  face = "bold",
                                  hjust = 0.5,
                                  size = 14)) %>%
  ggsave(filename = str_c("Output/Map_Indigenous.png"),
         .,
         height = 12, width = 16, units = "cm")


# End of the code ---------------------------------------------------------

