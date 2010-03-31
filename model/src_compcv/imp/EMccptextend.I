class implementation GRcompcurve;

#include "EMScc.h"
#include "msdef.h"
#include "godef.h"
#include "gr.h"
#include "ma.h"
#include "gocmacros.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsdistptpt.h"

method GRptextend(IGRlong *msg; struct GRmd_env *md_env; IGRpoint endpnt,
                  extpnt, new_endpnt)
/*
Abstract
   This method extends one end of a composite curve to a specified point.

Arguments

Return codes
   MSINARG      returned if 1) composite is closed.
                            2) user gives an extend point such that 
                               composite degenerates to a single element.
                            3) user gives an extend point such that a
                               component degenerates to a point.

   MSFAIL       returned for severe error.

   MSSUCC       returned for successful.

Notes

Files
   EMccptextend.I

History
   dhm   9/9/87   Creation date.
   dhm   12/21/87 converted to 1.1
   dhm   01/21/88 Modified to disextend to an interior component.
   dhm   04/05/88 Added GR_NOTIFY_LISTENERS
   dhm   02/17/89 Added check for composite degenerating to a single
                  element and check for component becoming a degenerate
                  point.
  dhm   03/08/89  Fixed phyically closed check to be "and'ed"
                  with the me->comp_props.
  Sudha 06/21/93  modified for BSprototype ansification

*/

{
  IGRlong    msg_loc, status;
  IGRpoint   prj_pt, endpoint, start_pnt, end_pnt;
  IGRdouble  tol, dist_start, dist_end;
  IGRint    count;
  OMuint     inx;
  IGRint     i;
  IGRchar    errmsg[EMMAXERRMSG_LEN];
  OM_S_CHANSELECT   composite_chan;
  struct     GRparms parms;
  IGRboolean sts, start1, end1;
  IGRchar    *geometry;
  GRobjid    new_id;
  struct     GRpost_info info;
  extern  IGRlong  EFclose_endpnt();

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(errmsg, "GRcompcurve.GRptextend\n");

  /*
   * If the composite curve is closed, then
   * no need to go any further
   */

  if (me->comp_props & GRIS_PHY_CLOSED)
  {
     *msg = MSINARG;
     goto ret_end;
  }

  /*
   * Initialize the channel selector
   */

  composite_chan.type = OM_e_addr;
  composite_chan.u_sel.addr = &ME.GRcmpowner->to_components;

  /*
   * Get the number of components on the composite channel
   */

  status = om$send(msg = message GRowner.GRget_number_components(&msg_loc,
                         &count),
                   targetid = my_id);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Set the flags indicating which end the
   * input endpnt is closes to.
   */

  start1 = FALSE;
  end1 = FALSE;

  status = om$send(msg = message GRcurve.GRendpts(&msg_loc,
                         &md_env->md_env.matrix_type,
                         md_env->md_env.matrix, start_pnt, end_pnt),
                   senderid = my_id,
                   targetid = my_id);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  dist_start = BSdistptpt(&msg_loc, endpnt, start_pnt);
  EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

  dist_end = BSdistptpt(&msg_loc, endpnt, end_pnt);
  EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

  if (dist_start <= dist_end)
     start1 = TRUE;
  else
     end1 = TRUE;

  /*
   * Project the extend point.  If the
   * extpnt and prj_pt are the same, then
   * get the index of the component it is
   * on.  If they're different, set inx to
   * either the start or end component.
   */

  status = om$send(msg = message GRgraphics.GRptproject(&msg_loc,
                        &md_env->md_env.matrix_type, md_env->md_env.matrix,
                        extpnt, prj_pt, &parms),
                   targetid = my_id);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  dist_end = BSdistptpt(&msg_loc, extpnt, prj_pt);
  EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

  sts = BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, tol);

  if (dist_end <= tol)
  {
      status = om$get_index(object_c = me,
                        p_chanselect = &composite_chan,
                        objid = parms.leaf_id.objid,
                        indexaddr = &inx);
      EMomerr_hndlr(status, ret_end, errmsg);
  }
  else
  {
     if (start1)
        inx = 0;
     else if (end1)
        inx = count - 1;
  }

  /*
   * Check to see if user is trying to extend from beginning to last
   * component or vise versa.  If so, return MSINARG since a composite
   * must have more than one element on it.  dhm  2/17/89.
   */

  if ( ( start1 && (inx == count - 1) ) ||
       ( end1 && (inx == 0) ) )
  {
    *msg = MSINARG;
    goto ret_end;
  }

  /*
   * Check to see if component that extend point falls on will cause a
   * degenerate point to be generated.  dhm  2/17/89.
   */

  status = om$send(msg = message GRcurve.GRendpts(&msg_loc,
                         &md_env->md_env.matrix_type,
                         md_env->md_env.matrix, start_pnt, end_pnt),
                   p_chanselect = &composite_chan,
                   from = inx,
                   to = inx);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  if (start1)
  {
     dist_end = BSdistptpt(&msg_loc, extpnt, end_pnt);
     EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

     if (dist_end <= tol)
     {
       *msg = MSINARG;
       goto ret_end;
     }
  }
  else if (end1)
  {
     dist_end = BSdistptpt(&msg_loc, extpnt, start_pnt);
     EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

     if (dist_end <= tol)
     {
       *msg = MSINARG;
       goto ret_end;
     }
  }

  /*
   * Delete components until the index of the extension point is
   * reached.
   */

  if (start1)
  {
     for (i = 0; i < inx; i++)
     {
         status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                                md_env),
                          p_chanselect = &composite_chan,
                          from = 0,
                          to = 0);
         EMomerr_hndlr(status, ret_end, errmsg);
         EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);
     }
     i = 0;
  }
  else if (end1)
  {
     for (i = (count-1); i > inx; i--)
     {
         status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                                md_env),
                          p_chanselect = &composite_chan,
                          from = i,
                          to = i);
         EMomerr_hndlr(status, ret_end, errmsg);
         EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);
     }
     i = inx;
  }

  /*
   * Send the GRptextend message to the component
   * to be extended giving it the correct endpoint to extend.
   */

  if (start1)
  {
     endpoint[0] = start_pnt[0];
     endpoint[1] = start_pnt[1];
     endpoint[2] = start_pnt[2];
  }
  else if (end1)
  {
     endpoint[0] = end_pnt[0];
     endpoint[1] = end_pnt[1];
     endpoint[2] = end_pnt[2];
  }

  status = om$send(msg = message GRcurve.GRptextend(&msg_loc, md_env,
                         endpoint, extpnt, new_endpnt),
                   senderid = my_id,
                   p_chanselect = &composite_chan,
                   from = i,
                   to = i);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Post the abstract geometry of the composite.
   */

  geometry = NULL;
  info.construct_flag = FALSE;
  status = om$send(msg = message GRvg.GRpostabsg(&msg_loc,
                         md_env, &info, geometry, &new_id),
                   senderid = my_id,
                   targetid = my_id);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);


  ret_end:

   GR_NOTIFY_LISTENERS(msg, &status, GR_GEOM_MODIFIED);

   return(status);

}

end implementation GRcompcurve;
