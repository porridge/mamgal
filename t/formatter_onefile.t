#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 2;
use Test::HTML::Content;

system('rm -rf td ; cp -a td.in td');

use MMGal::Formatter;
use MMGal::EntryFactory;
my $f = MMGal::Formatter->new;
my $d = MMGal::EntryFactory->create_entry_for('td/one_pic');
my $t = $f->format($d);
tag_ok($t, "a", { href => 'slides/a1.png.html' },
									"there is a link to the slide");
tag_ok($t, "img", { src => 'thumbnails/a1.png' },
									"there is a pic on the page");

