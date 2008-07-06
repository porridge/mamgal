# mmgal - a program for creating static image galleries
# Copyright 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# A class encapsulating locale environment settings.
package MMGal::LocaleEnv;
use strict;
use warnings;
use base 'MMGal::Base';
use Carp;
use Locale::gettext;
use POSIX;

sub init
{
	my $self = shift;
	croak "No arguments expected" if @_;
	eval {
		require I18N::Langinfo;
		I18N::Langinfo->import(qw(langinfo CODESET));
	};
	if ($@) {
		warn "nl_langinfo(CODESET) is not available. ANSI_X3.4-1968 (a.k.a. US-ASCII) will be used as HTML encoding. $@";
		$self->{get_codeset} = sub { "ANSI_X3.4-1968" };
	} else {
		$self->{get_codeset} = sub { langinfo(CODESET()) };
	}
}

sub get_charset
{
	my $self = shift;
	&{$self->{get_codeset}}
}

sub set_locale
{
	my $self = shift;
	my $locale = shift;
	setlocale(LC_ALL, $locale);
}

1;
