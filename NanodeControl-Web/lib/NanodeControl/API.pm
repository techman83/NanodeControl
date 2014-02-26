package NanodeControl::API;
use Dancer ':syntax';
use Dancer::Plugin::WebSocket;
use Dancer::Plugin::Mongo;
use AnyEvent::Util;

# settings
our $db = config->{plugins}{Mongo}{db_name};

get '/api/:collection' => sub {
  my $collection = params->{collection};
  debug("Getting $collection");
  my $cursor = mongo->get_database($db)->get_collection( "$collection" )->find();
  my $data;
  @{$data} = $cursor->all;
  debug(@{$data});
  return to_json($data,{allow_blessed=>1,convert_blessed=>1});
};

post '/api/:collection' => sub {
  my $collection = params->{collection};
  my $data = from_json(request->body);

  fork_call {
    my ($collection, $data) = @_;

    # Get collection
    $collection = mongo->get_database($db)->get_collection( "$collection" );

    # Insert data
    my $insert = $collection->insert($data);

    # Get result
    $data = $collection->find_one({ _id => MongoDB::OID->new("$insert->{value}") });
    return $data;
  } ($collection, $data), sub {
    my ($data) = @_;
    # Send data to clients
    my $result->{type} = 'insert';
    $result->{content} = $data;
    $result = to_json($result,{allow_blessed=>1,convert_blessed=>1});
    debug($result);
    ws_send $result;
    debug("Message Sent");
  };
  return;
};

post '/api/:collection/partial/:id' => sub {
  my $collection = params->{collection};
  my $id = params->{id};
  my $data = from_json(request->body);
  
  fork_call {
    my ($collection, $data, $id) = @_;

    # Get collection
    $collection = mongo->get_database($db)->get_collection( "$collection" );

    # Partial Update
    my $update = $collection->update({ _id => MongoDB::OID->new("$id") }, {'$set' => { "$data->{key}" => "$data->{value}"}});
    debug($update);
    # Get result
    $data = $collection->find_one({ _id => MongoDB::OID->new("$id") });
    debug($data);
    return $data;
  } ($collection, $data, $id), sub {
    my ($data) = @_;
    # Send data to clients
    my $result->{type} = 'update';
    $result->{content} = $data;
    $result = to_json($result,{allow_blessed=>1,convert_blessed=>1});
    debug($result);
    ws_send $result;
    debug("Message Sent");
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

