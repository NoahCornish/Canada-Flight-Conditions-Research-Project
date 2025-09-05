# 🌤️ METAR Flight Conditions Research Project

## 📌 Overview
This project automates the **collection and analysis of decoded METAR reports** for selected Ontario airports using the [CheckWX API](https://www.checkwx.com/).  
The goal is to track the **occurrence of flight categories** — **LIFR, IFR, MVFR, VFR** — over time to compare airports, assess trends, and build a long-term climatology of flying conditions in the province.

Data collection and processing are fully automated with **R scripts** and **GitHub Actions**, updating every **10 minutes**.

---

## ✈️ Airports Covered
Fifteen airports were chosen to maximize **geographic spread** across Ontario:

- **Far North:**  
  - CYER – Fort Severn (Hudson Bay, northernmost community)  
  - CYMO – Moosonee (James Bay access)  
  - CYPL – Pickle Lake (remote hub for northern communities)  

- **Northwest Ontario:**  
  - CYQT – Thunder Bay (largest NW Ontario hub)  
  - CYAM – Sault Ste. Marie (Lake Superior mid-point)  

- **Northeast Corridor:**  
  - CYTS – Timmins (mining/forestry hub)  
  - CYSB – Sudbury (largest Northern Ontario city)  
  - CYYB – North Bay (transition between north & south)  

- **Eastern Ontario:**  
  - CYOW – Ottawa (national capital)  
  - CYGK – Kingston (Lake Ontario east-end)  

- **Southwest / Central Ontario:**  
  - CYQG – Windsor (border city, Detroit proximity)  
  - CYOS – Owen Sound (Georgian Bay region, Lake Huron influence)  
  - CYHM – Hamilton (southern Ontario cargo hub)  

- **Greater Toronto Area:**  
  - CYYZ – Toronto Pearson (busiest airport in Canada)  
  - CYTZ – Billy Bishop (downtown Toronto, lake effect contrast)  

- **Central Ontario:**  
  - CYQA – Muskoka (recreational/cottage country)  

This mix balances **major hubs**, **regional centers**, and **remote northern airports** to capture Ontario’s full climatological diversity.

---

## ⚙️ How It Works
- **Script:** [`metar_fetch.R`](metar_fetch.R) queries the CheckWX API every 10 minutes.  
- **Data Extracted:** ICAO, timestamp, flight category, temperature, humidity, wind, visibility, altimeter, and raw METAR.  
- **Storage:** Appends results to `saved_METARs.csv` (with monthly archives). Duplicate entries (`icao + observed_utc`) are filtered.  
- **Automation:** A GitHub Actions workflow handles scheduling, data commits, and notifications to the maintainer.  

---

## 🎯 Research Scope
Flight categories are tracked using FAA/ICAO definitions:  
- **LIFR** – ceilings < 500 ft or visibility < 1 SM  
- **IFR** – ceilings 500–1,000 ft or visibility 1–3 SM  
- **MVFR** – ceilings 1,000–3,000 ft or visibility 3–5 SM  
- **VFR** – ceilings > 3,000 ft and visibility > 5 SM  

The dataset will support:  
- Daily and seasonal statistics  
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
This is a **long-term climatology project**.  
- Full yearly insights require at least **12 months** of data.  
- Meaningful early comparisons begin after **2–3 months**.  
- With each additional year, the dataset becomes **more powerful and credible** for aviation safety, training, and research.  
