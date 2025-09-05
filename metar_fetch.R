#!/usr/bin/env Rscript
# metar_fetch.R
# Fetch decoded METAR for multiple ICAOs (single row per station) and write CSV outputs.
# - API key is read from env var CHECKWX_API_KEY
# - Writes:
#   1. Monster archive: saved_METARs.csv (all time, deduped)
#   2. Monthly archives: metars_YYYY_MM.csv
#   3. Run log: metar_log.txt
# - Time Handling:
#   • observed_utc + observed_local (America/Toronto)
#   • fetched_at_utc + fetched_at_local (America/Toronto)
# ------------------------------------------------------------------------------
# NOTE: This script is verbose and broken into sections for clarity.
# ------------------------------------------------------------------------------

# ----------------------- User settings ----------------------
# Ontario Airports – Balanced Geographic Spread (15 total)
STATIONS <- c(
  # --- Far North / Hudson Bay ---
  "CYER", # Fort Severn – northernmost, Hudson Bay
  "CYMO", # Moosonee – James Bay access

  # --- Remote North Hub ---
  "CYPL", # Pickle Lake – northern hub

  # --- Northwest Ontario ---
  "CYQT", # Thunder Bay – NW anchor
  "CYAM", # Sault Ste. Marie – Lake Superior mid-point

  # --- Northeast Corridor ---
  "CYTS", # Timmins – NE mining/forestry hub
  "CYSB", # Sudbury – largest Northern Ontario city
  "CYYB", # North Bay – north/south transition

  # --- Eastern Ontario ---
  "CYOW", # Ottawa – national capital
  "CYGK", # Kingston – Lake Ontario east-end

  # --- Southwest Ontario ---
  "CYQG", # Windsor – Detroit border, lake-effect
  "CYOS", # Owen Sound – Lake Huron region

  # --- Greater Toronto Area ---
  "CYYZ", # Toronto Pearson – GTA anchor

  # --- Central Ontario / Cottage Country ---
  "CYQA", # Muskoka – recreational region

  # --- Special Contrast ---
  "CYTZ"  # Billy Bishop – downtown Toronto, lake effect
)

OUTFILE_MONSTER <- "saved_METARs.csv"   # Master archive
LOGFILE         <- "metar_log.txt"      # Run log
APPEND_MODE     <- TRUE                 # Append + dedupe mode
# ------------------------------------------------------------

# ---------------- Package Handling --------------------------
need <- c("httr","jsonlite","tibble","dplyr","lubridate")
missing <- need[!(need %in% rownames(installed.packages()))]
if (length(missing)) {
  message("Installing missing packages: ", paste(missing, collapse=", "))
  install.packages(missing, repos="https://cloud.r-project.org", quiet=TRUE)
}
suppressPackageStartupMessages({
  library(httr)
  library(jsonlite)
  library(tibble)
  library(dplyr)
  library(lubridate)
})

# ---------------- API Key Handling --------------------------
api_key <- Sys.getenv("CHECKWX_API_KEY", unset = NA)
if (is.na(api_key) || nchar(api_key) == 0) {
  stop("No API key found. Set env var CHECKWX_API_KEY first.")
}

# ---------------- Utility Functions -------------------------
# Null coalescing helper
`%||%` <- function(a, b) if (!is.null(a)) a else b

# Numeric extractor with fallback
get_num <- function(d, name_primary, name_alt=NULL) {
  if (name_primary %in% names(d)) as.numeric(d[[name_primary]])
  else if (!is.null(name_alt) && name_alt %in% names(d)) as.numeric(d[[name_alt]])
  else NA_real_
}

# Character extractor with fallback
get_chr <- function(d, name) {
  if (name %in% names(d)) as.character(d[[name]]) else NA_character_
}

# ---------------- Station Fetch Function --------------------
get_metar_row <- function(icao, key) {
  url <- paste0("https://api.checkwx.com/metar/", icao, "/decoded")
  res <- VERB("GET", url = url, add_headers(`X-API-Key` = key))

  # HTTP status handling
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

  # Observed UTC + local conversion
  observed_utc <- if ("observed" %in% names(d)) {
    tryCatch(ymd_hms(d$observed, tz="UTC"), error=function(e) as.POSIXct(NA))
  } else { as.POSIXct(NA) }

  observed_local <- if (!is.na(observed_utc)) {
    with_tz(observed_utc, "America/Toronto")
  } else { as.POSIXct(NA) }

  # Fetch time
  fetched_utc   <- Sys.time()
  fetched_local <- with_tz(fetched_utc, "America/Toronto")

  # Build tibble
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
    raw_text          = get_chr(d,"raw_text"),
    fetched_at_utc    = fetched_utc,
    fetched_at_local  = fetched_local
  )
}

# ---------------- Bulk Fetch Function -----------------------
fetch_all <- function(stations, key) {
  rows <- lapply(stations, function(s) {
    tryCatch(get_metar_row(s, key), error=function(e) {
      warning(sprintf("Error parsing %s: %s", s, conditionMessage(e)))
      NULL
    })
  })
  bind_rows(rows)
}

# ---------------- Write CSVs ------------------------
write_csvs <- function(df, outfile_monster, append_mode=TRUE) {
  if (nrow(df) == 0) return()

  # Ensure consistent columns
  col_order <- c("icao","observed_utc","observed_local",
                 "flight_category","temp_c","dewpoint_c","rh_percent",
                 "wind_dir_deg","wind_kts","vis_m","altimeter_hg",
                 "raw_text","fetched_at_utc","fetched_at_local")

  # Append mode: merge with existing and dedupe
  if (append_mode && file.exists(outfile_monster)) {
    existing <- tryCatch(read.csv(outfile_monster, stringsAsFactors=FALSE), error=function(e) NULL)
    if (!is.null(existing) && nrow(existing)) {
      existing$observed_utc    <- as.POSIXct(existing$observed_utc, tz="UTC")
      existing$fetched_at_utc  <- as.POSIXct(existing$fetched_at_utc, tz="UTC")
      existing$observed_local  <- with_tz(existing$observed_utc,"America/Toronto")
      existing$fetched_at_local<- with_tz(existing$fetched_at_utc,"America/Toronto")
      df <- bind_rows(existing, df) |>
        arrange(icao, desc(observed_utc), desc(fetched_at_utc)) |>
        distinct(icao, observed_utc, raw_text, .keep_all=TRUE)
    }
  }

  # Reorder columns
  missing_cols <- setdiff(col_order, names(df))
  for (mc in missing_cols) df[[mc]] <- NA
  df <- df[, col_order]

  # Write monster file
  write.csv(df, outfile_monster, row.names=FALSE)

  # Monthly file
  now_local <- with_tz(Sys.time(), "America/Toronto")
  month_file <- sprintf("metars_%s.csv", format(now_local,"%Y_%m"))
  if (file.exists(month_file)) {
    existing <- tryCatch(read.csv(month_file, stringsAsFactors=FALSE), error=function(e) NULL)
    if (!is.null(existing) && nrow(existing)) {
      existing$observed_utc    <- as.POSIXct(existing$observed_utc, tz="UTC")
      existing$fetched_at_utc  <- as.POSIXct(existing$fetched_at_utc, tz="UTC")
      existing$observed_local  <- with_tz(existing$observed_utc,"America/Toronto")
      existing$fetched_at_local<- with_tz(existing$fetched_at_utc,"America/Toronto")
      df <- bind_rows(existing, df) |>
        arrange(icao, desc(observed_utc), desc(fetched_at_utc)) |>
        distinct(icao, observed_utc, raw_text, .keep_all=TRUE)
    }
  }
  write.csv(df, month_file, row.names=FALSE)

  # Log file entry
  added <- nrow(df)
  now_str <- format(now_local, "%Y-%m-%d %H:%M:%S %Z")
  log_line <- sprintf("[%s] Added %d unique METAR(s)\n", now_str, added)
  cat(log_line, file=LOGFILE, append=TRUE)

  message(sprintf("Wrote %d rows to %s and %s", nrow(df), outfile_monster, month_file))
}

# --------------------------- Main ---------------------------
results <- fetch_all(STATIONS, api_key)
write_csvs(results, OUTFILE_MONSTER, append_mode=APPEND_MODE)

# Optional console preview
print(results)
