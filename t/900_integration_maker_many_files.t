#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007-2009 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Carp 'verbose';
use Test::More tests => 3;
use Test::Files;
use Test::HTML::Content;
use lib 'testlib';
use MMGal::TestHelper;
use MMGal::ImageInfo;

prepare_test_data;

dir_only_contains_ok('td/more', [qw(a.png b.png x.png subdir subdir/p.png subdir/p2.png subdir/lost+found),
                                 'zzz another subdir', 'zzz another subdir/p.png'], "not much exists initially");
use MMGal::Maker;
use MMGal::Formatter;
use MMGal::MplayerWrapper;
use Image::EXIF::DateTimeParser;

use MMGal::LocaleEnv;
my $l = MMGal::LocaleEnv->new;
# Get locale from environment so that you can see some representatative output in your language
$l->set_locale('');
my $m = MMGal::Maker->new(MMGal::Formatter->new($l), MMGal::MplayerWrapper->new, Image::EXIF::DateTimeParser->new);
ok($m->make_roots('td/more'),			"maker returns success on an dir with some files");
dir_only_contains_ok('td/more', [qw(.mmgal-root
					index.html index.png mmgal.css
					.mmgal-medium .mmgal-thumbnails .mmgal-slides
					a.png b.png x.png
					.mmgal-medium/a.png .mmgal-medium/b.png .mmgal-medium/x.png
					.mmgal-thumbnails/a.png .mmgal-thumbnails/b.png .mmgal-thumbnails/x.png
					.mmgal-slides/a.png.html .mmgal-slides/b.png.html .mmgal-slides/x.png.html
					subdir subdir/p.png subdir/p2.png subdir/lost+found
					subdir/index.html subdir/index.png subdir/mmgal.css
					subdir/.mmgal-medium subdir/.mmgal-medium/p.png subdir/.mmgal-medium/p2.png
					subdir/.mmgal-thumbnails subdir/.mmgal-thumbnails/p.png
					subdir/.mmgal-thumbnails/p2.png
					subdir/.mmgal-slides subdir/.mmgal-slides/p.png.html
					subdir/.mmgal-slides/p2.png.html),
					'zzz another subdir', 'zzz another subdir/index.png', 'zzz another subdir/index.html',
					'zzz another subdir/p.png', 'zzz another subdir/mmgal.css', 'zzz another subdir/.mmgal-slides',
					'zzz another subdir/.mmgal-slides/p.png.html', 'zzz another subdir/.mmgal-thumbnails',
					'zzz another subdir/.mmgal-thumbnails/p.png', 'zzz another subdir/.mmgal-medium',
					'zzz another subdir/.mmgal-medium/p.png'
					],
						"maker created index.html, .mmgal-medium, .mmgal-thumbnails and .mmgal-slides, also for both subdirs");
