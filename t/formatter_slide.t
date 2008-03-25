#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 9;
use Test::HTML::Content;
use Test::Exception;

system('rm -rf td ; cp -a td.in td');

use MMGal::Formatter;
use MMGal::Entry::Picture;
use MMGal::EntryFactory;
my $f = MMGal::Formatter->new;
my $d = MMGal::EntryFactory->create_entry_for('td/one_pic');
my $p = ($d->elements)[0];

dies_ok(sub { $f->format_slide },				"dies with no arg");
dies_ok(sub { $f->format_slide(1) },				"dies non pic arg");
dies_ok(sub { $f->format_slide($p, 2) },			"dies with > 1 arg");
my $t;
lives_ok(sub { $t = $f->format_slide($p) },			"lives with a pic arg");
tag_ok($t, "img", {src => '../medium/a1.png'},
								"there is a medium pic on the page");
tag_count($t, "img", {}, 1,					"just one img tag");
tag_ok($t, "a", {href => '../index.html'},			"there is a link up on the page");
tag_ok($t, "a", {href => '../a1.png'},				"there is a link to image itself");
tag_count($t, "a", {}, 2,					"two links");
