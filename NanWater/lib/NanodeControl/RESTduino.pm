package NanodeControl::RESTduino;
use strict;
use NanodeControl::PIcontrol;
use LWP::Simple qw(get);
use JSON::Parse qw(valid_json);
use Dancer qw(:syntax !get);
use base 'Exporter';

our @EXPORT = qw(get_station_state set_station_state);

sub get_station_state {
  my ($url) = @_;
  debug("Getting URL: $url");
  my $result = "";
  unless ($url =~ /http/) {
    $result = get_pigpio_state($url);
    debug("State: $result");
    return $result;
  } else {
    my $state = get($url);
    if ( ! defined $state ){
      debug("Failed: state undefined");
      return "failure";
    } elsif (valid_json($state)) {
      my $data = from_json($state);
      my $pinid = (keys $data)[0];
      my $result = $data->{"$pinid"};
      debug("State: $state Result: $result");
      return $result;
    } else {
      debug("Failed: $state");
      return "failure";
    }
  }
}

sub set_station_state {
  my ($url,$state,) = @_;
  unless ($url =~ /http/) {
    set_pigpio_state($url,$state);
  } else {
    my $stateurl = "$url/$state";  
    get($stateurl);
  }

  my $result = get_station_state($url);
  debug("State: $state - Result: $result");
  if ( $result eq "failure" ) {
    return "failed";
  } elsif ( $state == $result) {
    return "success";
  } else {
    return "failed";
  }
}

1
