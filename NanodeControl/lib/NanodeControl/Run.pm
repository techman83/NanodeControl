package NanodeControl::Run;
use strict;
use Dancer qw(:syntax !get);
use NanodeControl::DBsqlite;
use NanodeControl::RESTduino;
use NanodeControl::ToSeconds;
use LWP::Simple qw(get);
use Data::Dumper;
use base 'Exporter';

our @EXPORT = qw(run_schedule);

sub run_schedule {
  my ($scheduleid) = @_;
  my @stations = get_scheduled_stations($scheduleid);

  foreach my $station (@stations) {
    my $duration = $station->{duration};
    my $station =  get_station($station->{id});
    print Dumper($station);

    if ($station->{reversed} == 1) {
      set_station_state($station->{url},"LOW")
    } else {
      set_station_state($station->{url},"HIGH");
    }
    
    $duration = to_seconds($duration);
    print "$duration"; 
    sleep($duration);

    if ($station->{reversed} == 1) {
      set_station_state($station->{url},"HIGH")
    } else {
      set_station_state($station->{url},"LOW");
    }
  }
}

1

__END__
$VAR1 = {
          'runorder' => 1,
          'duration' => 500,
          'id' => 10001
        };

