#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007-2009 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 3;
use Test::Files;
use Test::HTML::Content;
use lib 'testlib';
use MMGal::TestHelper;

prepare_test_data;

dir_only_contains_ok('td/more', [qw(a.png b.png x.png subdir subdir/p.png subdir/p2.png subdir/lost+found),
                                 'zzz another subdir', 'zzz another subdir/p.png'], "not much exists initially");
use MMGal::Maker;
use MMGal::Formatter;
use MMGal::MplayerWrapper;
use MMGal::LocaleEnv;
my $l = MMGal::LocaleEnv->new;
# Get locale from environment so that you can see some representatative output in your language
$l->set_locale('');
my $m = MMGal::Maker->new(MMGal::Formatter->new($l), MMGal::MplayerWrapper->new);
ok($m->make_roots('td/more'),			"maker returns success on an dir with some files");
dir_only_contains_ok('td/more', [qw(.mmgal-root
					index.html index.png mmgal.css
					medium thumbnails slides
					a.png b.png x.png
					medium/a.png medium/b.png medium/x.png
					thumbnails/a.png thumbnails/b.png thumbnails/x.png
					slides/a.png.html slides/b.png.html slides/x.png.html
					subdir subdir/p.png subdir/p2.png subdir/lost+found
					subdir/index.html subdir/index.png subdir/mmgal.css
					subdir/medium subdir/medium/p.png subdir/medium/p2.png
					subdir/thumbnails subdir/thumbnails/p.png
					subdir/thumbnails/p2.png
					subdir/slides subdir/slides/p.png.html
					subdir/slides/p2.png.html),
					'zzz another subdir', 'zzz another subdir/index.png', 'zzz another subdir/index.html',
					'zzz another subdir/p.png', 'zzz another subdir/mmgal.css', 'zzz another subdir/slides',
					'zzz another subdir/slides/p.png.html', 'zzz another subdir/thumbnails',
					'zzz another subdir/thumbnails/p.png', 'zzz another subdir/medium',
					'zzz another subdir/medium/p.png'
					],
						"maker created index.html, medium, thumbnail and slides, also for both subdirs");
