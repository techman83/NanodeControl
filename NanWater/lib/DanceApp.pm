package DanceApp;
use Dancer ':syntax';
use Data::Dumper;
#set serializer => 'JSON';

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

post '/stations/:id' => sub {
  return qq({"result":"success"});
};

get '/stations' => sub {
  set layout => 'station_control';

  my @stations = ( { id => '10001', name => 'Station 1', state => 'off', },
                   { id => '10002', name => 'Station 2', state => 'on', },
                   { id => '10003', name => 'Station 3', state => 'off', },
                   );

  my $category = 'Water Stations';
  template 'stations', {
        stations => \@stations,
        category => "Watering Stations",
        title  => "Water Station Manager - Control",
  };
};

true;
