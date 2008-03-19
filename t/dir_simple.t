#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 31;
use Test::Exception;
use Test::MockObject;
use Test::Files;
use Test::HTML::Content;
use MMGal::Formatter;

system('rm -rf td ; cp -a td.in td');

use_ok('MMGal::Entry::Dir');
dies_ok(sub { MMGal::Entry::Dir->new },			"dir dies on creation with no args");
dies_ok(sub { MMGal::Entry::Dir->new(qw(td empty), 2, 3) },	"dir dies on creation with more than 3 args");

my $d;
lives_ok(sub { $d = MMGal::Entry::Dir->new(qw(td empty)) },	"dir can be created with one existant dir arg");
isa_ok($d, 'MMGal::Entry::Dir');
ok(! $d->is_root,					"freshly created dir is not a root");

my $deep_dir;
lives_ok(sub { $deep_dir = MMGal::Entry::Dir->new(qw(td/more subdir)) },	"dir can be created with one existant dir arg");
isa_ok($deep_dir, 'MMGal::Entry::Dir');
ok(! $deep_dir->is_root,						"freshly created dir is not a root");
is_deeply([map { $_->name } $deep_dir->containers], [qw(td more)],		"non-root directory has some container names");

my $rd;
lives_ok(sub { $rd = MMGal::Entry::Dir->new(qw(td root_dir)) },	"dir can be created with a root-marked dir arg");
isa_ok($rd, 'MMGal::Entry::Dir');
ok($rd->is_root,						"freshly created root dir is root");
is_deeply([($rd->containers)], [],			"root directory has no container names");

my $bd;
lives_ok(sub { $bd = MMGal::Entry::Dir->new(qw(/ bin)) },	"dir can be created with a toplevel dir arg");
isa_ok($bd, 'MMGal::Entry::Dir');
ok(! $bd->is_root,					"freshly created dir is not a root");

my $Rd;
lives_ok(sub { $Rd = MMGal::Entry::Dir->new(qw(/ /)) },	"dir can be created with the / dir");
isa_ok($Rd, 'MMGal::Entry::Dir');
ok($Rd->is_root,					"freshly created root dir is root");
ok($bd->container->is_root,				"toplevel dir's container is root");

dies_ok(sub { $d->neighbours_of_index(0) },		"no neighbours of first index in an empty dir");
dies_ok(sub { $d->neighbours_of_index(1) },		"no neighbours of second index in an empty dir");

dies_ok(sub { $d->make },				"dir dies on make invocation with no arg");

my $mf = Test::MockObject->new();
$mf->set_isa('MMGal::Formatter');
$mf->mock('format', sub { "whatever" });
$mf->mock('stylesheet', sub { "whatever" });
dir_only_contains_ok('td/empty', [],			"directory is empty initially");

lives_ok(sub { $d->make($mf) },				"dir lives on make invocation with a formatter");

ok($mf->called('format'),				"dir->make calls formatter->format internally");
ok($mf->called('stylesheet'),				"dir->make calls formatter->stylesheet internally");
dir_only_contains_ok('td/empty', [qw{index.html index.png mmgal.css}],
							"directory contains only the index file and thumb afterwards");
file_ok('td/empty/index.html', "whatever",		"dir->make creates an index file");

my $f = MMGal::Formatter->new;
my $rt = $f->format($d);
text_ok($rt, 'empty',					"contains dir name");
