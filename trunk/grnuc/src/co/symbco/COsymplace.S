/* #######################    APOGEE COMPILED   ######################## */
/*\
Abstract
   This is the command class for the place symbol, place cell, and
   place graphic group commands.

History
   Gray Winn   02/21/87    Creation date.
   Gray Winn   12/17/87    Changes for version 1.1
   Gray Winn   04/02/88    Added code for place graphic group
\*/

class specification COsymplace (0:5) of COroot;

#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grsymdef.h"
#include "grsym.h"

instance COsymplace
{
   IGRchar     classname[20]; /* classname                           */
   IGRshort    level;         /* The active level                    */
   IGRint      init_success;  /* Flag set if TRUE is successful init */
   IGRdouble   scale[3];      /* scale of the symbol from DPB        */
   IGRdouble   active_angle;  /* acitve angle from the DPB           */
   struct GRevent     origin_event; /* Event used for symbol origin  */
   struct GRdpb_scale dpb_scale;    /* DPB parameters                */
   struct GRactive_symbol_def active_symbol; /* Active symbol        */
};

override wakeup, execute;

end specification COsymplace;
