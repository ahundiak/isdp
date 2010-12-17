#!/usr/bin/perl
#
# Program:	kdsi
#
# Usage:
#   kdsi file_or_dir1 file_or_dir2 ...
#
# Purpose:
#   This Perl script is a wrapper around the kdsi program, which
#   counts lines of code in a C file.  This script calls 'indent' to
#   indent the code and then passes the result to kdsi.  It provides a
#   subtotal for each directory and a grand total at the end, if more
#   than one paths were passed in.
#
eval "exec /usr/bin/perl -S $0 $*"
	if $running_under_some_shell;

# include the 'find.pl' package
require "find.pl";

# Put lib directory on the front of the path
$ENV{'PATH'} = "/usr/ip32/certtools/bin:$ENV{'PATH'}";

# print headers
print "     LOC       BL       CL     NOC\tFilename\n";
print ('=' x 8, " ", '=' x 8, " ", '=' x 8, " ", '=' x 7, "\t",
       '=' x 35, "\n");

# Traverse desired filesystems

$number_of_dirs = $#ARGV;
foreach $start_dir (@ARGV) {
  if (-e $start_dir) {
    local (%CNT);
    &find($start_dir);
    &subtotal;
    print "\n\n";
  }
  else {
    print STDERR "$start_dir doesn't exist\n";
  }
}

&grand_total if ($number_of_dirs);

print "LOC = Lines Of Code\n";
print "BL  = Blank Lines\n";
print "CL  = Comment Lines\n";
print "NOC = Number Of Comments\n";
exit;

# wanted subroutine
#
# The find subroutine calls the wanted subroutine for each
# file/directory it finds.  If the file is a C file, call kdsi on it.
# Also keep a running total.
sub wanted
{
  local ($loc, $bl, $cl, $noc);

  if (/^.*\.c$/) {
    $dir =~ s@/$@@;
    $name = "${dir}/${_}" if ($name eq "");

    # chop './' off the front of the pathname
    $name =~ s@^\./@@;

    chdir $cwd;
    # run indent on the file, and pass the result to kdsi
    $_ = `indent -npro -kr -psl < $name | Kdsi`;
    chop;
    if (($loc, $bl, $cl, $noc) = (/\s*(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/)) {
      # add up current directory's total
      $CNT{'loc'} += $loc;
      $CNT{'bl'} += $bl;
      $CNT{'cl'} += $cl;
      $CNT{'noc'} += $noc;

      # add up grand total
      $GRAND_TOTAL{'loc'} += $loc;
      $GRAND_TOTAL{'bl'} += $bl;
      $GRAND_TOTAL{'cl'} += $cl;
      $GRAND_TOTAL{'noc'} += $noc;
    }
    print "$_\t$name\n";
    chdir $dir;
  }
}

sub subtotal
{
  local ($len_loc, $len_bl, $len_cl, $len_noc);

  # save the length of each of the fields
  $len_loc = length ($CNT{'loc'});
  $len_bl = length ($CNT{'bl'});
  $len_cl = length ($CNT{'cl'});
  $len_noc = length ($CNT{'noc'});

  # Print as many dashes ('-') as the field is wide.  This is done using the
  # 'x' repetition operator. '-' x 10 means to print 10 '-'.
  print (' ' x (8-$len_loc), '-' x $len_loc,
	 " ", ' ' x (8-$len_bl), '-' x $len_bl,
	 " ", ' ' x (8-$len_cl), '-' x $len_cl,
	 " ", ' ' x (7-$len_noc), '-' x $len_noc,
	 "\n");

  # print the totals themselves
  printf ("%8d %8d %8d %7d\tTotal\n", $CNT{'loc'}, $CNT{'bl'},
	  $CNT{'cl'}, $CNT{'noc'});
}


sub grand_total
{
  local ($len_loc, $len_bl, $len_cl, $len_noc);

  # save the length of each of the fields
  $len_loc = length ($GRAND_TOTAL{'loc'});
  $len_bl = length ($GRAND_TOTAL{'bl'});
  $len_cl = length ($GRAND_TOTAL{'cl'});
  $len_noc = length ($GRAND_TOTAL{'noc'});

  # print the totals themselves
  printf ("%8d %8d %8d %7d\tGrand Total\n", $GRAND_TOTAL{'loc'},
	  $GRAND_TOTAL{'bl'}, $GRAND_TOTAL{'cl'}, $GRAND_TOTAL{'noc'});
}
