use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'NanodeControl::Web',
    AUTHOR              => q{Leon Wright <techman83@gmail.com.com>},
    VERSION_FROM        => 'lib/NanodeControl/Web.pm',
    ABSTRACT            => 'YOUR APPLICATION ABSTRACT',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'                  => 0,
        'YAML'                        => 0,
        'EV'                          => 0,
        'Dancer'                      => 1.311,
        'LWP::Simple::Post'           => 0,
        'LWP::Simple'                 => 0,
        'Dancer::Plugin::WebSocket'   => 0,
        'Dancer::Plugin::Mongo'       => 0,
        'Dancer::Template::Tiny'      => 0,
        'AnyEvent::Util'              => 0,
        'Config::Crontab'             => 0,
        'MooseX/Traits.pm'            => 0,
        'DateTime::Format::Strptime'  => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'NanodeControl-Web-*' },
);
