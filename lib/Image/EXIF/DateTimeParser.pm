# Image::EXIF::DateTimeParser - parser for EXIF date/time strings
# Copyright 2009 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
package Image::EXIF::DateTimeParser;
use strict;
use warnings;
use POSIX;

sub new
{
	my $that = shift;
	my $class = ref $that || $that;
	my $self = {};
	bless $self, $class;
}

sub parse
{
	my $self = shift;
	my $string = shift;
	if ($string =~ /^([\d\x20]{4})(.)([\d\x20]{2})(.)([\d\x20]{2})(.)([\d\x20]{2})(.)([\d\x20]{2})(.)([\d\x20]{2}).?$/)
	{
		my ($y, $m, $d, $H, $M, $S) = ($1, $3, $5, $7, $9, $11);
		my @colons = ($2, $4, $8, $10);
		my @space = $6;
		# if all fields were empty (or whitespace-only), it means that time is unknown
		return undef if not map { /^( |0)+$/ ? () : (1) } ($y, $m, $d, $H, $M, $S);
		my $time = POSIX::mktime($S, $M, $H, $d, $m-1, $y-1900, 0, 0, -1);
		return $time if defined $time;
		# falls through on mktime() error
	}
	die "Invalid and unknown EXIF DateTime [$string].\n";
}

1;
