# mamgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# A helper class which knows how to create Entry subclass objects from paths
package MaMGal::EntryFactory;
use strict;
use warnings;
use Carp;
use base 'MaMGal::Base';
use MaMGal::Entry::Dir;
use MaMGal::Entry::Picture;
use MaMGal::Entry::Picture::Static;
use MaMGal::Entry::Picture::Film;
use MaMGal::Entry::NonPicture;
use MaMGal::Entry::BrokenSymlink;
use MaMGal::Entry::Unreadable;
use MaMGal::Exceptions;
use File::stat;
use Fcntl ':mode';
use Cwd;
use Locale::gettext;

sub init
{
	my $self = shift;
	my $formatter = shift or croak "Need a formatter arg";
	ref $formatter and $formatter->isa('MaMGal::Formatter') or croak "Arg is not a formatter, but a [$formatter]";
	my $mplayer_wrapper = shift or croak "Need an mplayer wrapper arg";
	ref $mplayer_wrapper and $mplayer_wrapper->isa('MaMGal::MplayerWrapper') or croak "Arg is not an mplayer wrapper, but a [$mplayer_wrapper]";
	my $image_info_factory = shift or croak "Need an image info factory arg ";
	ref $image_info_factory and $image_info_factory->isa('MaMGal::ImageInfoFactory') or croak "Arg is not an MaMGal::ImageInfoFactory, but a [$image_info_factory]";
	my $logger = shift or croak "Need a logger arg ";
	ref $logger and $logger->isa('MaMGal::Logger') or croak "Arg is not a MaMGal::Logger , but a [$logger]";
	$self->{formatter} = $formatter;
	$self->{mplayer_wrapper} = $mplayer_wrapper;
	$self->{image_info_factory} = $image_info_factory;
	$self->{logger} = $logger;
}

sub sounds_like_picture($)
{
	my $base_name = shift;
	return $base_name =~ /\.(jpe?g|gif|png|tiff?|bmp)$/io;
}

sub sounds_like_film($)
{
	my $base_name = shift;
	return $base_name =~ /\.(mpe?g|mov|avi|mjpeg|m[12]v|wmv|fli|nuv|vob|ogm|vcd|svcd|mp4|qt|ogg)$/io;
}

sub canonicalize_path($)
{
	croak "List context required" unless wantarray;

	my $path = shift;

	# Do some path mangling in two special cases:
	if ($path eq '.') {
		# discover current directory name, so that it looks nice in
		# listings, and we know where to ascend when retracting towards
		# root directory
		$path = Cwd::abs_path($path);
	} elsif ($path eq '/') {
		# mangle the path so that the following regular expression
		# splits it nicely
		$path = '//.';
	}

	# Split the path into containing directory and basename, stripping any trailing slashes
	$path =~ m{^(.*?)/?([^/]+)/*$}o or confess sprintf(gettext("Internal Error: [%s] does not end with a base name."), $path);
	my ($dirname, $basename) = ($1 || '.', $2);
	return ($path, $dirname, $basename);
}


sub create_entry_for
{
	my $self = shift;
	my $path_arg = shift or croak "Need path"; # absolute, or relative to CWD
	croak "Need 1 arg, got more: [$_[0]]" if @_;

	my ($path, $dirname, $basename) = canonicalize_path($path_arg);
	my $lstat = lstat($path) or MaMGal::SystemException->throw(message => '%s: getting status failed: %s', objects => [$path, $!]);
	my $stat = $lstat;
	if ($lstat->mode & S_IFLNK) {
		$stat = stat($path);
	}

	my $e;
	if (not $stat) {
		$e = MaMGal::Entry::BrokenSymlink->new($dirname, $basename, $lstat)

	} elsif ($stat->mode & S_IFDIR) {
		$e = MaMGal::Entry::Dir->new($dirname, $basename, $stat)

	} elsif (($stat->mode & S_IFREG) and sounds_like_picture($path)) {
		$e = MaMGal::Entry::Picture::Static->new($dirname, $basename, $stat)

	} elsif (($stat->mode & S_IFREG) and sounds_like_film($path)) {
		$e = MaMGal::Entry::Picture::Film->new($dirname, $basename, $stat)

	} else {
		$e = MaMGal::Entry::NonPicture->new($dirname, $basename, $stat)
	}
	$e->add_tools({ entry_factory => $self, map { $_ => $self->{$_} } qw(formatter mplayer_wrapper image_info_factory logger) });
	return $e;
}

1;
