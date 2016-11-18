#!/usr/bin/perl -w
#
# <collect_mwalogs-v5.pl> - script to collect MWA logs and parm file in gziped 
#                    tar file.  This data are used to assess performance and
#                    and to size upgrade alternatives.
#                    December 1, 2009 - rewrote script in Perl and added
#                    collection of configuration information.
#
#                    The resultant file should be uploaded to the ftp site 
#                    provided by HP.
#       
#
#  Contributions from both David Totsch and Stephen Ciullo, many thanks.
#
#  December 2, 2009 Jim Reed (james.reed@hp.com).
#  December 3, 2009 - added logic for HP-UX 11i v1 to collect_sysdata.
#  September 24, 2012 - V2: enhanced text data collection.  
#  September 30, 2013 - v5: Added argument for log file and non-default placement for tarball.
#

use strict;
use Sys::Hostname;
use Time::localtime;
use Pod::Usage;
use Getopt::Long;


#
# Process Command Line Arguments
#
our $verbose = '';
my $dest     = '';
my $help_opt = '';
my $log      = '';

my $result = GetOptions('help' => \$help_opt, 'verbose|v' => \$verbose, 'log|l' => \$log, 'destination|d=s' => \$dest );
if ( $dest eq '' ) {
	$dest = "/tmp";
}


if ($verbose) { print "Options: --verbose=$verbose --log=$log --destination=$dest\n"; }

if (-w $dest) {
   if ( $verbose ) { print "Destination directory $dest is writable ...\n"; }
} else {
   print "***** WARNING: Destination directory $dest is not writable.  Switching destination to default, /tmp \n";
   $dest = "/tmp";
}

my $host = hostname();
my $tm = localtime;
my ($day, $month, $year) = ($tm->mday, $tm->mon, $tm->year);
$year = $year + 1900;
$month = $month + 1;

my $today  = $year . "-" . $month . "-" . $day;

my $TARFILE = $host . "_" . $today . "_mwalogs.tar.gz";
my $TMPDIR = $host . "_" . $today;
if ($log ) {
  my $LOGFILE = $dest . "/" . $host . "_" . $today . "_mwalogs.log";
  if ($verbose) { print "LOGFILE = $LOGFILE \n"; }
  open (STDOUT, "| tee -ai $LOGFILE");
}

print "-------------------------------------------------------------------------------\n";
printf ("Starting script:\t %s \n", $0);
printf ("Hostname:       \t %s \n", $host);
printf ("Tarball:        \t %s \n",$TARFILE);
printf ("Tarball path:   \t %s/%s \n", $dest, $TARFILE);
 my $start = qx{date};
printf ("Start time/date:\t %s \n", $start);
my $start_time = time;

#
#  Before we go much further, let's check the space available in 
#  /var/tmp to make sure there is room for our log files.  If there
#  isn't room, an ERROR message will be printed and this script will
#  terminate.
#

if ( -r "/var/opt/perf/datafiles") {
    #print "Checking space available in /var/tmp ...\n";
    chkspace();
    #print "We have enough space, let's get to work.\n\n";
} else {
    print "Warning, Measureware log files are not available on this system.\n";
    print "Only system configuration will be included.\n";
}

mkdir "/var/tmp/" . $TMPDIR, 0700 or die "cannot mkdir $TMPDIR: $!";

#  
#  Collect System data and put this text file into our temporary directory.
#
chop (my $OSTYPE = `uname`);

#print "DEBUG: OSTYPE = $OSTYPE \n\n";

if ( $OSTYPE ne "Linux") {
   print "Collecting system configuration information ...\n";
   my $sysdata = collect_sysdata();
   system("cp $sysdata /var/tmp/$TMPDIR");
   system("rm $sysdata");
   print "Collecting system configuration information complete.\n\n";
}

#
# Now copy the parm file and log files into our temporary directory
#
if ( -r "/var/opt/perf/datafiles") {
    print "Copy parm and log files to /var/tmp/${TMPDIR} ...\n";
    system("cp /var/opt/perf/parm /var/tmp/$TMPDIR");

    opendir(DIR,"/var/opt/perf/datafiles/") or 
	    die "Cannot open /var/opt/perf/datafiles \n";

    my @files = grep /^log/, readdir(DIR);
    close(DIR);
    
    foreach my $file (@files) {
       #print "Copying file $file ... \n";
       system("cp /var/opt/perf/datafiles/$file /var/tmp/$TMPDIR");
    }
    print "Copy complete. \n\n";
}

if (-r "/var/opt/gwlm") {
    mkdir "/var/tmp/$TMPDIR/gwlm" , 0700 or 
                            die "cannot mkdir $TMPDIR/gwlm: $!";
    #print "Copy /var/opt/gwlm to /var/tmp/${TMPDIR}/gwlm ...\n";
    system("cp -r /var/opt/gwlm /var/tmp/$TMPDIR/gwlm");
    #print "Copy complete. \n\n";
}

chdir("/var/tmp/$TMPDIR");
if ($verbose) { print "Tar/gzip /var/tmp/$TMPDIR to /tmp/$TARFILE ... \n"; }
system("tar cf - . | /usr/contrib/bin/gzip -c > $dest/$TARFILE");
if ($verbose) { print  "Tar/gzip complete. \n"; }

#
#  Cleanup
#
chdir("/var/tmp");
system("rm -rf $TMPDIR");

if ( -r "/var/opt/perf/datafiles") {
    print "Logs and parm copied to file: $dest/$TARFILE \n";
} else {
    print "Configuration data is in file: $dest/$TARFILE \n";
}

system("ls -l $dest/$TARFILE");

   
my $end_date = qx{date}; chomp($end_date);
my $elapsed = time - $start_time;
print "\n$0 complete $end_date in $elapsed seconds.\n";
print "-------------------------------------------------------------------------------\n";
if ($log) { close(STDOUT); }
exit;

sub collect_sysdata {
#
# <collect_sysdata> - Perl script that runs various configuration queries
#                     and appends these to a text file.  Commands can be
#                     added by simply making additional calls to the 
#                     logit() function using the full path of the command
#                     and required arguments.
#
#                     Based on SYSDATA_082906 script by Stephen Ciullo.
#
#     December 1, 2009 Jim Reed (james.reed@hp.com)
#

   use strict;
   use Sys::Hostname;
   use Time::localtime;

   my $host   = hostname();
   my $tm = localtime;
   my ($day, $month, $year) = ($tm->mday,$tm->mon, $tm->year);
   $year = $year + 1900;
   $month = $month + 1;
   my $today  = $year . "-" . $month . "-" . $day;
   my $log    = "/tmp/" . $host . "_sysdata_" . $today . ".txt";

#
#  Let's determine what version of HP-UX we have.
#
   my $uxver = `uname -r`;
   chop($uxver);

   open(my $logfh, "> $log") or die "Cannot open $log \n";

#
#   Quick System Overview
#
   print $logfh "*******************************************************************************\n"; 
   print $logfh "                    Quick System Overview". "\n";
   print $logfh "*******************************************************************************\n"; 
   my $ncpus=`ioscan -k|grep processor|wc -l`;
   my $ndisk=`ioscan -k|grep disk|wc -l`;
   my $OEName = " ";
   my $OEVer  = " ";

   $_ = qx{swlist -l bundle};
   if (/(HPUX.*-.*-OE).*(B.\d{2}.\d{2}.\d{4})/  or
       /(HPUX.*-OE-\w+).*(B.\d{2}.\d{2}.\d{4})/ or
       /(HPUX.*-OE).*(B.\d{2}.\d{2}.\d{4})/     or
       /(HPUXBase).*(B.*\d{2}.\d{2}.\d{4})/ )
   {
       $OEName = $1;
       $OEVer = $2;
   } else {
       $OEName = "*****";
       $OEVer =  "*****";
   }
   
   print $logfh "\n"; 
   print $logfh "              Hostname: ".`hostname 2>&1`;
   print $logfh "                 Model: ".`model 2>&1`;
   print $logfh "        # CPUs (cores): ".$ncpus;
   print $logfh "       Processor Speed: ".&getspeed()."\n";
   print $logfh "                Memory: ".&getmem()."\n";
   print $logfh "               # Disks: ".$ndisk;
   print $logfh "              HP-UX OE: ".$OEName."\n";
   print $logfh "         HP-UX Version: ".$OEVer."\n";
   print $logfh " Machine Serial Number: ".&getsn()."\n";
   print $logfh "\n\n\n"; 


   logit($logfh, "Date", "/usr/bin/date");
   logit($logfh, "Model", "/usr/bin/model");
   logit($logfh, "Full uname", "/usr/bin/uname -a");
   logit($logfh, "Machine Info", "/usr/contrib/bin/machinfo -v");
   logit($logfh, "Performance Utility", "/opt/perf/bin/utility -xs");
   logit($logfh, "Parstatus (if available)", "/usr/sbin/parstatus 2>/dev/null");
   logit($logfh, "Virtual Partition Status", "/usr/sbin/vparstatus ");
   logit($logfh, "Sysdef", "/etc/sysdef");
   logit($logfh, "System", "cat /stand/system");
   logit($logfh, "Fstab", "cat /etc/fstab");
   logit($logfh, "Mount", "/etc/mount");
   logit($logfh, "BDF", "/usr/bin/bdf");
   logit($logfh, "IPCS", "/usr/bin/ipcs -ma");
   logit($logfh, "IOSCAN", "/usr/sbin/ioscan -fn");

   my $dirname = " ";
   if ( "$uxver" eq "B.11.31" ) {
       $dirname = "/dev/rdisk";
   } else {
       $dirname = "/dev/rdsk";
   }
   logit($logfh, "Diskinfo", "/usr/bin/ls -l $dirname");
   opendir(DDIR,$dirname) or 
       die "Cannot open $dirname.\n";

   my @disks = readdir(DDIR);
   @disks = sort(@disks);
   
   foreach my $d (@disks) {
       next unless ( -c "$dirname/$d");
       #print "DEBUG Diskinfo $d\n";
       my $dout = qx{/usr/sbin/diskinfo "$dirname/$d" 2>/dev/null};
       print $logfh $dout;
   }
   close(DDIR);
   
   logit($logfh, "Swapinfo", "/usr/sbin/swapinfo -t");
 
   if ( "$uxver" eq "B.11.11" ) {
	# No known equivalent.
   } elsif ( "$uxver" eq "B.11.23" ) {
       logit($logfh, "INTCTL", "/usr/contrib/bin/intctl");
   } elsif ( "$uxver" eq "B.11.31" ) {
       logit($logfh, "INTCTL", "/usr/sbin/intctl");
   } else {
	print "Warning unrecognized HP-UX Version.\n\n";
   }

   logit($logfh, "Parm File", "cat /var/opt/perf/parm");
   logit($logfh, "DMESG", "/usr/sbin/dmesg");
   logit($logfh, "Detailed Volumegroups", "/usr/sbin/vgdisplay -v");

   if ( "$uxver" eq "B.11.11" ) {
       logit($logfh, "kmtune System Parameters", "/usr/sbin/kmtune");
   } elsif ( "$uxver" eq "B.11.23" ) {
       logit($logfh, "kctune System Parameters", "/usr/sbin/kctune");
   } elsif ( "$uxver" eq "B.11.31" ) {
       logit($logfh, "Kctune System Parameters", "/usr/sbin/kctune");
   } else {
	print "Warning unrecognized HP-UX Version.\n\n";
   }

   logit($logfh, "Registered SW Depots", 
                    "swlist -l depot 2>/dev/null|grep -v Initiali");
   logit($logfh, "Installed software", "swlist|tail +6");
   logit($logfh, "Installed Filesets", "swlist -l fileset|tail +6");
   logit($logfh, "Software Installation Date", 
                     "swlist -a date -a title -a revision|tail +6");
   logit($logfh, "Last Software Jobs", "swjob | tail");
#
#  Get files in in directory /etc/opt/gwlm/conf if it exists.
#
   my $gwlm_conf_dir = "/etc/opt/gwlm/conf";
   opendir (GDIR,$gwlm_conf_dir);

   while (my $file = readdir GDIR) {
      next if $file =~ /^\.\.?$/;   # skip . and ..
      #print "Processing $file ...\n";
      logit($logfh, "gWLM Configuration", "cat $gwlm_conf_dir/$file"); 
   }
   closedir(GDIR);

   close($logfh);
   return $log;

   sub logit {
     my $out = shift;
     my $comment = shift;
     my $command = shift;
     print $out "*******************************************************************************\n"; 
     print $out "       ".$comment.": ".$command . "\n";
     print $out "*******************************************************************************\n"; 
     print $out "\n"; 
     print $out `$command 2>&1`;
     print $out "\n\n\n"; 
     return;
   }
}
sub getspeed {
    my $speed;
    my $arch = qx{uname -m};
    chomp($arch);
    $_ = qx{/opt/ignite/bin/print_manifest};
    if  ( $arch ne "ia64") {
        /Speed: (.*)/;
       $speed = $1; 
    } else {
       /Clock speed = (.*)/ or /processor (.*)/;
       $speed = $1;
    }
    #print "DEBUG: Speed = $speed \n";
    return $speed;
}


sub getmem {
	$_ =qx{/opt/ignite/bin/print_manifest};
	/Main Memory: (.*)/;
	my $mem = $1;
	$mem =~ s/^\s+//;
	$mem =~ s/\s+$//;

	return $mem;
}

sub getsn {
    my $sn = " ";
    my $arch = qx{uname -m};
    chomp($arch);
    if  ( $arch ne "ia64") {
        $_ = qx{echo "sc product system;info;wait;il" | /usr/sbin/cstm };
        /System Serial Number...: (.*)/;
        $sn = $1;
        #print "DEBUG (PA) Machine serial number is: $sn\n";
     } else {
         $_ = qx{/usr/contrib/bin/machinfo};
         /[Mm]achine serial number (.*)/;
         $_ = $1;
         s/^= //;
         $sn = $_;
         #print "DEBUG (ia64) Machine serial number is: $sn\n";
    }
    $sn =~ s/^\s+//;
    $sn =~ s/\s+$//;
    return $sn;
}

sub chkspace {
#
# <chkspace> Perl script to check whether or not /var/opt/perf/datafiles/log*
#            files will fit into /var/tmp.
#
    use strict;

    # 
    #  Get list of log files 
    #
    opendir(DIR,"/var/opt/perf/datafiles/") or 
	    die "Cannot open /var/opt/perf/datafiles \n";

    my @files = grep /^log/, readdir(DIR);
    close(DIR);
    
    my $totsize = 0;
    my $filesize = 0;
    
    #
    #  Sum up the size of all the log files
    #
    foreach my $f (@files) {
       $filesize = -s "/var/opt/perf/datafiles/" . $f;
       $totsize = $totsize + $filesize;
       #print "DEBUG filesize of $f is $filesize\n";
    }
    
    #print "DEBUG totsize = $totsize\n";
    #
    # Now determine the capacity of the /var/tmp filesystem and compare it
    # to the size required to hold all of the log files.
    #
    
    my $dircap = 0;
    
    my @lines = `df -kP /var/tmp`;
    
    foreach my $line (@lines) {
       chomp $line;
       if  ($line =~ m/^Filesystem/) {
       } else {
          my @flds = split(" ",$line);
          $dircap = $flds[3];
          #print "DEBUG:  dircap = $dircap\n";
       }
    }
    
    if ( $totsize > ($dircap * 1024)) {
         die "ERROR: /var/tmp capacity needs to be increased by ($totsize - ($dircap * 1024)) bytes.\n";
    }
    return;
}
