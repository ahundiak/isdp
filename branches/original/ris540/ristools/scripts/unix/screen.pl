#!/usr/bin/perl
# Do not alter this line: $Revision: 1.1.54.1 $
#======================================================================
#	SOURCE FILE: screen.pl
#	AUTHOR: Patrick Fitzgerald
#	DATE: 11/29/92
#  DESCRIPTION: Screen printing variables and subroutines.
#
#	SUBROUTINES CONTAINED:
#		clear_screen
#		title
#		msg
#		line
#		debug
#		fatal
#		non_fatal
#		sys
#		isSuperUser
#		count
#
#	SUBROUTINES INVOKED:
#
#	CHANGE HISTORY:
#
# 08-JUN-92: pmfitzge
#	Changed &msg subroutine: now prints to STDERR.  Changed escape
#	sequences to use octal numbers.  Removed get_char subroutine.
# 15-JUN-92: pmfitzge
#	Changed debug subroutine to use @opt_debug as well as $debug.
# 13-AUG-92: pmfitzge
#	Added $inTTY and $outTTY variables.
# 25-SEP-92: pmfitzge
#	Added &line subroutine.
# 05-FEB-93: pmfitzge
#	Added display flag to &sys subroutine.
# 19-MAY-93: pmfitzge
#	Added &count subroutine.

local ($progname) = $0;
$progname =~ s#.*/##;

$inTTY = (-t STDIN);
$outTTY = (-t STDOUT);
$errTTY = (-t STDERR);

if ($outTTY && $errTTY)
{
  $esc = "\033";
  $beep = "\007";		# ring my bell
  $hi = $esc . '[1m';	# activate highlighting
  $lo = $esc . '[0m';	# deactivate highlighting
  $back = "${esc}[1D";
}


sub clear_screen
{
  system( 'tput clear' );
}



sub title
{
  local($format) = $~;

  format TITLE_FORMAT =
======================================================================
| @||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| |
  $progname
======================================================================

.
  $~ = TITLE_FORMAT;
  write;
}



sub msg
{
  # USAGE: &msg( msg, ... );
  print(STDERR "$progname: ", join(' ', @_ ), "\n");
}



sub line
{
  # USAGE: &line;
  &msg('~' x 50);
}



sub debug
{
  # USAGE: &debug( msg, ... );
  print(STDERR "$progname: >DEBUG< ", join(' ', @_ ), "\n")
    if (@opt_debug || $debug);
}



sub fatal
{
  # USAGE: &fatal( msg, return_val );
  local($msg,$return,@junk) = @_;

  # Make sure return value is a digit
  if ( $return =~ /^\D$/ )
    {
      $msg .= join(' ', $return, @junk);
      $return = 1;
    }

  print(STDERR "$progname: >FATAL< $msg\n",
	"$progname: EXITING after fatal error\n" );
  exit($return);
}



sub non_fatal
{
  # USAGE: &non_fatal( msg, ... );
  print(STDERR "$progname: >WARNING< ", join(' ', @_ ), "\n");
}



sub sys
{
  local($cmd,$display_flag) = @_;
  local($status);

  if ($display_flag)
    {
      &msg("executing '$cmd'");
    }
  else
    {
      &debug("system command = '$cmd'");
    }

  system($cmd);
  &non_fatal("system command returned error '$status'")
    if ($status = $? >> 8);
  $status;
}


sub isSuperUser
{
  $> == 0;
}



sub count
{
  local($current,$total,$file) = @_;
  local($indent);

  &msg("[$current/$total] $hi$file$lo");
}



1;
