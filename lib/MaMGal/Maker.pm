# mamgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# The runner module
package MaMGal::Maker;
use strict;
use warnings;
use base 'MaMGal::Base';
use Carp;
use MaMGal::Entry::Dir;

sub init
{
	my $self = shift;
	my $entry_factory = shift or croak "Need an entry factory arg";
	ref $entry_factory and $entry_factory->isa('MaMGal::EntryFactory') or croak "Arg is not an EntryFactory, but a [$entry_factory]";
	$self->{entry_factory} = $entry_factory;
}

sub make_without_roots
{
	my $self = shift;
	return $self->_make_any(0, @_);
}

sub make_roots
{
	my $self = shift;
	return $self->_make_any(1, @_);
}

sub _make_any
{
	my $self = shift;
	my $dirs_are_roots = shift;
	die "Argument required.\n" unless @_;

	my @dirs = map {
		my $d = $self->{entry_factory}->create_entry_for($_);
		die sprintf("%s: not a directory.\n", $_) unless $d->isa('MaMGal::Entry::Dir');
		$d->set_root(1) if $dirs_are_roots;
		$d
	} @_;
	$_->make foreach @dirs;

	return 1;
}

1;
