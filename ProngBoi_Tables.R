## ProngBoi_Tables.R
## R 3.5.1
## Author: Helen Davis
## Date Created: 02 August 2019
## Intended Use: I make tables for pronghorn technical reports. Not thoroughly tested, might be broken. Use at own risk.
## Inputs: Dataframe (.csv) containing survival estimates (Estimate), covariates (Variable), and estimates of standard error (SE).
##         Dataframe (.csv) containing output from species distribtuon model response curves including x value (x), y value (y), and month (Month).
##         Dataframe for response curves should be a single covariate. If multiple covariates are included in a single dataframe, it will need to be subset.
## Outputs: Publication ready figures for pronghorn technical report.
## Instructions: 
## Run script line-by-line from R Studio, depending on the style of figure you need.
## Manually adjust figure dimensions using the export button in the plots window. Dimensions used in the report are below:
## Survival Estimate Figures : 542w x 350h
## Stacked Survival Figures : 723w x 500h
## Response Curve Figures : 1085w x 700h


# Install required packages
install.packages(c("ggplot2", "grid"))

# Load Required Packages
packagelist <- c("ggplot2", "grid")  
lapply(packagelist, require, character.only = TRUE)


#Create User Input Prompts

wd <- function ()
{
  n <- readline(prompt = "Enter path to working directory: ")
  return(n)
}
filename <- function ()
{
  n <- readline(prompt = "Enter file name: ")
  return(n)
}
filename1 <- function ()
{
  n <- readline(prompt = "Enter first file name: ")
  return(n)
}
filename2 <- function ()
{
  n <- readline(prompt = "Enter second file name: ")
  return(n)
}
xname <- function ()
{
  n <- readline(prompt = "Enter X Axis Label: ")
  return(n)
}
yname <- function ()
{
  n <- readline(prompt = "Enter Y Axis Label: ")
  return(n)
}


# Set path for folder containing raster files
setwd(print(wd()))

# Verify successfully changed
print(getwd())

## SURVIVAL ESTIMATE FIGURES

# Read in dataframe
dat <- read.csv(print(filename()))

# Build figure
p1 <- ggplot(dat, aes(x=Variable, y=Estimate, label=round(Estimate, digits = 2))) + 
  geom_line()+ geom_pointrange(aes(ymin=Estimate-SE, ymax=Estimate+SE))+ 
  ylim(0.8,1.05) + ylab(print(yname())) + xlab(print(xname())) +
  theme_bw() +  theme(axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0)), 
                      panel.border = element_blank(), panel.grid.major = element_blank(), 
                      panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
                      axis.text.x = element_text(angle = 45, hjust=1))

# Plot figure
p1

# Use Export button on Plot window to export with desired dimensions.


## STACKED SURVIVAL FIGURES

# Read in 2 dataframes to stack
dat2 <- read.csv(print(filename1()))

dat3 <- read.csv(print(filename2()))

# Build top plot
p2 <- ggplot(dat2, aes(x=Variable, y=Estimate)) + 
  geom_line()+ geom_pointrange(aes(ymin=Estimate-SE, ymax=Estimate+SE))+ ylim(0.8,1) + 
  ylab(print(yname())) + theme_bw() +  
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0)), 
                      panel.border = element_blank(), panel.grid.major = element_blank(), 
                      panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"), 
                      axis.title.x=element_blank(), axis.text.x=element_blank(), axis.ticks.x=element_blank())

# Build bottom plot
p3 <- ggplot(dat3, aes(x=Variable, y=Estimate, group =1, label=round(Estimate, digits = 2))) + 
  geom_line() + geom_point() + ylim(0,1.2) + ylab(print(yname())) + xlab(print(xname())) + theme_bw() +  
  theme(axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0)), 
                      panel.border = element_blank(), panel.grid.major = element_blank(), 
                      panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
                      axis.text.x = element_text(angle = 45, hjust=1))

# Plot stacked figure
grid.newpage()
grid.draw(rbind(ggplotGrob(p2), ggplotGrob(p3),size = "last"))


## RESPONSE CURVE FIGURES
dat4 <- read.csv(print(filename()))

## Reorder months
dat4$month <- factor(dat4$month, levels=c("January", "February", "March", "April", "May", "June", 
                                          "July", "August", "September", "October", "November", "December"))

## Build figure
p4 <- ggplot(dat4, aes(x, y))
p4 + geom_smooth(aes(color=month), se=F) + xlim(0, NA) +ylim(0,1) + xlab(print(xname())) + ylab(print(yname())) + 
  theme_bw() + theme(legend.background = element_blank(), legend.box.background = element_rect(colour = "black"), 
                     panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
                     axis.line = element_line(colour = "black"))




