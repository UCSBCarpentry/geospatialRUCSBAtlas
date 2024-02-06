# geospatialRUCSBAtlas
A repo that uses local UCSB examples applied to all of the steps of the Carpentries' R for GeoSpatial workshop.

Scripts run parallel to the episodes of Raster and Vector Data with R Data Carpentry.
The goal is to produce several nice atlas pages of campus that use all the techniques
covered in the Intro to GeoSpatial R Carpentry lesson. (Maybe not the NDVI over time, 
since we've never ever done that episode.)

1: The repo is set up with a `source_data` folder

`source_data` is *.* git ignored, so it's probably not going to
get made automatically.

2: Run `data_prep.r`
The goal is for this script to download raw data (into a 
`downloaded_data` directory), unzips, and preps
any data that's required for the rAtlas. Its outputs
go into `source_data`

3: now each episode and map should run nicely, opening input data from the `source_data` directory


The narrative of the lesson produces a number of maps, but not particularly 
well formatted. We'll have 7 well-formatted maps that exist as a shadow to the 
lesson narrative. 

All have a 3 tall x 4 wide aspect ratio

###  1. A wide view of campus with
  * Extent should be the same as #3 inset of map 7.
  * NCOS
  * Water
  * Bathymentry and elevation
  * hillshade
  * walkways
  * buildings
![](/images/complicated_thematic_map.jpg)

November 28 test push.

### 2 A stylized thematic map with trees, water, and bikeways
![Stylized, minimalistic](/images/limited_thematic_map.jpg "Sketch")

### 3 An atlas page layout with 4 insets:
#### 4 California
Vertical
#### 5 The Bite of California
Vertical
#### 6 Extended Campus
Landscape
  * extended campus will have maptiles background
  * Bacara(?) or El Capitan to Modoc/State
#### 7 
Landscape
  * A stripped down version of #1
  * Include a Planet feed. (Issue #15)

![Overview map](/images/overview_map.jpg "Sketch")
Here's the beginning of a piece:
![Triplet zoom in](/images/3-zoom.png "Draft zoom.")


[UCSB Carpentry](https://ucsbcarpentry.github.io)

[Original lesson --  Introduction to Geospatial Raster and Vector Data with R](https://datacarpentry.org/r-raster-vector-geospatial/)

