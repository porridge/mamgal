# mamgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# The wrapper-for-everything module
package MaMGal;
use strict;
use warnings;
use base 'MaMGal::Base';
use MaMGal::CommandChecker;
use MaMGal::EntryFactory;
use MaMGal::Formatter;
use MaMGal::ImageInfo;
use MaMGal::LocaleEnv;
use MaMGal::Maker;
use MaMGal::MplayerWrapper;
use Image::EXIF::DateTime::Parser;
use Carp;
our $VERSION = '0.01';

sub init
{
	my $self = shift;
	my $f;
	if (@_) {
		my $l = MaMGal::LocaleEnv->new;
		$l->set_locale('');
		$f = MaMGal::Formatter->new($l);
	} else {
		$f = MaMGal::Formatter->new;
	}
	my $cc = MaMGal::CommandChecker->new;
	my $m = MaMGal::Maker->new($f, MaMGal::MplayerWrapper->new($cc), Image::EXIF::DateTime::Parser->new, MaMGal::EntryFactory->new);
	$self->{maker} = $m;
}

sub make_roots
{
	my $self = shift;
	$self->{maker}->make_roots(@_);
}

sub make_without_roots
{
	my $self = shift;
	$self->{maker}->make_without_roots(@_);
}

1;

