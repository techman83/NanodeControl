#!/usr/bin/perl
use LWP::Simple qw(get);

my $station = $ARGV[0];
my $pin = $ARGV[1];

if ($station eq "" || $pin eq "" ) {
  print "Usage: $0 station_ip pin\n";
  exit
}

while (1==1) {
  get("http://$station/$pin/LOW");
  select(undef,undef,undef, 0.02);

  get("http://$station/$pin/HIGH");
  select(undef,undef,undef, 0.02);
}
