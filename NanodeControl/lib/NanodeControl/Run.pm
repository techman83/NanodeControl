package NanodeControl::Run;
use strict;
use Dancer qw(:syntax);
use NanodeControl::DBsqlite;
use LWP::Simple;
use base 'Exporter';

our @EXPORT = qw(run_schedule);

sub run_schedule {
  my ($scheduleid) = @_;
  my @stations = get_scheduled_stations($scheduleid);

  foreach $station (@stations) {
    my $station =  get_station($station->{id});

    if ($station->{reversed} == 1 {
      set_stations_state($station->{url},"LOW")
    } else {
      set_stations_state($station->{url},"HIGH");
    }

    sleep($station->{duration});

    if ($station->{reversed} == 1 {
      set_stations_state($station->{url},"HIGH")
    } else {
      set_stations_state($station->{url},"LOW");
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

