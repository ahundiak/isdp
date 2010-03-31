/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsdef.h"
#include "emsdattyp.h"
#include "emserr.h"
#include "EMSmsgdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMptinside (IGRlong *msg; IGRuint *callinx;
                   struct EMSpartolbasis *partolb;
                   IGRint numpts; IGRdouble *pts; IGRdouble *atleast_dist)
{
  IGRlong stat_OM, msg_loc;
  IGRdouble uvlentol;
  struct GRid mygrid;
  struct EMSdataselect mydata;
  extern IGRboolean EFextract_par();
  extern IGRlong EMptinsidelp();
  extern void EMgetareatol();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  if (! partolb->is_valid)
    {
    stat_OM = om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
               NULL, partolb), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
    partolb->is_valid = TRUE;
    }
  EFextract_par (BSTOLLENVEC, partolb->tol, &uvlentol, &msg_loc);

  mygrid.objid = my_id;
  mygrid.osnum = OM_Gw_current_OS;
  mydata.datatype = EMSdata_object;
  mydata.data.object = &mygrid;
 
  stat_OM = EMptsinsidelp (msg, &mydata, ME.EMSloop->range, numpts, pts,
             NULL, uvlentol, callinx, atleast_dist);
  if(*msg == EMS_E_OutOfBounds)
   {
    IGRdouble lparea = 0.0, areatol = 0.0;

    /* If the loop is degenerate, return the single point representing this
       loop and set the return code to EMS_I_Degenerate.
    */
    (void) EMgetareatol(&areatol, 
            ME.EMSloop->lp_props & EMLP_XYZ ? TRUE : FALSE);

    stat_OM = om$send(msg = message EMSloop.EMarea(msg, &lparea), 
              targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
    if(lparea > areatol)
     *msg = EMS_E_OutOfBounds;
    else
     {
      stat_OM = om$send(msg = message EMSloop.EMendpts(&msg_loc, pts, NULL, 
                NULL, NULL), targetid = my_id);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
      *msg = EMS_I_Degenerate;
     }
   }

ret_end:
  if (*msg != EMS_E_OutOfBounds)
    {EMWRAPUP (*msg, stat_OM, "EMSloop.EMptinside");}
  else
    stat_OM = OM_E_ABORT;
  return (stat_OM);
}

end implementation EMSloop;
