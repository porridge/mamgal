# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# The picture encapsulating class
package MMGal::Entry::Picture::Film;
use strict;
use warnings;
use base 'MMGal::Entry::Picture';
use Carp;
#use Image::Magick;
#use Image::Info;
#use POSIX;

sub refresh_scaled_pictures
{
	my $self = shift;
	return $self->refresh_miniatures(['thumbnails', 200, 150, '.jpg']);
}

sub read_image
{
	my $self = shift;
	use MMGal::MplayerWrapper;
	my $w = MMGal::MplayerWrapper->new;
	return $w->snapshot($self->{path_name});
}

sub thumbnail_path { 'thumbnails/'.$_[0]->{base_name}.'.jpg' }
sub absolute_thumbnail_path { $_[0]->{dir_name}.'/thumbnails/'.$_[0]->{base_name}.'.jpg' }

#sub make
#{
#	my $self = shift;
#	my $formatter = shift or croak "Formatter required\n";
#	ref $formatter and $formatter->isa('MMGal::Formatter') or croak "Arg is not a formatter\n";
#	$self->refresh_medium_and_thumbnail;
#	$self->refresh_slide($formatter);
#}

1;
