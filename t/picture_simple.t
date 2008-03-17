#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 11;
use Test::Exception;
use Test::Files;

system('rm -rf td ; cp -a td.in td');

use_ok('MMGal::EntryFactory');
dies_ok(sub { MMGal::EntryFactory->create_entry_for(qw(td/one_pic), 2, 3) },
							"Dir dies on creation with more than 3 args");

my $d;
lives_ok(sub { $d = MMGal::EntryFactory->create_entry_for(qw(td/one_pic)) },
							"Dir can be created with one existant picture arg");
isa_ok($d, 'MMGal::Entry::Dir');
my $p = ($d->elements)[0];
my @n;
lives_ok(sub { @n = $p->neighbours; },			"lonely picture lives on neighbours call in list context");
is(scalar @n, 2,					"neighbours call returns 2 undefs");
ok(! defined $n[0],					"return is undef");
ok(! defined $n[1],					"return is undef");

dir_only_contains_ok('td/one_pic', [qw(a1.png)],
							"Only the picture at start");
lives_ok(sub { $p->refresh_medium_and_thumbnail },	"Lives through refresh_medium_and_thumbnail");
dir_only_contains_ok('td/one_pic', [qw(medium thumbnails a1.png
					thumbnails/a1.png
					medium/a1.png)],
							"Picture and thumbnail and medium after");

