# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# The picture encapsulating class
package MMGal::Entry::Picture::Film;
use strict;
use warnings;
use base 'MMGal::Entry::Picture';
use Carp;

sub refresh_scaled_pictures
{
	my $self = shift;
	return $self->refresh_miniatures([$self->thumbnails_dir, 200, 150, '.jpg']);
}

sub read_image
{
	my $self = shift;
	my $tools = $self->tools or croak "Tools were not injected.";
	my $w = $tools->{mplayer_wrapper} or croak "MplayerWrapper required.\n";
	return $w->snapshot($self->{path_name});
}

sub thumbnail_path { $_[0]->SUPER::thumbnail_path.'.jpg' }

1;
