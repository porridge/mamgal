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
	my $cc = shift or croak 'Arg required: command checker';
	$cc->isa('MaMGal::CommandChecker') or croak 'Arg must be a CommandChecker';
	croak "Just one argument allowed" if @_;
	$self->{tempdir} = tempdir(CLEANUP => 1);
	# The above dies on failure
	$self->{cc} = $cc;
}

sub run_mplayer
{
	my $self = shift;
	my $film_path = shift;
	my $dir = $self->{tempdir};
	my $pid = fork;
	if (not defined $pid) {
		die MaMGal::MplayerWrapper::ExecutionFailureException->new("Fork failed: $!");
	} elsif ($pid == 0) {
		# Child
		open(STDOUT, ">${dir}/stdout") or die MaMGal::MplayerWrapper::ExecutionFailureException->new("Cannot open \"${dir}/stdout\" for writing: $!");
		open(STDERR, ">${dir}/stderr") or die MaMGal::MplayerWrapper::ExecutionFailureException->new("Cannot open \"${dir}/stderr\" for writing: $!");
		my @cmd = ('mplayer', $film_path, '-noautosub', '-nosound', '-vo', "jpeg:quality=100:outdir=${dir}", '-frames', '2');
		exec(@cmd);
		die MaMGal::MplayerWrapper::ExecutionFailureException->new("Cannot run mplayer: $!\n");
	} else {
		# Parent
		waitpid($pid, 0);
		die MaMGal::MplayerWrapper::ExecutionFailureException->new("Mplayer failed ($?).\n", $self->_read_messages) if $? != 0;
	}
}

sub _read_log
{
	my $self = shift;
	my $name = shift;
	my $dir = $self->{tempdir};
	open(F, "<${dir}/$name") or die MaMGal::MplayerWrapper::ExecutionFailureException->new("Cannot open \"${dir}/$name\" for reading: $!");
	my @ret = <F>;
	close(F) or die MaMGal::MplayerWrapper::ExecutionFailureException->new("Cannot close \"${dir}/$name\": $!");
	return \@ret;
}

sub _read_messages
{
	my $self = shift;
	return ($self->_read_log('stdout'), $self->_read_log('stderr'));
}

sub snapshot
{
	my $self = shift;
	$self->{available} = $self->{cc}->is_available('mplayer') unless exists $self->{available};
	die MaMGal::MplayerWrapper::NotAvailableException->new unless $self->{available};
	my $film_path = shift or croak "snapshot needs an arg: path to the film";
	-r $film_path or croak "\"$film_path\" is not readable";
	my $dir = $self->{tempdir};
	$self->run_mplayer($film_path);
	my $img = Image::Magick->new;
	if (my $r = $img->Read("${dir}/00000001.jpg")) {
		die MaMGal::MplayerWrapper::ExecutionFailureException->new("Could not read the snapshot produced by mplayer: $r\n", $self->_read_messages);
	}
	$self->cleanup;
	return $img;
}

sub cleanup
{
	my $self = shift;
	my $path = $self->{tempdir};
	opendir my $d, $path or die MaMGal::MplayerWrapper::ExecutionFailureException->new("Cannot open \"$path\" to clean up after mplayer");
	my @files = readdir $d;
	closedir $d;
	# This assumes that mplayer did not create any directories.
	unlink(map($path.'/'.$_, @files));
}

package MaMGal::MplayerWrapper::NotAvailableException;
use strict;
use warnings;
use base 'MaMGal::Base';
use Carp;

sub init
{
	my $self = shift;
	croak "this exception does not accept arguments" if @_;
}

sub message
{
	my $self = shift;
	'mplayer is not available - films will not be represented by snapshots.'
}

package MaMGal::MplayerWrapper::ExecutionFailureException;
use strict;
use warnings;
use base 'MaMGal::Base';
use Carp;

sub init
{
	my $self = shift;
	$self->{message} = shift or croak "Message is required";
	$self->{stdout} = shift;
	$self->{stderr} = shift;
	croak "Either one or three arguments are required" if $self->{stdout} xor $self->{stderr};
}

sub message
{
	my $self = shift;
	$self->{message}
}

sub stdout
{
	my $self = shift;
	$self->{stdout}
}

sub stderr
{
	my $self = shift;
	$self->{stderr}
}


1;
