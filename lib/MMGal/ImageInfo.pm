# mmgal - a program for creating static image galleries
# Copyright 2009 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# A factory class for the image info library wrappers, makes it possible to
# decouple the rest of the program from particular implementation.
package MMGal::ImageInfo;
use strict;
use warnings;
use base 'MMGal::Base';
use Carp;

my $implementation;

BEGIN {
	if (exists $ENV{MMGAL_FORCE_IMAGEINFO}) {
		$implementation = $ENV{MMGAL_FORCE_IMAGEINFO};
		eval "require $implementation" or die;
	} elsif (require MMGal::ImageInfo::ExifTool) {
		$implementation = 'MMGal::ImageInfo::ExifTool';
	} elsif (require MMGal::ImageInfo::ImageInfo) {
		$implementation = 'MMGal::ImageInfo::ImageInfo';
	} else {
		die "No usable image info library found (tried Image::ExifTool and Image::Info.\n";
	}
}

# Alias read to new, as the latter seems impossible to mock
sub read { shift; $implementation->new(@_) }

1;
