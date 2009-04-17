#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Carp 'verbose';
use Test::More tests => 10;
use Test::HTML::Content;
use lib 'testlib';
use MMGal::TestHelper;

prepare_test_data;

use MMGal::Formatter;
my $f = MMGal::Formatter->new;

use MMGal::EntryFactory;
my $d = MMGal::EntryFactory->create_entry_for('td/one_dir');
$d->set_root(1);
my $t = $f->format($d);
text_ok($t, 'one_dir',					"there is the directory name");
tag_count($t, "a", { href => 'subdir/index.html' }, 2,	"there are two links to the subdir");
tag_ok($t, "img", { src => 'subdir/.mmgal-index.png' },	"there is a pic on the page");
no_tag($t, "a", { href => "../index.html" },		"there is no link down");
no_text($t, '/',					"there is no (leading) slash on root dir page");

my $tsub = $f->format(($d->elements)[0]);
no_tag($tsub, "img", {},				"subdir index has no pics");
link_ok($tsub, "../index.html",				"subdir has link down");
text_ok($tsub, 'subdir',				"there is the directory name");
text_ok($tsub, 'one_dir',				"there is the parent directory name");
no_text($tsub, 'td',					"there isn't the grandfather directory name");
