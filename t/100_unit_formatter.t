#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 14;
use Test::Exception;
use Test::HTML::Content;
use lib 'testlib';
use MMGal::TestHelper;
use MMGal::LocaleEnv;

prepare_test_data;

use_ok('MMGal::Formatter');
my $f;
lives_ok(sub { $f = MMGal::Formatter->new },		"formatter can be created without any arg");
dies_ok(sub { MMGal::Formatter->new(1) },		"formatter can not be created some junk parameter");

my $le = Test::MockObject->new;
$le->set_isa('MMGal::LocaleEnv');
$le->mock('get_charset', sub { 'UTF-8' });

lives_ok(sub { $f->set_locale_env($le) },               "Formatter accepts a set_locale_env call");
lives_ok(sub { $f = MMGal::Formatter->new($le) },	"formatter can be created with a locale env parameter");
isa_ok($f, 'MMGal::Formatter');

use MMGal::EntryFactory;
my $d = MMGal::EntryFactory->create_entry_for('td/empty');
dies_ok(sub { $f->format },                             "dies with no args");
dies_ok(sub { $f->format(1) },                          "dies with non-dir arg");
dies_ok(sub { $f->format($d, 1) },                      "dies with more than one arg");
my $t;
lives_ok(sub { $t = $f->format($d) },                   "formatter survives dir page creation");
tag_ok($t, 'meta', { 'http-equiv' => "Content-Type", 'content' => "text/html; charset=UTF-8" }, "generated dir page contains charset declaration");
no_tag($t, "img", {},					"the resulting page has no pics");
tag_ok($t, "td", { _content => MMGal::Formatter->EMPTY_PAGE_TEXT },
							"the resulting page has a cell");
link_ok($t, "../index.html",				"the resulting page has a link down");
