# geospatialRUCSBAtlas
A repo that uses local UCSB examples applied to all of the 
steps of the Carpentries' Intro to Raster and
Vector Data workshop.

Scripts run parallel to the episodes (ep_1.r ep_2.r ...) and create
maps 'suitable for publication'. (map1.r, map2.r) as laid our Maps 1 thru 7 below.

The goal is to produce several nice atlas pages of campus that use all the techniques
covered in the Intro to GeoSpatial R Carpentry lesson. (Maybe not the NDVI over time, 
since we've never ever done that episode.)

We have created a [Data Dictionary](datadictionary.md) to help us keep track of names.

## Getting Started
1: The repo is set up with a `source_data` folder

`source_data` is *.* git ignored, so it's probably not going to
get made automatically.

2: Run `data_prep.r`
The goal is for this script to download raw data (into a 
`downloaded_data` directory), unzips, and preps
any data that's required for the rAtlas. Its outputs
go into `source_data`

3: now each episode and map should run nicely, 
  opening input data from the `source_data` directory. Any data that
  an episode writes should be placed in `output_data`


The narrative of the lesson produces a number of maps, but not particularly 
well formatted. We'll have 7 well-formatted maps that exist as a shadow to the 
lesson narrative. 

All have a 3 tall x 4 wide aspect ratio, except where noted

###  Map 1. A wide view of campus with
  * Extent should be the same as #3 inset of map 7.
  * NCOS
  * Water
  * Bathymentry and elevation in one layer
  * hillshade
  * walkways
  * buildings
  * vernal pools: vector data to be create via analysis from DEMs
![](/images/complicated_thematic_map.jpg)
![](/images/map1.1.png)



### Map 2 A stylized thematic map with trees, water, and bikeways
(Issue #8)
![map 2 with tree height](/images/map2_TreeHeight.png "Map 2 tree height")
![map 2 with tree species](/images/map2_TreeSpecies.png "Map 2 tree height")
![Stylized, minimalistic](/images/limited_thematic_map.jpg "Sketch")
Trees from ArcGIS Online: 
Water: NCOS upper lagoon shapefile of bathymetric topo lines or polygons
is it this [bird habitat file?](https://drive.google.com/file/d/1ssytmTbpC1rpT5b-h8AxtvSgNrsGQVNY/view?usp=drive_link)

### Map 3 An atlas page layout with 4 insets:

#### map 4 California
Vertical 3x4

#### map 5 The Bite of California
Vertical 3x4

#### map 6 Extended Campus
Landscape 4x3
  * extended campus will have maptiles background
  * Bacara(?) or El Capitan to Modoc/State

#### 7 Campus Detail
Landscape
  * A stripped down version of #1


![Overview map](/images/overview_map.jpg "Sketch")

Maps 4-5-6:
![Triplet zoom in](/images/3-zoom.png "Draft zoom.")


![Triplet zoom in](/images/zoom_in_first_results.png "Draft zoom.")




Include a Planet feed. (Issue #15)



[UCSB Carpentry](https://ucsbcarpentry.github.io)

[Original lesson --  Introduction to Geospatial Raster and Vector Data with R](https://datacarpentry.org/r-raster-vector-geospatial/)

