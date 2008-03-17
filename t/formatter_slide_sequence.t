#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 9;
use Test::HTML::Content;

system('rm -rf td ; cp -a td.in td');

use MMGal::Formatter;
use MMGal::Entry::Picture;
use MMGal::Entry::Dir;
my $d = MMGal::Entry::Dir->new(qw(td more));
my $f = MMGal::Formatter->new;
my @elems = $d->elements;
my $p = $elems[1];
my $t = $f->format_slide($p);
tag_ok($t, "img", {src => '../medium/b.png'},		"b.png: there is a medium pic on the page");
tag_ok($t, "a", {href => '../index.html'},		"b.png: there is a link to the index on the page");
tag_ok($t, "a", {href => 'a.png.html'},			"b.png: there is a link to previous slide");
tag_ok($t, "a", {href => 'x.png.html'},			"b.png: there is a link to next slide");
tag_count($t, "a", {}, 3,				"b.png: there are only 3 links in total");
my $p2 = $elems[3];
my $t2 = $f->format_slide($p2);
tag_ok($t2, "img", {src => '../medium/x.png'},		"x.png: there is a medium pic on the page");
tag_ok($t2, "a", {href => '../index.html'},		"x.png: there is a link to the index on the page");
tag_ok($t2, "a", {href => 'b.png.html'},		"x.png: there is a link to previous slide");
tag_count($t2, "a", {}, 2,				"x.png: there are only 2 links in total");
