package MyTools;

use strict;
use warnings;

use File::Copy;
use List::MoreUtils qw(uniq);

use Exporter qw(import);

our @EXPORT_OK = qw(tStamp getComplexes);

sub tStamp {

   my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst);

   ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
   my $now =  sprintf("[%04d-%02d-%02d %02d:%02d:%02d] ", 
                      $year+1900, $mon, $mday, $hour, $min, $sec);

   return $now;

}

sub  getComplexes() {

	opendir(DIR, "./.logs") or die;

	my @clist = ();
	my @complexes = ();
	my $numServ = 0;
        my $numCmplx = 0;

	while ( defined( my $file = readdir(DIR))) {
		next if $file =~ /^\.\.?$/;     # skip . and ..
		next if $file =~ /\.log$/;	# skip if .log file
		$numServ++;
        	my @cmplx = split("v", $file);
		push @clist,$cmplx[0];
	}

	@complexes = uniq(@clist);
	$numCmplx = $#complexes + 1;
	print tStamp()."Complexes: $numCmplx  Servers: $numServ \n\n";
	return @complexes;

}

1;
