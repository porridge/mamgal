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
use Locale::gettext;
use MMGal::LocaleEnv;

sub init
{
	my $self = shift;
	my $le = shift;
	if ($le) {
		unless (ref $le and $le->isa('MMGal::LocaleEnv')) {
			croak "Optional argument must be a LocaleEnv, if provided";
		}
	} else {
		$le = MMGal::LocaleEnv->new;
	}
	$self->set_locale_env($le);
}

sub set_locale_env
{
	my $self = shift;
	my $le = shift;
	$self->{locale_env} = $le;
}

sub HEADER
{
	my $self = shift;
	my $head = shift || '';
	sprintf("<html><head><meta http-equiv='Content-Type' content='text/html; charset=%s'>%s</head><body>", $self->{locale_env}->get_charset, $head);
}

sub MAYBE_LINK
{
	my $self = shift;
	my $link = shift;
	my $text = shift;
	if ($link) {
		$self->LINK($link.'.html', $text)
	} else {
		$text
	}
}

sub MAYBE_IMG
{
	my $self = shift;
	my $img = shift;
	if ($img) {
		sprintf("<img src='%s'/>", $img);
	} else {
		# TRANSLATORS: This text will appear literally where no thumbnail is avaialable
		# for a given object.
		# Please use &nbsp; for whitespace, to avoid line breaks.
		gettext('[no&nbsp;icon]');
	}
}

sub LINK
{
	my $self = shift;
	my $link = shift;
	my $text = shift;
	"<a href='$link'>$text</a>";
}

# TRANSLATORS: The following three are for navigation on a slide page (&lt; is shown as <, and &gt; as >)
sub PREV                { gettext('&lt;&lt; prev') }
sub NEXT                { gettext('next &gt;&gt;') }
sub LINK_DOWN		{ $_[0]->LINK('../index.html', gettext('Up a dir')) }
sub FOOTER		{ "</body></html>"; }
sub EMPTY_PAGE_TEXT	{ gettext("This directory is empty") }
sub CURDIR		{ sprintf '<span class="curdir">%s</span>', $_[1] }

sub format
{
	my $self = shift;
	my $dir  = shift;
	croak "Only one arg is required" if @_;
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
	my $time = $entry->creation_time();
	$ret .= sprintf('<br><span class="date">%s</span> <span class="time">%s</span><br>', $self->{locale_env}->format_date($time), $self->{locale_env}->format_time($time));
	$ret .= $self->LINK($path, $self->MAYBE_IMG($thumbnail_path));
	if ($entry->description) {
		$ret .= sprintf('<br><span class="desc">%s</span>', $entry->description);
	} else {
		$ret .= sprintf('<br><span class="filename">[%s]</span><br>', $self->LINK($path, $entry->name));
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

	my $r = $self->HEADER('<link rel="stylesheet" href="../mmgal.css" type="text/css">')."\n";
	$r .= '<div style="float:left">';
	$r .= $self->MAYBE_LINK($prev, $self->PREV);
	$r .= ' | ';
	# TRANSLATORS: This is the text of the link from a slide page to the index page.
	$r .= $self->LINK('../index.html', gettext('index'));
	$r .= ' | ';
	$r .= $self->MAYBE_LINK($next, $self->NEXT);
	$r .= '</div>';

	$r .= '<div style="float:right">[ ';
	$r .= join(' / ', map { $self->CURDIR($_->name) } $pic->containers);
	$r .= " ]</div><br>\n";

	$r .= "<p>\n";
	if ($pic->description) {
		$r .= sprintf('<span class="slide_desc">%s</span>', $pic->description);
	} else {
		$r .= sprintf('[<span class="slide_filename">%s</span>]', $pic->name);
	}
	$r .= "</p>\n";

	$r .= $self->LINK('../'.$pic->name, $self->MAYBE_IMG('../'.$pic->medium_dir.'/'.$pic->name));
	my $time = $pic->creation_time();
	$r .= sprintf('<br><span class="date">%s</span> <span class="time">%s</span><br>', $self->{locale_env}->format_date($time), $self->{locale_env}->format_time($time));
	$r .= $self->FOOTER;
	return $r;
}

sub stylesheet
{
	my $t = <<END;
table.index { width: 100% }
.entry_cell { text-align: center }
.slide_desc     { font-weight: bold }
.slide_filename { font-family: monospace }
.filename { font-family: monospace }
.curdir { font-size: xx-large; font-weight: normal }
END
	return $t;
}

1;
