use Test::More tests => 2;
use strict;
use warnings;

# the order is important
use DanceApp;
use Dancer::Test;

route_exists [GET => '/'], 'a route handler is defined for /';
response_status_is ['GET' => '/'], 200, 'response status is 200 for /';
#route_exists [GET => '/stations/'], 'a route handler is defined for /';
#response_status_is ['GET' => '/stations/'], 200, 'response status is 200 for /';
