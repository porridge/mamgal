# mamgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# An output formatting class, for creating the actual index files from some
# contents
package MaMGal::MplayerWrapper;
use strict;
use warnings;
use base 'MaMGal::Base';
use Carp;
use File::Temp 'tempdir';

sub init
{
	my $self = shift;
	croak "No arguments allowed" if @_;
	$self->{tempdir} = tempdir(CLEANUP => 1);
	# The above dies on failure
}

sub run_mplayer
{
	my $self = shift;
	my $film_path = shift;
	my $dir = $self->{tempdir};
	my $pid = fork;
	if (not defined $pid) {
		die "Fork failed: $!";
	} elsif ($pid == 0) {
		# Child
		open(STDOUT, ">${dir}/stdout") or die "Cannot open \"${dir}/stdout\" for writing: $!";
		open(STDERR, ">${dir}/stderr") or die "Cannot open \"${dir}/stderr\" for writing: $!";
		my @cmd = ('mplayer', $film_path, '-noautosub', '-nosound', '-vo', "jpeg:quality=100:outdir=${dir}", '-frames', '2');
		exec(@cmd);
		die "Cannot run mplayer: $!\n";
	} else {
		# Parent
		waitpid($pid, 0);
		die "Mplayer failed ($?).\n", $self->mplayer_warnings if $? != 0;
	}
}

sub mplayer_warnings
{
	my $self = shift;
	my $dir = $self->{tempdir};
	my @ret;
	push @ret,
	 "Mplayer STDOUT:\n",
	 "-------------------------------------------------------------------------------------------\n";
	open(F, "<${dir}/stdout") or die "Cannot open \"${dir}/stdout\" for reading: $!";
	push @ret, <F>;
	close(F) or die "Cannot close \"${dir}/stdout\": $!";
	push @ret, "-------------------------------------------------------------------------------------------\n",
	 "Mplayer STDERR:\n",
	 "-------------------------------------------------------------------------------------------\n";
	open(F, "<${dir}/stderr") or die "Cannot open \"${dir}/stderr\" for reading: $!";
	push @ret, <F>;
	close(F) or die "Cannot close \"${dir}/stdout\": $!";
	push @ret, "-------------------------------------------------------------------------------------------\n";
	return @ret;
}
	
sub snapshot
{
	my $self = shift;
	my $film_path = shift or croak "snapshot needs an arg: path to the film";
	-r $film_path or croak "\"$film_path\" is not readable";
	my $dir = $self->{tempdir};
	$self->run_mplayer($film_path);
	my $img = Image::Magick->new;
	if (my $r = $img->Read("${dir}/00000001.jpg")) {
		die "Could not read the snapshot produced by mplayer: $r\n", $self->mplayer_warnings;
	}
	$self->cleanup;
	return $img;
}

sub cleanup
{
	my $self = shift;
	my $path = $self->{tempdir};
	opendir my $d, $path or die "Cannot open \"$path\" to clean up after mplayer";
	my @files = readdir $d;
	closedir $d;
	# This assumes that mplayer did not create any directories.
	unlink(map($path.'/'.$_, @files));
}

1;
