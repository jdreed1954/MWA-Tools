#!/usr/bin/perl -w

sub tStamp {

   my $sec;
   my $min;
   my $hour;
   my $mday;
   my $mon;
   my $year;
   my $wday;
   my $yday;
   my $isdst;

   ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
   my $now =  sprintf("[%04d-%02d-%02d %02d:%02d:%02d] ", 
                      $year+1900, $mon, $mday, $hour, $min, $sec);

   return $now;

}

