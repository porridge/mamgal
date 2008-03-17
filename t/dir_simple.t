#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 14;
use Test::Exception;
use Test::MockObject;
use Test::Files;

system('rm -rf td ; cp -a td.in td');

use_ok('MMGal::Entry::Dir');
dies_ok(sub { MMGal::Entry::Dir->new },			"dir dies on creation with no args");
dies_ok(sub { MMGal::Entry::Dir->new(qw(td empty), 2, 3) },	"dir dies on creation with more than 3 args");

my $d;
lives_ok(sub { $d = MMGal::Entry::Dir->new(qw(td empty)) },	"dir can be created with one existant dir arg");
isa_ok($d, 'MMGal::Entry::Dir');

dies_ok(sub { $d->neighbours_of_index(0) },		"no neighbours of first index in an empty dir");
dies_ok(sub { $d->neighbours_of_index(1) },		"no neighbours of second index in an empty dir");

dies_ok(sub { $d->make },				"dir dies on make invocation with no arg");

my $f = Test::MockObject->new();
$f->set_isa('MMGal::Formatter');
$f->mock('format', sub { "whatever" });
$f->mock('stylesheet', sub { "whatever" });
dir_only_contains_ok('td/empty', [],			"directory is empty initially");

lives_ok(sub { $d->make($f) },				"dir lives on make invocation with a formatter");

ok($f->called('format'),				"dir->make calls formatter->format internally");
ok($f->called('stylesheet'),				"dir->make calls formatter->format internally");
dir_only_contains_ok('td/empty', [qw{index.html index.png mmgal.css}],
							"directory contains only the index file and thumb afterwards");
file_ok('td/empty/index.html', "whatever",		"dir->make creates an index file");
