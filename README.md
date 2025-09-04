# 🌤️ METAR Flight Conditions Research Project

## 📌 Overview
This project automates the **collection and analysis of decoded METAR reports** for selected Ontario airports using the [CheckWX API](https://www.checkwx.com/).  
The goal is to track the **occurrence of flight categories** — **LIFR, IFR, MVFR, VFR** — over time to compare airports, assess trends, and build a long-term climatology of flying conditions in the province.

Data collection and processing are fully automated with **R scripts** and **GitHub Actions**, updating every **10 minutes**.

---

## ✈️ Airports Covered
Fifteen airports were chosen to maximize **geographic spread** across Ontario:  

- **Far North:** CYMO (Moosonee), CYPL (Pickle Lake)  
- **Northeast Corridor:** CYTS (Timmins), CYSB (Sudbury), CYYB (North Bay)  
- **Northwest:** CYQT (Thunder Bay)  
- **Eastern Ontario:** CYOW (Ottawa), CYGK (Kingston)  
- **Southwest Ontario:** CYQG (Windsor), CYXU (London), CYHM (Hamilton)  
- **Greater Toronto Area:** CYYZ (Toronto Pearson), CYTZ (Billy Bishop), CYOO (Oshawa)  
- **Central Ontario:** CYQA (Muskoka)  

This mix balances **major hubs**, **regional centers**, and **remote northern airports**.

---

## ⚙️ How It Works
- **Script:** [`metar_fetch.R`](metar_fetch.R) calls the API every 10 minutes.  
- **Data:** Extracts ICAO, time, flight category, temp/dewpoint, humidity, wind, visibility, altimeter, and raw METAR.  
- **Storage:** Appends results to `saved_METARs.csv` with duplicates removed (`icao + observed_utc`).  
- **Automation:** A GitHub Actions workflow runs on schedule, commits new data, and notifies the maintainer.  

---

## 🎯 Research Scope
Flight categories are tracked using FAA/ICAO definitions:  
- **LIFR** – ceilings < 500 ft or visibility < 1 SM  
- **IFR** – ceilings 500–1,000 ft or visibility 1–3 SM  
- **MVFR** – ceilings 1,000–3,000 ft or visibility 3–5 SM  
- **VFR** – ceilings > 3,000 ft and visibility > 5 SM  

The dataset will support:  
- Daily/seasonal stats  
- Airport-to-airport comparisons  
- Identifying fog/low visibility patterns  
- Long-term climatology and aviation research  

---

## 📊 Research Timeline
| Time Collected | What Can Be Studied | Confidence |
|----------------|---------------------|------------|
| **2–3 months** | Early airport comparisons, short-term trends, anomaly detection | Preliminary |
| **6 months**   | Seasonal tendencies (e.g., winter vs summer IFR) | Moderate |
| **12 months**  | Full annual climatology, robust airport & seasonal comparisons | Strong |
| **Beyond 1 year** | Multi-year trends, rare event statistics, climate/operational shifts | Very strong — dataset grows in reliability over time |

---

## 🔑 Key Point
This is a **long-term project**. Full yearly climatology requires at least **12 months** of data, but meaningful patterns will start emerging after **2–3 months**. With each additional year, the dataset becomes **more powerful and credible** for aviation safety, training, and research.
