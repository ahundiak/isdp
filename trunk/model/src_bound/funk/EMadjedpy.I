/* ###################   APOGEE COMPILED   ################## */
/*
  NOTES

    It must be remembered that this function looks for the parametric length
    tolerance in the field 'geninfo' of the information structure passed in.
    This character pointer will first be type cast into a pointer to an
    IGRdouble and it's contents retrieved as the tolerance.

  HISTORY

    SS  :  Long ago  :  Creation
    SS  :  03/27/89  :  Started looking for the parametric tolerance
                        in the 'geninfo' field of the information
			structure. Immediately adjacent non-degenerate
                        spans are attempted for return.
*/

class implementation EMSedge;

#include "EMS.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#include "emsgeteddef.h"

from EMSloop import EMnext_edge;

IGRint EMadjedpy (adjpy_info)
struct EMSgetadjgeom *adjpy_info;
{
  IGRboolean reverse, nondeg_span_found;
  IGRushort adj_option;
  IGRint from_spaninx;
  IGRlong msg_loc, send_rc, stat_OM;
  GRobjid sender_edge, nextedid;
  struct IGRpolyline *poly;
  IGRboolean EFpts_degenerate();
  IGRlong EMsend_loops();

  adjpy_info->msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  adj_option = (adjpy_info->at_stop ? EMGetEd_Next : EMGetEd_Previous) |
		EMGetEd_NonDegenerate;
		
  sender_edge = adjpy_info->this_edge;
  stat_OM = EMsend_loops (&send_rc, message EMSloop.EMnext_edge
             (&msg_loc, adj_option, sender_edge, &nextedid),
             sender_edge, 0, 0, EMLP_ACTIVE, NULL, NULL);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (send_rc | msg_loc), adjpy_info->msg,
   EMS_E_LoopError, ret_end);
  if (msg_loc != EMS_I_OutOfBounds)
    {
    poly = adjpy_info->adjdata.data.poly;
    reverse = (adjpy_info->at_stop ? FALSE : TRUE);
    nondeg_span_found = FALSE;
    from_spaninx = 0;

    while (!nondeg_span_found)
      {
      stat_OM = om$send (msg = message EMSedge.EMgetpygeom (&msg_loc, 
                 from_spaninx, 1, FALSE, NULL, poly, NULL, NULL),
                 targetid = nextedid, senderid = NULL_OBJID);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), adjpy_info->msg, EMS_E_EdgeError,
       ret_end);
      EMerr_hndlr (msg_loc == EMS_I_OutOfBounds, adjpy_info->msg, msg_loc,
       ret_end);

      if (!EFpts_degenerate (2, poly->points, NULL, 2, 
           *((IGRdouble *) adjpy_info->geninfo)))
        nondeg_span_found = TRUE;
      else
        from_spaninx++;
      }
    }
  else
    adjpy_info->msg = EMS_I_OutOfBounds;

ret_end:
  EMWRAPUP (adjpy_info->msg, stat_OM, "EMadjedpy");
  return (stat_OM);
}

end implementation EMSedge;
