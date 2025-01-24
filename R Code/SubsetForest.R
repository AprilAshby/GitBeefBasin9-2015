library(Boruta)
library(randomForest)

# usgs<-read.csv("F:/Soils/SoilEnvironmentaldataUSGSApril.csv",header=TRUE, row.names=1)
# usgs.den <- read.csv("F:/LPI/Output/USGSLPIDensityM2.csv",header=TRUE, row.names=1)
# 
# usgs.count <- usgs.den[c(1:37),]*90
# april.count <- usgs.den[c(38:136),]*150
# count <- rbind(usgs.count,april.count)
# 
# usgs$ARTR2 <- count$ARTR2
# usgs1 <- subset(usgs, select = -c(DepthClass,Aspect,Sand.50,Clay.50,pH.50,DryValue.50,EfferScale.50,AWHC.50,MaxClay,DWASand,DWA.AWHC,Tot.Texture,H1.Texture,SlopeShape,Tot.SandSize,H1.SandSize,H1.DryRed,H1.DryValue,H1.DryCClass,Tot.DryRed,Tot.DryValue,Tot.DryCClass,MaxSand,MaxpH,MaxDryValue,MaxAWHC))
# 
# c <- cbind(b[, which(colnames(b)%in% colnames(a))],
#            a[, which(colnames(a)%in% colnames(b))])


u<-read.csv("F:/Soils/SoilSubset.csv",header=TRUE, row.names=1)
u.den <- read.csv("F:/LPI/Output/USGSLPIDensityM2.csv",header=TRUE, row.names=1)
u$ARTR2 <- u.den$ARTR2

rownames(u)[rowSums(is.na(u)) > 0]
u[is.na(u)] <- 0 # replace NA with 0


Boruta.live <- Boruta(ARTR2~., data = u, doTrace = 2, ntree = 1000)
Boruta.live
TentativeRoughFix(Boruta.live, averageOver = Inf)
Boruta.live$finalDecision

live.rf = randomForest(as.numeric(ARTR2) ~ .
                       , data = u,proximity=TRUE,
                       importance=TRUE,keep.forest=TRUE,
                       na.action = na.omit,
                       ntree = 1000)


varImpPlot(live.rf, sort=TRUE, main = 'Live Sagebrush')

round(importance(live.rf,type=1), 2)

importance(live.rf, type=1)

plot(live.rf, type="l", main=deparse(substitute(live.rf)))


predict(live.rf, type="response",norm.votes=TRUE, predict.all=FALSE, proximity=FALSE, nodes=FALSE)



imp <- importance(live.rf)
impvar <- rownames(imp)[order(imp[, 1], decreasing=TRUE)]

op <- par(mfrow=c(2, 3))
for (i in seq_along(impvar)) {
  partialPlot(live.rf, u, impvar[i], xlab=impvar[i],
              main=paste("Partial Dependence on", impvar[i]),
              ylim=c(30, 70))
}
par(op)








# op <- par(mar=c(5.1, 4.1, 4.1, 2.1))
# par(mar=c(2,2,2,2))
# 
# importanceOrder=order(-live.rf$importance)
# names=rownames(live.rf$importance)[importanceOrder][1:15]
# par(mfrow=c(5, 3), xpd=NA)
# for (name in names)
#     partialPlot(live.rf, u,x.var=ARTR2, eval(name), main=name, xlab=name,ylim=c(-.2,.9))
# 
# par(op)



# x <- u[,c(1:24)]
# y <- u[,25]
# rf.cv <- rfcv(x, y, cv.fold=10)
# 
# with(rf.cv, plot(n.var, error.cv))
# 
# library(rfUtilities)
# multi.collinear(x, p = 0.05)




###
# Partial Dependence Plots
###

partialPlot(live.rf,u, H1.ClayPercent, main = 'Live Sagebrush Partial Dependence on ...')

partialPlot(live.rf,u, PedonDepth, main = 'Live Sagebrush Partial Dependence on ...')

partialPlot(live.rf,u, H1.DWA_AWC, main = 'Live Sagebrush Partial Dependence on ...')

partialPlot(live.rf,u, H1.Texture, main = 'Live Sagebrush Partial Dependence on ...')

partialPlot(live.rf,u, H1.MoistRed, main = 'Live Sagebrush Partial Dependence on ...')

partialPlot(live.rf,u, DepthClass, main = 'Live Sagebrush Partial Dependence on ...')

partialPlot(live.rf,u, H1.SandSize, main = 'Live Sagebrush Partial Dependence on ...')

partialPlot(live.rf,u, SlopeShape, main = 'Live Sagebrush Partial Dependence on ...')

