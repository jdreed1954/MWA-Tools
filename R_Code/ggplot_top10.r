#
# <ggplot_top10.r> -  R script to produce pdf plot file of the top ten in each of ten metrics.
#           
#                 Example execution:
#
#           > source('C:/Users/jxreed/Desktop/MyProjects/bin/ggplot_top10.r')
#           >
#                 
#   James D Reed (james.reed@hp.com)                
#   September 29, 2013
#
## # use all data frames in current workspace to generate graphs.


## Enter the name of the plot file in the pdf command below
pdf("ggplot2_top10.pdf", paper="USr", width=10.5, height = 8.0 )

require(ggplot2)
require(grid)
require(scales)
require(RColorBrewer)

require(graphics)

credit_title<- paste("James D Reed (james.reed@hp.com) Hewlett-Packard Company Solution Architect")
reportDateString <- date()
pnum <- 0


#  F  U  N  C  T  I  O  N  S             ----------------------------------
newPage <- function() {
  
  grid.newpage()
  pushViewport(viewport(layout = grid.layout(1,1)))

}

printPage <- function(plot,pnum) {
  
  print(plot, vp = vplayout(1,1))
  
  printHeaderFooter(pnum)
  print(paste(Sys.time(),"completed plot",pnum, sep=" "))
 
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



# M A I N  S T A R T S  H E R E -------------------------------------------



# CPU_30d/CPU.98th Barplot ------------------------------------------------
newPage()
plot_title<- c("Top 10 Systems by Statistic: CPU_30d_Report$CPU.98th")

top10 <- head(CPU_30d_Report[order(-CPU_30d_Report$CPU.98th),],10)
top10 <- transform(top10,host = reorder(host,-CPU.98th))
cplot <- ggplot(top10, aes(x=host, y=CPU.98th, fill = host)) + 
         geom_bar(stat="identity")  + 
         xlab("") + ylab("CPU Utilization 98th Percentile (%)") +  ggtitle(plot_title) +
         scale_colour_manual(values = brewer.pal(10,"Set3")) +
         geom_text(aes(label= as.numeric(format(top10$CPU.98th,digits=4, nsmall=2))), size = 3, hjust = 0.5, vjust = 3)

pnum <- pnum + 1; 
printPage(cplot,pnum); 
rm(top10, cplot)


# CPU_30d/CPU.Avg Barplot -------------------------------------------------
newPage()
plot_title<- c("Top 10 Systems by Statistic: CPU_30d_Report$CPU.Avg")

top10 <- head(CPU_30d_Report[order(-CPU_30d_Report$CPU.Avg),],10)
top10 <- transform(top10,host = reorder(host,-CPU.Avg))
cplot <- ggplot(top10, aes(x=host, y=CPU.Avg, fill = host)) + 
  geom_bar(stat="identity")  + 
  xlab("") + ylab("Average CPU Utilization (%)") +  ggtitle(plot_title) +
  scale_colour_manual(values = brewer.pal(10,"Set3")) +
  geom_text(aes(label= as.numeric(format(top10$CPU.Avg,digits=4, nsmall=2))), size = 3, hjust = 0.5, vjust = 3)

pnum <- pnum + 1; 
printPage(cplot,pnum); 
rm(top10, cplot)



# MEM_30d/MEM.Avg Barplot -------------------------------------------------
newPage()
plot_title<- c("Top 10 Systems by Statistic: MEM_30d_Report$MEM.Avg")

top10 <- head(MEM_30d_Report[order(-MEM_30d_Report$MEM.Avg),],10)
top10 <- transform(top10,host = reorder(host,-MEM.Avg))

cplot <- ggplot(top10, aes(x=host, y=MEM.Avg, fill = host)) + 
  geom_bar(stat="identity")  + 
  xlab("") + ylab("Memory Utilization (%)") +  ggtitle(plot_title) +
  scale_colour_manual(values = brewer.pal(10,"Set3")) +
  geom_text(aes(label= as.numeric(format(top10$MEM.Avg,digits=4, nsmall=2))), size = 3, hjust = 0.5, vjust = 3)

pnum <- pnum + 1; 
printPage(cplot,pnum); 
rm(top10, cplot)

# Int_30d/Int.Avg Barplot -------------------------------------------------
newPage()
plot_title<- c("Top 10 Systems by Statistic: INT_30d_Report$INT.AVG")

top10 <- head(INT_30d_Report[order(-INT_30d_Report$INT.Avg),],10)
top10 <- transform(top10,host = reorder(host,-INT.Avg))

cplot <- ggplot(top10, aes(x=host, y=INT.Avg, fill = host)) + 
  geom_bar(stat="identity")  + 
  xlab("") + ylab("Average Interrupts") +  ggtitle(plot_title) +
  scale_colour_manual(values = brewer.pal(10,"Set3")) +
  geom_text(aes(label= as.numeric(format(top10$INT.Avg,digits=4, nsmall=2))), size = 3, hjust = 0.5, vjust = 3)

pnum <- pnum + 1
printPage(cplot,pnum)
rm(top10, cplot)

# PRC_30d/PRC.Avg Barplot -------------------------------------------------
newPage()
plot_title<- c("Top 10 Systems by Statistic: PRC_30d_Report$PRC.Avg")

top10 <- head(PRC_30d_Report[order(-PRC_30d_Report$PRC.Avg),], 10)
top10 <- transform(top10,host = reorder(host,-PRC.Avg))

cplot <- ggplot(top10, aes(x=host, y=PRC.Avg, fill = host)) + 
  geom_bar(stat="identity")  + 
  xlab("") + ylab("Average Alive Processes") +  ggtitle(plot_title) +
  scale_colour_manual(values = brewer.pal(10,"Set3")) +
  geom_text(aes(label= as.numeric(format(top10$PRC.Avg,digits=4, nsmall=2))), size = 3, hjust = 0.5, vjust = 3)

pnum <- pnum + 1
printPage(cplot,pnum)
rm(top10, cplot)

# ACT_30d/ACT.Avg Barplot -------------------------------------------------
newPage()
plot_title<- c("Top 10 Systems by Statistic: ACT_30d_Report$ACT.Avg")

top10 <- head(ACT_30d_Report[order(-ACT_30d_Report$ACT.Avg),], 10)
top10 <- transform(top10,host = reorder(host,-ACT.Avg))

cplot <- ggplot(top10, aes(x=host, y=ACT.Avg, fill = host)) + 
  geom_bar(stat="identity")  + 
  xlab("") + ylab("Average ACTIVE Processes") +  ggtitle(plot_title) +
  scale_colour_manual(values = brewer.pal(10,"Set3")) +
  geom_text(aes(label= as.numeric(format(top10$ACT.Avg,digits=4, nsmall=2))), size = 3, hjust = 0.5, vjust = 3)

pnum <- pnum + 1
printPage(cplot,pnum)
rm(top10, cplot)


# NTI_30d/NTI.Avg Barplot -------------------------------------------------
newPage()
plot_title<- c("Top 10 Systems by Statistic: NTI_30d_Report$NTI.Avg")

top10 <- head(NTI_30d_Report[order(-NTI_30d_Report$NTI.Avg),], 10)
top10 <- transform(top10,host = reorder(host,-NTI.Avg))

cplot <- ggplot(top10, aes(x=host, y=NTI.Avg, fill = host)) + 
  geom_bar(stat="identity")  + 
  xlab("") + ylab("Network Input Packet Rate") +  ggtitle(plot_title) +
  scale_colour_manual(values = brewer.pal(10,"Set3")) +
  geom_text(aes(label= as.numeric(format(top10$NTI.Avg,digits=4, nsmall=2))), size = 3, hjust = 0.5, vjust = 3)

pnum <- pnum + 1; printPage(cplot,pnum); rm(top10, cplot)

# NTI_30d/NTO.Avg Barplot -------------------------------------------------
newPage()
plot_title<- c("Top 10 Systems by Statistic: NTO_30d_Report$NTO.Avg")

top10 <- head(NTO_30d_Report[order(-NTO_30d_Report$NTO.Avg),], 10)
top10 <- transform(top10,host = reorder(host,-NTO.Avg))

cplot <- ggplot(top10, aes(x=host, y=NTO.Avg, fill = host)) + 
  geom_bar(stat="identity")  + 
  xlab("") + ylab("Network Output Packet Rate") +  ggtitle(plot_title) +
  scale_colour_manual(values = brewer.pal(10,"Set3")) +
  geom_text(aes(label= as.numeric(format(top10$NTO.Avg,digits=4, nsmall=2))), size = 3, hjust = 0.5, vjust = 3)

pnum <- pnum + 1; printPage(cplot,pnum); rm(top10, cplot)

# RUN_30d/RQ.Avg Barplot --------------------------------------------------
newPage()
plot_title<- c("Top 10 Systems by Statistic: RUN_30d_Report$RQ.Avg")

top10 <- head(RUN_30d_Report[order(-RUN_30d_Report$RQ.Avg),], 10)
top10 <- transform(top10,host = reorder(host,-RQ.Avg))

cplot <- ggplot(top10, aes(x=host, y=RQ.Avg, fill = host)) + 
  geom_bar(stat="identity")  + 
  xlab("") + ylab("Run Queue") +  ggtitle(plot_title) +
  scale_colour_manual(values = brewer.pal(10,"Set3")) +
  geom_text(aes(label= as.numeric(format(top10$RQ.Avg,digits=4, nsmall=2))), size = 3, hjust = 0.5, vjust = 3)

pnum <- pnum + 1; printPage(cplot,pnum); rm(top10, cplot)

# COR_30d/COR.Max Barplot -------------------------------------------------
newPage()
plot_title<- c("Top 10 Systems by Statistic: COR_30d_Report$COR.Max")

top10 <- head(COR_30d_Report[order(-COR_30d_Report$COR.Max),], 10)
# Adjust for cores versus LP
#top10$COR.Max <- top10$COR.Max/2

top10 <- transform(top10,host = reorder(host,-COR.Max))

cplot <- ggplot(top10, aes(x=host, y=COR.Max, fill = host)) + 
  geom_bar(stat="identity")  + 
  xlab("") + ylab("Maximum Cores") +  ggtitle(plot_title) +
  scale_colour_manual(values = brewer.pal(10,"Set3")) +
  geom_text(aes(label= as.numeric(format(top10$COR.Max,digits=4, nsmall=2))), size = 3, hjust = 0.5, vjust = 3)

pnum <- pnum + 1; printPage(cplot,pnum); rm(top10, cplot)


# COR_30d/COR.Avg Barplot -------------------------------------------------
newPage()
plot_title<- c("Top 10 Systems by Statistic: COR_30d_Report$COR.Avg")

top10 <- head(COR_30d_Report[order(-COR_30d_Report$COR.Avg),], 10)
# Adjust for cores versus LP
#top10$COR.Avg <- top10$COR.Avg/2

top10 <- transform(top10,host = reorder(host,-COR.Avg))

cplot <- ggplot(top10, aes(x=host, y=COR.Avg, fill = host)) + 
  geom_bar(stat="identity")  + 
  xlab("") + ylab("Average Cores") +  ggtitle(plot_title) +
  scale_colour_manual(values = brewer.pal(10,"Set3")) +
  geom_text(aes(label= as.numeric(format(top10$COR.Avg,digits=4, nsmall=2))), size = 3, hjust = 0.5, vjust = 3)

pnum <- pnum + 1; printPage(cplot,pnum); rm(top10, cplot)

dev.off()