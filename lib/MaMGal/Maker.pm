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
use MaMGal::Formatter;

sub init
{
	my $self = shift;
	my $formatter = shift or croak "Need a formatter arg";
	ref $formatter and $formatter->isa('MaMGal::Formatter') or croak "Arg is not a formatter, but a [$formatter]";
	my $mplayer_wrapper = shift or croak "Need an mplayer wrapper arg";
	ref $mplayer_wrapper and $mplayer_wrapper->isa('MaMGal::MplayerWrapper') or croak "Arg is not an mplayer wrapper, but a [$mplayer_wrapper]";
	my $exif_dtparser = shift or croak "Need an EXIF DateTimeParser arg ";
	ref $exif_dtparser and $exif_dtparser->isa('Image::EXIF::DateTime::Parser') or croak "Arg is not an Image::EXIF::DateTime::Parser, but a [$exif_dtparser]";
	my $entry_factory = shift or croak "Need an entry factory arg";
	ref $entry_factory and $entry_factory->isa('MaMGal::EntryFactory') or croak "Arg is not an EntryFactory, but a [$entry_factory]";
	$self->{formatter} = $formatter;
	$self->{mplayer_wrapper} = $mplayer_wrapper;
	$self->{exif_dtparser} = $exif_dtparser;
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
	croak "No args" unless @_;

	my $tools = { map { $_ => $self->{$_} } qw(formatter mplayer_wrapper exif_dtparser entry_factory) };
	my @dirs = map {
		my $d = $self->{entry_factory}->create_entry_for($_);
		$d->set_root(1) if $dirs_are_roots;
		$d->add_tools($tools);
		$d
	} @_;
	$_->make foreach @dirs;

	return 1;
}

1;
