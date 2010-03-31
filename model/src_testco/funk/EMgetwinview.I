/*
  DESCRIPTION

    Given an event structure, this function returns the window id (if one
    present on the button), the view matrix corresponding to the window
    (if not on this event, then on the previous event, if not on the previous
    event, the view matrix of the top view). It also returns the vectors
    that correspond to the view X-axis, Y-axis and Z-axis. Any of the 5
    output arguments can be NULL.

  HISTORY

    SS  :  04/27/90  :  Creation. View matrix code stolen from EFboreline.
 Sudha  :  07/02/93  :  Modified for BSprototypes ansification

*/

class implementation Root;

#include "EMS.h"

%safe
#include <math.h>
%endsafe

#include "ems_m_inc.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "maidmx.h"
#include "bsnorvec.h"

from IGEgragad import DPinrot;

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

void EMgetwinview (msg, event, wingrid, viewmat, xvec, yvec, zvec)
IGRlong *msg;
struct GRevent *event;         
struct GRid *wingrid;
IGRdouble *viewmat, *xvec, *yvec, *zvec;
{
  IGRboolean stat;
  IGRint size, dum;
  IGRlong msg_loc, stat_OM;
  IGRmatrix viewmat_loc;
  struct GRid wingrid_loc;
  struct EX_button button;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain the window id
   */

  stat_OM = om$is_objid_valid (objid = event->event.button.objid,
             osnum = event->event.button.osnum);
  if (stat_OM == OM_S_SUCCESS)
    {
    wingrid_loc.objid = event->event.button.objid;
    wingrid_loc.osnum = event->event.button.osnum;
    }
  else
    {
    wingrid_loc.objid = NULL_OBJID;
    stat_OM = OM_S_SUCCESS;
    }

  if (wingrid)
    *wingrid = wingrid_loc;

  if (viewmat || xvec || yvec || zvec)
    {
    /* 
     * Get the view matrix.
     */

    stat_OM = om$send (msg = message IGEgragad.DPinrot (&msg_loc, viewmat_loc),
               targetid = wingrid_loc.objid, targetos = wingrid_loc.osnum,
               senderid = NULL_OBJID);
    if (EMSerror (msg_loc & stat_OM))
      {
      /*
       * If this failed it is probably because the point
       * in the event did not have an associated view.
       * In this case, try and use the last point input
       * to get the view matrix.
       */

      size = sizeof (struct EX_button);
      gr$get_last_point (msg = &msg_loc, sizbuf = &size, buffer = &button,
       nret = &dum);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      stat_OM = om$send (msg = message IGEgragad.DPinrot (&msg_loc,
                 viewmat_loc), targetid = button.objid,
                 targetos = button.osnum, senderid = NULL_OBJID);
      if (EMSerror (msg_loc & stat_OM))
        {
        /*
         * If this point did not have a view matrix
         * just use the top view.
         */

        MAidmx (&msg_loc, viewmat_loc);
        stat_OM = OM_S_SUCCESS;
        }
      }
   
    if (viewmat)
      OM_BLOCK_MOVE (viewmat_loc, viewmat, sizeof (IGRmatrix));
    if (xvec)
      {
      OM_BLOCK_MOVE (&viewmat_loc[0], xvec, sizeof (IGRvector));;
      stat = BSnorvec (&msg_loc, xvec);
      EMerr_hndlr (!stat, *msg, EMS_E_Fail, ret_end);
      }
    if (yvec)
      {
      OM_BLOCK_MOVE (&viewmat_loc[4], yvec, sizeof (IGRvector));;
      stat = BSnorvec (&msg_loc, yvec);
      EMerr_hndlr (!stat, *msg, EMS_E_Fail, ret_end);
      }
    if (zvec)
      {
      OM_BLOCK_MOVE (&viewmat_loc[8], zvec, sizeof (IGRvector));;
      stat = BSnorvec (&msg_loc, zvec);
      EMerr_hndlr (!stat, *msg, EMS_E_Fail, ret_end);
      }
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMgetwinview");
  return;
}

end implementation Root;

