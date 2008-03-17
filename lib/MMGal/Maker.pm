# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# The runner module
package MMGal::Maker;
use strict;
use warnings;
use base 'MMGal::Base';
use Carp;
use MMGal::Entry::Dir;
use MMGal::Formatter;
our $VERSION = '0.01';

sub init
{
	my $self = shift;
	my $formatter = shift or croak "Need a formatter arg";
	ref $formatter and $formatter->isa('MMGal::Formatter') or croak "Arg is not a formatter, but a [$formatter]";
	$self->{formatter} = $formatter;
}

sub make_without_roots
{
	my $self = shift;
	return $self->make_any(0, @_);
}

sub make_roots
{
	my $self = shift;
	return $self->make_any(1, @_);
}

sub make_any
{
	my $self = shift;
	my $dirs_are_roots = shift;
	croak "No args" unless @_;

	my @dirs = map {
		my $d = MMGal::EntryFactory->create_entry_for($_);
		$d->set_root(1) if $dirs_are_roots;
		$d
	} @_;
	my $f = $self->{formatter};
	$_->make($f) for @dirs;

	return 1;
}

1;
