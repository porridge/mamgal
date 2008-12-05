# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# The picture encapsulating class
package MMGal::Entry::Picture;
use strict;
use warnings;
use base 'MMGal::Entry';
use Carp;

sub make
{
	my $self = shift;
	my $tools = shift or croak "Tools required\n";
	my $formatter = $tools->{formatter} or croak "Formatter required\n";
	ref $formatter and $formatter->isa('MMGal::Formatter') or croak "Arg is not a formatter\n";
	$self->refresh_scaled_pictures($tools);
	$self->refresh_slide($formatter);
}

sub refresh_slide
{
	my $self = shift;
	my $formatter = shift;

	$self->{container}->ensure_subdir_exists($self->slides_dir);
	$self->{container}->_write_contents_to(sub { $formatter->format_slide($self) }, $self->page_path);
}

sub refresh_miniatures
{
	my $self = shift;
	my $tools = shift or croak "Tools required\n";
	my @miniatures = @_ or croak "Need args: miniature specifications";
	my $i = $self->read_image($tools);
	my $r;
	for my $miniature (@miniatures) {
		my ($subdir, $x, $y, $suffix) = @$miniature;
		$self->scale_into($i, $x, $y);
		$self->{container}->ensure_subdir_exists($subdir);
		my $name = $self->{dir_name}.'/'.$subdir.'/'.$self->{base_name};
		$name .= $suffix if defined $suffix;
		$r = $i->Write($name)		and die "Writing \"${name}\": $r";
	}
}

sub page_path { $_[0]->slides_dir.'/'.$_[0]->{base_name}.'.html' }
sub thumbnail_path { $_[0]->thumbnails_dir.'/'.$_[0]->{base_name} }
sub absolute_thumbnail_path { $_[0]->{dir_name}.'/'.$_[0]->thumbnail_path }

# This method does not operate on MMGal::Entry::Picture::Static, but this was the most
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

1;
