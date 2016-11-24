#
# <ggplot_all.r> -Latest R script to create graphs and histograms of key system performance metrics.  The performance 
#                 are extracted from a Measureware global logfile.  This script will execute on datasets listing in 
#                 the character array SYSTEMS.  If preceeding this script with the load30.r script and you wish to 
#                 create plots for each host loaded, simply apply the following assignment in the R interpreter before
#                 executing this script:
#           
#
#                 > host
#                   [1] "hsgccu25" "hsgccu28" "hsgccu41" "hsgccu46" "hsgccu75" "hsgccu76" "hsgccu96"
#                 > SYSTEMS <- host
#                 > source('C:/Users/jxreed/Desktop/MyProjects/bin/ggplot_all.r')
#                   [1] "Processing: sea-hp03_2013-06-06_ALL_MET_30d.pdf ..."
#                   [1] 0
#                      ...
#                   There were 36 warnings (use warnings() to see them)
#
#
#   James D Reed (james.reed@hp.com)                
#   July 30, 2013
#
#
# use all data frames listed in the SYSTEMS variable
# For example: SYSTEMS <- c("sea-hp03","sea-hp04","sea-hp11","sea-hp12","twoface") 
#
#
require(ggplot2)
require(grid)
require(scales)

# Enter number of days to graph (1-30)
DAYS <- 30
#Customer = ""

credit_title<- paste("James D Reed (james.reed@hp.com) Hewlett-Packard Company Solution Architect")

reportDateString <- date()



################################################################################################################
#     F  U  N  C  T  I  O  N  S                                                                                #
################################################################################################################
genplot.p <- function(df,metric,plot_title ){
 
  if ( DAYS <= 2) {
    breakString <- "1 hour"
    dFormat <- "%H"
    xlabString <- "Hour"
  } else if ( DAYS > 2 && DAYS <= 10 ){ 
    breakString <- "1 day"
    dFormat <- "%b %d"
    xlabString <- "Date"
  } else {
    breakString <- "2 day"
    dFormat <- "%b %d"
    xlabString <- "Date"
  }
  
  lp <- ggplot(df, aes(as.POSIXlt(Epoch.DT, origin="1970-1-1"), metric), environment=environment()) +  
    geom_line() + scale_x_datetime(labels = date_format(dFormat), breaks=date_breaks(breakString)) + 
    ggtitle(plot_title) + theme(axis.text.x = element_text(angle=90, vjust=1)) +
    xlab(xlabString) + ylab(deparse(substitute(metric)))
  
   return(lp)
  
}

genplot.h <- function(df,metric,plot_title, binrange){
  
  if ( binrange <= 0 ) {
    lh <- 0
  } else {
    binw <- binrange / 100
    lh <- ggplot(df, aes(metric), environment=environment()) + geom_histogram(binwidth=binw) + ggtitle(plot_title) +
           xlab(deparse(substitute(metric)))
  }
  return(lh)
  
}

newPage <- function() {
  
  grid.newpage()
  pushViewport(viewport(layout = grid.layout(2,1)))
  return
}

printPage <- function(pnum) {
  
  print(top, vp = vplayout(1,1))
  print(bot, vp = vplayout(2,1))
  
  
  printHeaderFooter(pnum)
  return  
}

printHeaderFooter <- function(pnum){
  pageString <- paste("  Page ", pnum)
  
  #page Header
  popViewport()
  grid.text(Customer, y = unit(1, "npc") - unit(2,"mm"), just=c("centre"), gp=gpar(col="grey", fontsize=10))
  grid.text(reportDateString, x=unit(1,"npc"), y = unit(1, "npc") - unit(2,"mm"), just=c("right"), gp=gpar(col="grey", fontsize=10))
  
  
  # Page Footer
  grid.text(credit_title, x=unit(.5,"npc"), y=unit(2,"mm"),gp=gpar(col="grey", fontsize=8))
  grid.text(pageString, x=unit(1,"npc"), y=unit(2,"mm"), just=c("right", "bottom"),gp=gpar(col="grey", fontsize=10))
  
  
}

vplayout <- function(x, y) {
  viewport(layout.pos.row = x, layout.pos.col = y)
}

################################################################################################################
#     M A I N  S T A R T S  H E R E                                                                            #
################################################################################################################
for (i in SYSTEMS) {
  pnum <<- 0
  alldata <- get(i)
  alldata$dt <- as.POSIXlt(alldata$Epoch.DT, origin = "1970-01-01")
  endDate <- alldata$Int.Date[nrow(alldata)]

  endIndex <- nrow(alldata)
  
  startDate <- as.Date(endDate) - DAYS
  
  
  if ( DAYS > 29) {
    DAYS <- 30
    data <- alldata
  } else {
    data <- alldata[1:endIndex,]  
  }
  attach(as.data.frame(data), warn.conflicts=FALSE)
  startdate = min(Int.Date)
  enddate   = max(Int.Date)

  
  # Create the name of the plot file in the pdf command below
  pdf_name <- paste(as.character(i),"_",as.character(enddate),"_ALL_MET_",DAYS,"d.pdf", sep = "")
  
  pdf(pdf_name, paper="US", height=10.5, width=7.5)
  print(paste("Processing:", pdf_name, "..."))
  
  
  #################################################################################
  #                           C P U                                               #
  #################################################################################
  newPage()
  
  plot_title<- paste("Total CPU Utilization\nHost:", as.character(i), startdate, "to", enddate)
  top <- genplot.p(data,CPU.Tot, plot_title) + ylim(0,100) + geom_hline(yintercept = 80, colour = "red")
  bot <- genplot.h(data, CPU.Tot, plot_title,diff(range(CPU.Tot))) + geom_vline(xintercept = 80, colour = "red")
  
  pnum <- pnum + 1
  printPage(pnum)
 
  newPage()
  
  plot_title<- paste("User CPU Utilization\nHost:", as.character(i), startdate, "to", enddate)
  top <- genplot.p(data,CPU.User, plot_title) + ylim(0,100) + geom_hline(yintercept = 80, colour = "red")
  bot <- genplot.h(data, CPU.User, plot_title,diff(range(CPU.User))) + geom_vline(xintercept = 80, colour = "red")
  
  pnum <- pnum + 1
  printPage(pnum)
  
  newPage()
  
  plot_title<- paste("System CPU Utilization\nHost:", as.character(i), startdate, "to", enddate)
  top <- genplot.p(data,CPU.Sys, plot_title) + ylim(0,100)
  bot <- genplot.h(data, CPU.Sys, plot_title, diff(range(CPU.Sys))) 
  
  pnum <- pnum + 1
  printPage(pnum)

  newPage()
  
  plot_title<- paste("Interrupt CPU Utilization\nHost:", as.character(i), startdate, "to", enddate)
  top <- genplot.p(data,CPU.Intrpt, plot_title) + ylim(0,100)
  bot <- genplot.h(data,CPU.Intrpt, plot_title, diff(range(CPU.Intrpt)))
  
  pnum <- pnum + 1
  printPage(pnum)
 
  newPage()
  
  plot_title<- paste("System Call CPU Utilization\nHost:", as.character(i), startdate, "to", enddate)
  top <- genplot.p(data,CPU.SysCall, plot_title) + ylim(0,100)
  bot <- genplot.h(data,CPU.SysCall, plot_title, diff(range(CPU.SysCall))) 
  
  pnum <- pnum + 1
  printPage(pnum)
  
  newPage()
  
  plot_title<- paste("Active CPUs (cores)\nHost:", as.character(i), startdate, "to", enddate)
  top <- genplot.p(data,CPU.Act, plot_title)
  bot <- 0 
  
  pnum <- pnum + 1
  printPage(pnum)
 
  newPage()
  
  plot_title<- paste("Interrupts\nHost:", as.character(i), startdate, "to", enddate)
  top <- genplot.p(data,Interrpt, plot_title)
  bot <- genplot.h(data,Interrpt, plot_title, diff(range(Interrpt))) 
  
  pnum <- pnum + 1
  printPage(pnum)
    
  
  newPage()
  
  plot_title<- paste("Run Queue\nHost:", as.character(i), startdate, "to", enddate)
  top <- genplot.p(data,Run.Queue, plot_title) + geom_hline(yintercept=3, colour = "red")
  bot <- genplot.h(data,Run.Queue, plot_title, diff(range(Run.Queue))) + geom_vline(xintercept=3, colour = "red")
  
  pnum <- pnum + 1
  printPage(pnum)
  
  
  newPage()
  
  plot_title<- paste("Alive Processes\nHost:", as.character(i), startdate, "to", enddate)
  top <- genplot.p(data,Alive.Proc, plot_title)
  bot <- genplot.h(data,Alive.Proc, plot_title, diff(range(Alive.Proc))) 
  
  pnum <- pnum + 1
  printPage(pnum)
  
  newPage()
  
  plot_title<- paste("System Calls\nHost:", as.character(i), startdate, "to", enddate)
  top <- genplot.p(data,SysCall.Num, plot_title)
  bot <- genplot.h(data,SysCall.Num, plot_title, diff(range(SysCall.Num))) 
  
  pnum <- pnum + 1
  printPage(pnum)
  
  newPage()
  
  plot_title<- paste("System Call Rate\nHost:", as.character(i), startdate, "to", enddate)
  top <- genplot.p(data,SysCall.Rt, plot_title)
  bot <- genplot.h(data,SysCall.Rt, plot_title, diff(range(SysCall.Rt))) 
  
  pnum <- pnum + 1
  printPage(pnum)


  #################################################################################
  #                           M E M O R Y                                         #
  #################################################################################
  newPage()
  
  plot_title<- paste("Memory Utilization\nHost:", as.character(i), startdate, "to", enddate)
  top <- genplot.p(data,Mem.Pct, plot_title)
  bot <- genplot.h(data,Mem.Pct, plot_title, diff(range(Mem.Pct))) 
  
  pnum <- pnum + 1
  printPage(pnum)
  
  
  newPage()
  
  plot_title<- paste("Memory Pageout Rate\nHost:", as.character(i), startdate, "to", enddate)
  top <- genplot.p(data,MemPO.Rt, plot_title)
  bot <- genplot.h(data,MemPO.Rt, plot_title, diff(range(MemPO.Rt))) 

  pnum <- pnum + 1
  printPage(pnum)

  newPage()
  
  plot_title<- paste("Memory Swapout Rate\nHost:", as.character(i), startdate, "to", enddate)
  top <- genplot.p(data, MemSO.Rt, plot_title)
  
  plot_title<- paste("Memory Queue\nHost:", as.character(i), startdate, "to", enddate)
  bot <- genplot.p(data,Mem.Queue, plot_title)  
  
  pnum <- pnum + 1
  printPage(pnum)

  
  #################################################################################
  #                           D I S K                                             #
  #################################################################################
  newPage()
  
  plot_title<- paste("Disk Physical I/O Rate\nHost:", as.character(i), startdate, "to", enddate)
  top <- genplot.p(data,DiskPhys.IORt, plot_title)
  bot <- genplot.h(data,DiskPhys.IORt, plot_title, diff(range(DiskPhys.IORt))) 
  
  pnum <- pnum + 1
  printPage(pnum)

  
  newPage()
  
  plot_title<- paste("Disk Physical I/O KB/s\nHost:", as.character(i), startdate, "to", enddate)
  top <- genplot.p(data,DiskPhys.BtRt, plot_title)
  bot <- genplot.h(data,DiskPhys.BtRt, plot_title, diff(range(DiskPhys.BtRt))) 
  
  pnum <- pnum + 1
  printPage(pnum)
  
  newPage()
  
  plot_title<- paste("Disk Request Queue\nHost:", as.character(i), startdate, "to", enddate)
  top <- genplot.p(data,DiskReq.Queue, plot_title)
  bot <- genplot.h(data,DiskReq.Queue, plot_title, diff(range(DiskReq.Queue))) 
  
  pnum <- pnum + 1
  printPage(pnum)
  
  
  #################################################################################
  #                           N E T W O R K                                       #
  #################################################################################   
  newPage()
  
  plot_title<- paste("Network Inbound Packet Rate\nHost:", as.character(i), startdate, "to", enddate)
  top <- genplot.p(data,InPkt.Rt, plot_title)
  bot <- genplot.h(data,InPkt.Rt, plot_title, diff(range(InPkt.Rt))) 
  
  pnum <- pnum + 1
  printPage(pnum)
  
  newPage()
  
  plot_title<- paste("Network Outbound Packet Rate\nHost:", as.character(i), startdate, "to", enddate)
  top <- genplot.p(data,OutPkt.Rt, plot_title)
  bot <- genplot.h(data,OutPkt.Rt, plot_title, diff(range(OutPkt.Rt))) 
  
  pnum <- pnum + 1
  printPage(pnum)
  
  
  dev.off()    
  
}
