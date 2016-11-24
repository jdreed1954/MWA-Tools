# use all data frames in current workspace to generate graphs.


## Enter the name of the plot file in the pdf command below
pdf("project_plots.pdf")
require(graphics)

bptitle<- paste("James D Reed, HP BCS Solution Architect/Unix Ambassador (james.reed@hp.com)")

pnum <- 0

for (i in SYSTEMS) {
   x <- get(i)

	attach(as.data.frame(x), warn.conflicts=FALSE)
	startdate = min(Int.Date)
	enddate   = max(Int.Date)

  Date <- Int.Date

	#  Page #1
  
  #
  # Setup page format, plot layout
  #
	par(mfrow=c(4,2), mar=c(4,4,2,2), oma=c(1.5,2,1,1))
  
  
   
  yts <- ts(CPU.User,frequency=288)
  plot(yts,main="CPU User %",ylab="%", xlab="Time (days)")
	hist(CPU.User,breaks=50,main="Histogram of CPU User %")
	
  xts <- ts(CPU.Sys,frequency=288)
  plot(xts,main="CPU Sys %",ylab="%", xlab="Time (days)")
	hist(CPU.Sys,breaks=50,main="Histogram of CPU Sys %")
	
  xts <- ts(CPU.Intrpt, frequency=288)
  plot(xts,main="CPU Interrupt %",ylab="%", xlab="Time (days)")
	hist(CPU.Intrpt,breaks=50,main="Histogram of CPU Interrupt %")
	
  xts <- ts(CPU.Tot, frequency=288)
  plot(xts,main="CPU Total %",ylab="%", xlab="Time (days)", col="red")
	hist(CPU.Tot,breaks=50,main="Histogram of CPU Total %", col="red")
  
  #
  # Page Header
  #
  pnum <- pnum + 1
  ptitle<- paste("Host", as.character(i), 
                "(",startdate, "to", enddate, ")                                  Page", pnum)
  print(ptitle)
  mtext(ptitle, 3, line=0.01, adj=1.0, cex=0.8, outer=TRUE)
  #
  # Page Footer
  #
  mtext(bptitle, 1, line=0.01, cex=0.5, outer=TRUE)
  
   
  #
  #  Page 2
  #
	par(mfrow=c(4,2), mar=c(4,4,2,2), oma=c(1.5,2,1,1))
  xts <- ts(CPU.Act, frequency=288)
  plot(xts,main="Cores Active",ylab="Count", xlab="Time (days)")
  hist(CPU.Act,breaks=50,main="Histogram of Active Cores")
	
  xts <- ts(Interrpt, frequency=288)
  plot(xts,main="Interrupts",ylab="Interrupts", xlab="Time (days)")
	hist(Interrpt,breaks=50,main="Histogram of Interrupts")
	
  xts <- ts(Run.Queue, frequency=288)
  plot(xts,main="Run Queue",ylab="Run.Queue", xlab="Time (days)", col="red")
	hist(Run.Queue,breaks=50,main="Histogram of Run Queue", col="red")
	
  xts <- ts(Alive.Proc, frequency=288)
  plot(xts,main="Alive Processes",ylab="Alive.Proc", xlab="Time (days)")
	hist(Alive.Proc,breaks=50,main="Histogram of Alive Processes")
  #
  # Page Header
  #
  pnum <- pnum + 1
  ptitle<- paste("Host", as.character(i), 
                "(",startdate, "to", enddate, ")                                  Page", pnum)
  print(ptitle)
  mtext(ptitle, 3, line=0.01, adj=1.0, cex=0.8, outer=TRUE)
  #
  # Page Footer
  #
  mtext(bptitle, 1, line=0.01, cex=0.5, outer=TRUE)
  
   
  #
	#  Page 3
  #
	par(mfrow=c(4,2), mar=c(4,4,2,2), oma=c(1.5,2,1,1))
  xts <- ts(Phys.KBrt, frequency=288)
  plot(xts,main="Physical Disk KB/s",ylab="Phys.KBrt", xlab="Time (days)")
	hist(Phys.KBrt,breaks=50,main="Histogram of Physical Disk KB/s")
	
  xts <- ts(Phys.KBrt, frequency=288)
  plot(xts,main="Memory Percent",ylab="Mem.Pct", xlab="Time (days)")
	hist(Mem.Pct,breaks=50,main="Histogram of Memory %")
	
  xts <- ts(InPkt.Rt, frequency=288)
  plot(xts,main="Inbound Packet Rate",ylab="InPkt.Rt", xlab="Time (days)")
	hist(InPkt.Rt,breaks=50,main="Histogram of Inbound Packet Rate")

  xts <- ts(OutPkt.Rt, frequency=288)
  plot(xts,main="Outbound Packet Rate",ylab="OutPkt.Rt", xlab="Time (days)")
  hist(OutPkt.Rt,breaks=50,main="Histogram of Outbound Packet Rate")
  #
  # Page Header
  #
  pnum <- pnum + 1
  ptitle<- paste("Host", as.character(i), 
                "(",startdate, "to", enddate, ")                                  Page", pnum)
  print(ptitle)
  mtext(ptitle, 3, line=0.01, adj=1.0, cex=0.8, outer=TRUE)
  #
  # Page Footer
  #
  mtext(bptitle, 1, line=0.01, cex=0.5, outer=TRUE)


}

dev.off()