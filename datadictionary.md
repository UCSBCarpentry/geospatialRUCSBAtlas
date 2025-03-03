# Data Dictionary

This is a list of all the data required for the 12 maps 
and 13 episodes described on the 
[Read Me](https://github.com/UCSBCarpentry/geospatialRUCSBAtlas/blob/main/README.md), along with notes regarding where they appear into the episode flow.

We're still not sure if we have everything we need. 

Items from the Carpentry Google Drive are downloaded as a single zip folder
by new_data_prep.r. They are currently stored in
`\\Carpentry\Workshop Development\Local Data for Workshops\geo`

If you need to add anything, zip up your source_data folder and replace the
zip archive on Google Drive.

We will someday move away from keeping them there. 
Perhaps build a zenodo package at the end of our exercise?
For now, we have 1 zip package up there. 

Eventually it will come with a OCFL manifest

* Hillshades at 3 scales and extents:
  * Campus and the surrounding area
  * The Bite of California
  * The Western United States

## DEM sources
Links are to their original source:
  * The Western United States
  * [The Bite of California](https://www.sciencebase.gov/catalog/item/542aebf9e4b057766eed286a)
    Elevation in the Western United States, 90 meter DEM, subsetted to CA
  * [Campus context: campus_DEM](https://drive.google.com/drive/folders/1_NWRIonW03jm5MdP9tq-zJjkfDjFCWEm?usp=drive_link)
  * campus_DEM gets made over and over. 
    The elevation field each time gets renamed from greatercampusDEM_1_1 to elevation 
    as in episode 1: 
    `names(campus_DEM_df)[names(campus_DEM_df) == 'greatercampusDEM_1_1'] <- 'elevation'`
  * [Henley Gate to Ellwood Beach: campus_topo_bath](https://pubs.usgs.gov/ds/781/)
    * California State Waters Map Series, Offshore of Coal Oil Point, Block ID 63

### The 3 files:
  * << linkies please >>



## Map 1
* we could use a my_crs here.
* Shapefiles
  * Walkways
  * Buildings
    * Campus_Buildings.shp
    * [Carpentry Google Drive](https://drive.google.com/drive/folders/1SwcCrBoa0a7I_kmBNCa3_zNQ6Aw9P-8H)
    Metadata says this came from the ICM on AGO circa 2017'ish.
  * Trees
    * From campus AGO:
      * https://ucsb.maps.arcgis.com/home/item.html?id=c6eb1b782f674be082f9eb764314dda5

      * URL of the service is actually: https://services1.arcgis.com/4TXrdeWh0RyCqPgB/arcgis/rest/services/Treekeeper_012116/FeatureServer/

  * Bike paths: 
     * original filename: bikelanescollapsedv8.shp
     * source_data/bike_paths/bike_paths.shp
     * DREAM Lab data drive collection
  * Vernal pools
     * will be created by analysis in a script.
  * Rasters
  * Planet SkySat images?
  
### Object list
"campus_bath"        
"campus_DEM"          
"campus_bathotopo" -- the above merged()
"campus_bath_df"      
"campus_DEM_df"       
"sea_level"           
"sea_level_0"        
"campus_hillshade_df"
"campus_projection"   -- this is whatever campus_DEM is when it comes out of episode 1.
"custom_bath_bins"   
"custom_bins"         
"custom_DEM_bins"    
"custom_sea_bins"     
"sea_level_df"  
"bikeways"            
"buildings"  
"iv_buildings"
"habitat"             


## Map 2
* Trees
* Water
* Bikeways
* Pirate MapBox themed basemap?

### Object list
* biked_df
bikes
bikes_crop
bikes_lines
bikes_proj    
coastline      
coastline_crop
coastline_proj
ext_trees
ht_0          
"new_ext"        
"perc_0"
streams
streams_crop
top5_species


### output gggraphics:
   ** "map2_v1"        "map2_v2"        "map2_v3"        "map2_v4"        "map2_v5"       


## Map 3: Page with 4 insets
Most of these will be used in Episodes 1 and 2

### Object list
 "bath_clipped"       "bath_df"            "bath_rast"          "campus_bath_df"    
 "campus_border"      "campus_border_poly" "campus_DEM"         "campus_DEM_df"     
 "custom_bath_bins"   "custom_bins"        "reprojected_bath"  

### Map 4-5-6: 
* Zoom in to site
  * Western North America
  * Bite of California
  * Extended Campus
* with little red extent boxes indicating the areas of zoom

#### Ojbect list
 "aligned_zoom"        "campus_DEM"          "campus_extent"       "campus_hillshade"   
 "grays"               "campus_crs"              "places"              "tryptic"            
 "world"               "zoom_1"              "zoom_1_df"           "zoom_1_extent"      
 "zoom_1_plot"         "zoom_2"              "zoom_2_aspect"       "zoom_2_cropped"     
 "zoom_2_df"           "zoom_2_extent"       "zoom_2_hillshade"    "zoom_2_hillshade_df"
 "zoom_2_plot"         "zoom_2_slope"        "zoom_3"              "zoom_3_df"          
 "zoom_3_fake_aoi"     "zoom_3_hillshade_df" "zoom_3_plot" 
 
 ## Map 7
 
 ## Map 8
 ###Current planet image
 Initially, we will use pre-packaged downloaded images from Planet.
 4- or 8-channel imagery will maps directly to the RGB- and 
 NDVI- portions of the lesson (Episodes 5 and 12)
 
 ## Map 11
 ### Re-projecting rasters
 Episode 3s and 11 is where this happens in the lesson.
 3 is re-projecting
 11 is cropping to a vector
 There is a purposeful mis-match in the lesson between the hillshades
 and the elevations. What should be our equivelent?
 We have already encountered projection mis-matches in any number of 
 maps before here.but should we make one up?
 Ep 3: Project to overlay Planet raster under / over the campus hillshade?
 Ep 11: Crop as we do in Map 4-5-6?

### Objects
campus_crs: the native CRS of campus_DEM

 
 ## Map 12
 aligns with Episode 12
 
 ### Object list
 
# Episode by Episode

## ep 1: Starting with rasters

  * [Campus context: campus_DEM](https://drive.google.com/drive/folders/1_NWRIonW03jm5MdP9tq-zJjkfDjFCWEm?usp=drive_link)
  * For the campus DEM, the elevation field should be renamed from greatercampusDEM_1_1 to elevation with the following code in episode 1: 
    * names(campus_DEM_df)[names(campus_DEM_df) == 'greatercampusDEM_1_1'] <- 'elevation'

find another one with NA's if this one doesn't have any

## ep 2: Raster Data
  * [Henley Gate to Ellwood Beach: campus_topo_bath](https://pubs.usgs.gov/ds/781/)
  * [The Bite of California](https://www.sciencebase.gov/catalog/item/542aebf9e4b057766eed286a)
  * [Campus context: campus_DEM](https://drive.google.com/drive/folders/1_NWRIonW03jm5MdP9tq-zJjkfDjFCWEm?usp=drive_link)
  * For the campus DEM, the elevation field should be renamed from greatercampusDEM_1_1 to elevation with the following code in episode 1: 
    * names(campus_DEM_df)[names(campus_DEM_df) == 'greatercampusDEM_1_1'] <- 'elevation'
    
## ep 3: Projections

## ep 4: Raster Data
  * [Henley Gate to Ellwood Beach: campus_topo_bath](https://pubs.usgs.gov/ds/781/)
  * [The Bite of California](https://www.sciencebase.gov/catalog/item/542aebf9e4b057766eed286a)
  * [Campus context: campus_DEM](https://drive.google.com/drive/folders/1_NWRIonW03jm5MdP9tq-zJjkfDjFCWEm?usp=drive_link)
  * For the campus DEM, the elevation field should be renamed from greatercampusDEM_1_1 to elevation with the following code in episode 1: 
    * names(campus_DEM_df)[names(campus_DEM_df) == 'greatercampusDEM_1_1'] <- 'elevation'
    
## ep 5: Multi-band raster data

## ep 6: Vector Data
POINTS
NCOS Planted Trees???
AGO: https://ucsb.maps.arcgis.com/home/item.html?id=6e05f326c17b4d84a626b42a3714c918


trees_sf <- vect("source_data/trees/DTK_012116.shp")
plot(trees_sf)

# maybe we could do change between 2 layers for this?
# new and removed trees between 2 years?

## ep 7 : visualizing by attribute
## ep 8 : vector overlays


## Episode 9: More about CRS
 Global vectors for insets
 NED raster
 kelp shapefile?
 I think we are using California Populated Places for this.

## Episode 10: data from a csv of lat-long pairs
 NCOS photo points?
 might have to backwards engineer a csv for this lesson.
 https://ucsb.maps.arcgis.com/apps/webappviewer/index.html?id=52f2fb744eb549289bed20adf34edfd7
 
 