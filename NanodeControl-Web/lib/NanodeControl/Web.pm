package NanodeControl::Web;
use Dancer ':syntax';

our $VERSION = '0.5';

get '/' => sub {
    template 'index';
};

true;
