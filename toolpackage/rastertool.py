## rastertool.py
## Python 2.7.8
## Date Created: 12 December 2018
## Intended Use: Written to prepare raster files for nest suitability model analysis.
##          Provides automation for ensuring all raster files are the same resolution, extent, and projection for easy transition to R and Maxent.
##          Can be applied to any species distribution modeling project or for projects where raster datasets need to be stacked. 
## Inputs: Raster files containing variables for use in analysis.
##          A shapefile(s) with desired projection and clipping extent.      
## Outputs: A snap raster file with user defined resolution and projection, extent matching input shapefile.
##          Raster files with matching resolution, extent, and projection
## Instructions: All shapefiles and raster files must be housed in a geodatabase prior to running module 

import arcpy,os
from arcpy.sa import *
from arcpy import env
arcpy.env.overwriteOutput=True

class StandardizeRasters(object):
    def __init__(self):
        '''Define the tool (tool name is the name of the class).'''
        self.label = '00-raster-tool'
        self.description = 'This tool faciliates a smooth transition ' + \
                           'of raster datasets into maxent or applicable analysis. ' + \
                           'Rasters contained in geodatabase are given the same ' + \
                           'projection, extent, and resolution. ' + \
                           'Output rasters can be used in species distribution modeling ' + \
                           'or when rasters needs to be stacked for analysis. '
        self.canRunInBackground = False

    def getParameterInfo(self):
        '''Define parameter definitions'''

        # Input raster parameter
        in_rasterdataset = arcpy.Parameter(
            displayName='Select geodatabase containing raster datasets',  
            name='in_rasterdataset',
            datatype='DEWorkspace',
            parameterType='Required',
            direction='Input')
       
        # Input feature class
        in_fc = arcpy.Parameter(
            displayName='Select the feature class you would like to ' + \
                        'use as mask.',
            name='in_fc',
            datatype='DEFeatureClass',
            parameterType='Required',
            direction='Input')
        
        # Input cell size
        in_cellsize = arcpy.Parameter(
            displayName='Enter desired cell size for output rasters ',
            name='in_cellsize',
            datatype='GPLong',
            parameterType='Required',
            direction='Input')
        
        # Validation field for snap raster
        in_field = arcpy.Parameter(
            displayName='Select field used to assign values to the output snap raster (e.g. sdsFeature) ',
            name='in_field',
            datatype='Field',
            parameterType='Required',
            direction='Input')
        
        # Filter field options based on input feature class and field type
        in_field.parameterDependencies = [in_fc.name]
        in_field.filter.list = ['Text']
        
        parameters = [in_rasterdataset, in_fc, in_cellsize, in_field]
        return parameters

    def isLicensed(self): #optional
        '''Set whether tool is licensed to execute.'''
        return True

    def updateParameters(self, parameters): #optional
        '''Modify the values and properties of parameters before internal
        validation is performed.  This method is called whenever a parameter
        has been changed.'''
        return

    def updateMessages(self, parameters): #optional
        '''Modify the messages created by internal validation for each tool
        parameter.  This method is called after internal validation.'''
        return

    def execute(self, parameters, messages):
        '''The source code of the tool.'''
        in_rasterdataset = parameters[0].valueAsText
        in_fc = parameters[1].valueAsText
        in_cellsize = parameters[2].valueAsText
        in_field = parameters[3].valueAsText


        arcpy.env.workspace=in_rasterdataset

        ## check workspace and raster files
        rasterlist=arcpy.ListRasters("*")
        arcpy.PolygonToRaster_conversion(in_features=in_fc, value_field=in_field, out_rasterdataset="snap1", cellsize=in_cellsize)
        snap="snap1"
        arcpy.AddMessage("Snap Raster Created")

        ## Project, resample, and clip rasters
        for raster in rasterlist:
            Ras=arcpy.Raster(raster)
            arcpy.env.snapRaster = snap
            projrast1=arcpy.ProjectRaster_management(Ras, "proj1", snap, "NEAREST")
            resamprast1=arcpy.Resample_management(projrast1, "resamp1", in_cellsize, "NEAREST")
            cliprast=arcpy.Clip_management(resamprast1, "#", raster+"_final", in_fc, "0", "ClippingGeometry")
            arcpy.AddMessage("Snap Raster Created")
    
        ## Delete temp files
        arcpy.Delete_management("resamp1")
        arcpy.Delete_management("proj1")

        