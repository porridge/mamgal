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

#	my $me = Test::MockObject->new;
#	$me->mocks('message', sub { 'foo bar' });

MaMGal::Unit::Logger->runtests unless defined caller;
1;
