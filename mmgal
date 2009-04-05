#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use lib 'blib/lib';

use MMGal::Maker;
use MMGal::Formatter;
use MMGal::MplayerWrapper;
use MMGal::LocaleEnv;
use Image::EXIF::DateTimeParser;
my $l = MMGal::LocaleEnv->new;
$l->set_locale('');
my $m = MMGal::Maker->new(MMGal::Formatter->new($l), MMGal::MplayerWrapper->new, Image::EXIF::DateTimeParser->new);
$m->make_roots($ARGV[0]);
