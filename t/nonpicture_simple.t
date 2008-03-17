#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 5;
use Test::Exception;
use Test::Files;

system('rm -rf td ; cp -a td.in td');

use_ok('MMGal::Entry::NonPicture');
dies_ok(sub { MMGal::Entry::NonPicture->new },			"NonPicture dies on creation with no args");
dies_ok(sub { MMGal::Entry::NonPicture->new(qw(td empty_file), 2, 3) },
							"NonPicture dies on creation with more than 3 args");

my $n;
lives_ok(sub { $n = MMGal::Entry::NonPicture->new(qw(td empty_file)) },
							"NonPicture can be created with one existant non-picture");
isa_ok($n, 'MMGal::Entry::NonPicture');

