use Test;
BEGIN { $| = 1; plan(tests => 13); chdir 't' if -d 't'; }
use blib;

use Mail::Procmailrc;

my $rcfile;
my @rcfile;
my $pmrc;

#########################################################
## test string constructor
#########################################################
$rcfile =<<'_RCFILE_';
LOGABSTRACT=yes

PMDIR=$HOME/.procmail

:0B:
## block indecent emails
* 1^0 people talking dirty
* 1^0 dirty persian poetry
* 1^0 dirty pictures
* 1^0 xxx
/dev/null
_RCFILE_

ok( $pmrc = new Mail::Procmailrc( { 'data' => $rcfile } ) );
ok( $pmrc->dump(), $rcfile );

#########################################################
## test different recipes
#########################################################

$rcfile =<<'_RCFILE_';
PMDIR=$HOME/.procmail

:0BH:
## badtrans
*  -1500^0
*    800^0  ^From: .*<_.*>
*    400^0  ^Content-Type: audio/x-wav
*    400^0  name=.*\.(doc|zip|mp3)\.(scr|pif)
$PMDIR/spam.test

:0B:
## Universal Advertising Systems
*  -1000^0
*    100^.5  please
*    200^0   removal
*    400^1   r[ .]*e[ .]*m[ .]*o[ .]*v[ .]*e
*    200^0   +++++++++++++++++++++++++++++++
$PMDIR/spam.test
_RCFILE_

ok( $pmrc->parse( $rcfile ) );
ok( $pmrc->dump(), $rcfile );


#########################################################
## test array ref constructor
#########################################################
$rcfile =<<'_RCFILE_';
:0c:
$PMDIR/in_copy
_RCFILE_
@rcfile = map { "$_\n" } split(/\n/, $rcfile);

ok( $pmrc = new Mail::Procmailrc( { 'data' => \@rcfile } ) );
ok( $pmrc->dump(), $rcfile );

$rcfile =<<'_RCFILE_';
:0
## forward all mail to joe
!joe@foo.bar
_RCFILE_
@rcfile = map { "$_\n" } split(/\n/, $rcfile);

ok( $pmrc = new Mail::Procmailrc( { 'data' => \@rcfile } ) );
ok( $pmrc->dump(), $rcfile );


#########################################################
## test recipe blank line squeezing
#########################################################

$rcfile =<<'_RCFILE_';
:0c:


$PMDIR/copy



:0:


* stinky pete


/var/mail/pete




:0
* this is not spam





/dev/null

_RCFILE_

my $trcfile =<<'_RCFILE_';
:0c:
$PMDIR/copy

:0:
* stinky pete
/var/mail/pete

:0
* this is not spam
/dev/null
_RCFILE_

ok( $pmrc->parse($rcfile) );
ok( $pmrc->dump(), $trcfile );

#####
$rcfile =<<'_RCFILE_';
    PMDIR=$HOME/.procmail
    
    :0BH:
    ## badtrans
    *  -1500^0
    *    800^0  ^From: .*<_.*>
    *    400^0  ^Content-Type: audio/x-wav
    *    400^0  name=.*\.(doc|zip|mp3)\.(scr|pif)
    $PMDIR/spam.test
    
    :0B:
    ## Universal Advertising Systems
    *  -1000^0
    *    100^.5  please
    *    200^0   removal
    *    400^1   r[ .]*e[ .]*m[ .]*o[ .]*v[ .]*e
    *    200^0   +++++++++++++++++++++++++++++++
    $PMDIR/spam.test
_RCFILE_

ok( $pmrc->level( 2 ) );
ok( $pmrc->parse( $rcfile ) );
ok( $pmrc->dump(), $rcfile );

#########################################################
## test file constructor
#########################################################

## constructor from file
#ok( $pmrc = new Mail::Procmailrc( { 'path' => 'rc.foo' } ) );


exit;
