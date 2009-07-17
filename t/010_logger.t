#!/usr/bin/perl
# mamgal - a program for creating static image galleries
# Copyright 2007-2009 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
package MaMGal::Unit::Logger;
use strict;
use warnings;
use Carp 'verbose';
use Test::More;
use Test::Exception;
use Test::Warn;
use base 'Test::Class';

use lib 'testlib';
use MaMGal::TestHelper;

sub class_load : Test(startup => 1) {
	use_ok('MaMGal::Logger');
}

sub instantiation : Test(setup => 1) {
	my $self = shift;
	$self->{l} = MaMGal::Logger->new;
	ok($self->{l});
}

sub log_message_method : Test(1) {
	my $self = shift;
	my $msg = 'bugga bugga buga!';
	warning_like { $self->{l}->log_message($msg) } qr{^\Q$msg\E$}, 'log_message causes a warning';
}

sub log_other_exception : Tests(4)
{
	my $self = shift;
	my $e = get_mock_exception 'MaMGal::MplayerWrapper::OtherException';
	warning_like { $self->{l}->log_exception($e) } qr{^foo bar$}, 'log_message causes a warning first time';
	warning_like { $self->{l}->log_exception($e) } qr{^foo bar$}, 'log_message causes a warning even second time';
	warning_like { $self->{l}->log_exception($e, 'prefix') } qr{^prefix: foo bar$}, 'log_message with prefix causes a warning first time';
	warning_like { $self->{l}->log_exception($e, 'prefix') } qr{^prefix: foo bar$}, 'log_message with prefix causes a warning even second time';
}

sub log_not_available_exception : Tests(2)
{
	my $self = shift;
	my $e = get_mock_exception 'MaMGal::MplayerWrapper::NotAvailableException';
	warning_like { $self->{l}->log_exception($e, 'prefix') } qr{^prefix: foo bar$}, 'log_message causes a warning';
	warnings_are { $self->{l}->log_exception($e, 'prefix') } [], 'reading image without an mplayer on the second time produces no warning';
}

MaMGal::Unit::Logger->runtests unless defined caller;
1;
