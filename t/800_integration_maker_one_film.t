#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Carp 'verbose';
use Test::More tests => 3;
use Test::Files;
use Test::HTML::Content;
use lib 'testlib';
use MMGal::TestHelper;

prepare_test_data;

dir_only_contains_ok('td/one_film', ['m.mov'],
						"index does not exist initially");
use MMGal::Maker;
use MMGal::Formatter;
use MMGal::MplayerWrapper;
use Image::EXIF::DateTimeParser;
my $m = MMGal::Maker->new(MMGal::Formatter->new, MMGal::MplayerWrapper->new, Image::EXIF::DateTimeParser->new);
ok($m->make_without_roots('td/one_film'),	"maker returns success on an dir with one film");
dir_only_contains_ok('td/one_film', [qw(index.html .mmgal-index.png .mmgal-style.css .mmgal-thumbnails .mmgal-slides
					m.mov
					.mmgal-thumbnails/m.mov.jpg
					.mmgal-slides/m.mov.html)],
						"maker created index.html, .mmgal-thumbnails and .mmgal-slides");
