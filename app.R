# Wader DB main script
library(conflicted)
library(shiny)
library(sf)
library(leaflet)
library(leafem)
library(tmap)
library(leaflet.providers)
library(dplyr)
library(tmap)
library(here)
library(DT)
library(bslib)
library(DT)

conflicts_prefer(dplyr::select)
conflicts_prefer(dplyr::filter)
vector_regions <- c("Whole area", "IHU areas", "Wader groups", "Wader areas", "Wader region")

ui <- fluidPage(
  theme = bs_theme(bootswatch = "solar", navbar_bg = "#2AA198"),
  navset_pill( 
    nav_panel(title = div(img(src = "LW_logo_white.png", width = "auto", height = "50"),"WADER Database"), 
              p("                                           "),
              layout_columns(
                col_widths = c(6,6,12),
                row_heights = c("500","300"),
                card(
                  card_header( 
                    "Database Overview"),
                  card_body(markdown("This database contains Data relating to the LIFE WADER Project.
                                     Data can be viewed according to the Work Package of Interest or by Protected area (SAC or SPA) encompassed by the Project."),
                            markdown("##### Work Package View
                                     
                                     The Work Package View details data for each work package of the project. For each work package data are separated into Pre WADER data: data that were collected prior to the initiation of the WADER project, and WADER Data: Data that have been collected during the WADER project lifetime.
                                     WADER data details data collected as part of project actions as well as data that are collected as part of ongoing monitoring/external activities that provide information that could be useful for the WADER project."
                            ),
                            markdown("##### Protected Area View
                                     
                                     Protected Area view details data that are available for each Protected area most of which are derived from condition monitoring assessments. Much of the condition monitoring assessments however are based on commissioned reports, many of which did not have the underlying data available.
                                     Where the underlying data were not available they are not detailed in this database. Reports are available under the Reports Tab for each area."))
                ),
                card( fill=FALSE,
                      img(src="data_diagram1.png", height = "500", width = "550")),
                card(class = "align-items-center",
                     img(src="LW_logo_white.png", height = "100%", width = 280))
              )),
    
    nav_panel(title= div(img(src = "LW_logo_blue.png", width = "auto", height = "50"),"Work Package View"), 
              p("Explore project data filtered according to the WADER work package that you are interested in."),
              
              navlistPanel(
                id="tabset",
                
                tabPanel("C1: Water Quailty",
                         navset_tab(
                           
                           nav_panel("Pre WADER Data",
                                     p("BE PATIENT - POINTS ARE LOADING"),
                                     display_mapUI("wqpoints",
                                                   heading = "Water sampling points",
                                                   description = "Sample data collected to monitor water quality",
                                                   map_info = wqd_df)),
                           nav_panel("Woodlands",
                                     p( "                   "),
                                     display_mapUI( "WOODS",
                                                    heading = "Woodland planting",
                                                    map_info = wood_df)),
                           nav_panel("Harehope",
                                     p( "                   "),
                                    h2( "Harehope River Restoration"),
                                     p("Pre and post restoration drone data exists including imagery, and LIDAR data. 
                                                      The associated data are extremely large and are therefore not included here. 
                                                      For more information regarding the UAV data please get in touch with XYZ."),
                                     display_mapUI( "HH",
                                                   heading="",
                                                    map_info = harehope_df),
                                     h2("Reports and associated information"),
                                     p(" The below table lists associated reports and datasets that are associated with this project"),
                                     DT::dataTableOutput("hh_rep")),
                           nav_panel("Wetlands",
                                     p( "                   "),
                                     display_mapUI( "WET",
                                                    heading = "Wetland creation",
                                                    map_info = wet_df), 
                           h2("Reports and associated information"),
                           p(" The below table lists associated reports and datasets that are associated with this project"),
                           DT::dataTableOutput("wet_rep")),
                         
                           nav_panel("WFD",
                                     
                                     display_mapUI("WFD",
                                                   heading = "Water Frameworks Directive",
                                                   description = "Environment agency data from WFD",
                                                   map_info = northumbria_wfd_df)))),
                tabPanel( "C2: Oppourtunisitic Macroalgae",
                          display_mapUI("OMDAT",
                                        heading = "Opportunistic Macroalgae data",
                                        description = "Data for Opportunistic Macroalgae",
                                        map_info = om_df)),
                
                tabPanel("C3: Wildlife Disturbance",
                         display_mapUI("WDDAT",
                                       heading = "Wildlife Disturbance Data",
                                       description = "Data for Wildlife Disturbance",
                                       map_info = wd_df)),
                
                tabPanel("C5: Invasive Species",
                         
                         navset_tab(
                           nav_panel("Pre WADER Data",
                                     display_mapUI("IAS",
                                                   heading = "Invasive Species Data",
                                                   description = "Data for INNS",
                                                   map_info = ias_df)),
                           nav_panel("WADER Project Data",
                                     p( "                   "),
                                     display_mapUI( "iaswader",
                                                    heading = "Invasive Species Data",
                                                    map_info = iaswader_df
                                                    
                                     )))))),
    
    nav_panel(title= div(img(src = "LW_logo_green.png", width = "auto", height = "50"),"Protected Area View"), 
              p("Explore WADER data based on the Protected area that you are interested in."),
              p(" The data shown here were largely collected prior to the WADER project as part of standard monitoring programmes or as part of protected area condition monitoring. 
                The data displayed here under the datasets tab are those that were mad available for the WADER project. Much of the information provided to inform the WADER project baseline were reports that informend condition monitoring, these can be seen under the Reports tab.
                Where the underlying data that these reports were based on were not provided they are not detailed here."),
              navlistPanel(
                id = "tabset",
                tabPanel("River Tweed SAC ",
                         navset_tab(
                           nav_panel( "Datasets",
                                      display_mapUI("RTSAC",
                                                    heading = "River Tweed SAC Data",
                                                    description = "Data for River Tweed SAC",
                                                    map_info = rt_sac_df)),
                           nav_panel( "Reports",
                                      p("display the reports and link to sharepoint"),
                                      DT::dataTableOutput("rt_rep")
                                      
                           ))),
                
                tabPanel("Tweed Estuary SAC",
                         navset_tab(
                           nav_panel( "Datasets",
                                      display_mapUI("TESAC",
                                                    heading = "Tweed Estuary SAC Data",
                                                    description = "Data for Tweed Estuary SAC",
                                                    map_info = te_sac_df)),
                           nav_panel( "Reports",
                                      
                                      DT::dataTableOutput("te_rep")
                                      
                           ))),
                
                
                tabPanel("North Northumberland Dunes SAC",
                         navset_tab(
                           nav_panel( "Datasets",
                                      display_mapUI("NNDSAC",
                                                    heading = "North Northumberland Dunes SAC Data",
                                                    description = "Data for North Northumberland Dunes SAC",
                                                    map_info = nnd_sac_df)),    
                           nav_panel( "Reports",
                                      
                                      DT::dataTableOutput("nnd_rep")
                                      
                           ))),
                
                tabPanel("Berwickshire North Northumberland Coast SAC",
                         tabPanel("Budle Bay bathymetric",
                                  h2("Detailed modelling by Steve for Budle Bay"),
                                  p("Select spatial resolution"),
                                  radioButtons("budle_res", "Select resolution", c("50m", "75m", "100m")),
                                  leafletOutput("raster_map"),
                                  p(),
                                  p("Data download is R internal RDS format. Use readRDS to input into R."),
                                  downloadButton("download_rast", "Download RDS"))),
                tabPanel("Lindisfarne SPA"),
                tabPanel("Northumbria Coast SPA")
              )
    )
  ),
  
  tags$head(tags$style(".leaflet-top {z-index:999!important;}")))



# Define server logic 
server <- function(input, output) {
  
  
  
  display_raster <- function(selected_region, raster_df){
    this_choice <- filter(raster_df, selected_region == selection)
    output$raster_map <- renderLeaflet({
      leaflet() %>%
        addTiles() %>%
        addProviderTiles(providers$Esri.WorldImagery,
                         options = providerTileOptions(noWrap = TRUE)
        ) %>%
        addRasterImage(get(this_choice[1,"ll_map"]), colors=topo.colors(25, alpha = 0.5))
    })
    output$download_rast <- downloadHandler(
      filename = function() {
        paste0(input$download_rast, ".RDS")
      },
      content = function(file) {
        saveRDS(get(this_choice[1, "os_map"]), file)
      })
  }
  
  observeEvent(input$budle_res, {
    selected_res <- input$budle_res
    display_raster(selected_res, budle_df)
  })
  
  
  display_mapServer("region", region_df)
  # display_mapServer("budle", budgle_df, type = "raster") # Needs doing
  display_mapServer("WFD", northumbria_wfd_df)
  display_mapServer("wqpoints",wqd_df)
  display_mapServer("wqwader",wqwader_df)
  display_mapServer("RTSAC",rt_sac_df)
  display_mapServer("TESAC",te_sac_df)
  display_mapServer("NNDSAC",nnd_sac_df)
  display_mapServer("WDDAT", wd_df)
  display_mapServer("iaswader",iaswader_df)
  display_mapServer("IAS", ias_df)
  display_mapServer("OMDAT", om_df)
  display_mapServer("HH",harehope_df)
  display_mapServer("WOODS", wood_df)
  display_mapServer("WET", wet_df)
  
  
  # display all data on an interactive map
  output$mapall <- renderTmap({
    
    tm_shape(hibb_wqd_po)+tm_dots(fill = "#2AA198")+
      tm_shape(ndt_spat_po)+tm_dots()
  })
  
  output$rt_rep <- DT::renderDataTable(rt_rep_tab,escape = FALSE)
  output$te_rep <- DT::renderDataTable(te_rep_tab,escape = FALSE)
  output$bnnc_rep <- DT::renderDataTable(bnnc_rep_tab,escape = FALSE)
  output$nnd_rep <- DT::renderDataTable(nnd_rep_tab,escape = FALSE)
  output$hh_rep <- DT::renderDataTable(hh_rep_tab,escape=FALSE)
  output$wet_rep <- DT::renderDataTable(wet_rep_tab, escape = FALSE)
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)
