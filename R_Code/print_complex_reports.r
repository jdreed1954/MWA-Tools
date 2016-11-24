#
#
# Print_complex_reports.r
#
# These are the complexes we are interested in generating this summary data.
Complexes <- c("cs01", "cs02", "csc03", "csc04", "csc05", "csc06", "pdb1n1")
#Complexes <- "cs01"

for (cmplx in Complexes) {
  print(' ', quote=FALSE)
  print(' ', quote=FALSE)
  print(paste("                                                     Complex",cmplx,startdate,"to",enddate), quote=FALSE)
  print(' ', quote=FALSE)
  print(' ', quote=FALSE)
  
  lhs <- "REPORT"
  rhs <- paste("complex_",cmplx,"_ALL",sep="")
  eq <- paste(paste(lhs,rhs,sep="<-"), collapse=";")

  eval(parse(text=eq))
  print(REPORT)
  rm(REPORT)
}