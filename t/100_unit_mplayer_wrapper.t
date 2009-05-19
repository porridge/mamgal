#!/usr/bin/perl
# mamgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Carp 'verbose';
use Test::More tests => 37;
use Test::Exception;
use Test::HTML::Content;
use lib 'testlib';
use MaMGal::TestHelper;
use MaMGal::LocaleEnv;
use Image::Magick;

prepare_test_data;

use_ok('MaMGal::MplayerWrapper');

my $e = MaMGal::MplayerWrapper::ExecutionFailureException->new('foo bar');
ok($e);
is($e->message, 'foo bar');
is($e->stdout, undef);
is($e->stderr, undef);

$e = MaMGal::MplayerWrapper::ExecutionFailureException->new('foo bar', [1,2,3], [2,3,4]);
ok($e);
is($e->message, 'foo bar');
is_deeply($e->stdout, [1,2,3]);
is_deeply($e->stderr, [2,3,4]);

dies_ok(sub { MaMGal::MplayerWrapper->new },                    "wrapper can not be created without any arg");
dies_ok(sub { MaMGal::MplayerWrapper->new(1) },                 "wrapper can not be created with some junk parameter");

{
my $w;
my $mccy = get_mock_cc(1);
lives_ok(sub { $w = MaMGal::MplayerWrapper->new($mccy) },        "wrapper can be created with command checker");

my ($snap);
is($mccy->next_call, undef, 'checker not interrogated until fist wrapper use');
$mccy->clear;

dies_ok(sub { $w->snapshot() },				"wrapper cannot get a snapshot of undef");
my ($m, $args) = $mccy->next_call;
is($m, 'is_available', 'checker is interrogated on fist wrapper use');
is_deeply($args, [$mccy, 'mplayer'], 'checker is asked about mplayer');
$mccy->clear;

dies_ok(sub { $w->snapshot('td/notthere.mov') },	"wrapper cannot get a snapshot of an inexistant file");
is($mccy->next_call, undef, 'checker not interrogated more than once');
$mccy->clear;

throws_ok(sub { $snap = $w->snapshot('td/c.jpg') }, 'MaMGal::MplayerWrapper::ExecutionFailureException', "wrapper cannot survive snapshotting a non-film file");
my $err = $@;
is($mccy->next_call, undef, 'checker not interrogated more than once');
$mccy->clear;
ok($err->message, "invalid file produces some exception message");
ok($err->stdout, "invalid file produces some messages");
ok($err->stderr, "invalid file produces some error messages");

lives_ok(sub { $snap = $w->snapshot('td/one_film/m.mov') },	"wrapper can get a snapshot of a film file");
is($mccy->next_call, undef, 'checker not interrogated more than once');
$mccy->clear;
isa_ok($snap, 'Image::Magick',					"snapshot");
}

{
my $mccn = get_mock_cc(0);
my $w;
lives_ok(sub { $w = MaMGal::MplayerWrapper->new($mccn) },        "wrapper can be created with command checker");

is($mccn->next_call, undef, 'checker not interrogated until fist wrapper use');
$mccn->clear;

throws_ok(sub { $w->snapshot() }, 'MaMGal::MplayerWrapper::NotAvailableException', "failed because mplayer was not found");
my ($m, $args) = $mccn->next_call;
is($m, 'is_available', 'checker is interrogated on fist wrapper use');
is_deeply($args, [$mccn, 'mplayer'], 'checker is asked about mplayer');
$mccn->clear;

throws_ok(sub { $w->snapshot('td/notthere.mov') }, 'MaMGal::MplayerWrapper::NotAvailableException', "failed because mplayer was not found");
is($mccn->next_call, undef, 'checker not interrogated more than once');
$mccn->clear;

throws_ok(sub { $w->snapshot('td/c.jpg') }, 'MaMGal::MplayerWrapper::NotAvailableException', "failed because mplayer was not found");
is($mccn->next_call, undef, 'checker not interrogated more than once');
$mccn->clear;

throws_ok(sub { $w->snapshot('td/one_film/m.mov') }, 'MaMGal::MplayerWrapper::NotAvailableException', "failed because mplayer was not found");
is($mccn->next_call, undef, 'checker not interrogated more than once');
$mccn->clear;
}


