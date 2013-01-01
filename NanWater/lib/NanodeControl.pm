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
  template 'settings', {
        title  => "Nanode Control - Settings",
  };
};

get '/mainsettings' => sub {
  template 'mainsettings', {
        title  => "Nanode Control - Main Settings",
  };
};

post '/mainsettings' => sub {
  return qq({"result":"success"});
};

get '/addstation' => sub {
  my @categories = ( { id => '20001', name => 'Water Station', },
                   { id => '20002', name => 'Shed Control', state => 'on', },
                   );

  template 'addstation', {
        title  => "Nanode Control - Add Station",
        categories => \@categories,
  };
};

post '/addstation' => sub {
  return qq({"result":"success"});
};

get '/removestations' => sub {
  my @stations = ( { category => 'Water Station', id => '10001', name => 'Station 1', state => 'off', },
                   { category => 'Water Station', id => '10002', name => 'Station 2', state => 'on', },
                   { category => 'Water Station', id => '10003', name => 'Station 3', state => 'on', },
                   );

  template 'removestations', {
        title  => "Nanode Control - Remove Stations",
        stations => \@stations,
  };
};

post '/removestations' => sub {
  return qq({"result":"success"});
};

post '/settings/:addcategory' => sub {
  return qq({"result":"success"});
};

post '/settings/:removecategory' => sub {
  return qq({"result":"success"});
};

get '/stations' => sub {
  my @stations = ( { category => 'Water Station', id => '10001', name => 'Station 1', state => 'off', },
                   { category => 'Water Station', id => '10002', name => 'Station 2', state => 'on', },
                   { category => 'Water Station', id => '10003', name => 'Station 3', state => 'on', },
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
