# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# Any interesting entry (picture or subdirectory)
package MMGal::Entry;
use strict;
use warnings;
use base 'MMGal::Base';
use Carp;
use File::Basename;
use File::stat;
use MMGal::EntryFactory;

sub init
{
	my $self     = shift;
	my $dirname  = shift or croak "Need dir"; # the directory which contains this entry, relative to WD or absolute
	my $basename = shift or croak "Need basename"; # under $dirname
	die "A basename of \".\" used when other would be possible (last component of $dirname)" if $basename eq '.' and not ($dirname eq '.' or $dirname eq '/');
	die "Basename [$basename] contains a slash" if $basename =~ m{/};
	my $stat     = shift;
	die "Third argument must be a File::stat, if provided" unless not $stat or (ref $stat and $stat->isa('File::stat'));
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
		$self->set_container(MMGal::EntryFactory->create_entry_for($self->{dir_name}));
	}
	return $self->{container};
}

sub containers
{
	my $self = shift;
	return ($self->container->containers, $self->container);
}

sub neighbours
{
	my $self = shift;
	return (undef, undef) unless $self->{container};
	return $self->{container}->neighbours_of_index($self->element_index);
}

# Returns the best available approximation of creation time of this entry
sub creation_time
{
	my $self = shift;
	# Get the stat object provided on construction, or do a stat now
	$self->{stat} = stat($self->{path_name}) unless defined $self->{stat};
	my $stat = $self->{stat};
	# We might not be able to get stat information (broken symlink, no permissions, ...)
	return undef unless $stat;
	# We need to use st_mtime, for lack of anything better
	return $stat->mtime;
}

# Some constants
sub slides_dir     { 'slides' }
sub thumbnails_dir { 'thumbnails' }
sub medium_dir     { 'medium' }

#######################################################################################################################
# Abstract methods
# these two need to return the text of the link ...
sub page_path		{ croak(sprintf("INTERNAL ERROR: Class [%s] does not define page_path.",      ref(shift))) }
sub thumbnail_path	{ croak(sprintf("INTERNAL ERROR: Class [%s] does not define thumbnail_path.", ref(shift))) }

1;
