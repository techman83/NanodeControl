#!/usr/bin/perl
use Dancer;
use NanodeControl::Run;
my $scheduleid = $ARGV[0];

run_schedule($scheduleid);
