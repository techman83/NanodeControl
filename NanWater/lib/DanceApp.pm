package DanceApp;
use Dancer ':syntax';
use Data::Dumper;
#set serializer => 'JSON';

our $VERSION = '0.1';

get '/' => sub {
    template 'index', {
        title  => "Nanode Control - Home",
    };
};

post '/stations/:id' => sub {
  return qq({"result":"success"});
};

get '/settings' => sub {
#  set layout => 'settings';

  template 'settings', {
        title  => "Nanode Control - Settings",
  };
};

get '/stations' => sub {
#  set layout => 'control';

  my @stations = ( { id => '10001', name => 'Station 1', state => 'off', },
                   { id => '10002', name => 'Station 2', state => 'on', },
                   { id => '10003', name => 'Station 3', state => 'on', },
                   );

  template 'control', {
        stations => \@stations,
        category => "Watering Stations",
        title  => "Nanode Control - Watering Sations",
  };

#  my @shed = ( { id => '10004', name => 'Air Conditioner', state => 'on', },
#                   );
#  template 'control', {
#        stations => \@shed,
#        category => "Shed",
#  };
};

true;
