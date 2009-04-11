# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# The picture encapsulating class
package MMGal::Entry::Picture::Static;
use strict;
use warnings;
use base 'MMGal::Entry::Picture';
use Carp;
use Image::Magick;
use POSIX;

sub init
{
	my $self = shift;
	$self->SUPER::init(@_);
	$self->{image_info_class} = 'MMGal::ImageInfo';
}

sub refresh_scaled_pictures
{
	my $self = shift;
	return $self->refresh_miniatures([$self->medium_dir, 800, 600], [$self->thumbnails_dir, 200, 150]);
}

sub image_info
{
	my $self = shift;
	return $self->{image_info} if exists $self->{image_info};
	$self->{image_info} = eval { $self->{image_info_class}->read($self->{path_name}); };
	warn "Cannot retrieve image info from [".$self->{path_name}."]: ".$@."\n" if $@;
	return unless $self->{image_info};
	my $tools = $self->tools or croak "tools not injected";
	my $parser = $self->tools->{exif_dtparser} or croak "no parser in tools";
	$self->{image_info}->{parser} = $parser if $self->{image_info};
	return $self->{image_info};
}

sub description
{
	my $self = shift;
	my $i = $self->image_info or return;
	return $i->description;
}

sub read_image
{
	my $self = shift;
	my $i = Image::Magick->new;
	my $r;
	$r = $i->Read($self->{path_name})	and die $self->{path_name}.': '.$r;
	return $i;
}

sub creation_time
{
	my $self = shift;
	my $info = $self->image_info or return $self->SUPER::creation_time(@_);
	return $info->creation_time || $self->SUPER::creation_time(@_);
}

1;
