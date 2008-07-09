#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 25;
use Test::Exception;
use lib 'testlib';
use MMGal::TestHelper;
use File::stat;

prepare_test_data;

use_ok('MMGal::Entry');

# test parameter checks
dies_ok(sub { MMGal::Entry->new },				"Entry dies on creation with no args");
dies_ok(sub { MMGal::Entry->new('/') },                         "Entry dies on creation with one arg");
dies_ok(sub { MMGal::Entry->new(qw(td empty_file), 1) },        "Entry dies on creation with third argument not being a File::stat");
my $stat = stat('td/empty_file');
dies_ok(sub { MMGal::Entry->new(qw(td empty_file), $stat, 3) },	"Entry dies on creation with more than 3 args");
my $e;
lives_ok(sub { $e = MMGal::Entry->new(qw(td empty)) },		"Entry can be created with one existant dir arg");
isa_ok($e, 'MMGal::Entry');
my $n;
lives_ok(sub { $n = $e->name },					"Entry knows its name");
is($n, 'empty',							"Entry name is ok");
lives_ok(sub { $e = MMGal::Entry->new(qw(td empty_file)) },	"Entry can be created with one existant file arg");
isa_ok($e, 'MMGal::Entry');
lives_ok(sub { $n = $e->name },					"Entry knows its name");
is($n, 'empty_file',						"Entry name is ok");
my $dir;
lives_ok(sub { $dir = $e->container },                          "Entry returns its container");
isa_ok($dir, 'MMGal::Entry::Dir',                               "Entry's container is a dir");

dies_ok(sub { MMGal::Entry->new(qw(td/empty .)) },              "Entry refuses to be created with '.' as the basename, when a name could have been provided");
dies_ok(sub { MMGal::Entry->new(qw(. td/empty)) },              "Entry refuses to be created with basename containing a slash");

# stat functionality
my $fake_stat = Test::MockObject->new;
$fake_stat->set_isa('File::stat');
$fake_stat->mock('mtime', sub { 'fake_timestamp' });
my $entry_with_stat;
lives_ok(sub { $entry_with_stat = MMGal::Entry->new(qw(td empty_file), $fake_stat) }, "Entry survives creation with a fake stat");
my $ct;
lives_ok(sub { $ct = $entry_with_stat->creation_time },         "Entry returns the a (mocked) creation time");
is($ct, 'fake_timestamp',                                       "Returned creation time is the mocked mtime");

my $entry_no_stat;
lives_ok(sub { $entry_no_stat = MMGal::Entry->new(qw(td empty_file)) }, "Entry survives creation without a stat object");
my $time = time;
utime($time, $time, 'td/empty_file') == 1 or die "Failed to touch file";
my $ret_time;
lives_ok(sub { $ret_time = $entry_no_stat->creation_time },     "Entry returns some creation time, even if a stat object was not passed on construction");
is($ret_time, $time,                                            "Returned creation time is correct");
my $time2 = $time + 10;
utime($time2, $time2, 'td/empty_file') == 1 or die "Failed to touch file";
lives_ok(sub { $ret_time = $entry_no_stat->creation_time },     "Entry returns some creation time, even if a stat object was not passed on construction");
is($ret_time, $time,                                            "Returned creation time is cached");

