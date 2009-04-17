# mamgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information

use ExtUtils::MakeMaker;
WriteMakefile(
	'NAME'		=> 'MaMGal',
	'VERSION_FROM'	=> 'lib/MaMGal/Maker.pm',
	'EXE_FILES'     => ['mamgal'],
);
