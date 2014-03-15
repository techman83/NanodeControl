package NanodeControl::ControlState;
use strict;
use LWP::Simple qw(get);
use JSON::Parse qw(valid_json);
use Dancer qw(:syntax !get);
use base 'Exporter';

#our @EXPORT = qw(get_station_state set_station_state);
our @EXPORT = qw(set_station_state);

sub get_station_state {
  my ($data) = @_;
  my $result;
  my $state;

  if ($data->{controlType} eq 'remote') {
    $state = get($data->{url});
    if (valid_json($state)) {
      $state = from_json($state);
      return $state->{value};
    } else {
      debug("Failed: $state");
      return "failure";
    }
  } elsif ($data->{controlType} eq 'pi') {
    $result = `/usr/local/bin/gpio -g read $data->{pin}`; # There are better more reliable ways to do this. Will implement later.
    debug("Pi Read: $result");
    return $result;
  }
}

sub set_station_state {
  my ($data,$state) = @_;
  my $return;
  my $pistate;

  if ($data->{type} eq 'onoff') {

    if ($data->{reversed} && $state =~ /high/i) {
      $state = 'LOW';
      $pistate = '0';
      $return->{state} = 'true';
    } elsif (! $data->{reversed} && $state =~ /high/i) {
      $state = 'HIGH';
      $pistate = '1';
      $return->{state} = 'true';
    } elsif ($data->{reversed} && $state =~ /low/i) {
      $state = 'HIGH';
      $pistate = '1';
      $return->{state} = '';
    } elsif (! $data->{reversed} && $state =~ /low/i) {
      $state = 'LOW';
      $pistate = '0';
      $return->{state} = '';
    }
    
    if ($data->{controlType} eq 'remote') {
      my $stateurl = "$data->{url}/$state";  
      get($stateurl);
    } elsif ($data->{controlType} eq 'pi') {
      system("/usr/local/bin/gpio -g write $data->{pin} $pistate");
    }

    my $result = get_station_state($data);
    debug("State: $state - Pi State: $pistate - Result: $result");

    if ( $result eq "failure" ) {
      $return->{result} = 'failed';
      return $return;
    } elsif ( $data->{controlType} eq 'remote' && $state eq $result ) {
      $return->{result} = 'success';
      debug($return);
      return $return;
    } elsif ( $data->{controlType} eq 'pi' && $pistate == $result ) {
      $return->{result} = 'success';
      debug($return);
      return $return;
    } else {
      $return->{result} = 'failed';
      return $return;
    }
  }
}

1
