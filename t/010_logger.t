#!/usr/bin/perl
# mamgal - a program for creating static image galleries
# Copyright 2007-2009 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
package MaMGal::Unit::Logger;
use strict;
use warnings;
use Carp 'verbose';
use Test::More;
use Test::Exception;
use base 'Test::Class';

use lib 'testlib';
use MaMGal::TestHelper;

sub class_load : Test(startup => 1) {
	use_ok('MaMGal::Logger');
}

MaMGal::Unit::Logger->runtests unless defined caller;
1;
