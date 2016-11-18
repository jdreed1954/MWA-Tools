#!/usr/bin/perl -w
#
#  This script uses the following environment variables:
#  export MWA_DATA_HOME=~/DISH/1405
#
##

use strict;
use File::Copy;
use List::MoreUtils qw(uniq);

my @DIRS = ("cs01", "cs02", "csc03", "csc04", "cs10", "cs1n0", "cs1n1", "cs6n0", "cs6n1", "cs7", "cs8", "cs9", "csc05", "csc06", "dt3", "dt5");

my $DATAHOME=$ENV{'MWA_DATA_HOME'};
print "[".tStamp()."] Using MWA_DATA_HOME = $DATAHOME \n\n";
chdir $DATAHOME or die;

my @Complexes = getComplexes();

print "Complexes = @Complexes \n";
exit;

sub  getComplexes() {

opendir(DIR, "./.logs") or die;

my @clist = ();
my @complexes = ();

while ( defined( my $file = readdir(DIR))) {
	next if $file =~ /^\.\.?$/;     # skip . and ..
	# Get the Complex name from each file
        my @cmplx = split("v", $file);
	push @clist,$cmplx[0];
	#print " file = $file, cmplx = $cmplx[0]\n";
}

@complexes = uniq(@clist);
#print "Complexes = @complexes \n";
return @complexes;

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

