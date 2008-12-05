#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 3;
use Test::Files;
use Test::HTML::Content;
use lib 'testlib';
use MMGal::TestHelper;

prepare_test_data;

dir_only_contains_ok('td/one_film', ['m.mov'],
						"index does not exist initially");
use MMGal::Maker;
use MMGal::Formatter;
my $m = MMGal::Maker->new(MMGal::Formatter->new);
ok($m->make_without_roots('td/one_film'),	"maker returns success on an dir with one film");
dir_only_contains_ok('td/one_film', [qw(index.html index.png mmgal.css thumbnails slides
					m.mov
					thumbnails/m.mov.jpg
					slides/m.mov.html)],
						"maker created index.html, thumbnail and slides");
