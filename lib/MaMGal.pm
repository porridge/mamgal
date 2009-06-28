# mamgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# The wrapper-for-everything module
package MaMGal;
use strict;
use warnings;
use base 'MaMGal::Base';
use MaMGal::CommandChecker;
use MaMGal::Formatter;
use MaMGal::ImageInfo;
use MaMGal::LocaleEnv;
use MaMGal::Maker;
use MaMGal::MplayerWrapper;
use Image::EXIF::DateTime::Parser;
use Carp;
use Peco::Container;
our $VERSION = '0.01';

sub init
{
	my $self = shift;
	my $c = Peco::Container->new;
	if (@_) {
		$c->register(formatter => 'MaMGal::Formatter', [qw(locale_env)]);
		$c->register(locale_env=> 'MaMGal::LocaleEnv', undef, 'new', {set_locale => ''});
	} else {
		$c->register(formatter => 'MaMGal::Formatter');
	}
	$c->register(datetime_parser => 'Image::EXIF::DateTime::Parser');
	$c->register(command_checker => 'MaMGal::CommandChecker');
	$c->register(mplayer_wrapper => 'MaMGal::MplayerWrapper', [qw(command_checker)]);
	$c->register(maker => 'MaMGal::Maker', [qw(formatter mplayer_wrapper datetime_parser)]);
	$self->{maker} = $c->service('maker');
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

