# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# Any interesting entry (picture or subdirectory)
package MMGal::Entry;
use strict;
use warnings;
use base 'MMGal::Base';
use Carp;
use Cwd 'abs_path';
use File::Basename;

sub init
{
	my $self     = shift;
	my $dirname  = shift or croak "Need dir"; # containing dir, relative to WD
	my $basename = shift or croak "Need basename"; # under $dirname
	my $stat     = shift; # File::stat (of target, if symlink)
	die "At most 3 args expected, got fourth: [$_[0]]" if @_;

	$self->{dir_name}  = $dirname;
	$self->{base_name} = $basename;
	$self->{stat}      = $stat;
	$self->{path_name} = $dirname.'/'.$basename;
}

# TODO: element should not have a need to know its index, container should be able to tell it simply given the object
sub element_index { $_[0]->{element_index}  }
sub set_element_index { $_[0]->{element_index} = $_[1]  }
sub name          { $_[0]->{base_name} }
sub description   { '' }
sub set_container { $_[0]->{container} = $_[1] }
sub container
{
	my $self = shift;
	unless (defined $self->{container}) {
		my $parent = abs_path($self->{dir_name});
		$self->{container} = $self->new(dirname($parent), basename($parent));
	}
	return $self->{container};
}

sub container_names
{
	my $self = shift;
	return ($self->container->container_names, $self->container->name);
}

sub neighbours
{
	my $self = shift;
	return (undef, undef) unless $self->{container};
	return $self->{container}->neighbours_of_index($self->element_index);
}

#######################################################################################################################
# Abstract methods
# these two need to return the text of the link ...
sub page_path		{ croak(sprintf("INTERNAL ERROR: Class [%s] does not define page_path.",      ref(shift))) }
sub thumbnail_path	{ croak(sprintf("INTERNAL ERROR: Class [%s] does not define thumbnail_path.", ref(shift))) }

1;
