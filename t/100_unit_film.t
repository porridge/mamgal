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

use_ok('MMGal::Entry::Picture::Film');

# test parameter checks
dies_ok(sub { MMGal::Entry::Picture::Film->new },				"Entry::Picture::Film dies on creation with no args");
dies_ok(sub { MMGal::Entry::Picture::Film->new('/') },				"Entry::Picture::Film dies on creation with one arg");
dies_ok(sub { MMGal::Entry::Picture::Film->new(qw(td/one_film m.mov), 1) },	"Entry::Picture::Film dies on creation with third argument not being a File::stat");
my $stat = stat('td/one_film/m.mov');
dies_ok(sub { MMGal::Entry::Picture::Film->new(qw(td/one_film m.mov), $stat, 3) },"Entry::Picture::Film dies on creation with more than 3 args");
my $e;
lives_ok(sub { $e = MMGal::Entry::Picture::Film->new(qw(td/one_film m.mov)) },	"Entry::Picture::Film can be created with one existant picture arg");
isa_ok($e, 'MMGal::Entry::Picture::Film');
my $n;
lives_ok(sub { $n = $e->name },						"Film knows its name");
is($n, 'm.mov',								"Film name is ok");
my $dir;
lives_ok(sub { $dir = $e->container },					"Film returns its container");
isa_ok($dir, 'MMGal::Entry::Dir',					"Film's container is a dir");

my $ret_time;
lives_ok(sub { $ret_time = $e->creation_time },				"Film returns some creation time, even if a stat object was not passed on construction");
is($ret_time, $stat->mtime,						"Returned creation time is the EXIF creation time");
