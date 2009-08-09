# mamgal - a program for creating static image galleries
# Copyright 2007-2009 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# The wrapper-for-everything module
package MaMGal;
use strict;
use warnings;
use base 'MaMGal::Base';
# Remeber to change po/mamgal.pot as well
our $VERSION = '1.1';
our $AUTOLOAD;
use Carp;
use FileHandle;
use Image::EXIF::DateTime::Parser;
use Locale::gettext;
use Peco::Container;

use MaMGal::CommandChecker;
use MaMGal::EntryFactory;
use MaMGal::Formatter;
use MaMGal::ImageInfoFactory;
use MaMGal::LocaleEnv;
use MaMGal::Maker;
use MaMGal::MplayerWrapper;

sub init
{
	my $self = shift;
	my $c = Peco::Container->new;
	if (@_) {
		$c->register(locale_env => 'MaMGal::LocaleEnv', [qw(logger)], 'new', {set_locale => $_[0]});
		textdomain('mamgal');
	} else {
		$c->register(locale_env => 'MaMGal::LocaleEnv', [qw(logger)]);
	}
	$c->register(formatter => 'MaMGal::Formatter', [qw(locale_env)]);
	$c->register(logger => 'MaMGal::Logger', [qw(filehandle)]);
	$c->register(filehandle => 'FileHandle', [qw(descriptor mode)], 'new_from_fd');
	$c->register(descriptor => 'STDERR');
	$c->register(mode => 'w');
	$c->register(datetime_parser => 'Image::EXIF::DateTime::Parser');
	$c->register(command_checker => 'MaMGal::CommandChecker');
	$c->register(mplayer_wrapper => 'MaMGal::MplayerWrapper', [qw(command_checker)]);
	$c->register(image_info_factory => 'MaMGal::ImageInfoFactory', [qw(datetime_parser logger)]);
	$c->register(entry_factory => 'MaMGal::EntryFactory', [qw(formatter mplayer_wrapper image_info_factory logger)]);
	$c->register(maker => 'MaMGal::Maker', ['entry_factory']);
	$self->{maker} = $c->service('maker');
	$self->{logger} = $c->service('logger');
}

sub DESTROY {} # avoid using AUTOLOAD

sub AUTOLOAD
{
	my $self = shift;
	my $method = $AUTOLOAD;
	$method =~ s/.*://;
	croak "Unknown method $method" unless $method =~ /^make_(without_)?roots$/;
	eval {
		$self->{maker}->$method(@_);
	};
	my $e;
	if ($e = Exception::Class->caught('MaMGal::SystemException')) {
		$self->{logger}->log_exception($e);
	} elsif ($e = Exception::Class->caught) {
		ref $e ? $e->rethrow : die $e;
	}
	1;
}

1;

