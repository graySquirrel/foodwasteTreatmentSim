# simuTreat.R to simulate treatments
#    of different feedstocks to generate GHG and cost outputs.

source("treatmentClasses.R") 
source("treatmentLandfill.R") 
source("parseGlobalFactors.R")

f1 <- Feedstock(type="OFMSW",TS=0.3,VS=0.90,Bo=334,TKN=5600,
                percentCarboTS = 0.8, percentProteinTS = 0.10, percentLipidTS = 0.10,
                fdeg = 0.84)

print(paste("TS",f1$TS,"Lo ",f1$Lo," TVS ",f1$TVS,"initialC ",f1$InitialC))
g1 <- getGlobalFactorsFromFile(doRanges = FALSE,verbose = TRUE)
res <- LandfillTreatmentPathway(f1, g1, debug = T)
print(res)
#res <- LandfillTreatmentPathway(f1, g1, debug = T, sequesterCarbon = F)
#print(res)