# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# The directory encapsulating class
package MMGal::Entry::Dir;
use strict;
use warnings;
use base 'MMGal::Entry';
use Carp;
use MMGal::Entry::Picture;
use MMGal::DirIcon;
use Image::Magick;
use MMGal::EntryFactory;

sub page_path        { $_[0]->{base_name}.'/index.html' }
sub thumbnail_path   { $_[0]->{base_name}.'/index.png'  }

sub set_root
{
	my $self = shift;
	$self->{is_root} = shift;
}

sub make
{
	my $self = shift;
	my $formatter = shift or croak "Formatter required";
	ref $formatter and $formatter->isa('MMGal::Formatter') or croak "[$formatter] is not a formatter";

	$_->make($formatter) for $self->elements;
	$self->_write_montage(grep { $_->isa('MMGal::Entry::Picture') } $self->elements);
	$self->_write_contents_to(sub { $formatter->stylesheet    }, 'mmgal.css');
	$self->_write_contents_to(sub { $formatter->format($self) }, 'index.html');
}

sub ensure_subdir_exists
{
	my $self = shift;
	my $basename = shift;
	my $dir = $self->{path_name}.'/'.$basename;
	mkdir $dir or die "[$dir]: $!\n" unless -w $dir;
}

# get _picture_ neighbours of given picture
sub neighbours_of_index
{
	my $self = shift;
	my $idx  = shift;
	croak "neighbours_of_index must run in array context" unless wantarray;
	my @elements = $self->elements;
	$idx >= 0 or croak "Pic index must be at least 0";
	$idx < scalar @elements or croak "Pic index out of bounds for this dir";

	my ($prev, $next);
	my $i = $idx - 1;
	while ($i >= 0) {
		$prev = $elements[$i], last if $elements[$i]->isa('MMGal::Entry::Picture');
		$i--;
	}
	$i = $idx + 1;
	while ($i < scalar @elements) {
		$next = $elements[$i], last if $elements[$i]->isa('MMGal::Entry::Picture');
		$i++;
	}
	return $prev, $next;
}


sub _write_contents_to
{
	my $self = shift;
	my $code = shift;
	my $suffix = shift;
	my $full_name = $self->{path_name}.'/'.$suffix;
	$self->SUPER::_write_contents_to($code, $full_name);
}

sub _write_montage
{
	my $self = shift;
	my @images = @_;

	$self->_write_contents_to(sub { MMGal::DirIcon->img }, 'index.png'), return unless @images;

	my $r;
	my $stack = Image::Magick->new;
	my $count = scalar @images > 36 ? 36 : scalar @images;
	push @$stack, map {
		my $img = Image::Magick->new;
		my $rr;
		$rr = $img->Read($_->absolute_thumbnail_path)			and die $_->absolute_thumbnail_path.': '.$rr;
		$img } @images[0..($count-1)];

	my $side = 1 + int(sqrt($count));
	$side = 2 if $side < 2;

	my $montage;
	$r = $montage = $stack->Montage(tile => $side.'x'.$side);
	ref($r)									or  die "montage: $r";
	MMGal::Entry::Picture->scale_into($montage, 200, 150);
	$r = $montage->Write($self->{path_name}.'/index.png')			and die $self->{path_name}.'/index.png: '.$r;
}

sub _ignorable_name($)
{
	my $name = shift;
	# ignore hidden files
	return 1 if substr($_, 0, 1) eq '.';
	return 1 if grep { $_ eq $name } qw(index.html index.png mmgal.css slides medium thumbnails);
	return 0;
}

sub elements
{
	my $self = shift;
	# Lookup the cache
	return @{$self->{elements}} if exists $self->{elements};

	# Read the names from the dir
	my $path = $self->{path_name};
	opendir DIR, $path or die "[$path]: $!\n";
	my @entries = sort { $a cmp $b } grep { ! _ignorable_name($_) } readdir DIR;
	closedir DIR or die "[$path]: $!\n";

	my $i = 0;
	# Instantiate objects and cache them
	$self->{elements} = [ map {
			$_ = $path.'/'.$_ ;
			my $e = MMGal::EntryFactory->create_entry_for($_);
			$e->set_element_index($i++);
			$e->set_container($self);
			$e
		} @entries
	];
	return @{$self->{elements}};
}

1;
