# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# The picture encapsulating class
package MMGal::Entry::Picture;
use strict;
use warnings;
use base 'MMGal::Entry';
use Carp;
use Image::Magick;
use Image::Info;
use POSIX;

sub make
{
	my $self = shift;
	my $formatter = shift or croak "Formatter required\n";
	ref $formatter and $formatter->isa('MMGal::Formatter') or croak "Arg is not a formatter\n";
	$self->refresh_medium_and_thumbnail;
	$self->refresh_slide($formatter);
}

sub refresh_medium_and_thumbnail
{
	my $self = shift;
	return $self->refresh_miniatures(['medium', 800, 600], ['thumbnails', 200, 150]);
}

sub refresh_slide
{
	my $self = shift;
	my $formatter = shift;

	$self->{container}->ensure_subdir_exists('slides');
	$self->{container}->_write_contents_to(sub { $formatter->format_slide($self) }, 'slides/'.$self->{base_name}.'.html');
}

sub page_path { 'slides/'.$_[0]->{base_name}.'.html' }
sub thumbnail_path { 'thumbnails/'.$_[0]->{base_name} }
sub absolute_thumbnail_path { $_[0]->{dir_name}.'/thumbnails/'.$_[0]->{base_name} }

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

sub refresh_miniature
{
	my $self = shift;
	return $self->refresh_miniatures([@_]);
}

sub refresh_miniatures
{
	my $self = shift;
	my @miniatures = @_ or croak "Need args: miniature specifications";
	my $i = Image::Magick->new;
	my $r;
	$r = $i->Read($self->{path_name})	and die $self->{path_name}.': '.$r;
	for my $miniature (@miniatures) {
		my ($subdir, $x, $y) = @$miniature;
		$self->scale_into($i, $x, $y);
		$self->{container}->ensure_subdir_exists($subdir);
		my $name = $self->{dir_name}.'/'.$subdir.'/'.$self->{base_name};
		$r = $i->Write($name)		and die $name.': '.$r;
	}
}

# This method does not operate on MMGal::Entry::Picture, but this was the most
# appropriate place to put it into.  At least until we grow a "utils" class.
sub scale_into
{
	my $that = shift;
	my $img = shift;
	ref($img) and $img->isa('Image::Magick') or croak "Need arg: an image";
	my ($x, $y) = @_;

	my $r;
	my ($x_pic, $y_pic) = $img->Get('width', 'height');
	my ($x_ratio, $y_ratio) = ($x_pic / $x, $y_pic / $y);
	if ($x_ratio <= 1 and $y_ratio <= 1) {
		return; # no need to scale
	} elsif ($x_ratio > $y_ratio) {
		$r = $img->Scale(width => $x, height => $y_pic / $x_ratio) and die $r;
	} else {
		$r = $img->Scale(height => $y, width => $x_pic / $y_ratio) and die $r;
	}
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
