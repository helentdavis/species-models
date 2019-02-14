## sdm_rastertool.py
## Python 2.7.8
## Date Created: 12 December 2018
## Intended Use: Written to prepare raster files for nest suitability model analysis.
##          Provides automation for ensuring all raster files are the same resolution, extent, and projection for easy transition to R and Maxent.
##          Can be applied to any species distribution modeling project or for projects where raster datasets need to be stacked. 
## Inputs: Raster files containing variables for use in analysis.
##          A shapefile(s) with desired projection and clipping extent.      
## Outputs: A snap raster file with user defined resolution and projection, extent matching input shapefile.
##          Raster files with matching resolution, extent, and projection
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

## print list of shapefile for mask
featurelist=arcpy.ListFeatureClasses("*")
print "Shapefile List"
for feature in featurelist:
    print feature

## user chooses mask for clipping geometry
mask=raw_input('Choose shapefile from list for clipping geometry\n') 

## create snap raster from mask shapefile
cellSize=raw_input('Define cell size for snap raster\n') 

fields=arcpy.ListFields(mask)
for field in fields:
    print("{0}".format(field.name))

valfield=raw_input('Select field used to assign values to the output raster (e.g. OBJECTID) \n') 
arcpy.PolygonToRaster_conversion(in_features=mask, value_field=valfield, out_rasterdataset="snap1", cellsize=cellSize)
snap="snap1"
print("snap created")

## Project, resample, and clip rasters
for raster in rasterlist:
    Ras=arcpy.Raster(raster)
    arcpy.env.snapRaster = snap
    projrast1=arcpy.ProjectRaster_management(Ras, "proj1", snap, "NEAREST")
    resamprast1=arcpy.Resample_management(projrast1, "resamp1", cellSize, "NEAREST")
    cliprast=arcpy.Clip_management(resamprast1, "#", raster+"_final", mask, "0", "ClippingGeometry")
    

## Delete temp files
arcpy.Delete_management("resamp1")
arcpy.Delete_management("proj1")

end = time.time()
elapsed = end - start
print elapsed
