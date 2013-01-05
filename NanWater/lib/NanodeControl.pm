package NanodeControl;
use Dancer ':syntax';
use Data::Dumper;
set serializer => 'JSON';

our $VERSION = '0.1';

# Index
get '/' => sub {
    my @categories = ( { id => '10001', name => 'Water Station', },
                       { id => '10002', name => 'Shed Control', },
                     );

    template 'index', {
        title  => "Nanode Control - Home",
        categories => \@categories,
    };
};

# Settings Menu
get '/settings' => sub {
  template 'settings', {
        title  => "Nanode Control - Settings",
  };
};

# Main Settings
get '/mainsettings' => sub {
  template 'mainsettings', {
        title  => "Nanode Control - Main Settings",
  };
};

post '/mainsettings' => sub {
  my $data = from_json(request->body);
  debug("Control Station: ", $data);
  return qq({"result":"success"});
};

# Add Station
get '/addstation' => sub {
  my @categories = ( { id => '10001', name => 'Water Station', },
                   { id => '10002', name => 'Shed Control', },
                   );

  my @types = ( { id => '10001', name => 'On/Off', },
                   { id => '10002', name => 'Slider', },
                   );

  template 'addstation', {
        title  => "Nanode Control - Add Station",
        categories => \@categories,
        types => \@types,
  };
};

post '/addstation' => sub {
  my $data = from_json(request->body);
  debug("Add station: ", $data);
  return qq({"result":"success"});
};

# Remove Stations
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
  my $data = from_json(request->body);
  debug("Remove station(s): ", $data);
  return qq({"result":"success"});
};

# Add/Remove Categories
get '/categories' => sub {
  my @categories = ( { id => '10001', name => 'Water Station', },
                   { id => '10002', name => 'Shed Control', state => 'on', },
                   );

  template 'categories', {
        title  => "Nanode Control - Categories",
        categories => \@categories,
  };
};

post '/addcategory' => sub {
  my $data = from_json(request->body);
  debug("Add Category: ", $data);
  return qq({"result":"success"});
};

post '/removecategory' => sub {
  my $data = from_json(request->body);
  debug("Remove Category: ", $data);
  return qq({"result":"success"});
};

# Station Control
get '/stations/:category' => sub {
  my $category = params->{category};
  my @stations = ( { category => $category, id => '10001', name => 'Station 1', state => 'off', },
                   { category => $category, id => '10002', name => 'Station 2', state => 'on', },
                   { category => $category, id => '10003', name => 'Station 3', state => 'on', },
                   );

  template 'control', {
        stations => \@stations,
        category => $category,
        title  => "Nanode Control - Sations",
  };
};

post '/stations/:id' => sub {
  my $data = from_json(request->body);
  debug("Control Station: ", $data);
  return qq({"result":"success"});
};

true;
