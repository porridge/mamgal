#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 18;
use Test::Exception;
use Test::Files;

system('rm -rf td ; cp -a td.in td');

use_ok('MMGal::EntryFactory');
my $e;
lives_ok(sub { $e = MMGal::EntryFactory->create_entry_for('td/empty_file') },		"EF creates entry from empty file");
isa_ok($e, 'MMGal::Entry::NonPicture',							"expected entry is a NonPicture");

lives_ok(sub { $e = MMGal::EntryFactory->create_entry_for('td/symlink_to_empty_file') },"EF creates entry from symlink to empty file");
isa_ok($e, 'MMGal::Entry::NonPicture',							"expected entry is a NonPicture");

lives_ok(sub { $e = MMGal::EntryFactory->create_entry_for('td/empty') },		"EF creates entry from empty dir");
isa_ok($e, 'MMGal::Entry::Dir',								"expected entry is a Dir");

lives_ok(sub { $e = MMGal::EntryFactory->create_entry_for('td/symlink_to_empty') },	"EF creates entry from symlink to empty dir");
isa_ok($e, 'MMGal::Entry::Dir',								"expected entry is a Dir");

lives_ok(sub { $e = MMGal::EntryFactory->create_entry_for('td/symlink_broken') },	"EF creates entry from broken symlink");
isa_ok($e, 'MMGal::Entry::BrokenSymlink',						"expected entry is a BrokenSymlink");

lives_ok(sub { $e = MMGal::EntryFactory->create_entry_for('td/one_pic/a1.png') },	"EF creates entry from a picture");
isa_ok($e, 'MMGal::Entry::Picture',							"expected entry is a Picture");

lives_ok(sub { $e = MMGal::EntryFactory->create_entry_for('td/symlink_pic.png') },	"EF creates entry from a symlink to picture");
isa_ok($e, 'MMGal::Entry::Picture',							"expected entry is a Picture");

lives_ok(sub { $e = MMGal::EntryFactory->create_entry_for('td/symlink_pic_noext') },	"EF creates entry from a secret symlink to picture");
isa_ok($e, 'MMGal::Entry::NonPicture',							"expected entry is a NonPicture");

dies_ok(sub { MMGal::EntryFactory->create_entry_for('td/non-existant') },		"EF dies on nonexistant arg");
