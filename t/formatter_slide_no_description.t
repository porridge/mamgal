#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 7;
use Test::HTML::Content;
use Test::Exception;

system('rm -rf td ; cp -a td.in td');

use MMGal::Formatter;
use MMGal::Entry::Picture;
use MMGal::Entry::Dir;
my $f = MMGal::Formatter->new;
my $d = MMGal::Entry::Dir->new('td/more', 'zzz another subdir');
# this is p.png, which has no description
my $p = ($d->elements)[0];

my $st;
lives_ok(sub { $st = $f->format_slide($p) },		"lives with a pic arg");
text_ok($st, 'p.png',					"slide contains filename");
for my $n ('td', 'more', 'zzz another subdir') {
	text_ok($st, $n,				"slide contains parent filename");
}

my $ct;
lives_ok(sub { $ct = $f->entry_cell($p) },		"lives through cell entry generation");
text_ok($ct, 'p.png',					"cell contains filename");
