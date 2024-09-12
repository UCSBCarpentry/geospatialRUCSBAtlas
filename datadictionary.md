# Data Files needed
Before we can integrate the files into the lesson scripts,
we need to know where we are going. Therefore, we need to build
the finished maps. 

This is a list of all the data required for the 7 maps 
described on the [Read Me](https://github.com/UCSBCarpentry/geospatialRUCSBAtlas/blob/main/README.md), along with notes regarding where they appear into the episode flow.

Items from the Carpentry Google Drive are at 
`\\Carpentry\Workshop Development\Local Data for Workshops\geo`
But we would like to move away from keeping them there. Perhaps build a zenodo package at the end of our exercise?

* Hillshades at 3 scales and extents:

Which episodes do each of these come in?

## DEM sources
Links are to their original source:
  * [The Bite of California](https://www.sciencebase.gov/catalog/item/542aebf9e4b057766eed286a)
    Elevation in the Western United States, 90 meter DEM, subsetted to CA
  * [Campus context: campus_DEM](https://drive.google.com/drive/folders/1_NWRIonW03jm5MdP9tq-zJjkfDjFCWEm?usp=drive_link)
  * For the campus DEM, the elevation field should be renamed from greatercampusDEM_1_1 to elevation with the following code in episode 1: 
    * names(campus_DEM_df)[names(campus_DEM_df) == 'greatercampusDEM_1_1'] <- 'elevation'
      * Kristi looking for metadata
  * [Henley Gate to Ellwood Beach: campus_topo_bath](https://pubs.usgs.gov/ds/781/)
    * California State Waters Map Series, Offshore of Coal Oil Point, Block ID 63
  * we will need 3 tiffs out of data_prep.r for these

## Map 1
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
  
## Map 2
* Trees
* Water
* Bikeways
* Pirate MapBox themed basemap?

## Map 3: Page with 4 insets
### Map 4-5-6: 
* Zoom in to site
  * Western North America
  * Bite of California
  * Extended Campus
* with little red extent boxes indicating the areas of zoom
