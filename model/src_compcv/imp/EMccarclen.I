/* ###################   APOGEE COMPILED   ################## */
class implementation GRcompcurve;

#include "EMScc.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "msdef.h"
#include "godef.h"
#include "gr.h"
#include "grdpbmacros.h"
#include "gocmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "bserr.h"

method GRarclength(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
                   IGRpoint point1, point2, point3; struct GRparms *par1,
                   *par2, *par3; IGRdouble *arclength)
/*
Abstract
	This method calculates the arclenth of a composite curve given three
	points defining the part to measure

Arguments

Notes

Files
	EMccarclen.I

History
	dhm		11/12/87		Creation date.
	dhm		12/21/87		converted to 1.1
    dhm     03/01/88        Rewrite the right way.
    dhm     03/08/89        Fixed phyically closed check to be "and'ed"
                            with the me->comp_props.
*/

{
 extern  IGRlong  EFclose_endpnt();
  IGRlong		msg_loc, status;
  IGRboolean	is_inside, start1, start2, end1, end2;
  OMuint                count;
  IGRint                i;
  OMuint		ind1, ind2, ind3;
  IGRdouble     arclen, totlen;
  IGRchar		errmsg[EMMAXERRMSG_LEN];
  IGRpoint		start_pnt1, end_pnt1, start_pnt2, end_pnt2, pt1, pt2, pt3;
  struct GRparms	p1, p3, dum_parm;
  OM_S_CHANSELECT   to_comps;
  struct GRmd_env   env;

  /*
   * Initialize variables.
   */

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(errmsg,"GRcompcurve.GRarclength\n");
  arclen = 0.0;
  totlen = 0.0;
  *arclength = 0.0;

  /*
   * Initialize the channel selector
   */

  status = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
  EMomerr_hndlr(status, ret_end, errmsg);

  /*
   * Get the number of components on the channel.
   */

  status = om$get_channel_count(object = me,
                                p_chanselect = &to_comps,
                                count = &count);
  EMomerr_hndlr(status, ret_end, errmsg);

  /*
   * Get the index of the object on which
   * start_parms, mid_parms, end_parms lie.
   */

  status = om$get_index(object_c = me,
                        p_chanselect = &to_comps,
                        objid = par1->leaf_id.objid,
                        indexaddr = &ind1);
  EMomerr_hndlr(status, ret_end, errmsg);

  if (me->comp_props & GRIS_PHY_CLOSED)
  {
     status = om$get_index(object_c = me,
                           p_chanselect = &to_comps,
                           objid = par2->leaf_id.objid,
                           indexaddr = &ind2);
     EMomerr_hndlr(status, ret_end, errmsg);
  }

  status = om$get_index(object_c = me,
                        p_chanselect = &to_comps,
                        objid = par3->leaf_id.objid,
                        indexaddr = &ind3);
  EMomerr_hndlr(status, ret_end, errmsg);

  /*
   * Order the points, parameters and indexes in ascending order.
   */

  if ( (ind1 < ind3) || ((ind1 == ind3) && (par1->u < par3->u)) )
  {
     p1.u = par1->u;
     p1.leaf_id.objid = par1->leaf_id.objid;
     p1.leaf_id.osnum = par1->leaf_id.osnum;
     pt1[0] = point1[0];
     pt1[1] = point1[1];
     pt1[2] = point1[2];
     p3.u = par3->u;
     p3.leaf_id.objid = par3->leaf_id.objid;
     p3.leaf_id.osnum = par3->leaf_id.osnum;
     pt3[0] = point3[0];
     pt3[1] = point3[1];
     pt3[2] = point3[2];
  }
  else
  {
     p1.u = par3->u;
     p1.leaf_id.objid = par3->leaf_id.objid;
     p1.leaf_id.osnum = par3->leaf_id.osnum;
     pt1[0] = point3[0];
     pt1[1] = point3[1];
     pt1[2] = point3[2];
     p3.u = par1->u;
     p3.leaf_id.objid = par1->leaf_id.objid;
     p3.leaf_id.osnum = par1->leaf_id.osnum;
     pt3[0] = point1[0];
     pt3[1] = point1[1];
     pt3[2] = point1[2];
     i = ind1;
     ind1 = ind3;
     ind3 = i;
  }

  /*
   * If the curve is open or the mid_parm is between
   * start_parm and end_parm, is_inside equals TRUE.
   * If the curve is closed and the mid_parm is outside
   * of start_parm and end_parm, is_inside equals FALSE.
   */

  is_inside = TRUE;

  if (me->comp_props & GRIS_PHY_CLOSED)
  {
    if ( (ind2 < ind1) || (ind2 > ind3) ||
         ((ind2 == ind1) && (par2->u < p1.u)) ||
         ((ind2 == ind3) && (par2->u > p3.u)) )
           is_inside = FALSE;
  }

  /*
   * If parameters are on the same index and is_inside,
   * then send EMpartofcv to component and quit.
   */

  if ( (ind1 == ind3) && (is_inside) )
  {
     status = om$send(msg = OPPmargs,
                      p_chanselect = &to_comps,
                      from = ind1,
                      to =ind1);
     EMomerr_hndlr(status, ret_end, errmsg);
     EMerr_hndlr(EMis_error(*msg), *msg, MSFAIL, ret_end);

     goto ret_end;
  }

  /*
   * Check to see if the points are close to the start or end of 
   * the components.
   */

  env.md_id.osnum = OM_Gw_current_OS;
  env.md_env.matrix_type = *matrix_type;
  OM_BLOCK_MOVE(matrix, env.md_env.matrix, sizeof(IGRmatrix));

  status = EFclose_endpnt(&msg_loc, my_id, &env, 
                          p1.leaf_id.objid, point1, &start1, &end1);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  status = EFclose_endpnt(&msg_loc, my_id, &env,
                          p3.leaf_id.objid, point3, &start2, &end2);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Get the total length of the composite if
   * the endpoints of the composite are requested.
   */

  if ( ((ind1 == 0) && start1) &&
       ((ind3 == count-1) && end2) )
  {
      status = om$send(msg = message GRcurve.GRtotlength(&msg_loc,
                             matrix_type, matrix, arclength),
                       targetid = my_id);
     EMomerr_hndlr(status, ret_end, errmsg);
     EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

     goto ret_end;
  }

  /*
   *  Calculate the arclength across components.
   */

  status = om$send(msg = message GRcurve.GRendpts(&msg_loc,
                         matrix_type, matrix, start_pnt1, end_pnt1),
                   targetid = p1.leaf_id.objid,
                   targetos = p1.leaf_id.osnum);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  status = om$send(msg = message GRcurve.GRendpts(&msg_loc,
                         matrix_type, matrix, start_pnt2, end_pnt2),
                   targetid = p3.leaf_id.objid,
                   targetos = p3.leaf_id.osnum);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  if (is_inside)  /* if is_inside */
  {
    dum_parm.u = 1.0;
    pt2[0] = pt1[0];
    pt2[1] = pt1[1];
    pt2[2] = pt1[2];
    status = om$send(msg = message GRcurve.GRarclength(&msg_loc,
                           matrix_type, matrix, pt1, pt2, end_pnt1,
                           &p1, par2, &dum_parm, &arclen),
                     targetid = p1.leaf_id.objid,
                     targetos = p1.leaf_id.osnum);
    EMomerr_hndlr(status,  ret_end, errmsg);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

    for (i = (ind1 + 1); i < ind3; i++)
    {
      status = om$send(msg = message GRcurve.GRtotlength(&msg_loc,
                             matrix_type, matrix, &totlen),
                        senderid = my_id,
                        p_chanselect = &to_comps,
                        from = i,
                        to = i);
      EMomerr_hndlr(status, ret_end, errmsg);
      EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

      arclen += totlen;
    }

    dum_parm.u = 0.0;
    pt2[0] = start_pnt2[0];
    pt2[1] = start_pnt2[1];
    pt2[2] = start_pnt2[2];
    status = om$send(msg = message GRcurve.GRarclength(&msg_loc,
                           matrix_type, matrix, start_pnt2, pt2, pt3,
                           &dum_parm, par2, &p3, &totlen),
                     targetid = p3.leaf_id.objid,
                     targetos = p3.leaf_id.osnum);
    EMomerr_hndlr(status,  ret_end, errmsg);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

    arclen += totlen;

  }  /* end if is_inside */

  else  /* closed, outside range */
  {
    dum_parm.u = 1.0;
    pt2[0] = pt3[0];
    pt2[1] = pt3[1];
    pt2[2] = pt3[2];
    status = om$send(msg = message GRcurve.GRarclength(&msg_loc,
                           matrix_type, matrix, pt3, pt2, end_pnt2,
                           &p3, par2, &dum_parm, &arclen),
                     targetid = p3.leaf_id.objid,
                     targetos = p3.leaf_id.osnum);
    EMomerr_hndlr(status,  ret_end, errmsg);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

    for (i = (ind3 + 1); i < count; i++)
    {
      status = om$send(msg = message GRcurve.GRtotlength(&msg_loc,
                             matrix_type, matrix, &totlen),
                        senderid = my_id,
                        p_chanselect = &to_comps,
                        from = i,
                        to = i);
      EMomerr_hndlr(status, ret_end, errmsg);
      EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

      arclen += totlen;
    }

    for (i = 0; i < ind1; i++)
    {
      status = om$send(msg = message GRcurve.GRtotlength(&msg_loc,
                             matrix_type, matrix, &totlen),
                        senderid = my_id,
                        p_chanselect = &to_comps,
                        from = i,
                        to = i);
      EMomerr_hndlr(status, ret_end, errmsg);
      EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

      arclen += totlen;
    }

    dum_parm.u = 0.0;
    pt2[0] = start_pnt1[0];
    pt2[1] = start_pnt1[1];
    pt2[2] = start_pnt1[2];
    status = om$send(msg = message GRcurve.GRarclength(&msg_loc,
                           matrix_type, matrix, start_pnt1, pt2, pt1,
                           &dum_parm, par2, &p1, &totlen),
                     targetid = p1.leaf_id.objid,
                     targetos = p1.leaf_id.osnum);
    EMomerr_hndlr(status,  ret_end, errmsg);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

    arclen += totlen;

  }  /* end else outside */

  *arclength = arclen;

  ret_end:
	return(status);

}

end implementation GRcompcurve;
