#!/usr/bin/env Rscript
# clean_metars.R
# -------------------------------------------------------------------
# Cleans the METAR archives by removing duplicates.
# Deduplication rule:
#   • Keep a new row only if one of these fields changes:
#     observed_utc, flight_category, temp_c, dewpoint_c,
#     altimeter_hg, wind_dir_deg, wind_kts
#
# Input:
#   - all_metars.csv
#   - all_metars_MM_YYYY.csv
#
# Output:
#   - clean_metars.csv
#   - clean_metars_MM_YYYY.csv
#   - clean_log.txt
# -------------------------------------------------------------------

# ---------------- Packages ----------------------
need <- c("dplyr","lubridate","readr")
missing <- need[!(need %in% rownames(installed.packages()))]
if (length(missing)) {
  install.packages(missing, repos="https://cloud.r-project.org", quiet=TRUE)
}
suppressPackageStartupMessages({
  library(dplyr); library(lubridate); library(readr)
})
# ------------------------------------------------

# ---------------- Files -------------------------
MASTER_FILE <- "all_metars.csv"
CLEAN_MASTER_FILE <- "clean_metars.csv"

month_file <- sprintf("all_metars_%s.csv", format(with_tz(Sys.time(),"America/Toronto"),"%m_%Y"))
CLEAN_MONTH_FILE <- sprintf("clean_metars_%s.csv", format(with_tz(Sys.time(),"America/Toronto"),"%m_%Y"))

LOG_FILE <- "clean_log.txt"
# ------------------------------------------------

# ---------------- Helpers -----------------------
safe_parse_time <- function(x, tz="UTC") {
  suppressWarnings({
    parsed <- ymd_hms(x, tz=tz, quiet=TRUE)
    if (all(is.na(parsed))) parsed <- parse_date_time(x, orders=c("Ymd HMS","Ymd HM","Ymd H"), tz=tz, quiet=TRUE)
    parsed
  })
}

clean_file <- function(file, outfile) {
  if (!file.exists(file)) {
    message("⚠️ File not found: ", file)
    return(NULL)
  }
  
  df <- suppressWarnings(read_csv(file, show_col_types = FALSE))
  before <- nrow(df)
  
  if (before == 0) {
    message("⚠️ File empty: ", file)
    return(NULL)
  }
  
  # Ensure important columns exist
  needed_cols <- c("icao","observed_utc","flight_category",
                   "temp_c","dewpoint_c","altimeter_hg",
                   "wind_dir_deg","wind_kts")
  for (col in needed_cols) {
    if (!col %in% names(df)) df[[col]] <- NA
  }
  
  # Parse times
  df$observed_utc <- safe_parse_time(df$observed_utc, tz="UTC")
  
  # Deduplicate based only on important fields
  df_clean <- df %>%
    arrange(icao, observed_utc) %>%
    group_by(icao) %>%
    distinct(icao, observed_utc, flight_category, temp_c, dewpoint_c,
             altimeter_hg, wind_dir_deg, wind_kts, .keep_all = TRUE) %>%
    ungroup()
  
  after <- nrow(df_clean)
  write_csv(df_clean, outfile)
  
  list(file=file, outfile=outfile, before=before, after=after, removed=before-after)
}
# ------------------------------------------------

# ---------------- Main --------------------------
results <- list()
results[["master"]]  <- clean_file(MASTER_FILE, CLEAN_MASTER_FILE)
results[["monthly"]] <- clean_file(month_file, CLEAN_MONTH_FILE)

# Log
now_str <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")
for (res in results) {
  if (!is.null(res)) {
    log_line <- sprintf("[%s] Cleaned %s → %s — before: %d, after: %d, removed: %d\n",
                        now_str, res$file, res$outfile, res$before, res$after, res$removed)
    cat(log_line, file=LOG_FILE, append=TRUE)
    message(log_line)
  }
}
# ------------------------------------------------
