#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Carp 'verbose';
use Test::More tests => 5;
use Test::Files;
use Test::HTML::Content;
use lib 'testlib';
use MMGal::TestHelper;
use Image::EXIF::DateTimeParser;

prepare_test_data;

dir_only_contains_ok('td/one_pic', ['a1.png'],
						"index does not exist initially");
use MMGal::Maker;
use MMGal::Formatter;
use MMGal::MplayerWrapper;
use Image::EXIF::DateTimeParser;
my $m = MMGal::Maker->new(MMGal::Formatter->new, MMGal::MplayerWrapper->new, Image::EXIF::DateTimeParser->new);
ok($m->make_without_roots('td/one_pic'),		"maker returns success on an dir with one file");
dir_only_contains_ok('td/one_pic', [qw(index.html index.png mmgal.css medium thumbnails slides
					a1.png
					medium/a1.png
					thumbnails/a1.png
					slides/a1.png.html)],
						"maker created index.html, medium, thumbnail and slides");

unlink('td/one_pic/a1.png') or die;
$m = MMGal::Maker->new(MMGal::Formatter->new, MMGal::MplayerWrapper->new, Image::EXIF::DateTimeParser->new);
ok($m->make_without_roots('td/one_pic'),		"maker returns success on an dir with one file");
dir_only_contains_ok('td/one_pic', [qw(index.html index.png mmgal.css)], "maker deleted medium, thumbnail and slides");
