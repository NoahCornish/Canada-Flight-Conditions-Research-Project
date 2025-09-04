#!/usr/bin/env Rscript
# metar_fetch.R
# Fetch decoded METAR for multiple ICAOs (single row per station) and write a CSV.
# Option A: Append + de-duplicate by (icao, observed_utc), keeping the newest fetch.
# - API key is read from env var CHECKWX_API_KEY
# - Edit STATIONS to your list (CYMO, CYYB, CYOO, CYOW, CYQG)
# ------------------------------------------------------------------------------

# ----------------------- User settings ----------------------
STATIONS     <- c("CYMO", "CYYB", "CYOO", "CYOW", "CYQG")
OUTFILE      <- "saved_METARs.csv"   # write to repo root (or set an absolute path)
APPEND_MODE  <- TRUE                 # append + de-dupe by (icao, observed_utc)
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

# Helper: safe extract for possibly-missing fields
`%||%` <- function(a, b) if (!is.null(a)) a else b

# Fetch one station, return a one-row tibble (no clouds)
get_metar_row <- function(icao, key) {
  url <- paste0("https://api.checkwx.com/metar/", icao, "/decoded")
  res <- VERB("GET", url = url, add_headers(`X-API-Key` = key))

  # HTTP status handling
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
      raw_text        = NA_character_
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
      raw_text        = NA_character_
    ))
  }

  d <- parsed$data[1, , drop = FALSE]  # single-row data.frame with dot-named cols

  get_num <- function(name_primary, name_alt = NULL) {
    if (name_primary %in% names(d)) as.numeric(d[[name_primary]])
    else if (!is.null(name_alt) && name_alt %in% names(d)) as.numeric(d[[name_alt]])
    else NA_real_
  }
  get_chr <- function(name) if (name %in% names(d)) as.character(d[[name]]) else NA_character_

  tibble(
    icao            = get_chr("icao") %||% icao,
    observed_utc    = if ("observed" %in% names(d))
                        tryCatch(lubridate::ymd_hms(d$observed, tz = "UTC"), error = function(e) as.POSIXct(NA))
                      else as.POSIXct(NA),
    flight_category = get_chr("flight_category"),
    temp_c          = get_num("temperature.celsius", "temperature"),
    dewpoint_c      = get_num("dewpoint.celsius", "dewpoint"),
    rh_percent      = get_num("humidity.percent", "humidity"),
    wind_dir_deg    = get_num("wind.degrees", "wind"),
    wind_kts        = get_num("wind.speed_kts", "wind_kts"),
    vis_m           = get_num("visibility.meters", "visibility"),
    altimeter_hg    = get_num("barometer.hg", "altimeter_hg"),
    raw_text        = get_chr("raw_text")
  )
}

# Fetch all stations and bind rows
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
        raw_text        = NA_character_
      )
    })
  })
  bind_rows(rows) |>
    arrange(icao, desc(observed_utc))
}

# Write CSV (append + de-duplicate by station & observation time)
write_csv_safe <- function(df, outfile, append_mode = TRUE) {
  # Ensure consistent column order/types
  col_order <- c(
    "icao","observed_utc","flight_category","temp_c","dewpoint_c","rh_percent",
    "wind_dir_deg","wind_kts","vis_m","altimeter_hg","raw_text","fetched_at_utc"
  )
  # Add fetched_at_utc if missing
  if (!"fetched_at_utc" %in% names(df)) df$fetched_at_utc <- as.POSIXct(NA)

  if (append_mode && file.exists(outfile)) {
    existing <- tryCatch(read.csv(outfile, stringsAsFactors = FALSE), error = function(e) NULL)
    if (!is.null(existing) && nrow(existing)) {
      # Coerce date-time columns back to POSIXct
      if ("observed_utc" %in% names(existing))
        existing$observed_utc <- as.POSIXct(existing$observed_utc, tz = "UTC")
      if ("fetched_at_utc" %in% names(existing))
        existing$fetched_at_utc <- as.POSIXct(existing$fetched_at_utc, tz = "UTC")
      else
        existing$fetched_at_utc <- as.POSIXct(NA)

      # Bind, sort, and de-duplicate keeping the most recent fetch for each (icao, observed_utc)
      df <- dplyr::bind_rows(existing, df) |>
        dplyr::arrange(icao, dplyr::desc(observed_utc), dplyr::desc(fetched_at_utc)) |>
        dplyr::distinct(icao, observed_utc, .keep_all = TRUE)
    }
  }

  # Reorder columns (add missing if previously absent)
  missing_cols <- setdiff(col_order, names(df))
  for (mc in missing_cols) df[[mc]] <- NA
  df <- df[, col_order]

  utils::write.csv(df, outfile, row.names = FALSE)
  message(sprintf("Wrote %d row(s) to %s", nrow(df), outfile))
}

# --------------------------- Main ---------------------------
results <- fetch_all(STATIONS, api_key)
results$fetched_at_utc <- as.POSIXct(Sys.time(), tz = "UTC")
write_csv_safe(results, OUTFILE, append_mode = APPEND_MODE)

# Optional: print preview to console
print(results)
