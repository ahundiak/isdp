/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This method takes an open loop and merges it with this loop by owning
    it's edges and maintaining a proper ordering. The input loop is deleted.

  NOTES

    If the information on which ends to merge has been passed in (inloop_atend
    and thisloop_atend are non-NULL) then no checks are made to detect for
    sameness of endpoints. The indiacted ends are merged.

    On the other hand if these indicator-flags are NULL, then this method uses
    the tolerance passed in to detect the ends to merge.

    A check is made to see if the remaining endpoints are the same are not. If
    found so, the loop's property bits are updated to indicate the closed
    state.

    If the parametric-tolerance argument is non-NULL (tolerance has been
    passed in) it is used for zero-vector length. If a NULL is passed then
    the machine zero is used as the tolerance.

    Caution:
    The final direction of the merged loop is the direction of this loop.
    This means that the edges of the incoming loop might get REVERSED
    in order to merge.

  HISTORY

    SS  :  05/01/87  :  Creation
    SM  : 11-Nov-87  : Modified due to argument change
		       in 'EMmodify_edge'. The call to this method sets the
		       'update_range' flag to TRUE.
*/

class implementation EMSloop;

#include "EMS.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMmergeloop (IGRlong *msg; GRobjid inloop; 
                    IGRboolean *inloop_atend, *thisloop_atend;
                    struct EMSpartolbasis *partol_basis)
{
  IGRboolean closed, reverse;
  IGRushort lpprops;
  OMuint count;
  IGRint stat_OM, i, j, connect_option;
  IGRlong msg_loc;
  IGRdouble lentol, lentolsq;
  IGRdouble mystartpt[2], mystoppt[2], lpstartpt[2], lpstoppt[2];
  IGRdouble *myendpt, *lpendpt;
  OM_p_OBJECT_LINKAGE objlist;
  OM_S_CHANSELECT chan_to_edges;
  IGRboolean EFextract_par();
  IGRboolean update_range = TRUE;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  objlist = NULL;

  /*
   * If either of the two loops to be merged is closed, send back
   * an error message
   */

  if (! ME.EMSloop->lp_props & EMLP_OPEN)
    EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);
  
  stat_OM = om$send (msg = message EMSloop.EMget_props (&msg_loc, 
             &lpprops), targetid = inloop);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);

  if (! lpprops & EMLP_OPEN)
    EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);

  /*
   * Obtain the zero-length vector tolerance and also the
   * endpoints of the loops involved.
   */

  if (partol_basis)
    {
    if (!partol_basis->is_valid)
      {
      stat_OM = om$send (msg = message EMSboundary.EMgetsurface_info
                 (&msg_loc, NULL, partol_basis), targetid = my_id);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      partol_basis->is_valid = TRUE;
      }
    EFextract_par (BSTOLLENVEC, partol_basis->tol, &lentol, &msg_loc);
    }
  else
    lentol = 0.0;
  lentolsq = lentol * lentol;

  stat_OM = om$send (msg = message EMSloop.EMendpts (&msg_loc, mystartpt,
             mystoppt, NULL, NULL), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);

  stat_OM = om$send (msg = message EMSloop.EMendpts (&msg_loc, lpstartpt,
             lpstoppt, NULL, NULL), targetid = inloop);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);

  /*
   * If no information about which end of the loops to merge has been passed
   * in, generate that information by checking endpts.
   */

  if (!inloop_atend && !thisloop_atend)
    {
    if (EM2ddistptpts (mystartpt, lpstoppt) < lentolsq)
      {
      connect_option = EMS_INS_ATBEGIN;
      reverse = FALSE;
      if (EM2ddistptpts (mystoppt, lpstartpt) < lentolsq)
        closed = TRUE;
      else
        closed = FALSE;
      }
    else if (EM2ddistptpts (mystoppt, lpstartpt) < lentolsq)
      {
      connect_option = EMS_INS_ATEND;
      reverse = FALSE;
      if (EM2ddistptpts (mystartpt, lpstoppt) < lentolsq)
        closed = TRUE;
      else
        closed = FALSE;
      }
    else if (EM2ddistptpts (mystartpt, lpstartpt) < lentolsq)
      {
      connect_option = EMS_INS_ATBEGIN;
      reverse = TRUE;
      if (EM2ddistptpts (mystoppt, lpstoppt) < lentolsq)
        closed = TRUE;
      else
        closed = FALSE;
      }
    else if (EM2ddistptpts (mystoppt, lpstoppt) < lentolsq)
      {
      connect_option = EMS_INS_ATEND;
      reverse = TRUE;
      if (EM2ddistptpts (mystartpt, lpstartpt) < lentolsq)
        closed = TRUE;
      else
        closed = FALSE;
      }
    else
      EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);
    }

  else if (inloop_atend && thisloop_atend)
    {
    connect_option = (*thisloop_atend ? EMS_INS_ATEND : EMS_INS_ATBEGIN);
    reverse = (*thisloop_atend == *inloop_atend ? TRUE : FALSE);
    myendpt = (*thisloop_atend ? mystartpt : mystoppt);
    lpendpt = (*inloop_atend ? lpstartpt : lpstoppt);
    if (EM2ddistptpts (myendpt, lpendpt) < lentolsq)
      closed = TRUE;
    else
      closed = FALSE;
    }

  else
    EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);

  /*
   * If it has been determined that the incoming loop has to be reversed
   * in order to merge, a message is sent to it to do the same and it's
   * properties updated.
   */

  if (reverse)
    {
    stat_OM = om$send (msg = message EMSloop.EMreverse (&msg_loc),
               targetid = inloop);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_LoopError, ret_end);
    if (lpprops & EMLP_REVERSED)
      lpprops &= ~EMLP_REVERSED;
    else
      lpprops |= EMLP_REVERSED;
    }

  /*
   * Get the edges of the incoming loop
   */

  stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &chan_to_edges);
  EMomerr_exit (stat_OM, ret_end);
  
  stat_OM = om$get_channel_count (objid = inloop, 
             p_chanselect = &chan_to_edges, count = &count);
  EMomerr_exit (stat_OM, ret_end);
  
  objlist = (OM_p_OBJECT_LINKAGE) om$malloc (size = count * sizeof 
              (OM_S_OBJECT_LINKAGE));
  EMerr_hndlr (!objlist, *msg, EMS_E_NoDynamicMemory, ret_end);
  
  stat_OM = om$get_channel_objects (objid = inloop, p_chanselect = 
             &chan_to_edges, size = count, list = objlist, count = &count);
  EMomerr_exit (stat_OM, ret_end);
  
  /*
   * Determine in which direction should the list of edges be traversed
   * to correctly maintain the order on this loops edge-channel.
   */

  if ((connect_option == EMS_INS_ATBEGIN && !(lpprops & EMLP_REVERSED)) ||
      (connect_option == EMS_INS_ATEND && (lpprops & EMLP_REVERSED)))
    reverse = TRUE;
  else
    reverse = FALSE;

  /*
   * Make the connections on this loop. Also reset this loops open bit
   * if this loop is determined to be no longer open.
   */

  for (i=0, j=count-1; i<count; i++, j--)
    {
    stat_OM = om$send (msg = message EMSloop.EMmodify_edge (&msg_loc,
               connect_option, 1, NULL_OBJID, &objlist[reverse?j:i].S_objid, 
		update_range),
               targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_LoopError, ret_end);
    }
       
  if (closed)
    {
    stat_OM = om$send (msg = message EMSloop.EMset_props (&msg_loc,
               EMLP_OPEN, EMS_O_OFF), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
    }  
       
  /*
   * Delete the incoming loop.
   */

  stat_OM = om$send (msg = message Root.delete (TRUE), targetid = inloop);
  EMomerr_exit (stat_OM, ret_end);
       
ret_end:
  if (objlist)
    om$dealloc (ptr = objlist);
  EMWRAPUP (*msg, stat_OM, "EMSloop.EMmergeloop");
  return (stat_OM);
}

end implementation EMSloop;
