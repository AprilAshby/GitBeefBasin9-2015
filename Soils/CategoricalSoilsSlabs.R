library(splitstackshape)
library(plyr)
library(aqp)
library(data.table)
library(reshape2)
library(tidyr)

# Read in data
# Manually in excel I added in second IL1_9 row of NA to dat so H2 still has 99obs
dat <- read.csv("F:/Soils/SoilDataFitUSGSColumns.csv", header = T,nrows = 444)
udat <- read.csv("F:/Soils/USGSsoildataModForAprilsdata.csv", header = T,nrows = 444)
udat$id <- extract_numeric(udat$id) # removes CLHS and P leaving only numbers.


# Creates an ordered list of each horizon in a plot
dat <- getanID(data = dat, id.vars = "id") 
udat <- getanID(data = udat, id.vars = "id")

H1 <- dat[ which(dat$.id=='1'), ] # Pull out horizon #1
Plot <- subset(H1, select = c(id,Elevation,Aspect,Slope,SlopeShape,CarbonateStage,BioticCrustClass))# Pull out data that is for the whole plot
H1 <- subset(H1, select = -c(Elevation,Aspect,Slope,SlopeShape,CarbonateStage,BioticCrustClass))# Remove out data that is for the whole plot
dat <- subset(dat, select = -c(Elevation,Aspect,Slope,SlopeShape,CarbonateStage,BioticCrustClass))# Remove out data that is for the whole plot

# Combine April and USGS soils data
dat <- rbind(dat,udat)

# Add in USGS Elevation, Slope Shape, Slope, Carbonate Stage, Biotic Crust Class
# Remove BLM Trend and Miller plots
site <- read.csv("F:/BeefBasin Data For April/BeefBasin/formattedR/Site_Data.csv")
site <- site[-c(66:77),]
site <- site[order(site$pedonID),] # Sort so plot 100 is by 9 same as data
site$pedonID <- extract_numeric(site$pedonID) # removes CLHS and P leaving only numbers.

loc <- read.csv("F:/BeefBasin Data For April/BeefBasin/formattedR/locInfo.csv")
loc <- loc[-c(66:77),]
loc <- loc[order(loc$Plot.Name),] # Sort so plot 100 is by 9 same as data
loc$Plot.Name <- extract_numeric(loc$Plot.Name) # removes CLHS and P leaving only numbers.

# put into dataframe to add to april
id <-site$pedonID
Elevation <- loc$altitude
Aspect <- site$Aspect
df <- data.frame(id,Elevation,Aspect)
df$Slope <- site$Slope
df$SlopeShape <- site$SlopeShape
df$CarbonateStage <- site$CarbonateStage
df$BioticCrustClass <- site$BioticCrustClass
# Add to april Plot dataframe
Plot <- rbind(Plot,df)

# combine redundant categories
{Plot$SlopeShape <- sub("LC", "CL", Plot$SlopeShape, ignore.case = FALSE)
 Plot$SlopeShape <- sub("VC", "CV", Plot$SlopeShape, ignore.case = FALSE)
 Plot$SlopeShape <- sub("VL", "LV", Plot$SlopeShape, ignore.case = FALSE)
 Plot$SlopeShape <- sub("LVQ", "LV", Plot$SlopeShape, ignore.case = FALSE)
 Plot$SlopeShape <- as.factor(Plot$SlopeShape)}

# get the maximum depth of the entire pedon
PedonDepth <- ddply( dat, .(id), function(x) max(x$bottom, na.rm = T) )
names(PedonDepth)[2] <- 'PedonDepth'

# get the depth of each horizon
dat$Depth <- dat$bottom-dat$top

#  Create Soil Depth Classes
# Very Shallow <25cm - Shallow 25-50cm - Moderately Deep 50-100cm - Deep 100-150cm - Very Deep >150cm
mysize <- function(x){
  if(x<25)return('VeryShallow')
  if(x>=25 & x<50)return('Shallow')
  if(x>=50 & x<100)return("ModeratelyDeep")
  if(x>=100 & x<150)return('Deep')
  if(x>=150) return('VeryDeep')
  elsereturn(NA)}
Plot$DepthClass <- sapply(PedonDepth$PedonDepth, mysize)
Plot$PedonDepth <- PedonDepth$PedonDepth
# Scale Hue - Redness Scale - Degree of Redness: least(1) to most(4) red. 2.5YR=4, 5YR=3, 7.5YR=2, 10YR=1.
# Scale Chroma - Chroma Class: 1&2=Low, 3&4=Medium, 6&8=High
dat$DryH <- dat$DryHue
dat$MoistH <- dat$MoistHue
dat$DryChroma <- sub("5", "4", dat$DryChroma, ignore.case = FALSE)
dat$DryC <- dat$DryChroma
dat$MoistC <- dat$MoistChroma
dat$Effervescence <- sub("LS", "SL", dat$Effervescence, ignore.case = FALSE)
dat$Effer <- dat$Effervescence

{
  dat$DryHue <- sub("2.5YR", "4", dat$DryHue, ignore.case = FALSE)
  dat$DryHue <- sub("7.5YR", "2", dat$DryHue, ignore.case = FALSE)
  dat$DryHue <- sub("5YR", "3", dat$DryHue, ignore.case = FALSE)
  dat$DryHue <- sub("10YR", "1", dat$DryHue, ignore.case = FALSE)
  
  dat$MoistHue <- sub("2.5YR", "4", dat$MoistHue, ignore.case = FALSE)
  dat$MoistHue <- sub("7.5YR", "2", dat$MoistHue, ignore.case = FALSE)
  dat$MoistHue <- sub("5YR", "3", dat$MoistHue, ignore.case = FALSE)
  dat$MoistHue <- sub("10YR", "1", dat$MoistHue, ignore.case = FALSE)
  
  dat$DryChroma <- sub("2", "1", dat$DryChroma, ignore.case = FALSE)
  dat$DryChroma <- sub("3", "2", dat$DryChroma, ignore.case = FALSE)
  dat$DryChroma <- sub("4", "2", dat$DryChroma, ignore.case = FALSE)
  dat$DryChroma <- sub("6", "3", dat$DryChroma, ignore.case = FALSE)
  dat$DryChroma <- sub("8", "3", dat$DryChroma, ignore.case = FALSE)
  
  
  dat$MoistChroma <- sub("2", "1", dat$MoistChroma, ignore.case = FALSE)
  dat$MoistChroma <- sub("3", "2", dat$MoistChroma, ignore.case = FALSE)
  dat$MoistChroma <- sub("4", "2", dat$MoistChroma, ignore.case = FALSE)
  dat$MoistChroma <- sub("6", "3", dat$MoistChroma, ignore.case = FALSE)
  
  dat$Effervescence <- sub("VE", "4", dat$Effervescence, ignore.case = FALSE)
  dat$Effervescence <- sub("ST", "3", dat$Effervescence, ignore.case = FALSE)
  dat$Effervescence <- sub("SL", "2", dat$Effervescence, ignore.case = FALSE)
  dat$Effervescence <- sub("VS", "1", dat$Effervescence, ignore.case = FALSE)
  dat$Effervescence <- sub("NE", "0", dat$Effervescence, ignore.case = FALSE)
   
  dat$Texture <- sub("LVFS", "LS", dat$Texture, ignore.case = FALSE)
  dat$Texture <- sub("VFLS", "LS", dat$Texture, ignore.case = FALSE)
  dat$Texture <- sub("VFSL", "SL", dat$Texture, ignore.case = FALSE)
  dat$Texture <- sub("FSL", "SL", dat$Texture, ignore.case = FALSE)
  dat$Texture <- sub("LCS", "LS", dat$Texture, ignore.case = FALSE)
  dat$Texture <- sub("LM", "L", dat$Texture, ignore.case = FALSE)
  dat$Texture <- sub("FLS", "LS", dat$Texture, ignore.case = FALSE)
  dat$Texture <- sub("FS", "S", dat$Texture, ignore.case = FALSE)
  dat$Texture <- sub("LFS", "LS", dat$Texture, ignore.case = FALSE)
  dat$Texture <- sub("LMS", "LS", dat$Texture, ignore.case = FALSE)

  
  dat$SandSize <- sub("MID", "MIX", dat$SandSize, ignore.case = FALSE)
  dat$SandSize <- sub("Vf, M", "MIX", dat$SandSize, ignore.case = FALSE)
  dat$SandSize <- sub("VFS", "VF", dat$SandSize, ignore.case = FALSE)
  dat$SandSize <- sub("VF ", "VF", dat$SandSize, ignore.case = FALSE)

}
dat <- rename(dat, c(DryHue="DryRed",DryH="DryHue",MoistHue="MoistRed",
             MoistH="MoistHue",DryChroma="DryCClass",DryC="DryChroma",
             MoistChroma="MoistCClass",MoistC="MoistChroma",
             Effervescence="EfferScale",Effer="Effervescence"))


# write file before removing anything for use in slabs function below
write.csv(dat,file="F:/Soils/SoilDataAprilUSGSnotremoved.csv", row.names=FALSE)
# # remove anything you don't want duplicated in H1 and H2
# dat <- subset(dat, select = -c(top,bottom,Horizon,Theta_fc,Theta_pwp, HzNum,Texture,SandSize) )

H1 <- dat[ which(dat$.id=='1'), ] # Pull out horizon #1
H1 <- subset(H1, select=-c(.id))
H1$DWA_AWC <- (H1$AWHC*H1$Depth)/PedonDepth$PedonDepth

H2 <- dat[! which(dat$.id=='1'), ] # Pull out horizon #1
H2 <- subset(H2, select=-c(.id))

{
# Categorical Depth Weighted Mode

  # Total Horizon
TDWA <- PedonDepth

TDryRed <- count(dat, vars=c("DryRed", "id"),wt_var="Depth")
TDryRed<-xtabs(freq~id+DryRed, TDryRed)
TDWA$DryRed <- colnames(TDryRed)[apply(TDryRed,1,which.max)]

TDryHue <- count(dat, vars=c("DryHue", "id"),wt_var="Depth")
TDryHue<-xtabs(freq~id+DryHue, TDryHue)
TDWA$DryHue <- colnames(TDryHue)[apply(TDryHue,1,which.max)]

TDryValue <- count(dat, vars=c("DryValue", "id"),wt_var="Depth")
TDryValue<-xtabs(freq~id+DryValue, TDryValue)
TDWA$DryValue <- colnames(TDryValue)[apply(TDryValue,1,which.max)]

TDryCClass <- count(dat, vars=c("DryCClass", "id"),wt_var="Depth")
TDryCClass<-xtabs(freq~id+DryCClass, TDryCClass)
TDWA$DryCClass <- colnames(TDryCClass)[apply(TDryCClass,1,which.max)]
TDWA[c(52,60,63),6]=3 # fix 3 occurences where chroma 6 was class 2

TDryChroma <- count(dat, vars=c("DryChroma", "id"),wt_var="Depth")
TDryChroma<-xtabs(freq~id+DryChroma, TDryChroma)
TDWA$DryChroma <- colnames(TDryChroma)[apply(TDryChroma,1,which.max)]

TMoistRed <- count(dat, vars=c("MoistRed", "id"),wt_var="Depth")
TMoistRed<-xtabs(freq~id+MoistRed, TMoistRed)
TDWA$MoistRed <- colnames(TMoistRed)[apply(TMoistRed,1,which.max)]

TMoistHue <- count(dat, vars=c("MoistHue", "id"),wt_var="Depth")
TMoistHue<-xtabs(freq~id+MoistHue, TMoistHue)
TDWA$MoistHue <- colnames(TMoistHue)[apply(TMoistHue,1,which.max)]

TMoistValue <- count(dat, vars=c("MoistValue", "id"),wt_var="Depth")
TMoistValue<-xtabs(freq~id+MoistValue, TMoistValue)
TDWA$MoistValue <- colnames(TMoistValue)[apply(TMoistValue,1,which.max)]

TMoistCClass <- count(dat, vars=c("MoistCClass", "id"),wt_var="Depth")
TMoistCClass<-xtabs(freq~id+MoistCClass, TMoistCClass)
TDWA$MoistCClass <- colnames(TMoistCClass)[apply(TMoistCClass,1,which.max)]
TDWA[c(105,154),11]=3 # fix 1 occurence where chroma 6 was class 2

TMoistChroma <- count(dat, vars=c("MoistChroma", "id"),wt_var="Depth")
TMoistChroma<-xtabs(freq~id+MoistChroma, TMoistChroma)
TDWA$MoistChroma <- colnames(TMoistChroma)[apply(TMoistChroma,1,which.max)]

TTexture <- count(dat, vars=c("Texture", "id"),wt_var="Depth")
TTexture<-xtabs(freq~id+Texture, TTexture)
TDWA$Texture <- colnames(TTexture)[apply(TTexture,1,which.max)]

TSandSize <- count(dat, vars=c("SandSize", "id"),wt_var="Depth")
TSandSize<-xtabs(freq~id+SandSize, TSandSize)
TDWA$SandSize <- colnames(TSandSize)[apply(TSandSize,1,which.max)]

TEffervescence <- count(dat, vars=c("Effervescence", "id"),wt_var="Depth")
TEffervescence<-xtabs(freq~id+Effervescence, TEffervescence)
TDWA$Effervescence <- colnames(TEffervescence)[apply(TEffervescence,1,which.max)]

TEfferScale <- count(dat, vars=c("EfferScale", "id"),wt_var="Depth")
TEfferScale<-xtabs(freq~id+EfferScale, TEfferScale)
TDWA$EfferScale <- colnames(TEfferScale)[apply(TEfferScale,1,which.max)]

  # Subsurface Horizon
SDWA <- PedonDepth

SDryRed <- count(H2, vars=c("DryRed", "id"),wt_var="Depth")
SDryRed<-xtabs(freq~id+DryRed, SDryRed)
SDWA$DryRed <- colnames(SDryRed)[apply(SDryRed,1,which.max)]

SDryHue <- count(H2, vars=c("DryHue", "id"),wt_var="Depth")
SDryHue<-xtabs(freq~id+DryHue, SDryHue)
SDWA$DryHue <- colnames(SDryHue)[apply(SDryHue,1,which.max)]

SDryValue <- count(H2, vars=c("DryValue", "id"),wt_var="Depth")
SDryValue<-xtabs(freq~id+DryValue, SDryValue)
SDWA$DryValue <- colnames(SDryValue)[apply(SDryValue,1,which.max)]

SDryCClass <- count(H2, vars=c("DryCClass", "id"),wt_var="Depth")
SDryCClass<-xtabs(freq~id+DryCClass, SDryCClass)
SDWA$DryCClass <- colnames(SDryCClass)[apply(SDryCClass,1,which.max)]
SDWA[c(52),6]=3 # fix 3 occurences where chroma 6 was class 2

SDryChroma <- count(H2, vars=c("DryChroma", "id"),wt_var="Depth")
SDryChroma<-xtabs(freq~id+DryChroma, SDryChroma)
SDWA$DryChroma <- colnames(SDryChroma)[apply(SDryChroma,1,which.max)]

SMoistRed <- count(H2, vars=c("MoistRed", "id"),wt_var="Depth")
SMoistRed<-xtabs(freq~id+MoistRed, SMoistRed)
SDWA$MoistRed <- colnames(SMoistRed)[apply(SMoistRed,1,which.max)]

SMoistHue <- count(H2, vars=c("MoistHue", "id"),wt_var="Depth")
SMoistHue<-xtabs(freq~id+MoistHue, SMoistHue)
SDWA$MoistHue <- colnames(SMoistHue)[apply(SMoistHue,1,which.max)]

SMoistValue <- count(H2, vars=c("MoistValue", "id"),wt_var="Depth")
SMoistValue<-xtabs(freq~id+MoistValue, SMoistValue)
SDWA$MoistValue <- colnames(SMoistValue)[apply(SMoistValue,1,which.max)]

SMoistCClass <- count(H2, vars=c("MoistCClass", "id"),wt_var="Depth")
SMoistCClass<-xtabs(freq~id+MoistCClass, SMoistCClass)
SDWA$MoistCClass <- colnames(SMoistCClass)[apply(SMoistCClass,1,which.max)]
SDWA[c(105,154),11]=3 # fix 3 occurences where chroma 6 was class 2

SMoistChroma <- count(H2, vars=c("MoistChroma", "id"),wt_var="Depth")
SMoistChroma<-xtabs(freq~id+MoistChroma, SMoistChroma)
SDWA$MoistChroma <- colnames(SMoistChroma)[apply(SMoistChroma,1,which.max)]

STexture <- count(H2, vars=c("Texture", "id"),wt_var="Depth")
STexture<-xtabs(freq~id+Texture, STexture)
SDWA$Texture <- colnames(STexture)[apply(STexture,1,which.max)]

SSandSize <- count(H2, vars=c("SandSize", "id"),wt_var="Depth")
SSandSize<-xtabs(freq~id+SandSize, SSandSize)
SDWA$SandSize <- colnames(SSandSize)[apply(SSandSize,1,which.max)]

SEffervescence <- count(H2, vars=c("Effervescence", "id"),wt_var="Depth")
SEffervescence<-xtabs(freq~id+Effervescence, SEffervescence)
SDWA$Effervescence <- colnames(SEffervescence)[apply(SEffervescence,1,which.max)]

SEfferScale <- count(H2, vars=c("EfferScale", "id"),wt_var="Depth")
SEfferScale<-xtabs(freq~id+EfferScale, SEfferScale)
SDWA$EfferScale <- colnames(SEfferScale)[apply(SEfferScale,1,which.max)]

}
## Using just H2, not H1
# MaxClay <- ddply( H2, 'id', summarize, MaxClay = max(ClayPercent, na.rm = T))
# MaxSand <- ddply(H2, 'id', summarize, MaxSand = max(SandPercent, na.rm = T))
# MaxpH <- ddply(H2, 'id', summarize, MaxpH = max(pH, na.rm = T))
# MaxDryValue <- ddply(H2, 'id', summarize, MaxDryValue = max(DryValue, na.rm = T))
# MaxAWHC <- ddply( H2, 'id', summarize, MaxAWHC = max(AWHC, na.rm = T))
# MaxEffervescence <- ddply( H2, 'id', summarize, MaxEffervescence = max(EfferScale, na.rm = T))

# Janis thinks we should look at whole pedon not remove H1 (11/23/15)
MaxClay <- ddply( dat, 'id', summarize, MaxClay = max(ClayPercent, na.rm = T))
MaxSand <- ddply(dat, 'id', summarize, MaxSand = max(SandPercent, na.rm = T))
MaxpH <- ddply(dat, 'id', summarize, MaxpH = max(pH, na.rm = T))
MaxDryValue <- ddply(dat, 'id', summarize, MaxDryValue = max(DryValue, na.rm = T))
MaxAWHC <- ddply( dat, 'id', summarize, MaxAWHC = max(AWHC, na.rm = T))
MaxEffervescence <- ddply( dat, 'id', summarize, MaxEffervescence = max(EfferScale, na.rm = T))

Max <- join(MaxClay, MaxSand, by = 'id', type = 'inner')
Max <- join(Max, MaxpH, by = 'id', type = 'inner')
Max <- join(Max, MaxDryValue, by = 'id', type = 'inner')
Max <- join(Max, MaxAWHC, by = 'id', type = 'inner')
Max <- join(Max, MaxEffervescence, by = 'id', type = 'inner')
is.na(Max) <- sapply(Max, is.infinite) # replace inf- with NA


#Now calculate depth weighted averages of each continuous variable, then append these to the other variables. 
#Convert to SoilProfileCollection
data <- read.csv("F:/Soils/SoilDataAprilUSGSnotremoved.csv", header = T)
depths(data) <- id ~ top + bottom

# # within each profile, compute weighted means, over the intervals: 0-25,0-50,0-100,0-150,0-200 removing NA if present 
# d25 <- slab(data, id ~ AWHC, slab.structure = c(0,25), slab.fun = mean, na.rm=TRUE)
# d50 <- slab(data, id ~ AWHC, slab.structure = c(0,50), slab.fun = mean, na.rm=TRUE)
# d100 <- slab(data, id ~ AWHC, slab.structure = c(0,100), slab.fun = mean, na.rm=TRUE)
# d150 <- slab(data, id ~ AWHC, slab.structure = c(0,150), slab.fun = mean, na.rm=TRUE)
# d200 <- slab(data, id ~ AWHC, slab.structure = c(0,200), slab.fun = mean, na.rm=TRUE)
# 
# 
# s50 <- slab(data, id ~ AWHC, slab.structure = c(25,50), slab.fun = mean, na.rm=TRUE)
# s100 <- slab(data, id ~ AWHC, slab.structure = c(50,100), slab.fun = mean, na.rm=TRUE)
# s150 <- slab(data, id ~ AWHC, slab.structure = c(100,150), slab.fun = mean, na.rm=TRUE)
# s200 <- slab(data, id ~ AWHC, slab.structure = c(150,200), slab.fun = mean, na.rm=TRUE)
# 
# 
# # reshape to wide format, remove unneeded variables and rename. 
# AWC.0.25 <- dcast(d25, id + top + bottom ~ variable, value.var = 'value')
# AWC.0.25 <- AWC.0.25[,-c(2,3)]
# names(AWC.0.25)[2] <- 'AWC.0.25'
# 
# AWC.0.50 <- dcast(d50, id + top + bottom ~ variable, value.var = 'value')
# AWC.0.50 <- AWC.0.50[,-c(2,3)]
# names(AWC.0.50)[2] <- 'AWC.0.50'
# 
# AWC.0.100 <- dcast(d100, id + top + bottom ~ variable, value.var = 'value')
# AWC.0.100 <- AWC.0.100[,-c(2,3)]
# names(AWC.0.100)[2] <- 'AWC.0.100'
# 
# AWC.0.150 <- dcast(d150, id + top + bottom ~ variable, value.var = 'value')
# AWC.0.150 <- AWC.0.150[,-c(2,3)]
# names(AWC.0.150)[2] <- 'AWC.0.150'
# 
# AWC.0.200 <- dcast(d200, id + top + bottom ~ variable, value.var = 'value')
# AWC.0.200 <- AWC.0.200[,-c(2,3)]
# names(AWC.0.200)[2] <- 'AWC.0.200'
# 
# AWC.25.50 <- dcast(s50, id + top + bottom ~ variable, value.var = 'value')
# AWC.25.50 <- AWC.25.50[,-c(2,3)]
# names(AWC.25.50)[2] <- 'AWC.25.50'
# 
# AWC.50.100 <- dcast(s100, id + top + bottom ~ variable, value.var = 'value')
# AWC.50.100 <- AWC.50.100[,-c(2,3)]
# names(AWC.50.100)[2] <- 'AWC.50.100'
# 
# AWC.100.150 <- dcast(s150, id + top + bottom ~ variable, value.var = 'value')
# AWC.100.150 <- AWC.100.150[,-c(2,3)]
# names(AWC.100.150)[2] <- 'AWC.100.150'
# 
# AWC.150.200 <- dcast(s200, id + top + bottom ~ variable, value.var = 'value')
# AWC.150.200 <- AWC.150.200[,-c(2,3)]
# names(AWC.150.200)[2] <- 'AWC.150.200'


# within each profile, compute weighted means, removing NA if present 
dwaclay <- slab(data, id ~ ClayPercent, slab.structure = c(0,200), slab.fun = mean, na.rm=TRUE)
dwasand <- slab(data, id ~ SandPercent, slab.structure = c(0,200), slab.fun = mean, na.rm=TRUE)
dwapH <- slab(data, id ~ pH, slab.structure = c(0,200), slab.fun = mean, na.rm=TRUE)
dwaawhc <- slab(data, id ~ AWHC, slab.structure = c(0,200), slab.fun = mean, na.rm=TRUE)

# reshape to wide format, remove unneeded variables and rename. 
DWAClay <- dcast(dwaclay, id + top + bottom ~ variable, value.var = 'value')
DWAClay <- DWAClay[,-c(2,3)]
names(DWAClay)[2] <- 'DWAClay'

DWASand <- dcast(dwasand, id + top + bottom ~ variable, value.var = 'value')
DWASand <- DWASand[,-c(2,3)]
names(DWASand)[2] <- 'DWASand'

DWApH <- dcast(dwapH, id + top + bottom ~ variable, value.var = 'value')
DWApH <- DWApH[,-c(2,3)]
names(DWApH)[2] <- 'DWApH'

DWA.AWHC <- dcast(dwaawhc, id + top + bottom ~ variable, value.var = 'value')
DWA.AWHC <- DWA.AWHC[,-c(2,3)]
names(DWA.AWHC)[2] <- 'DWA.AWHC'

# Pull out value at 50cm to compare to Max
clay50 <- slab(data, id ~ ClayPercent, slab.structure = c(50,51), slab.fun = mean, na.rm=TRUE)
sand50 <- slab(data, id ~ SandPercent, slab.structure = c(50,51), slab.fun = mean, na.rm=TRUE)
pH50 <- slab(data, id ~ pH, slab.structure = c(50,51), slab.fun = mean, na.rm=TRUE)
awhc50 <- slab(data, id ~ AWHC, slab.structure = c(50,51), slab.fun = mean, na.rm=TRUE)
efferscale50 <- slab(data, id ~ EfferScale, slab.structure = c(50,51), slab.fun = mean, na.rm=TRUE)
dryvalue50 <- slab(data, id ~ DryValue, slab.structure = c(50,51), slab.fun = mean, na.rm=TRUE)


Clay.50 <- dcast(clay50, id + top + bottom ~ variable, value.var = 'value')
Clay.50 <- Clay.50[,-c(2,3)]
names(Clay.50)[2] <- 'Clay.50'

Sand.50 <- dcast(sand50, id + top + bottom ~ variable, value.var = 'value')
Sand.50 <- Sand.50[,-c(2,3)]
names(Sand.50)[2] <- 'Sand.50'

pH.50 <- dcast(pH50, id + top + bottom ~ variable, value.var = 'value')
pH.50 <- pH.50[,-c(2,3)]
names(pH.50)[2] <- 'pH.50'

AWHC.50 <- dcast(awhc50, id + top + bottom ~ variable, value.var = 'value')
AWHC.50 <- AWHC.50[,-c(2,3)]
names(AWHC.50)[2] <- 'AWHC.50'

EfferScale.50 <- dcast(efferscale50, id + top + bottom ~ variable, value.var = 'value')
EfferScale.50 <- EfferScale.50[,-c(2,3)]
names(EfferScale.50)[2] <- 'EfferScale.50'

DryValue.50 <- dcast(dryvalue50, id + top + bottom ~ variable, value.var = 'value')
DryValue.50 <- DryValue.50[,-c(2,3)]
names(DryValue.50)[2] <- 'DryValue.50'

# #Now calculate depth weighted averages of H2
# #Convert to SoilProfileCollection
# Sub <- H2
# depths(Sub) <- id ~ top + bottom
# 
# # within each profile, compute weighted means, removing NA if present 
# subdwaclay <- slab(Sub, id ~ ClayPercent, slab.structure = c(0,200), slab.fun = mean, na.rm=TRUE)
# subdwasand <- slab(Sub, id ~ SandPercent, slab.structure = c(0,200), slab.fun = mean, na.rm=TRUE)
# subdwapH <- slab(Sub, id ~ pH, slab.structure = c(0,200), slab.fun = mean, na.rm=TRUE)
# subawhc <- slab(Sub, id ~ AWHC, slab.structure = c(0,200), slab.fun = mean, na.rm=TRUE)
# 
# # reshape to wide format, remove unneeded variables and rename. 
# SubDWAClay <- dcast(subdwaclay, id + top + bottom ~ variable, value.var = 'value')
# SubDWAClay <- SubDWAClay[,-c(2,3)]
# names(SubDWAClay)[2] <- 'SubDWAClay'
# 
# SubDWASand <- dcast(subdwasand, id + top + bottom ~ variable, value.var = 'value')
# SubDWASand <- SubDWASand[,-c(2,3)]
# names(SubDWASand)[2] <- 'SubDWASand'
# 
# SubDWApH <- dcast(subdwapH, id + top + bottom ~ variable, value.var = 'value')
# SubDWApH <- SubDWApH[,-c(2,3)]
# names(SubDWApH)[2] <- 'SubDWApH'
# 
# SubAWC <- dcast(subawhc, id + top + bottom ~ variable, value.var = 'value')
# SubAWC <- SubAWC[,-c(2,3)]
# names(SubAWC)[2] <- 'SubAWC'


# slabs <- join(AWC.0.25, AWC.0.50, by = 'id', type = 'inner')
# slabs <- join(slabs, AWC.0.100, by = 'id', type = 'inner')
# slabs <- join(slabs, AWC.0.150, by = 'id', type = 'inner')
# slabs <- join(slabs, AWC.0.200, by = 'id', type = 'inner')
# slabs <- join(slabs, AWC.25.50, by = 'id', type = 'inner')
# slabs <- join(slabs, AWC.50.100, by = 'id', type = 'inner')
# slabs <- join(slabs, AWC.100.150, by = 'id', type = 'inner')
# slabs <- join(slabs, AWC.150.200, by = 'id', type = 'inner')

slabs <- join(DWAClay, DWASand, by = 'id', type = 'inner')
slabs <- join(slabs, DWApH, by = 'id', type = 'inner')
slabs <- join(slabs, DWA.AWHC, by = 'id', type = 'inner')

# slabs <- join(slabs, SubDWAClay, by = 'id', type = 'inner')
# slabs <- join(slabs, SubDWASand, by = 'id', type = 'inner')
# slabs <- join(slabs, SubDWApH, by = 'id', type = 'inner')
# slabs <- join(slabs, SubAWC, by = 'id', type = 'inner')


which(grepl("NaN", Sand.50$Sand.50)) # Tells you the rows it occurs at
# fix 37 occurences where depth was less than 50
Clay.50[c(1),2]=2  
Clay.50[c(86,135),2]=3 
Clay.50[c(32),2]=4 
Clay.50[c(29,63,67,95,97,100,103,104,111,118,132,134),2]=5 
Clay.50[c(7,11),2]=6 
Clay.50[c(84,115,120,126,131),2]=7 
Clay.50[c(9,26,35,55),2]=8 
Clay.50[c(8,10,20,34,47,110),2]=10 
Clay.50[c(18,62,130),2]=15 
Clay.50[c(14),2]=18

Sand.50[1,2]=dat$SandPercent[446] 
Sand.50[7,2]=dat$SandPercent[501]
Sand.50[8,2]=dat$SandPercent[506] 
Sand.50[9,2]=dat$SandPercent[509]
Sand.50[10,2]=dat$SandPercent[513] 
Sand.50[11,2]=dat$SandPercent[515]
Sand.50[14,2]=dat$SandPercent[527] 
Sand.50[18,2]=dat$SandPercent[549]
Sand.50[20,2]=dat$SandPercent[556] 
Sand.50[26,2]=dat$SandPercent[575]
Sand.50[29,2]=dat$SandPercent[587] 
Sand.50[32,2]=dat$SandPercent[598]
Sand.50[34,2]=dat$SandPercent[605] 
Sand.50[35,2]=dat$SandPercent[458]
Sand.50[47,2]=dat$SandPercent[653] 
Sand.50[55,2]=dat$SandPercent[472]
Sand.50[62,2]=dat$SandPercent[480]
Sand.50[63,2]=dat$SandPercent[710] 
Sand.50[67,2]=dat$SandPercent[52]
Sand.50[84,2]=dat$SandPercent[92] 
Sand.50[86,2]=dat$SandPercent[147]
Sand.50[95,2]=dat$SandPercent[148] 
Sand.50[97,2]=dat$SandPercent[150]
Sand.50[100,2]=dat$SandPercent[163] 
Sand.50[103,2]=dat$SandPercent[173]
Sand.50[104,2]=dat$SandPercent[182] 
Sand.50[110,2]=dat$SandPercent[205]
Sand.50[111,2]=dat$SandPercent[210] 
Sand.50[115,2]=dat$SandPercent[222]
Sand.50[118,2]=dat$SandPercent[239] 
Sand.50[120,2]=dat$SandPercent[251]
Sand.50[126,2]=dat$SandPercent[275] 
Sand.50[130,2]=dat$SandPercent[294]
Sand.50[131,2]=dat$SandPercent[297]
Sand.50[132,2]=dat$SandPercent[299] 
Sand.50[134,2]=dat$SandPercent[305]
Sand.50[135,2]=dat$SandPercent[309]

DryValue.50[1,2]=dat$DryValue[446] 
DryValue.50[7,2]=dat$DryValue[501]
DryValue.50[8,2]=dat$DryValue[506] 
DryValue.50[9,2]=dat$DryValue[509]
DryValue.50[10,2]=dat$DryValue[513] 
DryValue.50[11,2]=dat$DryValue[515]
DryValue.50[14,2]=dat$DryValue[527] 
DryValue.50[18,2]=dat$DryValue[549]
DryValue.50[20,2]=dat$DryValue[556] 
DryValue.50[26,2]=dat$DryValue[575]
DryValue.50[29,2]=dat$DryValue[587] 
DryValue.50[32,2]=dat$DryValue[598]
DryValue.50[34,2]=dat$DryValue[605] 
DryValue.50[35,2]=dat$DryValue[458]
DryValue.50[47,2]=dat$DryValue[653] 
DryValue.50[55,2]=dat$DryValue[472]
DryValue.50[62,2]=dat$DryValue[480]
DryValue.50[63,2]=dat$DryValue[710] 
DryValue.50[67,2]=dat$DryValue[52]
DryValue.50[84,2]=dat$DryValue[92] 
DryValue.50[86,2]=dat$DryValue[147]
DryValue.50[95,2]=dat$DryValue[148] 
DryValue.50[97,2]=dat$DryValue[150]
DryValue.50[100,2]=dat$DryValue[163] 
DryValue.50[103,2]=dat$DryValue[173]
DryValue.50[104,2]=dat$DryValue[182] 
DryValue.50[110,2]=dat$DryValue[205]
DryValue.50[111,2]=dat$DryValue[210] 
DryValue.50[115,2]=dat$DryValue[222]
DryValue.50[118,2]=dat$DryValue[239] 
DryValue.50[120,2]=dat$DryValue[251]
DryValue.50[126,2]=dat$DryValue[275] 
DryValue.50[130,2]=dat$DryValue[294]
DryValue.50[131,2]=dat$DryValue[297]
DryValue.50[132,2]=dat$DryValue[299] 
DryValue.50[134,2]=dat$DryValue[305]
DryValue.50[135,2]=dat$DryValue[309]

pH.50[1,2]=dat$pH[446] 
pH.50[7,2]=dat$pH[501]
pH.50[8,2]=dat$pH[506] 
pH.50[9,2]=dat$pH[509]
pH.50[10,2]=dat$pH[513] 
pH.50[11,2]=dat$pH[515]
pH.50[14,2]=dat$pH[527] 
pH.50[18,2]=dat$pH[549]
pH.50[20,2]=dat$pH[556] 
pH.50[26,2]=dat$pH[575]
pH.50[29,2]=dat$pH[587] 
pH.50[32,2]=dat$pH[598]
pH.50[34,2]=dat$pH[605] 
pH.50[35,2]=dat$pH[458]
pH.50[47,2]=dat$pH[653] 
pH.50[55,2]=dat$pH[472]
pH.50[62,2]=dat$pH[480]
pH.50[63,2]=dat$pH[710] 
pH.50[67,2]=dat$pH[52]
pH.50[84,2]=dat$pH[92] 
pH.50[86,2]=dat$pH[147]
pH.50[95,2]=dat$pH[148] 
pH.50[97,2]=dat$pH[150]
pH.50[100,2]=dat$pH[163] 
pH.50[103,2]=dat$pH[173]
pH.50[104,2]=dat$pH[182] 
pH.50[110,2]=dat$pH[205]
pH.50[111,2]=dat$pH[210] 
pH.50[115,2]=dat$pH[222]
pH.50[118,2]=dat$pH[239] 
pH.50[120,2]=dat$pH[251]
pH.50[126,2]=dat$pH[275] 
pH.50[130,2]=dat$pH[294]
pH.50[131,2]=dat$pH[297]
pH.50[132,2]=dat$pH[299] 
pH.50[134,2]=dat$pH[305]
pH.50[135,2]=dat$pH[309]

EfferScale.50[1,2]=dat$EfferScale[446] 
EfferScale.50[7,2]=dat$EfferScale[501]
EfferScale.50[8,2]=dat$EfferScale[506] 
EfferScale.50[9,2]=dat$EfferScale[509]
EfferScale.50[10,2]=dat$EfferScale[513] 
EfferScale.50[11,2]=dat$EfferScale[515]
EfferScale.50[14,2]=dat$EfferScale[527] 
EfferScale.50[18,2]=dat$EfferScale[549]
EfferScale.50[20,2]=dat$EfferScale[556] 
EfferScale.50[26,2]=dat$EfferScale[575]
EfferScale.50[29,2]=dat$EfferScale[587] 
EfferScale.50[32,2]=dat$EfferScale[598]
EfferScale.50[34,2]=dat$EfferScale[605] 
EfferScale.50[35,2]=dat$EfferScale[458]
EfferScale.50[47,2]=dat$EfferScale[653] 
EfferScale.50[55,2]=dat$EfferScale[472]
EfferScale.50[62,2]=dat$EfferScale[480]
EfferScale.50[63,2]=dat$EfferScale[710] 
EfferScale.50[67,2]=dat$EfferScale[52]
EfferScale.50[84,2]=dat$EfferScale[92] 
EfferScale.50[86,2]=dat$EfferScale[147]
EfferScale.50[95,2]=dat$EfferScale[148] 
EfferScale.50[97,2]=dat$EfferScale[150]
EfferScale.50[100,2]=dat$EfferScale[163] 
EfferScale.50[103,2]=dat$EfferScale[173]
EfferScale.50[104,2]=dat$EfferScale[182] 
EfferScale.50[110,2]=dat$EfferScale[205]
EfferScale.50[111,2]=dat$EfferScale[210] 
EfferScale.50[115,2]=dat$EfferScale[222]
EfferScale.50[118,2]=dat$EfferScale[239] 
EfferScale.50[120,2]=dat$EfferScale[251]
EfferScale.50[126,2]=dat$EfferScale[275] 
EfferScale.50[130,2]=dat$EfferScale[294]
EfferScale.50[131,2]=dat$EfferScale[297]
EfferScale.50[132,2]=dat$EfferScale[299] 
EfferScale.50[134,2]=dat$EfferScale[305]
EfferScale.50[135,2]=dat$EfferScale[309]

AWHC.50[1,2]=dat$AWHC[446] 
AWHC.50[7,2]=dat$AWHC[501]
AWHC.50[8,2]=dat$AWHC[506] 
AWHC.50[9,2]=dat$AWHC[509]
AWHC.50[10,2]=dat$AWHC[513] 
AWHC.50[11,2]=dat$AWHC[515]
AWHC.50[14,2]=dat$AWHC[527] 
AWHC.50[18,2]=dat$AWHC[549]
AWHC.50[20,2]=dat$AWHC[556] 
AWHC.50[26,2]=dat$AWHC[575]
AWHC.50[29,2]=dat$AWHC[587] 
AWHC.50[32,2]=dat$AWHC[598]
AWHC.50[34,2]=dat$AWHC[605] 
AWHC.50[35,2]=dat$AWHC[458]
AWHC.50[47,2]=dat$AWHC[653] 
AWHC.50[55,2]=dat$AWHC[472]
AWHC.50[62,2]=dat$AWHC[480]
AWHC.50[63,2]=dat$AWHC[710] 
AWHC.50[67,2]=dat$AWHC[52]
AWHC.50[84,2]=dat$AWHC[92] 
AWHC.50[86,2]=dat$AWHC[147]
AWHC.50[95,2]=dat$AWHC[148] 
AWHC.50[97,2]=dat$AWHC[150]
AWHC.50[100,2]=dat$AWHC[163] 
AWHC.50[103,2]=dat$AWHC[173]
AWHC.50[104,2]=dat$AWHC[182] 
AWHC.50[110,2]=dat$AWHC[205]
AWHC.50[111,2]=dat$AWHC[210] 
AWHC.50[115,2]=dat$AWHC[222]
AWHC.50[118,2]=dat$AWHC[239] 
AWHC.50[120,2]=dat$AWHC[251]
AWHC.50[126,2]=dat$AWHC[275] 
AWHC.50[130,2]=dat$AWHC[294]
AWHC.50[131,2]=dat$AWHC[297]
AWHC.50[132,2]=dat$AWHC[299] 
AWHC.50[134,2]=dat$AWHC[305]
AWHC.50[135,2]=dat$AWHC[309]


slabs <- join(slabs, Sand.50, by = 'id', type = 'inner')
slabs <- join(slabs, Clay.50, by = 'id', type = 'inner')
slabs <- join(slabs, pH.50, by = 'id', type = 'inner')
slabs <- join(slabs, DryValue.50, by = 'id', type = 'inner')
slabs <- join(slabs, EfferScale.50, by = 'id', type = 'inner')
slabs <- join(slabs, AWHC.50, by = 'id', type = 'inner')

# remove anything you don't want H1, H2, Plot, TDWA, SDWA, slabs
H1 <- subset(H1, select = -c(top,bottom,Horizon,Theta_fc,Theta_pwp,AWHC, HzNum) )
SDWA <- subset(SDWA, select = -c(PedonDepth) )
TDWA <- subset(TDWA, select = -c(PedonDepth) )

colnames(H1) = paste("H1", sep=".", colnames(H1)) # Rename variables for H1
H1 <- rename(H1, c("H1.id"="id")) 

colnames(TDWA) = paste("Tot",sep=".", colnames(TDWA)) # Rename variables for H1
names(TDWA)[names(TDWA)=="Tot.id"]<-"id"
colnames(SDWA) = paste("Sub",sep=".", colnames(SDWA)) # Rename variables for H1
names(SDWA)[names(SDWA)=="Sub.id"]<-"id"

# # Create new soil parameter where depth is binary.
# # if the maximum depth is >50/100/150 then 1, if not then 0
# all$Depth50 <- as.numeric(all$PedonDepth > 50)
# all$Depth100 <- as.numeric(all$PedonDepth > 100)
# all$Depth150 <- as.numeric(all$PedonDepth > 150)
Plot$Depth200 <- as.numeric(Plot$PedonDepth == 200)

H1 <- subset(H1, select = -c(H1.DryHue,H1.MoistHue,H1.DryChroma,H1.MoistChroma,H1.Effervescence) )
TDWA <- subset(TDWA, select = -c(Tot.DryHue,Tot.MoistHue,Tot.DryChroma,Tot.MoistChroma,Tot.Effervescence) )
SDWA <- subset(SDWA, select = -c(Sub.DryHue,Sub.MoistHue,Sub.DryChroma,Sub.MoistChroma,Sub.Effervescence) )


Soils <- merge(Plot,H1,by='id')
Soils <- merge(Soils,TDWA,by='id')
# Soils <- merge(Soils,SDWA,by='id')
Soils <- merge(Soils,slabs,by='id')
Soils <- merge(Soils,Max,by='id')

Cat <- subset(Soils, select = c(id,SlopeShape,DepthClass,H1.Texture,H1.SandSize,Tot.Texture,Tot.SandSize) )
Soils <- subset(Soils, select = -c(SlopeShape,DepthClass,H1.Texture,H1.SandSize,Tot.Texture,Tot.SandSize) )
Soils <- merge(Soils,Cat,by='id')


#####
# Keep only Soils data that has matching veg data.
# Add to April Soils
SoilstoKeep <- Soils[c("1","2","10","11","12","14","15","16","17","18","19","20","21","23","24","32","33","38","39","40","42","43","44","47","48","50","57","59","60","61","67","68","73","77","80","82","90"),]
USGSinNSplain <- Soils[c("24","38","40","42","43","80","82"),]
April1 <- Soils[c(66:164),]
Veg <- rbind(April1, SoilstoKeep)
NSveg <- rbind(April1,USGSinNSplain)

# USGS & April
write.csv(Veg,file="F:/Soils/SoilEnvironmentaldataUSGSApril.csv", row.names=FALSE)
# USGS in N&S plain & April
write.csv(NSveg,file="F:/Soils/SoilEnvironmentaldataNSplain.csv", row.names=FALSE)
# April
write.csv(April1,file="F:/Soils/SoilEnvironmentaldataApril.csv", row.names=FALSE)
