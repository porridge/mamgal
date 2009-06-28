#!/usr/bin/perl
# mamgal - a program for creating static image galleries
# Copyright 2007, 2008 Marcin Owsiany <marcin@owsiany.pl>
# See the README file for license information
use strict;
use warnings;
use Carp 'verbose';
use Test::More tests => 16;
use Test::Exception;
use Test::Files;
use lib 'testlib';
use MaMGal::TestHelper;

prepare_test_data;

use_ok('MaMGal::Maker');
my $m;
dies_ok(sub { MaMGal::Maker->new },		"maker creation fails with no arg");

my $mock_entry = Test::MockObject->new
	->mock('set_root')
	->mock('make')
	->mock('add_tools');
my $ef = Test::MockObject->new
	->mock('create_entry_for', sub { $mock_entry });
$ef->set_isa('MaMGal::EntryFactory');
lives_ok(sub { $m = MaMGal::Maker->new($ef) },  "maker creation succeeds with entry factory arg");
isa_ok($m, 'MaMGal::Maker');

dies_ok(sub { $m->make() },			"maker dies on no args");
dies_ok(sub { $m->make('td/nonexistant')},	"maker dies on an inexistant dir");

ok($m->make_without_roots('td/empty'),		"maker returns success on an empty dir");
my ($method, $args) = $ef->next_call;
is($method, 'create_entry_for', 'create_entry_for called on the factory');
is($args->[1], 'td/empty', 'correct path passed to the factory');
ok(! $mock_entry->called('set_root'), 'root not set');
ok(! $mock_entry->called('add_tools'), 'tools not set - factory does this');
$mock_entry->clear;

ok($m->make_roots('td/empty'),			"maker returns success on an empty dir");
($method, $args) = $ef->next_call;
is($method, 'create_entry_for', 'create_entry_for called on the factory');
is($args->[1], 'td/empty', 'correct path passed to the factory');
$mock_entry->called_ok('set_root', 'root set');
ok(! $mock_entry->called('add_tools'), 'tools not set - factory does this');
$mock_entry->clear;

