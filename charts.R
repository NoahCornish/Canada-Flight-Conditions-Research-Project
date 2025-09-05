#!/usr/bin/env Rscript
# charts.R
# -------------------------------------------------------------
# Reads the time_alltime.csv file and generates bar charts
# showing hours spent in each flight category for every ICAO.
# -------------------------------------------------------------

# ---------------- Packages ----------------------
need <- c("ggplot2","readr","dplyr")
missing <- need[!(need %in% rownames(installed.packages()))]
if (length(missing)) {
  install.packages(missing, repos="https://cloud.r-project.org")
}
suppressPackageStartupMessages({
  library(ggplot2); library(readr); library(dplyr)
})
# ------------------------------------------------

# ---------------- Data --------------------------
time_alltime <- read_csv("time_alltime.csv", show_col_types = FALSE)

# Ensure flight_category is ordered nicely
time_alltime$flight_category <- factor(
  time_alltime$flight_category,
  levels = c("VFR","MVFR","IFR","LIFR")
)

# Make sure charts folder exists
if (!dir.exists("charts")) dir.create("charts")

# ---------------- Individual Charts -------------
unique_icaos <- unique(time_alltime$icao)

for (icao in unique_icaos) {
  df <- filter(time_alltime, icao == !!icao)
  
  p <- ggplot(df, aes(x=flight_category, y=hours, fill=flight_category)) +
    geom_col(show.legend = FALSE) +
    scale_fill_manual(values=c("VFR"="#2ecc71","MVFR"="#3498db",
                               "IFR"="#e74c3c","LIFR"="#8e44ad")) +
    labs(title=paste("All-Time Hours in Each Flight Category:", icao),
         x="Flight Category", y="Hours") +
    theme_minimal(base_size = 14)
  
  ggsave(filename = paste0("charts/", icao, "_alltime.png"),
         plot = p, width = 7, height = 5)
}

# ---------------- Combined Faceted Chart --------
p_all <- ggplot(time_alltime, aes(x=flight_category, y=hours, fill=flight_category)) +
  geom_col(show.legend = FALSE) +
  scale_fill_manual(values=c("VFR"="#2ecc71","MVFR"="#3498db",
                             "IFR"="#e74c3c","LIFR"="#8e44ad")) +
  facet_wrap(~icao, scales="free_y") +
  labs(title="All-Time Hours in Each Flight Category (All ICAOs)",
       x="Flight Category", y="Hours") +
  theme_minimal(base_size = 12)

ggsave(filename = "charts/all_airports_alltime.png",
       plot = p_all, width = 14, height = 10)
# ------------------------------------------------

message("✅ Charts generated in 'charts/' folder")
