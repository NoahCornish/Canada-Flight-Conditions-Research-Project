#!/usr/bin/env Rscript
# clean_metars.R
# -------------------------------------------------------------------
# Cleans all_metars.csv and produces:
#   • clean_metars.csv (deduped)
#   • clean_metars_MM_YYYY.csv (deduped monthly)
#   • clean_log.txt
# -------------------------------------------------------------------

need <- c("dplyr","lubridate","readr")
missing <- need[!(need %in% rownames(installed.packages()))]
if(length(missing)) install.packages(missing,repos="https://cloud.r-project.org",quiet=TRUE)
suppressPackageStartupMessages({ library(dplyr); library(lubridate); library(readr) })

MASTER_FILE <- "all_metars.csv"
CLEAN_MASTER_FILE <- "clean_metars.csv"
now_local <- with_tz(Sys.time(),"America/Toronto")
CLEAN_MONTH_FILE <- sprintf("clean_metars_%s.csv",format(now_local,"%m_%Y"))
LOG_FILE <- "clean_log.txt"

safe_parse_time <- function(x,tz="UTC"){
  suppressWarnings({
    parsed <- ymd_hms(x,tz=tz,quiet=TRUE)
    if(all(is.na(parsed))) parsed <- parse_date_time(x,orders=c("Ymd HMS","Ymd HM","Ymd H"),tz=tz,quiet=TRUE)
    parsed
  })
}

clean_file <- function(file,outfile){
  if(!file.exists(file)) return(NULL)
  df <- suppressWarnings(read_csv(file,show_col_types=FALSE))
  before <- nrow(df)
  if(before==0) return(NULL)
  for(c in c("icao","observed_utc","raw_text","fetched_at_utc")) if(!c%in%names(df)) df[[c]] <- NA
  df$observed_utc <- safe_parse_time(df$observed_utc,"UTC")
  df$fetched_at_utc <- safe_parse_time(df$fetched_at_utc,"UTC")
  df_clean <- df %>% arrange(icao,desc(observed_utc),desc(fetched_at_utc)) %>% distinct(icao,observed_utc,raw_text,.keep_all=TRUE)
  write_csv(df_clean,outfile)
  list(file=file,outfile=outfile,before=before,after=nrow(df_clean),removed=before-nrow(df_clean))
}

res1 <- clean_file(MASTER_FILE,CLEAN_MASTER_FILE)
res2 <- clean_file(MASTER_FILE,CLEAN_MONTH_FILE)
now <- format(Sys.time(),"%Y-%m-%d %H:%M:%S %Z")
for(r in list(res1,res2)){ if(!is.null(r)) cat(sprintf("[%s] Cleaned %s → %s (before %d → after %d, removed %d)\n",now,r$file,r$outfile,r$before,r$after,r$removed),file=LOG_FILE,append=TRUE) }
