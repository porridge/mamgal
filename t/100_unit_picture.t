#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 13;
use Test::Exception;
use lib 'testlib';
use MMGal::TestHelper;
use File::stat;

prepare_test_data;

use_ok('MMGal::Entry::Picture::Static');

# test parameter checks
dies_ok(sub { MMGal::Entry::Picture::Static->new },				"Entry::Picture::Static dies on creation with no args");
dies_ok(sub { MMGal::Entry::Picture::Static->new('/') },                        "Entry::Picture::Static dies on creation with one arg");
dies_ok(sub { MMGal::Entry::Picture::Static->new(qw(td c.jpg), 1) },		"Entry::Picture::Static dies on creation with third argument not being a File::stat");
my $time = time;
utime($time, $time, 'td/c.jpg') == 1 or die "Failed to touch file";
my $stat = stat('td/c.jpg');
dies_ok(sub { MMGal::Entry::Picture::Static->new(qw(td c.jpg), $stat, 3) },	"Entry::Picture::Static dies on creation with more than 3 args");
my $e;
lives_ok(sub { $e = MMGal::Entry::Picture::Static->new(qw(td c.jpg)) },		"Entry::Picture::Static can be created with one existant picture arg");
isa_ok($e, 'MMGal::Entry::Picture::Static');
my $n;
lives_ok(sub { $n = $e->name },							"Picture::Static knows its name");
is($n, 'c.jpg',									"Picture::Static name is ok");
my $dir;
lives_ok(sub { $dir = $e->container },						"Picture::Static returns its container");
isa_ok($dir, 'MMGal::Entry::Dir',						"Picture::Static's container is a dir");

my $ret_time;
lives_ok(sub { $ret_time = $e->creation_time },					"Picture::Static returns some creation time, even if a stat object was not passed on construction");
is($ret_time, 1227818631,							"Returned creation time is the EXIF creation time");
