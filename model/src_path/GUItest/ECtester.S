/*
  DESCRIPTION

  This command takes in the input to test calls to pypyint2d and cvcvint2d. 
  It outputs an ASCII file and also graphically highlights the 
  intersection points.
*/

class specification ECtester (3:2) of ECpathway;

#include "PWapi/clock.h"

instance ECtester
{
  char *infile, *outfile;
};

override execute;

end specification ECtester;
