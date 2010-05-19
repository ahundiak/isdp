/* $Id: dimtext_l.I,v 1.1 2001/10/17 20:39:58 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/dim / dimtext_l.I
 *
 * Description: The original file, defining these methods, is:
 *
 *              $GRNUC/src/dim/dim_linear/dimtext_l.I
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: dimtext_l.I,v $
 *	Revision 1.1  2001/10/17 20:39:58  hans
 *	Modifications for CR# MP5368
 *	
 *
 * History:
 *	MM/DD/YYYY	AUTHOR	DESCRIPTION
 *	10/16/2001	HF	Creation Date
 *                              Modifications for CR# MP5368
 * -------------------------------------------------------------------*/

class implementation DMlinear;

#define AS_DEBUG 1
#include "mascalvc.h"
#include "maaddvc.h"
#include "bsmkvec.h"
#include "bsdotp.h"

#define VD_DEBUG

#include "VDdebug.h"

// From $GRNUC/include/dimdef.h
/* - Terminator Location - */

#define TER_LOCA_INTERNAL	0
#define TER_LOCA_EXTERNAL	1
// Added for new functionality
#define TER_LOCA_LEFT		2
#define TER_LOCA_RIGHT		3

method make_dim_text(
  IGRint *msg;
  IGRdouble term_ori[3];
  IGRdouble term_mea[3];
  IGRdouble break_pt[3];
  IGRdouble leader_pt[3];
  struct DMenv_param *par_env;
  struct DMloc_param *par_loc;
  struct DMplan_info *plan_info;
  struct GRmd_env    *md_env)
{
  IGRint status, rc;
  IGRint index;
  IGRdouble def_offs[3], text_pt[3];
  IGRdouble *matrix;
  IGRdouble line_orie[3];
  IGRdouble txt_yoff;


  IGRdouble norm_to_plane[3];
  IGRdouble pt_on_plane[3];
  IGRdouble mea_axis[3];
  IGRdouble perp_axis[3];
  IGRdouble trak_dir[3];

  IGRdouble text_dir[3];
  IGRdouble offs_dir[3];
  IGRshort  txt_just, just_pos, just_neg;
  BSrc	bsrc;

  __enterMethod ( name = "make_dim_text", argfmt = "me->ter_loca = %d, me->dim_type = %d, me->leader = %d, me->brk_pos = %d",
                  args = `me->ter_loca, me->dim_type, me->leader, me->brk_pos` );

  *msg = MSSUCC;

  if (!me->leader)
  {
    if(par_loc->txt_orie == TXT_ORIE_HORIZONTAL || par_loc->txt_orie == TXT_ORIE_VERTICAL)
       par_loc->txt_posn = TXT_POSN_EMBEDDED;
  }

  DMget_axis_info(plan_info,
                  norm_to_plane,
                  pt_on_plane,
                  mea_axis,
                  perp_axis,
                  me->mea_trak,
                  trak_dir);

  DMget_text_info(par_loc,
                  plan_info,
                  me->mea_trak,
                  me->leader,
                  text_dir,
                  offs_dir,
                  &just_pos,
                  &just_neg);

  if (par_loc->txt_posn == TXT_POSN_ABOVE)
  {
    txt_yoff = par_env->txt_yoff_r * par_env->txt_heig;
    MAscalvc(&bsrc, &txt_yoff, offs_dir, def_offs);
  }
  else
  {
    def_offs[0] = def_offs[1] = def_offs[2] = 0.0;
  }

  MAaddvc(&bsrc, (me->leader)?leader_pt:break_pt, def_offs, text_pt);

  /*| - Add offset to text - */

  matrix = plan_info->act_plan.matrix;
  for (index=0; index<3; index++)
  {
    text_pt[index] +=
      me->offs_pt[0] * matrix[index] +
      me->offs_pt[1] * matrix[index + 4];
  }

  if (me->leader)
  {
    BSmkvec(&bsrc, line_orie, break_pt, leader_pt);
    if (BSdotp(&bsrc, line_orie, text_dir) >= 0.0)
      txt_just = just_pos;
    else
      txt_just = just_neg;
  }
  else
    txt_just = just_pos;

  status =
    om$send(msg = message DMroot.position_text(
              msg,
              TRUE,
              DIM_TEXT,
              NULL,
              md_env,
              txt_just,
              text_pt,
              text_dir,
              norm_to_plane,
              par_loc,
              par_env),
            targetid = my_id);
  dm$status(action = RET_STATUS);

  __exitMethod  ( name = "make_dim_text", argfmt = "me->ter_loca = %d",
                  args = `me->ter_loca`);

  return(OM_S_SUCCESS);
}

method make_dim_term(
  IGRint *msg;
  IGRdouble term_ori[3];
  IGRdouble term_mea[3];
  IGRdouble dimline[3];
  struct DMenv_param *par_env;
  struct DMloc_param *par_loc;
  struct DMplan_info *plan_info;
  struct GRmd_env *md_env)
{
  IGRint     status, rc, is_linear = 0;
  IGRdouble  norm[3], orig_orie[3], meas_orie[3];
  IGRdouble *origin, *orientation;
  IGRshort   orig_just, meas_just, justification;
  IGRint     dsp_flag, go_index;
  int        i, cycle_4_term = 0;
  GRclassid          clid;
  struct GRid        term_grid;

  extern struct DMglobal       DM_global;
  extern struct DMglobal_param frm_glob;
  extern int    get_cycle_4_term();

  status = om$get_classid( osnum = OM_Gw_current_OS, objid = my_id, p_classid = &clid);
  dm$status(action = RET_STATUS);

  if (om$is_ancestry_valid( subclassid   = clid,
                            superclassid = OPP_DMlinear_class_id) == OM_S_SUCCESS)
  {
    is_linear = 1;
  }
  cycle_4_term = get_cycle_4_term();
  if ( is_linear && par_loc->lin_disp > LIN_DISP_ON && me->ter_loca == TER_LOCA_INTERNAL && cycle_4_term == 0 )
  {
    me->ter_loca = TER_LOCA_LEFT;
  }

  __enterMethod ( name = "make_dim_term", argfmt = "me->ter_loca = %d, cycle_4_term = %d, me->leader = %d, me->brk_pos = %d",
                  args = `me->ter_loca, cycle_4_term, me->leader, me->brk_pos` );

  norm[0] = plan_info->win_plan.matrix[8];
  norm[1] = plan_info->win_plan.matrix[9];
  norm[2] = plan_info->win_plan.matrix[10];

  if (me->ter_loca == TER_LOCA_INTERNAL)
  {
    for (i=0; i<3; i++)
    {
      orig_orie[i] = -dimline[i];
      meas_orie[i] = dimline[i];
    }

    orig_just = DM_global.term_info[par_env->ter_type0].center_just ? CENTER_CENTER : RIGHT_CENTER;

    meas_just = DM_global.term_info[par_env->ter_type ].center_just ? CENTER_CENTER : RIGHT_CENTER;
  }
  else if (me->ter_loca == TER_LOCA_EXTERNAL)
  {
    for (i=0; i<3; i++)
    {
      orig_orie[i] = dimline[i];
      meas_orie[i] = -dimline[i];
    }

    orig_just = DM_global.term_info[par_env->ter_type0].center_just ? CENTER_CENTER : RIGHT_CENTER;

    meas_just = DM_global.term_info[par_env->ter_type ].center_just ? CENTER_CENTER : RIGHT_CENTER;
  }
  else if (me->ter_loca == TER_LOCA_LEFT)
  {
    for (i=0; i<3; i++)
    {
      orig_orie[i] = dimline[i];
      meas_orie[i] = dimline[i];
    }

    orig_just = DM_global.term_info[par_env->ter_type0].center_just ? CENTER_CENTER : RIGHT_CENTER;

    meas_just = DM_global.term_info[par_env->ter_type ].center_just ? CENTER_CENTER : RIGHT_CENTER;
  }
  else if (me->ter_loca == TER_LOCA_RIGHT)
  {
    for (i=0; i<3; i++)
    {
      orig_orie[i] = -dimline[i];
      meas_orie[i] = -dimline[i];
    }

    orig_just = DM_global.term_info[par_env->ter_type0].center_just ? CENTER_CENTER : RIGHT_CENTER;

    meas_just = DM_global.term_info[par_env->ter_type ].center_just ? CENTER_CENTER : RIGHT_CENTER;
  }

  for (i=0; i<2; i++)
  {
    if (i == 0)
    {
      orientation   = orig_orie;
      justification = orig_just;
      origin        = term_ori;
      dsp_flag      = (par_loc->ter_disp & TER_DISP_ORI);
      go_index      = DIM_ORI_TERM;

      if ((me->geom_type & DIM_DIRECTED) && (frm_glob.dim_mode == MODELING_MODE))
        dsp_flag = FALSE;
    }
    else
    {
      orientation   = meas_orie;
      justification = meas_just;
      origin        = term_mea;
      dsp_flag      = (par_loc->ter_disp & TER_DISP_MEA);
      go_index      = DIM_MEA_TERM;
    }

    if (dsp_flag)
    {
      status =
        om$send(msg = message DMroot.set_ter_type(
                  msg,
                  go_index,
                  &term_grid,
                  md_env,
                  par_env,
                  par_loc),
                targetid = my_id);
      dm$status(action = RET_STATUS);

      status =
        om$send(msg = message DMroot.position_text(
                  msg,
                  FALSE,
                  go_index,
                  &term_grid,
                  md_env,
                  justification,
                  origin,
                  orientation,
                  norm,
                  par_loc,
                  par_env),
                targetid = my_id);
      dm$status(action = RET_STATUS);
    }
    else
    {
      status =
        om$send(msg = message DMroot.delete_dim_go(
                  msg,
                  go_index,
                  md_env),
                targetid = my_id);
      dm$status(action = RET_STATUS);
    }
  }

  __exitMethod  ( name = "make_dim_term", argfmt = "me->ter_loca = %d",
                  args = `me->ter_loca`);

  return(OM_S_SUCCESS);
}

end implementation DMlinear;
