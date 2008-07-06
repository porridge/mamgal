#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 16;
use Test::Exception;
use lib 'testlib';
use MMGal::TestHelper;

prepare_test_data;

use_ok('MMGal::Entry');

# test parameter checks
dies_ok(sub { MMGal::Entry->new },				"Entry dies on creation with no args");
dies_ok(sub { MMGal::Entry->new('/') },                         "Entry dies on creation with one arg");
dies_ok(sub { MMGal::Entry->new(qw(td empty_file), 2, 3) },	"Entry dies on creation with more than 3 args");
my $e;
lives_ok(sub { $e = MMGal::Entry->new(qw(td empty)) },		"Entry can be created with one existant dir arg");
isa_ok($e, 'MMGal::Entry');
my $n;
lives_ok(sub { $n = $e->name },					"Entry knows its name");
is($n, 'empty',							"Entry name is ok");
lives_ok(sub { $e = MMGal::Entry->new(qw(td empty_file)) },	"Entry can be created with one existant file arg");
isa_ok($e, 'MMGal::Entry');
lives_ok(sub { $n = $e->name },					"Entry knows its name");
is($n, 'empty_file',						"Entry name is ok");
my $dir;
lives_ok(sub { $dir = $e->container },                          "Entry returns its container");
isa_ok($dir, 'MMGal::Entry::Dir',                               "Entry's container is a dir");

dies_ok(sub { MMGal::Entry->new(qw(td/empty .)) },              "Entry refuses to be created with '.' as the basename, when a name could have been provided");
dies_ok(sub { MMGal::Entry->new(qw(. td/empty)) },              "Entry refuses to be created with basename containing a slash");

