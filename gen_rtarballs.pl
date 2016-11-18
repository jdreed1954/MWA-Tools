#!/usr/local/bin/perl -w
#  This script uses the following environment variables:
#  export MWA_DATA_HOME=/u/DISH/1404
#
#	21-Oct-2014 Added getComplexes so we don't have to list the complexes
#		    explicitly.
#

#
##

use strict;
use Cwd;

# This is the magic to use my subroutine library in the ../lib directory
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(dirname abs_path $0).'/lib';
use MyTools qw(tStamp getComplexes);
#  Magic off

my $DATAHOME=$ENV{'MWA_DATA_HOME'};
print "\n\n".tStamp()."Generate R tarball START\n";
print tStamp()."MWA_DATA_HOME = $DATAHOME \n";

my $homeDir = getcwd;

chdir $DATAHOME or die;
my @flds = split("/", $DATAHOME);
my $base = $flds[$#flds];

my @DIRS = getComplexes();

foreach my $sys (@DIRS) 
{
   print tStamp()."Generate R files for complex $sys ...\n";
   my $start = time;
   system("~/bin/perfConvertCsvtoR.pl ../CSV/$base/$sys ../R/$base/$sys/DATA");
   my $elapsed = time - $start;
   print tStamp()."Generate R files for complex complete: $elapsed seconds\n\n";

}

#
#  Now let's tar everything at once ...`
#
   print tStamp()."Generate TAR Ball ...\n";
   chdir "../R/" or die;

   # Lets clean out the ALL directory in case it already exists.
   if (-e "$base/ALL/DATA") {
        system("rm $base/ALL/DATA/*.r");  
   }
   unless (-e "$base/ALL" or  mkdir "$base/ALL") {
	die "Unable to create directory $base/ALL\n";
   }
   unless (-e "$base/ALL/DATA" or mkdir "$base/ALL/DATA") {
   	die "Unable to create directory $base/ALL/DATA\n";
   }
   system("cp $base/*/DATA/*.r $base/ALL/DATA/.");
   system("tar cvf - $base | gzip > $homeDir/$base"."_R.tar.gz");
   print "\n\n".tStamp()."Generate R tarball COMPLETE.\n";

exit;

