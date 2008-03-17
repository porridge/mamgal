#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 13;
use Test::Exception;
use Test::Files;

system('rm -rf td ; cp -a td.in td');

use_ok('MMGal::Entry::Dir');
my $d;
lives_ok(sub { $d = MMGal::Entry::Dir->new(qw(td one_pic)) },		"dir can be created with one arg - existant dir with one pic");
isa_ok($d, 'MMGal::Entry::Dir');
my @ret = $d->elements;
is(scalar(@ret), 1,						"dir contains one element");
isa_ok($ret[0], 'MMGal::Entry::Picture');
is($ret[0]->element_index, 0,					"picture knows its index");

my ($prev, $next);
dies_ok(sub { ($prev, $next) = $d->neighbours_of_index(1) },	"there is no index one");
lives_ok(sub { ($prev, $next) = $d->neighbours_of_index(0) },	"there is index zero");
ok(not(defined($prev)),						"there is no prev neighbour");
ok(not(defined($next)),						"there is no next neighbour");

dir_only_contains_ok('td/one_pic', [qw(a1.png)],
								"Only the picture at start");
use MMGal::Formatter;
my $f = MMGal::Formatter->new;
lives_ok(sub { $d->make($f) },					"dir makes stuff and survives");

dir_only_contains_ok('td/one_pic', [qw(medium thumbnails slides index.html index.png mmgal.css
					a1.png
					thumbnails/a1.png
					medium/a1.png
					slides/a1.png.html)],
								"index, picture, thumbnail, medium and slides");

