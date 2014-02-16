package NanodeControl::Web;
use Dancer ':syntax';
use Dancer::Plugin::Mongo;
use Dancer::Plugin::Async;
use AnyEvent;

our $VERSION = '0.5';

get '/' => sub {
    template 'index';
};

true;
