package NanodeControl::API;
use Dancer ':syntax';
use NanodeControl::DBAbstract;
use NanodeControl::Websocket;
use AnyEvent::Util;

get '/api/:collection' => sub {
  my $collection = params->{collection};
  my $data = get_collection($collection);
  return to_json($data,{allow_blessed=>1,convert_blessed=>1});
};

post '/api/:collection' => sub {
  my $collection = params->{collection};
  my $data = from_json(request->body);

  fork_call {
    my ($collection, $data) = @_;
    $data = upsert($collection,$data);
    return $data;
  } ($collection, $data), sub {
    my ($data) = @_;
    socket_insert($data);
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
    return $data;
  } ($collection, $data, $id), sub {
    my ($data) = @_;
    socket_update($data);
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
    return $data;
  } ($collection, $data, $id), sub {
    my ($data) = @_;
    socket_remove($data);
    return;
  };
  return;
};

post '/api/:key/:state' => sub {
  my $key = params->{key};
  my $state = params->{state};
  
  #fork_call {
  #  my ($collection, $data, $id) = @_;
  #  debug($data);
  #  $data = upsert($collection,$data,$id);
  #  debug($data);
  #  return $data;
  #} ($collection, $data, $id), sub {
  #  my ($data) = @_;
  #  socket_update($data);
  #  return;
  #};
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

