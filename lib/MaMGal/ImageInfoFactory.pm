# mamgal - a program for creating static image galleries
# Copyright 2009 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# A factory class for the image info library wrappers, makes it possible to
# decouple the rest of the program from particular implementation.
package MaMGal::ImageInfoFactory;
use strict;
use warnings;
use base 'MaMGal::Base';
use Carp;

my $implementation;

BEGIN {
	if (exists $ENV{MAMGAL_FORCE_IMAGEINFO}) {
		$implementation = $ENV{MAMGAL_FORCE_IMAGEINFO};
		eval "require $implementation" or die;
	} elsif (eval "require MaMGal::ImageInfo::ExifTool") {
		$implementation = 'MaMGal::ImageInfo::ExifTool';
	} elsif (eval "require MaMGal::ImageInfo::ImageInfo") {
		$implementation = 'MaMGal::ImageInfo::ImageInfo';
	} else {
		die "No usable image info library found (tried Image::ExifTool and Image::Info.\n";
	}
}

sub init
{
	my $self = shift;
	my $parser = shift or croak "A Image::EXIF::DateTime::Parser argument is required";
	if (defined $parser) {
		ref $parser and $parser->isa('Image::EXIF::DateTime::Parser') or croak "Arg is not an Image::EXIF::DateTime::Parser , but a [$parser]";
	}
}

# Alias read to new, as the latter seems impossible to mock
sub read { shift; $implementation->new(@_) }

1;
