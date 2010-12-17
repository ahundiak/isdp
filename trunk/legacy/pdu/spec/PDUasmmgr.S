class specification PDUasmmgr (1:0) of global_class;

/*
DESCRIPTION

  This class provides for wakeup and sleep management functionality
  for the assembly modeling system. It also serves as a clearinghouse
  for updates to the assembly structure.

HISTORY

  Jamal Shakra     10/9/93  Creation date. 
*/


#include <igetypedef.h>
#include <igrtypedef.h>
#include <gr.h>

override sleep;
override wake_up;

end specification PDUasmmgr;
