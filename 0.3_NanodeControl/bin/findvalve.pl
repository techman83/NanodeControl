#!/usr/bin/perl
use Dancer;
use NanodeControl::ValveFinder;
my $scheduleid = $ARGV[0];
my $appdir = config->{appdir};

open(PID, "> $appdir/$0.pid") || die "could not open '$appdir/$0.pid'  $!";
print PID "$$\n";
close(PID); 

find_valve($scheduleid);

unlink("$appdir/$0.pid") || die "could not open '$appdir/$0.pid'  $!";
