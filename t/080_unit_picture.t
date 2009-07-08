#!/usr/bin/perl
# mamgal - a program for creating static image galleries
# Copyright 2007-2009 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
package MaMGal::Unit::Entry::Picture;
use strict;
use warnings;
use Carp qw(verbose confess);
use Test::More;
use Test::Exception;
use Test::Files;
use Test::HTML::Content;
use lib 'testlib';
use File::stat;
use Image::EXIF::DateTime::Parser;
use MaMGal::ImageInfoFactory;
use MaMGal::TestHelper;
BEGIN { our @ISA = 'MaMGal::Unit::Entry' }
BEGIN { do 't/050_unit_entry.t' }

sub pre_class_setting : Test(startup) {
	my $self = shift;
	$self->{tools} = {
		mplayer_wrapper => MaMGal::TestHelper->get_mock_mplayer_wrapper,
		formatter => MaMGal::TestHelper->get_mock_formatter('format_slide'),
		image_info_factory => MaMGal::ImageInfoFactory->new(Image::EXIF::DateTime::Parser->new, get_mock_logger),
	};
}

sub entry_tools_setup : Test(setup => 0) {
	my $self = shift;
	foreach my $entry (qw(entry entry_no_stat)) {
		foreach my $key (keys %{$self->{tools}}) {
			$self->{$entry}->tools->{$key} = $self->{tools}->{$key};
		}
	}
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
	$e->refresh_miniatures([$infix, 60, 60, $suffix]);
}

sub call_refresh_slide
{
	my $self = shift;
	my $e = $self->{entry};
	$e->refresh_slide;
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

sub slide_writing : Test(6) {
	my $self = shift;
	my $infix = 'test_slide-'.$self->{class_name};
	use MaMGal::Entry;
	local $MaMGal::Entry::slides_dir = $infix;
	my $path = $self->slide_path($infix);
	ok(! -f $path, "$path does not exist yet");
	my @ret = $self->call_refresh_slide();
	is($ret[0], $self->relative_slide_path($infix), "refesh_slide call returns the perhaps-refreshed path");
	my ($m, $args) = $self->{mock_container}->next_call;
	is($m, 'ensure_subdir_exists', 'subdir existence was ensured');
	is($args->[1], $infix, 'correct subdir was requested');
	($m, $args) = $self->{mock_container}->next_call;
	is($m, '_write_contents_to', 'slide was written');
	is($args->[2], $infix.'/'.$self->{test_file_name}->[1].'.html', 'correct slide path was requested');
	$self->{mock_container}->clear;
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
	local $MaMGal::Entry::slides_dir = $infix;
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

sub slide_refreshing : Test(6) {
	my $self = shift;
	my $file_mtime = $self->{entry}->{stat}->mtime;
	# make the slide older than the source file
	my $slide_mtime = $file_mtime - 60;
	my $infix = 'refreshed_slide-'.$self->{class_name};
	$self->_touch($infix, $slide_mtime, '.html');
	my $path = $self->slide_path($infix);
	my $stat_before = stat($path) or die "Cannot stat: $!";
	is($stat_before->mtime, $slide_mtime);
	local $MaMGal::Entry::slides_dir = $infix;
	my @ret = $self->call_refresh_slide();
	is($ret[0], $self->relative_slide_path($infix), "refesh_slide call returns the refreshed path");
	my ($m, $args) = $self->{mock_container}->next_call;
	is($m, 'ensure_subdir_exists', 'subdir existence was ensured');
	is($args->[1], $infix, 'correct subdir was requested');
	($m, $args) = $self->{mock_container}->next_call;
	is($m, '_write_contents_to', 'slide was written');
	is($args->[2], $infix.'/'.$self->{test_file_name}->[1].'.html', 'correct slide path was requested');
	$self->{mock_container}->clear;
}

sub page_path_method : Test(2) {
	my $self = shift;
	my $class_name = $self->{class_name};
	my @test_file_name = $self->file_name;
	{
		my $e = $self->{entry};
		is($e->page_path, '.mamgal-slides/'.$test_file_name[1].'.html', "$class_name page_path is correct");
	}
	{
		my $e = $self->{entry_no_stat};
		is($e->page_path, '.mamgal-slides/'.$test_file_name[1].'.html', "$class_name page_path is correct");
	}
}

sub is_intetresting_method : Test(1) {
	my $self = shift;
	my $e = $self->{entry};
	ok($e->is_interesting, "pictures generally are interesting");
}

sub tile_path_method : Test(1) {
	my $self = shift;
	my $class_name = $self->{class_name};
	my $e = $self->{entry};
	ok($e->tile_path, "$class_name tile_path is something");
}

package MaMGal::Unit::Entry::Picture::Static;
use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Files;
use Test::HTML::Content;
use lib 'testlib';
BEGIN { our @ISA = 'MaMGal::Unit::Entry::Picture' }

use MaMGal::TestHelper;
use File::stat;
use Test::Warn;

sub class_setting : Test(startup) {
	my $self = shift;
	$self->{class_name} = 'MaMGal::Entry::Picture::Static';
	$self->{test_file_name} = [qw(td c.jpg)];
}

sub image_info_class_injection : Test(setup => 0) {
	my $self = shift;
	$self->{mock_image_info_factory} = Test::MockObject->new;
	$self->{entry}->add_tools({image_info_factory => $self->{mock_image_info_factory}});

	$self->{mock_image_info} = Test::MockObject->new;
	$self->{mock_image_info_factory}->mock('read', sub { $self->{mock_image_info} });
}

sub successful_image_info_object_creation : Test(2) {
	my $self = shift;
	my @mocks = ({}, {});
	$self->{mock_image_info_factory}->mock('read', sub { $mocks[0] });
	is($self->{entry}->image_info, $mocks[0], 'calling image_info for the first time results in an object creation');
	$self->{mock_image_info_factory}->mock('read', sub { $mocks[1] });
	is($self->{entry}->image_info, $mocks[0], 'calling image_info second time results returning a cached object');
}

sub crashing_image_info_object_creation : Test(6) {
	my $self = shift;
	$self->{mock_image_info_factory}->mock('read', sub { die "oh my\n"; });
	my $val;
	warning_like { $val = $self->{entry}->image_info } qr{^Cannot retrieve image info from \[td/c\.jpg\]: oh my$}, 'crash instantiating an object results in a warning';
	is($val, undef, 'crash instantiating an object results in undef returned');
	$self->{mock_image_info_factory}->called_ok('read');
	$self->{mock_image_info_factory}->clear;
	warnings_are { $val = $self->{entry}->image_info } [], 'no warnings are produced on second image_info call';
	is($val, undef, 'after one crash, undef is returned by image_info always');
	ok(! $self->{mock_image_info_factory}->called('read'), 'read is not called after it crashed once');
}

sub description_method : Test {
	my $self = shift;
	$self->{mock_image_info}->mock('description', sub { 'some text' });
	is($self->{entry}->description, 'some text');
}

sub description_method_undefined : Test {
	my $self = shift;
	$self->{mock_image_info}->mock('description', sub { undef });
	is($self->{entry}->description, undef);
}

sub description_method_crash : Test(2) {
	my $self = shift;
	$self->{mock_image_info_factory}->mock('read', sub { die "oh noes!\n" });
	my $d;
	warning_like { $d = $self->{entry}->description } qr{Cannot.*oh noes}, 'crash when getting a description produces a warning';
	is($d, undef, 'description is undefined');
}

sub thumbnail_path_method : Test(2) {
	my $self = shift;
	my $class_name = $self->{class_name};
	my @test_file_name = $self->file_name;
	{
		my $e = $self->{entry};
		is($e->thumbnail_path, '.mamgal-thumbnails/'.$test_file_name[1], "$class_name thumbnail_path is correct");
	}
	{
		my $e = $self->{entry_no_stat};
		is($e->thumbnail_path, '.mamgal-thumbnails/'.$test_file_name[1], "$class_name thumbnail_path is correct");
	}
}

sub stat_functionality : Test(1) {
	my $self = shift;
	$self->{mock_image_info}->mock('creation_time', sub { 1234567890 });
	is($self->{entry}->creation_time, 1234567890, 'if image info object returns a defined time, that time is returned');
}

sub stat_functionality_undefined : Test(2) {
	my $self = shift;
	$self->{mock_image_info}->mock('creation_time', sub { undef });
	# if image info object returns undef, we turn to the stat data supplied on creation
	$self->SUPER::stat_functionality;
}

sub stat_functionality_crashed : Test(3) {
	my $self = shift;
	$self->{mock_image_info_factory}->mock('read', sub { die "oh noes too!" });
	# if image info object construction fails, we turn to the stat data supplied on creation
	warning_like { $self->SUPER::stat_functionality } qr{Cannot retrieve image info.*oh noes too}, 'crash when getting stat data produces a warning';
}

sub stat_functionality_when_created_without_stat : Test { ok(1) }

package MaMGal::Unit::Entry::Picture::Film;
use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Files;
use Test::Warn;
use Test::HTML::Content;
use MaMGal::Entry::Picture::Film;
use lib 'testlib';
BEGIN { our @ISA = 'MaMGal::Unit::Entry::Picture' }

use MaMGal::TestHelper;
use File::stat;

sub class_setting : Test(startup) {
	my $self = shift;
	$self->{class_name} = 'MaMGal::Entry::Picture::Film';
	$self->{test_file_name} = [qw(td/one_film m.mov)];
}

sub relative_miniature_path
{
	my $self = shift;
	$self->SUPER::relative_miniature_path(@_).'.png'
}

sub _touch {
	my $self = shift;
	$self->SUPER::_touch(@_, '.png')
}

sub call_refresh_miniatures
{
	my $self = shift;
	$self->SUPER::call_refresh_miniatures(@_, '.png')
}

sub thumbnail_path_method : Test(2) {
	my $self = shift;
	my $class_name = $self->{class_name};
	my @test_file_name = $self->file_name;
	{
		my $e = $self->{entry};
		is($e->thumbnail_path, '.mamgal-thumbnails/'.$test_file_name[1].'.png', "$class_name thumbnail_path is correct");
	}
	{
		my $e = $self->{entry_no_stat};
		is($e->thumbnail_path, '.mamgal-thumbnails/'.$test_file_name[1].'.png', "$class_name thumbnail_path is correct");
	}
}

sub read_image_method_normal : Test(2)
{
	my $self = shift;
	my $class_name = $self->{class_name};
	{
		my $e = $self->{entry};
		is($e->read_image, $self->{tools}->{mplayer_wrapper}->snapshot, 'read_image got correct image');
	}
	{
		my $e = $self->{entry_no_stat};
		is($e->read_image, $self->{tools}->{mplayer_wrapper}->snapshot, 'read_image got correct image');
	}
}

sub read_image_method_no_mplayer : Test(12)
{
	my $self = shift;
	my $class_name = $self->{class_name};
	{
		my $e = $self->{entry};
		$e->{tools}->{mplayer_wrapper} = MaMGal::TestHelper->get_mock_mplayer_wrapper;
		$e->{tools}->{mplayer_wrapper}->mock('snapshot', sub { my $e = Test::MockObject->new; $e->set_isa('MaMGal::MplayerWrapper::NotAvailableException'); die $e } );
		my $i;
		warning_like { $i = $e->read_image; } qr{^mplayer.*not available.*$}, 'reading image without an mplayer produces a warning';
		ok($i, 'read_image got SOME image');
		isa_ok($i, 'Image::Magick');
		warnings_are { $i = $e->read_image; } [], 'reading image without an mplayer on the second time produces no warning';
		ok($i, 'read_image got SOME image');
		isa_ok($i, 'Image::Magick');
	}
	undef $MaMGal::Entry::Picture::Film::warned_before;
	{
		my $e = $self->{entry_no_stat};
		$e->{tools}->{mplayer_wrapper} = MaMGal::TestHelper->get_mock_mplayer_wrapper;
		$e->{tools}->{mplayer_wrapper}->mock('snapshot', sub { my $e = Test::MockObject->new; $e->set_isa('MaMGal::MplayerWrapper::NotAvailableException'); die $e } );
		my $i;
		warning_like { $i = $e->read_image; } qr{^mplayer.*not available.*$}, 'reading image without an mplayer produces a warning';
		ok($i, 'read_image got SOME image');
		isa_ok($i, 'Image::Magick');
		warnings_are { $i = $e->read_image; } [], 'reading image without an mplayer on the second time produces no warning';
		ok($i, 'read_image got SOME image');
		isa_ok($i, 'Image::Magick');
	}
}

sub read_image_method_error : Test(6)
{
	my $self = shift;
	my $class_name = $self->{class_name};
	{
		my $e = $self->{entry};
		$e->{tools}->{mplayer_wrapper} = MaMGal::TestHelper->get_mock_mplayer_wrapper;
		$e->{tools}->{mplayer_wrapper}->mock('snapshot', sub { my $e = Test::MockObject->new; $e->set_isa('MaMGal::MplayerWrapper::ExecutionFailureException');$e->mock('message', sub { 'la di da' }); die $e } );
		my $i;
		warning_like { $i = $e->read_image; } qr{td/one_film/m\.mov.*snapshot.*la di da}, 'image read failure results in a warning';
		ok($i, 'read_image got SOME image');
		isa_ok($i, 'Image::Magick');
	}
	{
		my $e = $self->{entry_no_stat};
		$e->{tools}->{mplayer_wrapper} = MaMGal::TestHelper->get_mock_mplayer_wrapper;
		$e->{tools}->{mplayer_wrapper}->mock('snapshot', sub { my $e = Test::MockObject->new; $e->set_isa('MaMGal::MplayerWrapper::ExecutionFailureException');$e->mock('message', sub { 'la di da' }); die $e } );
		my $i;
		warning_like { $i = $e->read_image; } qr{td/one_film/m\.mov.*snapshot.*la di da}, 'image read failure results in a warning';
		ok($i, 'read_image got SOME image');
		isa_ok($i, 'Image::Magick');
	}
}

package main;
use Test::More;
unless (defined caller) {
	plan tests => MaMGal::Unit::Entry::Picture::Static->expected_tests + MaMGal::Unit::Entry::Picture::Film->expected_tests;
	MaMGal::Unit::Entry::Picture::Static->runtests;
	MaMGal::Unit::Entry::Picture::Film->runtests;
}

