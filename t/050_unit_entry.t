#!/usr/bin/perl
# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
package MMGal::Unit::Entry;
use strict;
use warnings;
use File::stat;
use Test::More;
use Test::Exception;
use base 'Test::Class';

use lib 'testlib';
use MMGal::TestHelper;

sub dir_preparation : Test(startup) {
	prepare_test_data;
}

sub class_setting : Test(startup) {
	my $self = shift;
	$self->{class_name} = 'MMGal::Entry';
	$self->{test_file_name} = [qw(td empty_file)];
}

sub file_name
{
	my $self = shift;
	return @{$self->{test_file_name}};
}

# This should be done in a BEGIN, but then planning the test count is difficult.
# However we are not using function prototypes, so it does not matter much.
sub class_usage : Test(startup => 1) {
	use_ok($_[0]->{class_name}) or $_[0]->BAILOUT("Class usage failed");
}

sub parameter_checks : Test(startup => 6) {
	my $self = shift;
	my $class_name = $self->{class_name};

	dies_ok(sub { $class_name->new },                             "$class_name dies on creation with no args");
	dies_ok(sub { $class_name->new('/') },                        "$class_name dies on creation with one arg");
	dies_ok(sub { $class_name->new($self->file_name, 1) },       "$class_name dies on creation with third argument not being a File::stat");
	dies_ok(sub { $class_name->new(qw(td/empty .)) },             "$class_name refuses to be created with '.' as the basename, when a name could have been provided");
	dies_ok(sub { $class_name->new(qw(. td/empty)) },             "$class_name refuses to be created with basename containing a slash");
	my $stat = stat('td/empty_file');
	dies_ok(sub { $class_name->new(qw(td empty_file), $stat, 3) },"$class_name dies on creation with more than 3 args");
}

sub entry_creation : Test(setup => 4) {
	my $self = shift;
	my $class_name = $self->{class_name};

	my $fake_stat = Test::MockObject->new;
	$fake_stat->set_isa('File::stat');
	$fake_stat->mock('mtime', sub { '1229888888' });
	$self->{fake_stat} = $fake_stat;

	my $e;
	{
		$e = $class_name->new($self->file_name, $fake_stat);
		isa_ok($e, $class_name);
		isa_ok($e, 'MMGal::Entry');
		$self->{entry} = $e;
	}
	{
		$e = $class_name->new($self->file_name);
		isa_ok($e, $class_name);
		isa_ok($e, 'MMGal::Entry');
		$self->{entry_no_stat} = $e;
	}
}

sub name_method : Test(2) {
	my $self = shift;
	my $class_name = $self->{class_name};
	my @test_file_name = $self->file_name;
	{
		my $e = $self->{entry};
		is($e->name, $test_file_name[1], "$class_name name is correct");
	}
	{
		my $e = $self->{entry_no_stat};
		is($e->name, $test_file_name[1], "$class_name name is correct");
	}
}

sub description_method : Test(2) {
	my $self = shift;
	my $class_name = $self->{class_name};
	{
		my $e = $self->{entry};
		is($e->description, '', "$class_name description is correct");
	}
	{
		my $e = $self->{entry_no_stat};
		is($e->description, '', "$class_name description is correct");
	}
}

sub thumbnails_dir_method : Test(2) {
	my $self = shift;
	my $class_name = $self->{class_name};
	{
		my $e = $self->{entry};
		is($e->thumbnails_dir, 'thumbnails', "$class_name thumbnails is correct");
	}
	{
		my $e = $self->{entry_no_stat};
		is($e->thumbnails_dir, 'thumbnails', "$class_name thumbnails is correct");
	}
}

sub slides_dir_method : Test(2) {
	my $self = shift;
	my $class_name = $self->{class_name};
	{
		my $e = $self->{entry};
		is($e->slides_dir, 'slides', "$class_name slides is correct");
	}
	{
		my $e = $self->{entry_no_stat};
		is($e->slides_dir, 'slides', "$class_name slides is correct");
	}
}

sub page_path_method : Test(2) {
	my $self = shift;
	my $class_name = $self->{class_name};
	{
		my $e = $self->{entry};
		dies_ok(sub { $e->page_path }, "$class_name page_path dies");
	}
	{
		my $e = $self->{entry_no_stat};
		dies_ok(sub { $e->page_path }, "$class_name page_path dies");
	}
}

sub thumbnail_path_method : Test(2) {
	my $self = shift;
	my $class_name = $self->{class_name};
	my @test_file_name = $self->file_name;
	{
		my $e = $self->{entry};
		dies_ok(sub { $e->thumbnail_path }, "$class_name thumbnail_path dies");
	}
	{
		my $e = $self->{entry_no_stat};
		dies_ok(sub { $e->thumbnail_path }, "$class_name thumbnail_path dies");
	}
}

sub container_method : Test(2) {
	my $self = shift;
	my $class_name = $self->{class_name};
	{
		my $e = $self->{entry};
		isa_ok($e->container, 'MMGal::Entry::Dir', "$class_name container is a dir");
	}
	{
		my $e = $self->{entry_no_stat};
		isa_ok($e->container, 'MMGal::Entry::Dir', "$class_name container is a dir");
	}
}

sub stat_functionality : Test(2) {
	my $self = shift;
	my $class_name = $self->{class_name};
	my $e = $self->{entry};

	my $ct = $e->creation_time;
	is($ct, '1229888888', "Returned creation time is the mocked mtime");
	my $time = time;
	utime($time, $time, join('/', $self->file_name)) == 1 or die "Failed to touch file";
	$ct = $e->creation_time;
	is($ct, '1229888888', "Returned creation time is still the (cached) mocked mtime");
}

sub stat_functionality_when_created_without_stat : Test(2) {
	my $self = shift;
	my $class_name = $self->{class_name};
	my $e = $self->{entry_no_stat};

	my $ct = $e->creation_time;
	is($ct, undef, "Returned creation time is undefined");
	my $time = time;
	utime($time, $time, join('/', $self->file_name)) == 1 or die "Failed to touch file";
	$ct = $e->creation_time;
	is($ct, undef, "Returned creation time is still the (cached) undef");
}

MMGal::Unit::Entry->runtests unless defined caller;
1;
