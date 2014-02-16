package NanodeControl::ValveFinder;
use Dancer qw(:syntax !get);
use NanodeControl::DBsqlite;
use LWP::Simple qw(get);
use base 'Exporter';

our @EXPORT = qw(find_valve);

sub find_valve {
  my ($stationid) = @_;
  my $station =  get_station($stationid);
  debug($station);

  while (1==1) {
    debug("Setting $stationid low");
    get("$station->{url}/LOW");
    select(undef,undef,undef, 0.02);

    debug("Setting $stationid high");
    get("$station->{url}/HIGH");
    select(undef,undef,undef, 0.02);
  }
}

1
