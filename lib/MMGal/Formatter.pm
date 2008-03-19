# mmgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# An output formatting class, for creating the actual index files from some
# contents
package MMGal::Formatter;
use strict;
use warnings;
use base 'MMGal::Base';
use Carp;

sub HEADER
{
	my $self = shift;
	my $head = shift || '';
	"<html><head>$head</head><body>";
}

sub LINK_DOWN		{ "<a href='../index.html'>Up a dir</a>" }
sub FOOTER		{ "</body></html>"; }
sub EMPTY_PAGE_TEXT	{ "This directory is empty" }
sub CURDIR		{ sprintf '<span class="curdir">%s</span>', $_[1] }

sub format
{
	my $self = shift;
	my $dir  = shift;
	my @elements = $dir->elements;
	my $ret = $self->HEADER('<link rel="stylesheet" href="mmgal.css" type="text/css">')."\n";
	$ret .= '<table class="index">';
	$ret .= '<tr><th colspan="4" class="header_cell">';
	$ret .= join(' / ', map { $self->CURDIR($_->name) } $dir->containers, $dir);
	$ret .= '</th></tr>'."\n";
	$ret .= ($dir->is_root ? '' : '<tr><th colspan="4" class="header_cell">'.$self->LINK_DOWN.'</th></tr>')."\n";
	$ret .= "\n<tr>\n";
	my $i = 1;
	if (@elements) {
		for my $e (@elements) {
			die "[$e] is not an object" unless ref $e;
			die "[$e] is a ".ref($e) unless $e->isa('MMGal::Entry');
			$ret .= '  '.$self->entry_cell($e)."\n";
			$ret .= "</tr>\n<tr>\n" if $i % 4 == 0;
			$i++;
		}
	} else {
		$ret .= '<td colspan="4">'.$self->EMPTY_PAGE_TEXT.'</td>';
	}
	$ret .= "</tr>\n";
	return $ret.$self->FOOTER;
}

sub entry_cell
{
	my $self  = shift;
	my $entry = shift;
	my $path = $entry->page_path;
	my $thumbnail_path = $entry->thumbnail_path;
	my $ret = '';
	$ret .= '<td class="entry_cell">';
	$ret .= sprintf("<a href='%s'>", $path);
	if ($thumbnail_path) {
		$ret .= sprintf("<img src='%s'/>", $entry->thumbnail_path);
	} else {
		$ret .= '[no&nbsp;icon]';
	}
	$ret .= '</a>';
	if ($entry->description) {
		$ret .= sprintf('<br><span class="desc">%s</span>', $entry->description);
	} else {
		$ret .= sprintf('<br><span class="filename">[<a href="%s">%s</a>]</span><br>', $path, $entry->name);
	}
	$ret .= '</td>';
	return $ret;
}

sub format_slide
{
	my $self = shift;
	my $pic  = shift or croak "No pic";
	croak "Only one arg required." if @_;
	ref $pic and $pic->isa('MMGal::Entry::Picture') or croak "Arg is not a pic";

	my ($prev, $next) = map { defined $_ ? $_->name : '' } $pic->neighbours;

	my $r = $self->HEADER;
	if ($prev) {
		$r .= "<a href='$prev.html'>Prev</a>";
	} else {
		$r .= 'Prev';
	}
	$r .= " <a href='../index.html'>Index</a> ";
	if ($next) {
		$r .= "<a href='$next.html'>Next</a>";
	} else {
		$r .= 'Next';
	}
	$r .= ' [ ';
	$r .= join(' / ', map { $self->CURDIR($_->name) } $pic->containers);
	$r .= " ]<br>\n";
	if ($pic->description) {
		$r .= sprintf('<span class="slide_desc">%s</span><br>', $pic->description);
	} else {
		$r .= sprintf('[<span class="slide_filename">%s</span>]<br>', $pic->name);
	}
	$r .= sprintf('<a href="%s"><img src="%s"/></a>', '../'.$pic->{base_name}, '../medium/'.$pic->{base_name});
	$r .= $self->FOOTER;
	return $r;
}

sub stylesheet
{
	my $t = <<END;
table.index { width: 100% }
.entry_cell { text-align: center }
.slide_filename { font-family: monospace }
.filename { font-family: monospace }
.curdir { font-size: xx-large; font-weight: normal }
END
	return $t;
}

1;
