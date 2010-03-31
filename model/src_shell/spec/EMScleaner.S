/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    Objects of this class are intended as gates through which control must
    pass whenever a file is being brought up or closed. There is one such
    object per object space. Their specific task is to deliver the EMwakeup
    and EMsleep messages to the EMS-controlled object managers.

  HISTORY

    SS  :  09/15/88  :  Creation
*/

class specification EMScleaner (1:2) of global_class;

#include <stdio.h>
#include "igrtypedef.h"

instance EMScleaner
 {
 channel {(one_to_many)} to_objmgr;
 };

override sleep, wake_up;

message EMvalidate_objmgr (IGRlong *msg; IGRushort options;
                           FILE *logfile; IGRchar *info; IGRint *severity);

end specification EMScleaner;
