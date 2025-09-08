# Canada METAR Flight Conditions Research Project  

[![⛅ METAR ⛈️](https://github.com/NoahCornish/METAR-Study/actions/workflows/metar.yml/badge.svg)](https://github.com/NoahCornish/METAR-Study/actions/workflows/metar.yml)  

---

## 🌍 Overview  
This project automates the **collection, analysis, and visualization of decoded METAR reports** for a national network of **50 Canadian airports**, tracked continuously through a GitHub-hosted pipeline.  

The central goal is to build a comprehensive, open climatology of **aviation flight conditions** (VFR, MVFR, IFR, LIFR) across Canada. This dataset and workflow provide insights into aviation safety, regional weather dynamics, and long-term climate variability.  

The repository integrates:  
- **Automated ingestion** (`metar_fetch.R`) of decoded METAR reports every 30 minutes (xx:00 and xx:30) via GitHub Actions.  
- **Cleaning & deduplication** (`clean_metars.R`) to produce curated archives.  
- **Analytical routines** (`analysis.R`) for averages, categorical frequencies, and time allocation metrics.  
- **Automated visual outputs** (`charts.R`, `chart_readme.R`) with maps and graphics generated daily.  
- **Front-end visualizations** (`index.html`, `map.html`) to explore the dataset interactively.  

---

## 🛰️ Airport Network  

The project monitors **50 airports across Canada**, chosen to capture the full diversity of climate regions, operational contexts, and flight environments. This includes **remote northern outposts, regional connectors, and major international hubs**.  

### Ontario (15)  
- CYER – Fort Severn  
- CYAT – Attawapiskat  
- CYMO – Moosonee  
- CYPL – Pickle Lake  
- CYQT – Thunder Bay  
- CYAM – Sault Ste. Marie  
- CYTS – Timmins  
- CYSB – Sudbury  
- CYYB – North Bay  
- CYOW – Ottawa/Macdonald–Cartier International  
- CYGK – Kingston  
- CYQG – Windsor  
- CYVV – Wiarton  
- CYYZ – Toronto Pearson International  
- CYQA – Muskoka  

### British Columbia (6)  
- CYVR – Vancouver International  
- CYYJ – Victoria International  
- CYLW – Kelowna International  
- CYXS – Prince George  
- CYXT – Terrace/Kitimat  
- CYQQ – Comox  

### Alberta (4)  
- CYYC – Calgary International  
- CYEG – Edmonton International  
- CYMM – Fort McMurray  
- CYQF – Red Deer  

### Saskatchewan & Manitoba (4)  
- CYXE – Saskatoon  
- CYQR – Regina  
- CYWG – Winnipeg International  
- CYBR – Brandon  

### Quebec (8)  
- CYUL – Montréal–Trudeau International  
- CYHU – Montréal/Saint-Hubert  
- CYQB – Québec City Jean Lesage International  
- CYVO – Val-d’Or  
- CYUY – Rouyn-Noranda  
- CYZV – Sept-Îles  
- CYBC – Baie-Comeau  
- CYRJ – Roberval  

### Atlantic Canada (6)  
- CYHZ – Halifax Stanfield International  
- CYYG – Charlottetown  
- CYQM – Moncton  
- CYFC – Fredericton  
- CYYT – St. John’s International  
- CYQY – Sydney (NS)  

### Northern Territories & Arctic (7)  
- CYXY – Whitehorse (Yukon)  
- CYZF – Yellowknife (NWT)  
- CYFB – Iqaluit (Nunavut)  
- CYRT – Rankin Inlet (Nunavut)  
- CYBK – Baker Lake (Nunavut)  
- CYRB – Resolute Bay (Nunavut)  
- CYCO – Kugluktuk (Nunavut)  

---

## ⚙️ Data Pipeline  

1. **Fetch METARs**  
   - Script: [`metar_fetch.R`]  
   - Retrieves decoded reports including temperature, dewpoint, humidity, wind, altimeter, visibility, conditions, cloud layers, and raw text.  

2. **Clean & Deduplicate**  
   - Script: [`clean_metars.R`]  
   - Filters for significant meteorological changes, removing redundant entries.  

3. **Archive Data**  
   - `all_metars.csv` – full master dataset.  
   - `metars_YYYY_MM.csv` – monthly archives for easier distribution.  

4. **Analyze**  
   - [`analysis.R`] produces:  
     - `daily_averages.csv` — meteorological means per day.  
     - `flight_summary.csv` — flight-category frequencies by airport.  
     - `time_daily.csv`, `time_alltime.csv`, `time_overall.csv` — time allocation by flight condition.  

5. **Visualize**  
   - `charts.R` creates airport-level bar charts.  
   - `chart_readme.R` generates overview maps for documentation.  

6. **Front-End Views**  
   - `index.html` — card-style dashboard of airport conditions.  
   - `map.html` — regional interactive map of flight conditions.  

All steps run automatically via GitHub Actions, ensuring daily updates and reproducibility.  

---

## 📊 Research Applications  

Using ICAO-defined thresholds for flight categories (e.g., **LIFR < 500 ft AGL or < 1 SM visibility**), this project enables:  

- **Daily & seasonal analyses** of weather-driven flight restrictions.  
- **Cross-provincial comparisons** of aviation weather variability.  
- **Identification of fog-prone and IFR-heavy airports.**  
- **Multi-year climatologies** to support aviation planning and safety policy.  
- **Climate research** linking long-term shifts to regional aviation impacts.  

---

## 📅 Research Milestones  

| Timeline       | Research Outputs                                         |
|----------------|----------------------------------------------------------|
| 2–3 months     | Station-level comparisons, anomaly detection             |
| 6 months       | Seasonal climatologies across provinces                  |
| 12 months      | Full annual cycle climatology and inter-airport analysis |
| Multi-year     | Detection of long-term shifts and climate-driven trends  |

---

## 🚀 Future Directions  

- **Interactive dashboards** for real-time exploration by region.  
- **Spatial interpolation maps** showing condition fields across provinces.  
- **Data portal** for public, aviation, and academic access.  
- **Collaborative partnerships** with aviation authorities and weather services.  

---

## 📌 Closing Note  

This repository is more than a data pipeline: it is a **national research platform** for Canadian aviation climatology. By combining automation, reproducible workflows, and open data outputs, it bridges aviation safety, geography, and climate science.  

The outputs are designed to serve **pilots, aviation operators, researchers, and the public** alike — advancing both practical understanding and scientific inquiry.  

*(See GitHub Actions tabs for live run logs and automatic updates.)*  
