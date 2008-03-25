#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 15;
use Test::HTML::Content;
use Test::Exception;

system('rm -rf td ; cp -a td.in td');

use MMGal::Formatter;
use MMGal::EntryFactory;
my $f = MMGal::Formatter->new;

my $d = MMGal::EntryFactory->create_entry_for('td/one_pic');
my $t;
lives_ok(sub { $t = $f->format($d) },             "formatter formats index page with one picture");
tag_ok($t, "a", { href => 'slides/a1.png.html' }, "there is a link to the slide");
tag_ok($t, "img", { src => 'thumbnails/a1.png' }, "there is a pic on the page");

my $p = MMGal::EntryFactory->create_entry_for('td/one_pic/a1.png');
dies_ok(sub { $f->format_slide },                 "dies with no arg");
dies_ok(sub { $f->format_slide(1) },              "dies non pic arg");
dies_ok(sub { $f->format_slide($p, 2) },          "dies with > 1 arg");
my $st;
lives_ok(sub { $st = $f->format_slide($p) },      "formatter formats a slide");
tag_ok($st, "img", {src => '../medium/a1.png'},   "there is a medium pic on the page");
tag_count($st, "img", {}, 1,                      "just one img tag");
tag_ok($st, "a", {href => '../index.html'},       "there is a link up on the page");
tag_ok($st, "a", {href => '../a1.png'},           "there is a link to image itself");
tag_count($st, "a", {}, 2,                        "two links");
like($st, qr/Another test image\./,               "contains description");

my $p_dir = ($d->elements)[0];
my $st2;
lives_ok(sub { $st2 = $f->format_slide($p_dir) }, "formatter formats a slide");
is($st, $st2,                                     "slide is the same for both kinds of picture access");

