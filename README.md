# 🌤️ METAR Flight Conditions Research Project

## 📌 Overview
This repository automates the **collection and analysis of decoded METAR reports** for a selected set of Canadian airports.  
The purpose is to study the **occurrence of different flight categories** — **LIFR, IFR, MVFR, and VFR** — over time and generate statistics that can be used to compare airports, assess trends, and explore flight safety conditions.

This project is particularly focused on:
- **Automating METAR data collection** using the [CheckWX API](https://www.checkwx.com/)  
- **Saving observations** into a continuously updated CSV file  
- **Classifying flight conditions** for each airport at each observation  
- **Analyzing long-term statistics** (frequency of LIFR/IFR/MVFR/VFR occurrences)  

The project is implemented with **R scripts** and **GitHub Actions** to ensure **fresh data every 10 minutes**.

---

## ✈️ Target Airports
Currently, the following Canadian airports are included in the dataset:

- **CYMO** – Moosonee Airport  
- **CYYB** – North Bay Jack Garland Airport  
- **CYOO** – Oshawa Executive Airport  
- **CYOW** – Ottawa Macdonald–Cartier International Airport  
- **CYQG** – Windsor International Airport  

You can easily expand this list in [`metar_fetch.R`](metar_fetch.R).

*More airports are expected to be added once the maximum sustainable refresh rate for the API is established.*

---

## ⚙️ How It Works

### 1. Data Collection (`metar_fetch.R`)
- Uses the **CheckWX API** to fetch **decoded METAR reports**.
- Each run requests all stations in **one API call** for efficiency.
- Extracted fields include:
  - ICAO code
  - Observation timestamp
  - Flight category (VFR, MVFR, IFR, LIFR)
  - Temperature, dewpoint, humidity
  - Wind direction and speed
  - Visibility
  - Altimeter pressure
  - Raw METAR text
  - Fetch timestamp (when the script ran)

- Data is written to **`saved_METARs.csv`**:
  - Appended at each run
  - Automatically **deduplicated** by `(ICAO, observed_utc)`
  - Ensures a clean and growing historical dataset

### 2. Automation (GitHub Actions)
A GitHub Actions workflow [`fetch_metars.yml`](.github/workflows/fetch_metars.yml) runs the script automatically:

- **Schedule:** every 10 minutes (`*/10 * * * *`)
- **Containerized R Environment:** uses the [`rocker/tidyverse`](https://hub.docker.com/r/rocker/tidyverse) image for speed and reproducibility
- **Workflow Steps:**
  1. Checkout the repository  
  2. Install `jsonlite` if missing (only required R package)  
  3. Run the METAR fetch script  
  4. Commit & push updates to `saved_METARs.csv`  
  5. Record run time  
  6. Post a GitHub notification comment tagging the maintainer  

This ensures **continuous updates** with minimal maintenance.

---

## 🎯 Research Scope
The research focuses on the **frequency and distribution** of flight conditions:

- **LIFR (Low Instrument Flight Rules)**  
  *Ceilings < 500 ft AGL and/or visibility < 1 SM*
- **IFR (Instrument Flight Rules)**  
  *Ceilings 500–1,000 ft AGL and/or visibility 1–3 SM*
- **MVFR (Marginal Visual Flight Rules)**  
  *Ceilings 1,000–3,000 ft AGL and/or visibility 3–5 SM*
- **VFR (Visual Flight Rules)**  
  *Ceilings > 3,000 ft AGL and visibility > 5 SM*

By storing every METAR cycle, the dataset will allow for:
- Daily, monthly, and seasonal statistics  
- Comparison of **airport-specific tendencies**  
- Identifying **patterns of poor visibility** (e.g., fog-prone regions)  
- Supporting **operational decision-making** and **academic study**  

It is important to note that this is a **long-term climatology project**.  
- To build a **full yearly profile** of flight conditions, at least **12 months of continuous data** will be required.  
- However, **early insights and preliminary comparisons** between airports should start to become meaningful after **2–3 months of consistent collection**, particularly when looking at relative frequencies (e.g., “Airport A experiences MVFR more often than Airport B”).  

---

## 📊 Planned Analyses
With a growing dataset, future analyses will include:

- **Occurrence counts** of each flight category per airport  
- **Percentage distributions** (e.g., % of MVFR at CYMO vs CYQG)  
- **Time-of-day effects** (morning vs evening METARs)  
- **Seasonal comparisons** (winter IFR vs summer VFR tendencies)  
- **Trend lines** showing monthly IFR/LIFR rates over time  

---

## 📅 Research Timeline

| Time Collected | What Can Be Studied | Level of Insight |
|----------------|---------------------|-----------------|
| **2–3 months** | Basic comparisons between airports (e.g., % of IFR at CYMO vs CYQG); preliminary trendlines; short-term anomaly detection (foggy week vs clear week) | Early signals, but influenced by seasonal bias |
| **6 months**   | Seasonal tendencies (e.g., winter vs summer IFR rates); stronger statistical confidence in comparisons; emerging airport-specific patterns | Medium-term insights; still partial picture |
| **12 months**  | Full annual climatology of flight categories; long-term trend analysis; robust comparisons across airports and seasons | Strong, research-grade climatological dataset |
| **Beyond 1 year** | Multi-year climatology; stronger statistical reliability; identification of unusual or rare events (e.g., extremely prolonged IFR); ability to track year-over-year shifts, climate impacts, or operational risks | The dataset grows in **power and credibility** with each additional year, creating a long-term archive valuable for aviation research, training, and safety planning |

---

This staged approach ensures the project provides **immediate exploratory value** while also building toward a **comprehensive, multi-year climatology** of flight conditions at the selected airports.  
The longer the dataset runs, the more reliable and impactful the statistics become.
