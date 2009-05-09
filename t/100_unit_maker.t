#!/usr/bin/perl
# mamgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Carp 'verbose';
use Test::More tests => 9;
use Test::Exception;
use Test::Files;
use lib 'testlib';
use MaMGal::TestHelper;

prepare_test_data;

use_ok('MaMGal::Maker');
my $m;
dies_ok(sub { MaMGal::Maker->new },		"maker creation fails with no arg");

use MaMGal::Formatter;
my $f = MaMGal::Formatter->new;
use MaMGal::MplayerWrapper;
my $w = MaMGal::MplayerWrapper->new;
use Image::EXIF::DateTime::Parser;
my $p = Image::EXIF::DateTime::Parser->new;
lives_ok(sub { $m = MaMGal::Maker->new($f, $w, $p) },"maker creation succeeds with formatter, wrapper and parser args");
isa_ok($m, 'MaMGal::Maker');

dies_ok(sub { $m->make() },			"maker dies on no args");
dies_ok(sub { $m->make('td/nonexistant')},	"maker dies on an inexistant dir");
dir_only_contains_ok('td/empty', [],		"directory is empty initially");
ok($m->make_without_roots('td/empty'),		"maker returns success on an empty dir");
dir_only_contains_ok('td/empty', [qw(index.html .mamgal-index.png .mamgal-style.css)],
						"directory contains index files only after running");
