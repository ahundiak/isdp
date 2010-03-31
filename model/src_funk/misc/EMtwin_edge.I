/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
class implementation GRvg;

/*
  HISTORY

    Sudha  07/09/93  :  Modified for BSprototypes anisfication
*/

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "OMerrordef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "EMSerrordef.h"
#include "bssfeval.h"
#include "bsdistptpts.h"

IGRlong EMget_twin_edge (EMmsg, surface, point, edge1, edge2, is_u,
                         right_edge)
 
IGRlong *EMmsg;
struct IGRbsp_surface *surface;
IGRpoint point;
GRobjid edge1, edge2;
IGRboolean is_u;
GRobjid *right_edge;
{
 IGRlong        stat_OM, msg;
 IGRpoint       pnts[2];
 IGRdouble      parm0, parm1;
 IGRdouble      bas_tol;

/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 BSEXTRACTPAR(&msg, BSTOLSQLENVEC, bas_tol);

 if (is_u)
  {
   parm0 = 0; parm1 = 0;
   BSsfeval(surface, parm0, parm1, 0, (IGRpoint *)pnts[0], &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   parm0 = 0; parm1 = 1;
   BSsfeval(surface, parm0, parm1, 0, (IGRpoint *)pnts[1], &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  }
 else
  {
   parm0 = 0; parm1 = 1;
   BSsfeval(surface, parm0, parm1, 0, (IGRpoint *)pnts[0], &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   parm0 = 1; parm1 = 1;
   BSsfeval(surface, parm0, parm1, 0, (IGRpoint *)pnts[1], &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  }

 if ((BSdistptpts(&msg, point, pnts[0]) <= bas_tol) ||
     (BSdistptpts(&msg, point, pnts[1]) <= bas_tol))
    *right_edge = edge1;
 else
    *right_edge = edge2;

 wrapup:
  EMWRAPUP (*EMmsg, stat_OM, "EMget_twin_edge"); 
  return(stat_OM);
} 
end implementation GRvg;
