#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Data::Dumper;

use_ok( 'Medical::OPCS4' );

my $O = Medical::OPCS4->new();

$O->parse('/Users/spiros/Documents/caliber/data_variables/lookups/opcs.txt');