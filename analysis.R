#!/usr/bin/env Rscript
# metar_analysis.R
# -------------------------------------------------------------
# Reads cleaned METAR data from GitHub and computes:
#   1. Daily averages (temp, dew point, RH, wind)
#   2. Flight condition counts (all-time)
#   3. Overall percentages of each condition
#   4. Time-in-category estimates (daily + all-time + overall)
# Saves results as CSVs in working directory.
# -------------------------------------------------------------

# ---------------- Packages ----------------------
need <- c("dplyr","lubridate","readr","tidyr")
missing <- need[!(need %in% rownames(installed.packages()))]
if (length(missing)) {
  install.packages(missing, repos="https://cloud.r-project.org")
}
suppressPackageStartupMessages({
  library(dplyr); library(lubridate); library(readr); library(tidyr)
})
# ------------------------------------------------

# ---------------- Data Input --------------------
URL <- "https://raw.githubusercontent.com/NoahCornish/METAR-Study/main/clean_metars.csv"

df <- suppressMessages(read_csv(URL, show_col_types = FALSE))

# Ensure datetime is parsed
df <- df %>%
  mutate(observed_utc = ymd_hms(observed_utc, quiet=TRUE, tz="UTC"),
         date = as.Date(observed_utc)) %>%
  filter(!is.na(observed_utc))
# ------------------------------------------------

# ---------------- 1. Daily Averages ----------------
daily_averages <- df %>%
  group_by(icao, date) %>%
  summarise(
    avg_temp_c = mean(temp_c, na.rm=TRUE),
    avg_dewpoint_c = mean(dewpoint_c, na.rm=TRUE),
    avg_rh = mean(rh_percent, na.rm=TRUE),
    avg_wind_kts = mean(wind_kts, na.rm=TRUE),
    .groups="drop"
  )

write_csv(daily_averages, "daily_averages.csv")
# ---------------------------------------------------

# ---------------- 2. Flight Summary Counts ---------
flight_summary <- df %>%
  group_by(icao, flight_category) %>%
  summarise(count = n(), .groups="drop")

write_csv(flight_summary, "flight_summary.csv")
# ---------------------------------------------------

# ---------------- 3. Overall Percentages -----------
overall_percentages <- df %>%
  count(flight_category) %>%
  mutate(percent = 100 * n / sum(n))

# Ensure all categories appear
all_cats <- c("VFR","MVFR","IFR","LIFR")
overall_percentages <- overall_percentages %>%
  right_join(tibble(flight_category=all_cats), by="flight_category") %>%
  replace_na(list(n=0, percent=0))

write_csv(overall_percentages, "overall_percentages.csv")
# ---------------------------------------------------

# ---------------- 4. Time in Category --------------
time_df <- df %>%
  arrange(icao, observed_utc) %>%
  group_by(icao) %>%
  mutate(next_time = lead(observed_utc),
         duration_mins = as.numeric(difftime(next_time, observed_utc, units="mins"))) %>%
  ungroup()

# Handle last obs of the day → extend to midnight
time_df <- time_df %>%
  mutate(date = as.Date(observed_utc),
         midnight = as.POSIXct(paste0(date, " 23:59:59"), tz="UTC"),
         duration_mins = ifelse(is.na(duration_mins),
                                as.numeric(difftime(midnight, observed_utc, units="mins")),
                                duration_mins))

# Daily per ICAO with totals + %
time_daily <- time_df %>%
  group_by(icao, date, flight_category) %>%
  summarise(hours = sum(duration_mins, na.rm=TRUE)/60, .groups="drop") %>%
  group_by(icao, date) %>%
  mutate(total_hours = sum(hours, na.rm=TRUE),
         percent = 100 * hours / total_hours) %>%
  ungroup()

write_csv(time_daily, "time_daily.csv")

# All-time per ICAO with totals + %
time_alltime <- time_df %>%
  group_by(icao, flight_category) %>%
  summarise(hours = sum(duration_mins, na.rm=TRUE)/60, .groups="drop") %>%
  group_by(icao) %>%
  mutate(total_hours = sum(hours, na.rm=TRUE),
         percent = 100 * hours / total_hours) %>%
  ungroup()

write_csv(time_alltime, "time_alltime.csv")


# Overall (all airports combined)
time_overall <- time_df %>%
  group_by(flight_category) %>%
  summarise(hours = sum(duration_mins, na.rm=TRUE)/60, .groups="drop") %>%
  mutate(percent = 100 * hours / sum(hours))

# Ensure all categories included
time_overall <- right_join(tibble(flight_category=all_cats), time_overall, by="flight_category") %>%
  replace_na(list(hours=0, percent=0))

write_csv(time_overall, "time_overall.csv")
# ---------------------------------------------------

message("✅ Analysis complete. CSVs written: daily_averages.csv, flight_summary.csv, overall_percentages.csv, time_daily.csv, time_alltime.csv, time_overall.csv")
