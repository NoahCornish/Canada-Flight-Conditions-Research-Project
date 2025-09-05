# 🌤️ Canadian METAR Flight Conditions Research Project

## Overview
This project automates the **collection, analysis, and visualization of decoded METAR reports** for a **nationwide network of 50 Canadian airports** using the [CheckWX API](https://www.checkwx.com/).  

The long-term goal is to build a **national climatology of aviation flight conditions** by tracking the frequency and duration of **LIFR, IFR, MVFR, and VFR** categories.  
With METARs collected **every 30 minutes**, this dataset will grow into a valuable resource for studying **aviation safety, weather patterns, regional differences, and long-term climate variability**.

---

## Airports Covered

### Ontario Core (15 airports)
- **Far North / Hudson Bay:** CYER (Fort Severn), CYAT (Attawapiskat), CYMO (Moosonee)  
- **Northern Hubs:** CYPL (Pickle Lake), CYQT (Thunder Bay), CYAM (Sault Ste. Marie)  
- **Northeast Corridor:** CYTS (Timmins), CYSB (Sudbury), CYYB (North Bay)  
- **Eastern Ontario:** CYOW (Ottawa), CYGK (Kingston)  
- **Southwest Ontario:** CYQG (Windsor), CYVV (Wiarton)  
- **Greater Toronto Area:** CYYZ (Toronto Pearson)  
- **Central Ontario:** CYQA (Muskoka)  

### Western Canada
- CYVR (Vancouver), CYLW (Kelowna), CYXS (Prince George), CYXD (Edmonton City Centre), CYYC (Calgary), CYQR (Regina), CYXE (Saskatoon), CYWG (Winnipeg)

### Northern Canada
- CYZF (Yellowknife), CYFB (Iqaluit), CYRT (Rankin Inlet), CYRB (Resolute Bay), CYCB (Cambridge Bay), CYXY (Whitehorse), CYDA (Dawson City)

### Quebec & Atlantic Canada
- CYUL (Montréal–Trudeau), CYQB (Quebec City), CYHU (St-Hubert), CYVO (Val-d’Or), CYJN (St-Jean)  
- CYHZ (Halifax), CYQY (Sydney), CYQM (Moncton), CYFC (Fredericton), CYYG (Charlottetown), CYYT (St. John’s), CYDF (Deer Lake), CYJT (Stephenville)  

*(Ontario core + additional 35 airports = 50 total for nationwide climatology)*

## 🗺️ National Coverage Map
Below is the current spread of 50 airports included in the project:

![Canadian METAR Network](charts/airport_map.png)

---

## How It Works

### Data Pipeline
- **Fetch:** `metar_fetch.R` pulls decoded METARs (flight category, temps, dew point, humidity, wind, altimeter, raw text).  
- **Clean:** `clean_metars.R` deduplicates reports into `clean_metars.csv`.  
- **Archive:** Master file (`all_metars.csv`) plus monthly archives (`metars_YYYY_MM.csv`).  
- **Analyze:** `analysis.R` computes daily averages, summaries, and time spent in each flight category.  
- **Visualize:** `charts.R` generates PNG charts of airport statistics in `charts/`.

### Outputs
- `daily_averages.csv` – daily means of temp, dewpoint, humidity, wind  
- `flight_summary.csv` – counts of VFR/MVFR/IFR/LIFR per airport  
- `time_daily.csv`, `time_alltime.csv`, `time_overall.csv` – time spent in each flight condition  
- `charts/*.png` – bar charts of flight categories per airport  

---

## Automation
- **Fetch Workflow:** Runs **every 30 minutes** to collect fresh METARs.  
- **Analysis Workflow:** Runs **daily at 01:30 ET** to update summaries and charts.  
- **GitHub Actions:** Commits new CSVs and PNGs back into the repo automatically.

---

## Research Scope
ICAO/FAA flight category thresholds:
- **LIFR:** ceilings < 500 ft AGL or vis < 1 SM  
- **IFR:** ceilings 500–1,000 ft AGL or vis 1–3 SM  
- **MVFR:** ceilings 1,000–3,000 ft AGL or vis 3–5 SM  
- **VFR:** ceilings > 3,000 ft AGL and vis > 5 SM  

This project allows:
- Daily and seasonal statistics for each airport  
- Comparisons between northern, coastal, and urban airports  
- Identification of fog-prone or IFR-heavy regions  
- Multi-year climatology for aviation operations across Canada  

---

## Project Roadmap
| Timeline         | Goals                                                                 |
|------------------|----------------------------------------------------------------------|
| **2–3 months**   | Preliminary national comparisons, short-term anomalies               |
| **6 months**     | Seasonal tendencies across provinces                                 |
| **12 months**    | Full annual climatology, strong airport-to-airport comparisons       |
| **1+ years**     | Multi-year climatology, rare event statistics, aviation safety trends |

---

## Future Directions
- 📊 Interactive dashboards of flight conditions by airport and region  
- 🗺️ Enhanced maps with wind overlays and trend animations  
- 📂 Public datasets for aviation and climate researchers  
- 🤝 Collaboration with training schools, regulators, and climatology researchers  
- 🌐 Expansion to **all major Canadian airports** with real-time web visualization  

---

## Key Point
This is a **long-term national research project**.  
Ontario provided the **testbed**, but now the scope is **all of Canada** with 50 representative airports.  
Every day of data collected strengthens the climatology for **aviation safety, weather awareness, and long-term research**.
