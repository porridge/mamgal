# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# A class for broken symlinks
package MMGal::Entry::BrokenSymlink;
use strict;
use warnings;
use base 'MMGal::Entry::NonPicture';
use Carp;

1;
