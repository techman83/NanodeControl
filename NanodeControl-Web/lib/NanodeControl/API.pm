package NanodeControl::API;
use Dancer ':syntax';
use Dancer::Plugin::WebSocket;
use Dancer::Plugin::Mongo;
use AnyEvent::Util;


get '/api/:collection' => sub {
  my $collection = params->{collection};
  debug("Getting $collection");
  fork_call {
    my ($collection) = @_;
    debug("Forking: $collection");
    $collection = mongo->database->get_collection( "$collection" );
    return $collection;
  } $collection, sub {
    my ($data) = @_;
    debug($data);
    ws_send $data;
    debug("Message Sent");
  };
  return;
};

get '/api/stations' => sub {

  return;
};
true;
