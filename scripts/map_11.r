# map 11
# look at a dibble

library(terra)

dibblee_gol <- rast("07gGoleta/DB0007.tif")
dibblee_gol <- rectify(dibblee_gol, method="bilinear")
dibblee_gol

plot(dibblee_gol)
plotRGB(dibblee_gol)

dibblee_gav <- rast("16gSolvangGaviota/DB0016.tif")
dibblee_gav <- rectify(dibblee_gav, method="bilinear")

plot(dibblee_gav)
plotRGB(dibblee_gav)
collar <- read.delim("07gGoleta/DB0007.tif.txt", sep="\t", header = FALSE)
str(collar)
collar_df <- as.data.frame(collar)
str(collar_df)

collar_vect <- vect(collar)
## Jon is thinking this is a georeferencing table -- not a definition of the collar

# Crop extent from lat/long on the map corners:
# NW corner: 34° 30' 00" N (34.500) / 119° 52' 30" W (-119.875) 
# NE corner: 34° 30' 00" N (34.500) / 119° 45' 00" W (-119.750)
# SE corner: 34° 22' 30" N (34.375) / 119° 45' 00" W (-119.750)
# SW corner: 34° 22' 30" N (34.375) / 119° 52' 30" W (-119.875) 
ll_ext <- ext(-119.875, -119.750, 34.375, 34.500)

# make a vector to reproject form lat/long to utm 
ll_vec <- as.polygons(ll_ext, crs="EPSG:4326")
utm_ext <- ext(project(ll_vec, "EPSG:32611"))

# do the crop
crop_dibblee_gol <- crop(dibblee_gol, utm_ext)
plotRGB(crop_dibblee_gol)
