# $Id$
use strict;

use Test::Builder::Tester;
use Test::More tests => 33; # includes those in t/setup_common
use Test::File;

my $can_symlink = eval { symlink("",""); 1 };

my $test_directory = 'test_files';
SKIP: {
    skip "This system does't do symlinks", 5 unless $can_symlink;
    require "t/setup_common";
};

chdir $test_directory or print "bail out! Could not change directories: $!";


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Things that don't work with symlinks. Fake that we don't understand
# symlinks
{
no warnings 'redefine';
local *Test::File::_no_symlinks_here = sub { 1 };

my @subs = qw(
	file_is_symlink_ok
	symlink_target_exists_ok
	symlink_target_dangles_ok
	symlink_target_is
	);

foreach my $sub ( @subs )
	{
	no strict 'refs';
	
	test_out("ok 1 # skip $sub doesn't work on systems without symlinks");
	&{$sub}();	
	test_test();
	}

}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#
{
my $test_name     = "This is my test name";
my $readable      = 'readable';
my $readable_sym  = 'readable_sym';
my $not_there     = 'not_there';
my $dangle_sym    = 'dangle_sym';

my $s = ! $can_symlink
	? "# skip file_is_symlink_ok doesn't work on systems without symlinks"
	: "- $readable_sym is a symlink";

file_exists_ok( $readable );
file_not_exists_ok( $readable_sym );

test_out( "ok 1 - $test_name\nok 2 - $test_name\nok 3 - $test_name" );
link_count_lt_ok( $readable, 100, $test_name );
link_count_gt_ok( $readable,   0, $test_name );
link_count_is_ok( $readable,   1, $test_name );
test_test();

test_out( "ok 1 - $readable has a link count of [1]" );
link_count_is_ok( $readable, 1 );
test_test();

test_out( "not ok 1 - $test_name" );
test_diag( 
	"File [$readable] points has [1] links: expected [100]!\n" .
	"#   Failed test '$test_name'\n" . 
	"#   at $0 line " . line_num(+5) . "." 
	);
link_count_is_ok( $readable, 100, $test_name );
test_test();

if( $can_symlink )
	{
	symlink( $readable, $readable_sym );
	
	open my($fh), ">", $not_there;
	close $fh;
	file_exists_ok( $not_there );
	
	symlink( $not_there, $dangle_sym );
	file_exists_ok( $readable_sym );
	file_exists_ok( $dangle_sym );
	
	unlink $not_there;
	file_exists_ok( $dangle_sym );
	ok( ! -e $not_there );
	}
else
	{
	pass();
	}

test_out( "ok 1 $s" );
file_is_symlink_ok( $readable_sym );
test_test();

test_out( "ok 1 - $test_name" );
file_is_symlink_ok( $readable_sym, $test_name );
test_test();

test_out( "ok 1 - $test_name" );
symlink_target_dangles_ok( $dangle_sym, $test_name );
test_test();

test_out( "not ok 1 - $test_name" );
test_diag( 
	"File [$readable] is not a symlink!\n" .
	"#   Failed test '$test_name'\n" . 
	"#   at $0 line " . line_num(+5) . "." 
	);
file_is_symlink_ok( $readable, $test_name );
test_test();

test_out( "not ok 1 - $test_name" );
test_diag( 
	"File [$not_there] is not a symlink!\n" .
	"#   Failed test '$test_name'\n" . 
	"#   at $0 line " . line_num(+5) . "." 
	);
file_is_symlink_ok( $not_there, $test_name );
test_test();

test_out( "not ok 1 - $test_name" );
test_diag( 
	"File [$not_there] is not a symlink!\n" .
	"#   Failed test '$test_name'\n" . 
	"#   at $0 line " . line_num(+5) . "." 
	);
file_is_symlink_ok( $not_there, $test_name );
test_test();

test_out( "not ok 1 - $test_name" );
test_diag( 
	"File [$readable] is not a symlink!\n" .
	"#   Failed test '$test_name'\n" . 
	"#   at $0 line " . line_num(+5) . "." 
	);
symlink_target_is( $readable, $readable_sym, $test_name );
test_test();

test_out( "ok 1 $s\nok 2 - $test_name" );
symlink_target_exists_ok( $readable_sym, $readable );
symlink_target_is( $readable_sym, $readable, $test_name );
test_test();

test_out( "ok 1 - $test_name" );
symlink_target_exists_ok( $readable_sym, $readable, $test_name );
test_test();

# Test using bad target that doesn't exist
test_out( "not ok 1 $s" );
test_diag( 
	"Symlink [$readable_sym] points to non-existent target [$not_there]!\n" .
	"#   Failed test '$readable_sym is a symlink'\n" . 
	"#   at $0 line " . line_num(+5) . "." 
	);
symlink_target_exists_ok( $readable_sym, $not_there );
test_test();

test_out( "not ok 1 - symlink $readable_sym points to $not_there" );
test_diag( 
	"  Failed test 'symlink $readable_sym points to $not_there'\n" .
	"#   at $0 line " . line_num(+6) . ".\n" .
	"#        got: $readable\n" .
	"#   expected: $not_there\n" 
	);
symlink_target_is( $readable_sym, $not_there );
test_test();

# Test using bad target that exists
test_out( "not ok 1 $s" );
test_diag( 
	"Symlink [$readable_sym] points to\n" .
	"#     $readable\n" . 
	"# expected\n" .
	"#     writeable\n#\n" .
	"#   Failed test '$readable_sym is a symlink'\n" . 
	"#   at $0 line " . line_num(+8) . "." 
	);
symlink_target_exists_ok( $readable_sym, "writeable" );
test_test();

# Test using non-symlink
test_out( "not ok 1 - $readable is a symlink" );
test_diag( 
	"File [$readable] is not a symlink!\n" . 
	"#   Failed test '$readable is a symlink'\n" . 
	"#   at $0 line " . line_num(+5) . "." 
	);
symlink_target_exists_ok( $readable );
test_test();


}

END {
unlink glob( "test_files/*" );
rmdir "test_files";
}