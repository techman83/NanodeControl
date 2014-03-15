package NanodeControl::Initialise;
use Dancer ':syntax';
use NanodeControl::DBAbstract;
use NanodeControl::ControlState;
use AnyEvent::Util;

use base 'Exporter';

our @EXPORT = qw(initialise_pin);

sub all {
  my $data = get_collection('stations');
  
  # Set pin mode to out
  foreach my $station (@{$data}) {
    debug($station);
    if ($station->{controlType} eq 'pi') {
      debug("Setting exporting pin $station->{pin} as output");
      system("/usr/local/bin/gpio export $station->{pin} out");
      set_station_state($station,"low");
    }
  }

  return;
}

sub initialise_pin {
  my ($data) = @_;
  
  debug("Exporting pin $data->{pin} as output");
  system("/usr/local/bin/gpio export $data->{pin} out");
  set_station_state($data,"low");

  return;
};

1;
