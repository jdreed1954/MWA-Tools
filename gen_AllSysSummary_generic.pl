#!/usr/bin/perl -w
#  This script uses the following environment variables:
#  export MWA_DATA_HOME=~/DISH/1406
#

#
##

use strict;
use Cwd;

# Save location from which this script is executed.
my $homeDir = getcwd;

my $DATAHOME=$ENV{'MWA_DATA_HOME'};
#print "Using MWA_DATA_HOME = $DATAHOME \n\n";
chdir $DATAHOME or die;
my @flds = split("/", $DATAHOME);
my $base = $flds[$#flds];
#print "DEBUG: base = $base\n";


# This is the magic to use my subroutine library in the ../lib directory
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(dirname abs_path $0).'/lib';
use MyTools qw(tStamp getComplexes);
#  Magic off
print "\n\n".tStamp()."Generate All System Summaries START\n";
print tStamp()."MWA_DATA_HOME = $DATAHOME \n";
chdir $DATAHOME or die;

system("~/bin/perfSysSummary.pl */*.txt");
system("cp SYS_SUMMARY.csv $homeDir/${base}_SYS_SUMMARY.csv");
print "Result: ${base}_SYS_SUMMARY.csv in directory $homeDir \n\n";

print tStamp()."Generate All System Summaries COMPLETE.\n";
exit;


