package MMGal::TestHelper;
use Test::MockObject;
use lib 'Exporter';
@EXPORT = 'get_mock_formatter';

sub get_mock_formatter {
	my @methods = @_;
	my $mf = Test::MockObject->new();
	$mf->set_isa('MMGal::Formatter');
	$mf->mock($_, sub { "whatever" }) for @methods;
	return $mf;
}

1;
