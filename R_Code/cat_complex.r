#
# <cat_dish_complex_30d.r> - R script to build a complex-wide summary dataframe.
#           
#                 Example execution:
#
#                 
#   James D Reed (james.reed@hp.com)                
#   May 12, 2014
#
## 
blank.df <- data.frame(Epoch.DT=0,    Int.Date=as.Date("01/01/2000", format="%Y-%m-%d"), Int.Time=0, CPU.User=0.0, CPU.Sys=0.0, 
                       CPU.Intrpt=0,  CPU.SysCall=0, CPU.Tot=0.0,        CPU.Act=0.0, Interrpt=0.0, Run.Queue=0.0, Alive.Proc=0,
                       Active.Proc=0, SysCall.Num=0, SysCall.Rt=0.0,     Mem.Pct=0.0, MemPO.Rt=0.0, MemSO.Rt=0.0,
                       Mem.Queue=0.0, DiskPhys.IORt=0, DiskPhys.BtRt=0,  DiskReq.Queue=0.0, InPkt.Rt=0.0, OutPkt.Rt=0.0)

host <- c("N/A")
START <- c(as.Date("2000-01-01")); END <- c(as.Date("2000-01-01"))
DAYS <- c(0.0); OBS <- c(0.0)
max.epoch <- c(0); min.epoch <- 9999999999999999999999;
vPars <- c("")

#
# Get file names and number
#
files <- list.files(path="./DATA",pattern="*.r")
numVpars <- length(files)


#
# Let's find the min of the max Epoch.DT and set this as the end date.
#
j <- 1
for (i in files) {
  x <- read.csv(as.character(paste("./DATA/",i,sep="")))
  #
  # Fix dates ...	
  #
  x$Int.Date <- as.Date(x$Int.Date,"%m/%d/%Y")
  max.epoch[j] <- x[nrow(x),"Epoch.DT"]
  
}

  #
  # Select last 30 days of data
  #

  endEpoch <- min(max.epoch)
  startEpoc <- endEpoch - (30*24*60*60)



#
#  Loop over Epoch every five minutes and calculate the aggregated data values
#
complex <- blank.df
dt.rec <- blank.df

dt <- startEpoch
repeat {
  dt.rec$Epoch.DT <- dt
  CPUSum <- 0.0
  coreSum <- 0
  k <- 0
  for (i in vPars) {
    k <- k + 1
    assign(vPars[k],x)
    coreSum <- coreSum + x[x$Epoch.DT == dt,x$CPU.Act]/2   
    CPUSum <-   (x$CPU.Act)/2 * x$CPU.Tot
  }
  dt.rec$CPU.Tot <- CPUSum/coreSum
  complex <- rbind(data.frame(dt.rec)) 
  
  dt <- dt + (5*60)
  if (dt > endEpoch) {
      break
  }
}



#assign(paste("complex_",basename(getwd()),sep=""),blank.df)



save.image()

