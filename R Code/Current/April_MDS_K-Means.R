# MDS before K-Means 05/11/2016



# LPI Data
data <- read.csv("F:/LPI/Output/AprilLPIPercentCover_CombineSome.csv",header=TRUE, row.names=1)


# # plot variance of columns
# mar <- par()$mar
# par(mar=mar+c(0,5,0,0))
# # par(mfrow=c(1,2))
# barplot(sapply(data, var), horiz=T, las=1, cex.names=0.5)
# barplot(sapply(data, var), horiz=T, las=1, cex.names=0.5, log='x')
# par(mar=mar)

######## NMDS #########

library(vegan)
library(MASS)
library(colorspace)
library(plyr)
library(RColorBrewer)
library(scales)

set.seed(32)
ord<-metaMDS(comm=data,distance="euc",trace=FALSE)
ord #.195
plot.sc = scores(ord)
# Stress <0.10 indicates that the ordination is good "with no real 
# risk of drawing false inferences" (Clarke 1993, p. 26). 
# linear fit is the fit between ordination values and distances
stressplot(ord) 
gof <- goodness(ord)

### K-Means ###
set.seed(32)
# Determine number of clusters
wss <- (nrow(ord$points)-1)*sum(apply(ord$points,2,var))
for (i in 2:15) wss[i] <- sum(kmeans(ord$points,
                                     centers=i)$withinss)
plot(1:15, wss, type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares")


# From scree plot elbow occurs at k = 3 (or 8?)
# Apply k-means with k=3 (then try 8)
set.seed(32)
k <- kmeans(ord$points, 7, nstart=25, iter.max=1000)


# Correct Legend names 
val <- sort(unique(k$cluster))
val2 <- c()
for(clust in val){
  val2 <- c(val2, paste("Cluster", as.character(clust), sep=" "))
}

palette(alpha(brewer.pal(9,'Set1'), 0.5))
plot(ord$points, col=k$clust, pch=16)
legend('bottomleft', c(val2)
       ,pch=16, col=val,x.intersp=0.6
       ,y.intersp=0.3,bty="n")
text(ord, display="sites", col="black", cex=0.5, pos=3)

ordihull(ord, groups = k$clust, display = "sites"
         ,draw="polygon")


# Cluster sizes

table(k$clust)
clust <- names(table(k$clust))

# First cluster
row.names(data[k$clust==clust[1],])
# Second Cluster
row.names(data[k$clust==clust[2],])
# Third Cluster
row.names(data[k$clust==clust[3],])
# Fourth Cluster
row.names(data[k$clust==clust[4],])
# Fifth Cluster
row.names(data[k$clust==clust[5],])
# Sixth Cluster
row.names(data[k$clust==clust[6],])
# Seventh Cluster
row.names(data[k$clust==clust[7],])
# Eighth Cluster
row.names(data[k$clust==clust[8],])

# Pull Out Cluster Plot Names
Clust1 <- row.names(data[k$clust==clust[1],])
Clust2 <- row.names(data[k$clust==clust[2],])
Clust3 <- row.names(data[k$clust==clust[3],])
Clust4 <- row.names(data[k$clust==clust[4],])
Clust5 <- row.names(data[k$clust==clust[5],])
Clust6 <- row.names(data[k$clust==clust[6],])
Clust7 <- row.names(data[k$clust==clust[7],])
Clust8 <- row.names(data[k$clust==clust[8],])



### Health Data ###

LA<-read.csv("F:/Health/LeafAreaEpidermalConductance.csv",header=TRUE)
LA <- LA[ which(!LA$Wet.Dry<0.000000), ] # Remove negative weights.
LA <- LA[,c(1,14:15)]

NP<-read.csv("F:/Health/April Sagebrush N and Protein.csv",header=TRUE)
NP <- NP[,c(2,5:6)]

# find means from LA
pdw <- ddply( LA, 'Plot', summarize, pdw = mean(PctDryWeight, na.rm = T))
sla <- ddply( LA, 'Plot', summarize, sla = mean(SLAcm, na.rm = T))
LA <- join(pdw, sla, by = 'Plot', type = 'inner')

# What plots do LA and NP have in common?
LA.NP <- merge(NP, LA, by=c("Plot")) 


# Find which Health rows are in which clusters
LAC1 <- LA[LA$Plot %in% Clust1,]
LAC2 <- LA[LA$Plot %in% Clust2,]
LAC3 <- LA[LA$Plot %in% Clust3,]
LAC4 <- LA[LA$Plot %in% Clust4,]
LAC5 <- LA[LA$Plot %in% Clust5,]
LAC6 <- LA[LA$Plot %in% Clust6,]
LAC7 <- LA[LA$Plot %in% Clust7,]
LAC8 <- LA[LA$Plot %in% Clust8,]


NPC1 <- NP[NP$Plot %in% Clust1,]
NPC2 <- NP[NP$Plot %in% Clust2,]
NPC3 <- NP[NP$Plot %in% Clust3,]
NPC4 <- NP[NP$Plot %in% Clust4,]
NPC5 <- NP[NP$Plot %in% Clust5,]
NPC6 <- NP[NP$Plot %in% Clust6,]
NPC7 <- NP[NP$Plot %in% Clust7,]
NPC8 <- NP[NP$Plot %in% Clust8,]



# Find the Mean of each column (each health variable) 
MeanLAC1 <- colMeans(LAC1[,c(2,3)])
MeanLAC2 <- colMeans(LAC2[,c(2,3)])
MeanLAC3 <- colMeans(LAC3[,c(2,3)])
MeanLAC4 <- colMeans(LAC4[,c(2,3)])
MeanLAC5 <- colMeans(LAC5[,c(2,3)])
MeanLAC6 <- colMeans(LAC6[,c(2,3)])
MeanLAC7 <- colMeans(LAC7[,c(2,3)])
MeanLAC8 <- colMeans(LAC8[,c(2,3)])

MeanNPC1 <- colMeans(NPC1[,c(2,3)])
MeanNPC2 <- colMeans(NPC2[,c(2,3)])
MeanNPC3 <- colMeans(NPC3[,c(2,3)])
MeanNPC4 <- colMeans(NPC4[,c(2,3)])
MeanNPC5 <- colMeans(NPC5[,c(2,3)])
MeanNPC6 <- colMeans(NPC6[,c(2,3)])
MeanNPC7 <- colMeans(NPC7[,c(2,3)])
MeanNPC8 <- colMeans(NPC8[,c(2,3)])



# Combine means of LA and NP into one string
MeanC1 <- c(MeanLAC1,MeanNPC1)
MeanC2 <- c(MeanLAC2,MeanNPC2)
MeanC3 <- c(MeanLAC3,MeanNPC3)
MeanC4 <- c(MeanLAC4,MeanNPC4)
MeanC5 <- c(MeanLAC5,MeanNPC5)
MeanC6 <- c(MeanLAC6,MeanNPC6)
MeanC7 <- c(MeanLAC7,MeanNPC7)
MeanC8 <- c(MeanLAC8,MeanNPC8)



# Combine into cluster mean table
Mean <- rbind(MeanC1,MeanC2,MeanC3,MeanC4,MeanC5,MeanC6,MeanC7)




### Add in Soils Varibles ###
data.env <- read.csv("F:/Soils/SoilEnvironmentaldataApril.csv",header=TRUE, row.names=1)
data.env[is.na(data.env)] <- 0 # replace NA with 0

fit.env <- envfit(ord,data.env,perm=1000)
fit.env


# Pull out statistically significant data 
  # Seperate factors vs vectors
#sig.fit.env <- data.env[ which(fit.env$vectors$pvals<.05), ]
sig.fit.env <- data.env[fit.env$vectors$pvals<.05]
sig.fit.env <- envfit(ord,sig.fit.env,perm=1000)
sig.fit.env$factors <- NULL
sig.fit.env # Check that you pulled up the right vectors.

#v.sig.fit.env <- data.env[ which(fit.env$factors$pvals<.05), ]
v.sig.fit.env <- data.env[fit.env$factors$pvals<.05]
v.sig.fit.env <- envfit(ord,v.sig.fit.env,perm=1000)
v.sig.fit.env$vectors <- NULL
v.sig.fit.env # Check that you pulled up the right factors.

# v.sig.fit.env.DC <- data.env[ which(fit.env$factors$var.id=="DepthClass"), ]
# v.sig.fit.env.DC <- data.env[fit.env$factors$var.id=="DepthClass"]
# v.sig.fit.env.DC <- envfit(ord,v.sig.fit.env.DC,perm=1000)
# v.sig.fit.env.DC$vectors <- NULL
# v.sig.fit.env.DC

### Plot Soils and Ordihull ###
par(mfrow=c(1,1))
plot(ord$points, col=k$clust, pch=16,
     xlim=c(-0.4,0.25),ylim=c(-0.2,0.35))

legend('topright', c(val2),xjust=1,yjust=0
       ,pch=16, col=val,x.intersp=0.5
       ,y.intersp=0.8,bty="n",inset=.001)

ordihull(ord, groups = k$clust, display = "sites"
         ,draw="polygon")

plot(sig.fit.env,col="blue", cex=0.7,font=2)
title(main = "Soil Variables")

plot(v.sig.fit.env,col="blue", cex=0.7,font=2)
title(main = "Soil Variables")

### Add Health Data to Ordination plot ###

text(k$centers,labels=c(signif((Mean[,1]),digits=2)))
title(main = "Percent Dry Weight")

text(k$centers,labels=c(signif((Mean[,2]),digits=3)))
title(main = "Specific Leaf Area")

text(k$centers,labels=c(signif((Mean[,3]),digits=3)))
title(main = "Nitrogen Percent")

text(k$centers,labels=c(signif((Mean[,4]),digits=3)))
title(main = "Protein Percent")



# #myData <- v.sig.fit.env$factors$centroids
# #myDataNames <- dimnames(myData)[1]
# names1 <- names(sig.fit.env$vectors$r)
# names2 <- names(v.sig.fit.env$factors$r)

#plot(myData,col="green4", cex=0.7,font=2)



# ordiplot(ord)
# ordiplot(ord, display ="sites", type ="n"
#          ,xlim=c(-0.25,0.3),ylim=c(-0.2,0.4))
# text(ord, display="sites", col="black", cex=0.5)
# text(ord, display="species", col="red", cex=0.5)
# 


### Boxplots ###

# Compare accommodation by cluster in boxplot 
boxplot(data$KRLA2 ~ k$cluster,
        xlab='Cluster', ylab='Krascheninnikovia lanata ',
        main='Krascheninnikovia lanata  by Cluster')

boxplot(data$JUOS ~ k$cluster,
        xlab='Cluster', ylab='Juniperus osteosperma',
        main='Juniperus osteosperma by Cluster')

boxplot(data$PIED ~ k$cluster,
        xlab='Cluster', ylab='Pinus edulis ',
        main='Pinus edulis  by Cluster')

boxplot(data$Bare.Soil ~ k$cluster,
        xlab='Cluster', ylab='Bare Soil',
        main='Bare Soil by Cluster')

boxplot(data$ARTR2 ~ k$cluster,
        xlab='Cluster', ylab='Artemisia tridentata ',
        main='Artemisia tridentata  by Cluster')

boxplot(data$ARTR2.D ~ k$cluster,
        xlab='Cluster', ylab='Dead Artemisia tridentata ',
        main='Dead Artemisia tridentata  by Cluster')

boxplot(data$ATCA2 ~ k$cluster,
        xlab='Cluster', ylab='Atriplex canescens',
        main='Atriplex canescens by Cluster')

boxplot(data$BOGR2 ~ k$cluster,
        xlab='Cluster', ylab='Bouteloua gracilis',
        main='Bouteloua gracilis by Cluster')

boxplot(data$SPCR ~ k$cluster,
        xlab='Cluster', ylab='Sporobolus cryptandrus',
        main='Sporobolus cryptandrus by Cluster')

boxplot(data$HECO26 ~ k$cluster,
        xlab='Cluster', ylab='Hesperostipa comata',
        main='Hesperostipa comata by Cluster')

boxplot(data$OPPO ~ k$cluster,
        xlab='Cluster', ylab='Opuntia polyacantha ',
        main='Opuntia polyacantha  by Cluster')



# Bar graph each cluster by species
for (i in 1:7){
  cluster <- data[k$cluster==i,]
  par(mar=c(1,1,1,1))
  par(las=2) # make label text perpendicular to axis
  par(mar=c(5,8,4,2)) # increase y-axis margin.
  par(mfrow=c(1,1)) # number of plots on a page
  
  # barplot(as.matrix(cluster)
  #         , main=paste("Cluster ",toString(i))
  #         , sub="Sum"
  #         , xlab="")
  # 
  barplot(sapply(cluster, function(x) mean(as.numeric(x)) )
          , main=paste("Cluster ",toString(i))
          , sub="Average"
          , xlab="")
  
}
