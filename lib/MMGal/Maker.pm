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
use Locale::gettext;
our $VERSION = '0.01';

sub init
{
	my $self = shift;
	my $formatter = shift or croak "Need a formatter arg";
	ref $formatter and $formatter->isa('MMGal::Formatter') or croak "Arg is not a formatter, but a [$formatter]";
	my $mplayer_wrapper = shift or croak "Need an mplayer wrapper arg";
	ref $mplayer_wrapper and $mplayer_wrapper->isa('MMGal::MplayerWrapper') or croak "Arg is not an mplayer wrapper, but a [$mplayer_wrapper]";
	my $exif_dtparser = shift or croak "Need an EXIF DateTimeParser arg ";
	ref $exif_dtparser and $exif_dtparser->isa('Image::EXIF::DateTimeParser') or croak "Arg is not an Image::EXIF::DateTimeParser, but a [$exif_dtparser]";
	$self->{formatter} = $formatter;
	$self->{mplayer_wrapper} = $mplayer_wrapper;
	$self->{exif_dtparser} = $exif_dtparser;
	my $le = MMGal::LocaleEnv->new;
	$le->set_locale('');
	$formatter->set_locale_env($le);
	textdomain('mmgal');
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

	my $tools = { formatter => $self->{formatter}, mplayer_wrapper => $self->{mplayer_wrapper}, exif_dtparser => $self->{exif_dtparser} };
	my @dirs = map {
		my $d = MMGal::EntryFactory->create_entry_for($_);
		$d->set_root(1) if $dirs_are_roots;
		$d->set_tools($tools);
		$d
	} @_;
	$_->make for @dirs;

	return 1;
}

1;
