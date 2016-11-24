#  Print Top10 Reports
#
#load(".RData")
# ----------------------------------------------------------------------- CPU30 Top-10
fname <- "top10_CPU30.csv"
sort1 <- with(CPU_30d_Report,CPU_30d_Report[order(-CPU.98th),])
write.csv(sort1[1:10,],file=fname)
rm(sort1)

# ----------------------------------------------------------------------- COR30 Top-20
fname <- "top10_COR30.csv"
sort1 <- with(COR_30d_Report, COR_30d_Report[order(-COR.Avg),])
write.csv(sort1[1:10,],file=fname)
rm(sort1)


# ----------------------------------------------------------------------- MEM30 Top-10
fname <- "top10_MEM30.csv"
sort1 <- with(MEM_30d_Report,MEM_30d_Report[order(-MEM.Avg),])
write.csv(sort1[1:10,],file=fname)
rm(sort1)


# ----------------------------------------------------------------------- RUN30 Top-10
fname <- "top10_RUN30.csv"
sort1 <- with(RUN_30d_Report,RUN_30d_Report[order(-RQ.Avg),])
write.csv(sort1[1:10,],file=fname)
rm(sort1)


# ----------------------------------------------------------------------- PRC30 Top-10
fname <- "top10_PRC30.csv"
sort1 <- with(PRC_30d_Report, PRC_30d_Report[order(-PRC.Avg),])
write.csv(sort1[1:10,],file=fname)
rm(sort1)

# ----------------------------------------------------------------------- PIO30 Top-10
fname <- "top10_PIO30.csv"
sort1 <- with(PIO_30d_Report,PIO_30d_Report[order(-PIO.Avg),])
write.csv(sort1[1:10,],file=fname)
rm(sort1)

# ----------------------------------------------------------------------- IOPS30 Top-10
fname <- "top10_IOPS30.csv"
sort1 <- with(PIOPS_30d_Report,PIOPS_30d_Report[order(-PIOPS.98th),])
write.csv(sort1[1:10,],file=fname)
rm(sort1)


# ----------------------------------------------------------------------- NTI30 Top-10
fname <- "top10_NTI30.csv"
sort1 <- with(NTI_30d_Report, NTI_30d_Report[order(-NTI.Avg),])
write.csv(sort1[1:10,],file=fname)
rm(sort1)


# ----------------------------------------------------------------------- NTO30 Top-10
fname <- "top10_NTO30.csv"
sort1 <- with(NTO_30d_Report, NTO_30d_Report[order(-NTO.Avg),])
write.csv(sort1[1:10,],file=fname)   
rm(sort1)

# ----------------------------------------------------------------------- INT30 Top-10
fname <- "top10_INT30.csv"
sort1 <- with(INT_30d_Report, INT_30d_Report[order(-INT.Avg),])
write.csv(sort1[1:10,],file=fname)   
rm(sort1)

# 
# 

