# mamgal - a program for creating static image galleries
# Copyright 2007-2009 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# The wrapper-for-everything module
package App::MaMGal;
use strict;
use warnings;
use base 'App::MaMGal::Base';
# Remeber to change po/mamgal.pot as well
our $VERSION = '1.2';
our $AUTOLOAD;
use Carp;
use FileHandle;
use Image::EXIF::DateTime::Parser;
use Locale::gettext;
use Peco::Container;

use App::MaMGal::CommandChecker;
use App::MaMGal::EntryFactory;
use App::MaMGal::Formatter;
use App::MaMGal::ImageInfoFactory;
use App::MaMGal::LocaleEnv;
use App::MaMGal::Maker;
use App::MaMGal::MplayerWrapper;

sub init
{
	my $self = shift;
	my $c = Peco::Container->new;
	if (@_) {
		$c->register(locale_env => 'App::MaMGal::LocaleEnv', [qw(logger)], 'new', {set_locale => $_[0]});
		textdomain('mamgal');
	} else {
		$c->register(locale_env => 'App::MaMGal::LocaleEnv', [qw(logger)]);
	}
	$c->register(formatter => 'App::MaMGal::Formatter', [qw(locale_env)]);
	$c->register(logger => 'App::MaMGal::Logger', [qw(filehandle)]);
	$c->register(filehandle => 'FileHandle', [qw(descriptor mode)], 'new_from_fd');
	$c->register(descriptor => 'STDERR');
	$c->register(mode => 'w');
	$c->register(datetime_parser => 'Image::EXIF::DateTime::Parser');
	$c->register(command_checker => 'App::MaMGal::CommandChecker');
	$c->register(mplayer_wrapper => 'App::MaMGal::MplayerWrapper', [qw(command_checker)]);
	$c->register(image_info_factory => 'App::MaMGal::ImageInfoFactory', [qw(datetime_parser logger)]);
	$c->register(entry_factory => 'App::MaMGal::EntryFactory', [qw(formatter mplayer_wrapper image_info_factory logger)]);
	$c->register(maker => 'App::MaMGal::Maker', ['entry_factory']);
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
	if ($e = Exception::Class->caught('App::MaMGal::SystemException')) {
		$self->{logger}->log_exception($e);
	} elsif ($e = Exception::Class->caught) {
		ref $e ? $e->rethrow : die $e;
	}
	1;
}

1;

