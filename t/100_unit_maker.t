#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 9;
use Test::Exception;
use Test::Files;
use lib 'testlib';
use MMGal::TestHelper;

prepare_test_data;

use_ok('MMGal::Maker');
my $m;
dies_ok(sub { MMGal::Maker->new },		"maker creation fails with no arg");

use MMGal::Formatter;
my $f = MMGal::Formatter->new;
lives_ok(sub { $m = MMGal::Maker->new($f) },	"maker creation succeeds with one formatter arg");
isa_ok($m, 'MMGal::Maker');

dies_ok(sub { $m->make() },			"maker dies on no args");
dies_ok(sub { $m->make('td/nonexistant')},	"maker dies on an inexistant dir");
dir_only_contains_ok('td/empty', [],		"directory is empty initially");
ok(	$m->make_without_roots('td/empty'),		"maker returns success on an empty dir");
dir_only_contains_ok('td/empty', [qw(index.html index.png mmgal.css)],
						"directory contains index files only after running");
