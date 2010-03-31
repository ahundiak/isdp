/*
  DESCRIPTION

  This command initializes all or specified "clocks" within the system.
  Another flavor of this command, prints the accumulated times of each
  of the clocks.
*/

class specification ECclock (3:2) of ECpathway;

#include "PWapi/clock.h"

instance ECclock
{
  char *outfile;
};

override init, execute;

end specification ECclock;
