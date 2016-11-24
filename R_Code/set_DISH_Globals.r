
#
# set_DISH_Globals.r
#
##
## This block should be edited to reflect the data being summarized.
## Between this line to the comment that begins with "#######"
CASE      <- "1601"
vMax <- 15;  # Maximum number of vPars in a Complex.

DATAROOT  <- "C:/Users/jxreed/Desktop/MyProjects/bin/global/";
DBFILE    <- paste(DATAROOT,"db2016-02-15.csv",sep="");
SYSFILE   <- paste(DATAROOT,CASE,"_SYS_SUMMARY.csv", sep="");

dbs <- read.csv(DBFILE, header=T, sep=",", fill=T,stringsAsFactors=F);
sys <- read.csv(SYSFILE, header=T, sep=",", fill=T,stringsAsFactors=F);

# Calculate Date Range
enddate <- as.Date("01/16/2016", "%m/%d/%Y");
startdate <- enddate - 30;

# These are the complexes we are interested in generating this summary data.
Complexes <- c("csc01", "csc02", "csc05","csc06", "csm1" );                       # 1601

baseDir <- paste("C:/Users/jxreed/Desktop/MyProjects/",CASE,sep="");

################################################################################
