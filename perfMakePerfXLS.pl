#!/usr/local/bin/perl -w
#
# perMakePerfXLS.pl  PERL script to create an Excel spreadsheet con-
#	taining the individual performance summaries for MWA.
#
#
#	by James D. Reed (james.reed@hp.com)
#	January 8, 2010
#
#	Modifications:
#	Date			Description
#	10-May-2013 	Added metrics for CPU, Memory and Disk to better 
#                       diagnose bottlenecks and overall utilization.
#
#
use strict;
use Spreadsheet::WriteExcel;
use File::Basename;
use Text::CSV_XS;
use Cwd;


# 
# Process Command Line Arguments
#
my $numargs = $#ARGV + 1;
if ( $numargs < 2 ) {
	print "Usage: $0 xls_file_name CSV_dir\n";
	exit;
}

our ($xls_name, $CSVDIR) = @ARGV;

my $wb = Spreadsheet::WriteExcel->new($xls_name);

set_properties($wb,"James D. Reed (james.reed\@hp.com)");

#
#  Get list of CSV files
#
my $cwd = getcwd();
opendir (DIR,$CSVDIR) or 
	die "Cannot open $CSVDIR: $!\n";
my @csvlist = grep /\.csv$/, readdir(DIR);
close(DIR);


# 
# Insert Summary Worksheet
#
my $sheetname = "Summary";
my $ws = make_worksheet($wb, $sheetname);
write_summ_headers($wb,$ws);

my @CSV = sort @csvlist;

foreach my $csvFileName (@csvlist)
{
   my ($sheetname, $path, $suffix) = fileparse($csvFileName,qr/\.[^.]*/);
   my $ws = make_worksheet($wb, $sheetname);
   my $lastRow;
   
   print "\tFile: $csvFileName";
   my $start = time;
   my $skipRecs = countRecs($csvFileName);
   write_perf_headers($wb,$ws);
   $lastRow = copy_csv_to_xls($CSVDIR."/".$csvFileName, $wb, $ws, $skipRecs);
   if ( $lastRow > 65536 ) { $lastRow = 65536; }
   insert_formulae($wb,$ws,$lastRow);
   my $elapsed = time - $start;
   print ":\t$elapsed sec.\n";

}

exit;


sub copy_csv_to_xls {
   my ($csvfn, $wb, $ws, $skipRecs) = @_;

   my $date_fmt = $wb->add_format(num_format => 'yyyy-mm-dd');
   my $num_fmt = $wb->add_format(num_format => '#,##0.00');
   my $num2_fmt = $wb->add_format(num_format => '#,##0');
   my $skipem = $skipRecs;

   open (CSVFILE, $csvfn) or 
		die "Cannot open $csvfn\n";;

   my $csv = Text::CSV_XS->new;

   # Row and column are zero indexed
   my $row_offset = 0;
   my $row = 0;
   RECORD: while (<CSVFILE>) {
      if ($csv->parse($_) ) {
        my @Fld = $csv->fields;
        if ( $skipem > 0 && $row > 0 ) {
           $skipem--;
           next RECORD;
        }
        my $col = 0;
        if ($row == 0 || $row > 3 ) {
           if ($row == 4 ) {
              $row = 12;
           }
           foreach my $token (@Fld) {
		       #print ("DEBUG:  $row, $col, token = $token \n");
			   if ( $token eq "")  { $row++; next RECORD; }
               if ( $row == 0 ) {
                  $ws->write($row,$col,$token); 

               } else {
				  if    ( $col == 0 ) { 
					$ws->write_date_time($row,$col,mdate($token), $date_fmt); }

				  elsif ( $col == 1 ) { 
					$ws->write($row,$col,$token); }                                 # TIME

				  elsif ( $col == 2 || $col == 3 || $col == 4 ||  $col == 5  || $col == 6 ) { 
					$ws->write_number($row,$col,$token,$num_fmt); }

				  elsif ( $col == 7  || $col == 8 ) {                               # Active CPUs and Interrupts
					$ws->write_number($row,$col,$token,$num2_fmt); }
				
				  elsif ( $col == 9 ) {                                             # Run Queue
					$ws->write_number($row,$col,$token,$num_fmt); }
					
				  elsif ( $col == 10 || $col == 11 || $col == 12 || $col == 13 ) {  # Alive Processes, Active Proc, SysCall, SysCall Rate
					$ws->write_number($row,$col,$token,$num2_fmt); }

				  elsif ( $col > 13 ) {
					$ws->write_number($row,$col,$token,$num_fmt); }
	   
				  else  {  $ws->write($row, $col, $token); }
               }
			
               $col++;
           }
        }
        $row++;
    }
    else {
        my $err = $csv->error_input;
        print "Text::CSV_XS parse() failed on argument: ", $err, "\n";
    }
   
   }
   close(CSVFILE);
   return $row;
}

sub make_worksheet {
  my ($workbook, $worksheet_name) = @_;
  my $worksheet = $workbook->add_worksheet($worksheet_name);
  return $worksheet;
}
 
sub set_properties {

   my ($workbook,$author) = @_;

   $workbook->set_properties(
      title    => 'Measureware performance data summary.',
      subject  => 'MWA Performance by System',
      author   => $author,
      manager  => 'James Pendergrass james.pendergrass@hp.com',
      company  => 'Hewlett-Packard Company',
      category => 'Confidential',
      keywords => '',
      comments => 'Created with Perl and Spreadsheet::WriteExcel',);
    return;
}

sub insert_formulae {

   my ($wb, $ws, $lastRow) = @_;
   my $col = 1;
   my $row = 3;
   my $formula;

   my $num_fmt = $wb->add_format(num_format => '#,##0.00');
   my $num2_fmt = $wb->add_format(num_format => '#,##0');
   my $date_fmt = $wb->add_format(num_format => 'yyyy-mm-dd');

   foreach my $d (  'A', 'C', 'D', 'E', 'F', 'G', 'H', 
		'I', 'J', 'K', 'L', 'M' , 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W') {
      #  Minimum, row = 3, col = 1
      $row = 3;
      $formula = build_formula_string('MIN',$d,$lastRow);
      if ( $col == 1 ) {
         $ws->write_formula($row++, $col, $formula, $date_fmt);
      } elsif ( $col == 6 || $col == 7 || $col == 9 ) {
         $ws->write_formula($row++, $col, $formula, $num2_fmt);
      } else {
         $ws->write_formula($row++, $col, $formula, $num_fmt);
      }

      # Maximum
         $formula = build_formula_string('MAX',$d,$lastRow);
      if ( $col == 1 ) {
         $ws->write_formula($row++, $col, $formula, $date_fmt);
      } elsif ( $col == 6 || $col == 7 || $col == 9 ) {
         $ws->write_formula($row++, $col, $formula, $num2_fmt);
      } else {
         $ws->write_formula($row++, $col, $formula, $num_fmt);
      }


      # Number of Days/Average
      if ( $col == 1 ) {
         $ws->write_formula(  5, 1, '=B5-B4', $num2_fmt);
      } else {
         $formula = build_formula_string('AVERAGE',$d,$lastRow);
         $ws->write_formula($row++, $col, $formula, $num_fmt); 
      }


      if ( $col != 1 ) {

         # Std Deviation
         $formula = build_formula_string('STDEV',$d,$lastRow);
         $ws->write_formula($row++, $col, $formula, $num_fmt);

         # 90th Percentile
         $formula = build_perc_formula_string($d,$lastRow,0.90);
         $ws->write_formula($row++, $col, $formula, $num_fmt);

         # 95th Percentile
         $formula = build_perc_formula_string($d,$lastRow,0.95);
         $ws->write_formula($row++, $col, $formula, $num_fmt);

         # 98th Percentile
         $formula = build_perc_formula_string($d,$lastRow,0.98);
         $ws->write_formula($row++, $col, $formula, $num_fmt);
      }


      $col++;
   }

   #
   # Insert formulas for "# Cores @ CPU%"
   #
   $col = 23;
   for ( $row = 3; $row <= 9; $row++ ) {
      my $addr = $row + 1;
      $formula = "=G".$addr."*H5/100";
      ##print "DEBUG: row,col = $row,$col formula = $formula\n";
      $ws->write_formula($row, $col, $formula, $num_fmt);
   }
}
 
sub build_formula_string {

   my ($oper, $let, $last) = @_;
   my $formula_strng;


   $formula_strng = '='.$oper.'('.$let.'13:'.$let.$last.')';
   return $formula_strng;

}

sub build_perc_formula_string {

   my ($let, $last,$perc) = @_;
   my $formula_strng;
   my $oper = 'PERCENTILE';


   $formula_strng = '='.$oper.'('.$let.'13:'.$let.$last.','.$perc.')';
   return $formula_strng;

}


sub write_perf_headers {

   my ($wb, $ws) = @_;
   my $row;
   my $col;

   my $light_blue  = $wb->set_custom_color(40, 149, 179, 215);
   my $clear_color = $wb->set_custom_color(41,   0,   0,   0);

   # Set up some formats
   my %heading         =   (
                               bold        => 0,
                               font        => 'Arial Unicode MS',
                               pattern     => 0,
                               fg_color    => $light_blue,
                               border      => 1,
                               align       => 'center',
			       text_wrap   => 1,
			       valign      => 'center',
                           );
   my %standard        =   (
                               bold        => 0,
                               font        => 'Arial Unicode MS',
                               border      => 1,
                               align       => 'left',
			       text_wrap   => 1,
			       valign      => 'bottom',
                           );

   my %total           =   (
                           bold        => 1,
                           font        => 'Arial Unicode MS',
                           top         => 1,
                           num_format  => '$#,##0.00'
                           );

   my $heading         = $wb->add_format(%heading);
   my $standard        = $wb->add_format(%standard);
   my $total_format    = $wb->add_format(%total);
   my $price_format    = $wb->add_format(num_format => '$#,##0.00');
   my $date_format     = $wb->add_format(num_format => 'mmm d yyy');

# Set Column Widths
   $ws->set_column( 0,  0, 20);
   $ws->set_column( 1,  6, 10);
   $ws->set_column( 7,  7, 14);
   $ws->set_column( 8,  9, 10);
   $ws->set_column(10, 10, 12);
   $ws->set_column(11, 11, 10);
   $ws->set_column(12, 13, 14);
   $ws->set_column(14, 14, 10);



   $row = 2;
   $col = 0;
   $ws->write($row,$col++, "Statistics               ", $heading);
   $ws->write($row,$col++, "Date                     ", $heading);
   $ws->write($row,$col++, "User\nCPU \%             ", $heading);
   $ws->write($row,$col++, "System\nCPU \%           ", $heading);
   $ws->write($row,$col++, "Intrpt\nCPU \%           ", $heading);
   $ws->write($row,$col++, "SYSCALL\nCPU \%          ", $heading);
   $ws->write($row,$col++, "CPU \%                   ", $heading);
   $ws->write($row,$col++, "Active\nCPUs             ", $heading);
   $ws->write($row,$col++, "Interrupts               ", $heading);
   $ws->write($row,$col++, "Run\nQueues              ", $heading);
   $ws->write($row,$col++, "Alive\nProcesses         ", $heading);
   $ws->write($row,$col++, "Active\nProcesses        ", $heading);
   $ws->write($row,$col++, "SysCall                  ", $heading);
   $ws->write($row,$col++, "SysCall\nRate            ", $heading);
   $ws->write($row,$col++, "Memory \%                ", $heading);
   $ws->write($row,$col++, "Pg Out\nRate             ", $heading);
   $ws->write($row,$col++, "Swap Out\nRate           ", $heading);
   $ws->write($row,$col++, "Memory\nQueue            ", $heading);
   $ws->write($row,$col++, "Disk Phys\nIO Rate       ", $heading);
   $ws->write($row,$col++, "Disk Phys\nKB Rate       ", $heading);
   $ws->write($row,$col++, "Disk Request\nQueue      ", $heading);
   $ws->write($row,$col++, "Network\nInput Pkt\nRate ", $heading);
   $ws->write($row,$col++, "Network\nOutput Pkt\nRate", $heading);
 
  
   $ws->write($row,$col++, "\# Cores\n\@ CPU \%      ", $heading);

   $row = 11;
   $col = 0;
   $ws->write($row,$col++, "Date                     ", $heading);
   $ws->write($row,$col++, "Time                     ", $heading);
   $ws->write($row,$col++, "User\nCPU \%             ", $heading);
   $ws->write($row,$col++, "System\nCPU \%           ", $heading);
   $ws->write($row,$col++, "Intrpt\nCPU \%           ", $heading);
   $ws->write($row,$col++, "SYSCALL\nCPU \%          ", $heading);
   $ws->write($row,$col++, "CPU \%                   ", $heading);
   $ws->write($row,$col++, "Active\nCPUs             ", $heading);
   $ws->write($row,$col++, "Interrupts               ", $heading);
   $ws->write($row,$col++, "Run\nQueues              ", $heading);
   $ws->write($row,$col++, "Alive\nProcesses         ", $heading);
   $ws->write($row,$col++, "Active\nProcesses        ", $heading);
   $ws->write($row,$col++, "SysCall                  ", $heading);
   $ws->write($row,$col++, "SysCall\nRate            ", $heading);
   $ws->write($row,$col++, "Memory \%                ", $heading);
   $ws->write($row,$col++, "Pg Out\nRate             ", $heading);
   $ws->write($row,$col++, "Swap Out\nRate           ", $heading);
   $ws->write($row,$col++, "Memory\nQueue            ", $heading);
   $ws->write($row,$col++, "Disk Phys\nIO Rate       ", $heading);
   $ws->write($row,$col++, "Disk Phys\nKB Rate       ", $heading);
   $ws->write($row,$col++, "Disk Request\nQueue      ", $heading);
   $ws->write($row,$col++, "Network\nInput Pkt\nRate ", $heading);
   $ws->write($row,$col++, "Network\nOutput Pkt\nRate", $heading); 
 

   $row = 3;
   $col = 0;
   $ws->write($row++,$col, "Minimum                  ", $standard);
   $ws->write($row++,$col, "Maximum                  ", $standard);
   $ws->write($row++,$col, "\# Days/Average          ", $standard);
   $ws->write($row++,$col, "Std Deviation            ", $standard);
   $ws->write($row++,$col, "90th Percentile          ", $standard);
   $ws->write($row++,$col, "95th Percentile          ", $standard);
   $ws->write($row++,$col, "98th Percentile          ", $standard);

}

sub write_summ_headers {

   my ($wb, $ws) = @_;
   my $r;
   my $c;

   my $light_blue  = $wb->set_custom_color(40, 149, 179, 215);
   my $clear_color = $wb->set_custom_color(41,   0,   0,   0);

   # Set up some formats
   my %heading         =   (
                               bold        => 0,
                               font        => 'Arial Unicode MS',
                               pattern     => 0,
                               fg_color    => $light_blue,
                               border      => 1,
                               align       => 'center',
			       text_wrap   => 1,
			       valign      => 'center',
                           );
   my %standard        =   (
                               bold        => 0,
                               font        => 'Arial Unicode MS',
                               border      => 1,
                               align       => 'left',
			       text_wrap   => 1,
			       valign      => 'bottom',
                           );

   my %total           =   (
                           bold        => 1,
                           font        => 'Arial Unicode MS',
                           top         => 1,
                           num_format  => '$#,##0.00'
                           );

   my $hdg             = $wb->add_format(%heading);
   my $standard        = $wb->add_format(%standard);
   my $total_format    = $wb->add_format(%total);
   my $price_format    = $wb->add_format(num_format => '$#,##0.00');
   my $date_format     = $wb->add_format(num_format => 'mmm d yyy');

# Set Column Widths
   $ws->set_column( 0,  0, 20);
   $ws->set_column( 1,  6, 10);
   $ws->set_column( 7,  7, 14);
   $ws->set_column( 8,  9, 10);
   $ws->set_column(10, 10, 12);
   $ws->set_column(11, 11, 10);
   $ws->set_column(12, 13, 14);
   $ws->set_column(14, 28, 10);



   $r = 1;
   $c = 0;
   $ws->write($r,$c++, "System                   ",            $hdg); # A
   $ws->write($r,$c++, "Start Date               ",            $hdg); # B
   $ws->write($r,$c++, "End Date                 ",            $hdg); # C
   $ws->write($r,$c++, "Days                     ",            $hdg); # D
   $ws->write($r,$c++, "Active\nCPUs             ",            $hdg); # E
   $ws->write($r,$c++, "Average\nRun\nQueue      ",            $hdg); # F
   $ws->write($r,$c++, "Average\nAlive\nProcesses",            $hdg); # G
   $ws->write($r,$c++, "Average\nActive\nProcesses",           $hdg); # H
   $ws->write($r,$c++, "Average\nUser\nCPU %     ",            $hdg); # I
   $ws->write($r,$c++, "Average\nSystem\nCPU %   ",            $hdg); # J
   $ws->write($r,$c++, "Average\nIntrpt\nCPU %   ",            $hdg); # K
   $ws->write($r,$c++, "Average\nCPU %           ",            $hdg); # L
   $ws->write($r,$c++, "Minimum\nCPU %           ",            $hdg); # M
   $ws->write($r,$c++, "Maximum\nCPU %           ",            $hdg); # N
   $ws->write($r,$c++, "90th\nPercentile\nCPU %  ",            $hdg); # O
   $ws->write($r,$c++, "95th\nPercentile\nCPU %  ",            $hdg); # P
   $ws->write($r,$c++, "98th\nPercentile\nCPU %  ",            $hdg); # Q

   $ws->write($r,$c++, "Minimum\nDisk Phys\nKB Rate",          $hdg); # R
   $ws->write($r,$c++, "Maximum\nDisk Phys\nKB Rate",          $hdg); # S
   $ws->write($r,$c++, "Average\nDisk Phys\nKB Rate",          $hdg); # T
   $ws->write($r,$c++, "90th\nPercentile\nDisk Phys\nKB Rate", $hdg); # U

   $ws->write($r,$c++, "Minimum\nMemory\nUtil % ",             $hdg); # V
   $ws->write($r,$c++, "Maximum\nMemory\nUtil % ",             $hdg); # W
   $ws->write($r,$c++, "Average\nMemory\nUtil % ",             $hdg); # X
   $ws->write($r,$c++, "90th\nPercentile\nMemory\nUtil %",     $hdg); # Y

   $ws->write($r,$c++, "Maximum\nNetwork\nInput Pkt\nRate",    $hdg); # Z
   $ws->write($r,$c++, "Average\nNetwork\nInput Pkt\nRate",    $hdg); # AA
   $ws->write($r,$c++, "90th Pct\nNetwork\nInput Pkt\nRate",   $hdg); # AB
    
   $ws->write($r,$c++, "Maximum\nNetwork\nOutput Pkt\nRate",   $hdg); # AC
   $ws->write($r,$c++, "Average\nNetwork\nOutput Pkt\nRate",   $hdg); # AD
   $ws->write($r,$c++, "90th Pct\nNetwork\nOutput Pkt\nRate",  $hdg); # AE


}

sub mdate {
   my ($token) = @_;
   my ($mnth, $day, $yr);
   my $newdate;	
   ($mnth, $day, $yr) = split("/",$token);

   $newdate = $yr."-".$mnth."-".$day."T";
   return $newdate;
}


sub countRecs {
   my ($fileName) = @_;
   my $count = 0;
   my $detail = 0;
   my $skipRecs = 0;
   open (my $FILE, "<", $CSVDIR."/".$fileName) or 
		die "cannot open file $fileName $! \n";
   
   $count++ while<$FILE>;
   close($FILE);

   #
   # Calculate the number of records to skip to accommodate Excel limit of 65536
   #
   $detail = $count - 4;
   if ( $detail + 12 > 65536 ) {
      $skipRecs = ($detail + 12) - 65536;
      #print "     WARNING: $detail detail records, ", 
      #             "$skipRecs will be skipped to accomodate Excel \n",
      #      "            limit of 65536 rows per worksheet. \n";
   }
   return $skipRecs;
}
exit;


