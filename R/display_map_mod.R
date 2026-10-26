# Shiny module for map display and data download. As this is likely to be a
# common pattern for many datasets, might be simplest as a module

# Needs doing for display_mapUI
# add a parameter 'type' that defaults to 'type = "vector"' but accepts "raster"
display_mapUI <- function(id, heading, description, map_info){
  ns <- NS(id)
    tagList(
      h2(heading),
      p("Select a dataset to view a sample of the data avialiable within the file. Where datasets are large a small subset will be shown for demonstration purposes. Full datasets can be downloaded for investigation."),
      selectInput(NS(id, "radio"), "Select dataset", choices = map_info$selection),
      p(strong("The Data being displayed are:")),
      textOutput(NS(id,"descript")),
      tmapOutput(NS(id, "leaflet_map"), height = "500px"),
      p(strong("Data Preview")),
      textOutput(NS(id,"map_tab_deets")),
      DT::dataTableOutput(NS(id,"map_tab")),
     
#      downloadButton(NS(id, "download_R"), "Download RDS")
      actionButton(
        inputId = ns("action"),
        label = "get data",
        icon = icon("download")
      ),
    p("Additional information")
    )
}

# Needs doing. Add parameter 'type' and alter code to display raster map.
# Alternatively, add a flag in the map_info data.frame.
display_mapServer <- function(id, map_info){
  moduleServer(id, function(input, output, session){
    
    observeEvent(input$radio, {
      this_choice <- filter(map_info, input$radio == selection)
      this_ll_map <- get(this_choice[1, "ll_map"])
      this_os_map <- get(this_choice[1, "os_map"])
      this_typ_map <- this_choice[1,"typ_map"]
      this_typ_tab <- get(this_choice[1,"typ_df"])

      descript <- this_choice[1,"description"]
      # output$leaflet_map <- renderLeaflet({
      #   leaflet() %>%
      #     addTiles() %>%
      #     addProviderTiles(providers$Esri.WorldImagery,
      #                      options = providerTileOptions(noWrap = TRUE)
      #     )  %>%
      #     addFeatures(this_ll_map)
      
      # change map code depending on input type - points/polygons/lines etc.
      
      
        if (this_typ_map =="points"){
        output$leaflet_map <- renderTmap({
          
          tm_shape(this_ll_map)+tm_dots(fill = "#CB4B16", size = 0.6)+
            tm_basemap("OpenStreetMap")
        
      })
        }
      if(this_typ_map =="lines"){
        
        output$leaflet_map <- renderTmap({
          
          tm_shape(this_ll_map)+tm_lines(col = "#CB4B16")+
            tm_basemap("OpenStreetMap")
        })
      }
   
      if(this_typ_map=="polygons"){
        #tmap_options(check.and.fix = TRUE)
          output$leaflet_map <- renderTmap({
            
            tm_shape(this_ll_map)+tm_polygons(fill_alpha = 0.6, col = "#CB4B16")+
              tm_basemap("OpenStreetMap")
          })
        }
      # cat(file=stderr(), "this_map is", class(this_os_map), "\n")
      
output$map_tab <- DT::renderDataTable({table <- head(this_typ_tab)
DT::datatable(table, options = list(scrollX = TRUE, fixedHeader = TRUE))
  }) 
output$map_tab_deets <- renderText(paste0 ("The data contains ",dim(this_typ_tab)[1], " observations of ",dim(this_typ_tab)[2], " variables, a sample of which can be seen in the below table."))

output$descript <- renderText(descript)
      
      ns <- NS(id)
      observeEvent(input$action, {

          showModal(
            modalDialog(
              title = NULL,
              h3("Download the file?"),
              footer = tagList(
                downloadButton(
                  outputId = ns("download")
                ),
                modalButton("Cancel")
              )
            )
          )
        }
      )
      output$download <- downloadHandler(
        filename = function() {
          paste0("WADERdata-", Sys.Date(), ".csv",sep="")
        },
        content = function(file) {
          write.csv(this_typ_tab, file)
        })

    })


  })
}

