#
# <plot_top10.r> -  R script to produce pdf plot file of the top ten in each of ten metrics.
#           
#                 Example execution:
#
#           > source('C:/Users/jxreed/Desktop/MyProjects/bin/load30.r')
#           [1] "sea-hp03"
#           [1] "sea-hp04"
#           [1] "sea-hp11"
#           [1] "sea-hp12"
#           [1] "twoface"
#           There were 20 warnings (use warnings() to see them)
#                 
#   James D Reed (james.reed@hp.com)                
#   September 29, 2013
#
## # use all data frames in current workspace to generate graphs.


## Enter the name of the plot file in the pdf command below
pdf("top10_plots.pdf")
require(ggplot2)
require(grid)
require(scales)
require(RColorBrewer)

require(graphics)

Customer <- ""
credit_title<- paste("James D Reed (james.reed@hp.com) Hewlett-Packard Company Solution Architect")
################################################################################################################
#     F  U  N  C  T  I  O  N  S                                                                                #
################################################################################################################
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

################################################################################################################
#     M A I N  S T A R T S  H E R E                                                                            #
################################################################################################################

# Create a palette for the colors we will use in out plots

mypal   <- brewer.pal(10,"Dark2")

#=================================================================================================================   
#
#  Page 1
#
#=================================================================================================================   
pnum <- 0
	
#
# Setup page format, plot layout
#
par(mfrow=c(2,1), mar=c(4,4,2,2), oma=c(1.5,2,1,1))


# ------------------------------------------------------------------------------------------ CPU30/CPU.98th Barplot
vals <- 1:10
top10 <- head(CPU_30d_Report[order(-CPU_30d_Report$CPU.98th),],10)
vals <- as.numeric(format(top10$CPU.98th,digits=4, nsmall=2))
mp <- barplot(top10$CPU.98th, names.arg=top10$host, cex.names=0.5, ylim = c(0,110), col=rainbow(10), 
              ylab="CPU.98th Percent")
text(mp,vals, labels= vals, pos = 3, cex=0.8)
title(main = "Top 10 Systems by Statistic: CPU_30d_Report$CPU.98th")
rm(top10, vals, mp)


# ------------------------------------------------------------------------------------------ MEM30/MEM.Avg Barplot
vals <- 1:10
top10 <- head(MEM_30d_Report[order(-MEM_30d_Report$MEM.Avg),],10)
vals <- as.numeric(format(top10$MEM.Avg,digits=4, nsmall=2))
mp <- barplot(top10$MEM.Avg, names.arg=top10$host, cex.names=0.5, ylim = c(0,110), col=rainbow(10), 
              ylab="MEM.Avg Percent")
text(mp,vals, labels= vals, pos = 3, cex=0.8)
title(main = "Top 10 Systems by Statistic: MEM_30d_Report$MEM.Avg")
rm(top10, vals, mp)

#
# Page Header
#

pnum <- pnum + 1
ptitle<- paste("Top 10 Systems by Statistic                                Page", pnum)
print(ptitle)
mtext(ptitle, 3, line=0.01, adj=1.0, cex=0.8, outer=TRUE)
#
# Page Footer
#
mtext(credit_title, 1, line=0.01, cex=0.5, outer=TRUE)
  
#=================================================================================================================   
#
#  Page 2
#
#=================================================================================================================   
par(mfrow=c(2,1), mar=c(4,4,2,2), oma=c(1.5,2,1,1))
  
# ------------------------------------------------------------------------------------------ INT30/INT.Avg Barplot
vals <- 1:10
top10 <- head(INT_30d_Report[order(-INT_30d_Report$INT.Avg),],10)
vals <- as.numeric(format(top10$INT.Avg,digits=4, nsmall=2, scientific=TRUE))
mp <- barplot(top10$INT.Avg, names.arg=top10$host, cex.names=0.5, ylim=c(0,1.20*max(top10$INT.Avg)), col=rainbow(10), 
              ylab="INT.Avg Count")
text(mp,vals, labels= vals, pos = 3, cex=0.8)
title(main = "Top 10 Systems by Statistic: INT_30d_Report$INT.Avg")
rm(top10, vals, mp)


# ------------------------------------------------------------------------------------------ PRC30/PRC.Avg Barplot
vals <- 1:10
top10 <- head(PRC_30d_Report[order(-PRC_30d_Report$PRC.Avg),],10)
vals <- as.numeric(format(top10$PRC.Avg,digits=4, nsmall=0))
mp <- barplot(top10$PRC.Avg, names.arg=top10$host, cex.names=0.5, ylim = c(0,1.20*max(top10$PRC.Avg)), col=rainbow(10), 
              ylab="PRC.Avg Count")
text(mp,vals, labels= vals, pos = 3, cex=0.8)
title(main = "Top 10 Systems by Statistic: PRC_30d_Repor$PRC.Avg")
rm(top10, vals, mp)

#
# Page Header
#
pnum <- pnum + 1
ptitle<- paste("Top 10 Systems by Statistic                                Page", pnum)
print(ptitle)
mtext(ptitle, 3, line=0.01, adj=1.0, cex=0.8, outer=TRUE)
#
# Page Footer
#
mtext(bptitle, 1, line=0.01, cex=0.5, outer=TRUE)
   
#=================================================================================================================   
#
#  Page 3
#
#=================================================================================================================   
par(mfrow=c(2,1), mar=c(4,4,2,2), oma=c(1.5,2,1,1))


# ------------------------------------------------------------------------------------------ NTI30/NTI.Avg Barplot
vals <- 1:10
top10 <- head(NTI_30d_Report[order(-NTI_30d_Report$NTI.Avg),],10)
vals <- as.numeric(format(top10$NTI.Avg,digits=4, nsmall=2, scientific=TRUE))
mp <- barplot(top10$NTI.Avg, names.arg=top10$host, cex.names=0.5, ylim=c(0,1.20*max(top10$NTI.Avg)), col=rainbow(10), 
              ylab="NTI.Avg Count")
text(mp,vals, labels= vals, pos = 3, cex=0.8)
title(main = "Top 10 Systems by Statistic: NTI_30d_Report$NTI.Avg")
rm(top10, vals, mp)


# ------------------------------------------------------------------------------------------ NTO30/PRC.Avg Barplot
vals <- 1:10
top10 <- head(NTO_30d_Report[order(-NTO_30d_Report$NTO.Avg),],10)
vals <- as.numeric(format(top10$NTO.Avg,digits=4, nsmall=2, scientific=TRUE))
mp <- barplot(top10$NTO.Avg, names.arg=top10$host, cex.names=0.5, ylim=c(0,1.20*max(top10$NTO.Avg)), col=rainbow(10), 
              ylab="NTO.Avg Count")
text(mp,vals, labels= vals, pos = 3, cex=0.8)
title(main = "Top 10 Systems by Statistic: NTO_30d_Report$NTO.Avg")
rm(top10, vals, mp)

#
# Page Header
#
pnum <- pnum + 1
ptitle<- paste("Top 10 Systems by Statistic                                Page", pnum)
print(ptitle)
mtext(ptitle, 3, line=0.01, adj=1.0, cex=0.8, outer=TRUE)
#
# Page Footer
#
mtext(bptitle, 1, line=0.01, cex=0.5, outer=TRUE)


#=================================================================================================================   
#
#  Page 4
#
#=================================================================================================================   
par(mfrow=c(2,1), mar=c(4,4,2,2), oma=c(1.5,2,1,1))


# ------------------------------------------------------------------------------------------ RUN30/RQ.Avg Barplot
vals <- 1:10
top10 <- head(RUN_30d_Report[order(-RUN_30d_Report$RQ.Avg),],10)
vals <- as.numeric(format(top10$RQ.Avg,digits=4, nsmall=2, scientific=TRUE))
mp <- barplot(top10$RQ.Avg, names.arg=top10$host, cex.names=0.5, ylim=c(0,1.20*max(top10$RQ.Avg)), col=rainbow(10), 
              ylab="RQ.Avg Count")
text(mp,vals, labels= vals, pos = 3, cex=0.8)
title(main = "Top 10 Systems by Statistic: RUN_30d_Report$RQ.Avg")
rm(top10, vals, mp)



#
# Page Header
#
pnum <- pnum + 1
ptitle<- paste("Top 10 Systems by Statistic                                Page", pnum)
print(ptitle)
mtext(ptitle, 3, line=0.01, adj=1.0, cex=0.8, outer=TRUE)
#
# Page Footer
#
mtext(bptitle, 1, line=0.01, cex=0.5, outer=TRUE)


#=================================================================================================================   
#
#  Page 
#
#=================================================================================================================   
par(mfrow=c(2,1), mar=c(4,4,2,2), oma=c(1.5,2,1,1))

# ------------------------------------------------------------------------------------------ COR30/COR.Max Barplot
vals <- 1:10
top10 <- head(COR_30d_Report[order(-COR_30d_Report$COR.Max),],10)
vals <- as.numeric(format(top10$COR.Max,digits=4, nsmall=2, scientific=TRUE))
mp <- barplot(top10$COR.Max, names.arg=top10$host, cex.names=0.5, ylim=c(0,1.20*max(top10$COR.Max)), col=rainbow(10), 
              ylab="COR.Max Count")
text(mp,vals, labels= vals, pos = 3, cex=0.8)
title(main = "Top 10 Systems by Statistic: COR_30d_Report$COR.Max")
rm(top10, vals, mp)


# ------------------------------------------------------------------------------------------ COR30/COR.Avg Barplot
vals <- 1:10
top10 <- head(COR_30d_Report[order(-COR_30d_Report$COR.Avg),],10)
vals <- as.numeric(format(top10$COR.Avg,digits=4, nsmall=2, scientific=TRUE))
mp <- barplot(top10$COR.Avg, names.arg=top10$host, cex.names=0.5, ylim=c(0,1.20*max(top10$COR.Avg)), col=rainbow(10), 
              ylab="COR.Avg Count")
text(mp,vals, labels= vals, pos = 3, cex=0.8)
title(main = "Top 10 Systems by Statistic: COR_30d_Report$COR.Avg")
rm(top10, vals, mp)


#
# Page Header
#
pnum <- pnum + 1
ptitle<- paste("Top 10 Systems by Statistic                                Page", pnum)
print(ptitle)
mtext(ptitle, 3, line=0.01, adj=1.0, cex=0.8, outer=TRUE)
#
# Page Footer
#
mtext(bptitle, 1, line=0.01, cex=0.5, outer=TRUE)
dev.off()