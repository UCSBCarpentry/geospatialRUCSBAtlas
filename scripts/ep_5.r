# episode 5
# multi-band rasters
# grab a landsat scene?

library(raster)
library(tidyverse)
library(sf)

# bring in an overview map 


natural_color <- raster("source_data/cirgis2020/w_campus_1ft.tif")

# can do the quickplot, but it don't make much sense
plot(natural_color)

str(natural_color)
class(natural_color)

# outputting it to stdout shows how
# many bands.
natural_color

# also nbands()
nbands(natural_color)

# a brick is a new class for us
# nl is the number of layers it should expect.
natural_color_brick <- brick("source_data/cirgis2020/w_campus_1ft.tif", nl=5)
natural_color_brick

plotRGB(natural_color_brick)


# we also have raster stack
natural_color_stack <- stack("source_data/cirgis2020/w_campus_1ft.tif")
# still has 5 layers
natural_color_stack

plotRGB(natural_color_stack)

plotRGB(natural_color_stack, stretch = "lin")
plotRGB(natural_color_stack, stretch = "hist")


plotRGB(natural_color_stack,
        r = 1,
        g = 2, 
        b = 3)

plotRGB(natural_color_stack,
        r = 2,
        g = 3, 
        b = 4)

plotRGB(natural_color_stack,
        r = 3,
        g = 4, 
        b = 5)

plotRGB(natural_color_stack,
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
