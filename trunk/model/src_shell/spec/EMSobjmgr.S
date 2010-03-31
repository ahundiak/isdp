/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This class is the super class for all type of EMS defined object
    manager's. This super class exists to ensure some kinds of protocol,
    currently, during a wakeup and sleep. Each instance of manager is
    connected to an EMScleaner object (of which there is only one instance
    per object space). This EMScleaner being a sub-class of global_class
    (an exnuc defined class) receives a wakeup and sleep message every
    time a file is opened and closed, respectively. This causes the
    EMwakeup and EMsleep methods to be invoked on the manager's.

  HISTORY

    SS  :  09/21/88  :  Creation
*/

class specification EMSobjmgr (1:2) of Root;

#include <stdio.h>
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMSobjmgrdef.h"

instance EMSobjmgr
  {
  IGRulong label;
  channel {(many_to_one)} to_cleaner;
  };

message EMinit (IGRulong label; IGRchar *moreinfo);

message EMwakeup (IGRboolean temp_wakeup);

message EMsleep (IGRboolean temp_sleep; IGRboolean file_write);

message EMtouchobj (IGRlong *msg; GRobjid obj);

message EMgetinfo (IGRlong *msg; IGRulong *label);

message EMvalidate (IGRlong *msg; IGRushort options;
                    FILE *logfile; IGRchar *info; IGRint *severity);

reject EMwakeup, EMsleep, EMvalidate;

end specification EMSobjmgr;
   
