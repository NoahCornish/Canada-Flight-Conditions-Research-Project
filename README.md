# 🌤️ Ontario METAR Flight Conditions Research Project

## 📌 Overview
This project automates the **collection and analysis of decoded METAR reports** for a carefully selected set of **Ontario airports** using the [CheckWX API](https://www.checkwx.com/).  

The primary goal is to build a **long-term climatology of aviation flight conditions** by tracking the frequency of **LIFR, IFR, MVFR, and VFR** categories across the province.  
With METARs collected **every 10 minutes**, this dataset will grow into a powerful resource for studying aviation safety, weather patterns, and regional variability.

---

## ✈️ Airports Covered
Fifteen airports were chosen to maximize **geographic spread** across Ontario — balancing **remote northern airports**, **regional hubs**, and **major population centers**:

- **Far North / Hudson Bay**  
  - CYER – Fort Severn (northernmost, Hudson Bay)  
  - CYMO – Moosonee (James Bay access point)  

- **Remote North Hub**  
  - CYPL – Pickle Lake (northern hub)  

- **Northwest Ontario**  
  - CYQT – Thunder Bay (regional anchor)  
  - CYAM – Sault Ste. Marie (Lake Superior midpoint)  

- **Northeast Corridor**  
  - CYTS – Timmins (mining/forestry hub)  
  - CYSB – Sudbury (largest Northern Ontario city)  
  - CYYB – North Bay (north/south transition point)  

- **Eastern Ontario**  
  - CYOW – Ottawa (national capital)  
  - CYGK – Kingston (Lake Ontario east-end)  

- **Southwest Ontario**  
  - CYQG – Windsor (Detroit border, lake-effect)  
  - CYVV – Wiarton (Lake Huron region)  

- **Greater Toronto Area**  
  - CYYZ – Toronto Pearson (Canada’s busiest airport)  

- **Central Ontario**  
  - CYQA – Muskoka (cottage/recreational region)  

---

## ⚙️ How It Works
- **Data Collection:**  
  - [`metar_fetch.R`](metar_fetch.R) calls the CheckWX API every 10 minutes.  
  - Extracted data includes: ICAO, time (UTC + local EDT/EST), flight category, temperature, dewpoint, humidity, wind, visibility, altimeter, and raw METAR.  

- **Storage:**  
  - **Master file:** `saved_METARs.csv` (all-time archive, deduplicated by `(icao + observed_utc + raw_text)`)  
  - **Monthly files:** `metars_YYYY_MM.csv` (organized archives for easier analysis)  
  - **Log file:** `metar_log.txt` (tracks each run and unique METARs added)  

- **Automation:**  
  - A GitHub Actions workflow runs on schedule (every 10 minutes).  
  - Data is committed back to the repository automatically.  
  - Notifications are posted to GitHub Issues for monitoring.  

- **Visualization:**  
  - [`map.html`](map.html) displays current flight conditions on a **live interactive map**.  
  - Airports are shown as **colored dots** (VFR green, MVFR blue, IFR red, LIFR purple).  
  - Popups display temperature, wind, and the raw METAR.  

---

## 🎯 Research Scope
Flight categories are tracked using ICAO/FAA definitions:

- **LIFR** – ceilings < 500 ft AGL or visibility < 1 SM  
- **IFR** – ceilings 500–1,000 ft AGL or visibility 1–3 SM  
- **MVFR** – ceilings 1,000–3,000 ft AGL or visibility 3–5 SM  
- **VFR** – ceilings > 3,000 ft AGL and visibility > 5 SM  

This dataset will enable:
- Daily, monthly, and seasonal statistics  
- Airport-to-airport comparisons  
- Analysis of **fog-prone vs clear-air regions**  
- A long-term **climatology of Ontario flight conditions**  

---

## 📊 Research Timeline
| Time Collected | What Can Be Studied | Confidence |
|----------------|---------------------|------------|
| **2–3 months** | Preliminary airport comparisons, anomaly detection, short-term patterns | Early signals |
| **6 months**   | Seasonal tendencies (e.g., winter IFR vs summer VFR) | Moderate |
| **12 months**  | Full annual climatology, robust airport & seasonal comparisons | Strong |
| **Beyond 1 year** | Multi-year trends, rare events, climate variability, operational impacts | Very strong — dataset grows in reliability and value |

---

## 🔮 Future Directions
As this project matures, possible next steps include:
- 📈 **Statistical Dashboards**: Interactive charts of VFR/MVFR/IFR/LIFR frequencies by airport, month, or season.  
- 🗺️ **Enhanced Maps**: Real-time visualizations with wind arrows, weather overlays, and trend layers.  
- 📂 **Public Dataset**: Curated CSVs or databases for researchers and aviation enthusiasts.  
- 🤝 **Collaborations**: Integration with aviation training programs, climatology studies, or safety planning initiatives.  
- 🔗 **Expansion**: Adding more airports beyond Ontario, or including airports from other provinces for national-level climatology.  

---

## 🔑 Key Point
This is a **long-term research project**.  
A full **annual climatology** requires at least **12 months of data**, but **meaningful insights** begin emerging after just **2–3 months**.  

With each additional year, the dataset becomes more **powerful, reliable, and useful** for aviation research, safety, and climatology.
