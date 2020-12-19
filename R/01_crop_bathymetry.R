## -----------------------------------------------------------------------------
# render shell script executable on linux
# nb: windows users should use curl or similar
# and save the commands to a bat file
# file an issue if this is needed or simply go to the website
# and download the file manually
system(
  command = "chmod +x get_etopo.sh"
)

# run shell script for bathymetry/topography layer
system(
  command = "./get_etopo.sh"
)


## -----------------------------------------------------------------------------
# make shell script executable
system(
  command = "chmod +x get_hawaii_boundaries.sh"
)

# run script
system(
  command = "./get_hawaii_boundaries.sh"
)


## -----------------------------------------------------------------------------
library(sf)

# load main islands
boundary_main <- st_read("data/vector/boundary_main_islands")
# load north west islands
boundary_nwhi <- st_read("data/vector/boundary_nwhi")

# check geometry class, should be identical
sapply(list(boundary_main, boundary_nwhi), st_geometry_type)

# the geometry types differ


## -----------------------------------------------------------------------------
# get extents
bbox_main <- st_as_sfc(
  st_bbox(boundary_main)
)
bbox_nwhi <- st_as_sfc(
  st_bbox(boundary_nwhi)
)
# combine extents
bbox_total <- st_union(bbox_main, bbox_nwhi)
bbox_total <- st_as_sfc(
  st_bbox(bbox_total)
)

# project to UTM 4N (main island Hawaii)
bbox_total <- st_transform(bbox_total, 2782)

# buffer by a buffer value
buffer_size <- 100000
bbox_total <- st_buffer(bbox_total, buffer_size)

# retransform to wgs84
bbox_total <- st_transform(bbox_total, 4326)

# save as hawaii extent
st_write(
  bbox_total,
  dsn = "data/vector/extent_hawaii.gpkg", 
  append = FALSE
)


## -----------------------------------------------------------------------------
library(raster)

# read in etopo
etopo <- raster("data/raster/ETOPO1_Bed_c_geotiff.tif")

# crop by extent
etopo_hawaii <- crop(etopo, as(bbox_total, "Spatial"))


## -----------------------------------------------------------------------------
# set values > 0 to NA for visualisation
values(etopo_hawaii)[values(etopo_hawaii) > 0] <- NA

# assign a crs
crs(etopo_hawaii) <- st_crs(4326)$proj4string


## -----------------------------------------------------------------------------
# remove values below -1000
etopo_shallow <- etopo_hawaii
values(etopo_shallow)[values(etopo_shallow) < -1000] <- NA

# save this to operate out of memory
writeRaster(etopo_shallow,
            filename = "data/raster/etopo_shallow.tif")

library(stars)
contour_levels <- st_contour(
  x = st_as_stars(etopo_shallow),
  contour_lines = FALSE,
  breaks = c(-1000, -30, 0)
)

# assign classes
contour_levels$upper_limit <- c(-1000, -30, 0, NA)
# filter values
contour_levels <- filter(contour_levels, upper_limit %in% c(-30, 0))

# save to file
st_write(
  contour_levels,
  dsn = "data/vector/hawaii_selected_contours.gpkg"
)


## -----------------------------------------------------------------------------
library(tmap)

# plot figure
figure_hawaii <- 
  tm_shape(shp = etopo_hawaii)+
  tm_raster(
    colorNA = "black",
    # palette = rev(RColorBrewer::brewer.pal(7, "PuBu")
    palette = rev(pals::kovesi.linear_blue_95_50_c20(7)),
    title = "depth (m)")+
  tm_shape(contour_levels)+
  tm_fill(col = "upper_limit", 
          palette = RColorBrewer::brewer.pal(2, "Reds"), 
          style = "cat")+
  tm_compass(position = "left")+
  tm_scale_bar(position = "left", 
               breaks = c(0, 100, 250, 500))

# save to file
tmap_save(
  figure_hawaii, filename = "figures/figure_hawaii_bathymetry.png"
)

