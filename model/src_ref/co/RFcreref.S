class specification RFcreref (1:0) of super_cmd;

#include "OMindex.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "igr.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "dp.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "igrdef.h"
#include "lcdef.h"
#include "lc.h"

#define MAX_NAME 2048 

instance RFcreref
{
   IGRint rf_action;
   IGRchar filename[MAX_NAME];
   struct GRevent  locate_event,acc_event;
   struct GRlc_stack locate_stack;
};

override wakeup, execute;

end specification RFcreref;
