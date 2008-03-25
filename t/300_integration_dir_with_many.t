#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 24;
use Test::Exception;
use Test::Files;

system('rm -rf td ; cp -a td.in td');

use_ok('MMGal::Entry::Dir');
my $d;
lives_ok(sub { $d = MMGal::Entry::Dir->new(qw(td more)) },	"creation ok");
isa_ok($d, 'MMGal::Entry::Dir',                                 "a dir is a dir");
my @ret = $d->elements;
is(scalar(@ret), 5,						"dir contains 5 elements");
# read ordering
isa_ok($ret[0], 'MMGal::Entry::Picture');
is($ret[0]->element_index, 0, 					"pic 0 knows its element index");
isa_ok($ret[1], 'MMGal::Entry::Picture');
is($ret[1]->element_index, 1, 					"pic 1 knows its element index");
isa_ok($ret[2], 'MMGal::Entry::Dir');
is($ret[2]->element_index, 2, 					"pic 2 knows its element index");
isa_ok($ret[3], 'MMGal::Entry::Picture');
is($ret[3]->element_index, 3, 					"pic 3 knows its element index");

my ($prev, $next);
lives_ok(sub { ($prev, $next) = $d->neighbours_of_index(0) },	"there is index zero");
ok(not(defined($prev)),						"there is no prev neighbours for 1st element");
ok(defined($next),						"there is next neighbour for 1st element");
is($next, $ret[1],						"next after 1st is 2nd");
lives_ok(sub { ($prev, $next) = $d->neighbours_of_index(1) },	"there is index one");
ok(defined $prev && defined $next,				"there is both prev and next neighbour for 2nd element");
is($prev, $ret[0],						"prev before 2nd is 1st");
is($next, $ret[3],						"next after 2nd is 3rd pic (4th element)");

my $subdir = $ret[2];
is($subdir->container, $d,					"container of dir's subdir is dir");

my $topdir;
lives_ok(sub { $topdir = $d->container },			"a dir can return its container");
isa_ok($topdir, 'MMGal::Entry::Dir',				"dir's container is a dir");
is($topdir->name, 'td',						"dir's parent name is correct");
