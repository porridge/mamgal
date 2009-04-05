#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007-2009 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
package MMGal::Unit::Entry::Picture;
use strict;
use warnings;
use Carp qw(verbose confess);
use Test::More;
use Test::Exception;
use Test::Files;
use Test::HTML::Content;
use lib 'testlib';
use File::stat;
BEGIN { our @ISA = 'MMGal::Unit::Entry' }
BEGIN { do 't/050_unit_entry.t' }

sub pre_class_setting : Test(startup) {
	my $self = shift;
	$self->{tools} = {
		mplayer_wrapper => MMGal::TestHelper->get_mock_mplayer_wrapper,
		formatter => MMGal::TestHelper->get_mock_formatter('format_slide'),
	};
}

sub entry_tools_setup : Test(setup => 0) {
	my $self = shift;
	$self->{entry}->set_tools($self->{tools});
	$self->{entry_no_stat}->set_tools($self->{tools});
}

sub _touch
{
	my ($self, $infix, $time, $suffix) = @_;
	my $dir = $self->{test_file_name}->[0].'/'.$infix;
	my $name = $self->{test_file_name}->[1];
	$name .= $suffix || '';
	mkdir $dir or confess "Cannot mkdir [$dir]: $!";
	open(T, '>'.$dir.'/'.$name) or die "Cannot open: $!";
	print T 'whatever';
	close(T) or die "Cannot close: $!";
	utime $time, $time, $dir.'/'.$name or die "Cannot touch: $!";
}

sub miniature_path
{
	my $self = shift;
	my $component = shift;
	return $self->{test_file_name}->[0].'/'.$self->relative_miniature_path($component);
}

sub relative_miniature_path
{
	my $self = shift;
	my $component = shift;
	return $component.'/'.$self->{test_file_name}->[1];
}

sub slide_path
{
	my $self = shift;
	my $component = shift;
	return $self->{test_file_name}->[0].'/'.$self->relative_slide_path($component);
}

sub relative_slide_path
{
	my $self = shift;
	my $component = shift;
	return $component.'/'.$self->{test_file_name}->[1].'.html';
}

sub call_refresh_miniatures
{
	my $self = shift;
	my $infix = shift;
	my $suffix = shift;
	my $e = $self->{entry};
	$e->refresh_miniatures($self->{tools}, [$infix, 60, 60, $suffix]);
}

sub call_refresh_slide
{
	my $self = shift;
	my $e = $self->{entry};
	$e->refresh_slide($self->{tools});
}

sub miniature_writing : Test(3) {
	my $self = shift;
	my $infix = 'test_miniature-'.$self->{class_name};
	my $path = $self->miniature_path($infix);
	ok(! -f $path, "$path does not exist yet");
	my @ret = $self->call_refresh_miniatures($infix);
	is($ret[0], $self->relative_miniature_path($infix), "refesh_miniatures call returns the perhaps-refreshed path");
	ok(-f $path, "$path exists now");
}

sub slide_writing : Test(3) {
	my $self = shift;
	my $infix = 'test_slide-'.$self->{class_name};
	use MMGal::Entry;
	local $MMGal::Entry::slides_dir = $infix;
	my $path = $self->slide_path($infix);
	ok(! -f $path, "$path does not exist yet");
	my @ret = $self->call_refresh_slide();
	is($ret[0], $self->relative_slide_path($infix), "refesh_slide call returns the perhaps-refreshed path");
	ok(-f $path, "$path exists now");
}

sub miniature_not_rewriting : Test(3) {
	my $self = shift;
	my $file_mtime = $self->{entry}->{stat}->mtime;
	my $miniature_mtime = $file_mtime + 60;
	my $infix = 'rewriting_miniature-'.$self->{class_name};
	$self->_touch($infix, $miniature_mtime);
	my $path = $self->miniature_path($infix);
	my $stat_before = stat($path) or die "Cannot stat [$path]: $!";
	is($stat_before->mtime, $miniature_mtime);
	my @ret = $self->call_refresh_miniatures($infix);
	is($ret[0], $self->relative_miniature_path($infix), "refesh_miniatures call returns the not-refreshed path");
	my $stat_after = stat($path) or die "Cannot stat: $!";
	is($stat_after->mtime, $miniature_mtime);
}

sub slide_not_rewriting : Test(3) {
	my $self = shift;
	my $file_mtime = $self->{entry}->{stat}->mtime;
	my $slide_mtime = $file_mtime + 60;
	my $infix = 'rewriting_slide-'.$self->{class_name};
	$self->_touch($infix, $slide_mtime, '.html');
	my $path = $self->slide_path($infix);
	my $stat_before = stat($path) or die "Cannot stat [$path]: $!";
	is($stat_before->mtime, $slide_mtime);
	local $MMGal::Entry::slides_dir = $infix;
	my @ret = $self->call_refresh_slide();
	is($ret[0], $self->relative_slide_path($infix), "refesh_slide call returns the not-refreshed path");
	my $stat_after = stat($path) or die "Cannot stat: $!";
	is($stat_after->mtime, $slide_mtime, 'timestamp did not change after refresh_slide()');
}

sub miniature_refreshing : Test(4) {
	my $self = shift;
	my $file_mtime = $self->{entry}->{stat}->mtime;
	# make the miniature older than the source file
	my $miniature_mtime = $file_mtime - 60;
	my $infix = 'refreshed_miniature-'.$self->{class_name};
	$self->_touch($infix, $miniature_mtime);
	my $path = $self->miniature_path($infix);
	my $stat_before = stat($path) or die "Cannot stat: $!";
	is($stat_before->mtime, $miniature_mtime);
	my @ret = $self->call_refresh_miniatures($infix);
	is($ret[0], $self->relative_miniature_path($infix), "refesh_miniatures call returns the refreshed path");
	my $stat_after = stat($path) or die "Cannot stat: $!";
	cmp_ok($stat_after->mtime, '>', $miniature_mtime, 'refreshed miniature mtime is newer than its previous mtime');
	cmp_ok($stat_after->mtime, '>', $file_mtime, 'refreshed miniature mtime is newer than its source file\'s mtime');
}

sub slide_refreshing : Test(4) {
	my $self = shift;
	my $file_mtime = $self->{entry}->{stat}->mtime;
	# make the slide older than the source file
	my $slide_mtime = $file_mtime - 60;
	my $infix = 'refreshed_slide-'.$self->{class_name};
	$self->_touch($infix, $slide_mtime, '.html');
	my $path = $self->slide_path($infix);
	my $stat_before = stat($path) or die "Cannot stat: $!";
	is($stat_before->mtime, $slide_mtime);
	local $MMGal::Entry::slides_dir = $infix;
	my @ret = $self->call_refresh_slide();
	is($ret[0], $self->relative_slide_path($infix), "refesh_slide call returns the refreshed path");
	my $stat_after = stat($path) or die "Cannot stat: $!";
	cmp_ok($stat_after->mtime, '>', $slide_mtime, 'refreshed slide mtime is newer than its previous mtime');
	cmp_ok($stat_after->mtime, '>', $file_mtime, 'refreshed slide mtime is newer than its source file\'s mtime');
}

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
	# we need to use localtime() as comparing raw time_t value breaks tests when changing locale
	is(localtime($ct), 'Thu Nov 27 20:43:51 2008', "Returned creation time is the EXIF creation time");
	my $time = time;
	utime($time, $time, join('/', $self->file_name)) == 1 or die "Failed to touch file";
	$ct = $e->creation_time;
	is(localtime($ct), 'Thu Nov 27 20:43:51 2008', "Returned creation time is still the (cached) EXIF creation time");
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

sub relative_miniature_path
{
	my $self = shift;
	$self->SUPER::relative_miniature_path(@_).'.jpg'
}

sub _touch {
	my $self = shift;
	$self->SUPER::_touch(@_, '.jpg')
}

sub call_refresh_miniatures
{
	my $self = shift;
	$self->SUPER::call_refresh_miniatures(@_, '.jpg')
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

