# mmgal - a program for creating static image galleries
# Copyright 2007-2009 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# The picture encapsulating class
package MMGal::Entry::Picture;
use strict;
use warnings;
use base 'MMGal::Entry';
use Carp;
use File::stat;

sub make
{
	my $self = shift;
	return ($self->refresh_scaled_pictures, $self->refresh_slide);
}

sub refresh_slide
{
	my $self = shift;
	my $tools = $self->tools or croak "Tools were not injected";
	my $formatter = $tools->{formatter} or croak "Formatter required\n";
	ref $formatter and $formatter->isa('MMGal::Formatter') or croak "Arg is not a formatter\n";

	$self->container->ensure_subdir_exists($self->slides_dir);
	my $name = $self->{dir_name}.'/'.$self->page_path;
	$self->container->_write_contents_to(sub { $formatter->format_slide($self) }, $self->page_path) unless $self->fresher_than_me($name);
	return $self->page_path;
}

sub fresher_than_me
{
	my $self = shift;
	my $name = shift;
	if (-e $name) {
		my $stat = stat($name) or die "File \"$name\" exists, but cannot read its metadata (stat).\n";
		return 1 if $stat->mtime > $self->{stat}->mtime;
	}
	return 0;
}

sub refresh_miniatures
{
	my $self = shift;
	my @miniatures = @_ or croak "Need args: miniature specifications";
	my $i = undef;
	my $r;
	my @ret;
	for my $miniature (@miniatures) {
		my ($subdir, $x, $y, $suffix) = @$miniature;
		my $relative_name = $subdir.'/'.$self->{base_name}.($suffix ? $suffix : '');
		push @ret, $relative_name;
		my $name = $self->{dir_name}.'/'.$relative_name;
		next if $self->fresher_than_me($name);
		# loading image data deferred until it's necessary
		$i = $self->read_image unless defined $i;
		$self->scale_into($i, $x, $y);
		$self->container->ensure_subdir_exists($subdir);
		$r = $i->Write($name)		and die "Writing \"${name}\": $r";
	}
	return @ret;
}

sub page_path { $_[0]->slides_dir.'/'.$_[0]->{base_name}.'.html' }
sub thumbnail_path { $_[0]->thumbnails_dir.'/'.$_[0]->{base_name} }
sub absolute_thumbnail_path { $_[0]->{dir_name}.'/'.$_[0]->thumbnail_path }

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

1;
