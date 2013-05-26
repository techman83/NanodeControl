#!/usr/bin/perl
use Dancer;
use NanodeControl::ValveFinder;
my $scheduleid = $ARGV[0];
my $appdir = config->{appdir};

open(PID, "> $appdir/tmp/ValveFinder.pid") || die "could not open '$appdir/ValveFinder.pid' $!";
print PID "$$";
close(PID); 

find_valve($scheduleid);

unlink("$appdir/tmp/ValveFinder.pid") || die "could not open '$appdir/tmp/ValveFinder.pid' $!";
