
# use all data frames in current workspace to generate graphs.

srate <- 240

for (i in SYSTEMS) {
        x <- get(i)


	attach(as.data.frame(x), warn.conflicts=FALSE)
	startdate = min(Int.Date)
	enddate   = max(Int.Date)
	
	plotfile <- paste(as.character(i), ".pdf",sep="")
	ptitle<- paste("Host", as.character(i), 
		"(",startdate, "to", enddate, ")")
        print(ptitle)


	pdf(plotfile)
##	Date <- sample(Int.Date,srate)
  	Date <- Int.Date

	#  Page #1
	par(mfrow=c(4,2), mar=c(4,4,2,2), oma=c(1.5,2,1,1))
	plot(Date,CPU.User,main="CPU User %", type="l")
	hist(CPU.User,breaks=100,main="Histogram of CPU User %")
	
	plot(Date,CPU.Sys,main="CPU Sys %", type="l")
	hist(CPU.Sys,breaks=100,main="Histogram of CPU Sys %")
	
	plot(Date,CPU.Intrpt,main="CPU Interrupt %", type="l")
	hist(CPU.Intrpt,breaks=100,main="Histogram of CPU Interrupt %")
	
	plot(Date,CPU.Tot,main="CPU Total %", type="l")
	hist(CPU.Tot,breaks=100,main="Histogram of CPU Total %")
##	mtext(ptitle, 3, line=0.3, adj=0.5, cex=0.9, col="red", outer=TRUE)
	mtext(ptitle, 1, line=0.1, adj=0.5, cex=0.9, col="red", outer=TRUE)
	
	#  Page 2
	par(mfrow=c(4,2), mar=c(4,4,2,2), oma=c(1.5,2,1,1))
	plot(Date,CPU.Act,main="CPU Cores Active", type="l")
	hist(CPU.Act,breaks=100,main="Histogram of Active Cores")
	
	plot(Date,Interrpt,main="Interrupts", type="l")
	hist(Interrpt,breaks=100,main="Histogram of Interrupts")
	
	plot(Date,Run.Queue,main="Run Queue", type="l")
	hist(Run.Queue,breaks=100,main="Histogram of Run Queue")
	
	plot(Date,Alive.Proc,main="Alive Processes", type="l")
	hist(Alive.Proc,breaks=100,main="Histogram of Alive Processes")
##	mtext(ptitle, 3, line=0.3, adj=0.5, cex=0.9, col="red", outer=TRUE)
	mtext(ptitle, 1, line=0.1, adj=0.5, cex=0.9, col="red", outer=TRUE)

	#  Page 3
	par(mfrow=c(4,2), mar=c(4,4,2,2), oma=c(1.5,2,1,1))
	plot(Date,Phys.KBrt,main="Physical Disk KB/s", type="l")
	hist(Phys.KBrt,breaks=100,main="Histogram of Physical Disk KB/s")
	
	plot(Date,Mem.Pct,main="Memory %", type="l")
	hist(Mem.Pct,breaks=100,main="Histogram of Memory %")
	
	plot(Date,InPkt.Rt,main="Network Inbound Packets", type="l")
	hist(InPkt.Rt,breaks=100,main="Histogram of Inbound Packet Rate")

	plot(Date,OutPkt.Rt,main="Network Outbound Packets", type="l")
	hist(OutPkt.Rt,breaks=100,main="Histogram of Outbound Packet Rate")
##	mtext(ptitle, 3, line=0.3, adj=0.5, cex=0.9, col="red", outer=TRUE)
	mtext(ptitle, 1, line=0.1, adj=0.5, cex=0.9, col="red", outer=TRUE)
	dev.off()

}








