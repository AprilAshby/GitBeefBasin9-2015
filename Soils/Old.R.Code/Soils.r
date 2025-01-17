#April's Soil Data
#install.packages('plyr')
library(plyr)
library(data.table)
library(splitstackshape)
library(aqp)
library(reshape2)

# Read in Soils Data
dat <- read.csv("F:/Soils/SoilDataFitUSGSColumns.csv", header = T,nrows = 444)

# Subset Slope Shape and combine categories
SlopeShape <- subset(dat, select=c(id, SlopeShape))
SlopeShape <- SlopeShape[complete.cases(SlopeShape), ] #Remove rows with only NA
# row.names(SlopeShape)<-SlopeShape$id
# SlopeShape <- SlopeShape[,-1]
SlopeShape$SlopeShape <- sub("LC", "CL", SlopeShape$SlopeShape, ignore.case = FALSE)
SlopeShape$SlopeShape <- sub("VC", "CV", SlopeShape$SlopeShape, ignore.case = FALSE)
SlopeShape$SlopeShape <- sub("VL", "LV", SlopeShape$SlopeShape, ignore.case = FALSE)
SlopeShape$SlopeShape <- as.factor(SlopeShape$SlopeShape)
dat <- subset(dat, select = -c(Horizon,Theta_fc,Theta_pwp, HzNum,SlopeShape) )

#Look at data
names(dat)
sapply(dat, class)

f2 <- function(x) summary(x[,-1])
summary <- ddply( dat, .(id), function(x) summary(x[,-1]) )

#AWC
TotalAWC <- ddply(dat, 'id', summarize, TotalAWC = sum(AWHC, na.rm = T))
MaxAWC <- ddply(dat, 'id', summarize, MaxAWC = max(AWHC, na.rm = T))
Slope <- ddply( dat, .(id), function(x) max(x$Slope, na.rm = T) )
  names(Slope)[2] <- 'Slope'
maxDepth <- ddply( dat, .(id), function(x) max(x$bottom, na.rm = T) )
  names(maxDepth)[2] <- 'maxDepth'
maxSand <- ddply( dat, .(id), function(x) max(x$SandPercent, na.rm = T) )
  names(maxSand)[2] <- 'maxSand'
minSand <- ddply( dat, .(id), function(x) min(x$SandPercent, na.rm = T) )
  names(minSand)[2] <- 'minSand'
minClay <- ddply( dat, .(id), function(x) min(x$ClayPercent, na.rm = T) )
  names(minClay)[2] <- 'minClay'
maxClay <- ddply( dat, .(id), function(x) max(x$ClayPercent, na.rm = T) )
  names(maxClay)[2] <- 'maxClay'
Elevation <- ddply( dat, .(id), function(x) max(x$Elevation, na.rm = T) )
  names(Elevation)[2] <- 'Elevation'
maxpH <- ddply( dat, .(id), function(x) max(x$pH, na.rm = T) )
  names(maxpH)[2] <- 'maxpH'
minpH <- ddply( dat, .(id), function(x) min(x$pH, na.rm = T) )
  names(minpH)[2] <- 'minpH'
CarbonateStage <- ddply( dat, .(id), function(x) max(x$CarbonateStage, na.rm = T) )
  names(CarbonateStage)[2] <- 'CarbonateStage'
BioticCrustClass <- ddply( dat, .(id), function(x) max(x$BioticCrustClass, na.rm = T) )
  names(BioticCrustClass)[2] <- 'BioticCrustClass'


 #Factor
maxDryValue <- ddply(.data = dat, .(id), function(x) max(x$DryValue, na.rm = T))
 names(maxDryValue)[2] <- 'maxDryValue'
minDryValue <- ddply(.data = dat, .(id), function(x) min(x$DryValue, na.rm = T))
 names(minDryValue)[2] <- 'minDryValue'
maxDryChroma <- ddply(.data = dat, .(id), function(x) max(x$DryChroma, na.rm = T))
 names(maxDryChroma)[2] <- 'maxDryChroma'
minDryChroma <- ddply(.data = dat, .(id), function(x) min(x$DryChroma, na.rm = T))
 names(minDryChroma)[2] <- 'minDryChroma'
maxMoistValue <- ddply(.data = dat, .(id), function(x) max(x$MoistValue, na.rm = T))
 names(maxMoistValue)[2] <- 'maxMoistValue'
minMoistValue <- ddply(.data = dat, .(id), function(x) min(x$MoistValue, na.rm = T))
 names(minMoistValue)[2] <- 'minMoistValue'
maxMoistChroma <- ddply(.data = dat, .(id), function(x) max(x$MoistChroma, na.rm = T))
 names(maxMoistChroma)[2] <- 'maxMoistChroma'
minMoistChroma <- ddply(.data = dat, .(id), function(x) min(x$MoistChroma, na.rm = T))
 names(minMoistChroma)[2] <- 'minMoistChroma'

# Change moist Chroma to 1st horizon and 2nd horizon as a proxy
# for organic carbon accumulation in surface and subsurface horzons
# A lower chroma means more organic carbon. Grassland soils have
# higher fine root turnover.

# Surface
dat$Surface <- as.numeric(dat$top<1) # Turns surface horizon into 1, and all other into 0

max.func.sur <- function(dat) {
  max.moist.sur <- max(dat$Surface)
  
  return(data.frame(Surface = dat$MoistChroma[dat$Surface==max.moist.sur]))
}

Surface <- ddply(dat, .(id), max.func.sur)
names(Surface)[2] <- 'Surface'

# Subsurface
dat <- getanID(data = dat, id.vars = "id") # Creates an ordered list of each horizon in a plot
dat$Subsurface <- as.numeric(dat$.id==2) # Makes subsurface horizon 1, and all other horizons 0
dat$MoistChroma[is.na(dat$MoistChroma)] <- 0

max.func.sub <- function(dat) {
  max.moist.sub <- max(dat$Subsurface)
  
  return(data.frame(Subsurface = dat$MoistChroma[dat$Subsurface==max.moist.sub]))
}

Subsurface <- ddply(dat, .(id), max.func.sub)
names(Subsurface)[2] <- 'Subsurface'

#Numeric Data
dat$top <- as.numeric(dat$top)
dat$bottom <- as.numeric(dat$bottom)
dat$ClayPercent <- as.numeric(dat$ClayPercent)
dat$Elevation <- as.numeric(dat$Elevation)
dat$SandPercent <- as.numeric(dat$SandPercent)
dat$pH <- as.numeric(dat$pH)
dat$Slope <- as.numeric(dat$Slope)
dat$AWHC <- as.numeric(dat$AWHC)

# Factor Data
dat$DryHue <- as.factor(dat$DryHue)
dat$DryValue <- as.factor(dat$DryValue)
dat$DryChroma <- as.factor(dat$DryChroma)
dat$MoistHue <- as.factor(dat$MoistHue)
dat$MoistValue <- as.factor(dat$MoistValue)
dat$MoistChroma <- as.factor(dat$MoistChroma)
dat$Texture <- as.factor(dat$Texture)
dat$SandSize <- as.factor(dat$SandSize)
dat$Effervescence <- as.factor(dat$Effervescence)
dat$CarbonateStage <- as.factor(dat$CarbonateStage)
dat$BioticCrustClass <- as.factor(dat$BioticCrustClass)
dat$Aspect <- as.factor(dat$Aspect)


all <- join(maxClay, minClay, by = 'id', type = 'inner')
all <- join(all, maxSand, by = 'id', type = 'inner')
all <- join(all, minSand, by = 'id', type = 'inner')
all <- join(all, maxDepth, by = 'id', type = 'inner')
all <- join(all, maxpH, by = 'id', type = 'inner')
all <- join(all, minpH, by = 'id', type = 'inner')
all <- join(all, maxDryValue, by = 'id', type = 'inner')
all <- join(all, minDryValue, by = 'id', type = 'inner')
all <- join(all, maxDryChroma, by = 'id', type = 'inner')
all <- join(all, minDryChroma, by = 'id', type = 'inner')
all <- join(all, maxMoistValue, by = 'id', type = 'inner')
all <- join(all, minMoistValue, by = 'id', type = 'inner')
all <- join(all, maxMoistChroma, by = 'id', type = 'inner')
all <- join(all, minMoistChroma, by = 'id', type = 'inner')
all <- join(all, Surface, by = 'id', type = 'inner')
all <- join(all, Subsurface, by = 'id', type = 'inner')


# Create new soil parameter where depth is binary.
 # if the maximum depth is >50/100/150/200 then 1, if not then 0
all$Depth50 <- as.numeric(all$maxDepth > 50)
all$Depth100 <- as.numeric(all$maxDepth > 100)
all$Depth150 <- as.numeric(all$maxDepth > 150)
all$Depth200 <- as.numeric(all$maxDepth == 200)

#Now calculate depth weighted averages of each continuous variable, then append these to the other variables. 
#Convert to SoilProfileCollection
depths(dat) <- id ~ top + bottom

# within each profile, compute weighted means, over the intervals: 0-25,0-50,0-100, removing NA if present 
d25 <- slab(dat, id ~ AWHC, slab.structure = c(0,25), slab.fun = mean, na.rm=TRUE)
d50 <- slab(dat, id ~ AWHC, slab.structure = c(0,50), slab.fun = mean, na.rm=TRUE)
d100 <- slab(dat, id ~ AWHC, slab.structure = c(0,100), slab.fun = mean, na.rm=TRUE)

# reshape to wide format, remove unneeded variables and rename. 
AWC25 <- dcast(d25, id + top + bottom ~ variable, value.var = 'value')
AWC25 <- AWC25[,-c(2,3)]
names(AWC25)[2] <- 'AWC25'

AWC50 <- dcast(d50, id + top + bottom ~ variable, value.var = 'value')
AWC50 <- AWC50[,-c(2,3)]
names(AWC50)[2] <- 'AWC50'

AWC100 <- dcast(d100, id + top + bottom ~ variable, value.var = 'value')
AWC100 <- AWC100[,-c(2,3)]
names(AWC100)[2] <- 'AWC100'

all <- join(all, AWC25, by = 'id', type = 'inner')
all <- join(all, AWC50, by = 'id', type = 'inner')
all <- join(all, AWC100, by = 'id', type = 'inner')
all <- join(all, MaxAWC, by = 'id', type = 'inner')
all <- join(all, TotalAWC, by = 'id', type = 'inner')
all <- join(all, Elevation, by = 'id', type = 'inner')
all <- join(all, Slope, by = 'id', type = 'inner')
all <- join(all, SlopeShape, by = 'id', type = 'inner')
all <- join(all, CarbonateStage, by = 'id', type = 'inner')
all <- join(all, BioticCrustClass, by = 'id', type = 'inner')

write.csv(all,file="F:/Soils/SoilEnvironmentalData.csv", row.names=FALSE)
