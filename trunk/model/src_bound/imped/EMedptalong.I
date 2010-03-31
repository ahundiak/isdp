class implementation EMSedge;

/*
   History

         Sudha 06/04/93          modified to include BSprototype header files
*/

#include "bserr.h"
#include "bsparameters.h"
#include "bsptsdlcv.h"
#include "bsmdstptcv.h"
#include "bscvkttol2.h"
#include "bscveval.h"

#define ENDPT  0
#define TANVEC 1

method EMptalong (IGRlong *msg; IGRushort opts;
                  struct GRmdenv_info *mdenv_info;
                  IGRpoint refpt; IGRdouble dist; IGRboolean in_fwd_dir;
                  struct EMSpartedinfo *partinfo;
                  IGRpoint pt)
{
  IGRlong i, msg_loc, stat_OM;
  IGRdouble refpar, dirpar, dumdist, minpar, maxpar, partol, tol;
  IGRpoint dumpt, dirpt, dirvals[2];
  struct IGRbsp_curve edcv;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  edcv.poles = NULL;
  edcv.knots = NULL;
  edcv.weights = NULL;

  stat_OM = om$send (msg = message EMSedge.EMget_bcxyz_geom (&msg_loc,
             mdenv_info, NULL, NULL, 0, MAXINT, FALSE, partinfo, &edcv),
             targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError, ret_end);

  minpar = edcv.knots[edcv.order-1];
  maxpar = edcv.knots[edcv.num_poles];
  BScvkttol2 (edcv.order, edcv.knots, edcv.num_poles, edcv.poles,
   edcv.weights, &partol, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
  partol *= 10.0;

  BSmdstptcv (&edcv, refpt, &refpar, dumpt, &dumdist, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

  dirpar = refpar + (in_fwd_dir ? partol : -partol);
  if (dirpar > maxpar || dirpar < minpar)
    {
    BScveval (&edcv, dirpar > maxpar ? maxpar : minpar, 1, dirvals, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
    
    BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, tol);
    tol *= 10.0;
    for (i=X; i<=Z; i++)
      dirpt[i] = dirvals[ENDPT][i] + (dirpar > maxpar ? 1 : -1) * 
                                     tol * dirvals[TANVEC][i];
    }
  else
    {
    BScveval (&edcv, dirpar, 0, (IGRpoint *)dirpt, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
    }

  BSptsdlcv (&msg_loc, &edcv, &refpar, dirpt, &dist, pt);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

ret_end:
  if (edcv.poles)
    om$dealloc (ptr = edcv.poles);
  if (edcv.knots)
    om$dealloc (ptr = edcv.knots);
  if (edcv.rational && edcv.weights)
    om$dealloc (ptr = edcv.weights);

  EMWRAPUP (*msg, stat_OM, "EMSedge.EMptalong");
  return (stat_OM);
}

end implementation EMSedge;
