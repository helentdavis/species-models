## ProngBoi_SDM.R
## R 3.5.1
## Author: Helen Davis
## Date Created: 17 June 2019
## Intended Use: Written to predict suitable monthly pronghorn habitat.
## Code closely follows the dismo R vignette by Hijmans et al. 2017 https://cran.r-project.org/web/packages/dismo/vignettes/sdm.pdf
## Inputs: GPS collar locations must be in points shapefile.
##         Predictor raster files must be in separate folder by themselves
## Outputs: Predicted pronghorn habitat raster. Maxent output can be saved or viewed in pop-out explorer window.
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
install.packages(c("raster", "rgdal", "dismo", "rJava", "usdm"))

# Load Required Packages
packagelist <- c("raster", "rgdal", "dismo", "rJava", "usdm")  
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
output <- function ()
{
  n <- readline(prompt = "Enter model output directory file path: ")
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

## Extract random presence and pseudo-absence pts for multicollinearity analysis
presvals <- extract(predictors, pts)
set.seed(0)
backgr <- randomPoints(predictors, nrow(pts))
absvals <- extract(predictors, backgr)
pb <- c(rep(1, nrow(presvals)), rep (0, nrow(absvals)))
sdmdata <- data.frame(cbind(pb, rbind(presvals, absvals)))

## Test for multicollinearity
vif(sdmdata)

## Remove spatial sorting bias (SSB)... "the difference between the distance from
## testing-presence to training-presence and the distance from testing-absence to
## training-presence points through 'point-wise distance sampling'". -Hijmans and Elith 2017
nr <- nrow(pts)
s <- sample(nr, 0.25*nr)
pres_train <- pts[-s, ]
pres_test <- pts[s, ]
nr <- nrow(backgr)
s <- sample(nr, 0.25*nr)
back_train <- backgr[-s, ]
back_test <- backgr[s, ]

sb <- ssb(pres_test, back_test, pres_train)
sb[,1]/sb[,2]

## Value with SSB, may be close to 0.

i <- pwdSample(pres_test, back_test, pres_train, n=1, tr=0.1)
pres_test_pwd <- pres_test[!is.na(i[,1]), ]
back_test_pwd <- back_test[na.omit(as.vector(i)), ]
sb2 <- ssb(pres_test_pwd, back_test_pwd, pres_train)
sb2[1]/sb2[2]

## Value should approach 1 with SSB removed.


## Partition data into 5 groups for model training. This allows for 80% training (4 groups) and 20% testing (1 group).
group <- kfold(pts, 5)
pres_train <- pts[group !=1, ]
pres_test <- pts[group == 1, ]

## Select random background pts within 12.5% of specified raster extent, partition into 5 groups.
set.seed(0)
backg <- randomPoints(predictors, n=nrow(pts), extf=1.25)
colnames(backg) = c('lon','lat')
group <- kfold(backg, 5)
backg_train <- backg[group !=1, ]
backg_test <- backg[group == 1, ]

## Create presence/psuedo-absence training dataframe
pres_train <- coordinates(pres_train)
train <- rbind(pres_train, backg_train)
pb_train <- c(rep(1, nrow(pres_train)), rep(0, nrow(backg_train)))
envtrain <- extract(predictors, train)
envtrain <- data.frame( cbind(pa=pb_train, envtrain))
envtrain <- na.omit(envtrain)
head(envtrain)

## Extract values from generated presence/psuedo-absence points
testpres <- data.frame(extract(predictors, pres_test))
testbackg <- data.frame(extract(predictors, backg_test))

## Run maxent model using presence training points. This process will take a while.
## Write response curve plot data for future plot creation
mx <- maxent(predictors, pres_train, args=c('responsecurves=true', 'writeplotdata=true'), path=print(output()))

## Evaluate model fit using test data
e <- evaluate(pres_test, backg_test, mx, predictors)
e

## Evaluate model and covariate contribution
mx

## Create raster of predicted nest distribution. This process will take a while.
px <- predict(predictors, mx, progress='text')

## Plot predictor raster
plot(px)

## Save raster as geotiff. Select filename and location of output.
writeRaster(px, print(filename()), format = "GTiff")

