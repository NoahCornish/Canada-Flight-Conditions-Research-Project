#!/usr/bin/env Rscript

# 📦 Packages
need <- c("ggplot2","maps","dplyr")
missing <- need[!(need %in% rownames(installed.packages()))]
if (length(missing)) install.packages(missing, repos="https://cloud.r-project.org")
suppressPackageStartupMessages({
  library(ggplot2); library(maps); library(dplyr)
})

# 🌍 Canadian map
canada <- map_data("world", region = "Canada")

# ✈️ Airport coordinates
airports <- data.frame(
  icao = c("CYER","CYAT","CYMO","CYPL","CYQT","CYAM","CYTS","CYSB","CYYB","CYOW","CYGK","CYQG","CYVV","CYYZ","CYQA",
           "CYVR","CYLW","CYXS","CYXD","CYYC","CYQR","CYXE","CYWG",
           "CYZF","CYFB","CYRT","CYRB","CYCB","CYXY","CYDA",
           "CYUL","CYQB","CYHU","CYVO","CYJN",
           "CYHZ","CYQY","CYQM","CYFC","CYYG","CYYT","CYDF","CYJT"),
  lat = c(56.018,52.927,51.291,51.446,48.371,46.485,48.569,46.625,46.363,45.322,44.225,42.275,44.746,43.677,44.974,
          49.194,49.957,53.889,53.572,51.122,50.432,52.170,49.910,
          62.463,63.756,62.811,74.717,69.108,60.710,64.043,
          45.470,46.792,45.517,48.053,45.300,
          44.880,46.161,46.113,45.868,46.290,47.618,49.210,48.543),
  lon = c(-87.676,-82.431,-80.607,-90.214,-89.324,-84.509,-81.377,-80.798,-79.422,-75.669,-76.596,-82.955,-81.107,-79.624,-79.303,
          -123.184,-119.377,-122.679,-113.521,-114.020,-104.666,-106.700,-97.239,
          -114.376,-68.555,-92.115,-94.967,-105.138,-135.067,-139.128,
          -73.741,-71.393,-73.417,-77.783,-73.283,
          -63.514,-60.049,-64.678,-66.537,-63.131,-52.742,-57.391,-58.549),
  region = c(rep("Ontario",15),
             rep("West",8),
             rep("North",7),
             rep("Quebec",5),
             rep("Atlantic",7)) # adjust number for final list
)

# 🎨 Map
p <- ggplot() +
  geom_polygon(data = canada, aes(x=long,y=lat,group=group), fill="grey90", color="black") +
  geom_point(data=airports, aes(x=lon,y=lat,color=region), size=3, alpha=0.8) +
  scale_color_manual(values=c("Ontario"="#3498db","West"="#e67e22","North"="#9b59b6","Quebec"="#2ecc71","Atlantic"="#e74c3c")) +
  coord_fixed(1.3) +
  theme_minimal() +
  labs(title="🌤️ Canadian METAR Network (50 Airports)", color="Region")

# Save
ggsave("charts/airport_map.png", p, width=10, height=6)
