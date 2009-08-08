# mamgal - a program for creating static image galleries
# Copyright 2007-2009 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
# Exception class definitions.
package MaMGal::Exceptions;
use strict;
use warnings;
use Carp;
use Exception::Class (
	'MaMGal::MplayerWrapper::NotAvailableException',
	'MaMGal::MplayerWrapper::ExecutionFailureException' => {
		fields => [qw(stdout stderr)],
	},
	'MaMGal::SystemException' => {
		fields => [qw(objects)],
	}
);

package MaMGal::MplayerWrapper::NotAvailableException;
use strict;
use warnings;
use Carp;

sub _initialize
{
	my $self = shift;
	croak "this exception does not accept arguments" if @_;
	$self->SUPER::_initialize(@_);
}

sub message
{
	my $self = shift;
	'mplayer is not available - films will not be represented by snapshots.'
}

package MaMGal::MplayerWrapper::ExecutionFailureException;
use strict;
use warnings;
use Carp;

sub _initialize
{
	my $self = shift;
	$self->SUPER::_initialize(@_);
	croak "This exception requires a message argument" unless $self->message;
	croak "Either one or three arguments are required" if $self->stdout xor $self->stderr;
}

package MaMGal::SystemException;
use strict;
use warnings;
use Carp;

sub _initialize
{
	my $self = shift;
	$self->SUPER::_initialize(@_);
	croak "This exception requires a message argument" unless $self->message;
	# zero-width negative look-ahead assertion: a percent not followed by percent
	my $placeholder_count = () = $self->message =~ /%(?!%)/g;
	my $object_count = $self->objects ? scalar @{$self->objects} : 0;
	croak "Message with $placeholder_count placeholders must be followed by this many arguments, not $object_count" unless $placeholder_count == $object_count;
}

sub interpolated_message
{
	my $self = shift;
	my @args = $self->objects ? @{$self->objects} : ();
	sprintf($self->message, @args);
}

1;
