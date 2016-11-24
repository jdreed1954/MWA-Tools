#
# <import_dish_30d.r> - R script to load last thirty days pf data from R datafiles created by 
#                          extracting performance data from Measureware global data logs.
#           
#                 Example execution:
#
#           > source('C:/Users/jxreed/Desktop/MyProjects/bin/import_dish_30d.r')
#           [1] "sea-hp03"
#           [1] "sea-hp04"
#           [1] "sea-hp11"
#           [1] "sea-hp12"
#           [1] "twoface"
#           There were 20 warnings (use warnings() to see them)
#                 
#   James D Reed (james.reed@hp.com)                
#   July 1, 2013
#
## 
parMax <- 15;

START <- c(rep(as.Date("2000-01-01"),parMax)); END <- c(rep(as.Date("2000-01-01"),parMax));
DAYS <- c(rep(0,parMax));                      OBS <- c(rep(0.0,parMax));

DATAROOT  <- "C:/Users/jxreed/Desktop/MyProjects/bin/global/";

# Specify here the database table from a previous era.
dbs <- read.csv(DBFILE, header=T, sep=",", fill=T,stringsAsFactors=F);


db <- c(rep(" ",parMax));            host <- c(rep("N/A",parMax));
START <- c(rep(0,parMax));           END <- c(rep(0,parMax));
CPU.Min <- c(rep(0.00,parMax));      CPU.Max <- c(rep(0.00,parMax)); 
CPU.Avg <- c(rep(0.00,parMax));      CPU.Std <- c(rep(0.00, parMax));
CPU.90th <- c(rep(0.00,parMax));     CPU.95th <- c(rep(0.00,parMax)); 
CPU.98th <- c(rep(0.00,parMax));     COR.Min <- c(rep(0.00,parMax)); 
COR.Max <- c(rep(0.00,parMax));      COR.Avg <- c(rep(0.00,parMax)); 
COR.Std <- c(rep(0.00,parMax));      MEM.Min <- c(rep(0.00,parMax)); 
MEM.Max <- c(rep(0.00,parMax));      MEM.Avg <- c(rep(0.00,parMax)); 
MEM.Std <- c(rep(0.00,parMax));      MEM.98th <- c(rep(0.00,parMax));
RQ.Min <- c(rep(0.00,parMax));       RQ.Max <- c(rep(0.00,parMax)); 
RQ.Avg <- c(rep(0.00,parMax));       RQ.Std <- c(rep(0.00,parMax));
RQ.98th <- c(rep(0.00,parMax));

PRC.Min <- c(rep(0.00,parMax));      PRC.Max <- c(rep(0.00,parMax)); 
PRC.Avg <- c(rep(0.00,parMax));      PRC.Std  <- c(rep(0.00,parMax));
ACT.Min <- c(rep(0.00,parMax));      ACT.Max <- c(rep(0.00,parMax)); 
ACT.Avg <- c(rep(0.00,parMax));      ACT.Std  <- c(rep(0.00,parMax));
PIO.Min <- c(rep(0.00,parMax));      PIO.Max <- c(rep(0.00,parMax)); 
PIO.Avg <- c(rep(0.00,parMax));      PIO.Std  <- c(rep(0.00,parMax)); 
PIO.98th <- c(rep(0.00,parMax));     PIOPS.Min <- c(rep(0.00,parMax)); 
PIOPS.Max <- c(rep(0.00,parMax));    PIOPS.Avg <- c(rep(0.00,parMax)); 
PIOPS.Std  <- c(rep(0.00,parMax));   PIOPS.98th <- c(rep(0.00,parMax));
NTI.Min <- c(rep(0.00,parMax));      NTI.Max <- c(rep(0.00,parMax));  
NTI.Avg <- c(rep(0.00,parMax));      NTI.Std <- c(rep(0.00,parMax));
NTO.Min <- c(rep(0.00,parMax));      NTO.Max <- c(rep(0.00,parMax)); 
NTO.Avg <- c(rep(0.00,parMax));      NTO.Std <- c(rep(0.00,parMax));
INT.Min <- c(rep(0.00,parMax));      INT.Max <- c(rep(0.00,parMax)); 
INT.Avg <- c(rep(0.00,parMax));      INT.Std <- c(rep(0.00,parMax));

print(getwd())
files <- list.files(path="./DATA",pattern="*.r")
numPars <- length(files)
j <- 1

for (i in files) {
	x <- read.csv(as.character(paste("./DATA/",i,sep="")))
  #
	# Fix dates ...	
	#
	x$Int.Date <- as.Date(x$Int.Date,"%m/%d/%Y")
	#
  # Select last 30 days of data
	#
  enddate <- max(x$Int.Date)
	startdate <- as.Date(enddate - 30)
	x <- x[which(x$Int.Date >= startdate & x$Int.Date <= enddate),]
  i <- substr(i,1,nchar(i)-2)
	assign(i,x)
	print(i)
        host[j] = i
	      db[j] <- dbs[dbs$vpar==host[j],2]
        #   db[j] <- "N/A"
        START[j] <- as.Date(startdate)
        END[j]   <- as.Date(enddate)
        DAYS[j] <- enddate - startdate
        OBS[j] <- nrow(x)
        
        # ---------------------------- CPU.Tot
        CPU.Min[j]=min(x$CPU.Tot)
        CPU.Max[j]=max(x$CPU.Tot)
        CPU.Avg[j]=mean(x$CPU.Tot)
        CPU.Std[j]=sd(x$CPU.Tot)
        CPU.90th[j]=quantile(x$CPU.Tot,.90)
        CPU.95th[j]=quantile(x$CPU.Tot,.95)
        CPU.98th[j]=quantile(x$CPU.Tot,.98)
  
	     # ---------------------------- CPU.Act
    	COR.Min[j]=min(x$CPU.Act)/2
	    COR.Max[j]=max(x$CPU.Act)/2
	    COR.Avg[j]=mean(x$CPU.Act)/2
	    COR.Std[j]=sd(x$CPU.Act)/2
	
        # ---------------------------- Mem.Pct
	    MEM.Min[j] =min(x$Mem.Pct)
	    MEM.Max[j] =max(x$Mem.Pct)
	    MEM.Avg[j] =mean(x$Mem.Pct)
	    MEM.Std[j] =sd(x$Mem.Pct)
      MEM.98th[j]=quantile(x$MEM.Pct,.98)
	
        # ---------------------------- Run.Queue
	    RQ.Min[j] =min(x$Run.Queue)
	    RQ.Max[j] =max(x$Run.Queue)
	    RQ.Avg[j] =mean(x$Run.Queue)
	    RQ.Std[j] =sd(x$Run.Queue)
      RQ.98th[j]=quantile(x$Run.Queue,.98)

        # ---------------------------- Alive.Proc
	    PRC.Min[j] =min(x$Alive.Proc)
	    PRC.Max[j] =max(x$Alive.Proc)
	    PRC.Avg[j] =mean(x$Alive.Proc)
	    PRC.Std[j] =sd(x$Alive.Proc)

  # ---------------------------- Active.Proc
	    ACT.Min[j] =min(x$Active.Proc)
	    ACT.Max[j] =max(x$Active.Proc)
	    ACT.Avg[j] =mean(x$Active.Proc)
	    ACT.Std[j] =sd(x$Active.Proc)
	
        # ---------------------------- DiskPhys.BtRt
	    PIO.Min[j] =min(x$DiskPhys.BtRt)
	    PIO.Max[j] =max(x$DiskPhys.BtRt)
	    PIO.Avg[j] =mean(x$DiskPhys.BtRt)
	    PIO.Std[j] =sd(x$DiskPhys.BtRt)
	    PIO.98th[j] =quantile(x$DiskPhys.BtRt,.98)
  
	    # ---------------------------- DiskPhys.IORt
	    PIOPS.Min[j] =min(x$DiskPhys.IORt)
	    PIOPS.Max[j] =max(x$DiskPhys.IORt)
	    PIOPS.Avg[j] =mean(x$DiskPhys.IORt)
	    PIOPS.Std[j] =sd(x$DiskPhys.IORt)
	    PIOPS.98th[j] =quantile(x$DiskPhys.IORt,.98)
	
        # ---------------------------- InPkt.Rt
	    NTI.Min[j] =min(x$InPkt.Rt)
	    NTI.Max[j] =max(x$InPkt.Rt)
	    NTI.Avg[j] =mean(x$InPkt.Rt)
	    NTI.Std[j] =sd(x$InPkt.Rt)

        # ---------------------------- OutPkt.Rt
	    NTO.Min[j] =min(x$OutPkt.Rt)
	    NTO.Max[j] =max(x$OutPkt.Rt)
	    NTO.Avg[j] =mean(x$OutPkt.Rt)
	    NTO.Std[j] =sd(x$OutPkt.Rt)

        # ---------------------------- Interrpt
	    INT.Min[j] =min(x$Interrpt)
	    INT.Max[j] =max(x$Interrpt)
	    INT.Avg[j] =mean(x$Interrpt)
	    INT.Std[j] =sd(x$Interrpt)

        j <- j + 1

}

##  Create Reports
CPU_30d_Report <- data.frame(host,db, START, END, DAYS, OBS,  CPU.Min, CPU.Max, CPU.Avg, CPU.Std,
                                 CPU.90th, CPU.95th, CPU.98th)
COR_30d_Report <- data.frame(host, db, START, END, DAYS, OBS,  COR.Min, COR.Max, COR.Avg, COR.Std)
MEM_30d_Report <- data.frame(host, db, START, END, DAYS, OBS,  MEM.Min, MEM.Max, MEM.Avg, MEM.Std)
RUN_30d_Report <- data.frame(host, db, START, END, DAYS, OBS,  RQ.Min, RQ.Max, RQ.Avg, RQ.Std)
PRC_30d_Report <- data.frame(host, db, START, END, DAYS, OBS,  PRC.Min, PRC.Max, PRC.Avg, PRC.Std) 
ACT_30d_Report <- data.frame(host, db, START, END, DAYS, OBS,  ACT.Min, ACT.Max, ACT.Avg, ACT.Std) 
PIO_30d_Report <- data.frame(host, db, START, END, DAYS, OBS,  PIO.Min, PIO.Max, PIO.Avg, PIO.Std, PIO.98th) 
PIOPS_30d_Report <- data.frame(host, db, START, END, DAYS, OBS,  PIOPS.Min, PIOPS.Max, PIOPS.Avg, PIOPS.Std, PIOPS.98th) 
NTI_30d_Report <- data.frame(host, db, START, END, DAYS, OBS,  NTI.Min, NTI.Max, NTI.Avg, NTI.Std) 
NTO_30d_Report <- data.frame(host, db, START, END, DAYS, OBS,  NTO.Min, NTO.Max, NTO.Avg, NTO.Std) 
INT_30d_Report <- data.frame(host, db, START, END, DAYS, OBS,  INT.Min, INT.Max, INT.Avg, INT.Std) 

#
#  Export 30-day reports to csv files.
#

write.table(COR_30d_Report, "COR_30d_Report.csv", sep=",", row.names=FALSE)
write.table(INT_30d_Report, "INT_30d_Report.csv", sep=",", row.names=FALSE)
write.table(CPU_30d_Report, "CPU_30d_Report.csv", sep=",", row.names=FALSE)
write.table(MEM_30d_Report, "MEM_30d_Report.csv", sep=",", row.names=FALSE)
write.table(NTI_30d_Report, "NTI_30d_Report.csv", sep=",", row.names=FALSE)
write.table(NTO_30d_Report, "NTO_30d_Report.csv", sep=",", row.names=FALSE)
write.table(PIO_30d_Report, "PIO_30d_Report.csv", sep=",", row.names=FALSE)
write.table(PIOPS_30d_Report, "PIOPS_30d_Report.csv", sep=",", row.names=FALSE)
write.table(PRC_30d_Report, "PRC_30d_Report.csv", sep=",", row.names=FALSE)
write.table(ACT_30d_Report, "ACT_30d_Report.csv", sep=",", row.names=FALSE)
write.table(RUN_30d_Report, "RUN_30d_Report.csv", sep=",", row.names=FALSE)

save.image()


