#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 6;
use Test::Exception;
use Test::HTML::Content;

system('rm -rf td ; cp -a td.in td');

use_ok('MMGal::Formatter');
my $f;
lives_ok(sub { $f = MMGal::Formatter->new },		"formatter can be created without any arg");
isa_ok($f, 'MMGal::Formatter');
use MMGal::Entry::Dir;
my $d = MMGal::Entry::Dir->new(qw(td empty));
my $t = $f->format($d);
no_tag($t, "img", {},					"the resulting page has no pics");
tag_ok($t, "h1", { _content => MMGal::Formatter->EMPTY_PAGE_TEXT },
							"the resulting page has a special header");
link_ok($t, "../index.html",				"the resulting page has a link down");
