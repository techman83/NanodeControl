#!/usr/bin/env perl
use Dancer;
use NanodeControl::Web;
use NanodeControl::API;
use NanodeControl::Initialise;

NanodeControl::Initialise->all;

dance;
