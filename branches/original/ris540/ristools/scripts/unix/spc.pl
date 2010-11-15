#!/usr/bin/perl
# Do not alter this line: $Revision: 1.1.54.1 $
#======================================================================
#	SOURCE FILE: spc.pl
#	AUTHOR: Patrick Fitzgerald
#	DATE: 01/15/94
#  DESCRIPTION: Perl include file with general-function SPC subroutines.
#
#	SUBROUTINES CONTAINED:
#		SPCgetVersion
#
#	SUBROUTINES INVOKED:
#		debug
#
#	CHANGE HISTORY:
#======================================================================

require 'screen.pl';

#----------------------------------------------------------------------
# Make sure nobody tries to execute this file from the command line
#
die "$0: ERROR - This is a Perl include file.  Do not execute.\n"
  if ($0 =~ /spc\.pl$/);



#----------------------------------------------------------------------
# Name: SPCgetVersion
# Desc: Reads an RCS version string from a file.
# Inputs: Filename to read.
# Return Value: RCS version string, if any, or -1 if cannot read file
# Subroutines called:
# Example:
#	$version = &SPCgetVersion($filename);
#	die "cannot read $filename" if ($id == -1);
#	die "$filename has no SPC version, or invalid SPC version"
#	  unless ($version);
#	print "SPC version = $version\n";
#----------------------------------------------------------------------
sub SPCgetVersion
{
  local ($filename) = @_;
  local (*FILE,$_,$ver,$ver_regexp,$loop,$max_loop);

  $max_loop = 5; # maximum number of lines to search before giving up
		 # on finding the SPC revision

  #--------------------------------------------------
  # The following kludge is so we can check this file into SPC without
  # SPC expanding the Revision info.
  #
  $ver_regexp = '\$' . 'Revision: ?(.+) ?\$';

  open(FILE, $filename) || return -1;

  $loop = 0;
  while (<FILE>)
    {
      if (/$ver_regexp/) { $ver = $1; last; }
      last if ($loop++ > $max_loop);
    }
  close FILE;

  $ver; # return value
}


1;  # Perl include files must return 1.

__END__
# GNU Emacs Code
# Local Variables:
# mode: perl
# End:
