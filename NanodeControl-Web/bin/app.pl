#!/usr/bin/env perl
use Dancer;
use NanodeControl::Web;
use NanodeControl::API;
use Dancer::Plugin::Async;
use Twiggy::Server;
use AnyEvent;
use EV;

my $server = Twiggy::Server->new(
    host => '0.0.0.0',
    port => 3000,
);

$server->register_service(Dancer::Plugin::Async::app());

EV::loop;

