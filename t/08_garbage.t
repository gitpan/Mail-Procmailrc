use Test;
BEGIN { $| = 1; plan(tests => 3); chdir 't' if -d 't'; }
use blib;

## garbage testing

use Mail::Procmailrc;

my $rcfile;
my @rcfile;
my $pmrc = new Mail::Procmailrc;

$rcfile =<<'_RCFILE_';
## nice recipe
:0B:

## some conditions here
* foo
* bar

## file away
/dev/foobar
_RCFILE_

ok( $pmrc->parse( $rcfile ) );
ok( $pmrc->dump, <<'_RCFILE_' );
## nice recipe
:0B:
## some conditions here
* foo
* bar
/dev/foobar
_RCFILE_

ok( $pmrc->rc->[1]->action, '/dev/foobar' );

exit;
