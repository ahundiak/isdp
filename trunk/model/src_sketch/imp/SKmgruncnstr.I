/*

Name
  SKdisplay_underconstrained

Abstract

Synopsis

Description
    This method is used to display the ghost image of an underconstrained
    profile.  The underconstrained variables are perturbed by a small
    amount and the profile is recomputed.

Return Value

Notes

Index

Keywords
  profile, ghost image, degrees of freedom.

History
  ???????? : ????????????? : created
  08/06/92 : Rajiv Agrawal : Call SKgetval and SKputval in case of Pseudo-variables.
  10/19/92 : Rajiv Agrawal : Put SK_UPDATE_DONOTPOST options in SKputval so that
                             the children of SKmgr do not get updated.
  03/21/93 : Rajiv Agrawal : Get the linestyles of all the profile components (TR11925250).
  05/14/93 : Rajiv Agrawal : Removed the display of degrees of freedom message since the
                             command object handles it.
  07/02/93 : Sudha         : Modified for BSprototypes ansification

 */

class implementation SKmgr;

#include "alloca.h"
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "bserr.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "bsnorvec.h"
#include "bsdistptpt.h"
#include "bscrossp.h"

#define FRACTION_RANGE 0.25

from SKvariable import SKgetvar, SKputvar;
from SKgeometry import SKrecompute_yourself;
from SKexplicit import SKgetval, SKputval;

extern OMuword OPP_SKground_class_id, OPP_SKcompcurve_class_id;

method SKdisplay_underconstrained ( long *msg; unsigned short opts; struct GRmd_env *md_env )
{
  IGRboolean         in_world_system = TRUE, reverse_vector = FALSE;
  IGRboolean         var_uncnstr;
  IGRboolean         pt_found, gr_cnstr_exists, bssts;
  IGRuchar           new_style, **old_line_style;
  short              mattyp_to_lxyz;
  int                num_undersolved, i, j, num_comps;
  int                bytes_in, bytes_out;
  int                num_uncnstr, last_var_inx;
  int                pt_ix;
  OMuint             num_cnstrs;
  long               msg_loc, stat_OM, rc;
  double             sld, delta_x, delta_y, delta_value;
  double 	     cnstr_pts[6], val_vec[3];
  IGRpoint           transform_pt, pt;
  IGRvector          unit_x, unit_y;
  IGRmatrix          mat_to_lxyz;
  GRrange            xyz_range, xy_range;
  struct SKsolvepath solvepath;
  struct SKsolvevars *varlist;
  struct SKsolvevars *loc_solved_vars, *loc_nosolution_vars;
  struct SKsolvevars *loc_undersolved_vars;
  struct IGRdisplay  active_display;
  struct GRsymbology old_symb;
  enum GRdpmode      DisplayMode;
  OM_S_CHANSELECT    to_cmpnts_chan, cnstr_pts_chan, pts_cnstr_chan;
  GRobjid            cnstr_pt_ids[2], cnstr_id;
  GRspacenum         dum_os;
  OMuword            cnstr_classid;
  struct GRid	     *comp_list;

  IGRboolean aflag = 0;
  struct GRmd_env disp_env;

%safe
  extern void        EFdraw_vector_on_screen(), SKmerge_vars();
  extern long        SKsolve();
%endsafe

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  loc_solved_vars 	= NULL;
  loc_nosolution_vars 	= NULL;
  loc_undersolved_vars 	= NULL;
  num_undersolved 	= 0;
  solvepath.constrs 	= NULL;
  solvepath.action 	= NULL;
  solvepath.num_constrs = 0;

  aflag = pwIsActivationOn();
  if(aflag)
    gr$get_module_env(msg= msg , buffer = &disp_env);

  /*
   * Perform the analysis on the constraints and the variables within
   * this system, determining the solution path, any under-constrained
   * variables and the overconstrained variables. If overconstrainedness
   * is found, terminate with appropriate return code. If fully constrained
   * then terminate too.
   */

  stat_OM = om$send (msg = message SKmgr.SKanalyze (&msg_loc, NULL,
                           NULL, &loc_undersolved_vars, NULL, &solvepath),
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, wrapup);

  stat_OM = SKsolve (&msg_loc, opts, &solvepath,
                     OM_Gw_current_OS,
                     &loc_solved_vars, NULL, &loc_undersolved_vars, 
                     NULL);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, wrapup);

  if (msg_loc == EMS_S_Success)
    msg_loc = EMS_I_FullyConstrained;

  if (loc_solved_vars)
    SKfreevarlist (loc_solved_vars, MAXINT);
  loc_solved_vars = NULL;

  varlist = loc_undersolved_vars;
  num_uncnstr = 0;

  while (varlist)
  {
    num_uncnstr++;
    if (varlist->props & VAR_PT)
    {
      stat_OM = om$send (msg = message SKvariable.SKgetvar (msg,
                               NULL, NULL, NULL, varlist->var),
                         targetid = varlist->varobj);
      EMerr_hndlr (!(1&stat_OM&*msg), *msg, EMS_E_Fail, wrapup);
    }
    varlist = varlist->next;
  } /* while (varlist) */

  last_var_inx = solvepath.num_constrs - 1;

  for (i = 0; i < (solvepath.num_constrs - num_uncnstr); i++)
  {
    varlist = loc_undersolved_vars;
    var_uncnstr = FALSE;

    for (j = 0; j < num_uncnstr; j++)
    {
      if (varlist->varobj == solvepath.constrs[i].varsolveid  &&
          varlist->props == solvepath.constrs[i].vprops)
      {
        var_uncnstr = TRUE;
        break;
      }
      varlist = varlist->next;
    }

    if (var_uncnstr)
    {

      while (var_uncnstr)
      {
        varlist = loc_undersolved_vars;
        var_uncnstr = FALSE;

        for (j = 0; j < num_uncnstr; j++)
        {
          if (varlist->varobj == solvepath.constrs[last_var_inx].varsolveid 
              &&
              varlist->props == solvepath.constrs[last_var_inx].vprops)
          {
            last_var_inx--;
            var_uncnstr = TRUE;
            break;
          }
          varlist = varlist->next;
        }

        if (!var_uncnstr)
        {
          solvepath.constrs[i].vprops = 
              solvepath.constrs[last_var_inx].vprops;
          solvepath.constrs[i].varsolveid =
              solvepath.constrs[last_var_inx].varsolveid;
          last_var_inx--;
        }

      } /* while (var_uncnstr) */

    } /* if (var_uncnstr) */
  } /* for (i = 0; i < solvepath.num_constrs; i++) */

  solvepath.num_constrs -= num_uncnstr;

  if (msg_loc == EMS_I_Redundant || msg_loc == EMS_I_FullyConstrained)
  {
    *msg = msg_loc;
    goto wrapup;
  }

  /*
   * If underconstrainedness found, tweak these variables by an amount
   * related to the size of the geometry. Mark them as grounds in the
   * subsequent solution process and thus obtain the underconstrained image.
   */

  if (msg_loc == EMS_I_UnderConstrained)
  {

    *msg = msg_loc;

    stat_OM = om$make_chanselect (channame = "SKconstraint.to_variables",
                                  p_chanselect = &cnstr_pts_chan);
    EMerr_hndlr (!(1&stat_OM),*msg,EMS_E_OMerror,wrapup);

    stat_OM = om$make_chanselect (channame = "SKvariable.to_constraints",
                                  p_chanselect = &pts_cnstr_chan);
    EMerr_hndlr (!(1&stat_OM),*msg,EMS_E_OMerror,wrapup);

    stat_OM = om$send (msg = message GRvg.GRgetrang (&msg_loc,
                             &md_env->md_env.matrix_type, md_env->md_env.matrix, 
                             &in_world_system, xyz_range), 
                       targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, wrapup);

    stat_OM = om$send (msg = message SKmgr.SKtransform_pt (&msg_loc,
                             SK_OPT_GET_XYZ_TO_XY, &md_env->md_env.matrix_type,
                             md_env->md_env.matrix, 2, xyz_range, xy_range),
                       targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, wrapup);
    for (i=3;i<6;i++)
      xyz_range[i] = xyz_range[i-3] + FRACTION_RANGE * 
                     (xyz_range[i] - xyz_range[i-3]);
    sld = BSdistptpt (&msg_loc, xy_range, &xy_range[3]);
    delta_x = 0.05 * sld;
    delta_y = 0.07 * sld;
    delta_value = 0.065 * sld;

    bytes_in = sizeof (struct IGRdisplay);
    gr$get_active_display (msg = &msg_loc, sizbuf = &bytes_in,
                           buffer = &active_display, nret = &bytes_out);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);
    active_display.weight = 2;

    OM_BLOCK_MOVE(me->x_axis, unit_x, sizeof (IGRvector));
   
   if(aflag = pwIsActivationOn())
   {  
    IGRvector tmp_vec;
    OM_BLOCK_MOVE(me->normal, tmp_vec, sizeof (IGRvector));
    RFtransform(md_env->md_env.matrix, md_env->md_env.matrix_type,
                FALSE, unit_x, tmp_vec, NULL, NULL);
    BScrossp(&msg_loc, tmp_vec, unit_x, unit_y);
   }
   else 
    BScrossp(&msg_loc, me->normal, unit_x, unit_y);

    if (msg_loc == 0) msg_loc = 1;
    else 
    {
      *msg = EMS_E_Fail;
      goto wrapup;
    }

    varlist = loc_undersolved_vars;
    while (varlist)
    {
      if (varlist->props & VAR_PT)
      {
        stat_OM = om$send (msg = message SKmgr.SKtransform_pt (&msg_loc,
                                 SK_OPT_GET_XY_TO_XYZ, &md_env->md_env.matrix_type,
                                 md_env->md_env.matrix, 1, varlist->var, transform_pt),
                           targetid = my_id);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);

        if (varlist->props & VAR_X)
        {
          EFdraw_vector_on_screen (my_id,&active_display, 
                                   aflag?&disp_env : md_env,
                                   GRhd, reverse_vector, transform_pt, 
                                   unit_x, xyz_range, 
                                   &msg_loc);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);
          varlist->var[X] += delta_x;
        }

        if (varlist->props & VAR_Y)
        {
          EFdraw_vector_on_screen(my_id,&active_display, 
                                  aflag?&disp_env : md_env,
                                  GRhd, reverse_vector, transform_pt, 
                                  unit_y, xyz_range, 
                                  &msg_loc);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);
          varlist->var[Y] += delta_y;
        }

      } /* if (varlist->props & VAR_PT) */
      else if (varlist->props & VAR_SOMEVAL)
      {
        if (varlist->props & VAR_PSEUDO_VAL)
        {
          /*
           * Assuming that the pseudo val is corresponding to a
           * pt-to-pt constraint, we can display a arrow at one
           * of its end points (which ever is not ground, if there
           * is one), in the direction of the pt_to_pt.
           */

          for (pt_ix = 0; pt_ix < 2; pt_ix++)
          {
            stat_OM = om$get_objid_at_index (objid = varlist->varobj,
                p_chanselect = &cnstr_pts_chan, index = pt_ix,
                objidaddr = &cnstr_pt_ids[pt_ix], 
                osnumaddr = &dum_os);
            EMerr_hndlr (!(1&stat_OM),*msg, EMS_E_OMerror, wrapup);

            stat_OM = om$send (msg = message SKvariable.SKgetvar (
                                     msg, NULL, &md_env->md_env.matrix_type,
                                     md_env->md_env.matrix, &cnstr_pts[3*pt_ix]),
                               targetid = cnstr_pt_ids[pt_ix]);
            EMerr_hndlr (!(1&stat_OM&*msg),*msg,EMS_E_Fail,wrapup);
          }

          pt_found = FALSE;
          for (pt_ix = 0; pt_ix < 2 && !pt_found; pt_ix++)
          {
            stat_OM = om$get_channel_count (objid = cnstr_pt_ids[pt_ix],
                osnum = OM_Gw_current_OS, 
                p_chanselect = &pts_cnstr_chan, 
                count = &num_cnstrs);
            EMerr_hndlr (!(1&stat_OM),*msg,EMS_E_OMerror,wrapup);

            gr_cnstr_exists = FALSE;

            for (j = 0; j < num_cnstrs && !gr_cnstr_exists; j++)
            {
              stat_OM = om$get_objid_at_index (objid=cnstr_pt_ids[pt_ix],
                  osnum = OM_Gw_current_OS, 
                  p_chanselect = &pts_cnstr_chan, index = j,
                  objidaddr = &cnstr_id, osnumaddr = &dum_os);
              EMerr_hndlr (!(1&stat_OM),*msg, EMS_E_OMerror, wrapup);

              stat_OM = om$get_classid (objid = cnstr_id, 
                  osnum = OM_Gw_current_OS, 
                  p_classid = &cnstr_classid);
              EMerr_hndlr (!(1&stat_OM), *msg, EMS_E_OMerror, wrapup);

              stat_OM = om$is_ancestry_valid (
                  superclassid = OPP_SKground_class_id,
                  subclassid = cnstr_classid);
              EMerr_hndlr (!(1&stat_OM), *msg, EMS_E_OMerror, wrapup);

              if (stat_OM == OM_S_SUCCESS)
                gr_cnstr_exists = TRUE;

            } /* for (j = 0; j < num_cnstrs && !gr_cnstr_exists; j++) */

            if (!gr_cnstr_exists)
            {
              pt_found = TRUE;
              for (j = 0; j < 3; j++)
                val_vec[j] = cnstr_pts[3+j] - cnstr_pts[j];
              if (!pt_ix)
                for (j = 0; j < 3; j++)
                  val_vec[j] = -val_vec[j];

              bssts = BSnorvec (&rc, val_vec);
              EMerr_hndlr (BSERROR(rc),*msg,EMS_E_BSerror,wrapup);

              EFdraw_vector_on_screen (my_id, &active_display, 
                                       aflag?&disp_env : md_env,
                                       GRhd, reverse_vector, 
                                       pt_ix ? &cnstr_pts[3] : cnstr_pts,
                                       val_vec, xyz_range, &msg_loc);
              EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);

            }

          } /* for (pt_ix = 0; pt_ix < 2 && !pt_found; pt_ix++) */


        } /* if (varlist->props & VAR_PSEUDO_VAL) */

        varlist->var[0] += delta_value;

      }
      else
      {
        *msg = EMS_E_InvalidArg;
        goto wrapup;
      }

      num_undersolved++;
      varlist = varlist->next;

    } /* while (varlist) */

    loc_solved_vars = loc_undersolved_vars;
    loc_undersolved_vars = NULL;

  } /* if (msg_loc == EMS_I_UnderConstrained) */

  /*
   * Knowing the solution path, solve the system. No overconstraints or 
   * undercontraints should be reported as these are taken care of in
   * the previous analysis step. But, a no-solution situation might exist.
   * In this latter case, terminate the process with the appropriate
   * return code.
   */

  stat_OM = SKsolve (&msg_loc, opts, &solvepath, OM_Gw_current_OS,
                     &loc_solved_vars, NULL, NULL, &loc_nosolution_vars);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, wrapup);

  if (msg_loc != EMS_S_Success)
    ex$message ( msgnumb = EMS_S_GhostApproximate );

  /* 
   * Update the variables with their new values. Save the oldvalues 
   * in the varlist structure.  Compute the new geometry and
   * display it in the dashed symbology.
   */

  SKmerge_vars (loc_solved_vars);

  varlist = loc_solved_vars;
  while (varlist)
  {
    if (varlist->props & VAR_PSEUDO_VAL)
    {
      stat_OM = om$send (msg = message SKexplicit.SKgetval (msg, pt),
                         targetid = varlist->varobj);
      EMerr_hndlr (!(1&stat_OM&*msg), *msg, EMS_E_Fail, wrapup);
      
      stat_OM = om$send (msg = message SKexplicit.SKputval (msg,
                               SK_UPDATE_DONOTPOST, varlist->var[0], NULL),
                         targetid = varlist->varobj);
      EMerr_hndlr (!(1&stat_OM&*msg), *msg, EMS_E_Fail, wrapup);
    }
    else
    {
      stat_OM = om$send (msg = message SKvariable.SKgetvar (msg, 
                               NULL, NULL, NULL, pt),
                         targetid = varlist->varobj);
      EMerr_hndlr (!(1&stat_OM&*msg), *msg, EMS_E_Fail, wrapup);
  
      stat_OM = om$send (msg = message SKvariable.SKputvar (msg, 
                               SK_OPT_VAR_X | SK_OPT_VAR_Y, NULL, NULL, varlist->var),
                         targetid = varlist->varobj);
      EMerr_hndlr (!(1&stat_OM&*msg), *msg, EMS_E_Fail, wrapup);
    }

    OM_BLOCK_MOVE (pt, varlist->var, sizeof(IGRpoint));

    varlist = varlist->next;

  } /* while (varlist) */

  stat_OM = om$make_chanselect (channame = "GRcmpowner.to_components",
                                p_chanselect = &to_cmpnts_chan);
  EMerr_hndlr (!(1&stat_OM), *msg, EMS_E_OMerror, wrapup);

  stat_OM = om$send (msg = message SKmgr.SKget_xymat (msg,
                           SK_OPT_GET_XY_TO_LXYZ, NULL, NULL, &mattyp_to_lxyz,
                           mat_to_lxyz), 
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & *msg), *msg, EMS_E_Fail, wrapup);

  stat_OM = om$send (msg = message SKgeometry.SKrecompute_yourself (msg,
                           md_env, &mattyp_to_lxyz, mat_to_lxyz),
                     p_chanselect = &to_cmpnts_chan);
  EMerr_hndlr (!(1&stat_OM&*msg), *msg, EMS_E_Fail, wrapup);

  /*
   * Save the old symbology and make all the components into a dashed style.
   */
  stat_OM = om$send  ( msg =  message GRowner.GRget_number_components 
                              (&msg_loc, &num_comps),
                       targetid = my_id);
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, wrapup);
  comp_list = (struct GRid *) alloca (num_comps * sizeof (struct GRid));
  stat_OM = om$send (msg = message GRowner.GRget_components (&msg_loc, NULL, 
                           comp_list, num_comps, &num_comps, 0, MAXINT),
                     targetid = my_id);
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, wrapup );
  old_line_style = (IGRuchar **) alloca ( num_comps * sizeof (IGRuchar *));
  for (i=0; i<num_comps; i++) 
  {
    struct GRid *sub_comp_list = NULL;
    int		num_sub_comps = 0;
    GRclassid	sk_classid;

    old_line_style[i] = NULL;
    stat_OM = om$get_classid (objid = comp_list[i].objid, osnum = comp_list[i].osnum,
                              p_classid = &sk_classid);
    if (sk_classid == OPP_SKcompcurve_class_id)
    {
      stat_OM = om$send  ( msg =  message GRowner.GRget_number_components 
                                  (&msg_loc, &num_sub_comps),
                           targetid = comp_list[i].objid, 
                           targetos = comp_list[i].osnum);
      EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, wrapup);
      EMerr_hndlr ( !num_sub_comps, *msg, EMS_I_InvalidCase, wrapup);
      if (num_sub_comps) 
      {
        sub_comp_list = (struct GRid *) alloca (num_sub_comps * sizeof (struct GRid));
        stat_OM = om$send (msg = message GRowner.GRget_components (&msg_loc, NULL, 
                                 sub_comp_list, num_sub_comps, &num_sub_comps, 0, MAXINT),
                           targetid = comp_list[i].objid, 
                           targetos = comp_list[i].osnum);
        EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, wrapup );
        old_line_style[i] = (IGRuchar *) alloca (num_sub_comps * sizeof (IGRuchar));
      }
    }
    else
    {
      num_sub_comps = 1;
      sub_comp_list = (struct GRid *) alloca (num_sub_comps * sizeof (struct GRid));
      sub_comp_list[0].objid = comp_list[i].objid;
      sub_comp_list[0].osnum = comp_list[i].osnum;
      old_line_style[i] = (IGRuchar *) alloca (num_sub_comps * sizeof (IGRuchar));
    }
    for (j=0; j<num_sub_comps; j++) 
    {
      stat_OM = om$send (msg = message GRvg.GRgetsymb (msg, &old_symb),
                         targetid = sub_comp_list[j].objid,
                         targetos = sub_comp_list[j].osnum);
      EMerr_hndlr (!(1&stat_OM&*msg), *msg, EMS_E_Fail, wrapup);
      old_line_style[i][j] = old_symb.display_attr.style;
    }
  }

  new_style = 2;
  stat_OM = om$send (msg = message GRvg.GRchgstyle (msg, &new_style),
                     p_chanselect = &to_cmpnts_chan);
  EMerr_hndlr (!(1&stat_OM&*msg), *msg, EMS_E_Fail, wrapup);

  DisplayMode = GRhd;
  
  stat_OM = om$send (msg = message GRgraphics.GRdisplay (msg, 
                           aflag?&disp_env.md_env.matrix_type:
                                 &md_env->md_env.matrix_type,
                           aflag?disp_env.md_env.matrix:
                                 md_env->md_env.matrix,
                           &DisplayMode, 
                           aflag?&disp_env.md_id:
                                 &md_env->md_id),
                     p_chanselect = &to_cmpnts_chan);
  EMerr_hndlr (!(1&stat_OM&*msg), *msg, EMS_E_Fail, wrapup);

  /*
   * Put the old values back.
   */
 
  varlist = loc_solved_vars;
  while (varlist)
  {
    if (varlist->props & VAR_PSEUDO_VAL)
    {
      stat_OM = om$send (msg = message SKexplicit.SKputval (msg,
                               SK_UPDATE_DONOTPOST, varlist->var[0], NULL),
                         targetid = varlist->varobj);
      EMerr_hndlr (!(1&stat_OM&*msg), *msg, EMS_E_Fail, wrapup);
    }
    else
    {
      stat_OM = om$send (msg = message SKvariable.SKputvar (msg, 
                               SK_OPT_VAR_X | SK_OPT_VAR_Y, NULL, NULL, varlist->var),
                         targetid = varlist->varobj);
      EMerr_hndlr (!(1&stat_OM&*msg), *msg, EMS_E_Fail, wrapup);
    }

    varlist = varlist->next;
  } /* while (varlist) */

  /*
   * Put the old line styles back.
   */
  for (i=0; i<num_comps; i++) 
  {
    struct GRid *sub_comp_list = NULL;
    int		num_sub_comps = 0;
    GRclassid	sk_classid;

    stat_OM = om$get_classid (objid = comp_list[i].objid, osnum = comp_list[i].osnum,
                              p_classid = &sk_classid);
    if (sk_classid == OPP_SKcompcurve_class_id) 
    {
      stat_OM = om$send  ( msg =  message GRowner.GRget_number_components 
                                  (&msg_loc, &num_sub_comps),
                           targetid = comp_list[i].objid, 
                           targetos = comp_list[i].osnum);
      EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, wrapup);
      EMerr_hndlr ( !num_sub_comps, *msg, EMS_I_InvalidCase, wrapup);
      if (num_sub_comps) 
      {
        sub_comp_list = (struct GRid *) alloca (num_sub_comps * sizeof (struct GRid));
        stat_OM = om$send (msg = message GRowner.GRget_components (&msg_loc, NULL, 
                                 sub_comp_list, num_sub_comps, &num_sub_comps, 0, MAXINT),
                           targetid = comp_list[i].objid, 
                           targetos = comp_list[i].osnum);
        EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, wrapup );
      }
    }
    else
    {
      num_sub_comps = 1;
      sub_comp_list = (struct GRid *) alloca (num_sub_comps * sizeof (struct GRid));
      sub_comp_list[0].objid = comp_list[i].objid;
      sub_comp_list[0].osnum = comp_list[i].osnum;
    }
    
    for (j=0; j<num_sub_comps; j++) 
    {
      stat_OM = om$send (msg = message GRvg.GRchgstyle (msg, &old_line_style[i][j]),
                         targetid = sub_comp_list[j].objid,
                         targetos = sub_comp_list[j].osnum);
      EMerr_hndlr (!(1&stat_OM&*msg), *msg, EMS_E_Fail, wrapup);
    }
  }
  
  /*
   * Recompute the geometry back.
   */
  stat_OM = om$send (msg = message SKgeometry.SKrecompute_yourself (msg,
                           md_env, &mattyp_to_lxyz, mat_to_lxyz),
                     p_chanselect = &to_cmpnts_chan);
  EMerr_hndlr (!(1&stat_OM&*msg), *msg, EMS_E_Fail, wrapup);


wrapup:
  if (loc_solved_vars)
    SKfreevarlist (loc_solved_vars, MAXINT);
  if (loc_nosolution_vars)
    SKfreevarlist (loc_nosolution_vars, MAXINT);
  if (loc_undersolved_vars)
    SKfreevarlist (loc_undersolved_vars, MAXINT);
  if (solvepath.action)
    om$dealloc (ptr = solvepath.action);
  if (solvepath.constrs)
    om$dealloc (ptr = solvepath.constrs);

  EMWRAPUP (*msg, stat_OM, "SKmgr.SKdisplay_underconstrained");
  return (stat_OM);
}
                  
end implementation SKmgr;

