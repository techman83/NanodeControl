#!/usr/bin/env perl
use Dancer;
use NanodeControl;
use NanodeControl::DBsqlite;
my $appdir = config->{appdir};

unless ( -e "$appdir/db/nanode_control.sqlite") {
  create_db();
}
 
dance;
