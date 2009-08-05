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
use MaMGal::Exceptions;

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
		MaMGal::SystemException->throw(message => 'No usable image info library found (looked for "Image::ExifTool" and "Image::Info" in %s).', objects => [join(':', @INC)]);;
	}
}

sub init
{
	my $self = shift;
	my $parser = shift or croak "A Image::EXIF::DateTime::Parser argument is required";
	ref $parser and $parser->isa('Image::EXIF::DateTime::Parser') or croak "Arg is not an Image::EXIF::DateTime::Parser , but a [$parser]";
	my $logger = shift or croak "A MaMGal::Logger argument is required";
	ref $logger and $logger->isa('MaMGal::Logger') or croak "Arg is not an MaMGal::Logger, but a [$logger]";
	$self->{parser} = $parser;
	$self->{logger} = $logger;
}

sub read {
	my $self = shift;
	my $o = $implementation->new(@_);
	$o->{parser} = $self->{parser};
	$o->{logger} = $self->{logger};
	$o
}

1;
