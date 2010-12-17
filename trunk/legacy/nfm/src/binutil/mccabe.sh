#!/usr/bin/perl
#
# Program:	mccabe
#
# Usage:
#   mccabe file_or_dir1 file_or_dir2 ...
#
# Purpose:
#   This Perl script is outputs a mccabe complexity analysis for the
#   file or directory names passed in.  It does this by trying to
#   parse the C file and finding all if, while, case, else, etc.
#   structures.
#
#   It provides a subtotal for each path and a grand total at the
#   end, if more than one paths were passed in.
#
eval "exec /usr/bin/perl -S $0 $*"
	if $running_under_some_shell;

# include the 'find.pl' package
require "find.pl";

# Put lib directory on the front of the path
$ENV{'PATH'} = "/usr/ip32/certtools/bin:$ENV{'PATH'}";

# Traverse desired filesystems

if ($#ARGV < $[) {
  print "usage: $0 file1 [file2 ...]\n";
  exit 1;
}

$orig_dir = `pwd`;

&grand_initialize;

$number_of_dirs = $#ARGV;

foreach $start_dir (@ARGV) {
  if (-e $start_dir) {

    &initialize;

    if (-d _) {
      chdir ($start_dir);
      &find(".");
      &summarize;
      chdir ($orig_dir);
    }
    elsif (-f _) {
      &find($start_dir);
      &summarize;
    }
    $- = 0;			# force new page between directories
  }
  else {
    print STDERR "$start_dir doesn't exist\n";
  }
}

&grand_summarize if ($number_of_dirs);

exit;

# wanted subroutine
#
# The find subroutine calls the wanted subroutine for each
# file/directory it finds.  If the file is a C file, call mccabe on it.
sub wanted
{
    /^.*\.c$/ && &mccabe ($_, $name);
}

# initialize subroutine
#
# Initialize variables for each directory.
sub initialize
{
  $total_complexity = 0;
  $total_linecount = 0;
  $total_functions = 0;
  $total_complex10 = 0;
  $total_complex15 = 0;
  $total_complex20 = 0;
  $total_complex30 = 0;
  $total_complex40 = 0;
  $total_complex50 = 0;
  $total_complex75 = 0;
  $total_complex100 = 0;
  $total_complex200 = 0;
  $total_complex300 = 0;
  $total_complex400 = 0;
  $total_complex500 = 0;

  $nofunc = '*noname*';
}

# grand_initialize subroutine
#
# Initialize variables for grand totals.
sub grand_initialize
{
  $grand_complexity = 0;
  $grand_linecount = 0;
  $grand_functions = 0;
  $grand_complex10 = 0;
  $grand_complex15 = 0;
  $grand_complex20 = 0;
  $grand_complex30 = 0;
  $grand_complex40 = 0;
  $grand_complex50 = 0;
  $grand_complex75 = 0;
  $grand_complex100 = 0;
  $grand_complex200 = 0;
  $grand_complex300 = 0;
  $grand_complex400 = 0;
  $grand_complex500 = 0;
}

# mccabe subroutine
#
# Arguments: file, and full pathname
#
# Try to parse the C file, looking for function names and then
# counting C statements.
sub mccabe
{
  local ($file, $pathname) = @_;	# file and full pathname
  local ($gotfunction) = 0;		# have we got a function declaration?
  local ($infunction) = 0;		# are we in a function definition?
  local (%complexity);			# complexity of a function
  local (%returns);			# number of returns in a function
  local (%casecount);			# number of case statement labels
  local (%linecount);			# number of lines in a function
  local ($functions) = 0;		# number of functions in file
  local ($complex);			# complexity for a single function
  local ($file_complexity) = 0;		# total complexity for the file
  local ($file_linecount) = 0;		# total lines for the file

  $pathname = $file if ($pathname eq "");

  # chop './' off the front of the pathname
  $pathname =~ s@^\./@@;

  # initialize data for 'nofunc'
  $complexity{$nofunc} = 1;
  $returns{$nofunc} = 0;
  $casecount{$nofunc} = 0;
  $linecount{$nofunc} = 0;

  # format the code and remove the comments
  open (STRIPCOM, "indent -npro -kr -psl < $file | stripcom |")
    || die "Couldn't open $file";

  $~ = "pathname";			# switch to pathname format
  $- = 0 if ($- < 4);			# force new page if < 3 lines left
  write;
  $~ = "STDOUT";			# switch back to default format

  # read the output
  line: while (<STRIPCOM>) {
    chop;				# strip record separator

    # Should recognize the actual function
    #
    # look for a word starting a line with '(.*)'.  Make sure that
    # 'extern' is not the word.  Also make sure that the line doesn't
    # end in a ';', so that we haven't found a function pointer.
    if (/^[_a-zA-Z]\w*\s*\(.*\)?\s*$/ && $_ !~ /^extern\s+/
	&& $_ !~ /;\s*$/ && ! $infunction) {
      $gotfunction = 1;

      # strip off parens
      $endpos = index($_, '(');
      $funcname = substr($_, 0, $endpos);

      # strip off beginning declaratory stuff (if any)
      @funky = split(' ', $funcname, 9999);
      $funcname = $funky[$#funky];
      $complexity{$funcname} = 1;	# default complexity is 1
      $casecount{$funcname} = 0;
      $switchcount{$funcname} = 0;
      $linecount{$funcname} = 0;

      next line;
    }

    # do not count preprocessor lines
    if (/^#/) {
      next line;
    }
    # do not count blank lines
    if (/^\w*$/) {
      next line;
    }

    # find end of formal parameters
    if ($gotfunction && /[ 	]*{/) {
      $gotfunction = 0;
      $infunction = 1;

      $depth = index($_, '{');
      next line;
    }

    # count lines in the function
    $linecount{$funcname}++ if ($infunction);

    if ($infunction && /^\s*(if|else|while|for)($|[ \t(])/) {
      $complexity{$funcname}++;
    }

    if ($infunction && /^\s*switch($|[ \t(])/) {
      $switchcount{$funcname}++;
    }

    if ($infunction && /^\s*(case|default[ \t]*:)($|[ \t])/) {
      $casecount{$funcname}++;
    }

    if ($infunction && /^\s*return([ \t(]|$)/) {
      $returns{$funcname}++;
    }

    if ($infunction && /^\s*exit($|[ \t(])/) {
      $returns{$funcname}++;
    }

    if ($infunction && /}/) {
      if (index($_, '}') == $depth) {
	$infunction = 0;
	$gotfunction = 0;
      }
      next line;
    }

    if (! $infunction && /^\s*(if|else|while|for)($|[ \t(])/) {
      $complexity{$nofunc}++;
    }

    if (! $infunction && /^\s*(case|default[ \t]*:)($|[ \t])/) {
      $casecount{$nofunc}++;
    }

    if (! $infunction && /^\s*return([ \t(]|$)/) {
      $returns{$nofunc}++;
    }

    if (! $infunction && /^\s*exit($|[ \t(])/) {
      $returns{$nofunc}++;
    }
  }
  close (STRIPCOM);

  # output complexity for all functions
  $functions = 0;
  foreach $func (sort keys %complexity) {
    if ($func eq $nofunc && $complexity{$func} == 1 &&
	$casecount{$func} == 0 && $returns{$func} == 0) {
      next;
    }
    $functions++;
    $complex = $complexity{$func} + $casecount{$func};
    $- = 0 if ($- < 3);			# force new page if < 3 lines left
    write;
  }
  if ($functions == 0) {
    # this means that no functions were found in the file
    $func = $nofunc;
    $complex = $complexity{$func};
    write;
  }

  # sum up complexity for the file
  #
  # formula for complexity for a file is:
  #    file_complexity = ( (#loc1 * mccabe#1) + (#loc2 * mccabe#2)
  #			   + ... + (#locN * mccabe#N) ) / #loc_in_file
  # where: '#locX' is number of lines of code for function X, and
  #	   'mccabe#X' is the mccabe number for for function X
  foreach $func (sort keys %complexity) {
    if ($func eq $nofunc && $complexity{$func} == 1 &&
	$casecount{$func} == 0 && $returns{$func} == 0) {
      next;
    }
    $complex = $complexity{$func} + $casecount{$func};
    $file_complexity += ($linecount{$func} * $complex);
    $file_linecount += $linecount{$func};

    # keep track of complexities > 10
    if ($complex > 10) {
      $total_complex10++;
      $grand_complex10++;
    }
    if ($complex > 15) {
      $total_complex15++;
      $grand_complex15++;
    }
    if ($complex > 20) {
      $total_complex20++;
      $grand_complex20++;
    }
    if ($complex > 30) {
      $total_complex30++;
      $grand_complex30++;
    }
    if ($complex > 40) {
      $total_complex40++;
      $grand_complex40++;
    }
    if ($complex > 50) {
      $total_complex50++;
      $grand_complex50++;
    }
    if ($complex > 75) {
      $total_complex75++;
      $grand_complex75++;
    }
    if ($complex > 100) {
      $total_complex100++;
      $grand_complex100++;
    }
    if ($complex > 200) {
      $total_complex200++;
      $grand_complex200++;
    }
    if ($complex > 300) {
      $total_complex300++;
      $grand_complex300++;
    }
    if ($complex > 400) {
      $total_complex400++;
      $grand_complex400++;
    }
    if ($complex > 500) {
      $total_complex500++;
      $grand_complex500++;
    }
  }
  $total_functions += $functions;
  $grand_functions += $functions;
  $complex = 0;
  $complex = $file_complexity / $file_linecount if ($file_linecount);
  $~ = "file_total";			# switch to file_total format
  write;
  $~ = "STDOUT";			# switch back to default format

  $total_complexity += $file_complexity;
  $grand_complexity += $file_complexity;
  $total_linecount += $file_linecount;
  $grand_linecount += $file_linecount;
}

# summarize subroutine
#
# Summarize the complexity for a directory path.
sub summarize
{
  local ($total_complex);
  local ($complex);

  $^ = "";				# get rid of the top-of-page format

  $~ = "project_total";			# switch to project_total format
  $- = 0 if ($- < 3);			# force new page if < 3 lines left
  $total_complex = $total_linecount ? $total_complexity / $total_linecount : 0;
  write;

  $~ = "complexity";			# switch to complexity format
  if ($total_complex10 && $total_complex10 != $total_complex15) {
    $total_complex = $total_complex10;
    $complex = 10;
    write;
  }
  if ($total_complex15 && $total_complex15 != $total_complex20) {
    $total_complex = $total_complex15;
    $complex = 15;
    write;
  }
  if ($total_complex20 && $total_complex20 != $total_complex30) {
    $total_complex = $total_complex20;
    $complex = 20;
    write;
  }
  if ($total_complex30 && $total_complex30 != $total_complex40) {
    $total_complex = $total_complex30;
    $complex = 30;
    write;
  }
  if ($total_complex40 && $total_complex40 != $total_complex50) {
    $total_complex = $total_complex40;
    $complex = 40;
    write;
  }
  if ($total_complex50 && $total_complex50 != $total_complex75) {
    $total_complex = $total_complex50;
    $complex = 50;
    write;
  }
  if ($total_complex75 && $total_complex75 != $total_complex100) {
    $total_complex = $total_complex75;
    $complex = 75;
    write;
  }
  if ($total_complex100 && $total_complex100 != $total_complex200) {
    $total_complex = $total_complex100;
    $complex = 100;
    write;
  }
  if ($total_complex200 && $total_complex200 != $total_complex300) {
    $total_complex = $total_complex200;
    $complex = 200;
    write;
  }
  if ($total_complex300 && $total_complex300 != $total_complex400) {
    $total_complex = $total_complex300;
    $complex = 300;
    write;
  }
  if ($total_complex400 && $total_complex400 != $total_complex500) {
    $total_complex = $total_complex400;
    $complex = 400;
    write;
  }
  if ($total_complex500) {
    $total_complex = $total_complex500;
    $complex = 500;
    write;
  }

  $^ = "top";				# restore the top-of-page format
}

# grand_summarize subroutine
#
# Summarize the complexity for all directory paths specified.
sub grand_summarize
{
  local ($total_complex);
  local ($complex);

  $^ = "";				# get rid of the top-of-page format

  $~ = "grand_total";			# switch to grand_total format
  $- = 0;				# force new page
  write;

  $~ = "project_total";			# switch to project_total format

  $total_complex = $grand_linecount ? $grand_complexity / $grand_linecount : 0;
  $total_functions = $grand_functions;
  write;

  $~ = "complexity";			# switch to complexity format
  if ($grand_complex10 && $grand_complex10 != $grand_complex15) {
    $total_complex = $grand_complex10;
    $complex = 10;
    write;
  }
  if ($grand_complex15 && $grand_complex15 != $grand_complex20) {
    $total_complex = $grand_complex15;
    $complex = 15;
    write;
  }
  if ($grand_complex20 && $grand_complex20 != $grand_complex30) {
    $total_complex = $grand_complex20;
    $complex = 20;
    write;
  }
  if ($grand_complex30 && $grand_complex30 != $grand_complex40) {
    $total_complex = $grand_complex30;
    $complex = 30;
    write;
  }
  if ($grand_complex40 && $grand_complex40 != $grand_complex50) {
    $total_complex = $grand_complex40;
    $complex = 40;
    write;
  }
  if ($grand_complex50 && $grand_complex50 != $grand_complex75) {
    $total_complex = $grand_complex50;
    $complex = 50;
    write;
  }
  if ($grand_complex75 && $grand_complex75 != $grand_complex100) {
    $total_complex = $grand_complex75;
    $complex = 75;
    write;
  }
  if ($grand_complex100 && $grand_complex100 != $grand_complex200) {
    $total_complex = $grand_complex100;
    $complex = 100;
    write;
  }
  if ($grand_complex200 && $grand_complex200 != $grand_complex300) {
    $total_complex = $grand_complex200;
    $complex = 200;
    write;
  }
  if ($grand_complex300 && $grand_complex300 != $grand_complex400) {
    $total_complex = $grand_complex300;
    $complex = 300;
    write;
  }
  if ($grand_complex400 && $grand_complex400 != $grand_complex500) {
    $total_complex = $grand_complex400;
    $complex = 400;
    write;
  }
  if ($grand_complex500) {
    $total_complex = $grand_complex500;
    $complex = 500;
    write;
  }
}

#
# format statements
#
	
# top of form format
format top =
Function Name                               Complexity    Returns    Lines
----------------------------------------    ----------    -------    -----
.

# format for mccabe number for a function
format STDOUT =
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<      @######       @>>>>>>    @>>>>
$func, $complex, $returns{$func}, $linecount{$func}
.

# format for printing a pathname
format pathname =
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
"*** $pathname ***"
.

# format for mccabe number for a file
format file_total =
                                   Total    @######.##
$complex

.

# format for mccabe number for the project
format project_total =
Total complexity:                           @######.##
$total_complex
Total number of functions:                  @######
$total_functions

.

# format for reporting complexity analysis
format complexity =
There were @>>> function(s) (@#%) with a complexity > @>>
$total_complex, $total_complex / $total_functions * 100, $complex
.

# format for grand total
format grand_total =
Grand Total

.
