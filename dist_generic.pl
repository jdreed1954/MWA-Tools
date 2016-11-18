#!/usr/bin/perl -w
#
#  This script uses the following environment variables:
#  export MWA_DATA_HOME=~/OFI/1411
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
print "\n\n".tStamp()."Distribute and Decompress GENERIC START\n";
print tStamp()."MWA_DATA_HOME = $DATAHOME \n";
chdir $DATAHOME or die;


print tStamp()."Decompress All Systems ...\n";
my $start = time;
system("cp .logs/*.gz .");
# Decompress ...
system("~/bin/perfExtractMWA.pl");
system("rm *.gz");
chdir "..";
my $elapsed = time - $start;
print tStamp()."Decompress Complete: $elapsed seconds\n\n";

print tStamp()."Distribute and Decompress GENERIC COMPLETE.\n";
exit;

