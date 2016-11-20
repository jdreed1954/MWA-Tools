#!/usr/local/bin/perl -w
#
# report_fpl-coremoves-v3.pl  PERL script to report core moves from SD2 FPL (forward progress log).
#
#       by James D. Reed (james.reed@hpe.com)
#       February 18, 2016
#
# Synopsis:
#	report_fpl_coremoves-v3.pl [--verbose] [--fillgaps] -flp <FLP_File1>[,FLP_File2]...
#       
#       November 20, 2016   - v5:  Cleanup of unitialized references and made sure 15 vPARs are accounted for in all reports and 
#                                  CSV files.:wq
#
#
#
use strict;
use File::Basename;
use Time::Local;
use Date::Calc qw( Date_to_Days Add_Delta_Days );
use Pod::Usage;
use Getopt::Long;

#
# Define Output Record
#
#
my $epochTime;
my $dateString;
my $timeString;
my @vparState = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

#
# Process Command Line Arguments
#
our $verbose = '';
our $fillgaps = '';
our $Version  = 'v5';
my @fplfiles = '';
my $help_opt = '';

my $result = GetOptions('help' => \$help_opt, 'verbose|v' => \$verbose, 'fillgaps|fill|f' => \$fillgaps, 'fpl=s' => \@fplfiles);
@fplfiles = split(/,/, join(',',@fplfiles));
pod2usage(1)  if ((@fplfiles == 0) && (-t STDIN));
shift(@fplfiles);  # required to get rid of bogus blank entry in this array.
if ($verbose) { print "Options: --verbose=$verbose --fillgaps=$fillgaps --flp=@fplfiles\n"; }

foreach (@fplfiles) {
	open FILE, $_ or die "$0: cannot open $_\n";


	my ($base, $path, $suffix) = fileparse($_,qr/\.[^.]*/);
	my $outCsvFileName = $base.".csv";

	open (my $fh, ">", $outCsvFileName) or 
          die "$0: cannot open $outCsvFileName.\n";


	my $eventID;
	my $line;
	my $line2;
	my @flds;
	my $records = 0;
	my $numVpars = 0;
	my @days;
	my @vpars;
	my @vparNames;
	my $vparNum;
	my $maxVparNum = 0;
	my $nparNum;
	my $numActivate = 0;
	my $numDeactivate = 0;
	my $parString;
	my @delta     = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	my @coreAct   = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	my @coreDeAct = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	my @repHead   = ("  ", "  ", "  ");
	my %coresByDay;
	my $fDateCaptured = 0;

	#
	# We scan the FPL (Forward Progress Log) for key log entries and extract
	# details we need to characterize core movement in the complex.
	#
	while (defined ($line = <FILE>)) {
		$records++;
		if ( $verbose && (($records % 100000) == 0)) { print "#"; $| = 1; }
		chomp $line;
		$line2 = "";
		if ($records == 1 ) {
		   write_headers($line, $fh);
		   
		   if ( $line =~ /^Version/) {
			 @flds = split(/ +/,$line);
			 $repHead[0] = "FPL Dump Version: ".$flds[1];
			 $repHead[1] = "FPL Dump Collected from: ".$flds[7];
			 $repHead[2] = "Collected on: ".$flds[11]." at ".$flds[14]." ".$flds[15];
		   } else {
			 @flds = split(/ +/,$line);
			 $repHead[0] = "SD2DC version: ".$flds[2];
			 $repHead[1] = "FPL Dump Collected from: ".$flds[8];
			 $repHead[2] = "Collected on: ".$flds[12]." at ".$flds[15]." ".$flds[16];
		   }
		}
	   #
	   # Capture activation and deactivation messages and corresponding partition
	   #
	   if ( $line =~ /SEND_PMI_TO_CPU/) {
		my @flds = split(/ +/, $line);
		($nparNum, $vparNum) = split(/:/, $flds[3]);
		if ($vparNum > $maxVparNum) { $maxVparNum = $vparNum; }
		
		# Check to see if this vparName has been seen yet!
		if ( ! value_in($flds[3],@vparNames)) {
			if ($#vparNames == -1 ) {
			   foreach my $i (0..14) {
				 $vparNames[$i] = " ";
				}
			}
			$vparNames[$vparNum-1] = $flds[3];
		}
		$delta[$vparNum-1]--;
		$coreDeAct[$vparNum-1]++;
		$numDeactivate++;
	   }
	   if ( $line =~ /CPU_OLA_SEND_TO_PARTITION/) {
		my @flds = split(/ +/, $line);
		($nparNum, $vparNum) = split(/:/, $flds[3]);
		$delta[$vparNum-1]++;
		$coreAct[$vparNum-1]++;
		$numActivate++;
	   }
	   if (($line =~ /CFW_PROCESSOR_CORE_DEACTIVATION_COMPLETE/)  
		|| ($line =~ /CFW_PROCESSOR_CORE_ACTIVATION_COMPLETE/)) {
		
		my @flds = split(/ +/, $line);
		$parString = $flds[3];
		($nparNum, $vparNum) = split(/:/, $flds[3]);
		
		# Check to see if this vparName has been seen yet!
		if ( ! value_in($flds[3],@vparNames)) {
		if ($#vparNames == -1 ) {
			   foreach my $i (0..14) {
				 $vparNames[$i] = " ";
				}
			}
			$vparNames[$vparNum-1] = $flds[3];
			#print "DEBUG:  vparNames = @vparNames\n";
		}
		
		# get the next line for date and time.
		$line2 = <FILE>;
		$line2 =~ s/\s*$//g;
		@flds = split(/ +/, $line2);
		$timeString = $flds[2];
		$dateString = $flds[1];
		$epochTime = epochtime($dateString, $timeString);

		# Check to see if this date has been seen yet!
		if ( ! value_in($dateString,@days)) {
			#foreach my $i (@coreAct) {
			#	$i = 0;
			#}
			$days[$#days+1] = $dateString;
			foreach  my $i (0..14) {
			   $coresByDay{$dateString}[$i] = 0;
			}
		}

		#  Now summarize the data into buckets for date and vPARs.
		$coresByDay{$dateString}[$vparNum-1] += $coreAct[$vparNum-1];
		$coreAct[$vparNum-1] = 0;
		#print "DEBUG: vparState = $#vparState, @vparState\n";
		for ( my $i = 0; $i <= $#vparState; $i++) {
		 $vparState[$i] += $delta[$i];
		}
		@delta = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

		#my $out_line = combine($epochTime, $dateString, $timeString, @vparState); 
		
		#print $fh $out_line,"\n";

	  }
	}

	# Total cores Activated
	my $sumAct = 0;
	foreach (@coreAct) {
		 $sumAct += $_;
	}

	# Total cores deactivated.
	my $sumDeAct = 0;
	foreach (@coreDeAct) {
		 $sumDeAct += $_;
	}
	
	print "+-------------------------------------------------------------------------+\n";
	print "Starting script:\t $0\n";
	print "Script Version: \t $Version\n";
	print "$repHead[0]\n";
	print "$repHead[1]\n";
	print "$repHead[2]\n\n";
	print "  Data Range from: $days[0]\n";
	print "    Data Range to: $days[$#days]\n";
	print "Core-Move History: $outCsvFileName\n";
	print "+-------------------------------------------------------------------------+\n\n";
	print "Total Cores Activated: $numActivate \t Total Cores Deactivated: $numDeactivate\n\n\n";

	# Fill in the Gaps of the vparNames
	my $vNum = 0;
	foreach (@vparNames) {
		$vNum++;
		if ($_ eq " ") {
		  $_ = "1:".$vNum;
		}
	}


	# Report Header
	print "\n\n\t\t\tCores Activated by Day/vPAR\n\n";
	printf("%12s,%5s,%5s,%5s,%5s,%5s,%5s,%5s,%5s,%5s,%5s,%5s,%5s,%5s,%5s,%5s,%10s\n", 
			 "Date/vPar->", @vparNames,"Day Total");
	my $checkSum =0;
	
	my $i;
	for $i (0 .. $#days) {
	   #print "DEBUG: day = $days[$i] \n";
	  
	   my @nums;
	   my $daySum = 0;
	   foreach my $vnum (0..14) {
		  $checkSum += $coresByDay{$days[$i]}[$vnum];
		  push(@nums,$coresByDay{$days[$i]}[$vnum]);
		  $daySum += $coresByDay{$days[$i]}[$vnum]
	   }
	   printf("%12s,%5d, %5d,%5d,%5d,%5d,%5d,%5d,%5d,%5d,%5d,%5d,%5d,%5d,%5d,%5d,%10d\n",$days[$i],@nums,$daySum);
	   #
	   # Print the number of core moves per partition on a daily basis.
	   my $out_line = combine($days[$i],@nums, $daySum); 
	   print $fh $out_line,"\n";
		if ( $i < $#days ) {
		  my ($m1, $d1, $y1) = split("/", $days[$i]);
		  my ($m2, $d2, $y2) = split("/", $days[$i+1]);
		  my $datediff = Date_to_Days($y2, $m2, $d2) - Date_to_Days($y1, $m1, $d1);
		  if ( $datediff > 1 ) {
			if ( $fillgaps ) {
				my @zeros = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
				my $edate = "";
				for my $dnum (1 ..($datediff-1)) {
				  my ($year, $month, $day) = Add_Delta_Days($y1, $m1, $d1, $dnum);
				  $edate = sprintf '%02d/%02d/%04d', $month, $day, $year;
				  printf("%12s %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %5d %10d\n",$edate,@zeros);
				  # Print this information on the CSV file, as well.
				  my $out_line = combine($edate,@zeros); 
				  print $fh $out_line,"\n";
				}
			} else {
					my $edate = "   ...";
					printf("%12s\n",$edate);
			}
		  }
		}
	}
	print "\n\nChecksum (should match Total Cores Activated) = $checkSum\n";
	print "Total records processed: $records\n";
}
exit;

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

sub write_headers {
  my ($title, $fh) = @_;
  my @Headers = ( "Date",
                  "v1", "v2", "v3", "v4", "v5", "v6", 
				  "v7", "v8", "v9", "v10", "v11", "v12", "v13", "v14", "v15", "Day.Sum"); 

  my $headerLine = combine(@Headers);
  #print $fh $title, "\n";
  print $fh $headerLine,"\n";

}

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

sub value_in {
    my($value, @array) = @_;
    foreach my $element (@array)
    {
        return 1 if $value eq $element;
    }
    return 0;
}

 __END__

=head1 report_fpl_coremoves

    report_fpl_coremoves - Using GetOpt::Long and Pod::Usage

=head1 SYNOPSIS

report_fpl_coremoves [--help] [--verbose] [--fillgaps] --fpl <fpl_file>[,<fpl_file>] ...

Options:
	--help       		brief help message
	--verbose|v			increases progress messages
	--fillgaps|fill|f 	report is filled in with contiguous dates
	--fpl				fpl file[,fpl file]...

=head1 OPTIONS

=over 8

=item B<-help>

    Print a brief help message and exits.

=back

=head1 DESCRIPTION

    B<report_fpl_coremoves> will read the given FPL (Forward Progress Logs) input file(s) and generate a table of core moves by each vpar in the complex per day.

=cut
  
