#
# <plot_all3.r> - Latest R script to create graphs and histograms of key system performance metrics.  The performance 
#                 are extracted from a Measureware global logfile.  This script will execute on datasets listing in 
#                 the character array SYSTEMS.  If preceeding this script with the load30.r script and you wish to 
#                 create plots for each host loaded, simply apply the following assignment in the R interpreter before
#                 executing this script:
#           
#                 > SYSTEMS <- host
#                 > source('path to plot_all3.r')

#                 Example execution:
#                   > host
#                     [1] "sea-hp03" "sea-hp04" "sea-hp11" "sea-hp12" "twoface" 
#                   > SYSTEMS <- host
#                   > source('C:/Users/jxreed/Desktop/MyProjects/bin/plot_all3.r')
#                     Loading required package: zoo
#
#                     Attaching package: 'zoo'
#
#                     The following object is masked from 'package:base':
#  
#                     as.Date, as.Date.numeric
#
#                     [1] "Processing: sea-hp03_2013-05-07.pdf ..."
#                     [1] "Processing: sea-hp04_2013-05-07.pdf ..."
#                     [1] "Processing: sea-hp11_2013-05-07.pdf ..."
#                     [1] "Processing: sea-hp12_2013-05-08.pdf ..."
#                     [1] "Processing: twoface_2013-05-11.pdf ..."
#
#
#   James D Reed (james.reed@hp.com)                
#   July 1, 2013
#

# use all data frames in current workspace to generate graphs.

require(graphics)
require(zoo)

bptitle<- paste("James D Reed, HP BCS Solution Architect/Mission Critical Ambassador (james.reed@hp.com)")

putLegend <- function(z){
  xts_stats <- getStats(z)

  leg.text <- c(paste("     Mean:", format(xts_stats$average, digits=2, nsmall=2)),
                paste("98th Pctl:", format(xts_stats$pctl98, digits=2, nsmall=2)),
                paste("      Min:", format(xts_stats$min, digits=2, nsmall=2)),
                paste("      Max:", format(xts_stats$max, digits=2, nsmall=2)),
                paste("      Std:", format(xts_stats$std, digits=2, nsmall=2)))
  legend("topright", leg.text, cex=.6)
  
}
getStats <- function(z) {
    average <- mean(z)
    zmax <- max(z)
    zmin <- min(z)
    std <- sd(z)
    pctl90 <- quantile(z,.90)
    pctl95 <- quantile(z,.95)
    pctl98 <- quantile(z,.98)
    result <- list(max=zmax, min=zmin, average=average, std=std, pctl90=pctl90, pctl95=pctl95, pctl98=pctl98)
    return (result)
}

printHeaderFooter <- function(i, pnum, startdate, enddate){
  ptitle<- paste("                                   Host", as.character(i), 
    "(",startdate, "to", enddate, ")                               Page", pnum)
  
  #page Header
  mtext(ptitle, 3, line=3, adj=0, cex=0.8, outer=TRUE)
  
  # Page Footer
  mtext(bptitle, 1, line=3, cex=0.5, outer=TRUE) 

}

for (i in SYSTEMS) {
   x <- get(i)
   x$dt <- as.POSIXct(x$Epoch.DT, origin = "1970-01-01")
	 
   attach(as.data.frame(x), warn.conflicts=FALSE)
	 startdate = min(Int.Date)
	 enddate   = max(Int.Date)
   
  ## Enter the name of the plot file in the pdf command below
  pdf_name <- paste(as.character(i),"_",as.character(startdate),".pdf", sep = "")
   
  pdf(pdf_name, paper="US", height=10, width=7)
  print(paste("Processing:", pdf_name, "..."))
  pnum <- 0

  #
  # Setup page format, plot layout
  #
  par(mfrow=c(2,1), oma=c(4,4,4,4)+0.1, mar=c(4,4,1,1))
  
   
  #################################################################################
  #                           C P U                                               #
  #################################################################################
  xts <- zoo(CPU.Tot, order.by = x$dt)
  plot(xts,main="CPU Utilization %",ylab="%", xlab="Date", ylim=c(0.0, 100.0), col = 1)
  lines(zoo(CPU.User, order.by = x$dt), col = 2)
  lines(zoo(CPU.Sys, order.by = x$dt), col = 3)
  lines(zoo(CPU.Intrpt, order.by = x$dt), col=4)
  lines(zoo(CPU.SysCall, order.by = x$dt), col=5)
  
  grid(nx=31, ny=10, col = "lightgray", lty = "dotted")
	hist(CPU.Tot,breaks=50,main="CPU Total Utilization %")
  putLegend(xts)
  
  pnum <- pnum +1
  printHeaderFooter(i, pnum, startdate, enddate)

  xts <- zoo(CPU.Tot, order.by=x$dt)
  plot(xts,main="CPU Total %",ylab="%", ylim=c(0,110), xlab="Date", col="red")
  grid(nx=31, ny=10, col = "lightgray", lty = "dotted")
	hist(CPU.Tot,breaks=50,main="CPU Total %", col="red")
  putLegend(xts)
   
  pnum <- pnum +1
  printHeaderFooter(i, pnum, startdate, enddate)  
   
  xts <- zoo(CPU.Act, order.by=x$dt)
  plot(xts,main="Cores Active",ylab="Count", xlab="Date")
  grid(nx=31, ny=10, col = "lightgray", lty = "dotted")
  hist(CPU.Act,breaks=50,main="Active Cores")
  putLegend(xts)
   
  pnum <- pnum +1
  printHeaderFooter(i, pnum, startdate, enddate)
   
  xts <- zoo(Interrpt, order.by=x$dt)
  plot(xts,main="Interrupts",ylab="Interrupts", xlab="Date")
  grid(nx=31, ny=10, col = "lightgray", lty = "dotted")
  hist(Interrpt,breaks=50,main="Interrupts")
  putLegend(xts)
   
  pnum <- pnum +1
  printHeaderFooter(i, pnum, startdate, enddate)
   
     
  xts <- zoo(Run.Queue, order.by=x$dt)
  plot(xts,main="Run Queue",ylab="Run.Queue", xlab="Date", col="red")
  grid(nx=31, ny=10, col = "lightgray", lty = "dotted")
  hist(Run.Queue,breaks=50,main="Run Queue", col="red")
  putLegend(xts)
   
  pnum <- pnum +1
  printHeaderFooter(i, pnum, startdate, enddate)
     
  xts <- zoo(Alive.Proc, order.by=x$dt)
  plot(xts,main="Alive Processes",ylab="Alive.Proc", xlab="Date")
  grid(nx=31, ny=10, col = "lightgray", lty = "dotted")
	hist(Alive.Proc,breaks=50,main="Alive Processes")
  putLegend(xts)
   
  pnum <- pnum +1
  printHeaderFooter(i, pnum, startdate, enddate)  
   
  xts <- zoo(SysCall.Num, order.by=x$dt)
  plot(xts,main="Syscall Number",ylab="Alive.Proc", xlab="Date")
  grid(nx=31, ny=10, col = "lightgray", lty = "dotted")
  hist(SysCall.Num,breaks=50,main="Syscall Number")
  putLegend(xts)
   
  pnum <- pnum +1
  printHeaderFooter(i, pnum, startdate, enddate)   
  
  xts <- zoo(SysCall.Rt, order.by=x$dt)
  plot(xts,main="Syscall Rate",ylab="Alive.Proc", xlab="Date")
  grid(nx=31, ny=10, col = "lightgray", lty = "dotted")
  hist(SysCall.Rt,breaks=50,main="Syscall Rate")
  putLegend(xts)
   
  pnum <- pnum +1
  printHeaderFooter(i, pnum, startdate, enddate)   
  
   #################################################################################
   #                           M E M O R Y                                         #
   #################################################################################
   xts <- zoo(Mem.Pct, order.by=x$dt)
   plot(xts,main="Memory Utilization Percent",ylab="Mem.Pct", ylim = c(0.00, 100.0), xlab="Date")
   grid(nx=31, ny=10, col = "lightgray", lty = "dotted")
   hist(Mem.Pct,breaks=50,main="Memory %")
   putLegend(xts)
   
   pnum <- pnum + 1
   printHeaderFooter(i, pnum, startdate, enddate)
   
   xts <- zoo(MemPO.Rt, order.by=x$dt)
   plot(xts,main="Memory Pageout Rate",ylab="MemPO.Rt", xlab="Date")
   grid(nx=31, ny=10, col = "lightgray", lty = "dotted")
   hist(MemPO.Rt,breaks=50,main="Memory Pageout Rate")
   putLegend(xts)
   
   pnum <- pnum + 1
   printHeaderFooter(i, pnum, startdate, enddate)
   
   xts <- zoo(MemSO.Rt, order.by=x$dt)
   plot(xts,main="Memory Swapout Rate",ylab="MemSO.Rt", xlab="Date")
   grid(nx=31, ny=10, col = "lightgray", lty = "dotted")
   hist(MemSO.Rt,breaks=50,main="Memory Swapout Rate")
   putLegend(xts)
   
   pnum <- pnum + 1
   printHeaderFooter(i, pnum, startdate, enddate)
   
   xts <- zoo(Mem.Queue, order.by=x$dt)
   plot(xts,main="Memory Queue",ylab="Mem.Queue", xlab="Date")
   grid(nx=31, ny=10, col = "lightgray", lty = "dotted")
   hist(Mem.Queue,breaks=50,main="Memory Queue")
   putLegend(xts)
   pnum <- pnum + 1
   printHeaderFooter(i, pnum, startdate, enddate) 
   
   #################################################################################
   #                           D I S K                                             #
   #################################################################################
   xts <- zoo(DiskPhys.IORt, order.by=x$dt)
   plot(xts,main="Physical Disk IO Rate",ylab="DiskPhys.IORt", xlab="Date")
   grid(nx=31, ny=10, col = "lightgray", lty = "dotted")
	 hist(DiskPhys.IORt,breaks=50,main="Physical Disk IO Rate")
   putLegend(xts)
  
   pnum <- pnum +1
   printHeaderFooter(i, pnum, startdate, enddate)
  
   xts <- zoo(DiskPhys.BtRt, order.by=x$dt)
   plot(xts,main="Physical Disk KB/s",ylab="DiskPhys.BtRt", xlab="Date")
   grid(nx=31, ny=10, col = "lightgray", lty = "dotted")
   hist(DiskPhys.BtRt,breaks=50,main="Physical Disk KB/s")
   putLegend(xts)
   
   pnum <- pnum +1
   printHeaderFooter(i, pnum, startdate, enddate)
   
   xts <- zoo(DiskReq.Queue, order.by=x$dt)
   plot(xts,main="Disk Request Queue",ylab="DiskReq.Queue", xlab="Date")
   grid(nx=31, ny=10, col = "lightgray", lty = "dotted")
   hist(DiskReq.Queue,breaks=50,main="Disk Request Queue")
   putLegend(xts)
   
   pnum <- pnum +1
   printHeaderFooter(i, pnum, startdate, enddate)  
   
   
   #################################################################################
   #                           N E T W O R K                                       #
   #################################################################################   
   xts <- zoo(InPkt.Rt, order.by=x$dt)
   plot(xts,main="Inbound/Outbound Packet Rate",ylab="InPkt.Rt", xlab="Date")
   lines(zoo(OutPkt.Rt, order.by=x$dt), col = 2)
   grid(nx=31, ny=10, col = "lightgray", lty = "dotted")
	 hist(InPkt.Rt,breaks=50,main="Inbound Packet Rate")
   putLegend(xts)
   
   pnum <- pnum + 1
   printHeaderFooter(i, pnum, startdate, enddate)
   
 
      
   dev.off()    

}
