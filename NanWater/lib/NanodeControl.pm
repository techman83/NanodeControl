package NanodeControl;
use Dancer ':syntax';
use Data::Dumper;
use NanodeControl::DBsqlite;
use NanodeControl::RESTduino;
use Data::Validate::URI qw(is_web_uri);
set serializer => 'JSON';

our $VERSION = '0.1';

get '/test' => sub {
    #my $db = NanodeControl::DBsqlite->new( database => "db/nanode_control.sqlite", );
    my $data;
    @{$data->{stations}} = (10001,10002,1003);
    remove_stations(@{$data->{stations}});
    #print Dumper(@categories);
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

  template 'schedule', {
        title  => "Nanode Control - Schedule",
  }, { layout => 'schedule' };
};

post '/schedule' => sub {
  my $data = from_json(request->body);
  debug("Schedule: ", $data);
  return qq({"result":"success"});
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
  unless (is_web_uri($data->{stationurl})) { return qq({"result":"failure","error":"URL"}); }
  unless ($data->{stationname} eq "" || $data->{stationurl} eq "" || $data->{stationtype} eq "" || $data->{stationcategory} eq "") {
    my $add = add_station($data->{stationname},$data->{stationurl},$data->{stationtype},$data->{stationcategory});
    debug($add);
    return qq({"result":"success"});
  } else {
    return qq({"result":"failure","error":"undefined"});
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
  return qq({"result":"success"});
};

true;
