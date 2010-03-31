/* ###################   APOGEE COMPILED   ################## */
class implementation GRcompcurve;

#include "EMScc.h"
#include "OMminimum.h"
#include "msdef.h"
#include "godef.h"
#include "gr.h"
#include "ma.h"
#include "gocmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "bserr.h"
#include "bsparameters.h"

method GR3ptpartdel(IGRlong *msg; struct GRmd_env *env; IGRpoint point1,
                    point2, point3; struct GRparms *par1, *par2, *par3;
                    GRobjid *c1, *c2; IGRshort *num)
/*
Abstract
	This method does a partial delete from point1 to point3 in the
	direction of point2 on a composite curve.

Arguments

Notes

Files
	EMcc3ptpartd.I

History
	dhm		11/02/87		Creation date.
	dhm		12/21/87		converted to 1.1
    dhm     02/16/88        changed to delete whole composite if requested.
    dhm     04/05/88        added GR_NOTIFY_LISTENERS
    dhm     08/05/88        added GRidchanged.
    dhm     03/08/89        Fixed phyically closed check to be "and'ed"
                            with the me->comp_props.
*/

{
 extern  IGRlong  EFclose_endpnt();
  IGRlong		msg_loc, status;
  IGRshort		num_ret;
  IGRboolean	start1, start2, end1, end2, id_changed;
  IGRint                i;
  OMuint		ind1, ind2;
  IGRchar		errmsg[EMMAXERRMSG_LEN];
  GRobjid		cv1, cv2, cv3, crv, cc;
  IGRpoint		pnt1, pnt3, proj_pnt;
  struct GRparms	p1, p3, pr1, pr2, pr3;
  OM_S_CHANSELECT	composite_chan;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(errmsg,"GRcompcurve.GR3ptpartdel\n");
  *num = 0;
  *c1 = NULL_OBJID;
  *c2 = NULL_OBJID;
  cv1 = NULL;
  cv2 = NULL;
  cv3 = NULL;
  crv = NULL;
  cc = NULL;
  id_changed = TRUE;

  /*
   * Initialize the channel selector
   */

  status = EMmake_chanselect (GRcmpowner_to_components, &composite_chan);
  EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);

  /*
   * Get the index of the object on which
   * point1 and point3 lie.
   */

  status = om$get_index(object_c = me,
                        p_chanselect = &composite_chan,
                        objid = par1->leaf_id.objid,
                        indexaddr = &ind1);
  EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);

  status = om$get_index(object_c = me,
                        p_chanselect = &composite_chan,
                        objid = par3->leaf_id.objid,
                        indexaddr = &ind2);
  EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);

  /*
   * Copy myself in case something goes wrong then I'm still intact.
   * Also, get the object id's of copied curves at ind1 and ind2.
   */

  status = om$send(msg = message GRgraphics.GRcopy(&msg_loc,
                         env, env, &cc),
                   targetid = my_id);
  EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  status = om$get_objid_at_index(osnum = env->md_id.osnum,
                                 objid = cc,
                                 p_chanselect = &composite_chan,
                                 index = ind1,
                                 objidaddr = &par1->leaf_id.objid,
                                 osnumaddr = &par1->leaf_id.osnum);
  EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);

  status = om$get_objid_at_index(osnum = env->md_id.osnum,
                                 objid = cc,
                                 p_chanselect = &composite_chan,
                                 index = ind2,
                                 objidaddr = &par3->leaf_id.objid,
                                 osnumaddr = &par3->leaf_id.osnum);
  EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);

  /*
   * Get the parameters of the points on the composite curve.
   */

  status = om$send(msg = message GRvg.EMpratpt(&msg_loc,
                         &env->md_env.matrix_type, env->md_env.matrix,
                         point1, &pr1.u, &i),
                   senderid = my_id,
                   targetid = cc);
  EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  status = om$send(msg = message GRvg.EMpratpt(&msg_loc,
                         &env->md_env.matrix_type, env->md_env.matrix,
                         point2, &pr2.u, &i),
                   senderid = my_id,
                   targetid = cc);
  EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  status = om$send(msg = message GRvg.EMpratpt(&msg_loc,
                         &env->md_env.matrix_type, env->md_env.matrix,
                         point3, &pr3.u, &i),
                   senderid = my_id,
                   targetid = cc);
  EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * If the composite is open and the direction point is between
   * point1 and point3, then call GR2ptpartdel.  If the direction
   * point isn't between point1 and point3, then it is an error. 
   */

  if ( !(me->comp_props & GRIS_PHY_CLOSED) )  /* open curve */
  {
     if (((pr1.u <= pr2.u) && (pr2.u <= pr3.u)) ||
         ((pr1.u >= pr2.u) && (pr2.u >= pr3.u)))
     {
        status = om$send(msg = message GRcurve.GR2ptpartdel(&msg_loc,
                               env, point1, point3, par1, par3, c1, c2,
                               num),
                         senderid = my_id,
                         targetid = cc);
        EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
        EMerr_hndlr(EMis_error(msg_loc), *msg, msg_loc, ret_end);

        cc = NULL;
        goto ret_end;
     }
     else
     {
        *msg = MSINARG;
        goto ret_end;
     }
  }

  /*
   * Order the parameters and points in ascending order.
   */

  if (pr1.u <= pr3.u)
  {
     p1.u = par1->u;
     p1.leaf_id.objid = par1->leaf_id.objid;
     p1.leaf_id.osnum = par1->leaf_id.osnum;
     p3.u = par3->u;
     p3.leaf_id.objid = par3->leaf_id.objid;
     p3.leaf_id.osnum = par3->leaf_id.osnum;
     pnt1[0] = point1[0];
     pnt1[1] = point1[1];
     pnt1[2] = point1[2];
     pnt3[0] = point3[0];
     pnt3[1] = point3[1];
     pnt3[2] = point3[2];
  }
  else
  {
     p1.u = par3->u;
     p1.leaf_id.objid = par3->leaf_id.objid;
     p1.leaf_id.osnum = par3->leaf_id.osnum;
     p3.u = par1->u;
     p3.leaf_id.objid = par1->leaf_id.objid;
     p3.leaf_id.osnum = par1->leaf_id.osnum;
     pnt1[0] = point3[0];
     pnt1[1] = point3[1];
     pnt1[2] = point3[2];
     pnt3[0] = point1[0];
     pnt3[1] = point1[1];
     pnt3[2] = point1[2];
     i = ind1;
     ind1 = ind2;
     ind2 = i;
  }

  /*
   * Check to see if pnt1 is on the start point of the composite; and if
   * pnt3 is on the end point of the composite.
   */

  status = EFclose_endpnt(&msg_loc, my_id, env, cc, pnt1, &start1,
                          &end1);
  EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  status = EFclose_endpnt(&msg_loc, my_id, env, cc, pnt3, &start2,
                          &end2);
  EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Delete the whole curve if they gave the endpoints as points to
   * delete from and to.  Must delete the copy first.  Deletion of the
   * composite is done in the end.
   */

  if (start1 && end2)
  {
     status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                            env),
                      senderid = my_id,
                      targetid = cc);
     EMomerr_hndlr_action(status, ;, errmsg);
     EMerr_hndlr_action(EMis_error(msg_loc), *msg, MSFAIL, ;);

     cc = NULL;
     id_changed = FALSE;
     goto ret_end;
  }

  /*
   * Split the composite at the first point.
   */

  if (!start1)  /* pnt1 isn't at the start of the composite */
  {
     status = om$send(msg = message GRcurve.GRsplit(&msg_loc,
                            env, pnt1, &p1, &cv1, &cv2, &num_ret),
                      senderid = my_id,
                      targetid = cc,
                      targetos = env->md_id.osnum);
     EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
     EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

     crv = cv2;
     cc = NULL;  /* it's deleted */

  }  /* end if !start1 */
  else if (start1)  /* pnt1 is on the start of the composite */
  {
     /*
      * Split the composite at pnt3 and go directly to the deletion
      * section.
      */

     status = om$send(msg = message GRcurve.GRsplit(&msg_loc,
                            env, pnt3, &p3, &cv1, &cv2, &num_ret),
                      senderid = my_id,
                      targetid = cc,
                      targetos = env->md_id.osnum);
     EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
     EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

     cc = NULL;  /* it's deleted */
     goto ret_curves;

  }  /* end if start1 */

  /*
   * The split operation changed the objid and parameter value of pnt2.
   * Therefore, I need to project the second point onto the new curve to
   * split to get the new parameter value.
   */

  status = om$send(msg = message GRgraphics.GRptproject(&msg_loc,
                         &env->md_env.matrix_type, env->md_env.matrix,
                         pnt3, proj_pnt, &p3),
                   senderid = my_id,
                   targetid = crv,
                   targetos = env->md_id.osnum);
  EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Split the curve at the last point.
   */

  if (!end2)  /* pnt3 isn't on the end point of the composite */
  {
     status = om$send(msg = message GRcurve.GRsplit(&msg_loc,
                            env, pnt3, &p3, &cv2, &cv3, &num_ret),
                      senderid = my_id,
                      targetid = crv,
                      targetos = env->md_id.osnum);
     EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
     EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

     crv = NULL;  /* deleted */
  }
  else
     crv = NULL;

  /*
   * Delete the requested part and return the other portions of
   * the curve.
   */

 ret_curves:
  /*
   * If point2 lies between point1 and point3, then delete middle curve
   * and return outside curve.
   */

  if ( ( (pr1.u <= pr2.u) && (pr2.u <= pr3.u) ) ||
       ( (pr1.u >= pr2.u) && (pr2.u >= pr3.u) ) )
  {
     if (start1)
     {
        status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                               env),
                         senderid = my_id,
                         targetid = cv1);
        EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
        EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

        cv1 = NULL;  /* deleted */
        *c1 = cv2;
        *num = 1;
     }
     else if (end2)
     {
        status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                               env),
                         senderid = my_id,
                         targetid = cv2);
        EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
        EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

        cv2 = NULL;  /* deleted */
        *c1 = cv1;
        *num = 1;
     }
     else
     {
        status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                               env),
                         senderid = my_id,
                         targetid = cv2);
        EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
        EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

        cv2 = NULL;  /* deleted */
        *c1 = cv1;
        *c2 = cv3;
        *num = 2;
     }
  }
  else  /* point2 is outside of point1 and point3 */
  {
     if (start1)
     {
        status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                               env),
                         senderid = my_id,
                         targetid = cv2);
        EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
        EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

        cv2 = NULL;  /* deleted */
        *c1 = cv1;
        *num = 1;
     }
     else if (end2)
     {
        status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                               env),
                         senderid = my_id,
                         targetid = cv1);
        EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
        EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

        cv1 = NULL;  /* deleted */
        *c1 = cv2;
        *num = 1;
     }
     else
     {
        status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                               env),
                         senderid = my_id,
                         targetid = cv1);
        EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
        EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

        cv1 = NULL;  /* deleted */

        status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                               env),
                         senderid = my_id,
                         targetid = cv3);
        EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
        EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

        cv3 = NULL;  /* deleted */

        *c1 = cv2;
        *num = 1;
     }
  }


  ret_end:
	if (*msg != MSSUCC)
    {
       if (cv1)
       {
          status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                                 env),
                           senderid = my_id,
                           targetid = cv1);
          EMomerr_hndlr_action(status, ;, errmsg);
          EMerr_hndlr_action(EMis_error(msg_loc), *msg, MSFAIL, ;);

          cv1 = NULL;
       }

       if (cv2)
       {
          status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                                 env),
                           senderid = my_id,
                           targetid = cv2);
          EMomerr_hndlr_action(status, ;, errmsg);
          EMerr_hndlr_action(EMis_error(msg_loc), *msg, MSFAIL, ;);

          cv2 = NULL;
       }

       if (cv3)
       {
          status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                                 env),
                           senderid = my_id,
                           targetid = cv3);
          EMomerr_hndlr_action(status, ;, errmsg);
          EMerr_hndlr_action(EMis_error(msg_loc), *msg, MSFAIL, ;);

          cv3 = NULL;
       }

       if (crv)
       {
          status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                                 env),
                           senderid = my_id,
                           targetid = crv);
          EMomerr_hndlr_action(status, ;, errmsg);
          EMerr_hndlr_action(EMis_error(msg_loc), *msg, MSFAIL, ;);

          crv = NULL;
       }

       if (cc)
       {
          status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                                 env),
                           senderid = my_id,
                           targetid = cc);
          EMomerr_hndlr_action(status, ;, errmsg);
          EMerr_hndlr_action(EMis_error(msg_loc), *msg, MSFAIL, ;);

          cc = NULL;
       }

       *num = 0;  /* on error, return no curves */
    }
    else  /* msg is equal to a MSSUCC */
	{
      /*
       * Send the owners a GRidchanged message so can process new id's
       * if the id's changed.
       */

      if (id_changed)
      {
        struct GRid   newids[2];

        newids[0].osnum = OM_Gw_current_OS;
        newids[0].objid = *c1;
        newids[1].osnum = OM_Gw_current_OS;
        newids[1].objid = *c2;
        status = om$send(msg = message GRgraphics.GRidchanged(&msg_loc, 
                               num, newids),
                         targetid = my_id);
        EMomerr_hndlr_action(status, ;, errmsg);
        EMerr_hndlr_action(EMis_error(msg_loc), *msg, MSFAIL, ;);
      }

      /*
       * Delete the original composite curve.
       */


       status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                              env),
                        senderid = my_id,
                        targetid = my_id);
       EMomerr_hndlr_action(status, ;, errmsg);
       EMerr_hndlr_action(EMis_error(msg_loc), *msg, MSFAIL, ;);
	}

    GR_NOTIFY_LISTENERS(msg, &status, GR_CLIPPED);

	return(status);

}

end implementation GRcompcurve;
