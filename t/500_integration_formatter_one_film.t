#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 21;
use Test::HTML::Content;
use Test::Exception;
use lib 'testlib';
use MMGal::TestHelper;

prepare_test_data;

use MMGal::Formatter;
use MMGal::EntryFactory;
use MMGal::LocaleEnv;
my $le = MMGal::LocaleEnv->new;
$le->set_locale('C');
my $f = MMGal::Formatter->new($le);

#
# a dir with a single film
#

my $time = 1228933448;
utime($time, $time, 'td/one_film/m.mov') == 1 or die "Failed to touch file";
my $dir = MMGal::EntryFactory->create_entry_for('td/one_film');
# this is m.mov
my $mov = ($dir->elements)[0];
my $t;
lives_ok(sub { $t = $f->format($dir) },          "formatter formats index page with one film");
tag_ok($t, "a", { href => 'slides/m.mov.html' }, "there is a link to the slide");
tag_ok($t, "img", { src => 'thumbnails/m.mov.jpg' }, "there is a pic on the page");
text_ok($t, 'm.mov',                             "contains the filename alone");

dies_ok(sub { $f->format_slide },                   "dies with no arg");
dies_ok(sub { $f->format_slide(1) },                "dies non pic arg");
dies_ok(sub { $f->format_slide($mov, 2) },          "dies with > 1 arg");
my $st_mov;
lives_ok(sub { $st_mov = $f->format_slide($mov) },  "lives with a film arg");

text_ok($st_mov, 'm.mov',                           "slide contains filename");
for my $n ('td', 'one_film') {
	text_ok($st_mov, $n,                        "slide contains parent filenames");
}
no_tag($st_mov, "img",                              "there is not a medium pic on the page");
tag_ok($st_mov, "embed", {src => '../m.mov'},       "there is an embed tag on the page");
tag_count($st_mov, "embed", {}, 1,                  "just one embed tag");
tag_ok($st_mov, "a", {href => '../index.html'},     "there is a link up on the page");
tag_ok($st_mov, "a", {href => '../m.mov', _content => "Download"}, "there is a link to film itself");
tag_count($st_mov, "a", {}, 2,                      "two links in total");
tag_ok($st_mov, "span", {class => 'date', _content => '12/10/08'},"there is a date");
tag_ok($st_mov, "span", {class => 'time', _content => '18:24:08'},"there is a time");

my $ct_mov;
lives_ok(sub { $ct_mov = $f->entry_cell($mov) },   "lives through cell entry generation");
text_ok($ct_mov, 'm.mov',                           "cell contains filename");

