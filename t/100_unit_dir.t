#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 34;
use Test::Exception;
use Test::Files;
use Test::HTML::Content;
use MMGal::Formatter;
use lib 'testlib';
use MMGal::TestHelper;

prepare_test_data;

use_ok('MMGal::Entry::Dir');

# test parameter checks (same as Entry)
dies_ok(sub { MMGal::Entry::Dir->new },                      "Dir dies on creation with no args");
dies_ok(sub { MMGal::Entry::Dir->new('td') },                "Dir dies on creation with just one arg");
dies_ok(sub { MMGal::Entry::Dir->new(qw(td empty), 2, 3) },  "Dir dies on creation with more than 3 args");

# test reading empty dir
my $d;
lives_ok(sub { $d = MMGal::Entry::Dir->new(qw(td empty)) },  "Dir can be created with one existant dir arg");

# test some properties of an empty dir
isa_ok($d, 'MMGal::Entry::Dir',                              "Freshly created dir is a dir");
ok(! $d->is_root,                                            "Freshly created dir is not a root");
dies_ok(sub { $d->neighbours_of_index(0) },                  "No neighbours of first index in an empty dir, because there is no such index");
dies_ok(sub { $d->neighbours_of_index(1) },                  "No neighbours of second index in an empty dir, because there is no such index");

# test dir behaviour on "make()"
dies_ok(sub { $d->make },                                    "Dir dies on make invocation with no arg");

dir_only_contains_ok('td/empty', [],                         "Directory is empty initially");
my $mf = get_mock_formatter(qw(format stylesheet));
lives_ok(sub { $d->make($mf) },                              "Dir lives on make invocation with a formatter");
ok($mf->called('format'),                                    "Dir->make calls formatter->format internally");
ok($mf->called('stylesheet'),                                "Dir->make calls formatter->stylesheet internally");
dir_only_contains_ok('td/empty', [qw{index.html index.png mmgal.css}],
                                                             "Directory contains only the index file and thumb afterwards");
file_ok('td/empty/index.html', "whatever",                   "Dir->make creates an index file");

# test root and containers on a deeply nested dir
my $deep_dir;
lives_ok(sub { $deep_dir = MMGal::Entry::Dir->new(qw(td/more subdir)) }, "Dir can be created with one existant dir arg");
isa_ok($deep_dir, 'MMGal::Entry::Dir',                                   "A dir is a dir");
ok(! $deep_dir->is_root,                                                 "Freshly created dir is not a root");
is_deeply([map { $_->name } $deep_dir->containers], [qw(td more)],       "Non-root directory has some container names, in correct order");

# test root property on a dir already tagged as root
my $rd;
lives_ok(sub { $rd = MMGal::Entry::Dir->new(qw(td root_dir)) }, "Dir can be created with a root-marked dir arg");
isa_ok($rd, 'MMGal::Entry::Dir',                                "A dir is a dir");
ok($rd->is_root,                                                "Freshly created root dir is root");
is_deeply([($rd->containers)], [],                              "Root directory has no container names");

# test root properties on a absolutely referenced subdir of a root dir and its contaienr
my $bd;
lives_ok(sub { $bd = MMGal::Entry::Dir->new(qw(/ bin)) }, "Dir can be created with a toplevel dir arg");
isa_ok($bd, 'MMGal::Entry::Dir',                          "A dir is a dir");
ok(! $bd->is_root,                                        "Freshly created dir is not a root");
ok($bd->container->is_root,                               "Toplevel dir's container is root");

# test root property on the real "/" root
my $Rd;
lives_ok(sub { $Rd = MMGal::Entry::Dir->new(qw(/ .)) },	"Dir can be created with the / dir");
isa_ok($Rd, 'MMGal::Entry::Dir',                        "A dir is a dir");
ok($Rd->is_root,					"Freshly created root dir is root");

# test creation of the current directory
my $cd;
lives_ok(sub { $cd = MMGal::Entry::Dir->new(qw(. .)) }, "Dir can be created with the . dir");
isa_ok($cd, 'MMGal::Entry::Dir',                        "A dir is a dir");
ok(! $cd->is_root,                                      "Freshly created root dir is not a root");

