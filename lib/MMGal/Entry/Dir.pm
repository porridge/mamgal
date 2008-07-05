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

sub child            { $_[0]->{path_name}.'/'.$_[1]     }
sub page_path        { $_[0]->{base_name}.'/index.html' }
sub thumbnail_path   { $_[0]->{base_name}.'/index.png'  }

sub init
{
	my $self = shift;
	$self->SUPER::init(@_);
	if ($self->{dir_name} eq '/' and ($self->{base_name} eq '/' or $self->{base_name} eq '.')) {
		$self->{path_name} = '/';
		$self->{base_name} = '/';
		$self->{is_root} = 1;
	} elsif (-e $self->child('.mmgal-root')) {
		$self->{is_root} = 1;
	}
}

sub set_root
{
	my $self = shift;
	my $was_root = $self->is_root;
	my $is_root = $self->{is_root} = shift; 

	return if $is_root == $was_root;

	if ($is_root) {
		$self->_write_contents_to(sub {''}, '.mmgal-root');
	} else {
		unlink($self->child('.mmgal-root')) or die "unlink ".$self->child(".mmgal-root").": $!";
	}
}

sub is_root
{
	my $self = shift;
	return $self->{is_root} || 0;
}

sub make
{
	my $self = shift;
	my $formatter = shift or croak "Formatter required";
	ref $formatter and $formatter->isa('MMGal::Formatter') or croak "[$formatter] is not a formatter";

	foreach my $el ($self->elements) { $el->make($formatter) }
	$self->_write_montage;
	$self->_write_contents_to(sub { $formatter->stylesheet    }, 'mmgal.css');
	$self->_write_contents_to(sub { $formatter->format($self) }, 'index.html');
}

sub ensure_subdir_exists
{
	my $self = shift;
	my $basename = shift;
	my $dir = $self->child($basename);
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
	my $full_name = $self->child($suffix);
	$self->SUPER::_write_contents_to($code, $full_name);
}

sub _write_montage
{
	my $self = shift;
	my @images = grep { $_->isa('MMGal::Entry::Picture') } $self->elements;

	unless (@images) {
		$self->_write_contents_to(sub { MMGal::DirIcon->img }, 'index.png');
		return;
	}

	# Get just a bunch of images, not all of them.
	my $montage_count = scalar @images > 36 ? 36 : scalar @images;
	# Stack them all together
	my $stack = Image::Magick->new;
	push @$stack, map {
		my $img = Image::Magick->new;
		my $rr;
		$rr = $img->Read($_->absolute_thumbnail_path)			and die $_->absolute_thumbnail_path.': '.$rr;
		$img } @images[0..($montage_count-1)];

	# The montage is a visual clue that the object is a container.
	# Therefore ensure we do not get a 1x1 montage, because it would be
	# indistinguishable from a single image.
	my $side = 1 + int(sqrt($montage_count));
	$side = 2 if $side < 2;

	my ($m_x, $m_y) = (200, 150);

	my ($montage, $r);
	# Do the magick, scale and write.
	$r = $montage = $stack->Montage(tile => $side.'x'.$side, geometry => $m_x.'x'.$m_y, border => 2);
	ref($r)									or  die "montage: $r";
	MMGal::Entry::Picture->scale_into($montage, $m_x, $m_y);
	$r = $montage->Write($self->child('index.png'))			and die $self->child('index.png').': '.$r;
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

sub containers
{
	my $self = shift;
	return if $self->is_root;
	return $self->SUPER::containers(@_);
}

1;
