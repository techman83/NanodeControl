#!/usr/bin/env perl
use LWP::Simple 'get';
use LWP::Simple::Post 'post';
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
  print "Master $schedule->{master} ON\n";
  post("http://localhost:3000/api/$schedule->{master}/HIGH");
} else {
  $schedule->{master} = 0;
}

# Run through each station schedule
foreach my $station (@{$schedule->{scheduledStations}}) {
  if ( $station ne $schedule->{master} ) {
    print "Station $station ON\n";
    post("http://localhost:3000/api/$station/HIGH");

    print "Sleeping for $schedule->{duration}\n";
    sleep($schedule->{duration});

    print "Station $station OFF\n";
    post("http://localhost:3000/api/$station/LOW");
  }
}

# Turn off Master Station (Master valve in irrigation etc)
my $masterstation;
if ( $schedule->{master} ) {
  print "Master $schedule->{master} OFF\n";
  post("http://localhost:3000/api/$schedule->{master}/LOW");
}
