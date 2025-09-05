#!/usr/bin/env Rscript
# metar_fetch.R
# -------------------------------------------------------------------
# Fetch decoded METARs and append into:
#   • all_metars.csv (master, raw, append-only)
#   • all_metars_MM_YYYY.csv (monthly, raw, append-only)
#   • metar_log.txt
# -------------------------------------------------------------------

# ---------------- User Settings ----------------
STATIONS <- c(
  # Ontario (15)
  "CYER","CYAT","CYMO","CYPL","CYQT","CYAM","CYTS","CYSB","CYYB","CYOW",
  "CYGK","CYQG","CYVV","CYYZ","CYQA",
  # British Columbia (6)
  "CYVR","CYYJ","CYLW","CYXS","CYXT","CYQQ",
  # Alberta (4)
  "CYYC","CYEG","CYMM","CYQF",
  # Saskatchewan / Manitoba (4)
  "CYXE","CYQR","CYWG","CYBR",
  # Quebec (8)
  "CYUL","CYHU","CYQB","CYVO","CYUY","CYZV","CYBC","CYRJ",
  # Atlantic (6)
  "CYHZ","CYYG","CYQM","CYFC","CYYT","CYQY",
  # Territories / North (7)
  "CYXY","CYZF","CYFB","CYRT","CYBK","CYRB","CYCO"
)

MASTER_FILE <- "all_metars.csv"
LOG_FILE    <- "metar_log.txt"

# ---------------- Packages ----------------------
need <- c("httr","jsonlite","tibble","dplyr","lubridate")
missing <- need[!(need %in% rownames(installed.packages()))]
if(length(missing)) install.packages(missing,repos="https://cloud.r-project.org",quiet=TRUE)
suppressPackageStartupMessages({
  library(httr); library(jsonlite); library(tibble)
  library(dplyr); library(lubridate)
})

# ---------------- API Key -----------------------
api_key <- Sys.getenv("CHECKWX_API_KEY", unset=NA)
if(is.na(api_key) || nchar(api_key)==0){
  
}
if(is.na(api_key) || nchar(api_key)==0) stop("❌ No API key available")

# ---------------- Helpers -----------------------
`%||%` <- function(a,b) if(!is.null(a)) a else b
get_num <- function(d,n1,n2=NULL){
  if(n1%in%names(d)) as.numeric(d[[n1]])
  else if(!is.null(n2)&&n2%in%names(d)) as.numeric(d[[n2]])
  else NA
}
get_chr <- function(d,n){ if(n%in%names(d)) as.character(d[[n]]) else NA_character_ }

# ---------------- Fetch -------------------------
get_metar_row <- function(icao,key){
  url <- paste0("https://api.checkwx.com/metar/",icao,"/decoded")
  res <- VERB("GET",url=url,add_headers(`X-API-Key`=key))
  tryCatch(stop_for_status(res),error=function(e){ return(NULL) })
  parsed <- tryCatch(fromJSON(content(res,"text",encoding="UTF-8"),flatten=TRUE),error=function(e) NULL)
  if(is.null(parsed)||is.null(parsed$data)||nrow(parsed$data)<1) return(NULL)
  d <- parsed$data[1,,drop=FALSE]
  obs_utc <- tryCatch(ymd_hms(d$observed,tz="UTC"),error=function(e) NA)
  obs_loc <- if(!is.na(obs_utc)) with_tz(obs_utc,"America/Toronto") else NA
  f_utc <- Sys.time(); f_loc <- with_tz(f_utc,"America/Toronto")
  clouds <- NA_character_
  if("clouds"%in%names(d)&&length(d$clouds[[1]])>0){
    cl <- d$clouds[[1]]
    if(is.data.frame(cl)||is.list(cl)) clouds <- paste(paste(cl$code,cl$base$feet,"ft"),collapse="; ")
    else if(is.character(cl)) clouds <- paste(cl,collapse="; ")
  }
  tibble(
    icao=icao, observed_utc=obs_utc, observed_local=obs_loc,
    flight_category=get_chr(d,"flight_category"),
    temp_c=get_num(d,"temperature.celsius","temperature"),
    dewpoint_c=get_num(d,"dewpoint.celsius","dewpoint"),
    rh_percent=get_num(d,"humidity.percent","humidity"),
    wind_dir_deg=get_num(d,"wind.degrees","wind"),
    wind_kts=get_num(d,"wind.speed_kts","wind_kts"),
    vis_m=get_num(d,"visibility.meters","visibility"),
    altimeter_hg=get_num(d,"barometer.hg","altimeter_hg"),
    conditions=get_chr(d,"conditions.text"),
    clouds=clouds,
    raw_text=get_chr(d,"raw_text"),
    fetched_at_utc=f_utc, fetched_at_local=f_loc
  )
}

fetch_all <- function(stns,key) bind_rows(lapply(stns,function(s)get_metar_row(s,key)))

write_csvs <- function(df,master){
  now_local <- with_tz(Sys.time(),"America/Toronto")
  month_file <- sprintf("all_metars_%s.csv",format(now_local,"%m_%Y"))
  if(file.exists(master)) write.table(df,master,sep=",",row.names=FALSE,col.names=FALSE,append=TRUE) else write.csv(df,master,row.names=FALSE)
  if(file.exists(month_file)) write.table(df,month_file,sep=",",row.names=FALSE,col.names=FALSE,append=TRUE) else write.csv(df,month_file,row.names=FALSE)
  cat(sprintf("[%s] Added %d rows\n",format(now_local,"%Y-%m-%d %H:%M:%S %Z"),nrow(df)),file=LOG_FILE,append=TRUE)
}

# ---------------- Main --------------------------
res <- fetch_all(STATIONS,api_key)
if(!is.null(res)&&nrow(res)>0){ write_csvs(res,MASTER_FILE); print(res) } else message("⚠️ No METARs returned")
