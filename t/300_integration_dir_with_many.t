#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007-2009 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Carp 'verbose';
use Test::More tests => 35;
use Test::Exception;
use Test::Files;
use lib 'testlib';
use MMGal::TestHelper;
use File::stat;
use Image::EXIF::DateTimeParser;

prepare_test_data;
my $time_now  = time;
my $time_past = $time_now - 3600;
my $time_old  = 1103328000; # in 2004 - "very old"
# touch up the directory and picture with different times
utime $time_past, $time_past, 'td/more/subdir/p.png'  or die "Touching p.png failed";
utime $time_old,  $time_old,  'td/more/subdir/p2.png' or die "Touching p2.png failed";
utime $time_now,  $time_now,  'td/more/subdir'        or die "Touching directory failed";

use_ok('MMGal::Entry::Dir');
my $d;
lives_ok(sub { $d = MMGal::Entry::Dir->new(qw(td more), stat('td/more')) },	"creation ok");
isa_ok($d, 'MMGal::Entry::Dir',                                 "a dir is a dir");
my $mf = get_mock_formatter(qw(format stylesheet));
my $tools = {formatter => $mf, exif_dtparser => Image::EXIF::DateTimeParser->new};
$d->set_tools($tools);

my @ret = $d->elements;
is(scalar(@ret), 5,						"dir contains 5 elements");
# read ordering
isa_ok($ret[0], 'MMGal::Entry::Picture::Static');
is($ret[0]->element_index, 0, 					"pic 0 knows its element index");
isa_ok($ret[1], 'MMGal::Entry::Picture::Static');
is($ret[1]->element_index, 1, 					"pic 1 knows its element index");
isa_ok($ret[2], 'MMGal::Entry::Dir');
is($ret[2]->element_index, 2, 					"pic 2 knows its element index");
isa_ok($ret[3], 'MMGal::Entry::Picture::Static');
is($ret[3]->element_index, 3, 					"pic 3 knows its element index");

my ($prev, $next);
lives_ok(sub { ($prev, $next) = $d->neighbours_of_index(0) },	"there is index zero");
ok(not(defined($prev)),						"there is no prev neighbours for 1st element");
ok(defined($next),						"there is next neighbour for 1st element");
is($next, $ret[1],						"next after 1st is 2nd");
lives_ok(sub { ($prev, $next) = $d->neighbours_of_index(1) },	"there is index one");
ok(defined $prev && defined $next,				"there is both prev and next neighbour for 2nd element");
is($prev, $ret[0],						"prev before 2nd is 1st");
is($next, $ret[3],						"next after 2nd is 3rd pic (4th element)");

my $subdir = $ret[2];
is($subdir->container, $d,					"container of dir's subdir is dir");

my $sub_single_creation_time = $subdir->creation_time;
ok($sub_single_creation_time, "There is some non-zero create time");
my @sub_creation_time_range = $subdir->creation_time;
is(scalar @sub_creation_time_range, 2, "Creation time range is not empty");
cmp_ok($sub_creation_time_range[0], '<=', $sub_single_creation_time, "Second time in range is greater equal than the first one");
is($sub_creation_time_range[1], $sub_single_creation_time, "Second time in the range is equal to the scalar one, although I no longer remember why I wanted it this way...");
is($sub_creation_time_range[0], $time_old, "First time in the range is equal to the one of the oldest picture");

my $topdir;
lives_ok(sub { $topdir = $d->container },			"a dir can return its container");
isa_ok($topdir, 'MMGal::Entry::Dir',				"dir's container is a dir");
is($topdir->name, 'td',						"dir's parent name is correct");

# the td/more should only (apart from td/more/subdir) have files/dirs whose
# timestamps fall between the ones from subdir. So it should effectively
# inherit the range of the subdir.
my $single_creation_time = $d->creation_time;
ok($single_creation_time, "There is some non-zero create time");
my @creation_time_range = $d->creation_time;
is(scalar @creation_time_range, 2, "Creation time range is not empty");
cmp_ok($creation_time_range[0], '<=', $single_creation_time, "Second time in range is greater equal than the first one");
is($creation_time_range[1], $single_creation_time, "Second time in the range is equal to the scalar one, although I no longer remember why I wanted it this way...");
is($creation_time_range[0], $time_old, "First time in the range is equal to the one of the oldest picture");
is($creation_time_range[1], $time_past, "Second time in the range is equal to the one of the newer picture");

#my ($one_pic_entry) = $d->elements();
#ok($one_pic_entry, "There is one picture");
#my $picture_creation_time = $one_pic_entry->creation_time;
#ok($picture_creation_time, "Picture has a creation time");
#is($single_creation_time, $picture_creation_time, "The creation times match");
