#!/usr/bin/perl -w
#
# perfExtractGlobal.pl  PERL script use extract utility to selected global 
#               data to csv files.
#
#       by James D. Reed (james.reed@hp.com)
#       January 6, 2010
#
#	Modifications:
#	Date			Description
#	13-May-2013 	Added metrics for CPU, Memory and Disk to better 
#                       diagnose bottlenecks and overall utilization.
#
##

use strict;
use File::Basename;
use File::Path qw(make_path remove_tree);

my $INPUT="/tmp/global.inp";

#
# Process Command Line Arguments
#
my $numargs = $#ARGV + 1;
if ( $numargs < 2 ) {
   print "Usage: $0 [-n number of days] CSV_directory logglob_directories ... \n";
   exit;
}

# Process Optional -n flag
my $numdays = 0;
if (@ARGV && $ARGV[0] eq "-n") {
   $numdays = $ARGV[1];
   shift;
   shift;
}

my ($csvdir, @loglist) = @ARGV;

# 
# Copy global input parameters.
#
open(my $gblfh, "+>", $INPUT ) or 
          die "$0: cannot open temporary file: !\n";
while (my $line = <DATA>) {
   print $gblfh $line;
}
close($gblfh);

if ( -d $csvdir ) {
   print "CSV ouput files will be written to directory $csvdir\n";
} else {
# try to create directory or die.
   ##mkdir ($csvdir) or die "Unable to create CSV directory: $csvdir \n";
   make_path($csvdir, { verbose => 0, mode => 0700 });

}


open(my $tmpfh, "+>", undef) or die "$0: cannot open temporary file: !\n";

my $first = "FIRST";
if ( $numdays > 0) {
  $first = "LAST-".$numdays;
  print "DEBUG: numdays = $numdays, first = $first \n";
}

foreach my $logdir (@loglist) 
{

   my ($base, $path, $suffix) = fileparse($logdir,qr/\.[^.]*/);
   print "\tProcessing directory $base ...";
   my $start = time;
   my $out = "$csvdir/$base\.csv";
   my $log = "-l $logdir/logglob";

   if (-e $out) { unlink $out; }
         system("extract -b $first -e LAST -g -r $INPUT -xp -f $out $log 2>> /dev/null");
   my $elapsed = time - $start;
   print "\t$elapsed seconds\n";

}
unlink $INPUT;
exit;


__DATA__
REPORT "MWA Export !DATE !TIME Logfile: !LOGFILE !COLLECTOR !SYSTEM_ID"
FORMAT ASCII 
HEADINGS ON 
SEPARATOR=","
SUMMARY=5
MISSING=0

*********************************************************************
DATA TYPE GLOBAL
LAYOUT MULTIPLE
**................................ Global Record Identification Metrics
                      
DATE                                         
TIME                                         

**................................ Global CPU Metrics

GBL_CPU_USER_MODE_UTIL
GBL_CPU_SYS_MODE_UTIL
GBL_CPU_INTERRUPT_UTIL
GBL_CPU_SYSCALL_UTIL
GBL_CPU_TOTAL_UTIL                           
GBL_ACTIVE_CPU
GBL_INTERRUPT
GBL_RUN_QUEUE
GBL_ALIVE_PROC
GBL_ACTIVE_PROC
GBL_SYSCALL
GBL_SYSCALL_RATE
GBL_MEM_UTIL                                 
GBL_MEM_PAGEOUT_RATE
GBL_MEM_SWAPOUT_RATE
GBL_MEM_QUEUE
GBL_DISK_PHYS_IO_RATE
GBL_DISK_PHYS_BYTE_RATE
GBL_DISK_REQUEST_QUEUE
GBL_NET_IN_PACKET_RATE
GBL_NET_OUT_PACKET_RATE
