package NanodeControl::API;
use Dancer ':syntax';
use Dancer::Plugin::WebSocket;
use Dancer::Plugin::Mongo;
use AnyEvent::Util;

# https://github.com/jjn1056/Example-PlackStreamingAndNonblocking

get '/api/stations' => sub {
    debug("Stations Called");
    return;
};

true;
