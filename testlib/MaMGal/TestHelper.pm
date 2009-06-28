# mamgal - a program for creating static image galleries
# Copyright 2008-2009 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
package MaMGal::TestHelper;
use Test::MockObject;
use lib 'Exporter';
@EXPORT = qw(get_mock_datetime_parser get_mock_formatter get_mock_localeenv get_mock_cc prepare_test_data get_mock_mplayer_wrapper);

sub get_mock_datetime_parser {
	my $p = Test::MockObject->new->mock('parse');
	$p->set_isa('Image::EXIF::DateTime::Parser');
	$p
}

sub get_mock_formatter {
	my @methods = @_;
	my $mf = Test::MockObject->new();
	$mf->set_isa('MaMGal::Formatter');
	$mf->mock($_, sub { "whatever" }) for @methods;
	return $mf;
}

sub get_mock_localeenv {
	my $ml = Test::MockObject->new();
	$ml->set_isa('MaMGal::LocaleEnv');
	$ml->mock('get_charset', sub { "ISO-8859-123" });
	$ml->mock('set_locale');
	$ml->mock('format_time', sub { "12:12:12" });
	$ml->mock('format_date', sub { "18 dec 2004" });
	return $ml;
}

sub get_mock_mplayer_wrapper {
	my $mmw = Test::MockObject->new;
	$mmw->set_isa('MaMGal::MplayerWrapper');
	my $mock_image = Test::MockObject->new;
	$mock_image->set_isa('Image::Magick');
	$mock_image->mock('Get', sub { '100', '100' });
	$mock_image->mock('Scale', sub { undef });
	$mock_image->mock('Write', sub { system('touch', $_[1] ) });
	$mmw->mock('snapshot', sub { $mock_image });
	return $mmw;
}

sub get_mock_cc($) {
	my $ret = shift;
	my $mcc = Test::MockObject->new;
	$mcc->set_isa('MaMGal::CommandChecker');
	$mcc->mock('is_available', sub { $ret });
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
		system('cp', '-a', 'td.in/p.png', 'td.in/more/zzz another subdir/p.png');
	}
	# We also need to create our test symlinks, because MakeMaker does not like them
	for my $pair ([qw(td.in/symlink_broken broken)], [qw(td.in/symlink_pic_noext one_pic/a1.png)], [qw(td.in/symlink_to_empty empty)], [qw(td.in/symlink_to_empty_file empty_file)], [qw(td.in/symlink_pic.png one_pic/a1.png)]) {
		my ($link, $dest) = @$pair;
		symlink($dest, $link) or die "Failed to symlink [$dest] to [$link]" unless -l $link;
	}
	# Finally, purge and copy a clean version of the test data into "td"
	system('rm -rf td ; cp -a td.in td') == 0 or die "Test data preparation failed: $?";
}

1;
