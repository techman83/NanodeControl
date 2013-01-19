package NanodeControl::PIcontrol;
use strict;
use base 'Exporter';

our @EXPORT = qw(get_pigpio_state set_pigpio_state);

sub get_pigpio_state {
  my ($gpio) = @_;
  my $result = `/usr/local/bin/gpio -g read $gpio`; # There are better more reliable ways to do this. Will implement later.
  $result=~s/\s+$//;
  if ($result == 1) { $result = 255; }
  return $result;
}

sub set_pigpio_state {
  my ($gpio,$state) = @_;
  # Not all Pi pins are PWM controllable, unlike the arduino.
  if (! $state == 0 && $state < 256) { $state = 1; }

  # Set state
  system("/usr/local/bin/gpio -g write $gpio $state");

  # Check state was set
  my $result = `/usr/local/bin/gpio -g read $gpio`; # There are better more reliable ways to do this. Will implement later.
  if ( $state == $result ) {
    return "success";
  } else {
    return "failed";
  }
}

1
