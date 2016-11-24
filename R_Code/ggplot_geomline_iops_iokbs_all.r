#
# <ggplot_geomline_iops_kbs_all.r> -Latest R script to create detailed graphs of IO utilization.
#           
#
#                 > host
#                   [1] "hsgccu25" "hsgccu28" "hsgccu41" "hsgccu46" "hsgccu75" "hsgccu76" "hsgccu96"
#                 > SYSTEMS <- host
#                 > source('C:/Users/jxreed/Desktop/MyProjects/bin/ggplot_geomline_iops_kbs_all.r')
#                   > SYSTEMS
#                     [1] "sea-hp03" "sea-hp04" "sea-hp11" "sea-hp12" "twoface" 
#                   > source('C:/Users/jxreed/Desktop/MyProjects/bin/plotgg_cpu_mem_all.r')
#                     
#   James D Reed (james.reed@hpe.com)                
#   November 7, 2013
#
#
# use all data frames listed in the SYSTEMS variable
# For example: SYSTEMS <- c("sea-hp03","sea-hp04","sea-hp11","sea-hp12","twoface") 
#
#
require(ggplot2)
require(grid)
require(scales)
require(RColorBrewer)



# Enter number of days to graph (1-30)
DAYS <- 30
#Customer = ""

credit_title<- paste("James D Reed (james.reed@hpe.com) Hewlett Packard Enterprise/Enterprise Architect")

reportDateString <- date()

myvars <- c("Epoch.DT","DiskPhys.IORt","DiskPhys.BtRt")

#  F  U  N  C  T  I  O  N  S         --------------------------------------
newPage <- function() {
  
  grid.newpage()
  pushViewport(viewport(layout = grid.layout(1,1)))
  return
}

printPage <- function(plot,pnum) {
  
  print(plot, vp = vplayout(1,1))
  
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

#  M A I N  S T A R T S  H E R E           --------------------------------

# Create a palette for the colors we will use in out plots

mypalette   <- brewer.pal(3,"Dark2")
IOPS      <- mypalette[1]
KBPS      <- mypalette[2]


for (i in SYSTEMS) {
  pnum <<- 0
  alldata <- get(i)
  # Reduce dataframe to just the variables we care about.
  alldata <- alldata[myvars]
  endTime <- max(alldata$Epoch.DT)
  endIndex <- which(alldata$Epoch.DT == endTime)
  
  startTime <- endTime - DAYS*24*60*60
  if (startTime > min(alldata$Epoch.DT) && startTime > max(alldata$Epoch.DT)) {
    startIndex <- which(alldata$Epoch.DT == startTime)  
  } else {
    startIndex <- 1
  }
  
  if ( DAYS > 29) {
    DAYS <- 30
    data <- alldata
  } else {
    data <- alldata[startIndex:endIndex,]  
  }
  attach(as.data.frame(data), warn.conflicts=FALSE)
  startdate = min(Epoch.DT)
  enddate   = max(Epoch.DT)
  StartDate <- as.Date(as.POSIXlt(startdate, origin = "1970-1-1", format = "%Y-%m-%d"))
  EndDate <- as.Date(as.POSIXlt(enddate, origin = "1970-1-1", format = "%Y-%m-%d"))
  
  # Create the name of the plot file in the pdf command below
  pdf_name <- paste(as.character(i),"_",as.Date(as.POSIXlt(enddate, origin = "1970-1-1", format = "%Y-%m-%d")),"_IOPS_KBPS_",DAYS,"d.pdf", sep = "")
  
  pdf(pdf_name, paper="USr", width=10.5, height = 8.0 )
  print(paste("Processing:", pdf_name, "..."))
  
  #  I O P S         --------------------------------------------------------
  
  newPage()
  plot_title<- paste("Physical IOPS\nHost:", as.character(i), StartDate," to ", EndDate)
  if ( DAYS <= 2) {
    breakString <- "1 hour"; dFormat <- "%H"
  } else if ( DAYS > 2 && DAYS <= 10 ){ 
    breakString <- "1 day" ; dFormat <- "%b %d"
  } else {
    breakString <- "2 day" ;dFormat <- "%b %d"
  }
  
  IOPSPLOT <- ggplot(data, aes(as.POSIXlt(Epoch.DT, origin="1970-1-1"))) +  
    xlab("") + ylab("IOPS") + 
    geom_line(aes(y = DiskPhys.IORt,  colour = "IOPS")) +
    ggtitle(plot_title) + 
    theme(axis.text.x = element_text(angle=90, vjust=1)) +
    scale_x_datetime(labels = date_format(dFormat), breaks=date_breaks(breakString))

  pnum <- pnum + 1
  printPage(IOPSPLOT,pnum)
  
  # DiskPhys.BTRt -----------------------------------------------------------
  newPage()
  plot_title<- paste("IO KBytes/s\nHost:", as.character(i), StartDate," to ", EndDate)
  
  if ( DAYS <= 2) {
    breakString <- "1 hour"
    dFormat <- "%H"
    
  } else if ( DAYS > 2 && DAYS <= 10 ){ 
    breakString <- "1 day"
    dFormat <- "%b %d"
  
  } else {
    breakString <- "2 day"
    dFormat <- "%b %d"
 
  }
  
  KBPLOT <- ggplot(data, aes(as.POSIXlt(Epoch.DT, origin="1970-1-1"))) +
    geom_line(aes(y = DiskPhys.BtRt,   colour = "IO KByte/s")) +
    scale_x_datetime(labels = date_format(dFormat), breaks=date_breaks(breakString)) + 
    ggtitle(plot_title) + theme(axis.text.x = element_text(angle=90, vjust=1)) +
    xlab("") + ylab("IO KByte/s")
  
  
  pnum <- pnum + 1
  printPage(KBPLOT, pnum)
  
  
  dev.off()    
  
}



