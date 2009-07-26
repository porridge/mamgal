#!/usr/bin/perl
# mamgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Carp;
use Carp 'verbose';
use Test::More tests => 29;
use Test::Exception;
use Test::Files;
use lib 'testlib';
use MaMGal::TestHelper;

use_ok('MaMGal::Maker');
dies_ok(sub { MaMGal::Maker->new },        "maker creation fails with no arg");
dies_ok(sub { MaMGal::Maker->new('foo') }, "maker creation fails with something else than entry factory");

sub get_mock_entry
{
	my $class = shift or croak "class required";
	my $mock_entry = Test::MockObject->new
		->mock('set_root')
		->mock('make')
		->mock('add_tools');
	$mock_entry->set_isa($class);
	return $mock_entry;
}

my $mock_dir = get_mock_entry('MaMGal::Entry::Dir');
my $ef_dir = Test::MockObject->new
	->mock('create_entry_for', sub { $mock_dir });
$ef_dir->set_isa('MaMGal::EntryFactory');

my $mock_nodir = get_mock_entry('MaMGal::Entry::SomethingElse');
my $ef_nodir = Test::MockObject->new
	->mock('create_entry_for', sub { $mock_nodir });
$ef_nodir->set_isa('MaMGal::EntryFactory');

my $ef_crash = Test::MockObject->new
	->mock('create_entry_for', sub { croak 'dying here on purpose' });
$ef_crash->set_isa('MaMGal::EntryFactory');


my ($m_dir, $m_nodir, $m_crash);
lives_ok(sub { $m_dir = MaMGal::Maker->new($ef_dir) },     "maker creation succeeds with proper entry factory arg");
lives_ok(sub { $m_nodir = MaMGal::Maker->new($ef_nodir) }, "maker creation succeeds with other entry factory arg");
lives_ok(sub { $m_crash = MaMGal::Maker->new($ef_crash) }, "maker creation succeeds with yet different entry factory arg");
isa_ok($m_dir, 'MaMGal::Maker');
isa_ok($m_nodir, 'MaMGal::Maker');
isa_ok($m_crash, 'MaMGal::Maker');

throws_ok { $m_dir->make_roots } qr{^Argument required\.$}, "maker dies on no args";
throws_ok { $m_nodir->make_roots } qr{^Argument required\.$}, "maker dies on no args";
throws_ok { $m_crash->make_roots } qr{^Argument required\.$}, "maker dies on no args";

throws_ok { $m_dir->make_without_roots } qr{^Argument required\.$}, "maker dies on no args";
throws_ok { $m_nodir->make_without_roots } qr{^Argument required\.$}, "maker dies on no args";
throws_ok { $m_crash->make_without_roots } qr{^Argument required\.$}, "maker dies on no args";

throws_ok { $m_nodir->make_roots('something/whatever') } qr{^something/whatever: not a directory\.$}, "maker dies if thing returned by factory is not a dir object";
throws_ok { $m_crash->make_roots('something/whatever') } qr{^dying here on purpose}, "maker dies if factory call crashes";
throws_ok { $m_nodir->make_without_roots('something/whatever') } qr{^something/whatever: not a directory\.$}, "maker dies if thing returned by factory is not a dir object";
throws_ok { $m_crash->make_without_roots('something/whatever') } qr{^dying here on purpose}, "maker dies if factory call crashes";

ok($m_dir->make_without_roots('some/thing'), "maker returns success on an empty dir");
# TODO: what about make_without_roots?
my ($method, $args) = $ef_dir->next_call;
is($method, 'create_entry_for', 'create_entry_for called on the factory');
is($args->[1], 'some/thing', 'correct path passed to the factory');
ok(! $mock_dir->called('set_root'), 'root not set');
ok(! $mock_dir->called('add_tools'), 'tools not set - factory does this');
$mock_dir->clear;

ok($m_dir->make_roots('some/thing2'), "maker returns success on an empty dir");
($method, $args) = $ef_dir->next_call;
is($method, 'create_entry_for', 'create_entry_for called on the factory');
is($args->[1], 'some/thing2', 'correct path passed to the factory');
$mock_dir->called_ok('set_root', 'root set');
ok(! $mock_dir->called('add_tools'), 'tools not set - factory does this');
$mock_dir->clear;

