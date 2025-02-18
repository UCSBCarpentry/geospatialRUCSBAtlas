

# geospatialRUCSBAtlas

A repo that uses local UCSB examples applied to all of the steps of the
Carpentries' Intro to Raster and Vector Data workshop.

Scripts run parallel to the episodes (ep_01.r ep_02.r ... ep_13.r) and create maps
'suitable for publication' (map01.r, map02.r, ... map12.r) as laid out in Maps 1 thru 7
below.

The goals are to produce nice atlas pages of campus that use all of
the techniques covered in the Intro to GeoSpatial R Carpentry lesson.
(Maybe not the NDVI over time, since we've never ever done that
episode.)

We have created a [Data Dictionary](datadictionary.md) to help us keep
track of names.

## Getting Started

1: Clone this repo. 

2: Run `new_data_prep.r` This script downloads the filder `data.zip` from
our Carentry Google drive into a `downloaded_data` directory), and unzips
it into `source_data`

3: Now you can run `run_every_episode.r` or `run_ever_map.r` to produce output
from these data sources. Any data that an episode writes is
placed in `output_data` and any formated maps are placed in `images`.

4: Script away! Feel free to tackle issues, express issues, or just
do work if you see work that needs to be done.

5: Episode scripts produce a number of maps, but not
particularly well formatted. They are formated as in the Lesson, with 
the addition of ggtitles to keep track of where they are generated.

All outputs from map scripts should have a 3 tall x 4 wide 
aspect ratio, except where noted.

### Map 1. A wide view of campus with

(issue #7)

-   Extent should be the same as #3 inset of map 7.
-   NCOS – for now the new lagoon habitat shapefile
-   Water
-   Bathymentry and elevation in one layer
    -   hillshade
-   walkways – using bike paths for now
-   buildings – for context
-   vernal pools:
    -   vector data to be create via analysis from DEMs
    -   this will come later 
    
Something like this:
![Map 1 DRAFT](/images/map1.3.png "Map 1.3")

### Map 2 A stylized thematic map with trees, water, and bikeways

(Issue #8) ![map 2 with tree
species](/images/map2_TreeSpecies.png "Map 2 tree height")Trees from
ArcGIS Online: Water: NCOS upper lagoon shapefile of bathymetric topo
lines or polygons is it this [bird habitat
file?](https://drive.google.com/file/d/1ssytmTbpC1rpT5b-h8AxtvSgNrsGQVNY/view?usp=drive_link)
– yes bird habitats

### Map 3 An atlas page layout with 4 insets:
Each inset (4-5-6) is a png created by map4-5-6.r.
The final ggplots in that script are the inputs for
map 3.

#### map 4 California Overview
Portrait 3x4
Western US

#### map 5 The Bite of California
Portrait 3x4
Needs to be further zoomed in. 

#### map 6 Extended Campus
(issue #14)
Landscape 4x3 \* extended campus will have maptiles background? \*
Bacara-ish to 154/101 

Maps 4-5-6: ![Triplet zoom in](/images/3-zoom.png "Draft zoom.")

#### Map 7 Campus Detail
Wide Landscape 9x16ish? \* A stripped down version of #1


### Map 3 sketch:
![Overview map](/images/overview_map.jpg "Sketch")


### 8 RS Imagery
Include a Planet feed. (Issue #15)
For starters, this will be several pre-fetched campus images.
4- and 8- bands!


### 9 Analysis: Find landscape depressions on Campus DEM
ie: identify vernal pools

### 10 Analysis: Find bike paths that cross water?

### Map 12  / Episode 12: 12 months of NDVI Raster Stack
[UCSB Carpentry](https://ucsbcarpentry.github.io)

[Original lesson -- Introduction to Geospatial Raster and Vector Data
with R](https://datacarpentry.org/r-raster-vector-geospatial/)
