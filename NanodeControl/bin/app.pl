#!/usr/bin/env perl
use Dancer;
use NanodeControl;
use NanodeControl::DBsqlite;
my $appdir = config->{appdir};
my $tmpdir = config->{tmpdir};

unless ( -e "$appdir/db/nanode_control.sqlite") {
  create_db();
}

unless ( -d "$tmpdir" ) {
  mkdir $tmpdir;
}
 
dance;
