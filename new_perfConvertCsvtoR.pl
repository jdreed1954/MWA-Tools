#!/usr/local/bin/perl -w
#
# perfConverttoR.pl  PERL script to use input CSV files to create output files
#       containing R-format date with the date/time converted to Epoch time.
#
#
#	by James D. Reed (james.reed@hpe.com)
#	July 24, 2010
#
#	Modifications:
#	Date			Description
#	14-May-2013 	Added metrics for CPU, Memory and Disk to better diagnose bottlenecks and overall utilization.
#       27-Oct-2013	Added argument to direct .r files 
#       14-Nov-2016	Direct extract requires different way to hamdle date and time variables.
#
#
#
use strict;
use Time::Local;
use File::Basename;
use Text::CSV_XS;
use Text::Trim;
use File::Path qw(make_path remove_tree);


# 
# Process Command Line Arguments
#
my $numargs = $#ARGV + 1;
if ( $numargs < 1 ) {
	print "Usage: $0 CSV_Directory R_Directory\n";
	exit;
}

my ($CSVDIR, $RDIR) = @ARGV;
my $reclimit = 999999;
 
opendir(DIR,$CSVDIR) or 
	    die "Cannot open $CSVDIR\n";

my @csvlist = grep /\.csv$/, readdir(DIR);
close(DIR);
my @CSV = sort @csvlist;

#  Let's check to see if the desired output directory exists.  If it doesn't let try to create it.

unless (-d $RDIR) {
    #print "DEBUG: running mkdir ...\n";
    make_path($RDIR, { verbose => 0, mode => 0700 });
}
foreach my $csvFileName (@csvlist)
{
   
   print "\tFile: $csvFileName:";
   my $start = time;
   my $OldFormat = 0;
 
   open (CSVFILE, $CSVDIR."/".$csvFileName) or die;
   my $csv_in = Text::CSV_XS->new;
   my $csvout = Text::CSV_XS->new;

   my ($base, $path, $suffix) = fileparse($csvFileName,qr/\.[^.]*/);
   my $outCsvFileName = $base.".r";
   open (my $fh, ">", $RDIR."/".$outCsvFileName) or die "$0: cannot open $outCsvFileName.\n";
	
   write_headers($fh, $csvout);
   my $num_recs = 0;
   my $num_writ = 0;
   RECORD: while(<CSVFILE>) {
      $num_recs++;
      if ($num_recs == 1 && ($_ =~ /^MWA/)) { $OldFormat = 1 }
      if ($num_recs < 3 || $num_recs > $reclimit) {
	next RECORD;
      }
      if ($csv_in->parse($_) ) {
         my @Fld = $csv_in->fields;
	 my ($intDate, $intTime) = split / /, trim($Fld[0]);
         #print "DEBUG: Fld[0] = $Fld[0] \n";
         #print "DEBUG: intDate, intTime = $intDate, $intTime\n";

         #my ($etime) = epochtime($Fld[0],$Fld[1]);
         my ($etime) = epochtime($intDate,$intTime);
	 #  my $csvout_status = $csvout->combine($etime,@Fld);
         #my $line = combine($etime,@Fld);
         my $line = combine($etime, $intDate, $intTime, @Fld[2..$#Fld]);
         print $fh $line,"\n";
         $num_writ++;

      }
   }
   my $elapsed = time - $start;
   print "\t$elapsed sec\tRecords: $num_writ\n";

}

exit;

sub combine {

   my (@fields) = @_;
   my ($numf)  = scalar(@fields);
   my $line;
   my $num = 0;

   foreach my $tok (@fields) {
     $line = $line.$tok;
     $num++;
     if ($num < ($numf) ) {
        $line = $line.",";
     } 
   }
   $line =~ s/,$//;
   #print "DEBUG: combine: numf = $numf, $line\n";
   return $line;
}

 
sub write_headers {
  my ($fh, $csvout) = @_;
  my @Headers = ( "Epoch.DT",      "Int.Date",      "Int.Time",    "CPU.User",      "CPU.Sys",   
                  "CPU.Intrpt",    "CPU.SysCall",   "CPU.Tot",     "CPU.Act",       "Interrpt", 
				          "Run.Queue",     "Alive.Proc",    "Active.Proc", "SysCall.Num",   "SysCall.Rt",    
				          "Mem.Pct",       "MemPO.Rt",      "MemSO.Rt",    "Mem.Queue",     "DiskPhys.IORt", 
				          "DiskPhys.BtRt", "DiskReq.Queue", "InPkt.Rt",    "OutPkt.Rt");

  my $headerLine = combine(@Headers);
  print $fh $headerLine,"\n";

}



sub pdate {
  my ($token) = @_;

  my ($m, $d, $y) = split /\//, $token;

  my @Ret = ($m, $d, $y);
  return (@Ret);

}

sub ptime {
  my ($token) = @_;

  my ($h, $m, $s) = split /:/, $token;

  my @Ret = ($h, $m, $s);
  return (@Ret);

}

sub epochtime {
   my ($date, $time) = @_;

   my ($mnth, $day, $yr) = pdate($date);
   my ($hr, $min, $sec)  = ptime($time);

   my ($etime) = timelocal($sec, $min, $hr, $day, $mnth-1,$yr);
   return $etime;
}
