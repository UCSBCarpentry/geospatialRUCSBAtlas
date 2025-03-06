# map 11
# look at a dibble

library(terra)

dibblee_gol <- rast("07gGoleta/DB0007.tif")
dibblee_gol <- rectify(dibblee, method="bilinear")

plot(dibblee_gol)
plotRGB(dibblee_gol)

dibblee_gav <- rast("16gSolvangGaviota/DB0016.tif")
dibblee_gav <- rectify(dibblee, method="bilinear")

plot(dibblee_gav)
plotRGB(dibblee_gav)
