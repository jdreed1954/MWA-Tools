#
# generate_CORE_reports.r
#
require(xtable)
# Use Date range previously defined
enddate 
startdate


# These are the complexes we are interested in generating this summary data.
Complexes <- c("csc01", "csc02", "csc05", "csc06", "csm1" )
Reports <- c(complex_csc01_CORE, complex_csc02_CORE, complex_csc05_CORE, complex_csc06_CORE, complex_csm1_CORE )

#Complexes <- c("cs01")

for (i in c(1:7)) {
  
  strCaption <- paste0("\\textbf{Complex ",Complexes[i],": CORE Report}")
  
  print(xtable(as.data.frame(Reports[i]), digits=0, caption=strCaption, label=paste0(Complexes[i]," CORE"),
        include.rownames=FALSE,
        include.colnames=FALSE, 
        caption.placement="top", 
        hline.after=NULL,
        add.to.row = list(pos = list(-1,nrow(complex_cs01_CORE)),
            command = c(paste("\\toprule \n","Vpar&DB&Cores(low)&Cores(hi)&Cores(avg)&C.Moves & CM/d\\\\\n",
                     "\\midrule \n"), "\\bottomrule \n"))))
 
  }