#
# complex_report.r
#
dbs <- read.table("../../bin/databases.txt", header=T, sep=",", fill=T,stringsAsFactors=F)
sys <- read.csv("../../bin/SYS_SUMMARY.csv", header=T, sep=",", fill=T,stringsAsFactors=F)
cs01_cores <- read.csv("../../bin/2013-12-17_cs01-FPL.csv", header=T, sep=",", fill=T,stringsAsFactors=F)

#Fix Dtate Class
cs01_cores$Date <- as.Date(cs01_cores$Date,"%m/%d/%Y")

# Calculate Date Range
enddate <- as.Date("12/16/2013", "%m/%d/%Y")
startdate <- enddate - 30



# Select Subset of Core Moves File corresponding to start and end dates.

cm <- cs01_cores[cs01_cores$Date <= enddate & cs01_cores$Date >= startdate,]

Complex <- "cs01"
vpars <- c(rep(" ",11)); vpar.db <- c(rep("  ",11)); core.low <- c(rep(0,11)); core.high <- c(rep(0,11)); core.avg <- c(rep(0,11));
cpu.max <- c(rep(0,11)); cpu.avg <- c(rep(0,11)); cpu.98th <- c(rep(0,11));
mem.max <- c(rep(0,11)); mem.avg <- c(rep(0,11)); max.mem <- c(rep(0,11)); ram.gb <- (rep(0,11));
core.moves <- c(rep(0,11)); core.perd <- c(rep(0,11));


for (i in 1:11) {
  detach();attach(dbs, warn.conflicts=F)
  vpars[i]  <- paste(Complex,"v",as.character(i), sep="")
  vpar.db[i] <- dbs[vpar==as.character(vpars[i]),2]
  #
  #  Core
  detach();attach(COR_30d_Report, warn.conflicts=F)
  if ( nrow(vec <- COR_30d_Report[host==vpars[i],]) ) {
    core.low[i] <- vec[1,]$COR.Min
    core.high[i] <-vec[1,]$COR.Max
    core.avg[i] <- vec[1,]$COR.Avg
  }
 
  #
  #  Core Moves
  detach();attach(cm, warn.conflicts=F)
  core.moves[i] <- sum(cm[[i+1]])
  core.perd[i]  <- core.moves[i]/30

  #
  #  CPU
  detach();attach(CPU_30d_Report, warn.conflicts=F)
  if ( nrow(vec <- CPU_30d_Report[host==vpars[i],]) ) {
    cpu.max[i] <- vec[1,]$CPU.Max
    cpu.avg[i] <-vec[1,]$CPU.Avg
    cpu.98th[i] <- vec[1,]$CPU.98th
  }
  
  
  #
  #  RAM
  detach();attach(sys, warn.conflicts=F)
  if ( nrow(vec <- sys[Hostname==vpars[i],]) ) {
    ram.gb[i] <- vec[1,]$MemMB/1024
  }
  detach();attach(MEM_30d_Report, warn.conflicts=F)
  if ( nrow(vec <- MEM_30d_Report[host==vpars[i],]) ) {
    mem.max[i] <- vec[1,]$MEM.Max
    mem.avg[i] <-vec[1,]$MEM.Avg
    max.mem[i] <- mem.max[i]/100*ram.gb[i]
  }
  
}



complex <- dataframe(vpars,vpar.db, core.low, core.high, core.avg,core.moves,cores.perd, cpu.max, cpu.avg, cpu.98th,ram.gb, 
                     mem.max, mem.avg,max.mem)