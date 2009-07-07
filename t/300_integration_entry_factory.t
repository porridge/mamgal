#!/usr/bin/perl
# mamgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Carp 'verbose';
use Test::More tests => 36;
use Test::Exception;
use Test::Files;
use lib 'testlib';
use MaMGal::TestHelper;

prepare_test_data;

use_ok('MaMGal::EntryFactory');
my $ef;
dies_ok(sub { MaMGal::EntryFactory->new },                               "EF cannot be instantiated without arguments");
my ($mf, $mw, $mif) = (get_mock_formatter, get_mock_mplayer_wrapper, get_mock_iif);
dies_ok(sub { MaMGal::EntryFactory->new($mf, $mw) },                     "EF cannot be instantiated with just formatter, wrapper");
lives_ok(sub { $ef = MaMGal::EntryFactory->new($mf, $mw, $mif) },        "EF can be instantiated with formatter, wrapper, parser and image info factory");
my $e;
lives_ok(sub { $e = $ef->create_entry_for('td/empty_file') },            "EF creates entry from empty file");
isa_ok($e, 'MaMGal::Entry::NonPicture',                                  "expected entry is a NonPicture");
is($e->name, 'empty_file',                                               "file name matches");

lives_ok(sub { $e = $ef->create_entry_for('td/symlink_to_empty_file') }, "EF creates entry from symlink to empty file");
isa_ok($e, 'MaMGal::Entry::NonPicture',                                  "expected entry is a NonPicture");
is($e->name, 'symlink_to_empty_file',                                    "file name matches");

lives_ok(sub { $e = $ef->create_entry_for('td/empty') },                 "EF creates entry from empty dir");
isa_ok($e, 'MaMGal::Entry::Dir',                                         "expected entry is a Dir");
is($e->name, 'empty',                                                    "file name matches");

lives_ok(sub { $e = $ef->create_entry_for('td/symlink_to_empty') },      "EF creates entry from symlink to empty dir");
isa_ok($e, 'MaMGal::Entry::Dir',                                         "expected entry is a Dir");
is($e->name, 'symlink_to_empty',                                         "file name matches");

lives_ok(sub { $e = $ef->create_entry_for('td/symlink_broken') },        "EF creates entry from broken symlink");
isa_ok($e, 'MaMGal::Entry::BrokenSymlink',                               "expected entry is a BrokenSymlink");
is($e->name, 'symlink_broken',                                           "file name matches");

lives_ok(sub { $e = $ef->create_entry_for('td/one_pic/a1.png') },        "EF creates entry from a picture");
isa_ok($e, 'MaMGal::Entry::Picture::Static',                             "expected entry is a Picture::Static");
is($e->name, 'a1.png',                                                   "file name matches");

lives_ok(sub { $e = $ef->create_entry_for('td/symlink_pic.png') },       "EF creates entry from a symlink to picture");
isa_ok($e, 'MaMGal::Entry::Picture::Static',                             "expected entry is a Picture::Static");
is($e->name, 'symlink_pic.png',                                          "file name matches");

lives_ok(sub { $e = $ef->create_entry_for('td/symlink_pic_noext') },     "EF creates entry from a secret symlink to picture");
isa_ok($e, 'MaMGal::Entry::NonPicture',                                  "expected entry is a NonPicture");
is($e->name, 'symlink_pic_noext',                                        "file name matches");

dies_ok(sub { $ef->create_entry_for('td/non-existant') },                "EF dies on nonexistant arg");

# some corner cases:
my $rootdir;
lives_ok(sub { $rootdir = $ef->create_entry_for('/') },            "EF creates entry for '/'");
isa_ok($rootdir, 'MaMGal::Entry::Dir',                             "entry created by EF for '/' is a dir");
ok($rootdir->is_root,                                              "dir root created by EF knows that it's root");
is($rootdir->name, '/',                                            "dir root created by EF knows its name");
my $cwd;
lives_ok(sub { $cwd = $ef->create_entry_for('.') },                "EF creates entry for '.'");
isa_ok($cwd, 'MaMGal::Entry::Dir',                                 "entry created by EF for CWD is a dir");
isnt($cwd->name, '.',                                              "entry created by EF for CWD knows its canonical name (and not '.')");

