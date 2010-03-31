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

method GR2ptpartdel(IGRlong *msg; struct GRmd_env *env; IGRpoint point1,
                    point2; struct GRparms *par1, *par2; GRobjid *c1,*c2; 
                    IGRshort *num)
/*
Abstract
	This method does a partial delete from point1 to point2 on a composite
	curve.

Arguments

Notes

Files
	EMcc2ptpartd.I

History
	dhm		10/28/87		Creation date.
	dhm		12/21/87		converted to 1.1
    dhm     02/16/88        changed to delete whole curve is requested.
    dhm     04/05/88        added GR_NOTIFY_LISTENERS
    dhm     08/05/88        added GRidchanged.
*/

{
 extern  IGRlong  EFclose_endpnt();
  IGRlong		msg_loc, status;
  IGRshort		num_ret;
  IGRboolean	start1, start2, end1, end2, id_changed;
  IGRint                i;
  OMuint		ind1, ind2;
  IGRchar		errmsg[EMMAXERRMSG_LEN];
  GRobjid		cv1, cv2, crv, cc;
  IGRpoint		pnt1, pnt2, proj_pnt;
  OMuword		classid;
  struct GRparms	p1, p2;
  OM_S_CHANSELECT	composite_chan;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(errmsg,"GRcompcurve.GR2ptpartdel\n");
  *num = 0;
  *c1 = NULL_OBJID;
  *c2 = NULL_OBJID;
  cv1 = NULL;
  cv2 = NULL;
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
   * point1 and point2 lie.
   */

  status = om$get_index(object_c = me,
                        p_chanselect = &composite_chan,
                        objid = par1->leaf_id.objid,
                        indexaddr = &ind1);
  EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);

  status = om$get_index(object_c = me,
                        p_chanselect = &composite_chan,
                        objid = par2->leaf_id.objid,
                        indexaddr = &ind2);
  EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);

  /*
   * Order the parameters and points in ascending order.
   */

  if ((ind1 < ind2) || ((ind1 == ind2) && (par1->u < par2->u)))
  {
     p1.u = par1->u;
     p1.leaf_id.objid = par1->leaf_id.objid;
     p1.leaf_id.osnum = par1->leaf_id.osnum;
     p2.u = par2->u;
     p2.leaf_id.objid = par2->leaf_id.objid;
     p2.leaf_id.osnum = par2->leaf_id.osnum;
     pnt1[0] = point1[0];
     pnt1[1] = point1[1];
     pnt1[2] = point1[2];
     pnt2[0] = point2[0];
     pnt2[1] = point2[1];
     pnt2[2] = point2[2];
  }
  else
  {
     p1.u = par2->u;
     p1.leaf_id.objid = par2->leaf_id.objid;
     p1.leaf_id.osnum = par2->leaf_id.osnum;
     p2.u = par1->u;
     p2.leaf_id.objid = par1->leaf_id.objid;
     p2.leaf_id.osnum = par1->leaf_id.osnum;
     pnt1[0] = point2[0];
     pnt1[1] = point2[1];
     pnt1[2] = point2[2];
     pnt2[0] = point1[0];
     pnt2[1] = point1[1];
     pnt2[2] = point1[2];
     i = ind1;
     ind1 = ind2;
     ind2 = i;
  }

  /*
   * Check to see if pnt1 is on the start point of the composite; and if
   * pnt2 is on the end point of the composite.
   */

  status = EFclose_endpnt(&msg_loc, my_id, env, my_id, pnt1, &start1,
                          &end1);
  EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  status = EFclose_endpnt(&msg_loc, my_id, env, my_id, pnt2, &start2,
                          &end2);
  EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Delete the whole curve if they gave the endpoints as points to
   * delete from and to.  Deletion is done in the end.
   */

  if (start1 && end2)
  {
    id_changed = FALSE;
    goto ret_end;
  }

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
                                 objidaddr = &p1.leaf_id.objid,
                                 osnumaddr = &p1.leaf_id.osnum);
  EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);

  status = om$get_objid_at_index(osnum = env->md_id.osnum,
                                 objid = cc,
                                 p_chanselect = &composite_chan,
                                 index = ind2,
                                 objidaddr = &p2.leaf_id.objid,
                                 osnumaddr = &p2.leaf_id.osnum);
  EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);

  /*
   * Split the composite at pnt1 and pnt2.  Delete part between pnt1 and
   * pnt2 and return remaining portions.
   */

  if (!start1)  /* pnt1 isn't at the start of the composite */
  {
     /*
      * Split the composite at pnt1 and return cv1 as 1st portion.
      */

     status = om$send(msg = message GRcurve.GRsplit(&msg_loc,
                            env, pnt1, &p1, &cv1, &cv2, &num_ret),
                      senderid = my_id,
                      targetid = cc,
                      targetos = env->md_id.osnum);
     EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
     EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

     *c1 = cv1;
     (*num)++;
     crv = cv2;
     cc = NULL;  /* it's deleted */

  }  /* end if !start1 */
  else if (start1)  /* pnt1 is on the start of the composite */
  {
     /*
      * Split the composite at pnt2 and return cv2 as the only portion.
      * Delete cv1 since it is the part between pnt1 and pnt2.
      */

     status = om$send(msg = message GRcurve.GRsplit(&msg_loc,
                            env, pnt2, &p2, &cv1, &cv2, &num_ret),
                      senderid = my_id,
                      targetid = cc,
                      targetos = env->md_id.osnum);
     EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
     EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

     *c1 = cv2;
     (*num)++;
     cc = NULL;  /* it's deleted */

     status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                            env),
                      senderid = my_id,
                      targetid = cv1);
     EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
     EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

     cv1 = NULL;  /* deleted */
     goto ret_end;

  }  /* end if start1 */

  /*
   * The split operation changed the objid and parameter value of pnt2.
   * Therefore, I need to project the second point onto the new curve to
   * split to get the new parameter value.
   */

  status = om$send(msg = message GRgraphics.GRptproject(&msg_loc,
                         &env->md_env.matrix_type, env->md_env.matrix,
                         pnt2, proj_pnt, &p2),
                   senderid = my_id,
                   targetid = crv,
                   targetos = env->md_id.osnum);
  EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Split the curve at the last point.
   */

  if (!end2)  /* pnt2 isn't on the end point of the composite */
  {
     /*
      * Split the composite at pnt2 and return cv2 as the 2nd portion.
      * Delete cv1 since it is the part between pnt1 and pnt2.
      */

     status = om$send(msg = message GRcurve.GRsplit(&msg_loc,
                            env, pnt2, &p2, &cv1, &cv2, &num_ret),
                      senderid = my_id,
                      targetid = crv,
                      targetos = env->md_id.osnum);
     EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
     EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

     *c2 = cv2;
     (*num)++;
     crv = NULL;  /* deleted */

     status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                            env),
                      senderid = my_id,
                      targetid = cv1);
     EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
     EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

     cv1 = NULL;  /* deleted */

  }  /* end if !end2 */
  else if (end2)  /* pnt2 is on the end point of the composite */
  {
     status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                            env),
                      senderid = my_id,
                      targetid = crv);
     EMomerr_hndlr_action(status, *msg = MSFAIL; goto ret_end, errmsg);
     EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

     crv = NULL;  /* deleted */

  }  /* end if end2 */


  ret_end:
	if (*msg == MSFAIL)
    {
       if (*c1 != NULL_OBJID)
       {
          status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                                 env),
                           senderid = my_id,
                           targetid = *c1);
          EMomerr_hndlr_action(status, ;, errmsg);
          EMerr_hndlr_action(EMis_error(msg_loc), *msg, MSFAIL, ;);

          *c1 = NULL_OBJID;
          (*num)--;
       }

       if (*c2 != NULL_OBJID)
       {
          status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                                 env),
                           senderid = my_id,
                           targetid = *c2);
          EMomerr_hndlr_action(status, ;, errmsg);
          EMerr_hndlr_action(EMis_error(msg_loc), *msg, MSFAIL, ;);

          *c2 = NULL_OBJID;
          (*num)--;
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
    }  /* end if msg == MSFAIL */

	else if (*msg == MSSUCC)
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
