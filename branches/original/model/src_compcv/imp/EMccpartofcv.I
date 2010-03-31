/* ###################   APOGEE COMPILED   ################## */
class implementation GRcompcurve;

#include "EMScc.h"
#include "OMminimum.h"
#include "OMmacros.h"   /* for OM_BLOCK_MOVE */
#include "msdef.h"
#include "godef.h"
#include "gr.h"
#include "ma.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "bserr.h"
#include "bsparameters.h"

method EMpartofcv (IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
                   struct GRvg_construct *const_args;
                   struct GRparms *start_parms,*mid_parms,*end_parms;
                   GRobjid *partcvid)
/*
Abstract
	This method places part of a composite curve beginning at start_parms
	and ending at end_parms and in the direction of mid_parms for closed
	curves.

Arguments

Notes

Files
	EMccpartofcv.I

History
	dhm		11/06/87		Creation date.
	dhm		12/21/87		converted to 1.1
    dhm     02/2/88         rewrote for better performance.
    dhm     02/16/88        changed to return a copy of the composite if
                            request endpoints at start and end.
    dhm     03/08/89        Fixed phyically closed check to be "and'ed"
                            with the me->comp_props.
    rlw     06/09/89        Don't put symbology if it doesn't get passed in.
*/

{
 extern  IGRlong  EFclose_endpnt();
  IGRlong		msg_loc, status, rotten_one;
  IGRboolean	is_inside, start1, start2, end1, end2;
  OMuint                ind1, ind2, ind3;
  IGRint		i,num_arr, count, begin_extr, end_extr;
  IGRchar		errmsg[EMMAXERRMSG_LEN];
  IGRpoint		pnt1, pnt3;
  struct GRlc_info	*cv_arr;
  struct GRparms	par1, par3, spar, mpar, epar;
  OM_S_CHANSELECT   composite_chan;
  struct  GRsymbology   active_symb;
  struct  GRmd_env      env;

  /*
   * Initialize variables.
   */

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(errmsg,"GRcompcurve.EMpartofcv\n");
  *partcvid = NULL;
  cv_arr = NULL;
  if (const_args->display)
   {
    active_symb.display_attr = *(const_args->display);
    active_symb.level = const_args->level;
   }
  env.md_id.osnum = OM_Gw_current_OS;
  env.md_env.matrix_type = *matrix_type;
  OM_BLOCK_MOVE(matrix, env.md_env.matrix, sizeof(IGRmatrix));


  /*
   * Initialize the channel selector
   */

  status = EMmake_chanselect (GRcmpowner_to_components, &composite_chan);
  EMomerr_hndlr(status, ret_end, errmsg);

  /*
   * Get the number of components on the channel.
   */

  status = om$send(msg = message GRowner.GRget_number_components(
                         &msg_loc, &count),
                   targetid = my_id);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Get the index of the object on which
   * start_parms, mid_parms, end_parms lie.
   */

  status = om$get_index(object_c = me,
                        p_chanselect = &composite_chan,
                        objid = start_parms->leaf_id.objid,
                        indexaddr = &ind1);
  EMomerr_hndlr(status, ret_end, errmsg);

  if (me->comp_props & GRIS_PHY_CLOSED)
  {
     status = om$get_index(object_c = me,
                           p_chanselect = &composite_chan,
                           objid = mid_parms->leaf_id.objid,
                           indexaddr = &ind2);
     EMomerr_hndlr(status, ret_end, errmsg);
  }

  status = om$get_index(object_c = me,
                        p_chanselect = &composite_chan,
                        objid = end_parms->leaf_id.objid,
                        indexaddr = &ind3);
  EMomerr_hndlr(status, ret_end, errmsg);

  /*
   * Order the parameters and indexes in ascending order.
   */

  if ( (ind1 < ind3) || ((ind1 == ind3) &&
                         (start_parms->u < end_parms->u)) )
  {
     par1.u = start_parms->u;
     par1.leaf_id.objid = start_parms->leaf_id.objid;
     par1.leaf_id.osnum = start_parms->leaf_id.osnum;
     par3.u = end_parms->u;
     par3.leaf_id.objid = end_parms->leaf_id.objid;
     par3.leaf_id.osnum = end_parms->leaf_id.osnum;
  }
  else
  {
     par1.u = end_parms->u;
     par1.leaf_id.objid = end_parms->leaf_id.objid;
     par1.leaf_id.osnum = end_parms->leaf_id.osnum;
     par3.u = start_parms->u;
     par3.leaf_id.objid = start_parms->leaf_id.objid;
     par3.leaf_id.osnum = start_parms->leaf_id.osnum;
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
         ((ind2 == ind1) && (mid_parms->u < par1.u)) ||
         ((ind2 == ind3) && (mid_parms->u > par3.u)) )
           is_inside = FALSE;
  }

  /*
   * If parameters are on the same index and is_inside,
   * then send EMpartofcv to component and quit.
   */

  if ( (ind1 == ind3) && (is_inside) )
  {
     status = om$send(msg = OPPmargs,
                      p_chanselect = &composite_chan,
                      from = ind1,
                      to =ind1);
     EMomerr_hndlr(status, ret_end, errmsg);
     EMerr_hndlr(EMis_error(*msg), *msg, MSFAIL, ret_end);

     goto ret_end;
  }

  /*
   * Get the points at par1 and par3.  Check to see
   * if the points are close to the start or end of 
   * the components.
   */

  status = om$send(msg = message GRvg.EMptatpr(&msg_loc,
                         matrix_type, matrix, &par1.u, 1, pnt1),
                   senderid = my_id,
                   targetid = par1.leaf_id.objid,
                   targetos = par1.leaf_id.osnum);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  status = om$send(msg = message GRvg.EMptatpr(&msg_loc,
                         matrix_type, matrix, &par3.u, 1, pnt3),
                   senderid = my_id,
                   targetid = par3.leaf_id.objid,
                   targetos = par3.leaf_id.osnum);
  EMomerr_hndlr(status,  ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  status = EFclose_endpnt(&msg_loc, my_id, &env, 
                          par1.leaf_id.objid, pnt1, &start1, &end1);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  status = EFclose_endpnt(&msg_loc, my_id, &env,
                          par3.leaf_id.objid, pnt3, &start2, &end2);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Copy and return the copy of the composite if
   * the endpoints of the composite are requested.
   */

  if ( ((ind1 == 0) && start1) &&
       ((ind3 == count-1) && end2) )
  {
      status = om$send(msg = message GRgraphics.GRcopy(&msg_loc,
                             &env, const_args->env_info, partcvid),
                       targetid = my_id);
     EMomerr_hndlr(status, ret_end, errmsg);
     EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

     if (const_args->display)
     {
      status = om$send(msg = message GRvg.GRputsymb (&msg_loc,
                             &active_symb),
                       targetid = *partcvid);
      EMomerr_hndlr(status, ret_end, errmsg);
      EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);
     }

     goto ret_end;
  }

  /*
   * If is_inside, then get the objects between ind1 and ind3
   * calling EMpartofcv at ind1 or ind3 when not at an endpoint.
   * If !is_inside, then get the objects outside of ind1 and ind3.
   */

  cv_arr = (struct GRlc_info *) om$malloc(size = (count + 1) *
                                          sizeof(struct GRlc_info));
  EMerr_hndlr(!cv_arr, *msg, MSNOMEM, ret_end);

  num_arr = 0;

  if (is_inside)  /* if is_inside */
  {
    if (!start1 && !end1)
    {
      epar.u = 1.0;
      status = om$send(msg = message GRcurve.EMpartofcv(&msg_loc,
                             matrix_type, matrix, const_args, &par1,
                             mid_parms, &epar,
                             &cv_arr[num_arr].located_obj.objid),
                       targetid = par1.leaf_id.objid,
                       targetos = par1.leaf_id.osnum);
      EMomerr_hndlr(status,  ret_end, errmsg);
      EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

      cv_arr[num_arr].located_obj.osnum = par1.leaf_id.osnum;
      cv_arr[num_arr].module_info = *(const_args->env_info);
      num_arr++;
    }

    if (start1) begin_extr = ind1;
    else        begin_extr = ind1 + 1;

    if (end2)   end_extr = ind3;
    else        end_extr = ind3 - 1;

    spar.u = 0.0;
    mpar.u = spar.u;
    epar.u = 1.0;
    for (i = begin_extr; i <= end_extr; i++)
    {
      status = om$send(msg = message GRcurve.EMpartofcv(&msg_loc,
                             matrix_type, matrix, const_args, &spar,
                             &mpar, &epar,
                             &cv_arr[num_arr].located_obj.objid),
                        senderid = my_id,
                        p_chanselect = &composite_chan,
                        from = i,
                        to = i);
      EMomerr_hndlr(status, ret_end, errmsg);
      EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

      cv_arr[num_arr].located_obj.osnum = par1.leaf_id.osnum;
      cv_arr[num_arr].module_info = *(const_args->env_info);
      num_arr++;
    }

    if (!start2 && !end2)
    {
      spar.u = 0.0;
      status = om$send(msg = message GRcurve.EMpartofcv(&msg_loc,
                             matrix_type, matrix, const_args, &spar,
                             mid_parms, &par3,
                             &cv_arr[num_arr].located_obj.objid),
                       targetid = par3.leaf_id.objid,
                       targetos = par3.leaf_id.osnum);
      EMomerr_hndlr(status,  ret_end, errmsg);
      EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

      cv_arr[num_arr].located_obj.osnum = par3.leaf_id.osnum;
      cv_arr[num_arr].module_info = *(const_args->env_info);
      num_arr++;
    }
  }  /* end if is_inside */

  else  /* closed, outside range */
  {
    if (!start2 && !end2)
    {
      epar.u = 1.0;
      status = om$send(msg = message GRcurve.EMpartofcv(&msg_loc,
                             matrix_type, matrix, const_args, &par3,
                             mid_parms, &epar,
                             &cv_arr[num_arr].located_obj.objid),
                       targetid = par3.leaf_id.objid,
                       targetos = par3.leaf_id.osnum);
      EMomerr_hndlr(status,  ret_end, errmsg);
      EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

      cv_arr[num_arr].located_obj.osnum = par3.leaf_id.osnum;
      cv_arr[num_arr].module_info = *(const_args->env_info);
      num_arr++;
    }

    end_extr = count - 1;
    if (start2) begin_extr = ind3;
    else        begin_extr = ind3 + 1;

    spar.u = 0.0;
    mpar.u = spar.u;
    epar.u = 1.0;
    for (i = begin_extr; i <= end_extr; i++)
    {
      status = om$send(msg = message GRcurve.EMpartofcv(&msg_loc,
                             matrix_type, matrix, const_args, &spar,
                             &mpar, &epar,
                             &cv_arr[num_arr].located_obj.objid),
                        senderid = my_id,
                        p_chanselect = &composite_chan,
                        from = i,
                        to = i);
      EMomerr_hndlr(status, ret_end, errmsg);
      EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

      cv_arr[num_arr].located_obj.osnum = par1.leaf_id.osnum;
      cv_arr[num_arr].module_info = *(const_args->env_info);
      num_arr++;
    }

    begin_extr = 0;
    if (end1) end_extr = ind1;
    else      end_extr = ind1 - 1;

    for (i = begin_extr; i <= end_extr; i++)
    {
      status = om$send(msg = message GRcurve.EMpartofcv(&msg_loc,
                             matrix_type, matrix, const_args, &spar,
                             &mpar, &epar,
                             &cv_arr[num_arr].located_obj.objid),
                        senderid = my_id,
                        p_chanselect = &composite_chan,
                        from = i,
                        to = i);
      EMomerr_hndlr(status, ret_end, errmsg);
      EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

      cv_arr[num_arr].located_obj.osnum = par1.leaf_id.osnum;
      cv_arr[num_arr].module_info = *(const_args->env_info);
      num_arr++;
    }

    if (!start1 && !end1)
    {
      spar.u = 0.0;
      status = om$send(msg = message GRcurve.EMpartofcv(&msg_loc,
                             matrix_type, matrix, const_args, &spar,
                             mid_parms, &par1,
                             &cv_arr[num_arr].located_obj.objid),
                       targetid = par1.leaf_id.objid,
                       targetos = par1.leaf_id.osnum);
      EMomerr_hndlr(status,  ret_end, errmsg);
      EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

      cv_arr[num_arr].located_obj.osnum = par1.leaf_id.osnum;
      cv_arr[num_arr].module_info = *(const_args->env_info);
      num_arr++;
    }

  }  /* end else outside */

  /*
   * Make the composite curve out of cv_arr and 
   * return partcvid.
   */

  if (num_arr > 1)
  {
    status = om$construct(classid = OPP_GRcompcurve_class_id,
                          osnum = const_args->env_info->md_id.osnum,
                          p_objid = partcvid,
                          msg = message GRgraphics.GRconstruct
                                (const_args));
    EMomerr_hndlr(status, ret_end,errmsg);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

    status = om$send(msg = message GRcompcurve.EMmakecomp(&msg_loc,
                           const_args->env_info, num_arr, cv_arr,
                           &rotten_one),
                     senderid = my_id,
                     targetid = *partcvid,
                     targetos = const_args->env_info->md_id.osnum);
    EMomerr_hndlr(status, ret_end,errmsg);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);
  }
  else if (num_arr == 1)
    *partcvid = cv_arr[0].located_obj.objid;
  else
    *msg = MSFAIL;


  ret_end:
    if ( (*msg != MSSUCC) || !(status&1) )
    {
       if (*partcvid)
       {
          status = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                                 const_args->env_info),
                           senderid = my_id,
                           targetid = *partcvid);
          EMomerr_hndlr_action(status, ;, errmsg);
          EMerr_hndlr_action(EMis_error(msg_loc), *msg, MSFAIL, ;);

          *partcvid = NULL;
       }
	}

    if (cv_arr)   om$dealloc(ptr = cv_arr);

	return(status);

}

end implementation GRcompcurve;
