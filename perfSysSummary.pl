#!/usr/bin/perl -w
#
# perfSysSummary   PERL script to generate human-friendly storage report 
#                   based on bdf output as well as some summary statistics.
#
#	by James D. Reed (james.reed@hp.com)
#	December 21, 2013 
#
#
use strict;
use Time::Local;
use File::Basename;
use Pod::Usage;
use Getopt::Long;

# This is the magic to use my subroutine library in the ../lib directory
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(dirname abs_path $0).'/lib';
use MyTools qw(tStamp getComplexes);
#  Magic off

my $MemMB = 0;  

#
# Process Command Line Arguments
#
my %SharedStorage;
our $verbose = '';
our $detail  = '';
my @txtfiles = '';
my $help_opt = '';
my $sharedfh;
my $fh;

my $result = GetOptions('help' => \$help_opt, 'verbose|v' => \$verbose, 'detail|d' => \$detail);
@txtfiles = @ARGV;

pod2usage(1)  if ((@txtfiles == 0) && (-t STDIN));
if ($verbose) { print "Options: --verbose=$verbose  --detail=$detail @txtfiles"; }

if ($detail) {
   my $outSharedStorage = "ALL_SHARED.csv";

   open ($sharedfh, ">", $outSharedStorage) or 
	die "$0: cannot open $outSharedStorage.\n";


   # Print Headers on ALL_SHARED.csv 
   printf $sharedfh "Hostname, MemMB, Allocated ,Used    ,Available  ,Utilization,";  
   printf $sharedfh "Model, MachineID, MachineSN\n";  
}

my $outAllSystemsFileName = "SYS_SUMMARY.csv";

open (my $allfh, ">", $outAllSystemsFileName) or 
          die "$0: cannot open $outAllSystemsFileName.\n";

# Print Headers on SYS_SUMMARY Report File
printf $allfh "Hostname, Database, foPartner, Mem (MB), Alloc (GB),Used (GB),Avail (GB),Util (%),";  
printf $allfh "Model, MachineID, MachineSN\n";  


foreach (@txtfiles) {

   if ( $verbose ) { print tStamp()."$_ ... \n"; }
   open (BDF, $_) or die "Cannot open $_\n";
	
   my ($base, $path, $suffix) = fileparse($_,qr/\.[^.]*/);
   my $outCsvFileName = $base.".csv";
   $_ = $base;
   m/_/;
   my $hostname = $`;

	
   if ( $verbose && $detail ) { 
      print "Output will be written to: $outCsvFileName.\n\n"; 
   }
   if ( $detail ) {
      open ($fh, ">", $outCsvFileName) or 
             die "$0: cannot open $outCsvFileName.\n";
   }

   my ($FS, $Alloc, $Used, $Avail, $Util, $MountedOn);

   my ($AllocUn,  $UsedUn,  $AvailUn,  $UtilUn) = 0;
   my ($SharedAllocUn,  $SharedUsedUn,  $SharedAvailUn,  $SharedUtilUn) = 0;
   my ($AllocSum, $UsedSum, $AvailSum, $GlobUtil) = 0;
   my ($SharedAllocSum, $SharedUsedSum, $SharedAvailSum, $SharedGlobUtil) = 0;
   
   my $FS_head = "Filesystem";
   my $Alloc_head = "Allocated";
   my $Used_head  = "Used";
   my $Avail_head = "Free";
   my $Util_head = "Util";
   my $MountedOn_head = "Mounted On";
   my $modelString    = "";
   my $model          = "";
   my $machineID      = "";
   my $machineSN      = "";
   my $dbInstance     = "";
   my $foPartner      = "";

   if ($detail) { QuickSummary($fh); }

   RECORD: while(<BDF>) {
	  if ( $_ =~ /^Platform info:/) {
	        if (<BDF> =~ /(\".*\"$)/) {;
			$modelString = $1;
			$modelString =~ s/\"//g;
			my @flds = split(" ", $modelString);
                        $model = $flds[$#flds];
			if ( $model =~ /8s/ || $model =~ /16s/ ) {
                           $model = "SD2-".$model;
                        }
			#print "DEBUG: model = $model \n";
		}
		#print "DEBUG: modelString = $modelString \n";
		if ( <BDF> =~ /id number.=?\s*(.*$)/i ) {
			$machineID = $1;
		}
		#print "DEBUG: machineID = $machineID \n";
		if ( <BDF> =~ /serial number.=?\s*(.*$)/i ) {
			$machineSN = $1;
		}	
		#print "DEBUG: $hostname Machine Serial Number = $machineSN\n";
	  }
	  if ( $_ =~ /^Memory =/) {
	    my @memflds = split(" ",$_);
	    $MemMB = $memflds[2];
	    #print "DEBUG - MemMB = $MemMB \n";
	  }
	  if ( $_ =~ /^Memory:/ ) {
	    my @memflds = split(" ",$_);
	    $MemMB = $memflds[1];
	    #print "DEBUG - MemMB = $MemMB \n";
	  }
           
          
      last RECORD if $_ =~ m/BDF: /
   }

   # Skip to the beginning of the bdf output
   SKIP: while(<BDF>) {
	last SKIP if m/^Filesystem/;
      }

	if ($detail) {
	   #
	   #  Print report headers
	   #
	   printf $fh "%-16s,%10s,%10s,%10s,%5s,%-10s\n", 
       	      $FS_head, $Alloc_head, $Used_head, $Avail_head, $Util_head, 
     	      $MountedOn_head;

       	   printf $fh "%-16s,%10s,%10s,%10s,%5s,%-10s\n", 
  	      "----------", "---------", "----", "-----", "----", "----------";
   	}	
	my $num_recs = 0;
	REPORT: while(<BDF>) {
	   $num_recs++;
   	   next REPORT if $num_recs == 1;
	   last REPORT if /^\s/;
		
    	   my @flds = split(" ",$_);
		
	   # Take care of case where the filesystem and it's 
           # corresponding storage numbers are on two lines.
	   if ( $#flds+1 == 1 ) {
  	      $FS = $flds[0];
	      ($Alloc, $Used, $Avail, $Util, $MountedOn) = split(" ",<BDF>);
           } else {
	     ($FS, $Alloc, $Used, $Avail, $Util, $MountedOn) = split(" ",$_);
	   }
		
	   # Breakout summary statistics for shared and unshared (local) storage.
	   if ( $FS =~ m/:/ ){
     	      $SharedStorage{$FS} = $Alloc;
	      $SharedAllocSum += $Alloc;   
	      $SharedUsedSum  += $Used;    
	      $SharedAvailSum += $Avail;    
	   } else {
  	      $AllocSum += $Alloc;   
	      $UsedSum  += $Used;    
	      $AvailSum += $Avail;    
	   }
	   ($Alloc, $AllocUn) = getun($Alloc);
   	   ($Used, $UsedUn)  = getun($Used);
	   ($Avail, $AvailUn) = getun($Avail);
	 
	   if ($detail) {
	      printf $fh "%-16s,%8.2f%2s,%8.2f%2s,%8.2f%2s,%5s,%-15s\n", 
                      $FS,$Alloc,$AllocUn,$Used,		
		      $UsedUn,$Avail,$AvailUn,$Util,$MountedOn;
	   }
    }
      $dbInstance = "N/A";
      $foPartner  = "N/A";
      DBFIND: while(<BDF>) {
         if ($_ =~ /ora_pmon_/ ) {
            my @dbflds = split(" ",$_);
            foreach(@dbflds) {
               if ($_ =~ /ora_pmon_/) {
                  my @dbo = split("_",$_);
		  if ( $dbInstance eq "N/A" ) {
                     $dbInstance = $dbo[2];
                  } else {
                     $dbInstance = $dbInstance." | ".$dbo[2];
		  }
                  #print "DEBUG:  hostname, dbInstance:  $hostname $dbInstance \n";
		}
            }
	   }
           # Find Fail Over Partner
           if ($_ =~ /Base_Group/) {
              my @dbflds = split(" ",$_);
	      $foPartner = $dbflds[5];
	      if ( $foPartner eq $hostname ) {
                 $foPartner = $dbflds[3];
              }
       	      #print "DEBUG: hostname, foPartner: $hostname $foPartner \n";
           }             
          }

	#
	# Print Summary Information
	#

	# Calculate Local Storage Summary Statistics
    	$GlobUtil = $UsedSum/$AllocSum*100.0;
	($AllocSum, $AllocUn) = getun($AllocSum);
	($UsedSum, $UsedUn) = getun($UsedSum);
	($AvailSum, $AvailUn) = getun($AvailSum);
        if ($detail) {
	printf $fh "\n\n%-10s\n\n%30s %6.2f%2s\n%30s %6.2f%s\n%30s %6.2f%2s\n%30s %6.2f%2s\n",  
		"Local Storage Grand Totals:",
                      "Allocated:,", $AllocSum, $AllocUn,
                      "Used:,", $UsedSum, $UsedUn,
		      "Free:,", $AvailSum, $AvailUn,
		      "Local Storage Utilization:,", $GlobUtil, "% ";
	}

	# Calculate Shared Storage Summary Statistics
	if ( $SharedAllocSum > 0 ) {

		$SharedGlobUtil = $SharedUsedSum/$SharedAllocSum*100.0;
		($SharedAllocSum, $SharedAllocUn) = getun($SharedAllocSum);
		($SharedUsedSum, $SharedUsedUn) = getun($SharedUsedSum);
		($SharedAvailSum, $SharedAvailUn) = getun($SharedAvailSum);

		if ($detail) {
		   printf $fh "\n\n%-10s\n\n%30s %6.2f%2s\n%30s %6.2f%s\n%30s %6.2f%2s\n%30s %6.2f%2s\n",  
			"Shared Storage Grand Totals:",
			  "Allocated:,", $SharedAllocSum, $SharedAllocUn,
			  "Used:,", $SharedUsedSum, $SharedUsedUn,
			  "Free:,", $SharedAvailSum, $SharedAvailUn,
			  "Shared Storage Utilization:,", $SharedGlobUtil, "% ";

		}
	}

	# Print Summary to $outAllSystemsFileName in Records Suitable for 
        # copy/paste into spreadsheet row.
	printf $allfh "%-10s, %-10s, %-10s, %10.0f,%6.2f,%6.2f,%6.2f,%6.2f,%s,%s,%s\n",
               $hostname, $dbInstance, $foPartner, $MemMB, $AllocSum, 
               $UsedSum, $AvailSum, $GlobUtil/100, $model, $machineID, 
               $machineSN;

	if ( $SharedAllocSum > 0 ) {
	   if ($detail) {
	      # Print Summary to $outAllSystemsFileName in Records Suitable for 
              # copy/paste into spreadsheet row.
	      printf $sharedfh "%-10s,%6.2f,%6.2f,%6.2f,%6.2f,%s,%s,%s\n",
	          $hostname, $SharedAllocSum, $SharedUsedSum, $SharedAvailSum, 
                  $SharedGlobUtil/100, $model, $machineID, $machineSN;


	      close $fh;
	   }
	}

}
close $allfh;
if ($detail) {
	close $sharedfh;
}
exit;

sub getun {

   my $val = shift(@_);
   my $Unit = "KB";
   #print "DEBUG (getun): val = $val \n";
   if ( $val < 1024) {
      return ($val, $Unit);
   } 

   if ( $val < 1024*1024 ) {
       $Unit = "MB";
       return ($val/1024, $Unit);
   }

   $Unit = "GB";
   return ($val/1024/1024, $Unit);

}

sub QuickSummary {

	my $fh = shift(@_);
   SKIPEM: while(<BDF>) {
      last SKIPEM if $_ =~ m/Hostname: /
   }

   chomp($_);
   my ($title, $value) = split /:/, $_;
   print $fh "\n\n$title:, $value\n";
   
   SUMM: while(<BDF>) {
    last SUMM if /^\s*$/;
    chomp;
	my ($title, $value) = split /:/, $_;
	print $fh "$title:, $value\n";
   }
   print $fh "\n\n";

   # Print Headers on ALL_SHARED Report File
   #printf $sharedfh "%-60s,%12s\n", "File System", "Allocated (GB)";  
   #while (my ($k,$v)=each %SharedStorage){printf $sharedfh "%-60s,%12.2f\n", $k, $v/1024/1024}
}


 __END__

=head1 quick_summary.pl

    quick_summary.pl - Using GetOpt::Long and Pod::Usage

=head1 SYNOPSIS

quick_summary.pl [--help] [--verbose] <txt_file_containing_BDF> ...

Options:
	--help       		brief help message
	--verbose|v			increases progress messages
	txt_files			contains BDF and system summary information.

=head1 OPTIONS

=over 8

=item B<-help>

    Print a brief help message and exits.

=back

=head1 DESCRIPTION

    B<quick_summary.pl> will read the given TXT file generated by 
	collect_mwalogs.pl and generate a CSV file containg a quick 
	summary of the system and a table of filessystems (local and shared).


=cutquick
