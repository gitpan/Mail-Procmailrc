use Test;
BEGIN { $| = 1; plan(tests => 2); chdir 't' if -d 't'; }
use blib;

##
## creating a new recipe file programmatically
## flush to disk and read again
##

use Mail::Procmailrc;

my $pmrc = new Mail::Procmailrc;

## push a variable assignment
my $v1 = new Mail::Procmailrc::Variable();
$v1->lval('FOO');
$v1->rval('bar');
$pmrc->push($v1);

## push another variable assignment
$pmrc->push( new Mail::Procmailrc::Variable(['PMDIR=$HOME/.procmail']));

## push an empty line
$pmrc->push( new Mail::Procmailrc::Literal );

## push an entire recipe
my $rec = new Mail::Procmailrc::Recipe;
$rec->flags(':0B:');
$rec->info('## put spam away');
$rec->conditions([ q(* 1^0 this is not spam),
		   q(* 1^0 please read this),
		   q(* 1^0 urgent assistance),
		 ]);
$rec->action('$PMDIR/spam');
$pmrc->push($rec);

## flush
$pmrc->flush("_tmp.$$");

my $pmrc_new = new Mail::Procmailrc("_tmp.$$");
ok( $pmrc->dump(), $pmrc_new->dump() );

## test that what we created matches what we imagined
ok( $pmrc_new->dump(), <<'_RECIPE_' );
FOO=bar
PMDIR=$HOME/.procmail

:0B:
## put spam away
* 1^0 this is not spam
* 1^0 please read this
* 1^0 urgent assistance
$PMDIR/spam
_RECIPE_

unlink("_tmp.$$");

exit;
