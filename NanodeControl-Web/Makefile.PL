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
        'Dancer'                      => 1.311,
        'Dancer::Plugin::WebSocket'   => 0,
        'Dancer::Plugin::Mongo'       => 0,
        'AnyEvent::Util'              => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'NanodeControl-Web-*' },
);
