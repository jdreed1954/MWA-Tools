#!/usr/local/bin/perl -w
#
#  This script uses the following environment variables:
#  export MWA_DATA_HOME=/Users/Jim/Data/DISH/1310
#
##

use strict;
use Cwd;
use List::MoreUtils qw(uniq);

sub  getComplexes() {

	opendir(DIR, "./.logs") or die;

	my @clist = ();
	my @complexes = ();

	while ( defined( my $file = readdir(DIR))) {
		next if $file =~ /^\.\.?$/;     # skip . and ..
        	my @cmplx = split("v", $file);
		push @clist,$cmplx[0];
	}

	@complexes = uniq(@clist);
	return @complexes;

}

my $DATAHOME=$ENV{'MWA_DATA_HOME'};
print "Using MWA_DATA_HOME = $DATAHOME \n\n";
chdir $DATAHOME or die;
my @flds = split("/",$DATAHOME);
my $BASE= $flds[$#flds];

my @DIRS = getComplexes();

my $cwd = getcwd();
print "DEBUG (inside gen_perf_xls.pl): CWD = $cwd\n";
foreach my $sys (@DIRS) 
{
   print tStamp()."Complex $sys ...\n";
   my $start = time;
#  my $PerfSS=$sys."_".$BASE."_"."performance.xls";
   my $PerfSS=$BASE."_".$sys."_"."performance.xls";
   system("~/bin/perfMakePerfXLS.pl $PerfSS ../CSV/$BASE/$sys");
   my $elapsed = time - $start;
   print tStamp()."Complete: $elapsed sec.\n\n";

}
exit;

sub tStamp {

   my $sec;
   my $min;
   my $hour;
   my $mday;
   my $mon;
   my $year;
   my $wday;
   my $yday;
   my $isdst;

   ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
   my $now =  sprintf("[%04d-%02d-%02d %02d:%02d:%02d] ", 
                      $year+1900, $mon, $mday, $hour, $min, $sec);

   return $now;

}

