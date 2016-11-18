use List::MoreUtils qw(uniq);

sub  getComplexes() {

	opendir(DIR, "./.logs") or die;

	my @clist = ();
	my @complexes = ();

	while ( defined( my $file = readdir(DIR))) {
		next if $file =~ /^\.\.?$/;     # skip . and ..
        	my @cmplx = split("v", $file);
		push @clist,$cmplx[0];
	}

	@complexes = uniq(@clist);
	return @complexes;

}

