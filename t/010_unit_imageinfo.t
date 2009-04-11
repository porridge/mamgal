#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
package MMGal::Unit::ImageInfo;
use strict;
use warnings;
use Carp 'verbose';
use File::stat;
use Test::More;
use Test::Exception;
use Test::Warn;
use base 'Test::Class';

use lib 'testlib';
use MMGal::TestHelper;

sub _dir_preparation : Test(startup) {
	prepare_test_data;
}

# This should be done in a BEGIN, but then planning the test count is difficult.
# However we are not using function prototypes, so it does not matter much.
sub _class_usage : Test(startup => 1) {
	use_ok('MMGal::ImageInfo') or $_[0]->BAILOUT("Class use failed");
}

sub creation_aborts : Test(startup => 2) {
	my $self = shift;
	dies_ok(sub { MMGal::ImageInfo->read }, 'dies without an arg');
	dies_ok(sub { MMGal::ImageInfo->read('td') }, 'dies with a non-picture');
}

sub creation : Test(setup) {
	my $self = shift;
	$self->{jpg} = MMGal::ImageInfo->read('td/varying_datetimes.jpg');
	$self->{jpg_no_0x9003} = MMGal::ImageInfo->read('td/without_0x9003.jpg');
	$self->{jpg_no_0x9003_0x9004} = MMGal::ImageInfo->read('td/without_0x9003_0x9004.jpg');
	$self->{jpg_no_0x9003_0x9004_0x0132} = MMGal::ImageInfo->read('td/without_0x9003_0x9004_0x0132.jpg');
	$self->{png_nodesc} = MMGal::ImageInfo->read('td/more/b.png');
	$self->{png_desc} = MMGal::ImageInfo->read('td/more/a.png');
}

sub description_method : Test(6) {
	my $self = shift;
	is($self->{jpg}->description, "A description of c.jpg\n", 'jpeg description is correct');
	is($self->{jpg_no_0x9003}->description, "A description of c.jpg\n", 'jpeg description is correct');
	is($self->{jpg_no_0x9003_0x9004}->description, "A description of c.jpg\n", 'jpeg description is correct');
	is($self->{jpg_no_0x9003_0x9004_0x0132}->description, "A description of c.jpg\n", 'jpeg description is correct');
	is($self->{png_desc}->description, "Test image A", 'png description is correct');
	is($self->{png_nodesc}->description, undef, 'png with no description returns undef');
}

sub exif_datetime_original_string : Test(4) {
	my $self = shift;
	is($self->{jpg}->datetime_original_string, '2008:11:27 20:43:53', 'returned datetime original is the exif field');
	is($self->{jpg_no_0x9003}->datetime_original_string, undef, 'returned datetime original is undefined');
	is($self->{jpg_no_0x9003_0x9004}->datetime_original_string, undef, 'returned datetime original is undefined');
	is($self->{jpg_no_0x9003_0x9004_0x0132}->datetime_original_string, undef, 'returned datetime original is undefined');
}

sub exif_datetime_digitized_string : Test(4) {
	my $self = shift;
	is($self->{jpg}->datetime_digitized_string, '2008:11:27 20:43:51', 'returned datetime digitized is the exif field');
	is($self->{jpg_no_0x9003}->datetime_digitized_string, '2008:11:27 20:43:51', 'returned datetime digitized is the exif field');
	is($self->{jpg_no_0x9003_0x9004}->datetime_digitized_string, undef, 'returned datetime digitized is undefined');
	is($self->{jpg_no_0x9003_0x9004_0x0132}->datetime_digitized_string, undef, 'returned datetime digitized is undefined');
}

sub exif_datetime_string : Test(4) {
	my $self = shift;
	is($self->{jpg}->datetime_string, '2008:11:27 20:43:52', 'returned datetime is the exif field');
	is($self->{jpg_no_0x9003}->datetime_string, '2008:11:27 20:43:52', 'returned datetime is the exif field');
	is($self->{jpg_no_0x9003_0x9004}->datetime_string, '2008:11:27 20:43:52', 'returned datetime is the exif field');
	is($self->{jpg_no_0x9003_0x9004_0x0132}->datetime_string, undef, 'returned datetime original is undefined');
}

sub creation_time_method : Test(4) {
	my $self = shift;
	my %parsers = (
		jpg                         => Test::MockObject->new->mock('parse', sub { 1231231231 }),
		jpg_no_0x9003               => Test::MockObject->new->mock('parse', sub { 1231231232 }),
		jpg_no_0x9003_0x9004        => Test::MockObject->new->mock('parse', sub { 1231231233 }),
		jpg_no_0x9003_0x9004_0x0132 => Test::MockObject->new->mock('parse', sub { undef }),
	);
	# inject parsers
	$self->{$_}->{parser} = $parsers{$_} for keys %parsers;

	is($self->{jpg}->creation_time, '1231231231', 'returned datetime is the mocked time');
	is($self->{jpg_no_0x9003}->creation_time, '1231231232', 'returned datetime is the mocked time');
	is($self->{jpg_no_0x9003_0x9004}->creation_time, '1231231233', 'returned datetime is the mocked time');
	is($self->{jpg_no_0x9003_0x9004_0x0132}->creation_time, undef, 'returned datetime original is undefined');
}

sub _test_creation_time {
	my $self = shift;
	my $file = shift;
	my $mp = $self->{$file}->{parser} = Test::MockObject->new;
	my $parse_map = shift;
	my $expected_result = shift;
	my $expected_tag = shift;
	my $expected_warning = shift;
	$mp->mock('parse', sub { exists $parse_map->{$_[1]} ? return &{$parse_map->{$_[1]}} : die "arg ".$_[1]." not found in map" });
	local $Test::Builder::Level = 2;
	my $actual_result;
	if ($expected_warning) {
		warning_like { $actual_result = $self->{$file}->creation_time } $expected_warning;
	} else {
		warnings_are { $actual_result = $self->{$file}->creation_time } [];
	}
	is($actual_result, $expected_result, "creation time returns parse value for $expected_tag");
}

sub when_all_tags_present_and_datetime_original_crashes_then_creation_time_returns_datetime_digitized: Test(2) {
	my $self = shift;
	my %parse_map = (
		'2008:11:27 20:43:51' => sub { 1234567891 },
		'2008:11:27 20:43:52' => sub { 1234567892 },
		'2008:11:27 20:43:53' => sub { die "parsing failed" },
	);
	$self->_test_creation_time('jpg', \%parse_map, 1234567891, 'datetime_digitized', qr{td/varying_datetimes\.jpg: EXIF tag 0x9003: parsing failed});
}

sub when_all_tags_present_and_parse_then_creation_time_returns_datetime_original: Test(2) {
	my $self = shift;
	my %parse_map = (
		'2008:11:27 20:43:51' => sub { 1234567891 },
		'2008:11:27 20:43:52' => sub { 1234567892 },
		'2008:11:27 20:43:53' => sub { 1234567893 },
	);
	$self->_test_creation_time('jpg', \%parse_map, 1234567893, 'datetime_original');
}

sub when_all_tags_present_and_just_datetime_original_does_not_parse_then_creation_time_returns_datetime_digitized : Test(2) {
	my $self = shift;
	my %parse_map = (
		'2008:11:27 20:43:51' => sub { 1234567891 },
		'2008:11:27 20:43:52' => sub { 1234567892 },
		'2008:11:27 20:43:53' => sub { undef },
	);
	$self->_test_creation_time('jpg', \%parse_map, 1234567891, 'datetime_digitized');
}

sub when_all_tags_present_and_just_datetime_parses_then_creation_time_returns_datetime : Test(2) {
	my $self = shift;
	my %parse_map = (
		'2008:11:27 20:43:51' => sub { undef },
		'2008:11:27 20:43:52' => sub { 1234567892 },
		'2008:11:27 20:43:53' => sub { undef },
	);
	$self->_test_creation_time('jpg', \%parse_map, 1234567892, 'datetime');
}

sub when_all_tags_present_and_none_parses_then_creation_time_returns_undef : Test(2) {
	my $self = shift;
	my %parse_map = (
		'2008:11:27 20:43:51' => sub { undef },
		'2008:11:27 20:43:52' => sub { undef },
		'2008:11:27 20:43:53' => sub { undef },
	);
	$self->_test_creation_time('jpg', \%parse_map, undef, 'undef');
}

sub when_datetime_original_tag_not_present_and_rest_parse_then_creation_time_returns_datetime_digitized : Test(2) {
	my $self = shift;
	my %parse_map = (
		'2008:11:27 20:43:51' => sub { 1234567891 },
		'2008:11:27 20:43:52' => sub { 1234567892 },
	);
	$self->_test_creation_time('jpg_no_0x9003', \%parse_map, 1234567891, 'datetime_digitized');
}

sub when_datetime_original_tag_not_present_and_just_datetime_parses_then_creation_time_returns_datetime_digitized : Test(2) {
	my $self = shift;
	my %parse_map = (
		'2008:11:27 20:43:51' => sub { undef },
		'2008:11:27 20:43:52' => sub { 1234567892 },
	);
	$self->_test_creation_time('jpg_no_0x9003', \%parse_map, 1234567892, 'datetime');
}

sub when_datetime_original_tag_not_present_and_none_parses_then_creation_time_returns_undef : Test(2) {
	my $self = shift;
	my %parse_map = (
		'2008:11:27 20:43:51' => sub { undef },
		'2008:11:27 20:43:52' => sub { undef },
	);
	$self->_test_creation_time('jpg_no_0x9003', \%parse_map, undef, 'undef');
}


sub when_just_datetime_tag_present_and_parses_then_creation_time_returns_datetime : Test(2) {
	my $self = shift;
	my %parse_map = (
		'2008:11:27 20:43:52' => sub { 1234567892 },
	);
	$self->_test_creation_time('jpg_no_0x9003_0x9004', \%parse_map, 1234567892, 'datetime');
}

sub when_just_datetime_tag_present_and_none_parses_then_creation_time_returns_undef : Test(2) {
	my $self = shift;
	my %parse_map = (
		'2008:11:27 20:43:52' => sub { undef },
	);
	$self->_test_creation_time('jpg_no_0x9003_0x9004', \%parse_map, undef, 'undef');
}


sub when_no_datetime_tag_present_then_creation_time_returns_undef : Test(2) {
	my $self = shift;
	$self->_test_creation_time('jpg_no_0x9003_0x9004_0x0132', {}, undef, 'undef');
}

MMGal::Unit::ImageInfo->runtests unless defined caller;
1;
