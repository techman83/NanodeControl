package NanodeControl::API;
use Dancer ':syntax';
use NanodeControl::DBAbstract;
use NanodeControl::Websocket;
use NanodeControl::ControlState;
use NanodeControl::Schedule;
use NanodeControl::Initialise;
use AnyEvent::Util;

get '/api/:collection' => sub {
  my $collection = params->{collection};
  my $data = get_collection($collection);
  return to_json($data,{allow_blessed=>1,convert_blessed=>1});
};

get '/api/key/:key' => sub {
  my $key = params->{key};
  my $data;

  if ($key =~ /schedule/) {
    $data = find_key('schedules',$key);
  } else {
    $data = find_key('stations',$key);
  }

  return to_json($data,{allow_blessed=>1,convert_blessed=>1});
};

post '/api/:collection' => sub {
  my $collection = params->{collection};
  my $data = from_json(request->body);

  fork_call {
    my ($collection, $data) = @_;
    $data = upsert($collection,$data);   

    return ($data,$collection);
  } ($collection, $data), sub {
    my ($data,$collection) = @_;
    
    # Initialise Pin if Pi
    if ($data->{controlType} eq 'pi') {
      debug("Pi Pin, calling initialise");
      initialise_pin($data);
      my $result->{result} = 'success';
      $result->{content} = "$data->{name} initialised";
      socket_notify($result);
    }

    # Notify Clients
    socket_insert($data,$collection);
    return;
  };
  return;
};

post '/api/:collection/partial/:id' => sub {
  my $collection = params->{collection};
  my $id = params->{id};
  my $data = from_json(request->body);
  
  fork_call {
    my ($collection, $data, $id) = @_;
    debug($data);
    $data = upsert($collection,$data,$id);
    debug($data);
    return ($data,$collection);
  } ($collection, $data, $id), sub {
    my ($data,$collection) = @_;
    socket_update($data,$collection);
    return;
  };
  return;
};

post '/api/:collection/delete/:id' => sub { # change this to a delete when figure out why 'del' doesn't respond
  my $collection = params->{collection};
  my $id = params->{id};
  my $data->{deleted} = 'true';
  
  fork_call {
    my ($collection, $data, $id) = @_;
    debug($data);
    $data = upsert($collection,$data,$id);
    debug($data);
    return ($data,$collection);
  } ($collection, $data, $id), sub {
    my ($data,$collection) = @_;
    socket_remove($data,$collection);
    return;
  };
  return;
};

post '/api/:key/:state' => sub {
  my $key = params->{key};
  my $state = params->{state};
  
  fork_call {
    my ($key, $state) = @_;
    my ($result,$update,$data,$collection);

    if ($key =~ /schedule/) {
      debug('Setting Cron');
      $collection = 'schedules';
      $data = find_key($collection,$key);
      $result = set_cron($data,$state);
      $update->{state} = $result->{state};
    } else {
      $collection = 'stations';
      $data = find_key($collection,$key);
      $result = set_station_state($data,$state);
      $update->{state} = $result->{state};
    }

    if ($result->{result} eq 'success') {
      $data = upsert($collection,$update,$data->{_id}{value});
    } else {
      $result->{data} = $data;
      socket_notify($result);
    }
    return ($data,$collection);
  } ($key, $state), sub {
    my ($data,$collection) = @_;
    socket_update($data,$collection);
    return;
  };
  return;
};

true;

__END__
post '/api/message' => sub {
  my $id = from_json(request->body);
  debug($id);
  my $collection = mongo->get_database($db)->get_collection( "stations" );
  my $data->{content} = $collection->find_one({ _id => MongoDB::OID->new("$id->{id}") });
  $data->{type} = 'update';
  ws_send to_json($data,{allow_blessed=>1,convert_blessed=>1});
  return;
};

