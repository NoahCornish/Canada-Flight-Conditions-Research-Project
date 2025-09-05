#!/usr/bin/env Rscript
# metar_fetch.R
# -------------------------------------------------------------------
# Always fetch decoded METARs for multiple Ontario ICAOs and save them into:
#  1. Monster archive: saved_METARs.csv (all time, raw)
#  2. Monthly archives: metars_YYYY_MM.csv
#  3. Run log: metar_log.txt
#
# Time handling:
#  - observed_utc + observed_local (America/Toronto)
#  - fetched_at_utc + fetched_at_local (America/Toronto)
# -------------------------------------------------------------------

# ---------------- User Settings ----------------
STATIONS <- c(
  "CYER", # Fort Severn
  "CYAT", # Attawapiskat
  "CYMO", # Moosonee
  "CYPL", # Pickle Lake
  "CYQT", # Thunder Bay
  "CYAM", # Sault Ste. Marie
  "CYTS", # Timmins
  "CYSB", # Sudbury
  "CYYB", # North Bay
  "CYOW", # Ottawa
  "CYGK", # Kingston
  "CYQG", # Windsor
  "CYVV", # Wiarton / Owen Sound
  "CYYZ", # Toronto Pearson
  "CYQA"  # Muskoka
)

OUTFILE_MONSTER <- "saved_METARs.csv"
LOGFILE         <- "metar_log.txt"
# ------------------------------------------------

# ---------------- Packages ----------------------
need <- c("httr","jsonlite","tibble","dplyr","lubridate")
missing <- need[!(need %in% rownames(installed.packages()))]
if (length(missing)) {
  install.packages(missing, repos="https://cloud.r-project.org", quiet=TRUE)
}
suppressPackageStartupMessages({
  library(httr); library(jsonlite); library(tibble)
  library(dplyr); library(lubridate)
})
# ------------------------------------------------

# ---------------- API Key -----------------------
# Prefer GitHub secret if present, else fallback to hardcoded key
api_key <- Sys.getenv("CHECKWX_API_KEY", unset = NA)
if (is.na(api_key) || nchar(api_key) == 0) {
  api_key <- "c772ec8a139a4abcab171a94c0"   # <<< fallback hardcoded API key
}
if (is.na(api_key) || nchar(api_key) == 0) {
  stop("❌ No API key available. Set CHECKWX_API_KEY in GitHub or edit script.")
}
# ------------------------------------------------

# ---------------- Helpers -----------------------
`%||%` <- function(a, b) if (!is.null(a)) a else b
get_num <- function(d, name_primary, name_alt=NULL) {
  if (name_primary %in% names(d)) as.numeric(d[[name_primary]])
  else if (!is.null(name_alt) && name_alt %in% names(d)) as.numeric(d[[name_alt]])
  else NA_real_
}
get_chr <- function(d, name) {
  if (name %in% names(d)) as.character(d[[name]]) else NA_character_
}
# ------------------------------------------------

# ---------------- Station Fetch -----------------
get_metar_row <- function(icao, key) {
  url <- paste0("https://api.checkwx.com/metar/", icao, "/decoded")
  res <- VERB("GET", url = url, add_headers(`X-API-Key` = key))
  
  tryCatch({ stop_for_status(res) }, error=function(e) {
    warning(sprintf("Request failed for %s: %s", icao, conditionMessage(e)))
    return(NULL)
  })
  
  txt <- content(res, "text", encoding="UTF-8")
  parsed <- tryCatch(fromJSON(txt, flatten=TRUE), error=function(e) NULL)
  if (is.null(parsed) || is.null(parsed$data) || nrow(parsed$data) < 1) {
    warning(sprintf("No data for %s", icao))
    return(NULL)
  }
  
  d <- parsed$data[1, , drop=FALSE]
  
  observed_utc <- if ("observed" %in% names(d)) {
    tryCatch(ymd_hms(d$observed, tz="UTC"), error=function(e) as.POSIXct(NA))
  } else { as.POSIXct(NA) }
  
  observed_local <- if (!is.na(observed_utc)) {
    with_tz(observed_utc, "America/Toronto")
  } else { as.POSIXct(NA) }
  
  fetched_utc   <- Sys.time()
  fetched_local <- with_tz(fetched_utc, "America/Toronto")
  
  # Clouds: handle both list-of-lists and flat character
  clouds <- NA_character_
  if ("clouds" %in% names(d) && length(d$clouds[[1]]) > 0) {
    cl <- d$clouds[[1]]
    if (is.data.frame(cl) || is.list(cl)) {
      clouds <- paste(sapply(seq_len(nrow(cl)), function(i) {
        paste(cl$code[i], cl$base$feet[i], "ft")
      }), collapse="; ")
    } else if (is.character(cl)) {
      clouds <- paste(cl, collapse="; ")
    }
  }
  
  tibble(
    icao              = get_chr(d,"icao") %||% icao,
    observed_utc      = observed_utc,
    observed_local    = observed_local,
    flight_category   = get_chr(d,"flight_category"),
    temp_c            = get_num(d,"temperature.celsius","temperature"),
    dewpoint_c        = get_num(d,"dewpoint.celsius","dewpoint"),
    rh_percent        = get_num(d,"humidity.percent","humidity"),
    wind_dir_deg      = get_num(d,"wind.degrees","wind"),
    wind_kts          = get_num(d,"wind.speed_kts","wind_kts"),
    vis_m             = get_num(d,"visibility.meters","visibility"),
    altimeter_hg      = get_num(d,"barometer.hg","altimeter_hg"),
    conditions        = get_chr(d,"conditions.text"),
    clouds            = clouds,
    raw_text          = get_chr(d,"raw_text"),
    fetched_at_utc    = fetched_utc,
    fetched_at_local  = fetched_local
  )
}
# ------------------------------------------------

# ---------------- Bulk Fetch --------------------
fetch_all <- function(stations, key) {
  rows <- lapply(stations, function(s) get_metar_row(s, key))
  bind_rows(rows)
}
# ------------------------------------------------

# ---------------- Write CSVs --------------------
write_csvs <- function(df, outfile_monster) {
  now_local <- with_tz(Sys.time(), "America/Toronto")
  month_file <- sprintf("metars_%s.csv", format(now_local,"%Y_%m"))
  
  # Always append new rows
  if (file.exists(outfile_monster)) {
    write.table(df, outfile_monster, sep=",", row.names=FALSE,
                col.names=FALSE, append=TRUE)
  } else {
    write.csv(df, outfile_monster, row.names=FALSE)
  }
  
  if (file.exists(month_file)) {
    write.table(df, month_file, sep=",", row.names=FALSE,
                col.names=FALSE, append=TRUE)
  } else {
    write.csv(df, month_file, row.names=FALSE)
  }
  
  # Log
  added <- nrow(df)
  now_str <- format(now_local, "%Y-%m-%d %H:%M:%S %Z")
  log_line <- sprintf("[%s] Added %d METAR(s)\n", now_str, added)
  cat(log_line, file=LOGFILE, append=TRUE)
  
  message(sprintf("✅ Added %d rows", added))
}
# ------------------------------------------------

# ---------------- Main --------------------------
results <- fetch_all(STATIONS, api_key)
if (!is.null(results) && nrow(results) > 0) {
  write_csvs(results, OUTFILE_MONSTER)
  print(results)
} else {
  message("⚠️ No METARs returned this run.")
}
# ------------------------------------------------
