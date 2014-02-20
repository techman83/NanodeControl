package NanodeControl::API;
use Dancer ':syntax';
use Dancer::Plugin::WebSocket;
use Dancer::Plugin::Mongo;
use AnyEvent::Util;


get '/api/stations' => sub {
    debug("Stations Called");
    fork_call {
      debug("Forking");
      sleep 5;
    } sub {
      my $data->{type} = 'update';
      $data->{content} = 'content!';
      ws_send $data;
      debug("Message Sent");
    };
    return;
};

true;
