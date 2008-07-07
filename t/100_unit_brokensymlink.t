#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 10;
use Test::Exception;
use Test::Files;
use lib 'testlib';
use MMGal::TestHelper;
use File::stat;

prepare_test_data;

use_ok('MMGal::Entry::BrokenSymlink');

# test parameter checks (same as Entry)
dies_ok(sub { MMGal::Entry::BrokenSymlink->new },                          "BrokenSymlink dies on creation with no args");
dies_ok(sub { MMGal::Entry::BrokenSymlink->new('td/symlink_broken') },     "BrokenSymlink dies on creation with just one arg");
dies_ok(sub { MMGal::Entry::BrokenSymlink->new(qw(td symlink_broken), lstat('td/symlink_broken'), 3) }, "BrokenSymlink dies on creation with more than 3 args");

my $b;
lives_ok(sub { $b = MMGal::Entry::BrokenSymlink->new(qw(td symlink_broken)) }, "BrokenSymlink can be created with one existant broken symlink");
isa_ok($b, 'MMGal::Entry::BrokenSymlink',                                  "Newly created BrokenSymlink is correct class");
use_ok('MMGal::Formatter');
lives_ok(sub { MMGal::Formatter->new->entry_cell($b) },                    "BrokenSymlink can be interrogated as an entry cell target");
my $time;
lives_ok(sub { $time = $b->creation_time },                                "BrokenSymlink can be interrogated for creation time");
is($time, undef,                                                           "Creation time returned by a broken symlink is undefined");

