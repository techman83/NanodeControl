#!/usr/bin/perl
use LWP::Simple qw(get post);
use JSON;
use Data::Dumper;
my $apikey = $ARGV[0];

# Schedule Information
my $schedule = get("http://localhost:3000/api/key/$apikey");
$schedule = from_json($schedule);

print Dumper($schedule);

# Turn on Master Station (Master valve in irrigation etc)
my $masterstation;
if ( $schedule->{master} ) {
  post("http://localhost:3000/$schedule->{master}/HIGH");
}

## Run through each station schedule
#foreach my $station (@stations) {
#  my $duration = $station->{duration};
#  my $station =  get_station($station->{id});
#  print Dumper($station);
#
#  if ($station->{reversed} == 1) {
#    set_station_state($station->{url},"LOW")
#  } else {
#    set_station_state($station->{url},"HIGH");
#  }
#  
#  $duration = to_seconds($duration);
#  print "$duration"; 
#  sleep($duration);
#
#  if ($station->{reversed} == 1) {
#    set_station_state($station->{url},"HIGH")
#  } else {
#    set_station_state($station->{url},"LOW");
#  }
#}
#
## Turn off Master Station
#unless ( $schedule->{master} == 0 ) {
#  $masterstation =  get_station($schedule->{master});
#  
#  if ($station->{reversed} == 1) {
#    set_station_state($station->{url},"HIGH");
#  } else {
#    set_station_state($station->{url},"LOW")
#  }
#}



__END__
$VAR1 = {
          'runorder' => 1,
          'duration' => 500,
          'id' => 10001,
          'master' => 10002
        };

