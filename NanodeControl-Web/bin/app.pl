#!/usr/bin/env perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use NanodeControl::Web;
NanodeControl::Web->dance;
