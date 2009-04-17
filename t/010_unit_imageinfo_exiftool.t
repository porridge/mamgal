package MaMGal::Unit::ImageInfo::ExifTool;
use strict;
use warnings;
use Carp 'verbose';
use File::stat;
use Test::More;
use Test::Exception;
use Test::Warn;
BEGIN { our @ISA = 'MaMGal::Unit::ImageInfo'; }
BEGIN { do 't/010_unit_imageinfo.t' }
use lib 'testlib';
use MaMGal::TestHelper;

use vars '%ENV';
$ENV{MAMGAL_FORCE_IMAGEINFO} = 'MaMGal::ImageInfo::ExifTool';
MaMGal::Unit::ImageInfo::ExifTool->runtests unless defined caller;

1;
