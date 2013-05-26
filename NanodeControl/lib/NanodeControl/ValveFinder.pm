package NanodeControl::ValveFinder;
use Dancer qw(:syntax !get);
use NanodeControl::DBsqlite;
use LWP::Simple qw($ua get);
use base 'Exporter';

# We really don't care if the call fails.
$ua->timeout(1);

our @EXPORT = qw(find_valve);

sub find_valve {
  my ($stationid) = @_;
  my $station =  get_station($stationid);
  my $interruptions = 0;
  $interruptions = $SIG{HUP} = \&handle_interruptions;
  debug($station);

  while ($interruptions == 0) {
    debug("Setting $stationid low");
    get("$station->{url}/LOW");

    # Nanode devices seem to stall with anything much lower than 50ms
    select(undef,undef,undef, 0.05);

    debug("Setting $stationid high");
    get("$station->{url}/HIGH");
    select(undef,undef,undef, 0.05);
  }

  if ($station->{reversed} == 1) {
    get("$station->{url}/HIGH")
  } else {
    get("$station->{url}/LOW");
  }
}

sub handle_interruptions {
    my $interruptions++;
    warn "interrupted ${interruptions}x.\n";
    return $interruptions;
}

1
