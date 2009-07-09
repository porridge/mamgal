# mamgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# The picture encapsulating class
package MaMGal::Entry::Picture::Film;
use strict;
use warnings;
use base 'MaMGal::Entry::Picture';
use MaMGal::VideoIcon;
use Carp;
use Scalar::Util 'blessed';

my $thumbnail_extension = '.png';

sub refresh_scaled_pictures
{
	my $self = shift;
	return $self->refresh_miniatures([$self->thumbnails_dir, 200, 150, $thumbnail_extension]);
}

our $warned_before;

sub _new_video_icon
{
	my $self = shift;
	my $s = Image::Magick->new(magick => 'png');
	$s->BlobToImage(MaMGal::VideoIcon->img);
	$s;
}

sub read_image
{
	my $self = shift;
	my $tools = $self->tools or croak "Tools were not injected.";
	my $w = $tools->{mplayer_wrapper} or croak "MplayerWrapper required.\n";
	my $s;
	eval { $s = $w->snapshot($self->{path_name}); };
	if ($@) {
		if (blessed($@) and $@->isa('MaMGal::MplayerWrapper::NotAvailableException')) {
			$self->logger->log_message("mplayer is not available - films will not be represented by snapshots.") unless $warned_before;
			# TODO this warning limiting mechanism is a gross hack, but will do for single-threaded implementation.
			# Ideally the messages should be handed over to a logging subsystem which would make its own decision
			# on whether to log or not.
			$warned_before = 1;
			$s = $self->_new_video_icon;
		} elsif (blessed($@) and $@->isa('MaMGal::MplayerWrapper::ExecutionFailureException')) {
			$self->logger->log_message($self->{path_name}.': failed to produce a snapshot: '.$@->message);
			$s = $self->_new_video_icon;
		} else {
			die $@;
		}
	}
	return $s;
}

sub thumbnail_path { $_[0]->SUPER::thumbnail_path.$thumbnail_extension }

1;
