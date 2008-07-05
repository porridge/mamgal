package MMGal::TestHelper;
use Test::MockObject;
use lib 'Exporter';
@EXPORT = qw(get_mock_formatter prepare_test_data);

sub get_mock_formatter {
	my @methods = @_;
	my $mf = Test::MockObject->new();
	$mf->set_isa('MMGal::Formatter');
	$mf->mock($_, sub { "whatever" }) for @methods;
	return $mf;
}

sub prepare_test_data {
	# We have to create empty directories, because git does not track them
	for my $dir (qw(empty one_dir one_dir/subdir)) {
		mkdir("td.in/$dir") or die "td.in/$dir: $!" unless -d "td.in/$dir";
	}
	system('rm -rf td ; cp -a td.in td') == 0 or die "Test data preparation failed: $?";
}

1;
