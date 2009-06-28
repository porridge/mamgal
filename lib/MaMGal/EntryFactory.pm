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
use File::stat;
use Fcntl ':mode';
use Cwd;
use Locale::gettext;

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
	croak "list context required" unless wantarray;

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
	$path =~ m{^(.*?)/?([^/]+)/*$}o or die sprintf(gettext("Internal Error: [%s] does not end with a base name.\n"), $path);
	my ($dirname, $basename) = ($1 || '.', $2);
	return ($path, $dirname, $basename);
}


sub create_entry_for
{
	my $self = shift;
	my $path_arg = shift or croak "Need path"; # absolute, or relative to CWD
	croak "Need 1 arg, got more: [$_[0]]" if @_;

	my ($path, $dirname, $basename) = canonicalize_path($path_arg);
	my $lstat = lstat($path) or croak "[$path]: $!";
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
	$e->add_tools({entry_factory => $self});
	return $e;
}

1;
