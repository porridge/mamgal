#!/usr/bin/perl
# mamgal - a program for creating static image galleries
# Copyright 2007-2012 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Carp 'verbose';
use Test::More tests => 6;
use Test::Files;
use Test::HTML::Content;
use lib 'testlib';
use App::MaMGal::TestHelper;

prepare_test_data;

dir_only_contains_ok('td/one_anim', ['anim.gif'], "index does not exist initially");

use_ok('App::MaMGal');
my $M = App::MaMGal->new;

ok($M->make_without_roots('td/one_anim'),		"maker returns success on an dir with one file");
dir_only_contains_ok('td/one_anim', [qw(index.html .mamgal-index.png .mamgal-medium .mamgal-thumbnails .mamgal-slides
					anim.gif
					.mamgal-medium/anim.gif
					.mamgal-thumbnails/anim.gif
					.mamgal-slides/anim.gif.html)],
						"maker created index.html, .mamgal-medium, .mamgal-thumbnails and .mamgal-slides");

unlink('td/one_anim/anim.gif') or die;

$M = App::MaMGal->new;
ok($M->make_without_roots('td/one_anim'),		"maker returns success on an dir with one file");
dir_only_contains_ok('td/one_anim', [qw(index.html .mamgal-index.png)], "maker deleted .mamgal-medium, .mamgal-thumbnails and .mamgal-slides");
