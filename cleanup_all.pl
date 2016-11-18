#!/usr/bin/perl -w
#
#  This script uses the following environment variables:
#  export MWA_DATA_HOME=~/DISH/1405
#
##

use strict;
use File::Copy;

# This is the magic to use my subroutine library in the ../lib directory
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(dirname abs_path $0).'/lib';
use MyTools qw(tStamp getComplexes);
#  Magic off

use List::MoreUtils qw(uniq);

my $DATAHOME=$ENV{'MWA_DATA_HOME'};
print "\n\n".tStamp()."Cleanup All Decompressed  START\n";
print tStamp()."MWA_DATA_HOME = $DATAHOME \n";
chdir $DATAHOME or die;

my @DIRS = getComplexes();

foreach my $sys (@DIRS) 
{
   print tStamp()."Cleanup System complex $sys ...\n";
   my $start = time;
   system("rm -rf $sys");
   my $elapsed = time - $start;
   print tStamp()."Cleanup Complete. \n\n";

}

print tStamp()."Cleanup COMPLETE.\n";
exit;

