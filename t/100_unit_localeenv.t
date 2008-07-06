#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Test::More tests => 8;
use Test::Exception;
use lib 'testlib';
use MMGal::TestHelper;

prepare_test_data;

use_ok('MMGal::LocaleEnv');

# test parameter checks
dies_ok(sub { MMGal::LocaleEnv->new(1) },            "Locale env dies on creation with arg(s)");
my $le;
lives_ok(sub { $le = MMGal::LocaleEnv->new },        "Locale env survives creation with no args");
my $ch;
lives_ok(sub { $ch = $le->get_charset },             "Locale env returns a charset");
ok($ch,                                              "The charset returned by get_charset is never empty");

# It is not possible to portably test whether changing, retrieving or setting
# anything other than C locale is possible, because the set of available
# locales is system-specific.
lives_ok(sub { $le->set_locale("C") },               "Locale env can set a posix locale");
lives_ok(sub { $ch = $le->get_charset },             "Locale env can retrieve the charset name afterwards");
# The following string should be returned whether nl_langinfo is available or not
is($ch, "ANSI_X3.4-1968",                            "Charset name retrieved by locale env is expected name for posix locale");

