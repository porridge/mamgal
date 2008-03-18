#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 6;
use Test::HTML::Content;

system('rm -rf td ; cp -a td.in td');

use MMGal::Formatter;
use MMGal::Entry::Dir;
my $f = MMGal::Formatter->new;
my $d = MMGal::EntryFactory->create_entry_for('td/one_dir');
$d->set_root(1);
my $t = $f->format($d);
text_ok($t, 'one_dir',					"there is the directory name");
tag_count($t, "a", { href => 'subdir/index.html' }, 2,	"there are two links to the subdir");
tag_ok($t, "img", { src => 'subdir/index.png' },	"there is a pic on the page");
no_tag($t, "a", { href => "../index.html" },		"there is no link down");

my $tsub = $f->format(($d->elements)[0]);
no_tag($tsub, "img", {},				"subdir index has no pics");
link_ok($tsub, "../index.html",				"subdir has link down");
