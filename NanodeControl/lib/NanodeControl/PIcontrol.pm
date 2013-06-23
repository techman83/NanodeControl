package NanodeControl::PIcontrol;
use strict;
use base 'Exporter';

our @EXPORT = qw(get_pigpio_state set_pigpio_state);

sub get_pigpio_state {
  my ($gpio) = @_;

  my $result = `/usr/local/bin/gpio -g read $gpio`; # There are better more reliable ways to do this. Will implement later.
  if ($result == 0) {
    $result = 'LOW';
  } elsif ($result == 1) {
    $result = 'HIGH';
  } else {
    return "failed";
  }

  return $result;
}

sub set_pigpio_state {
  my ($gpio,$state) = @_;
  if ($state eq 'LOW') {
    $state = 0;
  } elsif ($state eq 'HIGH') {
    $state = 1;
  } else {
    return "failed";
  }

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
