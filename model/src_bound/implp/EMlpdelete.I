/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

#include "EMS.h"
# include "EMSlogic.h"      /* EMSmsgReport */
# include "EMStypedef.h"    /* EMSmsgReport */
# include "EMScmacros.h"    /* EMSmsgReport */
# include <stdio.h>

from GRlistener import GRnotifylis;

method delete(int defer_flag)

/*
Description
   This method will attempt to delete its loop object and all object
   that depend on it (inner loops and edges).
   
Return values
   
History
   RC           x/x/87   Creation
   DLB          4/8/87   Added check for assoc.
   AIC         15-Jul-87 Notify the associations. 
                         (Also changed error handler.)
   RC          11/04/87  Modified for version 1.1.0
   SM	       03-Mar-89 Problem - Loop has a partedge.
				   Partedge owns a full edge.
				   Full edge is also a part of the loop.
				   Message goes to full edge (2 owners).
				   Full edge does not delete.
				   Partedge tries to delete full edge when
				   it is still owned by the loop.
				   Full edge does not delete.
				   Loop deletes.
				   Full edge hanging in space.
				   got it?
			Solution - After sending delete once to the edges, 
				   send it once again. By this time partedges
				   are dead and full edge is in exclusive 
				   bondage of the loop. So it will delete.
   SS         04/25/89	     Before deleting myself, send the EMpostdelete
                             message to myself (if this has not been
                             inhibited by some higher level procedure).
   WBC        01/04/94  Making sure EMrestore_postproc gets called if
                        necessary, even when EMSboundary.EMpostdelete fails
                        (TR#119313321).
*/

{
  IGRlong               OM_stat;
  OM_S_CHANSELECT       to_outter;
  OMuint                outter_count;
  IGRboolean            delete_myself = TRUE, notify = FALSE;
  
  OM_stat = OM_S_SUCCESS;
  EMmake_chanselect (EMSloop_to_outter, &to_outter);

  OM_stat = om$get_channel_count(object = me,
             p_chanselect = &to_outter, count = &outter_count);
  if(! (1 & OM_stat)) goto wrapup;

  /*
   * If I have an owner and he didn't send this msg 
   * then don't delete
   */

  if (outter_count)
  {
    OM_stat = om$is_objid_on_channel(object_c = me,
              p_chanselect = &to_outter, objid = sender_id);

    if (OM_stat == OM_W_NOTONCHAN)
    {
      delete_myself = FALSE;
      OM_stat = OM_S_SUCCESS;
    }
  
  } /* if (outter_count) */

  if (delete_myself)
  {
     OM_S_CHANSELECT      to_inner, to_edges, to_notification;
     IGRlong              mthd_stat;
     IGRlong              mask;
     
     mthd_stat = EMS_S_Success;
     to_inner.type = to_edges.type = to_notification.type = OM_e_addr;
     to_inner.u_sel.addr = &ME.EMSloop->to_inner;
     to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;
     to_notification.u_sel.addr = &ME.GRnotify->notification;
     EMmake_chanselect (EMSloop_to_inner, &to_inner);
     EMmake_chanselect (GRnotify_notification, &to_notification);

     /*
      * Delete my inner regions.
      */
     
     OM_stat = om$send(msg = message Root.delete(defer_flag),
                       p_chanselect =&to_inner);
     if(! (1 & OM_stat)) goto wrapup;

    /*
     * Delete my edges.
     */
  
    OM_stat = om$send(msg = message Root.delete(defer_flag),
                p_chanselect =&to_edges);
    if(! (1 & OM_stat)) goto wrapup;

    /* Intentionally send the message again. (See comments in change history).
     *  -- SM 03-Mar-89.
    */
    OM_stat = om$send(msg = message Root.delete(defer_flag),
                p_chanselect =&to_edges);
    if(! (1 & OM_stat)) goto wrapup;

    /*
     * I am deleteing so tell my associated objects. THIS MUST BE PLACED
     * IN THE POSTPROCESSING METHOD INVOCATION BELOW. 
     */

    mask = GR_DELETED;
    om$send (msg = message GRlistener.GRnotifylis(&mthd_stat,
     &OM_stat, &mask, OPPmargs), p_chanselect = &to_notification);

    /*
     * Delete my helpers
     */
    {
      OM_S_CHANSELECT   to_helpers;

      OM_stat = EMmake_chanselect (EMSrequester_to_helpers, &to_helpers);
      if(! (1 & OM_stat)) goto wrapup;

      OM_stat = om$send(msg = message Root.delete(1),
                        p_chanselect = &to_helpers);
      if(! (1 & OM_stat)) goto wrapup;
    }

    /*
     * Delete myself.
     */

    if (notify = EMcheck_inhibit_postproc())
      {
      OM_stat = om$send (msg = message EMSboundary.EMpostdelete (&mthd_stat,
                 NULL, NULL), targetid = my_id);
      EMerr_hndlr (EMSerror (OM_stat & mthd_stat), OM_stat, OM_E_ABORT, 
       wrapup);
      }

    OM_stat = om$send(mode = OM_e_wrt_message, 
                msg = message Root.delete(defer_flag), targetid = my_id);

    if (notify)
    {
      EMrestore_postproc();
      notify = FALSE;
    }

    if(! (1 & OM_stat)) goto wrapup;

  } /* if (delete_myself) */

wrapup:

  if (notify)
    EMrestore_postproc();

  EMSmsgReport(OM_stat, "EMSloop.delete", FALSE);

  return(OM_stat);
}

end implementation EMSloop;
