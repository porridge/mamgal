#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 8;
use Test::Exception;
use Test::Files;
use lib 'testlib';
use MMGal::TestHelper;

prepare_test_data;

use_ok('MMGal::Entry::NonPicture');

# test parameter checks (same as Entry)
dies_ok(sub { MMGal::Entry::NonPicture->new },                          "NonPicture dies on creation with no args");
dies_ok(sub { MMGal::Entry::NonPicture->new('td/empty_file') },         "NonPicture dies on creation with just one arg");
dies_ok(sub { MMGal::Entry::NonPicture->new(qw(td empty_file), 2, 3) }, "NonPicture dies on creation with more than 3 args");

my $n;
lives_ok(sub { $n = MMGal::Entry::NonPicture->new(qw(td empty_file)) }, "NonPicture can be created with one existant non-picture");
isa_ok($n, 'MMGal::Entry::NonPicture',                                  "Newly created NonPicture is correct class");
use_ok('MMGal::Formatter');
lives_ok(sub { MMGal::Formatter->new->entry_cell($n) },                 "NonPicture can be interrogated as an entry cell target");

