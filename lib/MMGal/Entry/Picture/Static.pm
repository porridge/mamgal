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
use Image::Info;
use POSIX;

sub refresh_scaled_pictures
{
	my $self = shift;
	return $self->refresh_miniatures(['medium', 800, 600], ['thumbnails', 200, 150]);
}

sub image_info
{
	my $self = shift;
	return $self->{image_info} if defined $self->{image_info};
	$self->{image_info} = Image::Info::image_info($self->{path_name});
	warn "Cannot retrieve image info from [".$self->{path_name}."]: ".$self->{image_info}->{error}."\n" if exists $self->{image_info}->{error};
	return $self->{image_info};
}

sub description
{
	my $self = shift;
	return $self->{description} if $self->{description_is_cached};
	$self->{description} = $self->image_info->{Comment};
	$self->{description_is_cached} = 1;
	$self->{description};
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
	my $info = $self->image_info;
	my $exif_time = $info->{DateTimeOriginal} || $info->{DateTime} or return $self->SUPER::creation_time(@_);
	if ($exif_time =~ /^\s*(\d+):(\d+):(\d+)\s+(\d+):(\d+):(\d+)\s*$/) {
		my ($y, $m, $d, $H, $M, $S) = ($1, $2, $3, $4, $5, $6);
		my $time = POSIX::mktime($S, $M, $H, $d, $m-1, $y-1900);
		return $time if defined $time;
		# falls through on mktime() error
	}
	warn "Invalid EXIF DateTime [$exif_time] in [".$self->{path_name}."].\n";
	return $self->SUPER::creation_time(@_);
}

1;
