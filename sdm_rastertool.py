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

## Enter workspace. Workspace should be geodatabase of all rasters you want resampled, etc.

arcpy.env.workspace = raw_input('Enter path to geodatabase\n') 

## check workspace and raster files
rasterlist=arcpy.ListRasters("*")
print "Raster List"
for raster in rasterlist:
    print(raster)

## user chooses raster with desired extent, projection, and resolution
snap=raw_input('Enter path to raster with desired extent, projection, and resolution\n') 

featurelist=arcpy.ListFeatureClasses("*")
print "Shapefile List"
for feature in featurelist:
    print feature

## user chooses mask for clipping geometry
mask=raw_input('Choose shapefile from list for clipping geometry\n') 

## Describe cell size of snap raster
cellsize = "{0} {1}".format(arcpy.Describe(snap).meanCellWidth, arcpy.Describe(snap).meanCellHeight)

## Project, resample, and clip rasters
for raster in rasterlist:
    Ras=arcpy.Raster(raster)
    arcpy.env.snapRaster = snap
    projrast1=arcpy.ProjectRaster_management(Ras, "proj1", snap, "NEAREST")
    resamprast1=arcpy.Resample_management(projrast1, "resamp1", cellsize, "NEAREST")
    cliprast=arcpy.Clip_management(resamprast1, "#", raster+"_final", mask, "0", "ClippingGeometry")
    

## Delete temp files
arcpy.Delete_management("resamp1")
arcpy.Delete_management("proj1")

end = time.time()
elapsed = end - start
print elapsed
