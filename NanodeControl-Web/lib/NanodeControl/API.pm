package NanodeControl::API;
use Dancer ':syntax';
use Dancer::Plugin::Async;
use AnyEvent;

# Async request handler, responds when the timer triggers
async 'get' => '/timer' => sub {
    my $respond = respond;

    my $t; $t = AnyEvent->timer(after => 1, cb => sub {
        $respond->([ 200, [], [ 'foo!' ]]);
    });
};

# Normal Dancer route handler, blocking
get '/blocking' => sub {
    redirect '/timer';
};
