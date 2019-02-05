## sdm_rastertool.py
## Python 2.7.8
## Date Created: 12 December 2018
## Intended Use: Written to prepare raster files for nest suitability model analysis.
## Provides automation for ensuring all raster files are the same resolution, extent, and projection for easy transition to R and Maxent.
## Inputs: Raster files containing variables for use in analysis.
##          A shapefile(s) with desired projection and clipping extent.      
## Outputs: Raster files with matching resoltuion, extent, and projection
## Instructions: Run Module from preferred platform. Follow user prompts as specified.
##          All shapefiles and raster files must be housed in a geodatabase prior to running module 

import arcpy
import time
arcpy.env.overwriteOutput=True
start=time.time()

## Enter workspace. Workspace should be geodatabase of all rasters.

arcpy.env.workspace = raw_input('Paste the path to the workspace and hit enter\n') 

## check workspace and raster files
rasterlist=arcpy.ListRasters("*")
print "Raster List"
for raster in rasterlist:
    print(raster)

## check workspace and shapefile mask, define mask
featurelist=arcpy.ListFeatureClasses("*")
print "Shapefile List"
for feature in featurelist:
    print feature
mask=raw_input('Paste shapefile name to use as mask and hit enter\n') 

## Snap raster is raster with desired projection, resolution, and extent.
## All other rasters in the set will be projected, resampled, and clipped to the snap raster

cellsize=raw_input('Enter resample cell size and hit enter\n')

## Project, resample, and clip rasters
for raster in rasterlist:
    Ras=arcpy.Raster(raster)
    projrast1=arcpy.ProjectRaster_management(Ras, "proj1", mask, "NEAREST")
    resamprast1=arcpy.Resample_management(projrast1, "resamp1", cellsize, "NEAREST")
    cliprast=arcpy.Clip_management(resamprast1, "#", raster+"_final", mask, "0", "ClippingGeometry")
    

## Delete temp files
arcpy.Delete_management("resamp1")
arcpy.Delete_management("proj1")

end = time.time()
elapsed = end - start
print elapsed
