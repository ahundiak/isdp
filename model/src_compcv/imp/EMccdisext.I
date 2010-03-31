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
#include "bsdefs.h"
#include "bsdistptpt.h"

method GRdisextend(IGRlong *msg; struct GRmd_env *md_env; IGRpoint endpnt;
                   IGRdouble *dist; IGRpoint new_endpnt)
/*
Abstract
   This method extends one end of a composite curve a specified distance.

Arguments

Notes

Files
   EMccdisext.I

History
   dhm   9/15/87   Creation date.
   dhm   12/21/87  converted to 1.1
   dhm   01/21/88  Modified to disextend to an interior component.
   dhm   04/05/88  Added GR_NOTIFY_LISTENERS
   dhm   03/08/89  Fixed phyically closed check to be "and'ed"
                   with the me->comp_props.
   Sudha   06/21/93        modified for BSprototype ansification

*/

{
  IGRlong    msg_loc, status;
  IGRdouble  tot_length, real_dist, dist_start, dist_end;
  IGRboolean start1, end1, stay_in_loop;
  IGRpoint   startpnt, endpt, endpoint;
  IGRint    count;
  IGRint     i, drop_case;
  IGRchar    errmsg[EMMAXERRMSG_LEN];
  OM_S_CHANSELECT composite_chan;
  IGRchar    *geometry;
  GRobjid    new_id;
  struct     GRpost_info info;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(errmsg, "GRcompcurve.GRdisextend\n");

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
   * Set the flags indicating which end of the
   * composite the input endpnt is closes to.
   */

  start1 = FALSE;
  end1 = FALSE;

  status = om$send(msg = message GRcurve.GRendpts(&msg_loc,
                         &md_env->md_env.matrix_type,
                         md_env->md_env.matrix, startpnt, endpt),
                   targetid = my_id);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  dist_start = BSdistptpt(&msg_loc, endpnt, startpnt);
  EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

  dist_end = BSdistptpt(&msg_loc, endpnt, endpt);
  EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

  if (dist_start <= dist_end)
     start1 = TRUE;
  else
     end1 = TRUE;

  /*
   * If the dist is positive, then just get the endpoint
   * and send the GRdisextend message to the object on 
   * the channel.  If dist is negative, then have to 
   * determine which component to disextend and by how
   * much.
   */

  real_dist = (*dist);

  if (real_dist >= 0 )  /* if dist positive */
  {
     if (start1)
     {
        endpoint[0] = startpnt[0];
        endpoint[1] = startpnt[1];
        endpoint[2] = startpnt[2];
        i = 0;
     }
     else if (end1)
     {
        endpoint[0] = endpt[0];
        endpoint[1] = endpt[1];
        endpoint[2] = endpt[2];
        i = count-1;
     }

  }  /* end if dist positive */

  else  /* dist is negative */
  {
     if (start1) i = 0;
     else if (end1) i = count-1;
     stay_in_loop = TRUE;

     do
     {
       status = om$send(msg = message GRcurve.GRtotlength(&msg_loc,
                              &md_env->md_env.matrix_type,
                              md_env->md_env.matrix, &tot_length),
                        p_chanselect = &composite_chan,
                        from = i,
                        to = i);
       EMomerr_hndlr(status, ret_end, errmsg);
       EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

       if ( tot_length < ABS(real_dist) )
       {
          status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                                 md_env),
                           p_chanselect = &composite_chan,
                           from = i,
                           to = i);
          EMomerr_hndlr(status, ret_end, errmsg);
          EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

          real_dist = ABS(real_dist) - tot_length;
          if (end1) i--;

          stay_in_loop = TRUE;
       }
       else
          stay_in_loop = FALSE;

     } while (stay_in_loop);

     status = om$send(msg = message GRcurve.GRendpts(&msg_loc,
                            &md_env->md_env.matrix_type,
                            md_env->md_env.matrix, startpnt, endpt),
                      p_chanselect = &composite_chan,
                      from = i,
                      to = i);
     EMomerr_hndlr(status, ret_end, errmsg);
     EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

     if (start1)
     {
        endpoint[0] = startpnt[0];
        endpoint[1] = startpnt[1];
        endpoint[2] = startpnt[2];
     }
     else if (end1)
     {
        endpoint[0] = endpt[0];
        endpoint[1] = endpt[1];
        endpoint[2] = endpt[2];
     }
  }  /* end dist negative */


  /*
   * Send the GRdisextend message to the component
   * to be extended
   */

  status = om$send(msg = message GRcurve.GRdisextend(&msg_loc, md_env,
                         endpoint, &real_dist, new_endpnt),
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
