setwd("~/GitHub/BTB-mapping")
path <- getwd()

# install / load packages
l <- c("splancs","geoR","lattice","raster","OpenStreetMap","spatstat","caret","dplyr","lgcp")
#l <- c("splancs","geoR","lattice","raster","OpenStreetMap","spatstat","caret","dplyr")
#install.packages(l)
lapply(l, require, character.only = TRUE)


# load & transform data
load(file = paste0(path,"/Data/spatio_temporal_prediction.RData"))
load(file = paste0(path,"/Data/spatial_prediction.RData"))
load(file = paste0(path,"/Data/BTBppp.RData"))
load(file = paste0(path,"/Data/farmspdf.RData"))
ncmap <- openmap(upperLeft = c(lat = 50.94028, lon = -5.760212), 
                 lowerRight = c(lat = 49.94531, lon = -4.145465), type = "stamen-toner")
sdmc <- osppp2merc(pppdata) # requires lgcp package


# map
source(file = paste0(path,"/Code/BTBmap_prep_multi.R"))
source(file = paste0(path,"/Code/BTBmap_name.R"))
cat <- c("09", "12", "15","20")
h_name_s <- c("GPMCheat09.png","GPMCheat12.png","GPMCheat15.png","GPMCheat20.png")
s_name_s <- c("GPMCseg05.png","GPMCseg07.png","GPMCseg09.png")
h_name_t <- heat_names(n_year = 14, cat = cat)
s_name_t <- seg_name(n_year = 14, cutoff = 0.5)
co <- c(0.5,0.7,0.9)
cpal <- rev(heat.colors(64, alpha = 0.5))
cols <- c(transblue(0.2), transgreen(0.2), transblack(0.2), transred(0.2)) # requires lgcp package
#cols <- c("blue", "green", "black", "red")


setwd(paste0(path,"/Output/Plot"))
# spatial
for (i in 1:3){
  segregation_map(pred_values = pred_s, n_class = 4, name = s_name_s[i], cutoff = co[i])
}
heatmap(pred_values = pred_s, gr = gr*100, n_class = 4, filenames = h_name_s)

# spatio temporal
for (i in 1:14) {
  segregation_map(pred_values = pred_t[[i]], n_class = 4, name = s_name_t[i], cutoff = 0.5)
}
for (i in 1:14) {
  heatmap(pred_values = pred_t[[i]], gr = gr*100, n_class = 4, filenames = h_name_t[[i]])
}
