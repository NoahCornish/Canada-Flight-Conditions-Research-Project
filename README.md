#  Canada METAR Flight Conditions Research Project

[![⛅ METAR ⛈️](https://github.com/NoahCornish/METAR-Study/actions/workflows/metar.yml/badge.svg)](https://github.com/NoahCornish/METAR-Study/actions/workflows/metar.yml)

##  Overview  
This project automates the **collection, analysis, and visualization of decoded METAR reports** for a growing network of **50 Canadian airports**, tracked continuously via the GitHub-hosted pipeline. The goal: establish the first comprehensive **national climatology of aviation flight conditions** (VFR, MVFR, IFR, LIFR), supporting research in aviation safety, weather dynamics, and climate variability across Canada.

This repository demonstrates:
- **Automated data ingestion** (`metar_fetch.R`, every 10 minutes via GitHub Actions).
- **Deduplication & cleaning** (`clean_metars.R`) into `clean_metars.csv` (plus monthly archives).
- **State-of-the-art analysis** (`analysis.R`) of daily averages, flight-category frequencies, and time allocations.
- **Automated visual outputs** (`charts.R`, `chart_readme.R`) with bar charts and overview maps committed back to GitHub.
- **Front-end visualizations** (`index.html`, `map.html`) enabling interactive display of flight conditions.

---

##  Airport Network Expansion  
Originally centered on **15 Ontario airports**, the project now spans **50 key Canadian stations** across diverse climatic zones:

- **Ontario Core** (15 airports): From remote Far North (e.g., CYER, CYMO) to urban hubs (e.g., CYYZ).
- **Western Canada**: Vancouver, Calgary, Edmonton, and other regional centers.
- **Northern Canada**: Yellowknife, Iqaluit, Whitehorse, and more.
- **Quebec & Atlantic**: Montréal, Halifax, St. John’s, and complementary regional airports.

This network captures a geographically comprehensive snapshot of Canada’s aviation weather variability.

---

##  Data Pipeline & Analysis Framework

1. **Fetch METARs** via [`metar_fetch.R`], capturing flight-category, temperature, dew point, humidity, wind, altimeter, and raw text.
2. **Clean** the stream with [`clean_metars.R`], maintaining only significant meteorological changes.
3. **Archive**:
   - `all_metars.csv` — full master dataset.
   - Monthly snapshots `metars_YYYY_MM.csv`.
4. **Analyze** with [`analysis.R`]:
   - `daily_averages.csv` — meteorological means per day.
   - `flight_summary.csv` — total counts of categorical conditions per airport.
   - `time_daily.csv`, `time_alltime.csv`, `time_overall.csv` — time spent per flight condition.
5. **Visualize** with:
   - `charts.R` — airport-level bar charts.
   - `chart_readme.R` — maps and graphics embedded in documentation.
6. **Front-End Views**:
   - `index.html` — card-style interface for selecting and viewing METARs.
   - `map.html` — dynamic regional map of flight conditions.

All artifacts are generated and committed daily via GitHub Actions, ensuring up-to-date reproducibility.

---

##  Research Applications  
Leveraging defined category thresholds (LIFR < 500 ft AGL / < 1 SM, IFR 500–1,000 ft / 1–3 SM, etc.), this dataset supports:

- Daily to seasonal trend analysis across diverse Canadian environments.
- Cross-provincial comparison of aviation weather patterns.
- Analysis of fog-prone or instrument-heavy regions.
- Development of normative **multi-year climatologies** for safety planning and climate research.

---

| Timeline       | Research Milestones                                     |
|----------------|----------------------------------------------------------|
| 2–3 months     | Station-level comparisons, anomaly detection             |
| 6 months       | Seasonal climatologies across provincial groups          |
| 12 months      | Full annual cycle insights and robust inter-airport analysis |
| Multi-year     | Detection of long-term trends and climate-driven shifts  |

---

##  Future Directions

- **Interactive dashboards** for live condition monitoring by airport.
- **Interpolated condition maps** (e.g., provincial shading).
- **Data portal** for aviation, climatology, and public use.
- **Collaborative opportunities** with academics, weather services, and aviation authorities.

---

##  Final Note  
This repository is more than a data pipeline—it’s a **geographer-led, automated national research platform** for Canadian aviation climatology, combining methodology-driven workflows with modern visualization and analysis tools. It’s ready for academic publication, policy integration, and cross-disciplinary collaboration.

*(See GitHub Actions tabs for automatic run logs and status.)*
