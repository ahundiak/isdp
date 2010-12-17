#!/usr/bin/perl
# Do not alter this line: $Revision: 1.1.54.1 $
#======================================================================
#	SOURCE FILE: multiopts.pl
#	AUTHOR: Patrick Fitzgerald
#	DATE: 11/29/92
#  DESCRIPTION: Command-line argument reading.
#
#	SUBROUTINES CONTAINED:
#		Multiopts
#		abbrev
#
#	SUBROUTINES INVOKED:
#		abbrev
#
#	CHANGE HISTORY:
# 12-DEC-1991: pmfitzge
#	Created.
# 22-AUG-1993: pmfitzge
#	Added "--" support, cleaned up code.
# 22-AUG-1993:
#	Changed abbrev to return all applicable matches.
# 30-AUG-1993: pmfitzge
#	Added ability to specify flags anywhere on command line (that
#	is, before or after any non-flag options).



#----------------------------------------------------------------------
# Name: Multiopts
# Desc: Reads command-line arguments.
# Inputs: Description string.  Also uses @ARGV global.
# Return Value: 0 = success, non-zero = usage error, remaining args in @ARGV
# Subroutines called: abbrev
# Usage:	&Multiopts(<flags>) || die("invalid flags\n");
#
#	where <flags> is a string that describes the command line
#	flags.  Command line options are not limited to single
#	letters.
#	
#	You can specify two types of flags:
#
#	-flag		Flag without an argument.  Use a space after
#			this flag: "flag "
#	-flag <arg>	Flag with an argument.  Use a colon after this
#			flag: "flag:"
#
#	After this subroutine successfully returns, the value of
#	each flag is in the @opt_<flag> array.  If the user specified
#	an argument flag multiple times on the command line, the
#	values are stored in $opt_<flag>[0..n].
#
#	This subroutine stops processing the flags when it encounters
#	"--" or a command line option that does not begin with "-".
#
# Examples:
#	# options = [-display <disp> [-display <disp>] ...]
#	#           [-print <queue>] [-n]
#	&Multiopts('n display:queue:' );
#
#	@displays = @opt_display;
#	$queue = $opt_queue[0];
#	$n = @opt_n;
#----------------------------------------------------------------------
sub Multiopts
{
  local($meta) = $_[0];

  local($_,@NEW_ARGV,@matches,$abbrev,@flags,$flag_regexp,$errs);

  local($[) = 0; # index of the first array element

  @flags = split(/[ :]/, $meta);


  #--------------------------------------------------
  # Loop through the command line flags
  #
  while($_ = shift(@ARGV))
    {
      # If it is not a flag (that is, if it does not begin with "-",
      # then save it for later, and go to the next argument.
      unless (/^-(.*)/)
	{
	  push(@NEW_ARGV,$_);
	  next;
	}

      # Check if it is "--", the end of the flags
      last if ($_ eq '--');

      # Get the part without the "-"
      $abbrev = $1;
      
      #--------------------------------------------------
      # Find all flags for which the user's flag is an abbreviation
      #
      @matches = &abbrev($1, @flags);

      # ERROR: no matches, illegal flag!
      if ($#matches < 0)
	{
	  print STDERR "Unknown command-line flag: -$abbrev\n";
	  ++$errs;
	}

      # ERROR: more than one match, not a unique abbreviation!
      elsif ($#matches > 0)
	{
	  print(STDERR "Not a unique command-line flag ",
		"abbreviation: -$abbrev\n",
		"Matches: ", join(' ', grep(s/^/-/, @matches)), "\n");
	  ++$errs;
	}

      # SUCCESS: only one match
      else # ($#matches == 0)
	{
	  #--------------------------------------------------
	  # Now find out if the flag needs an argument
	  #

	  # Untaint the flag so it doesn't contain special regexp characters
	  ($flag_regexp = $matches[0]) =~ s#(\W)#\\$1#g;

	  # What was after the flag: " " or ":"?
	  $meta =~ /\b$flag_regexp\b([ :]?)/;

	  # Does not need an argument
	  if ($1 ne ':')
	    {
	      eval "\@opt_$matches[0] = 1";
	      next;
	    }

	  # ERROR: no argument present!
	  if ($ARGV[0] =~ /^-/  ||  $#ARGV < 0)
	    {
	      print(STDERR "Command-line flag -$matches[0] ",
		    "requires an argument.\n");
	      ++$errs;
	      next;
	    }

	  # Push the argument onto the @opt_<flag> array
	  eval "push( \@opt_$matches[0], shift(\@ARGV) );";
	}
    }

  unshift(@ARGV, @NEW_ARGV);

  $errs == 0; # return 0 if success, 1 otherwise
}



#----------------------------------------------------------------------
# Name: abbrev
# Desc: Returns the strings in LIST for which EXPR is an abbreviation.
#	If EXPR exactly matches on of the strings in LIST, then only EXPR is
#	returned.
# Inputs: abbreviated string, array of strings to check
# Return Value: single match, or array of all applicable matches
# Subroutines called: abbrev
# Usage: abbrev( EXPR, LIST );
# Example: abbrev( 'disp', 'display', 'doit' ) || die;
#----------------------------------------------------------------------
sub abbrev
{
  local($abbrev,@choices) = @_;
  local($choice,@matches);

  # Untaint $abbrev so it doesn't contain special regexp characters
  $abbrev =~ s/(\W)/\\$1/g;

  # Loop through all choices and find the matches
  foreach $choice (@choices)
    {
      # Is it an abbreviation?
      if ($choice =~ /^$abbrev/)
	{
	  # Special case:
	  # If it is an exact match, return only one match.
	  return($choice) if ($abbrev eq $choice);

	  push(@matches, $choice);
	}
    }

  return @matches;
}


1;
