#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007-2009 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Carp 'verbose';
use Test::More tests => 28;
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
$le->mock('format_time', sub { $_[1] == 1227684276 ? '12:00:00' : '13:13:13' });
$le->mock('format_date', sub { $_[1] == 1227684276 ? '18 gru 2004' : '2 kwi 2004' });

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

my $mp = Test::MockObject->new;
$mp->set_isa('MMGal::Picture::Static');
my $time = 1227684276;
$mp->mock('creation_time', sub { $time });
$mp->mock('page_path', sub { 'page_path' });
$mp->mock('thumbnail_path', sub { 'tn_path' });
$mp->mock('description', sub { 'some description' });
$mp->mock('name', sub { 'foobar' });
my $cell;
lives_ok(sub { $cell = $f->entry_cell($mp) },		"formatter can format a cell");
ok($mp->called('creation_time'),			"formatter interrogated the entry for creation time");
ok($le->called('format_time'),				"formatter interrogated the locale env for time formatting");
ok($le->called('format_date'),				"formatter interrogated the locale env for date formatting");
tag_ok($cell, 'span', { 'class' => 'time', _content => '12:00:00' }, "generated cell contains creation time");
tag_ok($cell, 'span', { 'class' => 'date', _content => '18 gru 2004' }, "generated cell contains creation date");

my $mp2 = Test::MockObject->new;
$mp2->set_isa('MMGal::Picture::Static');
my ($time1, $time2) = (1080907993, 1227684276);
$mp2->mock('creation_time', sub { ($time1, $time2) });
$mp2->mock('page_path', sub { 'page_path' });
$mp2->mock('thumbnail_path', sub { 'tn_path' });
$mp2->mock('description', sub { 'some description' });
$mp2->mock('name', sub { 'foobar' });
my $cell2;
lives_ok(sub { $cell2 = $f->entry_cell($mp2) },		"formatter can format a cell");
ok($mp2->called('creation_time'),			"formatter interrogated the entry for creation time");
ok($le->called('format_time'),				"formatter interrogated the locale env for time formatting");
ok($le->called('format_date'),				"formatter interrogated the locale env for date formatting");
tag_ok($cell2, 'span', { 'class' => 'time', _content => '12:00:00' }, "generated cell contains creation time");
tag_ok($cell2, 'span', { 'class' => 'date', _content => '18 gru 2004' }, "generated cell contains creation date");
tag_ok($cell2, 'span', { 'class' => 'time', _content => '13:13:13' }, "generated cell contains creation time");
tag_ok($cell2, 'span', { 'class' => 'date', _content => '2 kwi 2004' }, "generated cell contains creation date");

