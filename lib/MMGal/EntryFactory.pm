# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# A helper class which knows how to create Entry subclass objects from paths
package MMGal::EntryFactory;
use strict;
use warnings;
use Carp;
use MMGal::Entry::Dir;
use MMGal::Entry::Picture;
use MMGal::Entry::NonPicture;
use MMGal::Entry::BrokenSymlink;
use MMGal::Entry::Unreadable;
use File::stat;
use Fcntl ':mode';

sub _sounds_like_picture($)
{
	my $base_name = shift;
	return $base_name =~ /\.(jpe?g|gif|png|tiff?|bmp)$/i;
}

sub create_entry_for
{
	shift;
	my $path = shift or croak "Need path"; # relative to WD
	$path =~ m{^(.*?)/?([^/]+)/*$}o or die "[$path] does not end with a base name";
	my ($dirname, $basename) = ($1, $2);
	croak "Need 1 args, got second: [$_[0]]" if @_;

	my $stat = lstat($path);
	croak "[$path]: $!" if not $stat;

	$stat = stat($path) if ($stat->mode & S_IFLNK);

	return MMGal::Entry::BrokenSymlink->new($dirname, $basename)  if not $stat;
	return MMGal::Entry::Dir->new($dirname, $basename, $stat)     if ($stat->mode & S_IFDIR);
	return MMGal::Entry::Picture->new($dirname, $basename, $stat) if ($stat->mode & S_IFREG) and _sounds_like_picture($basename);
	return MMGal::Entry::NonPicture->new($dirname, $basename, $stat);
}

1;
