package NanodeControl::RESTduino;
use strict;
use REST::Client;
use JSON;
use base 'Exporter';
# Dev stuff
use File::Touch; # will just use files until the arduinos arrive!

our @EXPORT = qw(get_station_state set_station_state);

sub get_station_state {
  # id only needed during dev for tempfile name
  my ($url,$id) = @_;
# Potential code for rest state getting stuffs
#  my $restclient = REST::Client->new();
#  $restclient->GET($url);
#  my $result = from_json($restclient->responseContent());
  my $result = "";
  if ( -e "/tmp/$id.txt") {
    open (STATEFILE, "/tmp/$id.txt");
    while (<STATEFILE>) {
           chomp;
           $result = $_;
    }
    close (STATEFILE);
  } else {
    $result = 0;
  }
  return $result;
}

sub set_station_state {
  # id only needed during dev for tempfile name
  my ($url,$state,$id) = @_;
# Potential code for rest state settings stuffs
#  my $restclient = REST::Client->new();
#  my $stateurl = "$url/$state";  
#  $restclient->POST($stateurl);
#  $result = from_json($restclient->responseContent());
  open (STATEFILE, ">/tmp/$id.txt");
  print STATEFILE "$state";
  close (STATEFILE);
  return "success: $id - $state";
}

1
