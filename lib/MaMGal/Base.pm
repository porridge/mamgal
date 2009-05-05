# mamgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# Base class with some common stuff
package MaMGal::Base;
use strict;
use warnings;

sub new
{
	my $that  = shift;
	my $class = ref $that || $that;

	my $self = {};
	bless $self, $class;
	$self->init(@_);

	return $self;
}

sub init {;}

#######################################################################################################################
# Utility methods
sub _write_contents_to
{
	my $self = shift;
	my $code = shift;
	my $tmp_name = shift;
	my $full_name = shift;

	open(OUT, '>', $tmp_name) or die "${tmp_name}: $!\n";
	print OUT &$code;
	close(OUT)                or die "${tmp_name}: $!\n";
	rename($tmp_name, $full_name) or die "${tmp_name} -> ${full_name}: $!\n";
}

1;
