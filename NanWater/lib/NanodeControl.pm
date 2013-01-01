package NanodeControl;
use Dancer ':syntax';
use Data::Dumper;
#set serializer => 'JSON';

our $VERSION = '0.1';

get '/' => sub {
    template 'index', {
        title  => "Nanode Control - Home",
    };
};

get '/settings' => sub {
  my @categories = ( { id => '20001', name => 'Water Station', },
                   { id => '20002', name => 'Shed Control', state => 'on', },
                   );

  template 'settings', {
        title  => "Nanode Control - Settings",
        categories => \@categories,
  };
};

post '/settings/:main' => sub {
  return qq({"result":"success"});
};

post '/settings/:addstation' => sub {
  return qq({"result":"success"});
};

post '/settings/:removestation' => sub {
  return qq({"result":"success"});
};

post '/settings/:addcategory' => sub {
  return qq({"result":"success"});
};

post '/settings/:removecategory' => sub {
  return qq({"result":"success"});
};

get '/stations' => sub {
  my @stations = ( { id => '10001', name => 'Station 1', state => 'off', },
                   { id => '10002', name => 'Station 2', state => 'on', },
                   { id => '10003', name => 'Station 3', state => 'on', },
                   );

  template 'control', {
        stations => \@stations,
        category => "Watering Stations",
        title  => "Nanode Control - Watering Sations",
  };
};

post '/stations/:id' => sub {
  return qq({"result":"success"});
};

true;
