#
#  <ggplot_boxplot_special_systems.r> -Latest R script to create detailed graphs for systems of interest.
#           
#
#                 > host
#                   [1] "hsgccu25" "hsgccu28" "hsgccu41" "hsgccu46" "hsgccu75" "hsgccu76" "hsgccu96"
#                 > SYSTEMS <- host
#                 > source('C:/Users/jxreed/Desktop/MyProjects/bin/ggplot_boxp_MEM.r')
#                   > SYSTEMS
#                     [1] "sea-hp03" "sea-hp04" "sea-hp11" "sea-hp12" "twoface" 
#                   > source('C:/Users/jxreed/Desktop/MyProjects/bin/plotgg_cpu_mem_all.r')
#                     [1] "Processing: sea-hp03_2013-06-06_CPU_MEM_30d.pdf ..."
#                     [1] "Processing: sea-hp04_2013-06-06_CPU_MEM_30d.pdf ..."
#                     [1] "Processing: sea-hp11_2013-06-06_CPU_MEM_30d.pdf ..."
#                     [1] "Processing: sea-hp12_2013-06-07_CPU_MEM_30d.pdf ..."
#                     [1] "Processing: twoface_2013-06-10_CPU_MEM_30d.pdf ..."
#
#   James D Reed (james.reed@hp.com)                
#   April 1,2016
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


################################################################################
#
#     F  U  N  C  T  I  O  N  S 
#
################################################################################
# returns string w/o leading or trailing whitespace
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

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
  grid.text(Customer, y = unit(1, "npc") - unit(2,"mm"), just=c("centre"), 
            gp=gpar(col="grey", fontsize=10))
  grid.text(reportDateString, x=unit(1,"npc"), y = unit(1, "npc") - unit(2,"mm"), 
            just=c("right"), gp=gpar(col="grey", fontsize=10))
  
  
  # Page Footer
  grid.text(credit_title, x=unit(.5,"npc"), y=unit(2,"mm"),gp=gpar(col="grey", 
            fontsize=8))
  grid.text(pageString, x=unit(1,"npc"), y=unit(2,"mm"), 
            just=c("right", "bottom"),gp=gpar(col="grey", fontsize=10))
  
  
}

vplayout <- function(x, y) {
  viewport(layout.pos.row = x, layout.pos.col = y)
}

set_axis_format <- function(DAYS) {

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
  return (c(breakString, dFormat))
  
}

init_plot_file <- function(host){
  # Lookup DATABASE Name given host name.
  #dbName <- trim(dbs[dbs$vpar == host,2])
  #dbName <- gsub(" | ", "_", dbName, fixed=TRUE)
  
  # Create the name of the plot file in the pdf command below
  pdf_name <- paste(as.character(host),"_",as.Date(as.POSIXlt(enddate, 
     origin = "1970-1-1", format = "%Y-%m-%d")),"_BOXP_",DAYS,"d.pdf", sep = "")
  
  pdf(pdf_name, paper="USr", width=10.5, height = 8.0 )
  print(paste("Processing:", pdf_name, "..."))
  
  return()
  
}
genplot_cor <- function(system) {
  myvars <- c("Epoch.DT","Int.Date", "CPU.Act")
  
    alldata <- get(system)
  # Reduce dataframe to just the variables we care about.
  alldata <- alldata[myvars]
  endTime <- max(alldata$Epoch.DT)
  endIndex <- which(alldata$Epoch.DT == endTime)
  
  startTime <- endTime - DAYS*24*60*60
  if (startTime > min(alldata$Epoch.DT) && startTime < max(alldata$Epoch.DT)) {
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
  
  
  ##############################################################################
  #                          C P U  A C T I V E                                #
  ##############################################################################
  newPage()
  plot_title<- paste("Number of Cores Active Boxplot by Day\nHost: ", 
                     as.character(i)," ", 
                     StartDate," to ", EndDate)
  
  fmt <- set_axis_format(DAYS)
  dFormat <- fmt[1]
  breakString <- fmt[2]
  
  
  data$dayofweek <- days[as.POSIXlt(Int.Date, origin="1970-1-1")$wday+1]
  data$dow.code <- as.character(as.POSIXlt(Int.Date, origin="1970-1-1")$wday)
  
  MEMPLOT <- ggplot(data, aes(factor(Int.Date), fill=data$dow.code, CPU.Act/2)) +
    geom_boxplot() +
    xlab("") + ylab("Number of Cores Active") + 
    ggtitle(plot_title) + 
    scale_fill_brewer("Day of the Week", type = "seq", palette = 8, 
                      labels   =c("Sunday", "Monday", "Tuesday", "Wednesday", 
                                  "Thursday", "Friday", "Saturday")) +
    theme(axis.text.x = element_text(angle=90, vjust=1))
  
  pnum <- pnum + 1
  printPage(MEMPLOT, pnum)
  
  return
}

genplot_cpu <- function(system){
  myvars <- c("Epoch.DT","Int.Date", "CPU.Tot")
  
  alldata <- get(system)
  # Reduce dataframe to just the variables we care about.
  alldata <- alldata[myvars]
  endTime <- max(alldata$Epoch.DT)
  endIndex <- which(alldata$Epoch.DT == endTime)
  
  startTime <- endTime - DAYS*24*60*60
  if (startTime > min(alldata$Epoch.DT) && startTime < max(alldata$Epoch.DT)) {
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
  
  
  ##############################################################################
  #                                  C P U                                     #
  ##############################################################################
  newPage()
  plot_title<- paste("CPU Utilization (%) Boxplot by Day\nHost: ", 
                     as.character(i)," ", 
                     StartDate," to ", EndDate)
  
  fmt <- set_axis_format(DAYS)
  dFormat <- fmt[1]
  breakString <- fmt[2]
  
  data$dayofweek <- days[as.POSIXlt(Int.Date, origin="1970-1-1")$wday+1]
  data$dow.code <- as.character(as.POSIXlt(Int.Date, origin="1970-1-1")$wday)
  
  CPUPLOT <- ggplot(data, aes(factor(Int.Date), fill=data$dow.code, CPU.Tot)) +
    geom_boxplot() +
    xlab("") + ylab("CPU Utilization (%)") +
    ggtitle(plot_title) + ylim(0.0,100.0) +
    scale_fill_brewer("Day of the Week", type = "seq", palette = 8, 
                      labels   =c("Sunday", "Monday", "Tuesday", "Wednesday", 
                                  "Thursday", "Friday", "Saturday")) +
    theme(axis.text.x = element_text(angle=90, vjust=1))
  
  pnum <- pnum + 1
  printPage(CPUPLOT,pnum)
  
  return()
}

genplot_mem <- function(system) {
  myvars <- c("Epoch.DT","Int.Date", "Mem.Pct")
  alldata <- get(system)
  # Reduce dataframe to just the variables we care about.
  alldata <- alldata[myvars]
  endTime <- max(alldata$Epoch.DT)
  endIndex <- which(alldata$Epoch.DT == endTime)
  
  startTime <- endTime - DAYS*24*60*60
  if (startTime > min(alldata$Epoch.DT) && startTime < max(alldata$Epoch.DT)) {
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
  
  
  ##############################################################################
  #                                M E M O R Y                                 #
  ##############################################################################
  newPage()
  plot_title<- paste("Memory Utilization (%) Active Boxplot by Day\nHost: ", 
                     as.character(i)," ", 
                     StartDate," to ", EndDate)
  
  fmt <- set_axis_format(DAYS)
  dFormat <- fmt[1]
  breakString <- fmt[2]
  
  data$dayofweek <- days[as.POSIXlt(Int.Date, origin="1970-1-1")$wday+1]
  data$dow.code <- as.character(as.POSIXlt(Int.Date, origin="1970-1-1")$wday)
  
  MEMPLOT <- ggplot(data, aes(factor(Int.Date), fill=data$dow.code, Mem.Pct)) +
    geom_boxplot() +
    xlab("") + ylab("Memory Utilization (%)") + ggtitle(plot_title) + 
    scale_fill_brewer("Day of the Week", type = "seq", palette = 8, 
        labels   =c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", 
                    "Friday", "Saturday")) +
    theme(axis.text.x = element_text(angle=90, vjust=1))
  
  
  pnum <- pnum + 1
  printPage(MEMPLOT, pnum)
  
  return
  
}

genplot_piops <- function(system) {
  myvars <- c("Epoch.DT","Int.Date", "DiskPhys.IORt")
  alldata <- get(system)
  # Reduce dataframe to just the variables we care about.
  alldata <- alldata[myvars]
  endTime <- max(alldata$Epoch.DT)
  endIndex <- which(alldata$Epoch.DT == endTime)
  
  startTime <- endTime - DAYS*24*60*60
  if (startTime > min(alldata$Epoch.DT) && startTime < max(alldata$Epoch.DT)) {
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
  
  
  ##############################################################################
  #                                 P I O P S                                  #
  ##############################################################################
  newPage()
  plot_title<- paste("Physical IOPS Boxplot by Day\nHost: ", 
                     as.character(i)," ", 
                     StartDate," to ", EndDate)
  
  fmt <- set_axis_format(DAYS)
  dFormat <- fmt[1]
  breakString <- fmt[2]
  
  
  data$dayofweek <- days[as.POSIXlt(Int.Date, origin="1970-1-1")$wday+1]
  data$dow.code <- as.character(as.POSIXlt(Int.Date, origin="1970-1-1")$wday)
  
  MEMPLOT <- ggplot(data, aes(factor(Int.Date), fill=data$dow.code, DiskPhys.IORt)) +
    geom_boxplot() +
    xlab("") + ylab("Physical IOPS") + 
    ggtitle(plot_title) + 
    scale_fill_brewer("Day of the Week", type = "seq", palette = 8, 
        labels   =c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", 
                    "Friday", "Saturday")) +
    theme(axis.text.x = element_text(angle=90, vjust=1))
  
  
  
  pnum <- pnum + 1
  printPage(MEMPLOT, pnum)
  
  return()
  
}

genplot_runq <- function(system) {
  myvars <- c("Epoch.DT","Int.Date", "Run.Queue")
  alldata <- get(system)
  # Reduce dataframe to just the variables we care about.
  alldata <- alldata[myvars]
  endTime <- max(alldata$Epoch.DT)
  endIndex <- which(alldata$Epoch.DT == endTime)
  
  startTime <- endTime - DAYS*24*60*60
  if (startTime > min(alldata$Epoch.DT) && startTime < max(alldata$Epoch.DT)) {
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
  
  ##############################################################################
  #                                 R U N  Q U E U E                           #
  ##############################################################################
  newPage()
  plot_title<- paste("Run Queue Boxplot by Day\nHost: ", 
                     as.character(i)," ", 
                     StartDate," to ", EndDate)
  
  fmt <- set_axis_format(DAYS)
  dFormat <- fmt[1]
  breakString <- fmt[2]
  
  
  data$dayofweek <- days[as.POSIXlt(Int.Date, origin="1970-1-1")$wday+1]
  data$dow.code <- as.character(as.POSIXlt(Int.Date, origin="1970-1-1")$wday)
  
  MEMPLOT <- ggplot(data, aes(factor(Int.Date), fill=data$dow.code, Run.Queue)) +
    geom_boxplot() +
    xlab("") + ylab("Run Queue") + 
    ggtitle(plot_title) + 
    scale_fill_brewer("Day of the Week", type = "seq", palette = 8, 
        labels   =c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", 
                    "Friday", "Saturday")) +
    theme(axis.text.x = element_text(angle=90, vjust=1))
  
  pnum <- pnum + 1
  printPage(MEMPLOT, pnum)
  
}
################################################################################
#
#     M A I N  S T A R T S  H E R E                                                                           #
################################################################################

# Create a palette for the colors we will use in out plots

mypal   <- brewer.pal(7,"Dark2")
days    <- c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", 
             "Friday", "Saturday")

# Generate List of SYSTEMS with DataBases
#SYSTEMS <- dbs[trim(dbs$dbname) != "",1]


for (i in SYSTEMS) {
  pnum <<- 0
  
  init_plot_file(i)
  
  #genplot_cor(i)
  genplot_cpu(i)
  genplot_mem(i) 
  genplot_piops(i)
  genplot_runq(i)
  dev.off()
  
}