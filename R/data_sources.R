# Creating rds objects for use as app data 
library(readr)
library(janitor)
library(readxl)
library(rnrfa)
library(sf)
library(here)
library(dplyr)
library(tidyr)
library(stringr)
library(conflicted)
conflicts_prefer(dplyr::select)
conflicts_prefer(dplyr::filter)
# River Tweed SAC ------------------------------------------------------------

woods <- st_read(here("data/Proposed_Wader_woodland_Areas_SAC.gpkg"))
#correct typo
woods[1,1] <- "Lauderhaugh"
farms <- stringr::str_replace_all(woods$Farm,"Clvoerhill", "Cloverhill") 
farms <- str_replace_all(farms,"Coverhill", "Cloverhill")
woods$Farm <- farms

saveRDS(woods, here("data","woodlands.rds"))


fence <- st_read(here("data","WADER_Fencelines.gpkg"))

saveRDS(fence,here("data", "woodland_fence.rds"))

# rt <- st_read(here("data",  "GB_SAC_OSGB36_20191031.shp")) %>% 
#   filter(SITECODE %in% c("UK0012691", "UK0017097","UK0017072","UK9006011", "UK9006131", "UK0030292"))%>% 
#   dplyr::select(SITECODE,SITENAME,Shape_Leng,Shape_Area,geometry) %>%  
#   st_transform(,4326) %>% 
#   filter(SITECODE == "UK0012691")




#wetlands

#images
#monitoring data, add points to show on map?
waren_wet <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/C1_Water_Quality/Wetlands/WADER wetlands water samples.xlsx", sheet = 1)
saveRDS(waren_wet, here("data/waren_wet.rds"))
kilnp_wet <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/C1_Water_Quality/Wetlands/WADER wetlands water samples.xlsx", sheet = 2)
saveRDS(kilnp_wet, here("data/kilnp_wet.rds"))
#spatial data for wetlands

wet_loc <- read_csv("C:/Users/njw179/OneDrive - Newcastle University/WADER/C1_Water_Quality/Wetlands/wetland_locations.csv")
#convert grid references
en <- wet_loc$NGR %>% osg_parse()
wet_loc$easting <- en$easting
wet_loc$northing <- en$northing

wet_loc<- st_as_sf(wet_loc, coords = c("easting", "northing"), crs = 27700)
saveRDS(wet_loc, here("data", "wet_loc.rds"))


# River Tweed SAC boundary 
rt_sac <- st_read("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/GB-SAC-OSGB36/GB_SAC_OSGB36_20191031.shp") %>% 
  filter(SITENAME =="River Tweed") %>% 
  dplyr::select(SITECODE, SITENAME, Shape_Leng, Shape_Area, geometry)

saveRDS(rt_sac, here("data", "river_tweed_sac_boundary.rds"))


# ranunculus data downloaded from nbnatlas - collected as part of NatureScot monitoring in 2014
ranun <- read_csv("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/tweed_ranunc/records-2022-06-23.csv") %>% 
  st_as_sf(., coords = c("Longitude (WGS84)", "Latitude (WGS84)"), crs = "+proj=longlat +datum=WGS84")

saveRDS(ranun, here("data", "ranunculus.rds"))

# salmon counts data from Tweed foundation reports

salmon <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/FishCounterSalmon.xlsx") %>% 
  clean_names() 
#convert grid references
en <- salmon$gridref %>% osg_parse()
salmon$easting <- en$easting
salmon$northing <- en$northing

salmon <- st_as_sf(salmon, coords = c("easting", "northing"), crs = 27700)

saveRDS(salmon, here("data", "salmon_count.rds"))

# Otter counts extracted from Findlay et al 2015, count data from nature scot condition monitoring in 2011

otter <- read_xlsx("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/otter_count.xlsx")

saveRDS(otter, here("data", "otter_count.rds"))


# hogweed data combined to single df in WADER/scripts/hogweed_test.R


# lamprey monitoring data from naturescot 2011 condition monitoring 
lamp <- read_delim("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/lamprey/occurrence.txt") %>%
  dplyr::select(day, month,year,date,occurrenceStatus, decimalLatitude,decimalLongitude, species) %>% 
  filter(decimalLatitude < 55.9)
lampsp <- st_as_sf(lamp, coords = c("decimalLongitude", "decimalLatitude"),crs="WGS84")
lampsp$species <- replace_na(lampsp$species, "Absent")

saveRDS(lampsp, here("data/lamprey_monitoring.rds"))

#lamprey abundance data from Campbell 2002 - 2004 - report shows image rather than raw data 



# Tweed Estuary -----------------------------------------------------------

# River Tweed SAC boundary 
te_sac <- st_read("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/GB-SAC-OSGB36/GB_SAC_OSGB36_20191031.shp") %>% 
  filter(SITENAME =="Tweed Estuary") %>% 
  dplyr::select(SITECODE, SITENAME, Shape_Leng, Shape_Area, geometry)

saveRDS(te_sac, here("data", "tweed_estuary_sac_boundary.rds"))

# biotope survey data figs 2.11 and 2.12
biotopes <- readRDS(here("data", "te_biotopes.rds"))

biotopes_disp <- biotopes %>% filter(Year == 2017)
#water quality EA monitoring point at sandstell point 



# North Northumberland dunes  ---------------------------------------------

nnd_sac <- st_read("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/GB-SAC-OSGB36/GB_SAC_OSGB36_20191031.shp") %>% 
  filter(SITENAME =="North Northumberland Dunes") %>% 
  dplyr::select(SITECODE, SITENAME, Shape_Leng, Shape_Area, geometry)

saveRDS(nnd_sac, here("data", "north_dunes_sac_boundary.rds"))



# BNNC --------------------------------------------------------------------

bnnc_sac <- st_read("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/GB-SAC-OSGB36/GB_SAC_OSGB36_20191031.shp") %>% 
  filter(SITENAME =="Berwickshire and North Northumberland Coast") %>% 
  dplyr::select(SITECODE, SITENAME, Shape_Leng, Shape_Area, geometry)

saveRDS(bnnc_sac, here("data", "bnnc_sac_boundary.rds"))

# Lindisfarne spa ---------------------------------------------------------


# Northumbria coast spa ---------------------------------------------------




# Water Quality -----------------------------------------------------------



# consented discharges 

disch <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/Water_Quality/Discharges_NE.xlsx", skip = 1) %>% 
  clean_names()
#convert ngr to points that can be plotted 

en <- disch$outlet_grid_ref %>% osg_parse()
disch$easting <- en$easting
disch$northing <- en$northing
disch <- st_as_sf(disch, coords = c("easting", "northing"), crs = 27700)

saveRDS(disch, here("data/consented_discharges.rds"))

# abstraction licences 

nland_ab <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/Water_Quality/WADER project Northumberland Licences Summary March 2022.xlsx") %>% 
  clean_names()
till_ab <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/Water_Quality/WADER project Till Licences Summary March 2022.xlsx") %>% 
  clean_names() %>% 
  rename(max_annual_quantity_m_u_025c_y=max_annual_quantity_m_u_025c_d) %>% 
  rename(general_use= general_use_relating_to_secondary_category_medium_loss)

abstraction_all <- bind_rows(nland_ab, till_ab)

en <- abstraction_all$ngr %>% osg_parse()
abstraction_all$easting <- en$easting
abstraction_all$northing <- en$northing
abstraction_all <- st_as_sf(abstraction_all, coords = c("easting", "northing"), crs = 27700)

saveRDS(abstraction_all, here("data/abstraction_licences.rds"))


## River level data 
# this could be tidied up map_df for the folder 
riv1 <- read_csv("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/Water_Quality/River_levels/river-till-doddington-bridge.csv") %>% 
  clean_names()

riv2 <- read_csv("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/Water_Quality/River_levels/river-till-weetwood-bridge.csv") %>% 
  clean_names()
riv3 <- read_csv("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/Water_Quality/River_levels/till-cornhill-on-tweed-heaton-mill.csv") %>% 
  clean_names()
riv4 <- read_csv("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/Water_Quality/River_levels/tweed-berwick-tidal.csv") %>% 
  clean_names()
riv5 <- read_csv("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/Water_Quality/River_levels/tweed-norham.csv") %>% 
  clean_names()
riv6 <- read_csv("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/Water_Quality/River_levels/tweed-norham-till.csv") %>% 
  clean_names()
riv7 <- read_csv("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/Water_Quality/River_levels/waren-burn-chatton-waren-ford.csv") %>% 
  clean_names()
riv8 <- read_csv("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/Water_Quality/River_levels/waren-burn-easington-waren-mill.csv") %>% 
  clean_names()

rivall <- bind_rows(riv1,riv2,riv3,riv4,riv5,riv6,riv7,riv8)

en <- rivall$ngr %>% osg_parse()
rivall$easting <- en$easting
rivall$northing <- en$northing
rivall <- st_as_sf(rivall, coords = c("easting", "northing"), crs = 27700)


saveRDS(rivall, here("data/river_levels.rds"))

# csmg data 
csmg1 <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/Water_Quality/CSMG April 2022.xlsx", sheet = 1, skip = 1) %>% 
  clean_names()
csmg2 <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/Water_Quality/CSMG April 2022.xlsx", sheet = 7) %>% 
  clean_names() %>% 
  dplyr::select(smpt_ref, easting, northing) %>% 
  rename(wims_site_id_for_monitoring = smpt_ref) %>% 
  filter(wims_site_id_for_monitoring%in% csmg1$wims_site_id_for_monitoring) %>% 
  mutate(wims_site_id_for_monitoring = as.numeric(wims_site_id_for_monitoring)) 
csmg1 <- left_join(csmg1, csmg2, by = "wims_site_id_for_monitoring") %>% 
  slice(3:8)
csmg1 <- st_as_sf(csmg1, coords = c("easting", "northing"), crs = 27700)

#csmg1 to be used as display object for this dataset
# dataset to be downloaded is the excel file 
saveRDS(csmg1, here("data/csmg_april_22.rds"))

#David Kirklands N and P data 3 year means 
np <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/Water_Quality/NandP2010_2022.xlsx", sheet = 1, skip = 2) %>% 
  clean_names()

np <- st_as_sf(np, coords = c("easting", "northing"), crs = 27700)

saveRDS(np, here("data/nandp.rds"))


### HAREHOPE data 

#pre restoration

#sediment data (UK CEH samples)
#read first two rows to get header data
headers <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/C1_Water_Quality/Harehope/Sediment/Harehope_Sediment_Monitoring_2024_raw data.xlsx",
                      n_max = 2, col_names = FALSE) 
new_names <- paste(
  as.character(headers[1, ]),
  as.character(headers[2, ]),
  sep = "_"
)

sed_pre <- read_excel(
  "C:/Users/njw179/OneDrive - Newcastle University/WADER/C1_Water_Quality/Harehope/Sediment/Harehope_Sediment_Monitoring_2024_raw data.xlsx",
  skip = 2,
  col_names = new_names
) %>%
  clean_names()



sed_pre <- st_as_sf(sed_pre, coords = c("easting_na", "northing_na"), crs = 27700)

saveRDS(sed_pre, here("data/hhpresedceh.rds"))

#wet samples

hhwet <- read_csv("C:/Users/njw179/OneDrive - Newcastle University/WADER/C1_Water_Quality/Harehope/wet_samples_all.csv")

saveRDS(hhwet, here("data/hhwetpre.rds"))
#euan macrophytes report
#Zara sediment report


# Wildlife Disturbance ----------------------------------------------------

webs <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/birds/WEBS_LTC_Data/WEBS18_19_count_section_densities.xlsx") %>% 
  clean_names()
saveRDS(webs, here("data/webs.rds"))

bird_disturb20 <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/wildlife_disturbance/2020 LNNR Bird Disturbance Data.xlsx") %>% 
  clean_names() %>% 
  st_as_sf(., coords = c("easting", "northing"), crs = 27700)

saveRDS(bird_disturb20, here("data/bird_disturbance20.rds"))

dog_zone21 <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/wildlife_disturbance/2021 LNNR Dog Zone Data.xlsx") %>% 
  clean_names()
saveRDS(dog_zone21, here("data/dog_zone21.rds"))


people_count21 <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/wildlife_disturbance/2021 LNNR People Counter Data.xlsx") %>% 
  clean_names()
saveRDS(people_count21,here("data/people_count21.rds"))

visitor_q_use21 <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/wildlife_disturbance/2021 LNNR Visitor Usage Questionnaire Results.xlsx") %>% 
  clean_names()
saveRDS(visitor_q_use21,here("data/visitor_q_use21.rds"))

seals<- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/Copy of seals.xls") %>% 
  clean_names()
saveRDS(seals, here("data/seals.rds"))

plov <-read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/Northumberland Breeding Ringed Plover data 2021.xlsx", sheet = 2) %>% 
  clean_names()
saveRDS(plov,here("data/plovers.rds"))

shorebird_counts <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/Data/shorebirdcounts.xlsx") %>% 
  clean_names()
saveRDS(shorebird_counts, here("data/shorebird_counts.rds"))

webs <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW/birds/WEBS_LTC_Data/WEBS18_19_count_section_densities.xlsx") %>% 
  clean_names()
saveRDS(webs,here("data/webs18_19.rds"))


# shorebird protection areas



# pre wader 2021 protection 

protect21 <- st_read(here("data","Protection_area_shapes", "2021_protection.kml")) %>% 
  rename(id="Name", Area = "Description") %>% 
  st_transform(27700)
protect21$Year <- "2021"
protect21$Area <- as.numeric(protect21$Area)
protect21 <- protect21 %>% dplyr::select(Year,id,Area,geometry) %>% st_zm() %>% 
  slice(-1)
saveRDS(protect21, here("data/protection_2021.rds"))



gfence22 <- st_read(here("data","Protection_area_shapes","2022", "Goswick fence.shp")) %>% 
  st_set_crs(27700)
gfence22$id <- "Goswick"
gfence22$Year <- "2022"
gfence22 <- gfence22 %>% select(Year,id,Area,geometry)

kpfence22 <- st_read(here("data","Protection_area_shapes","2022", "Kiln Point fencing.shp"))%>% 
  st_set_crs(27700)
kpfence22$id <- "Kiln Point"
kpfence22$Year <- "2022"
kpfence22 <- kpfence22 %>% select(Year,id,area,geometry)%>% rename(Area=area)

rsfence22 <- st_read(here("data","Protection_area_shapes","2022", "Ross South.shp"))%>% 
  st_set_crs(27700)
rsfence22$id <- "Ross South"
rsfence22$Year <- "2022"
rsfence22 <- rsfence22 %>% select(Year,id,Area,geometry) 

# additional shapes 
extra22 <- st_read(here("data","Protection_area_shapes", "2022_protection.kml")) %>% 
  rename(id="Name", Area = "Description") %>% 
  st_transform(27700)
extra22$Year <- "2022"
extra22$Area <- as.numeric(extra22$Area)
extra22 <- extra22 %>% select(Year,id,Area,geometry) %>% st_zm()

extra22[3,2] <- "ross_low_tide"

protect22 <- bind_rows(gfence22,kpfence22,rsfence22,extra22)

saveRDS(protect22, here("data/protection_2022.rds"))


# data are 2023 protection areas 

fence23 <- st_read(here("data","Protection_area_shapes","2023", "Protection fencing.shp")) %>% 
  slice(-5) %>% 
  slice(-10) %>% 
  slice(-11) %>% 
  st_transform(crs = 27700) # throwing an issue when trying to plot for some reason??

fence23$id <- "Fencing"
fence23$Year <- "2023"
fence23 <- fence23 %>% select(Year,id,Area,geometry)

buffer23 <- st_read(here("data","Protection_area_shapes","2023", "buffer fencing.shp"))%>% 
  st_transform(crs = 27700)

buffer23$id <- "Buffer"
buffer23$Year <- "2023"
buffer23 <- buffer23 %>% select(Year,id,Area,geometry)

restrict23 <- st_read(here("data","Protection_area_shapes","2023", "Foreshore access restriction.shp"))%>% 
  st_transform(crs = 27700)

restrict23$id <- "Access Restriction"
restrict23$Year <- "2023"
restrict23 <- restrict23 %>% select(Year,id,foresh.are,geometry) %>% rename(Area = foresh.are)

protect23 <- bind_rows(fence23,buffer23,restrict23)
saveRDS(protect23, here("data/protection_2023.rds"))


protectall <- bind_rows(protect21,protect22,protect23) %>%select(Year,id, geometry) 
protectall <- protectall %>% mutate(protected_m2 = st_area(protectall))

saveRDS(protectall, here("data/protection_all.rds"))



#lindisfarne shape file from NE open geodatabase
lnnr_po <- st_read(here("data", "lindisfarne_nnr.gpkg")) %>% 
  filter(NAME== "LINDISFARNE") %>% 
  st_transform(crs = 27700)
saveRDS(lnnr_po, here("data/lnnr_po.rds"))

# IAS ---------------------------------------------------------------------

#nnd - lindisfarne invasives

ias_layers <- st_layers(here("DataRAW", "invasive_shapes", "Non-Native Species Audit.kml"))


cont  <- st_read(here("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW", "invasive_shapes", "Non-Native Species Audit.kml"), layer = "Contoneaster")
cont$Species <- "Contoneaster"
ladym <- st_read(here("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW", "invasive_shapes", "Non-Native Species Audit.kml"), layer = "Lady's Mantle")
ladym$Species <- "Lady's Mantle"
ptoad<- st_read(here("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW", "invasive_shapes", "Non-Native Species Audit.kml"), layer = "Purple Toadflax")
ptoad$Species <- "Purple Toadflax"
japrose<- st_read(here("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW", "invasive_shapes", "Non-Native Species Audit.kml"), layer = "Japanese Rose")
japrose$Species <- "Japanese Rose"
daisy<- st_read(here("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW", "invasive_shapes", "Non-Native Species Audit.kml"), layer = "Michaelmas Daisy")
daisy$Species <- "Michaelmas Daisy"
montb<- st_read(here("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW", "invasive_shapes", "Non-Native Species Audit.kml"), layer = "Montbretia")
montb$Species <- "Montbretia"
rose<- st_read(here("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW", "invasive_shapes", "Non-Native Species Audit.kml"), layer = "Unknown Rose Species")
rose$Species <- "Unknown Rose Species"
other<- st_read(here("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW", "invasive_shapes", "Non-Native Species Audit.kml"), layer = "Other Species")
other$Species <- "Other"
coldenrod<- st_read(here("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW", "invasive_shapes", "Non-Native Species Audit.kml"), layer = "Canadian Coldenrod")
coldenrod$Species <- "Canadian Coldenrod"

ias <- bind_rows(cont,ladym,ptoad,japrose,daisy,montb,rose,other, coldenrod) %>% dplyr::select(-Description)

saveRDS(ias, here("data/lindisfarne_ias.rds"))


biodiverse <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/Dune_invasives/Biodiverse_Survey/Copy of Dunes Invasives grid references.xlsx", sheet = 2) %>% 
  clean_names()

en <- biodiverse$grid_ref %>% osg_parse()
biodiverse$easting <- en$easting
biodiverse$northing <- en$northing
biodiverse <- st_as_sf(biodiverse, coords = c("easting", "northing"), crs = 27700)

saveRDS(biodiverse, here("data/biodiverse_2022.rds"))


biodiverse_loc <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/C5_Invasives/Dune_invasives/Biodiverse_Survey/Survey_sites_2025.xlsx", sheet = 1) %>% 
  clean_names()

biodiverse_loc <- st_as_sf(biodiverse_loc, coords = c( "longitude", "latitude"), crs = "EPSG:4326")

saveRDS(biodiverse_loc, "data/biodiverse_loc.rds")


myfilepath <- "C:/Users/njw179/OneDrive - Newcastle University/WADER/C5_Invasives/Dune_invasives/Biodiverse_Survey/BioC21-054 Dune Invasives All Years Raw Dataset.xlsx"
sheet_names <- excel_sheets(myfilepath)
data_list <- lapply(sheet_names, function(sheet){
  read_excel(myfilepath, sheet=sheet)
})

data_list2 <- head(data_list, -2)

biodiv_quad_all <- bind_rows(data_list2)

saveRDS(biodiv_quad_all,"data/biodiv_quad_all.rds")

## UAV data 

nnd <- st_read(here("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW", "GB-SAC-OSGB36", "GB_SAC_OSGB36_20191031.shp")) %>% 
  filter(SITECODE == "UK0017097")%>% 
  dplyr::select(SITECODE,SITENAME,Shape_Leng,Shape_Area,geometry) 

dune <- st_read(here("C:/Users/njw179/OneDrive - Newcastle University/WADER/DataRAW", "EA_CASIandLIDARHabitatMap_SHP","Data", "Sand_Dune_Habitat_Map_V1.shp"))
poo <- seq(1:18)
dunes <- st_cast(nnd, "POLYGON") %>% 
  mutate(idno = poo)


#nndd <- st_intersection(y = nnd, x = dune )

bamdn <- st_intersection(y = dunes[12,], x = dune)
saveRDS(bamdn, here("data/uav_ias.rds"))


##aonb pirri points
library(stringr)
ncpirri <- read_csv(here("C:/Users/njw179/OneDrive - Newcastle University/WADER/Dune_invasives", "Northumberland Coast Pirri Pirri Burr Survey_fieldworker.csv")) %>% 
  clean_names() %>% 
  st_as_sf(., coords = c("x",
                         "y"), 
           crs = 4326) %>% 
  mutate(year = str_extract(date, "^(.+?),")) %>% 
  mutate(year= str_sub(year, -5,-2))
saveRDS(ncpirri,here("data/ncpirri.rds") )


#Zarahs student pirri survey 

lin_pirri <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/Dune_invasives/Zarah_student_data/200228196_NES8001_Project_PirriData - For Zarah.xlsx", sheet = 1) %>% 
  clean_names()

en <- lin_pirri$grid_gps %>% osg_parse()
lin_pirri$easting <- en$easting
lin_pirri$northing <- en$northing
lin_pirri <- filter(lin_pirri, !is.na(easting)) %>% 
  st_as_sf(., coords = c("easting", "northing"), crs = 27700)
saveRDS(lin_pirri,here("data/lin_pirri.rds") )



# tweed invasives collated from individual year data from Tweed Forum
# WADER data - collate 2022-2026 data

#GH
#inns data 

hog22 <- st_read(here("C:/Users/njw179/OneDrive - Newcastle University/WADER/C5_Invasives/Freshwater_invasives/Emily_data/Giant_Hogweed_2022_MASTER.gpkg")) |> 
  select(elevation) 

hog22$year <- "2022"

hog23 <- st_read(here("C:/Users/njw179/OneDrive - Newcastle University/WADER/C5_Invasives/Freshwater_invasives/Emily_data//Hogweed/GH_2023.gpkg"))

#filtering out erroneous location records
library(rnaturalearth)
# Get UK boundary
uk <- ne_countries(
  country = "United Kingdom",
  returnclass = "sf"
)
# Make sure both use the same CRS
uk <- st_transform(uk, st_crs(hog23))
# Keep only points within the UK
hog23 <- hog23[st_within(hog23, uk, sparse = FALSE), ]

hog23 <- hog23 |>   select(elevation) |> 
  st_transform(crs = 27700)
hog23$year <- "2023"

# set crs to national grid to match other years 

hog24 <- st_read(here("C:/Users/njw179/OneDrive - Newcastle University/WADER/C5_Invasives/Freshwater_invasives/Emily_data/Hogweed/GH_2024_Final.gpkg"))|> 
  rename(elevation = ele) |> 
  select(elevation)

hog24$year <- "2024"

hog25 <- st_read(here("C:/Users/njw179/OneDrive - Newcastle University/WADER/C5_Invasives/Freshwater_invasives/Emily_data/GH_2025.gpkg")) |> 
  rename(elevation = ele) |> 
  select(elevation)

hog25$year <- "2025"

hog26 <- st_read(here("C:/Users/njw179/OneDrive - Newcastle University/WADER/C5_Invasives/Freshwater_invasives/Emily_data/GH_2026.gpkg")) |> 
  rename(elevation = ele) |> 
  select(elevation)

hog26$elevation <- as.numeric(hog26$elevation)
hog26$year <- "2026"


hog_all <- bind_rows(hog22,hog23,hog24,hog25,hog26)

saveRDS(hog_all, here("data/hog_wader.rds"))

#JK

jk23 <- st_read(here("C:/Users/njw179/OneDrive - Newcastle University/WADER/C5_Invasives/Freshwater_invasives/Emily_data/JK_2023.gpkg")) |> 
  select(elevation)
jk23$year <- "2023"
#tm_shape(jk23)+tm_dots()
jk24 <- st_read(here("C:/Users/njw179/OneDrive - Newcastle University/WADER/C5_Invasives/Freshwater_invasives/Emily_data/JK_2024.gpkg")) |> 
  rename(elevation = "ele") |> 
  select(elevation)
jk24$year <- "2024"

jk26 <-  st_read(here("C:/Users/njw179/OneDrive - Newcastle University/WADER/C5_Invasives/Freshwater_invasives/Emily_data/JK_2026.gpkg")) |> 
  rename(elevation = "ele") |> 
  select(elevation)
jk26$elevation <- as.numeric(jk26$elevation)
jk26$year <- "2026"

#tm_shape(jk24)+tm_dots()

jk_dat <- bind_rows(jk23,jk24, jk26)

tm_shape(jk_dat)+tm_dots(fill= "year")

saveRDS(jk_dat, "data/jk_dat.rds")
# botanical surveys data 
library(readxl)
library(purrr)

myfilepath <- "C:/Users/njw179/OneDrive - Newcastle University/WADER/C5_Invasives/Freshwater_invasives/Tables_2_to_8.xlsx"
sheet_names <- excel_sheets(myfilepath)
data_list <- lapply(sheet_names, function(sheet){
  read_excel(myfilepath, sheet=sheet)
})

data_list2 <- map(data_list,~select(.x, -site))

bot_all <- reduce(data_list2, full_join, by= "species")

saveRDS(bot_all, "data/bot_all.rds")
bot_sites <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/C5_Invasives/Freshwater_invasives/2023_INNS_Control_Assessment_sites.xlsx", sheet = 1)

nt_gridref_to_en <- function(gridref){
  gridref <- gsub("\\s+", "",toupper(gridref))
  easting <- 300000+as.numeric(substr(gridref,3,5))*100
  northing <- 600000+as.numeric(substr(gridref,6,8))*100
  data.frame(Easting=easting,
             Northing=northing)
}

coords <- do.call(rbind,lapply(bot_sites$Location, nt_gridref_to_en))

bot_sites <- cbind(bot_sites,coords)
bot_sites <- st_as_sf(bot_sites, coords = c("Easting", "Northing"), crs= 27700)

saveRDS(bot_sites, "data/bot_sites.rds")
#display bot_sites, points on map
#preview bot_all data


# OM ----------------------------------------------------------------------

# EA DEM digital elevation model 2019

#EA monitoring
# various shapefiles from seagrass monitoring but files seem to be corrupted - no data aother than shape itself

# MaccOpp Quadrat Info 2021.xlsx = QUadrat survey info from 2021 macroalgae surveys details percent cover of algae and weight of algae for patches that were surveyed. Data from Anthony Crook at Environment Agency

om21 <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/Macroalgae/EA_monitoring/MaccOpp Quadrat Info 2021.xlsx") %>% 
  clean_names()

en <- om21$quadrat_position_ngr %>% osg_parse()
om21$easting <- en$easting
om21$northing <- en$northing

om21 <- om21 %>% st_as_sf(.,coords = c("easting", "northing"), crs = 27700)
saveRDS(om21, here("data/om21.rds"))

# 2017 Budle Bay Opp Mac + Entrianment = survey data from 2017 includes biomass data and entrainment data, from Anthony Crook at Environment Agency

om17 <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/Macroalgae/EA_monitoring/2017_all.xlsx") %>% 
  clean_names()
om17 <- om17 %>% st_as_sf(.,coords = c("wgs84_long", "wgs84_lat"), crs = 4326)
saveRDS(om17, here("data/om17.rds"))

om0818 <- read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/Macroalgae/EA_monitoring/20190726_Seagrass_Taxa_abundance_oldVer.xlsx") %>% 
  clean_names() %>% 
  filter(site_station_name == "HOLY ISLAND AND BUDLE BAY SEAGRASS (FENHAM FLATS)") %>% 
  filter(!is.na(quadrat_full_easting)) %>% 
  st_as_sf(., coords = c("quadrat_full_easting", "quadrat_full_northing"), crs = 27700)

saveRDS(om0818, "data/om0818.rds")

# HIBB_Oppourtunistic_Macroalgae.xlsx = survey data from macroalgae surveys (2010-2013, 2015, 2017) includes percent cover, 
# entrainment (yes/no) and presence/absemce of various species. Environment Agency data from Anthony Crook

omhibb <-  read_excel("C:/Users/njw179/OneDrive - Newcastle University/WADER/Macroalgae/EA_monitoring/HIBB_Opportunistic_Macroalagae.xlsx") %>% 
  clean_names() %>% 
  filter(!is.na(quadrat_full_easting)) %>%
  st_as_sf(., coords = c("quadrat_full_easting", "quadrat_full_northing"), crs = 27700)

saveRDS(omhibb, "data/omhibb.rds")
