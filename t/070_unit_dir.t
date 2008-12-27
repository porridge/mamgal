#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
package MMGal::Unit::Entry::Dir;
use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Files;
use Test::HTML::Content;
use lib 'testlib';
BEGIN { our @ISA = 'MMGal::Unit::Entry::NonPicture' }
BEGIN { do 't/060_unit_nonpicture.t' }

use MMGal::TestHelper;
use File::stat;

sub class_setting : Test(startup) {
	my $self = shift;
	$self->{class_name} = 'MMGal::Entry::Dir';
}

sub page_path_method : Test(2) {
	my $self = shift;
	my $class_name = $self->{class_name};
	my @test_file_name = $self->file_name;
	{
		my $e = $self->{entry};
		is($e->page_path, $test_file_name[1].'/index.html', "$class_name page_path is correct");
	}
	{
		my $e = $self->{entry_no_stat};
		is($e->page_path, $test_file_name[1].'/index.html', "$class_name page_path is correct");
	}
}

sub thumbnail_path_method : Test(2) {
	my $self = shift;
	my $class_name = $self->{class_name};
	my @test_file_name = $self->file_name;
	{
		my $e = $self->{entry};
		is($e->thumbnail_path, $test_file_name[1].'/index.png', "$class_name thumbnail_path is correct");
	}
	{
		my $e = $self->{entry_no_stat};
		is($e->thumbnail_path, $test_file_name[1].'/index.png', "$class_name thumbnail_path is correct");
	}
}

sub invalid_make_invocation : Test {
	my $self = shift;
	dies_ok(sub { $self->{entry}->make }, "Dir dies on make invocation with no arg");
}

package MMGal::Unit::Entry::Dir::Empty;
use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Files;
use Test::HTML::Content;
use lib 'testlib';
BEGIN { our @ISA = 'MMGal::Unit::Entry::Dir' }

use MMGal::TestHelper;
use File::stat;

sub class_setting : Test(startup) {
	my $self = shift;
	$self->SUPER::class_setting;
	$self->{test_file_name} = [qw(td empty)];
}

sub empty_dir_properties : Test(3) {
	my $self = shift;
	my $d = $self->{entry};
	ok(! $d->is_root,                           "Freshly created dir is not a root");
	dies_ok(sub { $d->neighbours_of_index(0) }, "No neighbours of first index in an empty dir, because there is no such index");
	dies_ok(sub { $d->neighbours_of_index(1) }, "No neighbours of second index in an empty dir, because there is no such index");
}

sub zz_empty_dir : Test(startup => 1) {
	dir_only_contains_ok('td/empty', [],                         "Directory is empty initially");
}

sub valid_make_invocation : Test(5) {
	my $self = shift;
	my $d = $self->{entry};
	my $mf = get_mock_formatter(qw(format stylesheet));
	lives_ok(sub { $d->make({formatter => $mf}) },               "Dir lives on make invocation with a formatter");
	ok($mf->called('format'),                                    "Dir->make calls formatter->format internally");
	ok($mf->called('stylesheet'),                                "Dir->make calls formatter->stylesheet internally");
	dir_only_contains_ok('td/empty', [qw{index.html index.png mmgal.css}],
                                                                     "Directory contains only the index file and thumb afterwards");
	file_ok('td/empty/index.html', "whatever",                   "Dir->make creates an index file");
}

package MMGal::Unit::Entry::Dir::MoreSubdir;
use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Files;
use Test::HTML::Content;
use lib 'testlib';
BEGIN { our @ISA = 'MMGal::Unit::Entry::Dir' }

use MMGal::TestHelper;
use File::stat;

sub class_setting : Test(startup) {
	my $self = shift;
	$self->SUPER::class_setting;
	$self->{test_file_name} = [qw(td/more subdir)];
}

sub more_subdir_tests : Test(2) {
	my $self = shift;
	# test root and containers on a deeply nested dir
	my $deep_dir = $self->{entry};
	ok(! $deep_dir->is_root,                                           "Freshly created dir is not a root");
	is_deeply([map { $_->name } $deep_dir->containers], [qw(td more)], "Non-root directory has some container names, in correct order");
}

package MMGal::Unit::Entry::Dir::ARootDir;
use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Files;
use Test::HTML::Content;
use lib 'testlib';
BEGIN { our @ISA = 'MMGal::Unit::Entry::Dir' }

use MMGal::TestHelper;
use File::stat;

sub class_setting : Test(startup) {
	my $self = shift;
	$self->SUPER::class_setting;
	$self->{test_file_name} = [qw(td root_dir)];
}

sub root_dir_tests : Test(2) {
	my $self = shift;
	# test root property on a dir already tagged as root
	my $rd = $self->{entry};
	ok($rd->is_root,                   "Freshly created root dir is root");
	is_deeply([($rd->containers)], [], "Root directory has no container names");
}


package MMGal::Unit::Entry::Dir::Bin;
use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Files;
use Test::HTML::Content;
use lib 'testlib';
BEGIN { our @ISA = 'MMGal::Unit::Entry::Dir' }

use MMGal::TestHelper;
use File::stat;

sub class_setting : Test(startup) {
	my $self = shift;
	$self->SUPER::class_setting;
	$self->{test_file_name} = [qw(/ bin)];
}

sub slash_bin_tests : Test(2) {
	my $self = shift;
	# test root properties on a absolutely referenced subdir of a root dir and its container
	my $bd = $self->{entry};
	ok(! $bd->is_root,          "Freshly created dir is not a root");
	ok($bd->container->is_root, "Toplevel dir's container is root");
}

sub stat_functionality : Test {
	my $self = shift;
	my $e = $self->{entry_no_stat};

	my $ct = $e->creation_time;
	is($ct, undef, "Returned creation time is undefined");
	# don't try to touch a dir we don't own
}

sub stat_functionality_when_created_without_stat : Test {
	my $self = shift;
	$self->stat_functionality(@_);
}

package MMGal::Unit::Entry::Dir::Slash;
use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Files;
use Test::HTML::Content;
use lib 'testlib';
BEGIN { our @ISA = 'MMGal::Unit::Entry::Dir' }

use MMGal::TestHelper;
use File::stat;

sub class_setting : Test(startup) {
	my $self = shift;
	$self->SUPER::class_setting;
	$self->{test_file_name} = [qw(/ .)];
}

sub slash_tests : Test {
	my $self = shift;
	# test root property on the real "/" root
	my $Rd = $self->{entry};
	ok($Rd->is_root, "Freshly created root dir is root");
}

sub name_method : Test(2) {
	my $self = shift;
	my $class_name = $self->{class_name};
	my @test_file_name = $self->file_name;
	{
		my $e = $self->{entry};
		is($e->name, '/', "$class_name name is correct");
	}
	{
		my $e = $self->{entry_no_stat};
		is($e->name, '/', "$class_name name is correct");
	}
}

sub page_path_method : Test(2) {
	my $self = shift;
	my $class_name = $self->{class_name};
	my @test_file_name = $self->file_name;
	{
		my $e = $self->{entry};
		is($e->page_path, '//index.html', "$class_name page_path is correct");
	}
	{
		my $e = $self->{entry_no_stat};
		is($e->page_path, '//index.html', "$class_name page_path is correct");
	}
}

sub thumbnail_path_method : Test(2) {
	my $self = shift;
	my $class_name = $self->{class_name};
	my @test_file_name = $self->file_name;
	{
		my $e = $self->{entry};
		is($e->thumbnail_path, '//index.png', "$class_name thumbnail_path is correct");
	}
	{
		my $e = $self->{entry_no_stat};
		is($e->thumbnail_path, '//index.png', "$class_name thumbnail_path is correct");
	}
}

sub stat_functionality : Test {
	my $self = shift;
	my $e = $self->{entry_no_stat};

	my $ct = $e->creation_time;
	is($ct, undef, "Returned creation time is undefined");
	# don't try to touch a dir we don't own
}

sub stat_functionality_when_created_without_stat : Test {
	my $self = shift;
	$self->stat_functionality(@_);
}

package MMGal::Unit::Entry::Dir::Dot;
use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Files;
use Test::HTML::Content;
use lib 'testlib';
BEGIN { our @ISA = 'MMGal::Unit::Entry::Dir' }

use MMGal::TestHelper;
use File::stat;

sub class_setting : Test(startup) {
	my $self = shift;
	$self->SUPER::class_setting;
	$self->{test_file_name} = [qw(. .)];
}

sub dot_dir_tests : Test(1) {
	my $self = shift;
	# test creation of the current directory
	my $cd = $self->{entry};
	ok(! $cd->is_root, "Freshly created root dir is not a root");
}

package main;
use Test::More;
unless (defined caller) {
	my @classes = qw(MMGal::Unit::Entry::Dir::Empty MMGal::Unit::Entry::Dir::MoreSubdir MMGal::Unit::Entry::Dir::ARootDir MMGal::Unit::Entry::Dir::Bin MMGal::Unit::Entry::Dir::Slash MMGal::Unit::Entry::Dir::Dot);
	my $tests = 0;
	$tests += $_->expected_tests foreach @classes;
	plan tests => $tests;
	$_->runtests foreach @classes;
}

