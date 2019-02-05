## sdmcode.R
## R 3.5.1
## Intended Use: Written to predict suitable eagle nesting habitat.
## Code closely follows the dismo R vignette by Hijmans et al. 2017 https://cran.r-project.org/web/packages/dismo/vignettes/sdm.pdf
## Inputs: Nest locations must be in points shapefile.
## Predictor raster files must be in separate folder by themselves
## Outputs: Predicted nesting distribution raster. Maxent output can be saved or viewed in pop-out explorer window.
## Instructions: Maxent must be downloaded and dismo package configured prior to conducting analysis. Detailed instructions in dismo vignette, pg 56 (exerpt below).
## MaxEnt is available as a standalone Java program. Dismo has a function maxent that communicates with this program. 
## To use it you must first download the program from http://www.cs.princeton.edu/~schapire/maxent/. 
## Put the file maxent.jar in the java folder of the dismo package. That is the folder returned by system.file("java", package="dismo").
## Java must also be downloaded. If using windows 8 or 10, a new key must also be created following these instructions (This is a known issue with Java/Windows):
## 1. Go into your Start Menu and type regedit into the search field.
## 2. Navigate to path HKEY_LOCAL_MACHINE\Software\JavaSoft (Windows 10 seems to now have this here: HKEY_LOCAL_MACHINE\Software\WOW6432Node\JavaSoft)
## 3. Right click on the JavaSoft folder and click on New -> Key
## 4. Name the new Key Prefs and everything should work.
## Run script line-by-line from R Studio. 
## Raster files are stored as temp files during analysis. Make sure sufficient RAM is available prior to running Maxent (This will be largely dependent on the size/amount of rasters used).
## Raster files MUST have same resolution, projection, extent, and number of rows/columns. This is an important pre-processing step.
## Shapefiles MUST have the same extent and projection as raster files.

# Install Required Packages 
install.packages(c("raster", "rgdal", "dismo", "rJava"))

# Load Required Packages
packagelist <- c("raster", "rgdal", "dismo", "rJava")  
lapply(packagelist, require, character.only = TRUE)

#Create User Input Prompts

rastfolder <- function ()
{
  n <- readline(prompt = "Enter path to folder containing raster files: ")
  return(n)
}
filename <- function ()
{
  n <- readline(prompt = "Enter file name: ")
  return(n)
}

## Set path for folder containing raster files
setwd(print(rastfolder()))
#verify successfully changed
print(getwd())

## Read in raster files for model covariates and create raster stack
## You can also do this individually using the raster() function
predictors <- do.call(stack, lapply(list.files(pattern = "tif$"), raster))
names(predictors)

## Select points shapefile containing eagle nest locations
pts <- readOGR(file.choose())

## Run Maxent analysis. This process will take a while.
mx <- maxent(predictors, pts)

## Evaluate model and covariate contribution
mx

## Create raster of predicted nest distribution. This process will take a while.
px <- predict(predictors, mx, progress='text')

## Plot predictor raster
plot(px)

## Save raster as geotiff. Select filename and location of output.
writeRaster(px, print(filename()), format = "GTiff")

