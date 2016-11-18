#!/usr/bin/perl -w
#
# extract_global.pl  PERL script use 
#               data to csv files.
#
#  This script uses the following environment variables:
#  export MWA_DATA_HOME=/home/jdreed/DISH/1311
#
#
#       by James D. Reed (james.reed@hp.com)
#       October 25, 2013
#
#	Modifications:
#	Date			Description
#	13-May-2013 	Added metrics for CPU, Memory and Disk to better 
#                       diagnose bottlenecks and overall utilization.
#	21-Oct-2014	Added ability to get complexes without an explicit list.
#
##

use strict;
use List::MoreUtils qw(uniq);

# This is the magic to use my subroutine library in the ../lib directory
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(dirname abs_path $0).'/lib';
use MyTools qw(tStamp getComplexes);
#  Magic off

my $DATAHOME=$ENV{'MWA_DATA_HOME'};
print "\n\n".tStamp()."Extract Globals from MWA Logs START\n";
print tStamp()."Using MWA_DATA_HOME = $DATAHOME \n";
chdir $DATAHOME or die;
my @flds = split("/", $DATAHOME);
my $base = $flds[$#flds];

my @DIRS = getComplexes();

foreach my $sys (@DIRS) 
{
   print tStamp()."Extract Globals from system complex $sys ...\n";
   my $start = time;
   system("~/bin/perfExtractGlobal.pl ../CSV/$base/$sys $sys/* > /dev/null");
   my $elapsed = time - $start;
   print tStamp()."Extract Globals from system complex complete.: $elapsed seconds\n\n";

}

print tStamp()."Extract Globals from MWA Logs COMPLETE.\n";

exit;

