#
# Get top 10 host list for CPU, MEM, PIO and RUN

#Sort data table 

X <- CPU_30d_Report[order(-CPU.Avg),]$host
CPU_Top10 <- X[1:10]
SYSTEMS <- CPU_Top10

source('C:/Users/jxreed/Desktop/MyProjects/bin/ggplot_boxplot_CPU.r')

X <- MEM_30d_Report[order(-MEM.Max),]$host
MEM_Top10 <- X[1:10]
SYSTEMS <- MEM_Top10

source('C:/Users/jxreed/Desktop/MyProjects/bin/ggplot_boxplot_MEM.r')

X <- PIOPS_30d_Report[order(-PIOPS.Avg),]$host
PIOPS_Top10 <- X[1:10]
SYSTEMS <- PIOPS_Top10

source('C:/Users/jxreed/Desktop/MyProjects/bin/ggplot_boxplot_PIOPS.r')


X <- RUN_30d_Report[order(-RQ.Max),]$host
RUNQ_Top10 <- X[1:10]

SYSTEMS <- RUNQ_Top10

source('C:/Users/jxreed/Desktop/MyProjects/bin/ggplot_boxplot_RUNQ.r')

X <- COR_30d_Report[order(-COR.Std),]$host
COR_Top10 <- X[1:10]

SYSTEMS <- COR_Top10

source('C:/Users/jxreed/Desktop/MyProjects/bin/ggplot_boxplot_COR.r')
