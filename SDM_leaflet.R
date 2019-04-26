# Install Required Packages 
install.packages(c("shiny", "rgdal", "sp", "leaflet", "geojsonio"))

# Load Required Packages
packagelist <- c("shiny", "rgdal", "sp", "leaflet", "geojsonio")  
lapply(packagelist, require, character.only = TRUE)

# C:/Users/htdavis/Desktop/pronghorn/results/json

targets <- readOGR("C:/Users/htdavis/Desktop/pronghorn/targets.shp")
targets <- spTransform(targets, CRS("+proj=longlat +datum=WGS84"))

directory <- function ()
{
  n <- readline(prompt = "Enter path to folder containing raster files: ")
  return(n)
}

setwd(print(directory()))

filenames <- list.files(pattern=".json")
for (i in 1:length(filenames)) assign(filenames[i], readLines(filenames[i]))
target <- readOGR("C:/Users/htdavis/Desktop/pronghorn/targets.shp")
target <- spTransform("+init=epsg:4326 +proj=longlat +ellps=WGS84 ")

map<-leaflet() %>% 
  setView(lng = -113.0, lat = 32.6, zoom = 10) %>%
  addTiles(group="Default") %>%
  addProviderTiles('Esri.WorldImagery', group="Imagery") %>% 
  addTopoJSON(January.json, weight = 0, fillOpacity=.5, fillColor = "#FFFF00", group="January") %>%
  addTopoJSON(February.json, weight = 0, fillOpacity=.5, fillColor = "#FFFF00", group="February") %>%
  addTopoJSON(March.json, weight = 0, fillOpacity=.5, fillColor = "#FFFF00", group="March") %>%
  addTopoJSON(April.json, weight = 0, fillOpacity=.5, fillColor = "#FFFF00", group="April") %>%
  addTopoJSON(May.json, weight = 0, fillOpacity=.5, fillColor = "#FFFF00", group="May") %>%
  addTopoJSON(June.json, weight = 0, fillOpacity=.5, fillColor = "#FFFF00", group="June") %>%
  addTopoJSON(July.json, weight = 0, fillOpacity=.5, fillColor = "#FFFF00", group="July") %>%
  addTopoJSON(August.json, weight = 0, fillOpacity=.5, fillColor = "#FFFF00", group="August") %>%
  addTopoJSON(September.json, weight = 0, fillOpacity=.5, fillColor = "#FFFF00", group="September") %>%
  addTopoJSON(October.json, weight = 0, fillOpacity=.5, fillColor = "#FFFF00", group="October") %>%
  addTopoJSON(November.json, weight = 0, fillOpacity=.5, fillColor = "#FFFF00", group="November") %>%
  addMarkers(data=targets, popup=~as.character(target_id), group="Targets") %>%
  addTopoJSON(December.json, weight = 0, fillOpacity=.5, fillColor = "#FFFF00", group="December") %>%
  addTopoJSON(boundary.json, color = "#000000", weight=3, fillOpacity = 0, group = "Boundary") %>%
  # Layers control
  addLayersControl(
    baseGroups = c("Default", "Imagery"),
    overlayGroups= c("January", "February", "March", "April", "May", "June", "July", "August", "September",
                     "October", "November", "December", "Boundary", "Targets"),
    options = layersControlOptions(collapsed = FALSE))
  
  


map %>% hideGroup(c("February", "March", "April", "May", "June", "July", "August", "September",
                    "October", "November", "December"))

