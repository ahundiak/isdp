/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#include "bserr.h"
#include "bsparameters.h"
#include "EMSbstrim.h"
#include "emsgeteddef.h"
#include "bscvkttol2.h"

from EMSloop import EMnext_edge;

IGRint EMadjbs (adjbs_info)
struct EMSgetadjgeom *adjbs_info;

{
/* *****************************************************************
   
   This function gets the next span geometry for use in trimming. It is
   expected that the memory for the next span is already allocated in the
   field adjdata of the structure EMSgetadjgeom. The amount of memory that
   needs to be allocated is equivalent to storing a bezier span of order 16.

   On exit the completion code will be one of the following:
      EMS_S_Success : if all goes well
      EMS_E_BSerror : if there is a math error

   History:
       PP : 08/22/87    Creation
       SM : 02-Dec-87   option changes to EMnext_edge.
       PP : 05/08/88    Support for case when there is no next edge
       Sudha 7/08/93    Modified for BSprototypes ansification

   ***************************************************************** */


  IGRlong msg_loc, send_rc, stat_OM;
  IGRlong rc;
  IGRboolean found_span = FALSE;
  IGRdouble next_knottol;

  GRobjid sender_edge, nextedid;

  struct IGRbsp_curve next_edge;
  struct IGRbsp_curve *next_span;

  void getnextnondegeneratespan ();
  IGRlong EMsend_loops();

  adjbs_info->msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  next_edge.poles = NULL;
  next_edge.weights = NULL;
  next_edge.knots = NULL;
  next_edge.bdrys = NULL;

  sender_edge = adjbs_info->this_edge;
  next_span = adjbs_info->adjdata.data.curve;

  stat_OM = EMsend_loops (&send_rc, message EMSloop.EMnext_edge
            (&msg_loc, EMGetEd_Next | EMGetEd_NonDegenerate, 
	     sender_edge, &nextedid),
             sender_edge, 0, 0, EMLP_ACTIVE, NULL, NULL);
  EMerr_hndlr (EMSerror (send_rc | msg_loc), adjbs_info->msg,
    EMS_E_LoopError, ret_end);
  EMomerr_exit (stat_OM, ret_end);

  if (msg_loc != EMS_I_OutOfBounds)
  {
   stat_OM = om$send (msg = message EMSedge.EMgetbcgeom (&msg_loc, 
               0, 1, FALSE, NULL, &next_edge, NULL, NULL), targetid = nextedid,
               senderid = NULL_OBJID);
   EMomerr_exit (stat_OM, ret_end);
   EMerr_hndlr (EMis_error (msg_loc), adjbs_info->msg, EMS_E_EdgeError,
      ret_end);

   if (next_edge.rational)
   {
    BScvkttol2 (next_edge.order, next_edge.knots, next_edge.num_poles,
                next_edge.poles, next_edge.weights, &next_knottol, &rc);
    EMerr_hndlr (BSERROR (rc), adjbs_info->msg, EMS_E_BSerror, ret_end);
   }
   else
   {
    BScvkttol2 (next_edge.order, next_edge.knots, next_edge.num_poles,
                next_edge.poles, NULL, &next_knottol, &rc);
    EMerr_hndlr (BSERROR (rc), adjbs_info->msg, EMS_E_BSerror, ret_end);
   }

   getnextnondegeneratespan(&msg_loc, -1, &next_edge, next_knottol,
                            &found_span, next_span);
   EMerr_hndlr (EMis_error (msg_loc), adjbs_info->msg, msg_loc, ret_end);
  }

   if (!found_span)
    adjbs_info->msg = EMS_I_OutOfBounds;

ret_end :

  if (next_edge.poles) free (next_edge.poles);
  if (next_edge.knots) free (next_edge.knots);
  if (next_edge.weights) free (next_edge.weights);

  EMWRAPUP (adjbs_info->msg, stat_OM, "EMadjbs");
  return (stat_OM);
}

end implementation EMSedge;
