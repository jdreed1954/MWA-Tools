#
# <load_all.r> -    R script to load all available days data from R datafiles created by extracting performance data 
#                 from Measureware global data logs.
#           
#                 Example execution:
#
#           > source('C:/Users/jxreed/Desktop/MyProjects/bin/load_all.r')
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
host <- c("N/A")
START <- c(as.Date("2000-01-01")); END <- c(as.Date("2000-01-01"))
DAYS <- c(0.0); OBS <- c(0.0)
CPU.Min <- c(0.00); CPU.Max <- c(0.00); CPU.Avg <- c(0.00); CPU.Std <- c(0.00)
CPU.90th <- c(0.00); CPU.95th <- c(0.00); CPU.98th <- c(0.00)

COR.Min <- c(0.00); COR.Max <- c(0.00); COR.Avg <- c(0.00); COR.Std <- c(0.0)

MEM.Min <- c(0.0); MEM.Max <- c(0.0); MEM.Avg <- c(0.0); MEM.Std <- c(0.0); 
MEM.98th <- c(0.0);

RQ.Min <- c(0.0); RQ.Max <- c(0.0); RQ.Avg <- c(0.0); RQ.Std <- c(0.0);
RQ.98th <- c(0.0);

PRC.Min <- c(0.0); PRC.Max <- c(0.0); PRC.Avg <- c(0.0); PRC.Std  <- c(0.0);
ACT.Min <- c(0.0); ACT.Max <- c(0.0); ACT.Avg <- c(0.0); ACT.Std  <- c(0.0);
PIO.Min <- c(0.0); PIO.Max <- c(0.0); PIO.Avg <- c(0.0); PIO.Std  <- c(0.0);
NTI.Min <- c(0.0); NTI.Max <- c(0.0); NTI.Avg <- c(0.0); NTI.Std <- c(0.0);
NTO.Min <- c(0.0); NTO.Max <- c(0.0); NTO.Avg <- c(0.0); NTO.Std <- c(0.0);
INT.Min <- c(0.0); INT.Max <- c(0.0); INT.Avg <- c(0.0); INT.Std <- c(0.0);

files <- list.files(path="./DATA",pattern="*.r")
j <- 1
for (i in files) {
	x <- read.csv(as.character(paste("./DATA/",i,sep="")))
	#
	# Fix dates ...	
	#
	x$Int.Date <- as.Date(x$Int.Date,"%m/%d/%Y")
	#
  # Select days contained in the dataset.
	#
  enddate <- max(x$Int.Date)
  startdate <- min(x$Int.Date)
  days <- enddate - startdate
	i <- substr(i,1,nchar(i)-2)
#
  assign(i,x)
	print(i)
        host[j] = i
	      START[j] <- as.Date(startdate)
	      END[j]   <- as.Date(enddate)
	      DAYS[j] <- days   
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
	     COR.Min[j]=min(x$CPU.Act)
	     COR.Max[j]=max(x$CPU.Act)
	     COR.Avg[j]=mean(x$CPU.Act)
	     COR.Std[j]=sd(x$CPU.Act)
	
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
        MEM.98th[j]=quantile(x$Run.Queue,.98)

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
CPU_All_Report <- data.frame(host, DAYS, OBS,  CPU.Min, CPU.Max, CPU.Avg, CPU.Std,
                                 CPU.90th, CPU.95th, CPU.98th)
COR_All_Report <- data.frame(host, START, END, DAYS, OBS,  COR.Min, COR.Max, COR.Avg, COR.Std)
MEM_All_Report <- data.frame(host, START, END, DAYS, OBS,  MEM.Min, MEM.Max, MEM.Avg, MEM.Std)
RUN_All_Report <- data.frame(host, START, END, DAYS, OBS,  RQ.Min, RQ.Max, RQ.Avg, RQ.Std)
PRC_All_Report <- data.frame(host, START, END, DAYS, OBS,  PRC.Min, PRC.Max, PRC.Avg, PRC.Std) 
ACT_All_Report <- data.frame(host, START, END, DAYS, OBS,  ACT.Min, ACT.Max, ACT.Avg, ACT.Std) 
PIO_All_Report <- data.frame(host, START, END, DAYS, OBS,  PIO.Min, PIO.Max, PIO.Avg, PIO.Std) 
NTI_All_Report <- data.frame(host, START, END, DAYS, OBS,  NTI.Min, NTI.Max, NTI.Avg, NTI.Std) 
NTO_All_Report <- data.frame(host, START, END, DAYS, OBS,  NTO.Min, NTO.Max, NTO.Avg, NTO.Std) 
INT_All_Report <- data.frame(host, START, END, DAYS, OBS,  INT.Min, INT.Max, INT.Avg, INT.Std) 

#
#  Export All-day reports to csv files.
#
write.table(COR_All_Report, "COR_All_Report.csv", sep=",", row.names=FALSE)
write.table(INT_All_Report, "INT_All_Report.csv", sep=",", row.names=FALSE)
write.table(CPU_All_Report, "CPU_All_Report.csv", sep=",", row.names=FALSE)
write.table(MEM_All_Report, "MEM_All_Report.csv", sep=",", row.names=FALSE)
write.table(NTI_All_Report, "NTI_All_Report.csv", sep=",", row.names=FALSE)
write.table(NTO_All_Report, "NTO_All_Report.csv", sep=",", row.names=FALSE)
write.table(PIO_All_Report, "PIO_All_Report.csv", sep=",", row.names=FALSE)
write.table(PRC_All_Report, "PRC_All_Report.csv", sep=",", row.names=FALSE)
write.table(ACT_All_Report, "ACT_All_Report.csv", sep=",", row.names=FALSE)
write.table(RUN_All_Report, "RUN_All_Report.csv", sep=",", row.names=FALSE)

save.image()

