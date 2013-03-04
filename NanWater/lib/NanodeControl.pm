package NanodeControl;
use Dancer ':syntax';
use Data::Dumper;
use NanodeControl::DBsqlite;
use NanodeControl::RESTduino;
use NanodeControl::PIcontrol;
use NanodeControl::Schedule;
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

## Schedules
# Schedules
get '/schedules' => sub {
  my @schedules = get_schedules();

  template 'schedules', {
        title  => "Nanode Control - Schedules",
        schedules => \@schedules,
  };
};

post '/schedule' => sub {
  my $data = from_json(request->body);
  debug("Schedule: ", $data);
  
  foreach my $enable (@{$data->{enabled}}) {
    if ( get_schedule_state($enable) == 0 ) {
      enable_schedule($enable);
      add_cron($enable);
    }
  }

  foreach my $disable (@{$data->{disabled}}) {
    if ( get_schedule_state($disable) == 1 ) {
      disable_schedule($disable);
      remove_cron($disable);
    }
  }
  return qq({"result":"success"});
};

# Remove Schedules
get '/removeschedules' => sub {
  my @schedules = get_schedules();

  template 'removeschedules', {
        title  => "Nanode Control - Remove Schedules",
        schedules => \@schedules,
  };
};

post '/removeschedules' => sub {
  my $data = from_json(request->body);

  return qq({"result":"success"});
};

# Add a schedule
get '/addschedule' => sub {
  my @categories = get_categories();
  my @stations = get_stations("All"); 

  template 'addschedule', {
        title  => "Nanode Control - Add Schedule",
        stations => \@stations,
        categories => \@categories,
  }, { layout => 'addschedule' };
};

post '/addschedule' => sub {
  my $data = from_json(request->body);
  debug("Schedule: ", $data, $messages->{schedule}{success});
  my $scheduleid = add_schedule($data);
  add_cron($scheduleid);
  my $result = $messages->{schedule}{success};
  $result->{result} = 'success';
  to_json($result);
  debug("Schedule: ", $result);
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

  unless ($data->{stationname} eq "" || $data->{stationurl} eq "") {
    my $add = add_station($data->{stationname},$data->{stationurl},$data->{stationtype},$data->{stationcategory},$data->{stationreverse});
    my $result = { result => 'success',
                   title => $messages->{station}{success}{title},
                   message => $messages->{station}{success}{message},
                 };
    to_json($result);
    debug("Add Station: ", $result);
    return $result;
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
  unless ($data->{categoryname} eq "") {
    add_category($data->{categoryname});
    return qq({"result":"success"});
  } else {
    my $result = { result => 'failure',
                   title => $messages->{category}{undefined}{title},
                   message => $messages->{category}{undefined}{message},
                   error => 'undefined',
                 };
    to_json($result);
    debug("Remove Category: ", $result);
    return $result;
  }
};

post '/removecategory' => sub {
  my $data = from_json(request->body);
  debug("Remove Category: ", $data);

  ## Probably worth making the DB class OO and return an object here, handling mutliple category failures would be possible! ##
  if ( defined $data->{categories}[0] ) {
    my $removecat = remove_categories(@{$data->{categories}});

    ## Once DB class is OO, turn this into a switch statement for easier expansion.
    if ( $removecat eq "success" ) {
      debug("Category remove: ", $removecat);
      return qq({"result":"success"});
    } else {
      debug("Category still associated: ", $removecat);
      my $category = get_category($removecat);
      my $result = { result => 'failure',
                     title => $messages->{category}{associated}{title},
                     message => $messages->{category}{associated}{message} . '"' . $category . '"' . ".",
                     error => 'station_associated',
                   };
      to_json($result);
      debug("Remove Category: ", $result);
      return $result;
    }
  } else {
    my $result = { result => 'failure',
                   title => $messages->{category}{none_selected}{title},
                   message => $messages->{category}{none_selected}{message},
                   error => 'none_selected',
                 };
    to_json($result);
    debug("Remove Category: ", $result);
    return $result;
  }
};

# Station Control
get '/stations/:category' => sub {
  my $category = params->{category};
  my @stations = get_stations($category);
  my $number = 0;
  foreach my $station (@stations) {
    $stations[$number]->{state} = get_station_state($stations[$number]->{url});
    # After recieving the relay boards I noted that when using an external power source on them HIGH was considered off and LOW was considered on. Made sense when I looked at the circuit diagram.
    if ($stations[$number]->{reversed} == 1 && $stations[$number]->{state} eq 'LOW') {
      $stations[$number]->{state} = 'HIGH';
    } elsif ($stations[$number]->{reversed} == 1 && $stations[$number]->{state} eq 'HIGH') {
      $stations[$number]->{state} = 'LOW';
    }
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
  my $control = from_json(request->body);
  my $station =  get_station($control->{id});
  # After recieving the relay boards I noted that when using an external power source on them HIGH was considered off and LOW was considered on. Made sense when I looked at the circuit diagram.
  if ($station->{reversed} == 1 && $control->{value} eq 'LOW') {
    $control->{value} = 'HIGH';
  } elsif ($station->{reversed} == 1 && $control->{value} eq 'HIGH') {
    $control->{value} = 'LOW';
  }
  debug("Control Station: ", $station, $control);
  my $controlresult = set_station_state($station->{url},$control->{value},$station->{id}); # improve this, should be able to pass the whole object to the class... just not done it before! (That's kind of a lie... being lazy here)
  debug("Control result: $controlresult");
  if ($controlresult eq "success") {
    return qq({"result":"success"});
  } else {
    my $result = { result => 'failure',
                   title => $messages->{control}{failure}{title},
                   message => $messages->{control}{failure}{message},
                 };
    to_json($result);
    debug("Control station: ", $result);
    return $result;
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
  my $result = qq({"pin":"$gpio""value":"$state"});
  debug($result);
  return $result;
};

true;
