
#
# gen_complex_report.r
#
##
## This file "C:/Users/jxreed/Desktop/MyProjects/bin/set_DISH_Globals.r
## should be edited to reflect the data being summarized.
## 


source("C:/Users/jxreed/Desktop/MyProjects/bin/set_DISH_Globals.r");


setwd(baseDir);  #  baseDir defined in set_DISH_Globals.r above.
print(baseDir);

for (cmplx in Complexes) {
   print (paste("Processing complex: ",cmplx,"..."));
   setwd(cmplx);
  
   # Declare arrays and preset to zero/blank for those vpars not recorded.
   vpar <- c(rep(" ",vMax));         db <- c(rep("  ",vMax)); 
   core.low <- c(rep(0,vMax));       core.high <- c(rep(0,vMax)); 
   core.avg <- c(rep(0,vMax));       cpu.max <- c(rep(0,vMax)); 
   cpu.avg <- c(rep(0,vMax));        cpu.98th <- c(rep(0,vMax));
   mem.max <- c(rep(0,vMax));        mem.avg <- c(rep(0,vMax)); 
   mem.used.gb <- c(rep(0,vMax));    ram.gb <- (rep(0,vMax));
   c.moves <- c(rep(0,vMax));        c.perd <- c(rep(0,vMax));
   
   # Create file name for appropriate "core moves" file.  Then, read in the CSV 
   # file into a data frame.
   coreFileName <- paste(CASE,"_",cmplx,"-FPL.csv", sep="")
   if (file.exists(paste(DATAROOT,coreFileName,sep=""))) {
      moves <- read.csv(paste(DATAROOT,coreFileName,sep=""), header=T, sep=",", 
                        fill=T,stringsAsFactors=F)
   } else {   
      moves <- read.csv(paste(DATAROOT,"EMPTY-FPL.csv",sep=""), header=T, 
                        sep=",", fill=T,stringsAsFactors=F)
      print (paste("*** Warning, using EMPTY Core Moves file for complex: ",
                   cmplx,"..."))
   }
   
   #Fix Date Class
   moves$Date <- as.Date(moves$Date,"%m/%d/%Y")
   
   # Select Subset of Core Moves File corresponding to start and end dates.
   cm <- moves[moves$Date <= enddate & moves$Date >= startdate,]
   
   # Load data for this complex
   source("C:/Users/jxreed/Desktop/MyProjects/bin/import_dish_30d.r")

  # Note, numPars comes from import_dish_30d.r

   for (i in 1:numPars) {
     attach(dbs, warn.conflicts=F)
     vpar[i]  <- paste(cmplx,"v",as.character(i), sep="")
     db[i] <- dbs[dbs$vpar==vpar[i],2]

     #
     #  Core
     attach(COR_30d_Report, warn.conflicts=F)
     if ( nrow(vec <- COR_30d_Report[host==vpar[i],]) ) {
       core.low[i] <- vec[1,]$COR.Min
       core.high[i] <-vec[1,]$COR.Max
       core.avg[i] <- round(vec[1,]$COR.Avg,2)
     }
     
     
     #
     #  Core Moves
     attach(cm, warn.conflicts=F)
     c.moves[i] <- sum(cm[[i+1]])
     c.perd[i]  <- round(c.moves[i]/30,2)
     
     
     #
     #  CPU
     attach(CPU_30d_Report, warn.conflicts=F)
     if ( nrow(vec <- CPU_30d_Report[host==vpar[i],]) ) {
       cpu.max[i] <- vec[1,]$CPU.Max
       cpu.avg[i] <-round(vec[1,]$CPU.Avg,2)
       cpu.98th[i] <- round(vec[1,]$CPU.98th,2)
     }
     
     
     #
     #  RAM
     attach(sys, warn.conflicts=F)
     if ( nrow(vec <- sys[gsub("[[:space:]]*$","",Hostname)==vpar[i],]) ) {
       ram.gb[i] <- round(vec[1,]$MemMB/1024,0)
     }
     attach(MEM_30d_Report, warn.conflicts=F)
     if ( nrow(vec <- MEM_30d_Report[host==vpar[i],]) ) {
       mem.max[i] <- round(vec[1,]$MEM.Max,2)
       mem.avg[i] <-round(vec[1,]$MEM.Avg,2)
       mem.used.gb[i] <- round(mem.max[i]/100*ram.gb[i],0)
     }
     
   }

   #
   # Generate the data frames containing the pertinent data for each Complex.
   #
   tmp <- data.frame(vpar,db, core.low, core.high, core.avg,c.moves,c.perd, 
                         cpu.max, cpu.avg, cpu.98th,ram.gb, mem.max, mem.avg,mem.used.gb)
   lhs <- paste("complex_",cmplx,"_ALL", sep="")
   rhs <- paste("tmp",sep="")
   eq <- paste(paste(lhs,rhs,sep="<-"), collapse=";")
   eval(parse(text=eq))
   write.csv(tmp, file=paste0("../",CASE,"_",cmplx,"_Complex_Report.csv"))
   rm(tmp)   
   
   # Now, lets create the NARROW reports that can be included in the LaTeX 
   # Report in Portrait More.
   
   #
   # First the CORE Report
   #
   tmp <- data.frame(vpar,db,core.low,core.high, core.avg, c.moves, c.perd)
   lhs <- paste("complex_",cmplx,"_CORE", sep="")
   rhs <- paste("tmp",sep="")
   eq <- paste(paste(lhs,rhs,sep="<-"), collapse=";")
   eval(parse(text=eq))
   rm(tmp)
   
   #
   # Second, the CPU Report.
   #
   tmp <- data.frame(vpar,db,cpu.max, cpu.avg, cpu.98th)
   lhs <- paste("complex_",cmplx,"_CPU", sep="")
   rhs <- paste("tmp",sep="")
   eq <- paste(paste(lhs,rhs,sep="<-"), collapse=";")
   eval(parse(text=eq))
   rm(tmp)
   
   #
   # Third, the MEM Report.
   #
   tmp <- data.frame(vpar,db,ram.gb, mem.max, mem.avg,mem.used.gb)
   lhs <- paste("complex_",cmplx,"_MEM", sep="")
   rhs <- paste("tmp",sep="")
   eq <- paste(paste(lhs,rhs,sep="<-"), collapse=";")
   eval(parse(text=eq))
   rm(tmp)
   
   setwd("../.")
   
}

