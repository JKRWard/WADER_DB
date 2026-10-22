library(sf)
library(leaflet)
library(leafem)
library(leaflet.providers)
library(dplyr)
library(stringr)
library(here)
library(readxl)
library(tidyr)
library(readr)
library(tmap)
library(viridisLite)
library(ggplot2)
# 
# coast_os <- readRDS("data/coast.RDS")
# coast_ll <- st_transform(coast_os, 4326)
# coast_ll <- dplyr::mutate(coast_ll, label = "Wader study region")
# 
# no_dat <- coast_ll %>% group_by(label) %>% st_union() %>%  st_sf()
# no_dat$label <- "There is no map associated with this data"
# 
# areas_os <- readRDS("data/ihu_areas.RDS")
# areas_ll <- st_transform(areas_os, 4326)
# 
# wader_groups_os <- readRDS("data/wader_groups.RDS")
# wader_groups_ll <- st_transform(wader_groups_os, 4326)
# 
# wader_areas_os <- readRDS("data/wader_areas.RDS")
# wader_areas_ll <- st_transform(wader_areas_os, 4326)
# 
# wader_region_os <- readRDS("data/wader_region.RDS")
# wader_region_ll <- st_transform(wader_region_os, 4326)
# 
library(raster)
# Data from Clare
budle_50m_os  <- readRDS("data/budle_50m.RDS")
budle_50m_os@file@name <- "data/budle_crop_50m.tif"
budle_75m_os  <- readRDS("data/budle_75m.RDS")
budle_75m_os@file@name <- "data/budle_crop_75m.tif"
budle_100m_os <- readRDS("data/budle_100m.RDS")
budle_100m_os@file@name <- "data/budle_crop_100m.tif"

budle_50m_ll  <- projectRaster(budle_50m_os, crs=CRS("+init=epsg:4326"))
budle_75m_ll  <- projectRaster(budle_75m_os, crs=CRS("+init=epsg:4326"))
budle_100m_ll <- projectRaster(budle_100m_os, crs=CRS("+init=epsg:4326"))
crs(budle_50m_ll)  <- sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
crs(budle_75m_ll)  <- sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
crs(budle_100m_ll) <- sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
# 
# 
# Water Framework Directive
northumbria_twb_os <- readRDS("data/Northumbria_TWB.RDS")
northumbria_swoc_os <- readRDS("data/Northumbria_SWOC.RDS")
northumbria_swmc_os <- readRDS("data/Northumbria_SWMC.RDS")
northumbria_rca_os <- readRDS("data/wfd_catchments_2019_stat.rds")
northumbria_riv_os<- readRDS("data/wfd_rivers_2019_stat.rds")
northumbria_twb_ll <- st_transform(northumbria_twb_os, 4326)
northumbria_swoc_ll <- st_transform(northumbria_swoc_os, 4326)
northumbria_swmc_ll <- st_transform(northumbria_swmc_os, 4326)
northumbria_rca_ll <- st_transform(northumbria_rca_os, 4326)
northumbria_riv_ll <- st_transform(northumbria_riv_os, 4326)


# read map data from external file then filter according to display tab 
datinf <- read_excel("data/data_setup.xlsx")
# load tweed (scot and eng) rivers 

tw_riv_ln <- readRDS("data/tweed_rivers.rds")

# load all northumbria rivers 

riv_eng_ln <- readRDS("data/wfd_river_eng.rds")

#load sepa catchments

scot_catch <- readRDS("data/seap_wfd_catch.rds")


wchpa <- read_excel(here("data", "Water Classification Hub - Water Body - Protected Area General Information.xlsx"))


rivkeep <- c(wchpa$Name,"Whiteadder Water (Billie Burn confluence to tidal limit)", 
             "Whiteadder Water (Dye Water to Billie Burn confluences)", 
             "Billie Burn (Lintlaw Burn confluence to Whiteadder Water)", 
             "Monynut Water",
             " Whiteadder Water (Whiteadder Reservoir dam to Dye Water confluence)",
             "Bothwell Water", "Dye Water", "Watch Water",
             "Blackadder Water (Manse Burn to Howe Burn confluences)", "Blackadder Water (Howe Burn confluence to Whiteadder Water)")


rivers <- st_read(here("data", "SEPA_RIVER_WATERBODY_CLASSIFICATIONS_WGS84.shp" )) %>% 
  filter(WATER_BO_1 %in% rivkeep) #%>% 
  # filter(OBJECTID %in% c(29454,29907,30262,31181,29817))

# need to join rivers data to english data of same type 

wfd_spat <- readRDS(here("data","wfd_catchments_2019_stat.rds"))

rbd_wfd<- readRDS(here("data","wfd_rivers_2019_stat.rds"))

tweng <- rbd_wfd %>% filter(RBD_NAME.x == "Solway Tweed") %>% 
  dplyr::select(WB_NAME, OV_CLASS, geometry) %>% 
  st_transform(crs=4326)

twscot <- rivers %>% dplyr::select(WATER_BO_1,OVERALL_CL, geometry) %>% 
  rename(WB_NAME = WATER_BO_1, OV_CLASS = OVERALL_CL) %>% 
  st_zm() %>% 
  mutate(OV_CLASS = str_replace(OV_CLASS, " ecological potential", "")) %>% 
  mutate(OV_CLASS= factor(OV_CLASS, levels = c("Bad", "Poor", "Moderate","Good", "High")))


twall <- bind_rows(tweng,twscot)



### data frames for render_map functions 
# 
# region_df <- data.frame(
#   selection = c("Whole area", "IHU areas",  "Wader groups", "Wader areas", "Wader region"),
#   ll_map    = c("coast_ll", "areas_ll", "wader_groups_ll", "wader_areas_ll", "wader_region_ll"),
#   os_map    = c("coast_os", "areas_os", "wader_groups_os", "wader_areas_os", "wader_region_os"),
#   typ_map= c("polygons","polygons", "polygons", "polygons","polygons"),
#   typ_df    = c("coast_ll", "areas_ll", "wader_groups_ll", "wader_areas_ll", "wader_region_ll")
# )

budle_df <- data.frame(
  selection = c("50m", "75m", "100m"),
  ll_map    = c("budle_50m_ll", "budle_75m_ll", "budle_100m_ll"),
  os_map    = c("budle_50m_os", "budle_75m_os", "budle_100m_os"),
  typ_map= c("polygons","polygons", "polygons"),
  typ_df    = c("budle_50m_ll", "budle_75m_ll", "budle_100m_ll")
)

northumbria_wfd_df <- data.frame(
  selection = c("Transitional Water Bodies", "Surface Water Operational Catchments",
                "Surface Water Management Catchments","River catchements (England)", "Rivers (England)", "River catchments (Tweed)", "Rivers (Scotland)"),
  ll_map    = c("northumbria_twb_ll", "northumbria_swoc_ll", "northumbria_swmc_ll","northumbria_rca_ll","riv_eng_ln", "scot_catch","tw_riv_ln"),
  os_map    = c("northumbria_twb_ll", "northumbria_swoc_ll", "northumbria_swmc_ll", "northumbria_rca_os","riv_eng_ln","scot_catch","tw_riv_ln"),
  typ_map= c("polygons","polygons", "polygons", "polygons", "lines","polygons","lines"),
  typ_df = c("northumbria_twb_ll", "northumbria_swoc_ll", "northumbria_swmc_ll","northumbria_rca_ll","riv_eng_ln", "scot_catch","tw_riv_ln")
)


#create subset of points to increase plotting speed
ndt_spat_po <- readRDS("data/ndt_spat_2016-2022.rds") %>% 
  group_by(sample_sampling_point_label) %>% 
  filter(result == min(result)) %>% 
  slice(1) %>% 
  ungroup


# ndt_spat data for table display
ndt_spat_tab <- readRDS("data/ndt_spat_2016-2022.rds")

hibb_wqd_po <- readRDS("data/HIBB_WQD.rds")

riv_lev_tab <- readRDS("data/river_levels.rds")

riv_lev_po <- riv_lev_tab %>% 
  group_by(ngr) %>% 
  arrange(max_level) %>% 
  filter(row_number()==1)
  
csmg_po <- readRDS("data/csmg_april_22.rds")

# wqd_df <- data.frame(
#   selection = c("Standard monitoring data","HIBB Project Data"),
#   ll_map=c("ndt_spat_po", "hibb_wqd_po"),
#   os_map = c("ndt_spat_po", "hibb_wqd_po"),
#   typ_map= c("points","points"),
#   typ_df=c("ndt_spat_tab", "hibb_wqd_po")
# )

nandp_tab <- readRDS("data/nandp.rds")

nandp_po <- nandp_tab %>% 
  group_by(name) %>% 
  arrange(result) %>%
  filter(row_number()==1)



cdis_po <- readRDS("data/consented_discharges.rds")

abstract_po <- readRDS("data/abstraction_licences.rds")

wqd_df <- as.data.frame(datinf %>% filter(wp == "WQ")) %>% 
  filter(pre_wader =="pre")

wqwader_df <-as.data.frame(datinf %>% filter(wp == "WQ")) %>% 
  filter(during_wader == "d")

te_sac_poly <- readRDS("data/tweed_estuary_sac_boundary.rds")

te_sac_df <- as.data.frame(datinf %>% filter(sac == "TE"))


# te_sac_df <- data.frame(
#   selection = c("Ranunculus monitoring", "Salmon Counts", "Otter Counts",
#                 "Sea Lamprey monitoring","Hogweed locations", "WFD Rivers (England)", 
#                 "WFD Rivers (Scotland)", "WFD Catchments", "River Tweed SAC Boundary"),
#   ll_map = c(),
#   os_map = c(),
#   typ_map = c("points", "points", "points", "points", "points", "lines", "lines",
#               "polygons", "polygons"),
#   typ_df = c()
# )

rt_sac_df <- readRDS("data/river_tweed_sac_boundary.rds")




# tweed estuary data 

ran_pts <- readRDS("data/ranunculus.rds")
otter_pts <- readRDS("data/otter_count.rds")
salmon_pts <- readRDS("data/salmon_count.rds")
# hogweed is all data 
hogweed <- readRDS("data/hogweed_all_yrs.rds") %>% st_zm(drop = TRUE, what = "ZM")
hogweed$dt <- as.character(st_geometry_type(hogweed))
# hogweed_pts is only point data 
#filter to onlt first 100 points otherwise it will take too long to display on map 
hogweed_pts <- hogweed %>%filter(dt == "POINT") %>% slice(1:100)

bot_sites <- readRDS("data/bot_sites.rds")
bot_all <- readRDS("data/bot_all.rds")

rt_sac_poly <- readRDS("data/river_tweed_sac_boundary.rds")

lamp_11_pts <- readRDS("data/lamprey_monitoring.rds")

rt_sac_df <- as.data.frame(datinf %>% filter(sac == "RT"))

# North Northumberland Dunes data 

nnd_sac_df <- as.data.frame(datinf %>% filter(sac == "NND")) 


# BNNC SAC Data
bnnc_sac_df <- as.data.frame(datinf %>% filter(sac == "BNNC")) 

# Lindisfrane SPA data

lin_sac_df <- as.data.frame(datinf %>% filter(sac == "LIN")) 


## wildlife disturbance data 

 bird_disturbance20<- readRDS("data/bird_disturbance20.rds")
 bird_disturbance_po <- bird_disturbance20 #%>%
  # filter(row_number()==1:50)

 dog_zone21<- readRDS("data/dog_zone21.rds")
people_count21 <- readRDS("data/people_count21.rds")
 visitor_q_use21<- readRDS("data/visitor_q_use21.rds")
 
seals<- readRDS("data/seals.rds")
plovers<- readRDS("data/plovers.rds")
shorebird_counts<- readRDS("data/shorebird_counts.rds")
webs18_19<- readRDS("data/webs18_19.rds")

 wd_df <- as.data.frame(datinf %>% filter(wp == "WD"))
 
protect21<- readRDS( here("data/protection_2021.rds"))
protect22<- readRDS( here("data/protection_2022.rds"))
protect23<- readRDS(here("data/protection_2023.rds"))

lnnr_po <- readRDS(here("data/lnnr_po.rds")) 
wdw_df <- as.data.frame(datinf %>% filter(wp=="WDW")) 
 
 ## IAS data 
 
 lnnr_ias <-readRDS("data/lindisfarne_ias.rds")
 biodiverse_pts <- readRDS("data/biodiverse_2022.rds")
 biodiverse_loc <- readRDS( "data/biodiverse_loc.rds")
 biodiv_quad_all <- readRDS("data/biodiv_quad_all.rds")
 uav_ias <- readRDS("data/uav_ias.rds")
 
 ias_df <- as.data.frame(datinf %>% filter(wp == "IAS")) %>% 
   filter(pre_wader =="pre")
 
 iaswader_df <- as.data.frame(datinf %>% filter(wp == "IAS")) %>% 
   filter(during_wader =="d")
 
 ncpirri_pts <- readRDS("data/ncpirri.rds")
 
 
 lin_pirri <- readRDS("data/lin_pirri.rds")
 
 
 nnd_sac_poly <- readRDS("data/north_dunes_sac_boundary.rds")
 
 
 bnnc_sac_poly <- readRDS("data/bnnc_sac_boundary.rds")
 
 ##### report display
 
 reports <- read_excel("data/Report_Library.xlsx")
 rt_rep_tab <- reports %>% filter(PA == "RT") %>% dplyr::select(-PA,-WP,-pr)
 te_rep_tab <- reports %>% filter(PA == "TE") %>% dplyr::select(-PA,-WP,-pr)
 bnnc_rep_tab <- reports %>% filter(PA == "BNNC") %>% dplyr::select(-PA,-WP,-pr)
 nnd_rep_tab <- reports %>% filter(PA == "NND") %>% dplyr::select(-PA,-WP,-pr)
 
 hh_rep_tab <- reports |> filter(pr=="hh") |> dplyr::select(-PA,-WP,-pr)
 
 harehope_df <- as.data.frame(datinf %>% filter(pr == "hh")) 

 
 # wetlands
 
 wet_loc <- readRDS("data/wet_loc.rds")
 kilnp_wet <- readRDS("data/kilnp_wet.rds")
 waren_wet <- readRDS("data/waren_wet.rds")
 
 wet_df <- as.data.frame(datinf |> filter(pr=="wet"))
 
 wet_rep_tab <- reports |> filter(pr=="wet") |> dplyr::select(-PA,-WP,-pr)
 
# OM Data  ----------------------------------------------------------------
om21_pts <- readRDS("data/om21.rds")
om17_pts <- readRDS("data/om17.rds")
om0818_pts <- readRDS("data/om0818.rds")
omhibb_pts <- readRDS("data/omhibb.rds")


om_df <- as.data.frame(datinf %>% filter(wp == "OM"))


#### C1 WADER actions 

woods <- readRDS("data/woodlands.rds")
rt <- readRDS("data/river_tweed_sac_boundary.rds")
fence <- readRDS("data/woodland_Fence.rds")

lauder <- woods %>% filter(Farm=="Lauderehaugh" | Farm == "Lauderhaugh")

lauder_fence <- fence %>% filter(Farm == "Lauderhaugh")


tree_stats <- read_csv("data/tree_numbers.csv") %>% 
  pivot_longer(cols = 2:6, names_to= "Farm" )

wood_df <- as.data.frame(datinf %>% filter(pr == "tree")) 

lauder_stats <- tree_stats %>% filter(Farm == "Lauderhaugh") %>% filter(value >=1)


wood_plot <- tm_shape(woods)+tm_fill(col="blue")+tm_borders(col="blue", lwd=1.2)+tm_shape(twscot)+tm_lines(col="OV_CLASS", palette = viridis(5) )+
  tm_shape(tweng)+tm_lines(col="#21908CFF")

lau_map <- ggplot()+
  ggspatial::annotation_map_tile( zoom = 14,alpha = 0.9) +
  geom_sf(data= lauder, fill = "#A84268", alpha = 0.5)+
  geom_sf(data=lauder_fence, colour= "#4A6C6F", lwd = 1.2)+
  coord_sf(crs=4326, xlim=c(-2.770, -2.750), ylim =c(55.740,55.750),expand=FALSE) + xlab(NULL) + ylab(NULL)+
  ggspatial::annotation_scale()+
  theme(axis.text = element_blank(),axis.ticks = element_blank())

l_stat <- ggplot(lauder_stats, aes(fill = reorder(Species, value), y = value, x = Farm,label = Species))+
  geom_bar(position = "fill", stat = "identity")+
  geom_text(size = 3, position = position_fill(vjust = 0.5), colour = "white")+
  theme_void()+
  theme(legend.position = "none")

library(patchwork)

lau_maps <- lau_map+ l_stat
 
#harehope

sed_pre <- readRDS("data/hhpresedceh.rds")
hhwet <- readRDS("data/hhwetpre.rds")


## wetlands data


wet_df <- as.data.frame(datinf %>% filter(pr == "wet")) 

#C5

hog_wader <- read_rds("data/hog_wader.rds")

jk_dat <- read_rds("data/jk_dat.rds")