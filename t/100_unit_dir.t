#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 30;
use Test::Exception;
use Test::Files;
use Test::HTML::Content;
use MMGal::Formatter;
use lib 'testlib';
use MMGal::TestHelper;

system('rm -rf td ; cp -a td.in td');

use_ok('MMGal::Entry::Dir');

# test parameter checks
dies_ok(sub { MMGal::Entry::Dir->new },                      "dir dies on creation with no args");
dies_ok(sub { MMGal::Entry::Dir->new(qw(td empty), 2, 3) },  "dir dies on creation with more than 3 args");

# test reading empty dir
my $d;
lives_ok(sub { $d = MMGal::Entry::Dir->new(qw(td empty)) },  "dir can be created with one existant dir arg");

# test some properties of an empty dir
isa_ok($d, 'MMGal::Entry::Dir',                              "freshly created dir is a dir");
ok(! $d->is_root,                                            "freshly created dir is not a root");
dies_ok(sub { $d->neighbours_of_index(0) },                  "no neighbours of first index in an empty dir, because there is no such index");
dies_ok(sub { $d->neighbours_of_index(1) },                  "no neighbours of second index in an empty dir, because there is no such index");

# test dir behaviour on "make()"
dies_ok(sub { $d->make },                               "dir dies on make invocation with no arg");

dir_only_contains_ok('td/empty', [],                    "directory is empty initially");
my $mf = get_mock_formatter(qw(format stylesheet));
lives_ok(sub { $d->make($mf) },                         "dir lives on make invocation with a formatter");
ok($mf->called('format'),                               "dir->make calls formatter->format internally");
ok($mf->called('stylesheet'),                           "dir->make calls formatter->stylesheet internally");
dir_only_contains_ok('td/empty', [qw{index.html index.png mmgal.css}],
                                                        "directory contains only the index file and thumb afterwards");
file_ok('td/empty/index.html', "whatever",              "dir->make creates an index file");

# test root and containers on a deeply nested dir
my $deep_dir;
lives_ok(sub { $deep_dir = MMGal::Entry::Dir->new(qw(td/more subdir)) }, "dir can be created with one existant dir arg");
isa_ok($deep_dir, 'MMGal::Entry::Dir',                                   "a dir is a dir");
ok(! $deep_dir->is_root,                                                 "freshly created dir is not a root");
is_deeply([map { $_->name } $deep_dir->containers], [qw(td more)],       "non-root directory has some container names, in correct order");

# test root property on a dir already tagged as root
my $rd;
lives_ok(sub { $rd = MMGal::Entry::Dir->new(qw(td root_dir)) }, "dir can be created with a root-marked dir arg");
isa_ok($rd, 'MMGal::Entry::Dir',                                "a dir is a dir");
ok($rd->is_root,                                                "freshly created root dir is root");
is_deeply([($rd->containers)], [],                              "root directory has no container names");

# test root properties on a absolutely referenced subdir of a root dir and its contaienr
my $bd;
lives_ok(sub { $bd = MMGal::Entry::Dir->new(qw(/ bin)) }, "dir can be created with a toplevel dir arg");
isa_ok($bd, 'MMGal::Entry::Dir',                          "a dir is a dir");
ok(! $bd->is_root,                                        "freshly created dir is not a root");
ok($bd->container->is_root,                               "toplevel dir's container is root");

# test root property on the real "/" root
my $Rd;
lives_ok(sub { $Rd = MMGal::Entry::Dir->new(qw(/ /)) },	"dir can be created with the / dir");
isa_ok($Rd, 'MMGal::Entry::Dir',                        "a dir is a dir");
ok($Rd->is_root,					"freshly created root dir is root");

