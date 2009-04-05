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
	return $self->refresh_miniatures([$self->medium_dir, 800, 600], [$self->thumbnails_dir, 200, 150]);
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
	my $tools = $self->tools or croak "tools not injected";
	my $parser = $self->tools->{exif_dtparser} or croak "no parser in tools";
	my $exif_time = undef;
	foreach my $tag (qw(DateTimeOriginal DateTime)) {
		next unless exists $info->{$tag};
		$exif_time = eval { $parser->parse($info->{$tag}); };
		my $e = $@;
		return $exif_time if defined $exif_time;
		if ($e) {
			chomp $e;
			warn sprintf('%s: %s: %s', $self->{path_name}, $tag, $e);
		}
	}
	return $self->SUPER::creation_time(@_);
}

1;
