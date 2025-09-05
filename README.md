# 🌤️ Ontario METAR Flight Conditions Research Project

## 📌 Overview
This project automates the **collection and analysis of decoded METAR reports** for a carefully selected set of **Ontario airports** using the [CheckWX API](https://www.checkwx.com/).  
The goal is to build a **long-term climatology of aviation flight conditions** by tracking the frequency of **LIFR, IFR, MVFR, and VFR** categories across the province.  
With METARs collected **every 10 minutes**, this dataset will grow into a valuable resource for studying aviation safety, weather patterns, and regional variability.

## ✈️ Airports Covered
Fifteen airports were chosen to maximize **geographic spread** across Ontario — balancing **remote northern airports**, **regional hubs**, and **major population centers**:

- **Far North / Hudson Bay**:  
  CYER – Fort Severn, CYMO – Moosonee  
- **Remote North Hub**:  
  CYPL – Pickle Lake  
- **Northwest Ontario**:  
  CYQT – Thunder Bay, CYAM – Sault Ste. Marie  
- **Northeast Corridor**:  
  CYTS – Timmins, CYSB – Sudbury, CYYB – North Bay  
- **Eastern Ontario**:  
  CYOW – Ottawa, CYGK – Kingston  
- **Southwest Ontario**:  
  CYQG – Windsor, CYVV – Wiarton  
- **Greater Toronto Area**:  
  CYYZ – Toronto Pearson  
- **Central Ontario**:  
  CYQA – Muskoka  

## ⚙️ How It Works
- **Data Collection**  
  [`metar_fetch.R`](metar_fetch.R) calls the CheckWX API on schedule. Extracted fields include ICAO, observation time, flight category, temperature, dewpoint, humidity, wind, altimeter, and raw METAR.  

- **Storage**  
  - `all_metars.csv` — master archive of every METAR pulled  
  - `clean_metars.csv` — deduplicated dataset, keeping only meaningful changes  
  - `metars_YYYY_MM.csv` — monthly archives  
  - `metar_log.txt` — log of workflow runs  

- **Automation**  
  GitHub Actions workflows fetch and clean data, commit updates, and generate daily summaries and charts.  

- **Visualization**  
  - [`map.html`](map.html) shows flight categories on a **live interactive map**  
  - [`index.html`](index.html) provides a clean dashboard with wind arrows, temperatures, and raw METARs  

## 🎯 Research Scope
Flight categories are tracked using ICAO/FAA definitions:

- **LIFR** – ceilings < 500 ft AGL or visibility < 1 SM  
- **IFR** – ceilings 500–1,000 ft AGL or visibility 1–3 SM  
- **MVFR** – ceilings 1,000–3,000 ft AGL or visibility 3–5 SM  
- **VFR** – ceilings > 3,000 ft AGL and visibility > 5 SM  

This dataset enables:  
- Daily, monthly, and seasonal statistics  
- Airport-to-airport comparisons  
- Fog-prone vs. clear-air region analysis  
- Long-term climatology of Ontario flight conditions  

## 📊 Research Timeline
| Collected Time | What Can Be Studied | Confidence |
|----------------|---------------------|------------|
| 2–3 months | Preliminary airport comparisons, anomaly detection, short-term patterns | Early signals |
| 6 months | Seasonal tendencies (e.g., winter IFR vs summer VFR) | Moderate |
| 12 months | Full annual climatology, robust airport & seasonal comparisons | Strong |
| Beyond 1 year | Multi-year trends, rare events, climate variability | Very strong |

## 🔮 Future Directions
Planned expansions and improvements:  
- 📈 Interactive dashboards with charts of VFR/MVFR/IFR/LIFR frequencies  
- 🗺️ Real-time maps with wind arrows and overlays  
- 📂 Public dataset releases for researchers and aviation enthusiasts  
- 🤝 Collaborations with aviation programs, climatology studies, and safety planning  
- 🔗 Expansion to include airports across all of Canada for a **national climatology dataset**
