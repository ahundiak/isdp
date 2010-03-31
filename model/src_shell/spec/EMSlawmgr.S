/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    An object of this class may be constructed in the transient
    object-space. Only one such object exists per session and is not
    filed away. It maintains the various laws (default and
    user-specified).

  HISTORY

    SS  :  08/24/89  :  Creation
*/

class specification EMSlawmgr (1:3) of Root;

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
#include "exdef.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"

instance EMSlawmgr
  {
  IGRint num_lawcvs;
  variable struct IGRbsp_curve *lawcvs[];
  variable IGRint size_lawcvs[];
  variable IGRchar name_lawcvs[][MAX_CHAR+1];
  };

message EMinit (IGRlong *msg);

/*
 * Name and cv must be input, cvinx is returned
 */
message EMputcv (IGRlong *msg; IGRchar *name; IGRint *cvinx;
                 struct IGRbsp_curve *cv);

/*
 * Name or cvinx must be input (the other can be "" or -1, respectively).
 * The indicator that has not been input is returned along with the
 * malloced curve-structure.
 */
message EMgetcv (IGRlong *msg; IGRchar *name; IGRint *cvinx;
                 struct IGRbsp_curve **cv);

end specification EMSlawmgr;

