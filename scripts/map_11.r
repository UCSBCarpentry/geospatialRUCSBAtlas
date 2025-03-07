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