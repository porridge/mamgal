# mamgal - a program for creating static image galleries
# Copyright 2007-2009 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# A logging subsystem class
package MaMGal::Logger;
use strict;
use warnings;
use base 'MaMGal::Base';
use Carp;

sub init
{
	my $self = shift;
}

sub log_message
{
	my $self = shift;
	my $msg = shift;
	warn $msg."\n";
}

our $warned_before = 0;

sub log_exception
{
	my $self = shift;
	my $e = shift;
	my $prefix = shift || '';
	$prefix .= ': ' if $prefix;
	if ($e->isa('MaMGal::MplayerWrapper::NotAvailableException')) {
		# TODO this needs to be made thread-safe
		return if $warned_before;
		$warned_before = 1;
	}
	$self->log_message($prefix.$e->message);
}

1;
