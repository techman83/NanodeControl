package NanodeControl::ControlState;
use strict;
use LWP::Simple qw(get);
use JSON::Parse qw(valid_json);
use Dancer qw(:syntax !get);
use base 'Exporter';

#our @EXPORT = qw(get_station_state set_station_state);
our @EXPORT = qw(set_station_state);

sub get_station_state {
  my ($url) = @_;
  debug("Getting URL: $url");
  my $result = "";
  my $state = get($url);
  if ( ! defined $state ){
    debug("Failed: state undefined");
    return "failure";
  } elsif (valid_json($state)) {
    my $data = from_json($state);
    my $result = $data->{value};
    debug("State: $state Result: $result");
    return $result;
  } else {
    debug("Failed: $state");
    return "failure";
  }
}

sub set_station_state {
  my ($data,$state,) = @_;
  my $return;

  if ($data->{type} eq 'onoff') {

    if ($data->{reversed} && $state =~ /high/i) {
      $state = 'LOW';
      $return->{state} = '';
    } elsif (! $data->{reversed} && $state =~ /high/i) {
      $state = 'HIGH';
      $return->{state} = 'true';
    } elsif ($data->{reversed} && $state =~ /low/i) {
      $state = 'HIGH';
      $return->{state} = 'true';
    } elsif (! $data->{reversed} && $state =~ /low/i) {
      $state = 'LOW';
      $return->{state} = '';
    }

    my $stateurl = "$data->{url}/$state";  
    get($stateurl);

    my $result = get_station_state($data->{url});
    debug("State: $state - Result: $result");
    if ( $result eq "failure" ) {
      $return->{result} = 'failed';
      return $return;
    } elsif ( $state eq $result) {
      $return->{result} = 'success';
      return $return;
    } else {
      $return->{result} = 'failed';
      return $return;
    }
  }
}

1
