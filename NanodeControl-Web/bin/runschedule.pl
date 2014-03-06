#!/usr/bin/perl
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
}

# Run through each station schedule
foreach my $station (@{$schedule->{scheduledStations}}) {
  
  print "Station $station ON\n";
  post("http://localhost:3000/api/$station/HIGH");

  print "Sleeping for $schedule->{duration}\n";
  sleep($schedule->{duration});

  print "Station $station OFF\n";
  post("http://localhost:3000/api/$station/LOW");
}

# Turn on Master Station (Master valve in irrigation etc)
my $masterstation;
if ( $schedule->{master} ) {
  print "Master $schedule->{master} OFF\n";
  post("http://localhost:3000/api/$schedule->{master}/LOW");
}
