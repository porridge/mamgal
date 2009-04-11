# mmgal - a program for creating static image galleries
# Copyright 2009 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# A wrapper class for the image info library, will make it easier to make the
# rest of the program independent of the particular implementation.
package MMGal::ImageInfo;
use strict;
use warnings;
use base 'MMGal::Base';
use Carp;

use Image::Info;

# Alias read to new, as the latter seems impossible to mock
sub read { my $that = shift; $that->new(@_) }

sub init
{
	my $self = shift;
	my $file = shift or croak 'filename not provided';
	my $info = Image::Info::image_info($file);
	croak $info->{error} if exists $info->{error};
	$self->{info} = $info;
	$self->{file_name} = $file;
}

sub description
{
	my $self = shift;
	$self->{info}->{Comment};
}

# EXIF v2.2 tag 0x9003 DateTimeOriginal
# "when the original image data was generated"
#
# aka. Date/Time Original (exiftool output)
# aka. DateTimeOriginal (Image::ExifTool::Exif)
# aka. DateTimeOriginal (Image::Info, Image::TIFF)
sub datetime_original_string
{
	my $self = shift;
	$self->{info}->{DateTimeOriginal};
}

# EXIF v2.2 tag 0x9004 DateTimeDigitized
# "when the image was stored as digital data"
#
# aka. Create Date (exiftool output)
# aka. CreateDate (Image::ExifTool::Exif)
# aka. DateTimeDigitized (Image::Info, Image::TIFF)
sub datetime_digitized_string
{
	my $self = shift;
	$self->{info}->{DateTimeDigitized};
}

# EXIF v2.2 tag 0x0132 DateTime
# "of image creation"
#
# aka. Modify Date (exiftool output)
# aka. ModifyDate (Image::ExifTool::Exif)
# aka. DateTime (Image::Info, Image::TIFF)
sub datetime_string
{
	my $self = shift;
	$self->{info}->{DateTime};
}

my %methods_to_tags = (
	datetime_original_string  => '0x9003',
	datetime_digitized_string => '0x9004',
	datetime_string           => '0x0132',
);

sub creation_time
{
	my $self = shift;
	foreach my $type (qw(_original_ _digitized_ _)) {
		my $method = "datetime${type}string";
		my $string = $self->$method;
		next unless $string;
		my $value = eval { $self->{parser}->parse($string); };
		my $e = $@;
		return $value if $value;
		if ($e) {
			chomp $e;
			warn sprintf('%s: EXIF tag %s: %s', $self->{file_name}, $methods_to_tags{$method}, $e);
		}
	}
	return undef;
}

1;
