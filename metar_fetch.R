#!/usr/bin/env Rscript
# metar_fetch.R
# Fetch decoded METARs for multiple ICAOs and save:
#   1) A growing "monster file" (saved_METARs.csv)
#   2) Monthly archive files (metars_YYYY_MM.csv)
#
# API key comes from env var CHECKWX_API_KEY
# ------------------------------------------------------------------------------

# ----------------------- User settings ----------------------
STATIONS <- c(
  # --- Far North / James Bay ---
  "CYMO", "CYPL",
  # --- Northeast Corridor ---
  "CYTS", "CYSB", "CYYB",
  # --- Northwest Ontario ---
  "CYQT",
  # --- Eastern Ontario ---
  "CYOW", "CYGK",
  # --- Southwest Ontario ---
  "CYQG", "CYXU", "CYHM",
  # --- GTA ---
  "CYYZ", "CYTZ", "CYOO",
  # --- Central Ontario ---
  "CYQA"
)

OUTFILE_MONSTER <- "saved_METARs.csv"   # master archive
APPEND_MODE     <- TRUE
# ------------------------------------------------------------

# Install missing packages quietly, then load
need <- c("httr", "jsonlite", "tibble", "dplyr", "lubridate")
missing <- need[!(need %in% rownames(installed.packages()))]
if (length(missing)) {
  message("Installing packages: ", paste(missing, collapse = ", "))
  install.packages(missing, quiet = TRUE)
}
suppressPackageStartupMessages({
  library(httr)
  library(jsonlite)
  library(tibble)
  library(dplyr)
  library(lubridate)
})

# Pull API key from env
api_key <- Sys.getenv("CHECKWX_API_KEY", unset = NA)
if (is.na(api_key) || nchar(api_key) == 0) {
  stop("No API key found. Set env var CHECKWX_API_KEY first, e.g.\n",
       'Sys.setenv(CHECKWX_API_KEY = "YOUR_KEY_HERE")', call. = FALSE)
}

# Helper: safe extract
`%||%` <- function(a, b) if (!is.null(a)) a else b

# Fetch one station
get_metar_row <- function(icao, key) {
  url <- paste0("https://api.checkwx.com/metar/", icao, "/decoded")
  res <- VERB("GET", url = url, add_headers(`X-API-Key` = key))

  tryCatch({ stop_for_status(res) }, error = function(e) {
    warning(sprintf("Request failed for %s: %s", icao, conditionMessage(e)))
    return(tibble(
      icao            = icao,
      observed_utc    = as.POSIXct(NA),
      flight_category = NA_character_,
      temp_c          = NA_real_,
      dewpoint_c      = NA_real_,
      rh_percent      = NA_real_,
      wind_dir_deg    = NA_real_,
      wind_kts        = NA_real_,
      vis_m           = NA_real_,
      altimeter_hg    = NA_real_,
      raw_text        = NA_character_,
      fetched_at_utc  = as.POSIXct(Sys.time(), tz = "UTC")
    ))
  })

  txt <- content(res, "text", encoding = "UTF-8")
  parsed <- tryCatch(jsonlite::fromJSON(txt, flatten = TRUE), error = function(e) NULL)

  if (is.null(parsed) || is.null(parsed$data) || nrow(parsed$data) < 1) {
    warning(sprintf("No data returned for %s", icao))
    return(tibble(
      icao            = icao,
      observed_utc    = as.POSIXct(NA),
      flight_category = NA_character_,
      temp_c          = NA_real_,
      dewpoint_c      = NA_real_,
      rh_percent      = NA_real_,
      wind_dir_deg    = NA_real_,
      wind_kts        = NA_real_,
      vis_m           = NA_real_,
      altimeter_hg    = NA_real_,
      raw_text        = NA_character_,
      fetched_at_utc  = as.POSIXct(Sys.time(), tz = "UTC")
    ))
  }

  d <- parsed$data[1, , drop = FALSE]

  get_num <- function(name_primary, name_alt = NULL) {
    if (name_primary %in% names(d)) as.numeric(d[[name_primary]])
    else if (!is.null(name_alt) && name_alt %in% names(d)) as.numeric(d[[name_alt]])
    else NA_real_
  }
  get_chr <- function(name) if (name %in% names(d)) as.character(d[[name]]) else NA_character_

  tibble(
    icao            = get_chr("icao") %||% icao,
    observed_utc    = if ("observed" %in% names(d))
                        tryCatch(lubridate::ymd_hms(d$observed, tz = "UTC"),
                                 error = function(e) as.POSIXct(NA))
                      else as.POSIXct(NA),
    flight_category = get_chr("flight_category"),
    temp_c          = get_num("temperature.celsius", "temperature"),
    dewpoint_c      = get_num("dewpoint.celsius", "dewpoint"),
    rh_percent      = get_num("humidity.percent", "humidity"),
    wind_dir_deg    = get_num("wind.degrees", "wind"),
    wind_kts        = get_num("wind.speed_kts", "wind_kts"),
    vis_m           = get_num("visibility.meters", "visibility"),
    altimeter_hg    = get_num("barometer.hg", "altimeter_hg"),
    raw_text        = get_chr("raw_text"),
    fetched_at_utc  = as.POSIXct(Sys.time(), tz = "UTC")
  )
}

# Fetch all stations
fetch_all <- function(stations, key) {
  rows <- lapply(stations, function(s) {
    tryCatch(get_metar_row(s, key), error = function(e) {
      warning(sprintf("Error parsing %s: %s", s, conditionMessage(e)))
      tibble(
        icao            = s,
        observed_utc    = as.POSIXct(NA),
        flight_category = NA_character_,
        temp_c          = NA_real_,
        dewpoint_c      = NA_real_,
        rh_percent      = NA_real_,
        wind_dir_deg    = NA_real_,
        wind_kts        = NA_real_,
        vis_m           = NA_real_,
        altimeter_hg    = NA_real_,
        raw_text        = NA_character_,
        fetched_at_utc  = as.POSIXct(Sys.time(), tz = "UTC")
      )
    })
  })
  bind_rows(rows) |> arrange(icao, desc(observed_utc))
}

# Write to monster + monthly archive (only new unique METARs)
write_csvs <- function(df, monster_file, append_mode = TRUE) {
  col_order <- c(
    "icao","observed_utc","flight_category","temp_c","dewpoint_c","rh_percent",
    "wind_dir_deg","wind_kts","vis_m","altimeter_hg","raw_text","fetched_at_utc"
  )
  df <- df[, col_order]

  # ---- Monster file ----
  if (append_mode && file.exists(monster_file)) {
    existing <- tryCatch(read.csv(monster_file, stringsAsFactors = FALSE), error = function(e) NULL)
    if (!is.null(existing) && nrow(existing)) {
      # Compare against existing, only keep new rows
      existing_key <- paste(existing$icao, existing$observed_utc, existing$raw_text)
      new_key <- paste(df$icao, df$observed_utc, df$raw_text)
      df <- df[!new_key %in% existing_key, ]
      df <- bind_rows(existing, df)
    }
  }
  utils::write.csv(df, monster_file, row.names = FALSE)
  message(sprintf("Updated monster file: %s", monster_file))

  # ---- Monthly archive ----
  month_stamp <- format(Sys.time(), "%Y_%m")
  monthly_file <- sprintf("metars_%s.csv", month_stamp)

  if (file.exists(monthly_file)) {
    existing <- tryCatch(read.csv(monthly_file, stringsAsFactors = FALSE), error = function(e) NULL)
    if (!is.null(existing) && nrow(existing)) {
      existing_key <- paste(existing$icao, existing$observed_utc, existing$raw_text)
      new_key <- paste(df$icao, df$observed_utc, df$raw_text)
      df <- df[!new_key %in% existing_key, ]
      df <- bind_rows(existing, df)
    }
  }
  utils::write.csv(df, monthly_file, row.names = FALSE)
  message(sprintf("Updated monthly file: %s", monthly_file))
}

# --------------------------- Main ---------------------------
results <- fetch_all(STATIONS, api_key)
write_csvs(results, OUTFILE_MONSTER, append_mode = APPEND_MODE)

# Preview
print(results)
