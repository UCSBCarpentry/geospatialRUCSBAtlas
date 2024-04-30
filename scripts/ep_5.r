# episode 5
# multi-band rasters
# ie: color


library(terra)
library(tidyverse)
# library(sf)
library(raster)



# do we still need raster in this lesson?
# yes. for now. 
natural_color <- raster("source_data/w_campus_1ft/w_campus_1ft.tif")
natural_color_terra <- rast("source_data/w_campus_1ft/w_campus_1ft.tif")


# rast comes from terra
# it makes a SpatRaster object
# natural_color <- rast("source_data/w_campus_1ft.tif")

NCOS <- rast("source_data/NCOS_07_25-26_2023.tif")


# can do the quickplot, it's a bit mysterious
plot(NCOS)
plot(natural_color)

str(natural_color)
class(natural_color)

# outputting it to stdout shows how
# many bands (5 and 4).
natural_color
NCOS

# brick maybe no more. it's from raster
# a brick is a new class for us
# nl is the number of layers it should expect.
natural_color_brick <- brick("source_data/cirgis2020/w_campus_1ft.tif", nl=5)
natural_color_brick

plotRGB(natural_color_brick)


# we also have raster stack
natural_color_stack <- stack("source_data/cirgis2020/w_campus_1ft.tif")

NCOS_stack <- stack("source_data/NCOS_07_25-26_2023.tif")

# still has 5 channels
natural_color_stack

# still has 4 channels
NCOS_stack

plotRGB(NCOS, r=1, g=2, b=3)

plotRGB(natural_color)

plotRGB(natural_color, stretch = "lin")
plotRGB(natural_color, stretch = "hist")


plotRGB(natural_color,
        r = 1,
        g = 2, 
        b = 3)

plotRGB(natural_color,
        r = 2,
        g = 3, 
        b = 4)

plotRGB(natural_color,
        r = 3,
        g = 4, 
        b = 5)

plotRGB(natural_color,
        r = 3,
        g = 2, 
        b = 1)

# the metadata shows 5 bands. How 
# about nodata value?

# as we did in ep. 1
GDALinfo("source_data/cirgis2020/w_campus_1ft.tif")

# we can also use >describe<
# but that doesn't work for this file.
describe("source_data/cirgis2020/w_campus_1ft.tif")

# SpatRasterDataset
# comes from terra
natural_color_sds <- sds(natural_color)

# later we will stack up some SkySat imagery into a time series.


# ##################################
# take 2
# Alternate path preparing better for
# episode 12
# we can do this with SkySat!
SkySatPanSharp_B <- brick("source_data/SkySatCollect/20161210_185631_ssc3_u0001_pansharpened_clip.tif")
SkySatPanSharp_S <- stack("source_data/SkySatCollect/20161210_185631_ssc3_u0001_pansharpened_clip.tif")


# stdout shows 4 bands
plotRGB(SkySatPanSharp_B, r=1, g=2, b=3, scale=1932)
