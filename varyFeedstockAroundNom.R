# varyFeedstockAroundNom will vary a feedstock factors systematically to sample
#   a hypercube over the ranges of interest
#setwd("C:/Users/febner/Documents/CourseraDataScience/fracGASM")
source("treatmentClasses.R") 
source("treatmentAnaerobicDigestion.R") 
source("treatmentLandApplication.R") 
source("treatmentLandfill.R")
source("treatmentcompost.R")
###########################################################
createSamples <- function(dims=4,level=1,samps=10,min=0,max=1) {
    rep(0:(samps-1),times=samps^(level-1),each=samps^(dims-level))*((max-min)/(samps-1)) + min
}
###########################################################
plotit <- function(a,x,col='red',plotranges=FALSE) {
    #modelQ1<-lm(a ~ x)
    newx <- seq(min(x), max(x), length.out = 10)
    asum <- boxplot(a ~ x,plot= FALSE)
    if(plotranges) {
        polygon(c(rev(newx), newx), c(rev(asum$stats[5,]), asum$stats[1,]), col = 'grey95', border = NA)
        polygon(c(rev(newx), newx), c(rev(asum$stats[4,]), asum$stats[2,]), col = 'grey90', border = NA)
        # polygon(c(rev(newx), newx), c(rev(asum$conf[2,]), asum$conf[1,]), col = 'grey85', border = NA)
    }
    lines(asum$stats[3,]~newx,type='l',lwd=2, col=col)
}
###########################################################
plotBaselineFeedstocks <- function(inVar='NULL',offset=NULL,doleg2 = FALSE) {
    # dho, assumes we have o2 and f2 in scope.
    outVar <- lapply(o2,function(i) i[,1])
    points(inVar,outVar$AD,pch=c(2,3,4,5,6,15,16,17,18,19,20),col='red')
    points(inVar,outVar$LF,pch=c(2,3,4,5,6,15,16,17,18,19,20),col='green')
    points(inVar,outVar$CM,pch=c(2,3,4,5,6,15,16,17,18,19,20),col='black')
    points(inVar,outVar$CMf,pch=c(2,3,4,5,6,15,16,17,18,19,20),col='cyan')
    points(inVar,outVar$CMp,pch=c(2,3,4,5,6,15,16,17,18,19,20),col='blue')
    if(doleg2)
        legend(0.8, 6000, f2$type,ncol=2,
               pch=c(2,3,4,5,6,15,16,17,18,19,20))
}
###########################################################
plotAllOneVar <- function(inVar=NULL,xaxis='no',
                          doleg = FALSE,plotranges=FALSE,inVar2=NULL,
                          doleg2 = FALSE) {
    myin<-inVar
    minlim <- min(outAD[,1],outLF[,1],outCM[,1],outCMf[,1],outCMp[,1])
    maxlim <- max(outAD[,1],outLF[,1],outCM[,1],outCMf[,1],outCMp[,1])
     plot(outAD[,1] ~ myin,xlab=xaxis,ylab='Net Emissions', type = 'n',
              ylim=c(minlim, 3000))
#     plotit(outAD[,1], myin,'red',plotranges)
#     plotit(outLF[,1], myin,'green3',plotranges)
#     plotit(outCM[,1], myin,'black',plotranges)
#     plotit(outCMf[,1], myin,'cyan',plotranges)
#     plotit(outCMp[,1], myin,'blue',plotranges)
    if(doleg)
        legend(0.05, maxlim*0.95, c("AD","LF","CM","CMf","CMp"),
               lty=c(1,1,1,1,1),
               lwd=c(2.5,2.5,2.5,2.5,2.5),
               col=c('red','green3','black','cyan','blue'))
    plotBaselineFeedstocks(inVar2,(maxlim-minlim)*0.2,doleg2 = doleg2)
}
############################################################
getBaselineFeedstocks <- function(ins, f, g) {
    o<-NULL
    o$AD <- AnaerobicDigestionTreatmentPathway(f, g, Application = 'noDisplace')
    o$ADf <- AnaerobicDigestionTreatmentPathway(f, g, Application = 'Fertilizer')
    o$LA <- LandApplicationTreatmentPathway(f, g, Nremaining = f$TKN, 
                                            Application = 'noDisplace')
    o$LAf <- LandApplicationTreatmentPathway(f, g, Nremaining = f$TKN, 
                                             Application = 'Fertilizer')
    o$CM <- compostTreatmentPathway(f, g, Application = 'noDisplace')
    o$CMf <- compostTreatmentPathway(f, g, Application = 'Fertilizer')
    o$CMp <- compostTreatmentPathway(f, g, Application = 'Peat')
    o$LF <- LandfillTreatmentPathway(f, g)
    o
}
############################################################
####  Change these params to do a diff one.
numsampsPerDimension = 10 # Will create numsampsPerDimension^4 samples for the cube
inputs <- data.frame(createSamples(dims=4,level=1,samps=numsampsPerDimension, min=0.038,max=0.937))
inputs <- cbind(inputs, createSamples(dims=4,level=2,samps=numsampsPerDimension, min=0.8, max= 1))
inputs <- cbind(inputs, createSamples(dims=4,level=3,samps=numsampsPerDimension, min=180, max=1100))
inputs <- cbind(inputs, createSamples(dims=4,level=4,samps=numsampsPerDimension, min=3700, max=13000))
colnames(inputs) <- c("TS","VS","Bo","TKN")

f1 <- Feedstock(type="variability", TS=inputs[,1], VS=inputs[,2], Bo=inputs[,3], TKN=inputs[,4])
g1 <- GlobalFactors()
outAD <- AnaerobicDigestionTreatmentPathway(f1, g1, debug = F)
outLF <- LandfillTreatmentPathway(f1, g1, debug = F)
outCM <- compostTreatmentPathway(f1, g1, 'noDisplace', debug = F)
outCMf <- compostTreatmentPathway(f1, g1, 'Fertilizer', debug = F)
outCMp <- compostTreatmentPathway(f1, g1, 'Peat', debug = F)

i <- read.csv(file="Feedstock.csv",sep = ",",stringsAsFactors=FALSE)
f2 <- Feedstock(type=i$Feedstock,TS=i$TS,VS=i$VS,Bo=i$Bo,TKN=i$TKN,
                percentCarboTS = i$PercentCarboTS, percentLipidTS = i$PercentlipidTS,
                percentProteinTS = i$PercentproteinTS, fdeg = i$fdeg)
g2 <- GlobalFactors()
o2 <- getBaselineFeedstocks(i,f2,g2)

#if(dev.cur() != 1) dev.off() 
#par(mfrow=c(2,2))
noranges=FALSE
if(noranges) {
    plotAllOneVar(inputs$TS, inVar2=i$TS,xaxis='TS',doleg=TRUE)
    plotAllOneVar(inputs$VS, inVar2=i$VS,xaxis='VS',doleg2=TRUE)
    plotAllOneVar(inputs$Bo, inVar2=i$Bo,xaxis='Bo')
    plotAllOneVar(inputs$TKN, inVar2=i$TKN,xaxis='TKN')
} else {
    plotAllOneVar(inputs$TS, inVar2=i$TS,xaxis='TS',doleg=TRUE,plotranges=TRUE)
    plotAllOneVar(inputs$VS, inVar2=i$VS,xaxis='VS',plotranges=TRUE,doleg2=TRUE)
    plotAllOneVar(inputs$Bo, inVar2=i$Bo,xaxis='Bo',plotranges=TRUE)
    plotAllOneVar(inputs$TKN, inVar2=i$TKN,xaxis='TKN',plotranges=TRUE)
}
