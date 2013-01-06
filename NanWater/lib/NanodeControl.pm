package NanodeControl;
use Dancer ':syntax';
use Data::Dumper;
use NanodeControl::DBsqlite;
set serializer => 'JSON';

our $VERSION = '0.1';

get '/test' => sub {
    #my $db = NanodeControl::DBsqlite->new( database => "db/nanode_control.sqlite", );
    my @categories = get_stations(10001);
    print Dumper(@categories);
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
  #{'stationcategory' => '10001','stationname' => 'Test','stationtype' => '10001','stationurl' => 'http://test/1'}
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
  debug("Remove station(s): ", $data);
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
  my @stations = get_stations($category); 
  my $categoryname = "";
  unless ($category eq 'All') {
    $categoryname = get_category($category);
  } else {
    $categoryname = 'All';
  }

  template 'control', {
        stations => \@stations,
        category => $categoryname,
        title  => "Nanode Control - Sations",
  };
};

post '/stations/:id' => sub {
  my $data = from_json(request->body);
  debug("Control Station: ", $data);
  return qq({"result":"success"});
};

true;
