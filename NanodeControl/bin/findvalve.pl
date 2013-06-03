#!/usr/bin/perl
use FindBin qw($Bin);
use lib "$Bin/../lib";
use NanodeControl::DBsqlite;
use LWP::Simple qw($ua get);

my $stationid = $ARGV[0];
my $appdir = "$Bin/..";
#my $debug = 1;

# Would like to catch interrupts and handle exiting properly
$SIG{INT} = \&interrupt;

if ($debug) { use Data::Dumper; }

unless ( -e $appdir/tmp/ValveFinder.pid ) {
  open(PID, "> $appdir/tmp/ValveFinder.pid") || die "could not open '$appdir/ValveFinder.pid' $!";
  print PID "$$";
  close(PID); 
} else {
  exit(1);
}

# We really don't care if the call fails.
$ua->timeout(1);

my $station =  get_station($stationid);


if ($debug) { print Dumper($station); }

while (1 == 1) {
  if ($debug) { print "Setting $stationid low\n"; }
  get("$station->{url}/LOW");

  # Nanode devices seem to stall with anything much lower than 50ms
  select(undef,undef,undef, 0.05);

  if ($debug) { print "Setting $stationid high\n"; }
  get("$station->{url}/HIGH");
  select(undef,undef,undef, 0.05);
}

sub interrupt {
  my($signal)=@_;
  if ($debug) { print "Caught Interrupt\: $signal \n"; }
  if ($debug) { print "Now Exiting\n"; }

  if ($station->{reversed} == 1) {
    get("$station->{url}/HIGH")
  } else {
    get("$station->{url}/LOW");
  }
  
  unlink("$appdir/tmp/ValveFinder.pid") || die "could not open '$appdir/tmp/ValveFinder.pid' $!";
     
  exit(1);
}

__END__
