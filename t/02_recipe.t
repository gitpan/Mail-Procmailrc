use Test;
BEGIN { $| = 1; plan(tests => 9); chdir 't' if -d 't'; }
use blib;

use Mail::Procmailrc;

my $r1;
my $recipe;

$recipe =<<'_RECIPE_';
:0B:
## block indecent emails
* 1^0 people talking dirty
* 1^0 dirty persian poetry
* 1^0 dirty pictures
* 1^0 xxx
/dev/null
_RECIPE_

my @recipe = split(/\n/, $recipe);

## array constructor
ok( $r1 = new Mail::Procmailrc::Recipe(\@recipe) );

## test flags
ok( $r1->flags(), ':0B:' );

## test info
ok( join("\n", @{$r1->info()}), '## block indecent emails' );

## test conditions
ok( join("\n", @{$r1->conditions()}), "* 1^0 people talking dirty\
* 1^0 dirty persian poetry\
* 1^0 dirty pictures\
* 1^0 xxx" );

## test action
ok( $r1->action(), "/dev/null" );

## test whole recipe dump
ok( $r1->dump(), $recipe );

## test multiline action
$recipe =<<'_RECIPE_';
:0: bouncetemp.${BOUNCEPID}.lock
| (${FORMAIL} -rt \
  -I"From: MAILER-DAEMON@$RHOST (Mail Delivery Subsystem)" \
  -I"Subject: Returned mail: User unknown" \
  -I"Auto-Submitted: auto-generated (failure)" \
  -I"Bcc: ${SPAMERROR}" \
  -I"X-Loop: MAILER-DAEMON@${RHOST}";\
   echo "The original message was received at ${SPAMDATE}";\
   echo "from ${SPAMFROM}";\
   echo " ";\
   echo "   ----- The following addresses had permanent fatal errors -----";\
   echo "<${RECIPIENT}>";\
   echo " ";\
   echo "   ----- Transcript of session follows -----";\
   echo "... while talking to ${RHOST}.:";\
   echo ">>> RCPT To:<${RECIPIENT}>";\
   echo "<<< 550 5.1.1 <${RECIPIENT}>... User unknown";\
   echo "550 ${RECIPIENT}... User unknown";\
   echo " ";\
   echo "   ----- Original messages follows ----";\
   echo " ";\
   cat bouncetemp.${BOUNCEPID};\
   ${RM} -f bouncetemp.${BOUNCEPID}) \
   | ${SENDMAIL} -oi -t -fMAILER-DAEMON@${RHOST}
_RECIPE_

ok( $r1->init([split(/\n/, $recipe)]));
ok( $r1->flags(), ':0: bouncetemp.${BOUNCEPID}.lock' );
ok( $r1->dump(), $recipe );

exit;
