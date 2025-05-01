#' @name analysis.R
#' @author Tim Fraser

library(dplyr)
library(readr)
library(tidyr)
library(purrr)
library(ggplot2)
library(ggtext)
library(viridis)


setwd(paste0(rstudioapi::getActiveProject(), "/validation"))

# DATA16 ########################################################

geoids = c("Bronx" = "36005", "Brooklyn" = "36047", "Queens" = "36081", "Manhattan" = "36061", "Staten Island" = "36085")

## TABLE 1 #############################################

data = read_rds("data16.rds")


stat = data %>%
  select(bucket, geoid, scenario, emissions, vmt, vehicles) %>%
  pivot_longer(cols = c(emissions:vehicles), names_to = "var", values_to = "value") %>%
  group_by(scenario, var) %>%
  summarize(
    mean = mean(value, na.rm = TRUE),
    sd = sd(value, na.rm = TRUE),
    se = sd / sqrt(n()),
    lower = quantile(value, probs = 0.05, na.rm = TRUE),
    median = quantile(value, probs = 0.5, na.rm = TRUE),
    upper = quantile(value, probs = 0.95, na.rm = TRUE)
  ) %>%
  filter(var == "emissions") %>%
  select(-var)

# Get change over time
stat$change = c(round(diff(stat$mean) / stat$mean[-length(stat$mean)], 3), NA)

stat


## PLOT 1 ##############################################
data = read_rds("data16.rds") %>%
  filter(scenario %in% c(18:26, 29, 28), pollutant == 98)

# data %>%
#   filter(scenario == 25)

# Compare Defaults vs. custom sourcetypeyear and custom sourcetypeyear + sourcetypeyearvmt
ggplot() +
  geom_point(
    data = data,
    mapping = aes(x = factor(name), y = emissions, color = factor(scenario), group = factor(scenario)),
    size = 10
  ) +
#  scale_y_continuous(trans = "log") +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))


stat = data %>%
  group_by(geoid, name) %>%
  summarize(lower = min(emissions, na.rm = TRUE),
            upper = max(emissions, na.rm = TRUE))

# Compare Defaults vs. custom sourcetypeyear and custom sourcetypeyear + sourcetypeyearvmt
gg = ggplot() +
  # geom_errorbar(
  #   data = stat, mapping = aes(x = factor(name), ymin = lower, ymax = upper, width = 0.5)
  # ) +
  geom_line(
    data = data,
    mapping = aes(x = factor(name), y = emissions, group = factor(scenario), color = factor(scenario)),
    linewidth = 2, alpha = 0.5
  ) +
  geom_point(
    data = data,
    mapping = aes(x = factor(name), y = emissions, color = factor(scenario), group = factor(scenario)),
    size = 10, alpha = 0.5
  ) +
  #  scale_y_continuous(trans = "log") +
  theme_bw(base_size = 14) +
  theme(panel.border = element_rect(fill = NA, color = "#373737"),
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank()) +
  theme(axis.text.x = element_text(angle = 30, hjust = 1)) +
  viridis::scale_color_viridis(
    discrete = TRUE, option = "plasma", end = 0.9, 
    labels = c("18" = "Default",
               "19" = "+VMT by Vehicle Type",
               "20" = "+Vehicle Population by Vehicle Type",
               "21" = "+VMT Distribution by Roadtype",
               "22" = "+Vehicle Population by Age and Type",
               "23" = "+Average Speeds by Hour",
               "24" = "+Fleet Technology and Fuel Types",
               "25" = "+Meteorological Conditions by Hour",
               "26" = "+Inspection & Maintenance Coverage",
               "28" = "+Fuels...",
               "29" = "+VMT Fractions..."),
    name = "Scenario"
  )  +
  scale_y_continuous(
    labels = scales::label_number(scale_cut = scales::cut_si(unit = "t"))
  ) +
  labs(x = "New York Boroughs (n = 5 counties)",
       y = "Emissions (US tons)\nof Carbon Dioxide equivalent (CO2e)",
       title = "Change in Emissions by Level of MOVES Input Detail")

# gg
ggsave(gg, filename = "viz/lines.png", dpi = 500, width = 8, height =6)
browseURL("viz/lines.png")
# Marginal improvement from previous
# 
# data %>%
#   pivot_wider(
#     id_cols = any_of(c("geoid", "name")), 
#     names_from = scenario, values_from = emissions,
#     names_prefix = "s") %>%
#   mutate()

## PLOT 2 ###############################################
geoids = c("Bronx" = "36005", "Brooklyn" = "36047", "Queens" = "36081", "Manhattan" = "36061", "Staten Island" = "36085")
data = read_rds("data16.rds") %>%
  filter(geoid %in% geoids) %>%
  filter(pollutant == 98) %>%
  filter(scenario %in% c(18:26, 28, 29)) %>%
  select(-bucket) %>%
  distinct()


# Relative improvement as percent change from previous set?
compare = data %>%
  group_by(geoid, name) %>%
  reframe(
    # How much did 8 improve on 5?
    s18_s19 =  (emissions[scenario == 19] - emissions[scenario == 18]  ) / emissions[scenario == 18],
    s19_s20 =  (emissions[scenario == 20] - emissions[scenario == 19]) / emissions[scenario == 19],
    s20_s21 =  (emissions[scenario == 21] - emissions[scenario == 20]) / emissions[scenario == 20],
    s21_s22 = (emissions[scenario == 22] - emissions[scenario == 21]) / emissions[scenario == 21],
    s22_s23 = (emissions[scenario == 23] - emissions[scenario == 22]) / emissions[scenario == 22],
    s23_s24 = (emissions[scenario == 24] - emissions[scenario == 23]) / emissions[scenario == 23],
    s24_s25 = (emissions[scenario == 25] - emissions[scenario == 24]) / emissions[scenario == 24],
    s25_s26 = (emissions[scenario == 26] - emissions[scenario == 25]) / emissions[scenario == 25],
    s26_s28 = (emissions[scenario == 28] - emissions[scenario == 26]) / emissions[scenario == 26],
    s28_s29 = (emissions[scenario == 29] - emissions[scenario == 28]) / emissions[scenario == 28]
  ) %>%
  ungroup() %>%
  pivot_longer(cols = -any_of(c("geoid", "name")), names_to = "var", values_to = "value") %>%
  mutate(var = factor(var, levels = c("s18_s19", "s19_s20", "s20_s21", "s21_s22", "s22_s23",
                                      "s23_s24", "s24_s25", "s25_s26", "s26_s28", "s28_s29"))) %>%
  mutate(var = var %>% dplyr::recode_factor(
    "s18_s19" = "+VMT by Vehicle Type",
    "s19_s20" = "+Vehicle Population<br>by Vehicle Type",
    "s20_s21" = "+VMT Distribution<br>by Roadtype",
    "s21_s22" = "+Vehicle Population<br>by Age and Type",
    "s22_s23" = "+Average Speeds<br>by Hour",
    "s23_s24" = "+Fleet Technology<br>& Fuel Types",
    "s24_s25" = "+Meteorological<br>Conditions by Hour",
    "s25_s26" = "+Inspection &<br>Maintenance Coverage",
    "s26_s28" = "+Fuels...",
    "s28_s29" = "+VMT Fractions..."
    
    
    # "s28_s29" = "+monthVMTFraction\n+dayVMTFraction",
    # "s26_s28" = "+fuelFormulation\n+fuelSupply\n+fuelUsageFraction",
    # "s25_s26" = "+imCoverage",
    # "s24_s25" = "+zoneMonthHour",
    # "s23_s24" = "+AVFT",
    # "s22_s23" = '+avgSpeedDistribution',
    # "s21_s22" = "+sourceTypeAgeDistribution",
    # "s20_s21" = "+roadTypeDistribution",
    # "s19_s20" = "+sourceTypeYear",
    # "s18_s19" ="+sourceTypeYearVMT"
  ))


compare_stat = compare %>% 
  group_by(var) %>%
  summarize(lower = quantile(value, probs = 0, na.rm = TRUE),
            estimate = quantile(value, probs = 0.50, na.rm = TRUE),
            upper = quantile(value, probs = 1, na.rm = TRUE)
  ) %>%
  # Post-hoc, let's summarize these as absolute value percent changes
  mutate(
    estimate = abs(estimate),
    lower = abs(lower),
    upper = abs(upper)
  )

library(ggtext)

# Marginal successive improvement
gg = ggplot() +
  # geom_line(data = compare, mapping = aes(x = reorder(var, value), y = value, group = geoid), color = "grey", alpha = 0.75) +
  # geom_point(data = compare, mapping = aes(x = reorder(var, value), y = value, color = var, group = geoid), size = 3) +
  geom_crossbar(data = compare_stat, mapping = aes(x = reorder(var, estimate), y = estimate, ymin = lower, ymax = upper, group = var, fill = var, color = var),
                alpha = 0.75) +
  geom_label(data = compare_stat, mapping = aes(
    x = reorder(var, estimate), y = estimate,  group = var, color = var, 
    label = {
      x = scales::percent(estimate, accuracy = 1)
      if_else(x == "0%", "<0%", false = x)
      })) +
  scale_y_continuous(labels = scales::label_percent(), breaks = c(-0.75, -0.5, -0.1, -.2, -0.25, 0, 0.1, 0.2, 0.3, 0.5, 0.75)) +
  scale_fill_viridis(option = "plasma", discrete = TRUE, end = 0.9) +
  scale_color_viridis(option = "plasma", discrete = TRUE, end = 0.9) +
  theme_bw(base_size = 14) +
  labs(y = "Absolute Percent Change in Overall CO2e Emissions<br><sup>(Medians and Ranges, n = 5 counties)</sup>",
       x = NULL,
       title = "<b>Valued-Added of Customizing MOVES Tables</b><br><sup>compared to MOVES Anywhere-made Default Tables</sup>") +
  coord_flip() +
  theme_bw(base_size = 14) +
  guides(fill = "none", color = "none") +
  theme(panel.border = element_rect(fill = NA, color = "#373737"),
        panel.grid.minor = element_blank(), plot.title.position = "plot",
        plot.title = element_markdown(size = 14, hjust = 0.5), 
        axis.title.x = element_markdown(size = 12),
        axis.text.y = element_markdown(size = 10)
        )

ggsave(gg, filename = "viz/crossbars.png", dpi = 500, width = 6, height = 6)
browseURL("viz/crossbars.png")
#  geom_violin(data = compare, mapping = aes(x = var, y = value, color = var, group = var))
  

# ggplot() +
#   geom_col(data = compare, mapping = aes(x = geoid, y = value, color = var, group = var)) +
#   facet_wrap(~var, ncol = 4)

# DATA8 ############################################

## PLOT 3 #################################################
data = read_rds("data8.rds") %>%
  filter(scenario %in% c(18:26,28, 29) ) %>%
  mutate(scenario = scenario %>% dplyr::recode_factor(
    "29" = "+vmtFractions...",
    "28" = "+fuels...",
    "26" = "+imCoverage",
    "25" = "+zoneMonthHour",
    "24" = "+AVFT",
    "23" = "+avgSpeedDistribution",
    "22" = "+sourceTypeAgeDistribution",
    "21" = "+roadTypeDistribution",
    "20" = "+sourceTypeYear",
    "19" = "+sourceTypeYearVMT",
    "18" = "Default"
  )) %>%
  mutate(sourcetype = sourcetype %>% dplyr::recode_factor(
    "62" = "Combo\nLong-haul\nTruck",
    "61" = "Combo\nShort-haul\nTruck",
    "54" = "Motor\nHome",
    "53" = "Single Unit\nLong-haul\nTruck",
    "52" = "Single Unit\nShort-haul\nTruck",
    "51" = "Refuse\nTruck",
    "43" = "School Bus",
    "42" = "Transit Bus",
    "41" = "Other Buses",
    "32" = "Light\nCommercial\nTruck",
    "31" = "Passenger\nTruck",
    "21" = "Passenger\nCar",
    "11" = "Motorcycle"
  ))

stat = data %>%
  group_by(scenario, sourcetype) %>%
  summarize(lower = quantile(emissions, probs = 0.25, na.rm = TRUE),
            estimate = quantile(emissions, probs = 0.50, na.rm = TRUE),
            upper = quantile(emissions, probs = 0.75, na.rm = TRUE)
  )



gg = ggplot() +
  geom_jitter(
    data = data, mapping = aes(
      x = factor(scenario), y = emissions, 
      color = factor(sourcetype), group = geoid), 
    height = 0
  ) +
  geom_crossbar(
    data = stat, mapping = aes(x = factor(scenario),
                               y = estimate, ymin = lower, ymax = upper,
                               fill = factor(sourcetype)),
    alpha = 0.5
  ) +
  facet_wrap(~factor(sourcetype), nrow = 3, scales = "free_x" ) +
  # geom_violin(
  #   data = data, mapping = aes(
  #     x = factor(sourcetype),
  #     y = emissions,
  #     group = geoid),
  #   trim = TRUE,
  #   alpha = 0.25
  # ) + 
  theme_bw(base_size = 14) +
  theme(panel.border = element_rect(fill = NA, color = "#373737"),
        panel.grid = element_blank(),
        axis.text.x = element_text(size = 9),
        strip.background = element_rect(fill = "#373737"),
        strip.text = element_text(color = "white")) +
  scale_fill_viridis(option = "plasma", discrete = TRUE, end = 0.9) +
  scale_color_viridis(option = "plasma", discrete = TRUE, end = 0.9) +
  scale_y_continuous(trans = "log",
                     labels = scales::label_number(scale_cut = scales::cut_si(""))) +
  guides(fill = "none", color = "none") +
  coord_flip() +
  labs(x = NULL, y = "Emissions Range (90% Range) (n = 10 counties)")

gg
ggsave(gg, filename = "viz/crossbars_sourcetype.png", dpi = 500, width = 10, height = 10)
browseURL("viz/crossbars_sourcetype.png")


# DATA16-ALL #########################################


## MAP 1 ##############################################



data = read_rds("data16_compare.rds") %>%
  filter(pollutant == 98, scenario %in% c(18) )

# counties = tigris::counties(state = "NY", cb = TRUE, resolution = "20m", year = 2022)
# 
# counties %>% 
#   select(geoid = GEOID, name = NAME, area_land = ALAND, geometry) %>%
#   saveRDS("shapes_counties.rds")

# counties = read_rds("shapes_counties.rds") %>%
#   left_join(by = "geoid", y= data %>% select(-name, -bucket), multiple = "all")

counties %>% filter(is.na(emissions))

# 36079
# 36119
ggplot() + 
  geom_sf(data = counties, mapping = aes(fill = emissions))

## PLOT 1 ##############################################

data = read_rds("data16_compare.rds") %>%
  filter(pollutant == 98, scenario %in% c(18, 29) ) %>%
  select(year, name, geoid, scenario, emissions) %>%
  distinct()

colors = viridis::plasma(n = 2, begin = 0.8, end = 0.2)
library(ggplot2)
gg1 = ggplot() + 
  geom_point(
    data = data, mapping = aes(x = emissions, y = reorder(name, emissions), color = factor(scenario)),
    size = 2, alpha = 0.8
  ) +
  scale_x_continuous(trans = "log", labels = scales::label_number(scale_cut = scales::cut_si("t"))) +
  scale_color_manual(values = colors, labels = c("Default\nInputs", "Custom\nInputs")) +
  #guides(color = "none") +
  labs(x = "CO2 Equivalent Emissions (tons)\n[natural log scaled]",
       y = NULL, color = "Scenario",
       title = "Difference in Emissions") +
  theme_bw(base_size = 14) +
  theme(panel.border = element_rect(fill = NA, color = "#373737"),
        panel.grid.minor = element_blank(),
        legend.position = "bottom")
gg1
ggsave(gg1, filename = "viz/differences.png", dpi = 500, width = 4, height = 9.5)
browseURL("viz/differences.png")
# data %>%
#   group_by(year, geoid) %>%
#   count() %>%
#   ungroup() %>%
#   arrange(desc(n))

# stat = data %>%
#   group_by(year, geoid) %>%
#   summarize(residual = emissions[scenario == 29] - emissions[scenario == 18], .groups = "drop")

# gg2 = ggplot() +
#   geom_density(
#     data = data, mapping = aes(x = emissions, group = scenario, fill = factor(scenario) ),
#     alpha = 0.5
#   ) +
#   scale_x_continuous(trans = "log", guide = "none") +
#   labs(y = NULL, x = NULL) +
#   theme(plot.margin = margin(0,0,0,0), legend.margin = margin(0,0,0,0))
# 

# ggpubr::ggarrange(
#   plotlist = list(gg2,gg1), ncol = 1, heights = c(2,5),
#   align = "hv", common.legend = TRUE, legend = "bottom")


## TABLE 2 ##############################################

library(dplyr)
library(readr)
library(tidyr)
library(purrr)
# Let's try to develop an R-squared for MOVES Anywhere
yhat = 18
y = 29
read_rds("data16_compare.rds") %>%
  filter(scenario %in% c(y, yhat)) %>%
  select(year, geoid, pollutant, scenario, emissions) %>%
  distinct() %>%
  pivot_wider(id_cols = c(year, geoid, pollutant),
              names_from = scenario, values_from = emissions, 
              names_prefix = "s") %>%
  rename(predicted = paste0("s", yhat), observed = paste0("s", y) ) %>%
  filter(!is.na(observed)) %>%
  group_by(pollutant) %>%
  summarize(lm(formula = observed ~ predicted ) %>% broom::glance()) %>%
  # The pollutants we can actually evaluate here are...
  filter(pollutant %in% c(2,3, 31, 33, 98, 100, 110))

  # group_by(pollutant) %>%
  # summarize(
  #   rss = sum( (predicted - observed)^2 ),
  #   tss = sum(  (observed - mean(observed))^2 ),
  #   n = n(),
  #   p = 1,
  #   r2 = 1 - rss / tss
  #   #adjr2 = (1 - r2) * (n - 1) / (n - p - 1)  
  # ) %>%
  # # The pollutants we can actually evaluate here are...
  # filter(pollutant %in% c(2,3, 31, 33, 98, 100, 110))

# DATA8-ALL ############################################

data = read_rds("data8_compare.rds") %>%
  filter(scenario %in% c(y, yhat)) %>%
  select(year, geoid, pollutant, scenario, emissions, sourcetype) %>%
  distinct() %>%
  pivot_wider(id_cols = c(year, geoid, pollutant, sourcetype),
              names_from = scenario, values_from = emissions, 
              names_prefix = "s") %>%
  rename(predicted = paste0("s",yhat), observed = paste0("s", y)) %>%
  filter(!is.na(observed), !is.na(predicted)) %>%
  #mutate(predicted = if_else(is.na(predicted), 0, predicted)) %>%
  # The pollutants we can actually evaluate here are...
  filter(pollutant %in% c(2,3, 31, 33, 98, 100, 110))

bind_rows(
  # Slope, accuracy, and error
  data %>% 
    group_by(pollutant) %>%
    summarize(lm(formula = observed ~ predicted ) %>% broom::glance()) %>%
    mutate(sourcetype = 0),
  data %>% 
    #  filter(pollutant == 98) %>%
    group_by(sourcetype, pollutant) %>%
    summarize(lm(formula = observed ~ predicted ) %>% broom::glance())
) %>%
  pivot_wider(id_cols = c(pollutant), names_from = sourcetype, values_from = r.squared) %>%
  mutate(across(-pollutant, .fns = ~round(.x, digits = 2)*100)) %>%
  write_csv("viz/r2.csv")

read_csv("viz/r2.csv")

# DATA1-ALL ################################################

data = read_rds("data1_compare.rds") %>%
  filter(scenario %in% c(y, yhat)) %>%
  select(year, geoid, pollutant, scenario, emissions, sourcetype, regclass, fueltype, roadtype) %>%
  distinct() %>%
  pivot_wider(id_cols = c(year, geoid, pollutant, sourcetype, regclass, fueltype, roadtype),
              names_from = scenario, values_from = emissions, 
              names_prefix = "s") %>%
  rename(predicted = paste0("s",yhat), observed = paste0("s", y)) %>%
  filter(!is.na(observed), !is.na(predicted)) %>%
  #mutate(predicted = if_else(is.na(predicted), 0, predicted)) %>%
  # The pollutants we can actually evaluate here are...
  filter(pollutant %in% c(2,3, 31, 33, 98, 100, 110))

bind_rows(
  # Slope, accuracy, and error
  data %>% 
    group_by(pollutant) %>%
    summarize(lm(formula = observed ~ predicted ) %>% broom::glance()) %>%
    mutate(sourcetype = 0),
  data %>% 
    #  filter(pollutant == 98) %>%
    group_by(sourcetype, pollutant) %>%
    summarize(lm(formula = observed ~ predicted ) %>% broom::glance())
) %>%
  pivot_wider(id_cols = c(pollutant), names_from = sourcetype, values_from = r.squared) %>%
  mutate(across(-pollutant, .fns = ~round(.x, digits = 2)*100)) %>%
  write_csv("viz/r2.csv")


read_csv("viz/r2.csv")

data %>% 
  filter(pollutant == 98) %>%
  group_by(fueltype, pollutant) %>%
  summarize(lm(formula = observed ~ predicted ) %>% broom::glance())

data %>% 
  filter(pollutant == 98) %>%
  group_by(regclass, pollutant) %>%
  summarize(lm(formula = observed ~ predicted ) %>% broom::glance())

data %>% 
  filter(pollutant == 98) %>%
  group_by(roadtype, pollutant) %>%
  summarize(lm(formula = observed ~ predicted) %>% broom::glance())



# 
# data %>% 
#   lm(formula = log(observed + 1) ~ log(predicted + 1) ) %>%
#   broom::glance()
# 
# data %>% 
#   lm(formula = sqrt(observed) ~ sqrt(predicted) ) %>%
#   broom::glance()
# 
# 
# ggplot() +
#   geom_point(
#     data = data, 
#     mapping = aes(x = observed, y = predicted, color = factor(geoid))
#   ) + 
#   scale_y_continuous(trans = "sqrt") +
#   scale_x_continuous(trans = "sqrt")


rm(list = ls())
