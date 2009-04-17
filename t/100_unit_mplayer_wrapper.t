#!/usr/bin/perl
# mamgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Carp 'verbose';
use Test::More tests => 9;
use Test::Exception;
use Test::HTML::Content;
use lib 'testlib';
use MaMGal::TestHelper;
use MaMGal::LocaleEnv;
use Image::Magick;

prepare_test_data;

use_ok('MaMGal::MplayerWrapper');
my $w;
lives_ok(sub { $w = MaMGal::MplayerWrapper->new },	"wrapper can be created without any arg");
dies_ok(sub { MaMGal::MplayerWrapper->new(1) },		"wrapper can not be created with some junk parameter");

my ($snap, $err);
dies_ok(sub { $snap = $w->snapshot() },				"wrapper cannot get a snapshot of undef");
dies_ok(sub { $snap = $w->snapshot('td/notthere.mov') },	"wrapper cannot get a snapshot of an inexistant file");
dies_ok(sub { $snap = $w->snapshot('td/c.jpg') },		"wrapper cannot survive snapshotting a non-film file");
like($@, qr/Mplayer STDOUT/,					"invalid file produces some error messages");
lives_ok(sub { $snap = $w->snapshot('td/one_film/m.mov') },	"wrapper can get a snapshot of a film file");
isa_ok($snap, 'Image::Magick',					"snapshot");
