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
	# We have to create and populate directories with spaces in their
	# names, because perl's makemaker does not like them
	mkdir "td.in/more/zzz another subdir" unless -d "td.in/more/zzz another subdir";
	my $orig_size = -s "td.in/p.png" or die "Unable to stat td.in/p.png";
	my $dest_size = -s 'td.in/more/zzz another subdir/p.png';
	unless ($dest_size and $orig_size == $dest_size) {
		system('cp', '-a', 'td.in/p.png', 'td.in/more/zzz another subdir/p.png') unless $orig_size == -s 'td.in/more/zzz another subdir/p.png';
	}
	# Finally, purge and copy a clean version of the test data into "td"
	system('rm -rf td ; cp -a td.in td') == 0 or die "Test data preparation failed: $?";
}

1;
