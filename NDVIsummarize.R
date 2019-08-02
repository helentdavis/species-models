## Summarizes NDVI and Precipitation Data and makes a pretty figure for a report


summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=FALSE,
                      conf.interval=.95, .drop=TRUE) {
  library(plyr)
  
  # New version of length which can handle NA's: if na.rm==T, don't count them
  length2 <- function (x, na.rm=FALSE) {
    if (na.rm) sum(!is.na(x))
    else       length(x)
  }
  
  # This does the summary. For each group's data frame, return a vector with
  # N, mean, and sd
  datac <- ddply(data, groupvars, .drop=.drop,
                 .fun = function(xx, col) {
                   c(N    = length2(xx[[col]], na.rm=na.rm),
                     mean = mean   (xx[[col]], na.rm=na.rm),
                     sd   = sd     (xx[[col]], na.rm=na.rm)
                   )
                 },
                 measurevar
  )
  
  # Rename the "mean" column    
  datac <- rename(datac, c("mean" = measurevar))
  
  datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean
  
  # Confidence interval multiplier for standard error
  # Calculate t-statistic for confidence interval: 
  # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
  ciMult <- qt(conf.interval/2 + .5, datac$N-1)
  datac$ci <- datac$se * ciMult
  
  return(datac)
}
ag1 <- summarySE(l, measurevar="NDVI_constant", groupvars=c("DOY"))
ag2 <- summarySE(l, measurevar="NDVI_constant", groupvars=c("DOY"))
ag3 <- summarySE(m3, measurevar="TtlPrecip_", groupvars=c("DOY_ave"))
colnames(ag3)[1] <- "DOY"
# Standard error of the mean
p1 <- ggplot(ag1, aes(x=DOY, y=NDVI_constant)) + 
  geom_errorbar(aes(ymin=NDVI_constant-ci, ymax=NDVI_constant+ci), width=.1) +
  geom_line() +
  geom_point()

p2 <- ggplot(ag2, aes(x=DOY, y=sd)) + 
  geom_line() +
  geom_point()

p3 <- ggplot(ag3, aes(x=DOY, y=TtlPrecip_)) + 
  geom_errorbar(aes(ymin=TtlPrecip_-ci, ymax=TtlPrecip_+ci), width=.1) +
  geom_line() +
  geom_point()

library(grid)
grid.newpage()
grid.draw(rbind(ggplotGrob(p1), ggplotGrob(p2), ggplotGrob(p3),size = "last"))

p1 <- ggplot(dat, aes(date, adjusted)) + geom_line() + theme_minimal() + 
  theme(axis.title.x = element_blank(), axis.text.x = element_blank())
p2 <- ggplot(dat,aes(date, volume)) + geom_bar(stat="identity") + theme_minimal() + 
  theme(axis.title.x = element_blank(),axis.text.x = element_text(angle=90))
