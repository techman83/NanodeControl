package NanodeControl::Web;
use Dancer ':syntax';
use Dancer::Plugin::WebSocket;
use AnyEvent::Util;
use Dancer::Plugin::DebugToolbar;

our $VERSION = '0.5';

get '/' => sub {
    template 'index';
};

true;
