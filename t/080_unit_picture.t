#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
package MMGal::Unit::Entry::Picture;
use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Files;
use Test::HTML::Content;
use lib 'testlib';
BEGIN { our @ISA = 'MMGal::Unit::Entry' }
BEGIN { do 't/050_unit_entry.t' }

sub page_path_method : Test(2) {
	my $self = shift;
	my $class_name = $self->{class_name};
	my @test_file_name = $self->file_name;
	{
		my $e = $self->{entry};
		is($e->page_path, 'slides/'.$test_file_name[1].'.html', "$class_name page_path is correct");
	}
	{
		my $e = $self->{entry_no_stat};
		is($e->page_path, 'slides/'.$test_file_name[1].'.html', "$class_name page_path is correct");
	}
}

package MMGal::Unit::Entry::Picture::Static;
use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Files;
use Test::HTML::Content;
use lib 'testlib';
BEGIN { our @ISA = 'MMGal::Unit::Entry::Picture' }

use MMGal::TestHelper;
use File::stat;

sub class_setting : Test(startup) {
	my $self = shift;
	$self->{class_name} = 'MMGal::Entry::Picture::Static';
	$self->{test_file_name} = [qw(td c.jpg)];
}

sub description_method : Test(2) {
	my $self = shift;
	my $class_name = $self->{class_name};
	{
		my $e = $self->{entry};
		is($e->description, "A description of c.jpg\n", "$class_name description is correct");
	}
	{
		my $e = $self->{entry_no_stat};
		is($e->description, "A description of c.jpg\n", "$class_name description is correct");
	}
}

sub thumbnail_path_method : Test(2) {
	my $self = shift;
	my $class_name = $self->{class_name};
	my @test_file_name = $self->file_name;
	{
		my $e = $self->{entry};
		is($e->thumbnail_path, 'thumbnails/'.$test_file_name[1], "$class_name thumbnail_path is correct");
	}
	{
		my $e = $self->{entry_no_stat};
		is($e->thumbnail_path, 'thumbnails/'.$test_file_name[1], "$class_name thumbnail_path is correct");
	}
}

sub stat_functionality : Test(2) {
	my $self = shift;
	my $class_name = $self->{class_name};
	my $e = $self->{entry};

	my $ct = $e->creation_time;
	is($ct, 1227818631, "Returned creation time is the EXIF creation time");
	my $time = time;
	utime($time, $time, join('/', $self->file_name)) == 1 or die "Failed to touch file";
	$ct = $e->creation_time;
	is($ct, 1227818631, "Returned creation time is still the (cached) EXIF creation time");
}

sub stat_functionality_when_created_without_stat : Test(2) {
	my $self = shift;
	$self->stat_functionality(@_);
}

package MMGal::Unit::Entry::Picture::Film;
use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Files;
use Test::HTML::Content;
use lib 'testlib';
BEGIN { our @ISA = 'MMGal::Unit::Entry::Picture' }

use MMGal::TestHelper;
use File::stat;

sub class_setting : Test(startup) {
	my $self = shift;
	$self->{class_name} = 'MMGal::Entry::Picture::Film';
	$self->{test_file_name} = [qw(td/one_film m.mov)];
}

sub thumbnail_path_method : Test(2) {
	my $self = shift;
	my $class_name = $self->{class_name};
	my @test_file_name = $self->file_name;
	{
		my $e = $self->{entry};
		is($e->thumbnail_path, 'thumbnails/'.$test_file_name[1].'.jpg', "$class_name thumbnail_path is correct");
	}
	{
		my $e = $self->{entry_no_stat};
		is($e->thumbnail_path, 'thumbnails/'.$test_file_name[1].'.jpg', "$class_name thumbnail_path is correct");
	}
}

package main;
use Test::More;
unless (defined caller) {
	plan tests => MMGal::Unit::Entry::Picture::Static->expected_tests + MMGal::Unit::Entry::Picture::Film->expected_tests;
	MMGal::Unit::Entry::Picture::Static->runtests;
	MMGal::Unit::Entry::Picture::Film->runtests;
}

