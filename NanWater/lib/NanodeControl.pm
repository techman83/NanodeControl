package NanodeControl;
use Dancer ':syntax';
use Data::Dumper;
use NanodeControl::DBsqlite;
use NanodeControl::RESTduino;
use NanodeControl::PIcontrol;
set serializer => 'JSON';

our $VERSION = '0.1';
our $messages = config->{messages};

get '/test' => sub {
  template 'test', {
        title  => "Nanode Control - Schedule",
  }, { layout => 'schedule' };
};

# Index
get '/' => sub {
    my @categories = get_categories();

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

# Schedule
get '/schedule' => sub {
  my @categories = get_categories();
  my @stations = get_stations("All"); 

  template 'schedule', {
        title  => "Nanode Control - Schedule",
        stations => \@stations,
        categories => \@categories,
  }, { layout => 'schedule' };
};

post '/addschedule' => sub {
  my $data = from_json(request->body);
  debug("Schedule: ", $data, $messages->{schedule}{success});
  #add_schedule($data);
  my $result = $messages->{schedule}{success};
  $result->{result} = 'success';
  to_json($result);
  return $result;
};

# Add Station
get '/addstation' => sub {
  my @categories = get_categories();
  my @types = get_types();

  template 'addstation', {
        title  => "Nanode Control - Add Station",
        categories => \@categories,
        types => \@types,
  };
};

post '/addstation' => sub {
  my $data = from_json(request->body);
  debug("Add station: ", $data);
  unless ($data->{stationname} eq "" || $data->{stationurl} eq "" || $data->{stationtype} eq "" || $data->{stationcategory} eq "") {
    my $add = add_station($data->{stationname},$data->{stationurl},$data->{stationtype},$data->{stationcategory});
    my $result = $messages->{station}{success};
    $result->{result} = 'success';
    debug($add,$result);
    return qq({"result":"success"});
  } else {
    my $result = $messages->{station}{undefined};
    $result->{result} = 'failure';
    return $result;
  }
};

# Remove Stations
get '/removestations' => sub {
  my @stations = get_stations("All"); 
  template 'removestations', {
        title  => "Nanode Control - Remove Stations",
        stations => \@stations,
  };
};

post '/removestations' => sub {
  my $data = from_json(request->body);
  debug("Remove station(s): ", @{$data->{stations}});
  remove_stations(@{$data->{stations}});
  return qq({"result":"success"});
};

# Add/Remove Categories
get '/categories' => sub {
  my @categories = get_categories();

  template 'categories', {
        title  => "Nanode Control - Categories",
        categories => \@categories,
  };
};

post '/addcategory' => sub {
  my $data = from_json(request->body);
  debug("Add Category: ", $data);
  unless ($data->{data} eq "") {
    add_category($data->{data});
    return qq({"result":"success"});
  } else {
    return qq({"result":"failure", "error":"undefined"});
  }
};

post '/removecategory' => sub {
  my $data = from_json(request->body);
  debug("Remove Category: ", $data);
  if ( defined $data->{data}[0] ) {
    my $result = remove_categories(@{$data->{data}});
    if ( $result eq "success" ) {
      debug("Category remove: ", $result);
      return qq({"result":"success"});
    } else {
      debug("Category still associated: ", $result);
      my $category = get_category($result);
      return qq({"result":"failure", "error":"station_associated", "category":"$category"});
    }
  } else {
    return qq({"result":"failure", "error":"none_seleceted"});
  }
  return qq({"result":"success"});
};

# Station Control
get '/stations/:category' => sub {
  my $category = params->{category};
  my @stations = get_stations($category);
  my $number = 0;
  foreach my $station (@stations) {
    $stations[$number]->{state} = get_station_state($stations[$number]->{url});
    $number++;
  }   
  my $categoryname = "";
  unless ($category eq 'All') {
    $categoryname = get_category($category);
  } else {
    $categoryname = 'All';
  }

  debug("Stations: ", @stations);
  template 'control', {
        stations => \@stations,
        category => $categoryname,
        title  => "Nanode Control - Sations",
  };
};

post '/stations/:id' => sub {
  my $station = from_json(request->body);
  $station->{url} =  get_station_url($station->{station});
  debug("Control Station: ", $station);
  my $result = set_station_state($station->{url},$station->{act},$station->{station}); # improve this, should be able to pass the whole object to the class... just not done it before!
  debug("result: $result");
  if ($result eq "success") {
    return qq({"result":"success"});
  } else {
    return qq({"result":"failed"});
  }
};

get '/pigpio/:gpio/:state' => sub {
  my $gpio = params->{gpio};
  my $state = params->{state};
  debug("Control gpio $gpio: $state");
  set_pigpio_state($gpio,$state);
  return qq({"result":"success"});
};
get '/pigpio/:gpio' => sub {
  my $gpio = params->{gpio};
  debug("Get gpio $gpio state");
  my $state = get_pigpio_state($gpio);
  my $result = qq({"$gpio":"$state"});
  debug($result);
  return $result;
};

true;
