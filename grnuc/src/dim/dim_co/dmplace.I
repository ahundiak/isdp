/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:30 $
$Locker:  $
$Log: dmplace.I,v $
Revision 1.1.1.1  2001/12/17 22:39:30  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:07:51  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.2  1997/03/03  09:19:07  bbathina
# COMMENT : Modified the code to replace the RFtransform function call by theactual code. This is because RFtransform is defined at Model leveli, and will not be available for Grnuc .
#
# Revision 330.0  1996/01/11  21:21:50  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.2  1995/04/03  13:06:42  gvk
# COMMENT : Layer information needs to be updated to active layer after placement
#
# Revision 320.1  1995/01/07  12:27:51  gvk
# COMMENT : Validating inputs for intersection input generator
#
# Revision 320.0  1994/12/12  17:51:20  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.12  1994/09/23  11:31:26  gvk
# COMMENT : Cannot use toggle term icon on the form to switch terminators during dynamics.
#
# Revision 400.1  1994/05/11  14:17:08  gvk
# COMMENT : Dim parameters are reflected during dynamics.
#
# Revision 400.0  1994/03/16  18:28:36  grnuc40
# COMMENT : Initial checkin to 4.0 RCS
#
# Revision 240.10  1993/10/30  14:58:55  samuel
# COMMENT : Fix for TR 119309196
#
# Revision 240.8  1993/08/12  21:02:48  mike
# COMMENT : Hilite the Status Display button.
#
# Revision 240.7  1993/08/03  05:42:35  laxmi
# COMMENT : Dimensioning 2.4 CR and TR fixes checkin. -Laxmi
#
# Revision 240.4  1993/03/30  11:41:45  laxmi
# COMMENT : UMS fix -laxmi.
#
# Revision 220.5  1993/03/12  14:15:10  gvk
# COMMENT : Using the current mode for setting measure axis
#
# Revision 220.4  1993/02/10  06:36:26  rishad
# COMMENT : Fix for TR # 119300487 checked into 2.2 and 2.4
#
# Revision 220.3  1992/12/24  17:00:51  poo
# COMMENT : CR # 119222888, To dimenison Coordinate Systems.
#
# Revision 220.2  1992/10/30  23:26:04  poo
# COMMENT : Fix to avoid Radial & Single Parallel dim associating with measurement axis.
#
Revision 201.31  1992/10/26  17:41:24  poo
COMMENT : Fix to avoid radial & single parallel dim associating to measurement axis.

Revision 201.30  1992/10/07  21:00:27  poo
COMMENT : Prevent Geometric Constraint handle getting located.

Revision 201.29  1992/10/06  18:26:32  poo
COMMENT : Fix Jogged global flag

Revision 201.27  1992/09/18  09:38:19  poo
COMMENT : Fix for command keyins processed during Jogged Dimension.

Revision 201.22  1992/07/29  18:55:21  poo
COMMENT : Initial Release of Surface Finish & Jogged bug fixes

Revision 201.21  1992/07/23  12:15:12  poo
COMMENT : Fix for Jogged Coordinate Dimension.

Revision 201.20  1992/07/19  16:13:23  poo
COMMENT : Inital Checkin of Jogged Dimension fuctionality.

*/

class implementation COdmplace;

#define AS_DEBUG 1

#include "dpstruct.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"

#include "igrtypedef.h"
#include "bserr.h"
#include "mainvmx.h"
#include "matypemx.h"
#include "madef.h"
#include "maoptsxfo.h"

extern int GL_sgl_type;
extern IGRboolean Dim_rad_jog;
extern IGRboolean Dim_coord_jog;
extern struct DMglobal_param frm_glob;

/*- Defines for Form Gadgets */

#define CHECK	1
#define SGLPAR_TYPE	11
#define STD_DIM		11
#define JOG_DIM		12

from GRvg    import GRgenabsg;
from NDnode  import NDplace, NDs_compute_node, NDgive_structure;
from NDnode  import ASreturn_go, NDget_objects, NDdelete;
from DMroot  import DMplace, give_next, set_dim_state, leader_needed;
from DMroot  import is_complex, get_dim_attr, toggle_ter_loca, init_ter_loca;
from DMroot  import chgdp, set_trak_info, get_trak_info;
from DMroot  import get_first_in_cpx, give_previous;
from DMsuper import create_dim_param;
from DMdim   import get_active_params;
from DMsglarc import set_meas_type;
from dim_plan import select_axis, draw_axis;
from DMroot  import inq_geom_type, remove_from_cpx;
from DMroot  import jogged_off, clear_jog_pts;
from DMroot import get_jog_info, get_dim_type, return_go_index;

method get_dim_param()
{
	IGRint status;

	if (me->dim_type == CENTER_LINE)
	{
		status =
		dm$get_dim_param(type = DM_SENV_PARAM, p_grid =  &me->list[DIM_ROOT_SENV]);
		dm$status(action = RET_STATUS);
	}
	else
	{
		status =
		dm$get_dim_param(type = DM_ENV_PARAM, p_grid =  &me->list[DIM_ROOT_ENV]);
		dm$status(action = RET_STATUS);

		status =
		dm$get_dim_param(type = DM_LOC_PARAM, p_grid = &me->list[DIM_ROOT_LOC]);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method get_dim_plane()
{
	IGRint status, one;
	struct GRid win_grid;
	int rc, ref_lock_state =0;
	extern GRclassid OPP_dim_plan_class_id;

	if (me->is_a_complex && me->first_dim.objid != NULL_OBJID)
	{
		status =
		om$send(msg = message NDnode.NDget_objects(
						ND_ROOT,
						&me->list[DIM_ROOT_PLAN],
						1,
						NULL,
						DIM_ROOT_PLAN,
						DIM_ROOT_PLAN,
						&one),
			targetid = me->first_dim.objid,
			targetos = me->first_dim.osnum);
		dm$status(action = RET_STATUS);
	}
	else
	{
		win_grid.objid = NULL_OBJID;

		if( GRget_model_mode() == GR_MODEL_MODE)
		{
			ems$ref_plane_lock(
				msg = &rc,
				options = EMS_REF_PLANE_LOCK_INQ,
				mode = &ref_lock_state);
			if (!(1&rc))
			{
				ref_lock_state = 0;
			}

			if (ref_lock_state & EMS_REF_PLANE_LOCK_ON)
			   ems$get_active_datum_plane(msg = &rc, 
						datpln = &win_grid);
		}

		if (win_grid.objid == NULL_OBJID)
		{
			win_grid.objid = me->ori_event.event.button.objid;
			win_grid.osnum = me->ori_event.event.button.osnum;
		}

		if ((frm_glob.dim_mode == MODELING_MODE)
		&&  (me->dim_type == RADIAL || me->dim_type == SINGLE_PARALLEL)
		&&  (DMancestry_valid(win_grid, OPP_dim_plan_class_id)))
		{
			/*
			 *  If dimension type is radial or single parallel,
			 *  the dimension is directly connected to the
			 *  reference plane instead of DMplan object. This
			 *  is made to avoid DMplan(with measurement axis set)
			 *  being connected, since it causes some problem
			 *  while copying associative graph.
			 */

			me->list[DIM_ROOT_PLAN] = win_grid;
		}
		else
		{
			status =
			dm$get_dim_plane(win_grid = win_grid,
				md_env = &me->md_env,
				p_grid = &me->list[DIM_ROOT_PLAN]);
			dm$status(action = RET_STATUS);
		}
	}

	/*^ print_grid_info("DIM PLANE", me->list[DIM_ROOT_PLAN]); */

	status =
	dm$get_plan_info(
		plan_objid = me->list[DIM_ROOT_PLAN].objid,
		osnum = me->list[DIM_ROOT_PLAN].osnum,
		md_env = &me->md_env,
		plan_info = &me->plan_info);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method wakeup(int pos)
{
	IGRint status;

	status =
	om$send(msg = message COdim.wakeup(pos),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (me->draw_axis)
	{
		status =
		om$send(msg = message COdmplace.draw_axis(GRhd),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	if (me->draw_sect)
	{
		status =
		om$send(msg = message COdmplace.draw_sect(GRhd),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	if (me->form_displayed)
	{
		status = FIf_display(me->form);
		if (status != FI_SUCCESS)
		{
			/*|FIf_display fails*/
			return(OM_E_ABORT);
		}
	}

	if ((me->dim_type == SINGLE_PARALLEL)
	||  (me->dim_type == COORDINATE)
	||  (me->dim_type == RADIAL))
	{
		ex$message(msgnumb = DM_I_StatFormAvForOpt);
                GRstatus_display_button(1);
	}

	return( OM_S_SUCCESS);
}

method super_cmd.sleep(int pos)
{
	IGRint status;

	status =
	om$send(msg = message COdim.sleep(pos),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (me->form_displayed)
	{
		status = FIf_erase(me->form);
		if (status != FI_SUCCESS)
		{
			/*|FIf_erase fails*/
			return(OM_E_ABORT);
		}
	}

	if ((me->dim_type == SINGLE_PARALLEL)
	||  (me->dim_type == COORDINATE)
	||  (me->dim_type == RADIAL))
	{
		ex$message(msgnumb = GR_I_Clear);
                GRstatus_display_button(0);
	}

	return(OM_S_SUCCESS);
}

method execute(int *response; char *response_data; int pos)
{
	IGRint status, rc, index;
	IGRlong long_rc;
	IGRint msgkey;
	IGRboolean last_in_cpx, keyin_valid;
	struct GRid next[2];
	struct EX_cmd cmdstr;
	IGRint num_jog_pts;
	IGRdouble jog_line[12];
	IGRchar string[128];

	while (TRUE)
	{
		switch (me->state)
		{
			/*********************/
			case STATE_P_LOC_ORIG:
			/*********************/

			/*|- STATE_P_LOC_ORIG */

			status =
			om$send(msg = message COdmplace.display_form(TRUE),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if ((me->event2.response == EX_SINIT) &&
				(me->dim_grid.objid != NULL_OBJID))
			{
				/*|- Erase the dimension, cmd restarted*/

				status =
				DMdisplay_dimension(
					&rc,
					ROOT | CHILDREN,
					ERASE | REMWRNG,
					&me->md_env,
					&me->dim_grid);
				dm$status(action = RET_STATUS);
			}

			me->first_dim.objid = NULL_OBJID;
			me->orthogonal = FALSE;

			status =
			om$send(msg = message COdim.locate_parent(
						response,
						response_data,
						&me->ori_event,
						TRUE,
						me->loc_key,
						me->acc_key,
						me->rel_key),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (me->locate_rc == LC_OBJ_LOCATED)
			{
				if (me->mytype == 100)
					me->state = STATE_P_LOC_MEAS2;
				else if (me->meas_needed)
					me->state = STATE_P_LOC_MEAS;
				else if (me->axis_needed)
					me->state = STATE_P_SEL_AXIS;
				else if ((me->dim_type == RADIAL) ||
				 	 (me->dim_type == COORDINATE))
					me->state = STATE_P_LOC_JOG_PT;
				else	me->state = STATE_P_POS_TEXT;
			}
			else if (*response == RESET && me->angular_dim)
			{
				me->orthogonal = TRUE;
				me->state = STATE_P_LOC_ORTH_ORIG;
			}
			else if (*response == D_RESET && me->prev_dim.objid != NULL_OBJID)
			{
				me->dim_grid = me->prev_dim;
				me->prev_dim.objid = NULL_OBJID;

				if (me->dim_type == RADIAL)
				{
					status =
					om$send(msg = message DMroot.get_jog_info(
								&rc,
								&Dim_rad_jog,
								&num_jog_pts,
								jog_line,
								&me->dyn_env),
						targetid = me->dim_grid.objid,
						targetos = me->dim_grid.osnum);
					dm$status(action = RET_STATUS);

					status =
					om$send(msg = message COdmplace.display_form(TRUE),
						targetid = my_id);
					dm$status(action = RET_STATUS);

					if (Dim_rad_jog)
					{
						if (num_jog_pts == 3)
						   me->state = STATE_P_LOC_JOG_PT2;
						else if (num_jog_pts == 2)
						   me->state = STATE_P_LOC_JOG_PT1;
						else
						   me->state = STATE_P_LOC_JOG_PT;
					}
					else if (me->leader)
					   me->state = STATE_P_LOC_JOG_PT1;
					else
					   me->state = STATE_P_LOC_JOG_PT;
				}
				else
				{
					me->state = (me->leader)?
				   	STATE_P_HOR_TEXT:STATE_P_POS_TEXT;
				}

				status =
				om$send(msg = message COdmplace.display_dimension(
								ROOT | CHILDREN,
								ERASE | REMWRNG),
					targetid = my_id);
				dm$status(action = RET_STATUS);
			}
			break;

			/*********************/
			case STATE_P_LOC_MEAS:
			/*********************/

			if (me->angular_dim)
			{
				if (me->angle_center && !me->orthogonal)
					msgkey = DM_P_LocAngCen;
				else	msgkey = DM_P_SelQuad;
			}
			else	msgkey = DM_P_SelProjLin;

			status =
			om$send(msg = message COdim.locate_parent(
							response,
							response_data,
							&me->mea_event,
							TRUE,
							DM_P_LocMeas,
							msgkey,
							DM_E_MeasNotFound),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (me->locate_rc == LC_OBJ_LOCATED)
			{
				/* - For angular dimension find
				     if angle center is required - */

				if (me->angular_dim)
				{
					if (me->angle_center && !me->orthogonal)
						me->state = STATE_P_LOC_ANGL_CENT;
					else	me->state = STATE_P_SEL_QUAD;
				}
				else	me->state = STATE_P_SEL_AXIS;
			}
			else if (*response == D_RESET)
			{
				if (me->angular_dim && me->orthogonal)
					me->state = STATE_P_SEL_AXIS;
				else	me->state = STATE_P_LOC_ORIG;
			}
			break;

			/**********************/
			case STATE_P_SEL_AXIS:
			/**********************/

			status =
			om$send(msg = message COdmplace.draw_axis(GRhd),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message COdim.getevent(
						(me->angular_dim)?
							DM_P_SelAxis:
							DM_P_SelProjLin,
						response,
						response_data,
						&me->sel_event),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message COdmplace.draw_axis(GRhe),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (*response == DATA)
			{
				status =
				om$send(msg = message COdmplace.sel_axis(),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				if (me->dim_type == COORDINATE)
					me->state = STATE_P_LOC_JOG_PT;
				else	me->state = (me->angular_dim)?
					STATE_P_LOC_MEAS:STATE_P_POS_TEXT;
			}
			else if (*response == D_RESET)
			{
				if (me->angular_dim)
					me->state = STATE_P_LOC_ORTH_ORIG;
				else if (me->meas_needed)
					me->state = STATE_P_LOC_MEAS;
				else	me->state = STATE_P_LOC_ORIG;
			}
			break;

			/*********************/
			case STATE_P_POS_TEXT:
			case STATE_P_POS_TEXT2:
			/*********************/

			status =
			om$send(msg = message COdmplace.place_dimension(),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (me->dim_type == CENTER_LINE)
				msgkey = DM_P_PtInOut;
			else	msgkey = DM_P_PosDim;

			status =
			om$send(msg = message COdmplace.position_dim(
						msgkey,
						TRUE,
						LEADER_OFF | JOGGED_OFF,
						NULL,
						MOVE_TRAK_PT | MOVE_BREAK_PT,
						NULL,
						NULL),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message COdim.getevent(
							msgkey,
							response,
							response_data,
							&me->event1),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (*response == DATA)
			{
				status =
				om$send(msg = message COdmplace.position_dim(
							NULL,
							FALSE,
							NULL,
							NULL,
							MOVE_TRAK_PT | MOVE_BREAK_PT,
							CHGDP,
							NULL),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message DMroot.leader_needed(
								&rc,
								&me->dyn_env,
								&me->leader),
					targetid = me->dim_grid.objid,
					targetos = me->dim_grid.osnum);
				dm$status(action = RET_STATUS);

				if (me->leader)
				{
					if (me->state == STATE_P_POS_TEXT)
						me->state = STATE_P_HOR_TEXT;
					else	me->state = STATE_P_HOR_TEXT2;
				}
				else
				{
				        DMupdate_active_layer_info(&long_rc,
								   &me->dim_grid,
								   NULL);
					status =
					om$send(msg = message COdmplace.display_dimension(
							ROOT | CHILDREN,
							DISPLAY | ADDWRNG),
						targetid = my_id);
					dm$status(action = RET_STATUS);

					me->prev_dim = me->dim_grid;
					me->dim_grid.objid = NULL_OBJID;

					if (me->is_a_complex)
						me->state = STATE_P_LOC_MEAS2;
					else	me->state = STATE_P_LOC_ORIG;
				}
			}
			else if (*response == D_RESET)
			{
				status =
				om$send(msg = message COdmplace.delete_dimension(),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				if (me->is_a_complex)
				{
					if (me->state == STATE_P_POS_TEXT2)
						me->state = STATE_P_LOC_MEAS2;
					else if (me->angular_dim)
						me->state = STATE_P_SEL_QUAD;
					else	me->state = STATE_P_SEL_AXIS;
				}
				else if (me->axis_needed)
					me->state = STATE_P_SEL_AXIS;
				else	me->state = STATE_P_LOC_ORIG;
			}
			break;

			/*********************/
			case STATE_P_HOR_TEXT:
			case STATE_P_HOR_TEXT2:
			/*********************/

			status =
			om$send(msg = message DMroot.give_next(
							&rc,
							&last_in_cpx,
							next),
				targetid = me->dim_grid.objid,
				targetos = me->dim_grid.osnum);
			dm$status(action = RET_STATUS);

			if (!last_in_cpx)
			{
				for (index=0; index<2; index++)
				{
					if (next[index].objid == NULL_OBJID)
						continue;

					status =
					DMdisplay_dimension(
						&rc,
						ROOT | CHILDREN,
						DISPLAY | ADDWRNG,
						&me->md_env,
						&next[index]);
					dm$status(action = RET_STATUS);
				}
			}

			status =
			om$send(msg = message NDnode.NDs_compute_node(
								&long_rc,
								0,
								&me->dyn_env),
				targetid = me->dim_grid.objid,
				targetos = me->dim_grid.osnum);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message COdmplace.position_dim(
						DM_P_PosTextBrk,
						TRUE,
						NULL,
						NULL,
						MOVE_LEADER_PT,
						NULL,
						NULL),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message COdim.getevent(
						DM_P_PosTextBrk,
						response,
						response_data,
						&me->event1),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (*response == DATA)
			{
				status =
				om$send(msg = message COdmplace.position_dim(
							NULL,
							FALSE,
							NULL,
							NULL,
							MOVE_LEADER_PT,
							CHGDP,
							NULL),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				DMupdate_active_layer_info(&long_rc,&me->dim_grid,NULL);
				status =
				om$send(msg = message COdmplace.display_dimension(
							ROOT,
							DISPLAY | ADDWRNG),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				me->prev_dim = me->dim_grid;
				me->dim_grid.objid = NULL_OBJID;

				me->state = (me->is_a_complex)?
						STATE_P_LOC_MEAS2:
						STATE_P_LOC_ORIG;
			}
			else if (*response == D_RESET)
			{
				status =
				om$send(msg = message COdmplace.set_dim_state(
							DIM_IN_PLACEMENT |
							DIM_NEEDS_UPDATE),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				if (me->state == STATE_P_HOR_TEXT)
					me->state = STATE_P_POS_TEXT;
				else	me->state = STATE_P_POS_TEXT2;
			}
			break;

			/**********************/
			case STATE_P_LOC_MEAS2:
			/**********************/

			status =
			om$send(msg = message COdim.locate_parent(
							response,
							response_data,
							&me->mea_event,
							TRUE,
							DM_P_LocMeas,
							DM_P_LocMeas,
							DM_E_MeasNotFound),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (me->locate_rc == LC_OBJ_LOCATED)
			{
				if (me->dim_type == COORDINATE)
					me->state = STATE_P_LOC_JOG_PT;
				else	me->state = STATE_P_POS_TEXT2;
			}
			else if (*response == RESET)
			{
				if ((me->mytype == 100)
				&&  (me->dim_type == COORDINATE))
				{
					/*|- Erase the form*/

					if (me->form_displayed)
					{
						/*|- Erase the form*/

						status = FIf_erase(me->form);
						if (status != FI_SUCCESS)
						{
							/*|FIf_delete fails*/
							return(OM_E_ABORT);
						}

						me->form_displayed = FALSE;
					}
				}

				me->state = STATE_P_LOC_ORIG;
			}
			else if (*response == D_RESET)
			{
				status =
				om$send(msg = message COdmplace.delete_dimension(),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				if (me->prev_dim.objid == NULL_OBJID)
					break;

				me->dim_grid = me->prev_dim;
				me->prev_dim.objid = NULL_OBJID;

				status =
				om$send(msg = message COdmplace.display_dimension(
							ROOT | CHILDREN,
							ERASE | REMWRNG),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message DMroot.leader_needed(
								&rc,
								&me->dyn_env,
								&me->leader),
					targetid = me->dim_grid.objid,
					targetos = me->dim_grid.osnum);
				dm$status(action = RET_STATUS);

				if (me->dim_type == COORDINATE)
				{
					status =
					om$send(msg = message DMroot.get_jog_info(
								&rc,
								&Dim_coord_jog,
								&num_jog_pts,
								jog_line,
								&me->dyn_env),
						targetid = me->dim_grid.objid,
						targetos = me->dim_grid.osnum);
					dm$status(action = RET_STATUS);

					status =
					om$send(msg = message COdmplace.display_form(TRUE),
						targetid = my_id);
					dm$status(action = RET_STATUS);

					if (Dim_coord_jog)
					{
						if (num_jog_pts == 3)
						   me->state = STATE_P_LOC_JOG_PT2;
						else if (num_jog_pts == 2)
						   me->state = STATE_P_LOC_JOG_PT1;
						else
						   me->state = STATE_P_LOC_JOG_PT;
					}
					else if (me->leader)
					   me->state = STATE_P_LOC_JOG_PT1;
					else
					   me->state = STATE_P_LOC_JOG_PT;
				}
				else
				{
					me->state = (me->leader)?
				   	STATE_P_HOR_TEXT2:STATE_P_POS_TEXT2;
				}
			}
			break;

			/*************************/
			case STATE_P_LOC_ORTH_ORIG:
			/*************************/

			status =
			om$send(msg = message COdim.locate_parent(
							response,
							response_data,
							&me->ori_event,
							TRUE,
							DM_P_LocAxes,
							DM_P_SelAxis,
							DM_E_EltNotFound),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (me->locate_rc == LC_OBJ_LOCATED)
				me->state = STATE_P_SEL_AXIS;
			else if (*response == D_RESET)
				me->state = STATE_P_LOC_ORIG;
			break;

			/*********************/
			case STATE_P_SEL_QUAD:
			/*********************/

			status =
			om$send(msg = message COdmplace.draw_sect(GRhd),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message COdim.getevent(
						DM_P_SelQuad,
						response,
						response_data,
						&me->sel_quad),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message COdmplace.draw_sect(GRhe),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (*response == DATA)
			{
				status =
				om$send(msg = message COdmplace.sel_sector(),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				me->state = STATE_P_POS_TEXT;
			}
			else if (*response == D_RESET)
			{
				if (me->angle_center && !me->orthogonal)
					me->state = STATE_P_LOC_ANGL_CENT;
				else	me->state = STATE_P_LOC_MEAS;
			}
			break;

			/*************************/
			case STATE_P_LOC_ANGL_CENT:
			/*************************/

			status =
			om$send(msg = message COdim.locate_parent(
							response,
							response_data,
							&me->cent_event,
							TRUE,
							DM_P_LocAngCen,
							DM_P_SelQuad,
							DM_E_EltNotFound),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (me->locate_rc == LC_OBJ_LOCATED)
				me->state = STATE_P_SEL_QUAD;
			else  if (*response == D_RESET)
				me->state = STATE_P_LOC_MEAS;
			break;

			/**********************/
			case STATE_P_LOC_JOG_PT:
			/**********************/

			/*|- STATE_P_LOC_JOG_PT*/
			/*"Dim_rad_jog = %d\n", Dim_rad_jog*/
			/*"Dim_coord_jog = %d\n", Dim_coord_jog*/

			status =
			om$send(msg = message COdmplace.display_form(TRUE),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message COdmplace.place_dimension(),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (Dim_rad_jog || Dim_coord_jog)
			{
				if (me->dim_type == RADIAL)
					msgkey = DM_P_PosBrkPt;
				else	msgkey = DM_P_EnFBrkPt;
			}
			else	msgkey = DM_P_PosDim;

			status =
			om$send(msg = message COdmplace.position_dim(
						msgkey,
						TRUE,
						LEADER_OFF,
						NULL,
						MOVE_JOG_TRAK_PT | MOVE_BREAK_PT,
						NULL,
						NULL),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message COdim.getevent(
						msgkey,
						response,
						response_data,
						&me->event1),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (*response == DATA)
			{
				status =
				om$send(msg = message COdmplace.position_dim(
							NULL,
							FALSE,
							CLEAR_JOG_PTS,
							NULL,
							MOVE_JOG_TRAK_PT | MOVE_BREAK_PT,
							CHGDP,
							NULL),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message DMroot.leader_needed(
								&rc,
								&me->dyn_env,
								&me->leader),
					targetid = me->dim_grid.objid,
					targetos = me->dim_grid.osnum);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message DMroot.get_jog_info(
							&rc,
							&me->jogged,
							NULL,
							NULL,
							&me->dyn_env),
					targetid = me->dim_grid.objid,
					targetos = me->dim_grid.osnum);
				dm$status(action = RET_STATUS);

				if (me->leader || me->jogged)
				   me->state = STATE_P_LOC_JOG_PT1;
				else
				{
					status =
					om$send(msg = message DMroot.give_next(
								&rc,
								&last_in_cpx,
								next),
							targetid = me->dim_grid.objid,
							targetos = me->dim_grid.osnum);
					dm$status(action = RET_STATUS);

					if (!last_in_cpx)
					{
						for (index=0; index<2; index++)
						{
						  if (next[index].objid == NULL_OBJID)
							continue;

						  status =
						  om$send(msg = message NDnode.NDs_compute_node(
								&long_rc,
								0,
								&me->dyn_env),
							targetid = next[index].objid,
							targetos = next[index].osnum);
						  dm$status(action = RET_STATUS);
/*** Fix for TR11930196 - this is not necessary as it is added to R tree in
                          the display_dimension call below 
						  status =
						  DMdisplay_dimension(
								&rc,
								ROOT | CHILDREN,
								DISPLAY | ADDWRNG,
								&me->md_env,
								&next[index]);
						  dm$status(action = RET_STATUS);
*************/
						 }
					}

				        DMupdate_active_layer_info(&long_rc,
								   &me->dim_grid,
								   NULL);
					status =
					om$send(msg = message COdmplace.display_dimension(
								ROOT | CHILDREN,
								DISPLAY | ADDWRNG),
						targetid = my_id);
					dm$status(action = RET_STATUS);

					me->prev_dim = me->dim_grid;
					me->dim_grid.objid = NULL_OBJID;
	
					if (me->is_a_complex)
						me->state = STATE_P_LOC_MEAS2;
					else	me->state = STATE_P_LOC_ORIG;
				}
			}
			else if (*response == D_RESET)
			{
				if (me->is_a_complex)
				{
					if (me->dim_grid.objid
					== me->first_dim.objid)
						me->state = STATE_P_LOC_ORIG;
					else	me->state = STATE_P_LOC_MEAS2;
				}
				else	me->state = STATE_P_LOC_ORIG;

				status =
				om$send(msg = message COdmplace.delete_dimension(),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				me->dim_grid.objid = NULL_OBJID;
			}
			break;

			/**********************/
			case STATE_P_LOC_JOG_PT1:
			/**********************/

			status =
			om$send(msg = message COdmplace.display_form(TRUE),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (me->dim_type == RADIAL)
			{
				if (me->leader)
					msgkey = DM_P_PosTextBrk;
				else	msgkey = DM_P_PosBrkPtMd;
			}
			else
			{
				msgkey = DM_P_EnSBrkPt;
			}

			status =
			om$send(msg = message DMroot.give_next(
							&rc,
							&last_in_cpx,
							next),
				targetid = me->dim_grid.objid,
				targetos = me->dim_grid.osnum);
			dm$status(action = RET_STATUS);

			if (!last_in_cpx)
			{
				for (index=0; index<2; index++)
				{
					if (next[index].objid == NULL_OBJID)
						continue;

					status =
					om$send(msg = message NDnode.NDs_compute_node(
							&long_rc,
							0,
							&me->md_env),
							targetid = next[index].objid,
							targetos = next[index].osnum);
					dm$status(action = RET_STATUS);

					status =
					DMdisplay_dimension(
						&rc,
						ROOT | CHILDREN,
						DISPLAY,
						&me->md_env,
						&next[index]);
					dm$status(action = RET_STATUS);
				}
			}
	
			status =
			om$send(msg = message NDnode.NDs_compute_node(
							&long_rc,
							0,
							&me->dyn_env),
				targetid = me->dim_grid.objid,
				targetos = me->dim_grid.osnum);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message COdmplace.position_dim(
						msgkey,
						TRUE,
						NULL,
						NULL,
						MOVE_JOG_LEADER_PT,
						NULL,
						NULL),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message COdim.getevent(
						msgkey,
						response,
						response_data,
						&me->event1),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (*response == DATA)
			{
				status =
				om$send(msg = message COdmplace.position_dim(
							NULL,
							FALSE,
							NULL,
							NULL,
							MOVE_JOG_LEADER_PT,
							CHGDP,
							NULL),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				if (me->leader)
				{
					status =
					om$send(msg = message COdmplace.display_dimension(
							ROOT,
							DISPLAY | ADDWRNG),
					targetid = my_id);
					dm$status(action = RET_STATUS);

				        DMupdate_active_layer_info(&long_rc,
								   &me->dim_grid,
								   NULL);

					me->prev_dim = me->dim_grid;
					me->dim_grid.objid = NULL_OBJID;

					me->state = STATE_P_LOC_ORIG;
				}
				else	me->state = STATE_P_LOC_JOG_PT2;
			}
			else if ((*response == RESET) &&
				 (me->dim_type == RADIAL))
			{
				status =
				om$send(msg = message DMroot.clear_jog_pts(CLEAR_JOG_PTS),
					targetid = me->dim_grid.objid,
					targetos = me->dim_grid.osnum);
				dm$status(action = RET_STATUS);
					
				status =
				om$send(msg = message NDnode.NDs_compute_node(
								&long_rc,
								0,
								&me->dyn_env),
					targetid = me->dim_grid.objid,
					targetos = me->dim_grid.osnum);
				dm$status(action = RET_STATUS);

				DMupdate_active_layer_info(&long_rc,
							   &me->dim_grid,
							   NULL);
				status =
				om$send(msg = message COdmplace.display_dimension(
							ROOT,
							DISPLAY | ADDWRNG),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				me->prev_dim = me->dim_grid;
				me->dim_grid.objid = NULL_OBJID;

				me->state = STATE_P_LOC_ORIG;
			}
			else if (*response == D_RESET)
			{
				status =
				om$send(msg = message DMroot.clear_jog_pts(CLEAR_JOG_PTS),
					targetid = me->dim_grid.objid,
					targetos = me->dim_grid.osnum);
				dm$status(action = RET_STATUS);
					
				me->state = STATE_P_LOC_JOG_PT;
			}
			break;

			/**********************/
			case STATE_P_LOC_JOG_PT2:
			/**********************/

			status =
			om$send(msg = message COdmplace.display_form(TRUE),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (me->dim_type == RADIAL)
				msgkey = DM_P_PosCenPtMd;
			else	msgkey = DM_P_PosDim;

			status =
			om$send(msg = message COdmplace.position_dim(
						msgkey,
						TRUE,
						NULL,
						NULL,
						MOVE_JOG_PT2,
						NULL,
						NULL),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message COdim.getevent(
						msgkey,
						response,
						response_data,
						&me->event1),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (*response == DATA)
			{
				status =
				om$send(msg = message COdmplace.position_dim(
							NULL,
							FALSE,
							NULL,
							NULL,
							MOVE_JOG_PT2,
							CHGDP,
							NULL),
					targetid = my_id);
				dm$status(action = RET_STATUS);
	
				DMupdate_active_layer_info(&long_rc,
							&me->dim_grid,
							NULL);
				status =
				om$send(msg = message COdmplace.display_dimension(
							ROOT | CHILDREN,
							DISPLAY | ADDWRNG),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				me->prev_dim = me->dim_grid;
				me->dim_grid.objid = NULL_OBJID;

				me->state = (me->is_a_complex)?
				STATE_P_LOC_MEAS2:STATE_P_LOC_ORIG;
			}
			else if ((*response == RESET) &&
				 (me->dim_type == RADIAL))
			{
				status =
				om$send(msg = message DMroot.clear_jog_pts(CLEAR_JOG_PT2),
					targetid = me->dim_grid.objid,
					targetos = me->dim_grid.osnum);
				dm$status(action = RET_STATUS);
					
				status =
				om$send(msg = message NDnode.NDs_compute_node(
								&long_rc,
								0,
								&me->dyn_env),
					targetid = me->dim_grid.objid,
					targetos = me->dim_grid.osnum);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message COdmplace.display_dimension(
							ROOT,
							DISPLAY | ADDWRNG),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				me->prev_dim = me->dim_grid;
				me->dim_grid.objid = NULL_OBJID;

				me->state = STATE_P_LOC_ORIG;
			}
			else if (*response == D_RESET)
			{
				status =
				om$send(msg = message DMroot.clear_jog_pts(CLEAR_JOG_PT2),
					targetid = me->dim_grid.objid,
					targetos = me->dim_grid.osnum);
				dm$status(action = RET_STATUS);
					
				me->state = STATE_P_LOC_JOG_PT1;
			}
			break;

			/******/
			default:
			/******/

			printf("COdmplace: Unknown state %d\n", me->state);
			*response = TERMINATE;
			return(OM_S_SUCCESS);
		}

		switch (*response)
		{
			case DATA:
			case RESET:
			case D_RESET:
			case MOVE_ON:

			break;

			case STATUS_DISP:

			if ((me->dim_type == SINGLE_PARALLEL)
			||  (me->dim_type == RADIAL)
			||  (me->dim_type == COORDINATE))
			{
				status =
				om$send(msg = message COdmplace.display_form(FALSE),
					targetid = my_id);
				dm$status(action = RET_STATUS);
			}
			break;

			case STRING:
			case CMD_STRING:
			case EX_CMD_KEY:
			

			/*|- String Entered*/

			/*"dim_type = %d, me->state = %d\n", me->dim_type, me->state*/

			if (((me->dim_type == RADIAL)
			||  (me->dim_type == COORDINATE))
			&&  ((me->state == STATE_P_LOC_ORIG)
			||   (me->state == STATE_P_LOC_MEAS2)
			||   (me->state == STATE_P_SEL_AXIS)
			||   (me->state == STATE_P_LOC_JOG_PT)))
			{
				keyin_valid = FALSE;

				strcpy(string, response_data);
				DMupper_to_lower(string);

				/*"response_data = <%s>\n", response_data*/

				if (DMstrequ(string, "jogged"))
				{
					keyin_valid = TRUE;
					if (me->dim_type == RADIAL)
						Dim_rad_jog = TRUE;
					else	Dim_coord_jog = TRUE;
				}

				if (DMstrequ(string, "standard"))
				{
					keyin_valid = TRUE;
					if (me->dim_type == RADIAL)
						Dim_rad_jog = FALSE;
					else	Dim_coord_jog = FALSE;
				}

				if (keyin_valid)
				{
					status =
					om$send(msg = message COdmplace.display_form(TRUE),
						targetid = my_id);
					dm$status(action = RET_STATUS);

					break;
				}
			}

			if (me->dim_grid.objid != NULL_OBJID)
			{
				status =
				ex$get_cmd_info(
					string = response_data,
					mode = (*response == EX_CMD_KEY)?
							EX_CMD_KEY:EX_STRING,
					cmdstr = &cmdstr);
				if (!status
				|| strcmp(cmdstr.command_key, "DMTgTr"))
					return(OM_S_SUCCESS);

				status =
				om$send(msg = message DMroot.toggle_ter_loca(
								&rc, NULL),
					targetid = me->dim_grid.objid,
					targetos = me->dim_grid.osnum);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message COdmplace.set_dim_state(
							DIM_IN_PLACEMENT |
							DIM_NEEDS_UPDATE),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				break;
			}

			return(OM_S_SUCCESS);

			default:
			return(OM_S_SUCCESS);
		}
	}
}

method set_ter_loca()
{
	IGRint status;
	struct DMenv_param par_env;
	struct DMloc_param par_loc;
	struct DMmisc_param par_misc;

	if (me->dim_type == CENTER_LINE) return(OM_S_SUCCESS);

	dm$get_dim_param(type = DM_ENV_PARAM, p_data = (char *) &par_env);
	dm$get_dim_param(type = DM_LOC_PARAM, p_data = (char *) &par_loc);
	dm$get_dim_param(type = DM_MISC_PARAM, p_data = (char *) &par_misc);

	status =
	om$send(msg = message DMroot.init_ter_loca(par_misc.ter_limit_r *
						   par_env.txt_heig),
		targetid = me->dim_grid.objid,
		targetos = me->dim_grid.osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method LC_preproc(IGRint *msg; struct GRlc_info *lc_info)
{
	IGRint status;
	struct dim_attr dim_attr;

	me->event1.located_object[0] = *lc_info;

	switch (me->state)
	{
		/*********************/
		case STATE_P_LOC_ORIG:
		/*********************/

		me->ori_event = me->event1;

		if (me->mytype == 100)
		{
			status =
			om$send(msg = message DMroot.get_dim_attr((char *)&dim_attr),
				targetid = lc_info->located_obj.objid,
				targetos = lc_info->located_obj.osnum);
			dm$status(action = RET_STATUS);

			/*- axis is already defined for this group*/

			if (me->dim_type == COORDINATE)
			{
				if (dim_attr.mea_trak & DM_MEA_AXIS)
					me->axis_sel = 1;
				else	me->axis_sel = 0;
			}

			me->axis_needed = FALSE;
		}

		if (!me->angular_dim || me->mytype == 100)
		{
			status =
			om$send(msg = message COdmplace.create_origin(),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}

		break;

		/**************************/
		case STATE_P_LOC_ORTH_ORIG:
		/**************************/

		me->ori_event = me->event1;
		break;

		/*********************/
		case STATE_P_LOC_MEAS:
		/*********************/

		me->mea_event = me->event1;

		if (me->angular_dim)
		{
			status =
			om$send(msg = message COdmplace.check_for_angcen(),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (me->angle_center && !me->orthogonal)
			{
				ex$message(
					msgnumb = DM_P_LocAngCen,
					buff = me->acc_prompt);

				*msg = DIM_S_SUCCESS;
				return(OM_S_SUCCESS);
			}

			ex$message(msgnumb = DM_P_SelQuad,
				   buff = me->acc_prompt);

			status =
			om$send(msg = message COdmplace.create_origin(),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
		else
		{
			ex$message(msgnumb = DM_P_SelProjLin,
				   buff = me->acc_prompt);
		}

		status =
		om$send(msg = message COdmplace.create_measure(),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		break;

		/**********************/
		case STATE_P_LOC_MEAS2:
		/*********************/

		me->mea_event = me->event1;

		status =
		om$send(msg = message COdmplace.create_measure(),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		break;

		/**************************/
		case STATE_P_LOC_ANGL_CENT:
		/**************************/

		me->cent_event = me->event1;

		status =
		om$send(msg = message COdmplace.create_origin(),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message COdmplace.create_measure(),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		break;

		default: break;
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method LC_postproc()
{
	IGRint status;
	IGRint delete;

	/*^
		printf("event1.response=%d\n", me->event1.response);
		printf("event2.response=%d\n", me->event2.response);
	*/

	delete = FALSE;

	if (me->event2.response == RESET ||
	    me->event2.response == D_RESET)
	{
		if (me->is_a_complex)
			delete = (me->state == STATE_P_LOC_MEAS2);
		else if (!me->meas_needed && !me->axis_needed)
			delete = (me->state == STATE_P_LOC_ORIG);
	}

	if (delete)
	{
		/*|Deleting dimension*/

		status =
		om$send(msg = message COdmplace.delete_dimension(),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method LC_dynamics(
	IGRint *msg;
	struct GRid *obj;
	struct GRevent *event)
{
	IGRint status, msgkey;

	*msg = DIM_S_SUCCESS;

	if (me->event1.subtype != GRst_REGULAR)
	{
		/*"event1.subtype = %d\n", me->event1.subtype */
		return(OM_S_SUCCESS);
	}

	/*^
		printf("event1.response=%d\n", me->event1.response);
		printf("event2.response=%d\n", me->event2.response);
		printf("event1.point=%lf, %lf, %lf\n",
			me->event1.event.button.x,
			me->event1.event.button.y,
			me->event1.event.button.z);
		printf("event1.grid=%d, %d\n",
			me->event1.located_object[0].located_obj.objid,
			me->event1.located_object[0].located_obj.osnum);
		print_grid("obj", obj);
	*/

	switch (me->state)
	{
		/*********************/
		case STATE_P_LOC_ORIG:
		/*********************/

		/*|STATE_P_LOC_ORIG*/

		if (!me->meas_needed && (me->mytype != 100))
		{
			/*|meas NOT needed*/

			if (me->axis_needed)
			{
				/*|axis_needed*/

				status =
				om$send(msg = message COdmplace.draw_axis(GRhd),
					targetid = my_id);
				dm$status(action = RET_STATUS);
			}
			else
			{
				/*|axis NOT needed*/

				status =
				om$send(msg = message COdmplace.place_dimension(),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				if (Dim_rad_jog || Dim_coord_jog)
				{
					msgkey = (me->dim_type == RADIAL)?
					DM_P_PosBrkPt:DM_P_EnFBrkPt;
				}
				else	msgkey = DM_P_PosDim;

				status =
				om$send(msg = message COdmplace.position_dim(
							msgkey,
							TRUE,
							LEADER_OFF | JOGGED_OFF,
							NULL,
							MOVE_JOG_TRAK_PT | MOVE_BREAK_PT,
							NULL,
							NULL),
					targetid = my_id);
				dm$status(action = RET_STATUS);
			}
		}

		return(OM_S_SUCCESS);

		/**************************/
		case STATE_P_LOC_ORTH_ORIG:
		/**************************/

		status =
		om$send(msg = message COdmplace.draw_axis(GRhd),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		return(OM_S_SUCCESS);

		/*********************/
		case STATE_P_LOC_MEAS:
		/*********************/

		/*|STATE_P_LOC_MEAS*/

		if (me->angular_dim)
		{
			if (me->orthogonal || !me->angle_center)
			{
				status =
				om$send(msg = message COdmplace.draw_sect(GRhd),
					targetid = my_id);
				dm$status(action = RET_STATUS);
			}
		}
		else
		{
			status =
			om$send(msg = message COdmplace.draw_axis(GRhd),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}

		return(OM_S_SUCCESS);

		/**************************/
		case STATE_P_LOC_ANGL_CENT:
		/**************************/

		/*|STATE_P_LOC_ANGL_CENT*/

		status =
		om$send(msg = message COdmplace.draw_sect(GRhd),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		break;

		/**********************/
		case STATE_P_LOC_MEAS2:
		/**********************/

		/*|STATE_P_LOC_MEAS2*/

		status =
		om$send(msg = message COdmplace.place_dimension(),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if (Dim_rad_jog || Dim_coord_jog)
			msgkey = DM_P_EnFBrkPt;
		else	msgkey = DM_P_PosDim;

		status =
		om$send(msg = message COdmplace.position_dim(
						msgkey,
						TRUE,
						LEADER_OFF | JOGGED_OFF,
						NULL,
						MOVE_JOG_TRAK_PT | MOVE_BREAK_PT,
						NULL,
						NULL),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		return(OM_S_SUCCESS);
	}

	return(OM_S_SUCCESS);
}

method draw_axis(enum GRdpmode mode)
{
	IGRint status, rc;
	struct GRevent *draw_event;

	if (!me->axis_needed)
		return(OM_S_SUCCESS);

	if (mode == GRhe)
	{
		dp$erase_hilite(msg = &rc);
		me->draw_axis = FALSE;
		return(OM_S_SUCCESS);
	}

	status =
	om$send(msg = message COdmplace.get_dim_plane(),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	me->draw_axis = TRUE;
	draw_event = (!me->meas_needed || me->angular_dim)?
					&me->ori_event:&me->mea_event;

	status =
	om$send(msg = message dim_plan.draw_axis(&rc, &draw_event->event.button.x),
		targetid = me->list[DIM_ROOT_PLAN].objid,
		targetos = me->list[DIM_ROOT_PLAN].osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method sel_axis()
{
	IGRint status, rc;
	IGRdouble *origin, *selpt;
	struct GRevent *draw_event;

	draw_event = (!me->meas_needed || me->angular_dim)?
			&me->ori_event:&me->mea_event;
	origin = &draw_event->event.button.x;
	selpt  = &me->sel_event.event.button.x;

	status =
	om$send(msg = message dim_plan.select_axis(
					&rc,
					origin,
					selpt,
					&me->axis_sel),
		targetid = me->list[DIM_ROOT_PLAN].objid,
		targetos = me->list[DIM_ROOT_PLAN].osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method draw_sect(enum GRdpmode mode)
{
	IGRint status, rc, i;
	IGRlong long_rc;
	struct IGRdisplay   display;
	struct DPele_header buffer[2];
	struct IGRpolyline  line1, line2;
	IGRdouble pt_buffer[12];
	struct ret_struct retst[2];
	#define BIGNUM 1e5

    struct GRmd_env rfenv;
    IGRboolean aflag = 0;

	if (mode == GRhe)
	{
		dp$erase_hilite(msg = &rc);
		me->draw_sect = FALSE;
		return(OM_S_SUCCESS);
	}

	me->draw_sect = TRUE;

	if (!me->orthogonal)
	{
		status =
		om$send(msg = message COdmplace.get_dim_plane(),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	/* - Set the display  attributes */

	display.color     = 0;
	display.weight    = 0;
	display.style     = 1;

    if(aflag = pwIsActivationOn())
     {
      pwGetActiveModuleEnv(&rfenv);
	  status = 
	  om$send(msg = message NDnode.NDgive_structure(
						&long_rc,
						&retst[0],
						&rfenv),
		targetid = me->list[me->ori_index].objid,
		targetos = me->list[me->ori_index].osnum);
	  dm$status (action = RET_STATUS);

	  status = 
	  om$send(msg = message NDnode.NDgive_structure(
						&long_rc,
						&retst[1],
						&rfenv),
		targetid = me->list[me->mea_index].objid,
		targetos = me->list[me->mea_index].osnum);
	  dm$status (action = RET_STATUS);
     }
    else
     {
	  status = 
	  om$send(msg = message NDnode.NDgive_structure(
						&long_rc,
						&retst[0],
						&me->md_env),
		targetid = me->list[me->ori_index].objid,
		targetos = me->list[me->ori_index].osnum);
	  dm$status (action = RET_STATUS);

	  status = 
	  om$send(msg = message NDnode.NDgive_structure(
						&long_rc,
						&retst[1],
						&me->md_env),
		targetid = me->list[me->mea_index].objid,
		targetos = me->list[me->mea_index].osnum);
	  dm$status (action = RET_STATUS);
     }

	/* - Compute the two axis end points */

	line1.num_points	= 2;
	line1.points		= &pt_buffer[0];

	line2.num_points	= 2;
	line2.points		= &pt_buffer[6];

	for (i=0; i<3; i++)
   	{
		pt_buffer[i]	= retst[0].var.line_st.p0[i]
				  - BIGNUM*retst[0].var.line_st.v0[i];

		pt_buffer[i+3]	= retst[0].var.line_st.p1[i]
				  + BIGNUM*retst[0].var.line_st.v0[i];

		pt_buffer[i+6]	= retst[1].var.line_st.p0[i]
				  - BIGNUM*retst[1].var.line_st.v0[i];

		pt_buffer[i+9]	= retst[1].var.line_st.p1[i]
				  + BIGNUM*retst[1].var.line_st.v0[i];
        }	

	/* - Build the display buffer of the two lines */

	dp$build_dis_buffer(
		buffer = &buffer[0],
		type = IGRPY,
		display_att = &display,
		geometry = &line1);

	dp$build_dis_buffer(
		buffer = &buffer[1],
		type = IGRPY,
		display_att = &display,
		geometry = &line2);

	dp$display(msg = &rc, mode = GRhd, num_elem = 2, buffer = buffer);

	return(OM_S_SUCCESS);

}

method sel_sector()
{
	IGRint status, rc;
	IGRlong long_rc;
	IGRdouble *line1, *line2;
	IGRdouble *selpt;
	struct ret_struct retst[2];

   IGRshort dim=4,invmxtyp=MAIDMX;
   IGRlong one=1;
   IGRmatrix invmx;
   IGRpoint tmppt;
   BSrc rc2;
   struct GRmd_env rfenv;
   IGRboolean aflag = 0;

	status =
	om$send(msg = message NDnode.NDgive_structure(
						&long_rc,
						&retst[0],
						&me->md_env),
		targetid = me->list[me->ori_index].objid,
		targetos = me->list[me->ori_index].osnum);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message NDnode.NDgive_structure(
						&long_rc,
						&retst[1],
						&me->md_env),
		targetid = me->list[me->mea_index].objid,
		targetos = me->list[me->mea_index].osnum);
	dm$status(action = RET_STATUS);

	line1 = retst[0].var.line_st.p0;
	line2 = retst[1].var.line_st.p0;
	selpt = &me->sel_quad.event.button.x;

    if(aflag = pwIsActivationOn())
    {
     pwGetActiveModuleEnv(&rfenv);

     if(rfenv.md_env.matrix_type != MAIDMX)
     {
      MAinvmx( &rc2, &dim, rfenv.md_env.matrix, invmx);
      MAtypemx( &rc2, invmx, &invmxtyp);

      MAoptsxform( &rc2, &one, &invmxtyp, invmx, selpt, tmppt);
      memcpy(selpt, tmppt, sizeof(IGRvector));
     }
    } 

	status =
	DMselect_sector(
	 	&rc,
		line1,
		line2,
		selpt,
		&me->plan_info,
		&me->dim_attr.trak_dist,
		&me->sect_sel);

	/*^
		print_line("line1", line1);
		print_line("line2", line2);
		print_point("selpt", selpt);
		printf("sect_sel=%ld\n", me->sect_sel);
	*/

	return(OM_S_SUCCESS);
}

method LC_selection(IGRint *msg; struct GRlc_info *lc_info)
{
	IGRint status, comp_type, rc;
	IGRshort edge_view, dim_type;
	IGRlong long_rc;
	IGRchar geom_type;
	struct IGRbsp_curve *bsp_curve;
	extern GRclassid OPP_GRbspline_class_id,
			 OPP_GR3dcirarc_class_id,
			 OPP_GRpoint_class_id,
			 OPP_DMcenline_class_id,
			 OPP_DMradjog_class_id,
			 OPP_EMSdatpln_class_id,
			 OPP_GRgencs_class_id,
			 OPP_SKgmhndlpt_class_id;
	struct GRid owner;

	/*^ print_grid_info("located obj", lc_info->located_obj); */

	if (me->mytype == 100 && me->state == STATE_P_LOC_ORIG)
	{
		/*| Add measurement to group - Locate complexes only */

		if (DMancestry_valid(lc_info->located_obj, OPP_DMroot_class_id))
		{
			status =
			om$send(msg = message DMroot.is_complex(msg),
				targetid = lc_info->located_obj.objid,
				targetos = lc_info->located_obj.osnum);
			dm$status(action = RET_STATUS);

			if (*msg)
			{
			   status =
			   om$send(msg = message DMroot.inq_geom_type(&geom_type),
				targetid = lc_info->located_obj.objid,
				targetos = lc_info->located_obj.osnum);
			   dm$status(action = RET_STATUS);

			   if (geom_type & DIM_IMPORTED)
			   {
				*msg = FALSE;
				ex$message(msgnumb = DM_I_CannotAddToRetDimGrp);
				return(OM_S_SUCCESS);
			   }

			   status =
			   om$send(msg = message DMroot.get_dim_type(&dim_type),
				targetid = lc_info->located_obj.objid,
				targetos = lc_info->located_obj.osnum);
			   dm$status(action = RET_STATUS);

			   me->dim_type = dim_type;

			   status =
			   om$send(msg = message COdmplace.init_type(),
				targetid = my_id);
			   dm$status(action = RET_STATUS);
			}
		}
		else	*msg = FALSE;

		return(OM_S_SUCCESS);
	}

	*msg = DMancestry_valid(lc_info->located_obj, OPP_GRgencs_class_id);
	if (*msg && me->sel_type == POINT_TYPE)
	{
		/*"Coordinate system located, create DMsrc of DMkeypt\n"*/

		*msg = TRUE;
		return(OM_S_SUCCESS);
	}
	else	*msg = FALSE;

	*msg = DMancestry_valid(lc_info->located_obj, OPP_GRbspline_class_id);
	if (!(*msg))
	{
		/*| Not a graphic element */
		return(OM_S_SUCCESS);
	}

	if (DMancestry_valid(lc_info->located_obj, OPP_SKgmhndlpt_class_id))
	{
		/*|- Geometric Constraint handle */
		*msg = FALSE;
		return(OM_S_SUCCESS);
	}

	/* -
		Avoid locating any graphic component of
		a dimension in the same complex to avoid problems
	- */

	status =
        om$get_objid_at_index(
		objid = lc_info->located_obj.objid,
		osnum = lc_info->located_obj.osnum,
		index = 0,
		p_chanselect = &AS_to_owner,
		objidaddr = &owner.objid,
		osnumaddr = &owner.osnum);
	if (status == OM_S_SUCCESS)
	{
		if (DMancestry_valid(owner, OPP_DMradjog_class_id))
		{
			/*|- Locating a radial dim, check for component*/

			status =
			om$send(msg = message DMroot.return_go_index(
							&rc,
							lc_info->located_obj,
							&comp_type),
				targetid = owner.objid,
				targetos = owner.osnum);
			dm$status(action = RET_STATUS);

			if (comp_type == DIM_LINE3
			||  comp_type == DIM_LINE4)
				*msg = TRUE;
			else	*msg = FALSE;

			if (me->mytype > STRINGED_ANGULAR)
				*msg = FALSE;
		
			return(OM_S_SUCCESS);
		}

		if ((DMancestry_valid(owner, OPP_DMroot_class_id))
		&&  !(DMancestry_valid(owner, OPP_DMcenline_class_id)))
		{
			*msg = FALSE;
			return(OM_S_SUCCESS);
		}

		if (DMancestry_valid(owner, OPP_EMSdatpln_class_id))
		{
#ifdef DEBUG
			printf("datum plan located\n ");
#endif
			*msg = FALSE;
			return(OM_S_SUCCESS);
		}
	}

	/*|- Check if dimensioning to edgeview - */

	if ((me->state == STATE_P_LOC_ORIG)
	||  (me->state == STATE_P_LOC_ORTH_ORIG))
		me->ori_event = me->event1;

	status =
	om$send(msg = message COdmplace.get_dim_plane(),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	DMcheck_edge_view(
		lc_info->located_obj,
		me->list[DIM_ROOT_PLAN],
		&lc_info->module_info,
		&edge_view);
	dm$status(action = RET_STATUS);

	if (me->mytype == SINGLE_PARALLEL
	&&  DMancestry_valid(lc_info->located_obj, OPP_GR3dcirarc_class_id))
	{
		/*| - Circular arc for single parallel - */

		*msg = TRUE;
		me->sgl_type = (edge_view)?SINGLE_PARALLEL:GL_sgl_type;
	}
	else if (me->sel_type == LINE_TYPE || me->sel_type == ARC_TYPE)
	{
		status =
		om$send(msg = message GRvg.GRgenabsg(
				&long_rc,
				&lc_info->module_info.md_env.matrix_type,
				lc_info->module_info.md_env.matrix,
				(char **)&bsp_curve),
			targetid = lc_info->located_obj.objid,
			targetos = lc_info->located_obj.osnum);
		dm$status(action = RET_STATUS);

		/*"order=%d, nump=%d\n", bsp_curve->order, bsp_curve->num_poles*/

		if (me->sel_type == LINE_TYPE)
		{
			/* - Linear element is required for single
			     parallel dimension - */

			if (DMancestry_valid(lc_info->located_obj, OPP_GRpoint_class_id))
				*msg = FALSE;
			else if (edge_view)
				*msg = TRUE;
			else *msg = (bsp_curve->order == 2 &&
					bsp_curve->num_poles >= 2);

			me->sgl_type = SINGLE_PARALLEL;
		}
		else
		{
			/* - Curve with more than three poles is
			     required for measuring radius - */

			*msg = (!edge_view) && (bsp_curve->num_poles >= 3);
		}
	}

	/*"selection=%d\n", *msg*/

	return(OM_S_SUCCESS);
}

method position_dim(
	IGRint msgkey;
	IGRint dynamics;
	IGRint preproc;
	IGRint prestate;
	IGRint control;
	IGRint postproc;
	IGRint poststate)
{
	IGRint status, rc;

	me->in_dynamics = dynamics;

	status =
	dm$invoke_dynamics(
		msg = &rc,
		dynamics = dynamics,
		msgkey = msgkey,
		preproc = preproc,
		prestate = prestate,
		postproc = postproc,
		poststate = poststate,
		control = control,
		md_env = &me->dyn_env,
		dim_grid = &me->dim_grid,
		event = &me->event1);
	dm$status(action = RET_STATUS);

	me->in_dynamics = FALSE;

	return(OM_S_SUCCESS);
}

method delete_dimension()
{
	IGRint status, rc;
	struct GRid next[2];
	IGRboolean last_in_cpx;

	if (me->dim_grid.objid == NULL_OBJID)
	{
		/*| No such dimension exists */
		return(OM_S_SUCCESS);
	}

	status =
	om$send(msg = message DMroot.give_next(&rc, &last_in_cpx, next),
		targetid = me->dim_grid.objid,
		targetos = me->dim_grid.osnum);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.set_trak_info(REP_TRAK_DIST, &me->trak_info),
		targetid = me->dim_grid.objid,
		targetos = me->dim_grid.osnum);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.remove_from_cpx(
					&rc,
					DELETE_ACTION,
					&me->dyn_env),
		targetid = me->dim_grid.objid,
		targetos = me->dim_grid.osnum);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message NDnode.NDdelete(&me->dyn_env),
		mode = OM_e_wrt_message,
		targetid = me->dim_grid.objid,
		targetos = me->dim_grid.osnum);
	if (!(status & 1))
	{
		/*"delete failed\n"*/
	}

	if (!last_in_cpx)
	{
		/*"display %d, %d\n", next[0].objid, next[0].osnum*/

		status =
		DMdisplay_dimension(
			&rc,
			ROOT | CHILDREN,
			DISPLAY | ADDWRNG,
			&me->md_env,
			next);
		dm$status(action = RET_STATUS);
	}

	if (me->dim_grid.objid == me->first_dim.objid)
		me->first_dim.objid = NULL_OBJID;

	if (me->dim_grid.objid == me->prev_dim.objid)
		me->prev_dim.objid = NULL_OBJID;

	me->dim_grid.objid = NULL_OBJID;

	return(OM_S_SUCCESS);
}

method set_dim_attr()
{
	IGRint status;
	struct DMenv_param par_env;
	extern GRclassid OPP_DMsglpara_class_id,
			 OPP_DMsglarc_class_id;

	if (me->dim_type == CENTER_LINE)
	{
		me->cen_attr.gap_r = 0.5;
		me->cen_attr.minor_len_r = 1.0;
		me->cen_attr.major_len_r = 1.5;
		me->cen_attr.dim_type = me->dim_type;
		me->cen_attr.dim_state = DIM_IN_PLACEMENT | DIM_NEEDS_UPDATE;
		me->cen_attr.posn = TRUE;

		return(OM_S_SUCCESS);
	}

	status =
	dm$get_dim_param(type = DM_ENV_PARAM, p_data = (char *) &par_env);
	dm$status(action = RET_STATUS);

	if (me->dim_type == SINGLE_PARALLEL)
	{
		me->dim_attr.dim_type = me->sgl_type;
		me->dim_classid = (me->sgl_type == SINGLE_PARALLEL)?
					OPP_DMsglpara_class_id:
					OPP_DMsglarc_class_id;
	}
	else	me->dim_attr.dim_type = me->dim_type;

	me->dim_attr.dim_state = DIM_IN_PLACEMENT | DIM_NEEDS_UPDATE;
	me->dim_attr.geom_type = 0;
	me->dim_attr.display   = 0;
	me->dim_attr.mea_trak  = (me->angular_dim)?me->sect_sel:me->axis_sel;
	me->dim_attr.brk_pos   = BRK_CENTER;
	me->dim_attr.leader    = FALSE;
	me->dim_attr.brk_dist  = 0.5;
	me->dim_attr.lead_dist = par_env.txt_heig * par_env.pnt_exte_r;
	if ((me->dim_type != STACKED_ANGULAR
	&&  me->dim_type != STRINGED_ANGULAR)
	||  me->first_dim.objid != NULL_OBJID)
	{
		me->dim_attr.trak_dist
			= par_env.txt_heig * par_env.lin_offs_r;
	}

	return(OM_S_SUCCESS);
}

method set_dim_state(IGRshort dim_state)
{
	IGRint status;

	status =
	om$send(msg = message DMroot.set_dim_state(BIT_SET, dim_state),
		targetid = me->dim_grid.objid,
		targetos = me->dim_grid.osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method place_dimension()
{
	IGRint status, rc;
	IGRlong long_rc;
	IGRint count, one;

	if (me->dim_grid.objid != NULL_OBJID)
		return(OM_S_SUCCESS);

	count = me->count;

	if (me->is_a_complex && me->first_dim.objid != NULL_OBJID)
	{
		me->list[me->ori_index] = me->first_dim;
		me->context[me->ori_index].objid = NULL_OBJID;

		status =
		om$send(msg = message NDnode.NDget_objects(
						ND_ROOT,
						&me->list[DIM_ROOT_PLAN],
						1,
						NULL,
						DIM_ROOT_PLAN,
						DIM_ROOT_PLAN,
						&one),
			targetid = me->first_dim.objid,
			targetos = me->first_dim.osnum);
		dm$status(action = RET_STATUS);
	}
	else
	{
		status =
		om$send(msg = message COdmplace.get_dim_plane(),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if (me->dim_type == COORDINATE && me->mytype != 100)
			count--;
	}

	status =
	om$send(msg = message COdmplace.set_dim_attr(),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COdmplace.get_dim_param(),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	me->dim_grid.osnum = me->md_env.md_id.osnum;

	status =
	om$construct(classid = me->dim_classid,
		p_objid = &me->dim_grid.objid,
		osnum = me->dim_grid.osnum,
		msg = message DMroot.DMplace(
			&rc,
			count,
			me->list,
			(me->dim_type == CENTER_LINE)?(IGRchar *)&me->cen_attr:
							(IGRchar *)&me->dim_attr,
			&me->dyn_env));
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message NDnode.NDs_compute_node(
						&long_rc,
						0,
						&me->dyn_env),
		targetid = me->dim_grid.objid,
		targetos = me->dim_grid.osnum);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COdmplace.set_ter_loca(),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.get_first_in_cpx(&rc, &me->first_dim),
		targetid = me->dim_grid.objid,
		targetos = me->dim_grid.osnum);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.get_trak_info(&me->trak_info),
		targetid = me->dim_grid.objid,
		targetos = me->dim_grid.osnum);
	dm$status(action = RET_STATUS);

	status =
	DMdisplay_dimension(
		&rc,
		CHILDREN,
		ERASE | REMWRNG,
		&me->md_env,
		&me->dim_grid);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method create_origin()
{
	IGRint status;
	IGRint num_par;
	IGRshort edge_view;
	struct GRid parents[3];
	struct GRid context[3];
	IGRint type;
	IGRdouble attr[10];
	struct GRlc_info lc_info;
	struct DMobj_info obj_info;

	if (me->mytype == 100)
	{
		me->first_dim =
		me->orig.grid =
		me->list[me->ori_index] =
		me->ori_event.located_object[0].located_obj;

		me->orig.context.objid =
		me->context[me->ori_index].objid =
		NULL_OBJID;
	}
	else
	{
		status =
		om$send(msg = message COdim.load_obj_info(&me->ori_event, &me->orig),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	status =
	om$send(msg = message COdmplace.get_dim_plane(),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (me->mytype == 100)
		return(OM_S_SUCCESS);

	if (me->angular_dim)
	{
		if (me->orthogonal)
		{
			type = DMaxis;
			attr[0] = me->orig.lnproj[0];
			attr[1] = me->orig.lnproj[1];
			attr[2] = me->orig.lnproj[2];
			attr[3] = me->axis_sel?ACT_Y_AXIS:ACT_X_AXIS;
			num_par = 2;
			parents[0] = me->orig.grid;
			parents[1] = me->list[DIM_ROOT_PLAN];
			context[0] = me->orig.context;
			context[1] = me->context[DIM_ROOT_PLAN];
		}
		else if (me->angle_center)
		{
			status =
			om$send(msg = message COdim.load_obj_info(
						&me->cent_event,
						&me->cent),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			type = DM2ptseg;
			attr[0] = me->cent.lnproj[0];
			attr[1] = me->cent.lnproj[1];
			attr[2] = me->cent.lnproj[2];
			attr[3] = me->orig.lnproj[0];
			attr[4] = me->orig.lnproj[1];
			attr[5] = me->orig.lnproj[2];
			num_par = 2;
			parents[0] = me->cent.grid;
			parents[1] = me->orig.grid;
			context[0] = me->cent.context;
			context[1] = me->orig.context;
		}
		else
		{
			type = DMkeyseg;
			attr[0] = me->orig.lnproj[0];
			attr[1] = me->orig.lnproj[1];
			attr[2] = me->orig.lnproj[2];
			num_par = 1;
			parents[0] = me->orig.grid;
			context[0] = me->orig.context;
		}
	}
	else if (me->dim_type == SINGLE_PARALLEL
	&&	 me->sgl_type != SINGLE_PARALLEL)
	{
		/*| - Just make assoc source - */

		type = DMarc;
		num_par = 2;
		attr[0] = me->orig.lnproj[0];
		attr[1] = me->orig.lnproj[1];
		attr[2] = me->orig.lnproj[2];
		parents[0] = me->orig.grid;
		context[0] = me->orig.context;
		parents[1] = me->list[DIM_ROOT_PLAN];
		context[1].objid = NULL_OBJID;
	}
	else
	{
		if (me->sel_type == ARC_TYPE)
		{
			type = DMradcen;
			num_par = 2;

			parents[1] = me->list[DIM_ROOT_PLAN];
			context[1].objid = NULL_OBJID;
		}
		else
		{
			num_par = 1;

			if (me->sel_type == LINE_TYPE)
				type = DMkeyseg;
			else switch (me->ori_event.subtype)
			{
				case GRst_MIDPOINT:

				type = DMmidpt;
				break;

				case GRst_CENTER:

				type = DMcenpt;
				num_par = 2;
				parents[1] = me->list[DIM_ROOT_PLAN];
				context[1].objid = NULL_OBJID;
				break;

				case GRst_TANGENT_FROM:
				case GRst_TANGENT_TO:

				type = DMtanpt;
				num_par = 2;
				parents[1] = me->list[DIM_ROOT_PLAN];
				context[1].objid = NULL_OBJID;
				break;

				case GRst_INTER:

				lc_info = me->ori_event.located_object[0];
				me->ori_event.located_object[0] =
				me->ori_event.located_object[1];

				status =
				om$send(msg = message COdim.load_obj_info(
							&me->ori_event,
							&obj_info),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				me->ori_event.located_object[0] = lc_info;

				/*^ print_grid("intgrid", &obj_info.grid); */

				type = DMintpt;
				num_par = 3;
				parents[1] = obj_info.grid;
				context[1] = obj_info.context;
				parents[2] = me->list[DIM_ROOT_PLAN];
				context[2].objid = NULL_OBJID;
				break;

				default:

				type = DMkeypt;
				break;
			}
		}

		attr[0] = me->orig.lnproj[0];
		attr[1] = me->orig.lnproj[1];
		attr[2] = me->orig.lnproj[2];
		parents[0] = me->orig.grid;
		context[0] = me->orig.context;
	}

	if ((type == DMkeyseg) || (type == DMkeypt))
	{
		status =
		DMcheck_edge_view(
			me->orig.grid,
			me->list[DIM_ROOT_PLAN],
			&me->ori_event.located_object[0].module_info,
			&edge_view);
		dm$status(action = RET_STATUS);

		if(edge_view)
		{
			type = (type == DMkeyseg)?DMedgeseg:DMedgept;
			num_par = 2;
			parents[1] = me->list[DIM_ROOT_PLAN];
			context[1].objid = NULL_OBJID;
		}
	}

	status =
	dm$create_root(
		type = type,
		count = num_par,
		list = parents,
		context = context,
		attr = attr,
		md_env = &me->md_env,
		p_root = &me->list[me->ori_index]);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method create_measure()
{
	IGRint status;
	IGRint num_par;
	IGRshort edge_view;
	struct GRid parents[3];
	struct GRid context[3];
	IGRint type;
	IGRdouble attr[10];
	struct GRlc_info lc_info;
	struct DMobj_info obj_info;

	status =
	om$send(msg = message COdim.load_obj_info(&me->mea_event, &me->meas),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (me->angular_dim)
	{
		if (me->state == STATE_P_LOC_MEAS2)
		{
			type = DMkeypt;
			attr[0] = me->meas.lnproj[0];
			attr[1] = me->meas.lnproj[1];
			attr[2] = me->meas.lnproj[2];
			num_par = 1;
			parents[0] = me->meas.grid;
			context[0] = me->meas.context;
		}
		else if (me->angle_center)
		{
			type = DM2ptseg;
			num_par = 2;

			if (me->orthogonal)
			{
				attr[0] = me->orig.lnproj[0];
				attr[1] = me->orig.lnproj[1];
				attr[2] = me->orig.lnproj[2];
				parents[0] = me->orig.grid;
				context[0] = me->orig.context;
			}
			else
			{
				attr[0] = me->cent.lnproj[0];
				attr[1] = me->cent.lnproj[1];
				attr[2] = me->cent.lnproj[2];
				parents[0] = me->cent.grid;
				context[0] = me->cent.context;
			}

			attr[3] = me->meas.lnproj[0];
			attr[4] = me->meas.lnproj[1];
			attr[5] = me->meas.lnproj[2];
			parents[1] = me->meas.grid;
			context[1] = me->meas.context;
		}
		else
		{
			type = DMkeyseg;
			attr[0] = me->meas.lnproj[0];
			attr[1] = me->meas.lnproj[1];
			attr[2] = me->meas.lnproj[2];
			num_par = 1;
			parents[0] = me->meas.grid;
			context[0] = me->meas.context;
		}
	}
	else
	{
		type = DMkeypt;
		attr[0] = me->meas.lnproj[0];
		attr[1] = me->meas.lnproj[1];
		attr[2] = me->meas.lnproj[2];
		num_par = 1;
		parents[0] = me->meas.grid;
		context[0] = me->meas.context;
	}

	if (type == DMkeypt)
	{
		switch (me->mea_event.subtype)
		{
			case GRst_MIDPOINT:

			type = DMmidpt;
			break;

			case GRst_CENTER:

			type = DMcenpt;
			num_par = 2;
			parents[1] = me->list[DIM_ROOT_PLAN];
			context[1].objid = NULL_OBJID;
			break;

			case GRst_TANGENT_FROM:
			case GRst_TANGENT_TO:

			if (me->angular_dim)
				type = DMkeypt;
			else
			{
				type = DMtanpt;
				num_par = 2;
				parents[1] = me->list[DIM_ROOT_PLAN];
				context[1].objid = NULL_OBJID;
			}

			break;

			case GRst_INTER:

			lc_info = me->mea_event.located_object[0];
			me->mea_event.located_object[0] =
			me->mea_event.located_object[1];

			status =
			om$send(msg = message COdim.load_obj_info(
						&me->mea_event,
						&obj_info),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			me->mea_event.located_object[0] = lc_info;

			/*^ print_grid("intgrid", &obj_info.grid); */

			type = DMintpt;
			num_par = 3;
			parents[1] = obj_info.grid;
			context[1] = obj_info.context;
                        if((parents[0].objid == parents[1].objid) &&
                           (parents[0].osnum == parents[1].osnum))
                           return(OM_E_ABORT);
 
			parents[2] = me->list[DIM_ROOT_PLAN];
			context[2].objid = NULL_OBJID;
			break;

			default:

			type = DMkeypt;
			break;
		}
	}

	if ((type == DMkeyseg) || (type == DMkeypt))
	{
		status =
		DMcheck_edge_view(
			me->meas.grid,
			me->list[DIM_ROOT_PLAN],
			&me->mea_event.located_object[0].module_info,
			&edge_view);
		dm$status(action = RET_STATUS);

		if(edge_view)
		{
			type = (type == DMkeyseg)?DMedgeseg:DMedgept;
			num_par = 2;
			parents[1] = me->list[DIM_ROOT_PLAN];
			context[1].objid = NULL_OBJID;
		}
	}

	status =
	dm$create_root(
		type = type,
		count = num_par,
		list = parents,
		context = context,
		attr = attr,
		md_env = &me->md_env,
		p_root = &me->list[me->mea_index]);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method check_for_angcen()
{
	IGRint status, index;
	IGRlong long_rc;
	IGRshort edge_view;
	struct GRlc_info *lc_info;
	struct GRmd_env *lc_env;
	struct GRid *lc_obj;
	struct IGRbsp_curve *bsp_curve;
	struct GRevent *loc_event;
	extern GRclassid OPP_GRpoint_class_id;

	for (index=0; index<2; index++)
	{
		loc_event = (index)?&me->mea_event:&me->ori_event;
		lc_info = &loc_event->located_object[0];
		lc_obj	= &lc_info->located_obj;
		lc_env  = &lc_info->module_info;

		if (DMancestry_valid(*lc_obj, OPP_GRpoint_class_id))
		{
			/*| GRpoint */

			me->angle_center = TRUE;
			return(OM_S_SUCCESS);
		}

		status =
		om$send(msg = message GRvg.GRgenabsg(
					&long_rc,
					&lc_env->md_env.matrix_type,
					lc_env->md_env.matrix,
					(char **)&bsp_curve),
			targetid = lc_obj->objid,
			targetos = lc_obj->osnum);
		dm$status(action = RET_STATUS);

		/*"order=%d, num_poles=%d\n", bsp_curve->order, bsp_curve->num_poles*/

		if (bsp_curve->order != 2
		||  bsp_curve->num_poles < 2)
		{
			status =
			om$send(msg = message COdmplace.get_dim_plane(),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			status =
			DMcheck_edge_view(
				*lc_obj,
				me->list[DIM_ROOT_PLAN],
				&me->md_env,
				&edge_view);
			dm$status(action = RET_STATUS);

			me->angle_center = !edge_view;
			return(OM_S_SUCCESS);
		}
	}

	me->angle_center = FALSE;
	return(OM_S_SUCCESS);
}

method delete(int f_defer_flag)
{
	IGRint status;

	status =
        om$send(msg = message COdim.delete(f_defer_flag),
                targetid = my_id,
                mode = OM_e_wrt_message);
                dm$status(action = RET_STATUS);

	if (me->form)
	{
		status = FIf_delete(me->form);
		if (status != FI_SUCCESS)
		{
			/*|FIf_delete fails*/
			return(OM_E_ABORT);
		}
	}

	if (me->dim_grid.objid != NULL_OBJID)
	{
		status =
		om$send(msg = message COdmplace.delete_dimension(),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	status =
	om$send(msg = message COdim.delete(f_defer_flag),
		targetid = my_id,
		mode = OM_e_wrt_message);
		dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method display_form(IGRboolean disp0_updt1)
{
	IGRint status;
	IGRboolean jogged;
	extern IGRboolean Dim_rad_jog;
	extern IGRboolean Dim_coord_jog;

	if (disp0_updt1)
	{
		if (!me->form_displayed)
		   return(OM_S_SUCCESS);
	}
	else
	{
		if (me->form_displayed)
		   return(OM_S_SUCCESS);
	}

	status =
	FIg_set_value(
		me->form,
		CHECK,
		(double)0);
	if (status != FI_SUCCESS)
	{
		/*|FIg_set_value CHECK*/
		return(OM_E_ABORT);
	}

	if (me->dim_type == SINGLE_PARALLEL)
	{
		status =
		FIg_set_value(
			me->form,
			SGLPAR_TYPE,
			(double)(GL_sgl_type == SINGLE_ARC_LENGTH));
		if (status != FI_SUCCESS)
		{
			/*|FIg_set_value TYPE*/
			return(OM_E_ABORT);
		}
	}
	else
	{
		if ((me->dim_type == RADIAL)
		&&  ((me->state != STATE_P_LOC_JOG_PT)
		&&   (me->state != STATE_P_LOC_ORIG)))
		{
			/*|- disable the gadgets */

			status =
			FIg_disable(me->form, STD_DIM);
			if (status != FI_SUCCESS)
			{
				/*"FIg_disable fails:%d\n",status*/
				return(OM_E_ABORT);
			}

			status =
			FIg_disable(me->form, JOG_DIM);
			if (status != FI_SUCCESS)
			{
				/*"FIg_disable fails:%d\n",status*/
				return(OM_E_ABORT);
			}
		}
		else
		{
			/*|- enable the gadgets */

			jogged = (me->dim_type == RADIAL)? Dim_rad_jog:Dim_coord_jog;

			status =
			FIg_enable(me->form, STD_DIM);
			if (status != FI_SUCCESS)
			{
				/*"FIg_disable fails:%d\n",status*/
				return(OM_E_ABORT);
			}

			status =
			FIg_enable(me->form, JOG_DIM);
			if (status != FI_SUCCESS)
			{
				/*"FIg_disable fails:%d\n",status*/
				return(OM_E_ABORT);
			}

			status =
			FIg_set_value(
				me->form,
				STD_DIM,
				(double)(!(jogged)));
			if (status != FI_SUCCESS)
			{
				/*|FIg_set_value TYPE*/
				return(OM_E_ABORT);
			}

			status =
			FIg_set_value(
				me->form,
				JOG_DIM,
				(double)(jogged));
			if (status != FI_SUCCESS)
			{
				/*|FIg_set_value TYPE*/
				return(OM_E_ABORT);
			}
		}
	}

	status = FIf_display(me->form);
	if (status != FI_SUCCESS)
	{
		/*|FIf_display fails*/
		return(OM_E_ABORT);
	}

	me->form_displayed = TRUE;

	return(OM_S_SUCCESS);
}

method notify_form(
	int form_label;
	int label;
	double value;
	Form form)
{
	IGRint status, msgkey;
	IGRboolean jogged;
	extern IGRboolean Dim_rad_jog, Dim_coord_jog;

	if (label == CHECK)
	{
		status = FIf_erase(me->form);
		if (status != FI_SUCCESS)
		{
			/*|FIf_erase*/
			return(OM_E_ABORT);
		}

		me->form_displayed = FALSE;
		return(OM_S_SUCCESS);
	}

	if (me->dim_type == SINGLE_PARALLEL)
	{
		GL_sgl_type = (value)?SINGLE_ARC_LENGTH:SINGLE_ARC_ANGLE;

		if (me->dim_grid.objid == NULL_OBJID
		||  me->sgl_type == SINGLE_PARALLEL)
			return(OM_S_SUCCESS);

		status =
		om$send(msg = message DMsglarc.set_meas_type(GL_sgl_type),
			targetid = me->dim_grid.objid,
			targetos = me->dim_grid.osnum);
		dm$status(action = RET_STATUS);
	}
	else
	{
		jogged = (label == JOG_DIM)?TRUE:FALSE;

		if (me->dim_grid.objid != NULL_OBJID)
		{
			if (!jogged)
			{
				status =
				om$send(msg = message DMroot.jogged_off(),
					targetid = me->dim_grid.objid,
					targetos = me->dim_grid.osnum);
				dm$status(action = RET_STATUS);
			}
		}

		if (me->in_dynamics)
		{
			if (jogged)
			{
				msgkey = (me->dim_type == RADIAL)?
				DM_P_PosBrkPt:DM_P_EnFBrkPt;
			}
			else	msgkey = DM_P_PosDim;

			ex$message(msgnumb = msgkey);
		}

		/*"Jogged = %d\n", jogged*/

		if (me->dim_type == RADIAL)
			Dim_rad_jog = jogged;
		else	Dim_coord_jog = jogged;
	}

	return(OM_S_SUCCESS);
}

end implementation COdmplace;
