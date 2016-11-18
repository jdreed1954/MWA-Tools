#!/usr/bin/perl -w
#
# process_mwalogs.pl  PERL script to process MWA log collection files.
#
#
#	by James D. Reed (james.reed@hp.com)
#	June 19, 2009
#
#

#
# We get a list of files in the current directory by first opening the DIR.
# We then grep for the filenames we're interested in and pass them to a list
# variable.
#
opendir(DIR, ".") || die;
@files = grep(/mwalogs.tar.gz/,readdir(DIR));
closedir(DIR);

#
# The list of files in the @files variable are NOT in the right order, so 
# need to sort them first.
#
@files = sort @files;
#print "DEBUG: @files \n";

foreach $file (@files) {
   print "\t$file ... ";
   #
   # Parse host name from filename
   #
   $_ = $file;
   m/_/;
   #m/_2/;
   $hostname = $`;
   #print "DEBUG: hostname = $hostname \n";
   my $start = time;
   mkdir $hostname;

   chdir "$hostname" or die "Cannot chdir into $hostname: $!\n";
   
   system "gunzip -c ../$file | tar xf -";

   chdir ".." or die "Cannot chdir into ..: $!\n";
   my $elapsed = time - $start;
   print "\t $elapsed seconds.\n"

}


exit;

