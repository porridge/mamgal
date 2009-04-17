package MMGal::Unit::ImageInfo::ExifTool;
use strict;
use warnings;
use Carp 'verbose';
use File::stat;
use Test::More;
use Test::Exception;
use Test::Warn;
BEGIN { our @ISA = 'MMGal::Unit::ImageInfo'; }
BEGIN { do 't/010_unit_imageinfo.t' }
use lib 'testlib';
use MMGal::TestHelper;

use vars '%ENV';
$ENV{MMGAL_FORCE_IMAGEINFO} = 'MMGal::ImageInfo::ExifTool';
MMGal::Unit::ImageInfo::ExifTool->runtests unless defined caller;

1;
