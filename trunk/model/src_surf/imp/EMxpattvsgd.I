/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxsplane;
%safe
#include <math.h>
%endsafe


# include "msdef.h" /* MS message codes */
# include "ma.h"
# include "OMmacros.h"
# include "emsdef.h"
# include "emsmacros.h"
# include "EMcp.h"
# include "EMSprop.h"
# include "EMSopt.h"
# include "gocmacros.h"
# include "EMSbnddef.h"
# include "EMSbnd.h"
# include "EMSxsection.h"

/*
 DESCRIPTION
   This method connects a view specific graphics data object to the
   cross section plane.

 HISTORY     

        RC     12/09/88      Creation Date

*/

from EMSgradata import EMinit;

method EMattach_vsgd (
       IGRlong           *EMmsg;
       struct GRid       *vd_wn_GRid)
{
  IGRlong      OM_stat, mthd_stat;
  GRobjid      vsgd;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  wrapup:
   EMWRAPUP (*EMmsg, OM_stat, "In EMSxsplane.EMattach_vsgd");
   return (OM_stat);
  
}

end implementation EMSxsplane;
