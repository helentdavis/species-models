## raster-tool.pyt
## ArcGIS 10.2.2
## Python 2.7.5
## Date Created: 14 February 2019
## Usage: Standardize rasters for integration into maxent.
##------------------------------------------------------------------------------
import toolpackage.rastertool
# Reloading allows module to refesh when pyt refreshes
reload(toolpackage.rastertool)
from toolpackage.rastertool import StandardizeRasters

class Toolbox(object):
    def __init__(self):
        """Define the toolbox (the name of the toolbox is the name of the
        .pyt file)."""
        self.label = "raster-tool"
        self.alias = "Toolbox for standardizing rasters for maxent analysis."
    
        # List of tool classes associated with this toolbox
        self.tools = [StandardizeRasters] 