#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 9;
use Test::Exception;
use Test::HTML::Content;
use lib 'testlib';
use MMGal::TestHelper;

prepare_test_data;

use_ok('MMGal::Formatter');
my $f;
lives_ok(sub { $f = MMGal::Formatter->new },		"formatter can be created without any arg");
isa_ok($f, 'MMGal::Formatter');

use MMGal::EntryFactory;
my $d = MMGal::EntryFactory->create_entry_for('td/empty');
dies_ok(sub { $f->format },                             "dies with no args");
dies_ok(sub { $f->format(1) },                          "dies with non-dir arg");
dies_ok(sub { $f->format($d, 1) },                      "dies with more than one arg");
my $t = $f->format($d);
no_tag($t, "img", {},					"the resulting page has no pics");
tag_ok($t, "td", { _content => MMGal::Formatter->EMPTY_PAGE_TEXT },
							"the resulting page has a cell");
link_ok($t, "../index.html",				"the resulting page has a link down");
