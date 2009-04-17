#!/usr/bin/perl
# mamgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Carp 'verbose';
use Test::More tests => 5;
use Test::Files;
use Test::HTML::Content;
use lib 'testlib';
use MaMGal::TestHelper;
use Image::EXIF::DateTimeParser;
use MaMGal::ImageInfo;

prepare_test_data;

dir_only_contains_ok('td/one_pic', ['a1.png'],
						"index does not exist initially");
use MaMGal::Maker;
use MaMGal::Formatter;
use MaMGal::MplayerWrapper;
use Image::EXIF::DateTimeParser;
my $m = MaMGal::Maker->new(MaMGal::Formatter->new, MaMGal::MplayerWrapper->new, Image::EXIF::DateTimeParser->new);
ok($m->make_without_roots('td/one_pic'),		"maker returns success on an dir with one file");
dir_only_contains_ok('td/one_pic', [qw(index.html .mamgal-index.png .mamgal-style.css .mamgal-medium .mamgal-thumbnails .mamgal-slides
					a1.png
					.mamgal-medium/a1.png
					.mamgal-thumbnails/a1.png
					.mamgal-slides/a1.png.html)],
						"maker created index.html, .mamgal-medium, .mamgal-thumbnails and .mamgal-slides");

unlink('td/one_pic/a1.png') or die;
$m = MaMGal::Maker->new(MaMGal::Formatter->new, MaMGal::MplayerWrapper->new, Image::EXIF::DateTimeParser->new);
ok($m->make_without_roots('td/one_pic'),		"maker returns success on an dir with one file");
dir_only_contains_ok('td/one_pic', [qw(index.html .mamgal-index.png .mamgal-style.css)], "maker deleted .mamgal-medium, .mamgal-thumbnails and .mamgal-slides");
