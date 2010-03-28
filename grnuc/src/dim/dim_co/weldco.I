/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:30 $
$Locker:  $
$Log: weldco.I,v $
Revision 1.1.1.1  2001/12/17 22:39:30  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:08:01  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:22:00  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:51:29  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.6  1994/11/01  10:12:06  gvk
# COMMENT : Included prototypes for BSfunctions and GRNUC calls which return double.
#
# Revision 240.5  1994/08/10  21:52:40  grnuc40
# COMMENT : Upgrade due to Intel Solaris port
#
# Revision 240.4  1993/08/12  21:02:50  mike
# COMMENT : Hilite the Status Display button.
#
# Revision 240.3  1993/06/01  13:13:19  scott
# COMMENT : duplicate msgnumbs changed
#
# Revision 240.2  1993/03/01  19:39:04  mikel
# COMMENT : remove ms.h or change it to msmacros.h
#
# Revision 240.1  1993/01/10  23:29:54  pike
# COMMENT : port to NT.  make form display last thing in wakeup
#
# Revision 220.0  1992/08/29  06:23:15  root
# COMMENT : Corresponds to Rel201.8 in 2.0.1 RCS
#
Revision 201.8  1992/07/23  19:53:55  doree
COMMENT : message subsystem compliance

Revision 201.7  1992/06/30  07:40:26  laxmi
COMMENT : Source code changed to comply with ANSI compilation.

Revision 201.5  1992/01/28  10:37:32  dimdp20
COMMENT : Dimension Fixes Checkin - S. Poovannan - Jan 28 1992

Revision 201.4  92/01/22  07:35:13  dimdp20
COMMENT : Dimension Fixes Release - S. Poovannan - Jan. 22 1992.

Revision 201.3  92/01/22  06:46:50  dimdp20
COMMENT : Dimension Fixes Release - S. Poovannan - Jan 22 1992.

*/

class implementation COweld;

#define AS_DEBUG 1

/* STATE for weld command */

#define STATE_P_LOC_ELEMENT	1
#define STATE_P_GET_EVENT	2
#define STATE_P_BUTT_POINT	3
#define STATE_P_FILLET_EDGE1	4
#define STATE_P_FILLET_EDGE2	5
#define STATE_P_FILLET_SIZE	6

#include "dimdef.h"
#include "dim.h"
#include "form_env.h"
#include "dimformdef.h"
#include "dimform.h"
#include "dimgraph.h"
#include "weldform.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "bspt_on_lne.h"
#include "bsnorvec.h"
#include "bsdistptpt.h"

extern IGRboolean 		BSproj1();

from NDnode import NDs_compute_node, NDdelete;
from GRvg   import GRgenabsg, GRkeypoint;
from DMannot import ANadd_delete_vertex;
from DMroot import DMplace;
from DMroot import set_dim_state;
from DMroot import get_dimension_plane;
from DMsuper import create_dim_param;
from DMweld import set_cross_section;

extern GRclassid OPP_GR3dtext_class_id,
		 OPP_GRbspline_class_id,
		 OPP_GR3dpoint_class_id,
		 OPP_DMweld_class_id;

extern struct DMweld_param frm_weld;
extern double atof();
extern double fabs();

method get_dim_param()
{
	IGRint status;

	status =
	dm$get_dim_param(type = DM_SENV_PARAM, 
		p_grid = &me->list[DIM_ROOT_SENV]);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method get_dim_plane()
{
	IGRint status;
	struct GRid win_grid;

	win_grid.objid = me->loc_event.event.button.objid;
	win_grid.osnum = me->loc_event.event.button.osnum;

	status =
	dm$get_dim_plane(win_grid = win_grid,
			md_env = &me->md_env,
			p_grid = &me->list[DIM_ROOT_PLAN]);
	dm$status(action = RET_STATUS);

	status =
	dm$get_plan_info(
		plan_objid = me->list[DIM_ROOT_PLAN].objid,
		osnum = me->list[DIM_ROOT_PLAN].osnum,
		md_env = &me->md_env,
		plan_info = &me->plan_info);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method init(int type; char *string_ptr)
{
	IGRint status;
	IGRint index;

	status =
	om$send(msg = message COdim.init(type, string_ptr),
		targetid = my_id,
		mode = OM_e_wrt_message);
	dm$status(action = RET_STATUS);

	me->weld_grid.objid = NULL_OBJID;
	me->prev_weld.objid = NULL_OBJID;
	me->state = STATE_P_LOC_ELEMENT;
	me->form_display = FALSE;
	me->above_input = TRUE;
	
	me->mask1 |= GRm_STRING;
	me->mask2 |= GRm_STRING;


	for (index=0; index < NO_TEXT_LEADER_ROOTS; index++)
	{
		me->list[index].objid =
		me->context[index].objid = NULL_OBJID;
	}

	/*"me->mytype=%d, type=%d\n", me->mytype, type*/

	/*|- Create Forms */

	status =
	om$send(msg = message COdim.create_form(MAIN_FORM,"DMWeld",
						&me->form),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COdim.create_form(SUB_FORM1,"DMWeldSbAbov",
						&me->subform1),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COdim.create_form(SUB_FORM2,"DMWeldSbBlow",
						&me->subform2),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COdim.create_form(SUB_FORM3,"DMWeldSbCntr",
						&me->subform3),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COdim.create_form(SUB_FORM4,"DMWeldSub",
						&me->subform4),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COweld.init_type(),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	ex$message(msgnumb = DM_I_StatFormAvForOpt);
        GRstatus_display_button(1);
	return(OM_S_SUCCESS);
}

method init_type()
{
	me->an_attr.dim_state = DIM_IN_PLACEMENT | DIM_NEEDS_UPDATE;
	me->an_attr.dim_type  = me->mytype;

	me->msgnumb = DMC_M_PlWlSy;
	me->loc_key = DM_P_LocRunLdFr;
	me->acc_key = DM_P_PosBrkPtM;
	me->rel_key = DM_E_EltNotFound;

	return(OM_S_SUCCESS);
}
method super_cmd.sleep(int pos)
{
	IGRint status;

	status =
	om$send(msg = message COdim.sleep(pos),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if(me->form_display) erase_form(me->form);

	ex$message(msgnumb = GR_I_Clear);
        GRstatus_display_button(0);

	return(OM_S_SUCCESS);
}
 
method wakeup(int pos)
{
	IGRint status;
	IGRboolean set_inq;
	IGRlong msg;

	status =
	om$send(msg = message COdim.wakeup(pos),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	set_inq = 1;
    	DPdynflags(&msg,&set_inq,&me->dynamics_on,NULL);

	if(me->form_display)
	{
		me->form_display = FALSE;
		status = 
		om$send(msg = message COweld.display_form(),
				targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else
        {
                ex$message(msgnumb = DM_I_StatFormAvForOpt);
                GRstatus_display_button(1);
        }

	return( OM_S_SUCCESS);
}

method execute(int *response; char *response_data; int pos)
{
	IGRint status, rc, i, cs_type;
	IGRlong long_rc;
	IGRpoint point;
	IGRdouble weld_size;
	struct ret_struct ret_str;
	struct GRevent weld_event;

	while(TRUE)
	{
		if ((me->event1.response == EX_SINIT) &&
			(me->weld_grid.objid != NULL_OBJID))
		{
			/*|- Erase the dimension, cmd restarted*/

			status =
			DMdisplay_dimension(
				&rc,
				ROOT | CHILDREN,
				ERASE | REMWRNG,
				&me->md_env,
				&me->weld_grid);
			dm$status(action = RET_STATUS);
		}

		switch(me->state)
		{
			/*************************/
			case STATE_P_LOC_ELEMENT:
			/*************************/
	
			status =
			om$send(msg = message COdim.locate_parent(
						response,
						response_data,
						&me->loc_event,
						TRUE,
						me->loc_key,
						me->acc_key,
						me->rel_key),
				targetid = my_id);
			dm$status(action = RET_STATUS);
			
			if (me->locate_rc == LC_OBJ_LOCATED)
				me->state = STATE_P_GET_EVENT;
			else if ((*response == D_RESET)
			&& (me->prev_weld.objid != NULL_OBJID))
			{
				me->weld_grid.objid = me->prev_weld.objid;

				status =
				om$send(msg = message COweld.display_dimension(
							ROOT,
							ERASE|REMWRNG),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				me->prev_weld.objid = NULL_OBJID;
				me->state = STATE_P_GET_EVENT;
			}
			break;

			/********************/
			case STATE_P_GET_EVENT:
			/********************/
			
			/*|- get event */

			status =
			om$send(msg = message COweld.place_dimension(),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message COweld.position_dim(
						DM_P_PosBrkPtM,
						TRUE,
						NULL,
						NULL,
						MOVE_BREAK_PT,
						NULL,
						NULL),
			targetid = my_id);
			dm$status(action=RET_STATUS);

			status =
			om$send(msg = message COdim.getevent(
							DM_P_PosBrkPtM,
							response,
							response_data,
							&me->event1),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			/*^printf("getevnt : data point:%lf:%lf:%lf\n",me->event1.event.button.x,
							me->event1.event.button.y,
							me->event1.event.button.z);*/
			
			if( *response == DATA)
			{
				/*|- response is DATA */

				status =
				om$send(msg = message COweld.position_dim(
							DM_P_PosBrkPtM,
							FALSE,
							NULL,
							NULL,
							MOVE_BREAK_PT,
							NULL,
							NULL),
				targetid = my_id);
				dm$status(action=RET_STATUS);
				
				/*| - Add a vertex */

				status = 
				om$send(msg = message DMannot.ANadd_delete_vertex(
								&rc,
								ADD_VERTEX,
								NULL,
								&me->dyn_env),
					targetid = me->weld_grid.objid,
					targetos = me->weld_grid.osnum);
				dm$status(action= RET_STATUS);
					
				status =
				om$send(msg = message COweld.set_dim_state(
								DIM_IN_PLACEMENT |
								DIM_NEEDS_UPDATE ),
						targetid = my_id);
				dm$status(action = RET_STATUS);
			}
			else if(*response == D_RESET)
			{
				/*| - response is D_RESET */

				status = 
				om$send(msg = message DMannot.ANadd_delete_vertex(
							&rc,
							DELETE_VERTEX,
							NULL,
							&me->dyn_env),
					targetid = me->weld_grid.objid,
					targetos = me->weld_grid.osnum);
				dm$status(action= RET_STATUS);

				if(!rc)	me->state = STATE_P_LOC_ELEMENT;
			}
			else if(*response == RESET)
			{
				/*| - Delete Vertex  */

				status = 
				om$send(msg = message DMannot.ANadd_delete_vertex(
							&rc,
							DELETE_VERTEX,
							NULL,
							&me->dyn_env),
					targetid = me->weld_grid.objid,
					targetos = me->weld_grid.osnum);
				dm$status(action= RET_STATUS);

				status =
				om$send(msg = message NDnode.NDs_compute_node(
							&long_rc,
							0,
							&me->dyn_env),
					targetid = me->weld_grid.objid,
					targetos = me->weld_grid.osnum);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message COweld.display_dimension(
						ROOT,
						DISPLAY | ADDWRNG),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				if (frm_weld.cross_section)
				{
					if (frm_weld.above)
					{
						if (frm_weld.atext.weld_symbol != FILLET)
						   me->state = STATE_P_BUTT_POINT;
						else me->state = STATE_P_FILLET_EDGE1;
					}
					else
					{
						if (frm_weld.btext.weld_symbol != FILLET)
						   me->state = STATE_P_BUTT_POINT;
						else me->state = STATE_P_FILLET_EDGE1;
					}
				}
				else
				{
					me->prev_weld.objid = me->weld_grid.objid;
					me->weld_grid.objid = NULL_OBJID;
					me->state = STATE_P_LOC_ELEMENT;
				}
			}
			break;

			case STATE_P_BUTT_POINT:

			status =
			om$send(msg = message COdim.getevent(
							DM_P_IdButtPt,
							response,
							response_data,
							&me->event1),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			/*^printf("getevnt : data point:%lf:%lf:%lf\n",me->event1.event.button.x,
							me->event1.event.button.y,
							me->event1.event.button.z);*/
			
			if (*response == DATA)
			{
				status =
				DMnode_give_structure(
					&rc,
					DIM_NO_INDEX,
					ORIG_INFO,
					FALSE,
					me->list[AN_ROOT_ELEM1].objid,
					me->weld_grid.objid,
					me->list[AN_ROOT_ELEM1].osnum,
					&me->md_env,
					&ret_str);
				dm$status(action = RET_STATUS);

				status =
				BSproj1(&rc,
					&me->event1.event.button.x,
					&me->plan_info.win_plan.matrix[8],
					ret_str.var.point_st.pt,
					point);
				dm$status(action = RET_STATUS);

				for (i=0; i<3; i++)
				    me->vector[i] = point[i] -
					ret_str.var.point_st.pt[i];
 
				if (frm_weld.above)
				cs_type = (frm_weld.atext.weld_symbol == VWELD) ?
						VWELD_CS:BEVEL_CS;
				else
				cs_type = (frm_weld.btext.weld_symbol == VWELD) ?
						VWELD_CS:BEVEL_CS;

				status =
				om$send(msg = message DMweld.set_cross_section(
							cs_type,
							0.0,
							me->vector),
					targetid = me->weld_grid.objid,
					targetos = me->weld_grid.osnum);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message COweld.display_dimension(
						ROOT,
						ERASE | REMWRNG),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message NDnode.NDs_compute_node(
							&long_rc,
							0,
							&me->dyn_env),
					targetid = me->weld_grid.objid,
					targetos = me->weld_grid.osnum);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message COweld.display_dimension(
						ROOT,
						DISPLAY | ADDWRNG),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				me->prev_weld.objid = me->weld_grid.objid;

				me->weld_grid.objid = NULL_OBJID;

				me->state = STATE_P_LOC_ELEMENT;
			}

			break;

			/*************************/
			case STATE_P_FILLET_EDGE1:
			/*************************/

			/*|- Fillet Weld --> Locate edge 1*/

			status =
			om$send(msg = message COdim.locate_parent(
						response,
						response_data,
						&me->loc_event,
						TRUE,
						DM_P_IdFlEdge1,
						DM_P_IdFlEdge2,
						me->rel_key),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (me->locate_rc == LC_OBJ_LOCATED)
				me->state = STATE_P_FILLET_EDGE2;

			break;

			/*************************/
			case STATE_P_FILLET_EDGE2:
			/*************************/

			/*|- Fillet Weld --> locate Edge 2*/

			weld_size = 0.0;

			if (frm_weld.above)
				weld_size = atof(frm_weld.atext.ftext);

			if ((weld_size <= 0.0) && (frm_weld.below))
				weld_size = atof(frm_weld.btext.ftext);

			status =
			om$send(msg = message COdim.locate_parent(
						response,
						response_data,
						&me->loc_event,
						TRUE,
						DM_P_IdFlEdge2,
						(weld_size > 0.0)?
						DM_P_Ac:DM_P_KeFlWlSz,
						me->rel_key),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (me->locate_rc == LC_OBJ_LOCATED)
			{
				/*|- Object located */

				if (weld_size > 0.0)
				{
					/*|- Weld Size present place weld */
					
					status =
					om$send(msg = message DMweld.set_cross_section(
								FILLET_CS,
								weld_size,
								me->vector),
						targetid = me->weld_grid.objid,
						targetos = me->weld_grid.osnum);
					dm$status(action = RET_STATUS);

					status =
					om$send(msg = message COweld.display_dimension(
							ROOT,
							ERASE | REMWRNG),
						targetid = my_id);
					dm$status(action = RET_STATUS);

					status =
					om$send(msg = message NDnode.NDs_compute_node(
								&long_rc,
								0,
								&me->dyn_env),
						targetid = me->weld_grid.objid,
						targetos = me->weld_grid.osnum);
					dm$status(action = RET_STATUS);

					status =
					om$send(msg = message COweld.display_dimension(
							ROOT,
							DISPLAY | ADDWRNG),
						targetid = my_id);
					dm$status(action = RET_STATUS);

					me->prev_weld.objid = me->weld_grid.objid;
	
					me->weld_grid.objid = NULL_OBJID;
	
					me->state = STATE_P_LOC_ELEMENT;
				}
				else me->state = STATE_P_FILLET_SIZE;
			}
			break;

			/*************************/
			case STATE_P_FILLET_SIZE:
			/*************************/

			/*|- Get Fillet weld Size */

			status =
			co$getevent(
				msg = &rc,
				event_mask = GRm_VALUE,
				value_type = GRIO_DISTANCE,
				msgnum = DM_P_KeFlWlSz,
				response = response,
				response_data = response_data,
				event = &weld_event);

			if (weld_event.response == EX_VALUE)
			{
				status =
				om$send(msg = message DMweld.set_cross_section(
							FILLET_CS,
							weld_event.event.value,
							me->vector),
					targetid = me->weld_grid.objid,
					targetos = me->weld_grid.osnum);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message COweld.display_dimension(
						ROOT,
						ERASE | REMWRNG),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message NDnode.NDs_compute_node(
							&long_rc,
							0,
							&me->dyn_env),
					targetid = me->weld_grid.objid,
					targetos = me->weld_grid.osnum);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message COweld.display_dimension(
						ROOT,
						DISPLAY | ADDWRNG),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				me->prev_weld.objid = me->weld_grid.objid;

				me->weld_grid.objid = NULL_OBJID;

				me->state = STATE_P_LOC_ELEMENT;
			}
			break;

			/******/
			default:
			/******/

			printf("COweld: Unknown state %d\n", me->state);
			*response = TERMINATE;
			return(OM_S_SUCCESS);
		}

		switch (*response)
		{
			case DATA:
			case RESET:
			case D_RESET:
			case MOVE_ON:
			case STRING:
			break;

			case TERMINATE:
			if (me->weld_grid.objid != NULL_OBJID)
			{
				status =
				om$send(msg = message COweld.delete_dimension(),
					targetid = my_id);
				dm$status(action = RET_STATUS);
			}
			return(OM_S_SUCCESS);

			case STATUS_DISP:

			status = 
			om$send(msg = message COweld.display_form(),
					targetid = my_id);
			dm$status(action = RET_STATUS);
			break;

			case EX_CMD_KEY:
			case CMD_STRING:
			return(OM_S_SUCCESS);

			default:
			/*^ printf("response:%d\n",*response); */
			return(OM_S_SUCCESS);
		}
	}
}

method LC_preproc(IGRint *msg; struct GRlc_info *lc_info)
{
	IGRint status, rc, index1, index2, i;
	IGRboolean online;
	IGRlong long_rc, bsrc;
	IGRpoint point, point2, keypt;
	IGRpoint start_pt, end_pt;
	struct IGRbsp_curve *bsp_curve;
	struct ret_struct ret_str;
	struct IGRline boreline;
	struct GRparms par;
	IGRdouble *poles, *pole_i, dist1, dist2, dist;
	IGRdouble upar;

	me->event1.located_object[0] = *lc_info;
	me->loc_event = me->event1;
	
	switch(me->state)
	{
		/*************************/
		case STATE_P_LOC_ELEMENT:
		/*************************/
		
		status =
		om$send(msg = message COweld.create_arrow(),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		break;

		case STATE_P_FILLET_EDGE1:
		case STATE_P_FILLET_EDGE2:

		status =
		DMnode_give_structure(
			&rc,
			DIM_NO_INDEX,
			ORIG_INFO,
			FALSE,
			me->list[AN_ROOT_ELEM1].objid,
			me->weld_grid.objid,
			me->list[AN_ROOT_ELEM1].osnum,
			&me->md_env,
			&ret_str);
		dm$status(action = RET_STATUS);

		point[0] = me->loc_event.event.button.x;
		point[1] = me->loc_event.event.button.y;
		point[2] = me->loc_event.event.button.z;

		boreline.point1 = point;
		boreline.point2 = point2;

		point2[0] = point[0] + me->plan_info.win_plan.matrix[8];
		point2[1] = point[1] + me->plan_info.win_plan.matrix[9];
		point2[2] = point[2] + me->plan_info.win_plan.matrix[10];

		/*|GRkeypoint*/

		status =
		om$send(msg = message GRvg.GRkeypoint(
					&long_rc,
					&lc_info->module_info.md_env.matrix_type,
					lc_info->module_info.md_env.matrix,
					&boreline,
					keypt,
					&par),
			targetid = lc_info->located_obj.objid,
			targetos = lc_info->located_obj.osnum);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message GRvg.GRgenabsg(
					&long_rc,
					&lc_info->module_info.md_env.matrix_type,
					lc_info->module_info.md_env.matrix,
					(char **)&bsp_curve),
			targetid = lc_info->located_obj.objid,
			targetos = lc_info->located_obj.osnum);
		dm$status(action = RET_STATUS);
	
		/*"num poles=%d\n", bsp_curve->num_poles*/

		poles = bsp_curve->poles;

		index1 = -1;
		for (i=0; i<bsp_curve->num_poles; i=i+1)
		{
			pole_i = &poles[3*i];
			if ((fabs(pole_i[0] - keypt[0]) < 1e-09)
			&&  (fabs(pole_i[1] - keypt[1]) < 1e-09)
			&&  (fabs(pole_i[2] - keypt[2]) < 1e-09))
			{
				index1 = i;
				break;
			}
		}

		if (index1 < 0)
		{
			printf("Key point is not one of the line points\n");
			return(OM_E_ABORT);
		}

		if (index1 == 0)
		{
			if ((fabs(poles[3*index1] - poles[3*(bsp_curve->num_poles-1)]) < 1e-09)
			&&  (fabs(poles[3*index1+1] - poles[3*(bsp_curve->num_poles-1)+1]) < 1e-09)
			&&  (fabs(poles[3*index1+2] - poles[3*(bsp_curve->num_poles-1)+2]) < 1e-09))
			{
				dist1 = BSdistptpt(&bsrc, point, &poles[0]);
				dist2 = BSdistptpt(&bsrc, point, &poles[3]);
				dist  = BSdistptpt(&bsrc, &poles[0], &poles[3]);

				if (fabs(dist - dist1 - dist2) > 1e-9)
					index2 = bsp_curve->num_poles - 2;
				else	index2 = 1;
			}
			else index2 = 1;
		}
		else if (index1 == bsp_curve->num_poles - 1)
			index2 = bsp_curve->num_poles - 2;
		else
		{
			index2 = index1 + 1;
			dist1 = BSdistptpt(&bsrc, point, &poles[3*index1]);
			dist2 = BSdistptpt(&bsrc, point, &poles[3*index2]);
			dist  = BSdistptpt(&bsrc, &poles[3*index1], &poles[3*index2]);

			if (fabs(dist - dist1 - dist2) > 1e-9)
				index2 = index1 - 1;
		}

		status =
		BSproj1(&bsrc,
			&bsp_curve->poles[3*index1],
			&me->plan_info.win_plan.matrix[8],
			ret_str.var.point_st.pt,
			start_pt);
		dm$status(action = RET_STATUS);

		status =
		BSproj1(&bsrc,
			&bsp_curve->poles[3*index2],
			&me->plan_info.win_plan.matrix[8],
			ret_str.var.point_st.pt,
			end_pt);
		dm$status(action = RET_STATUS);

		status =
		BSpt_on_lne(
			&bsrc,
			start_pt,
			end_pt,
			ret_str.var.point_st.pt,
			&upar,
			&online);
		dm$status(action = RET_STATUS);

		if(!online)
		{
			ex$message(msgnumb = DM_I_SrfMustPassThruWeldEdg);
			*msg = FALSE;
			return(FALSE);
		}

		index1 = (me->state == STATE_P_FILLET_EDGE1)?0:3;

		for (i=0; i<3; i++)
		me->vector[i+index1] = end_pt[i] - start_pt[i];
		BSnorvec(&bsrc, &me->vector[index1]);
		break;
		
		default:
		printf("me->state:%d\n",me->state);
		break;
	}

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
	if (me->locate_rc == LC_OBJ_LOCATED)
		me->create_flag = TRUE;

	if (me->event2.response == RESET ||
	    me->event2.response == D_RESET)
		delete = (me->state == STATE_P_LOC_ELEMENT);

	if (delete)
	{
		/*|Deleting dimension*/

		status =
		om$send(msg = message COweld.delete_dimension(),
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
	IGRint status;

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

	if (me->state == STATE_P_LOC_ELEMENT)
	{
		if (me->weld_grid.objid == NULL_OBJID)
		{
			status =
			om$send(msg = message COweld.place_dimension(),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}	

		status =
		om$send(msg = message COweld.set_dim_state(
					DIM_IN_PLACEMENT |
					DIM_NEEDS_UPDATE),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		
		status =
		om$send(msg = message COweld.position_dim(
					DM_P_PosBrkPtM,
					TRUE,
					NULL,
					NULL,
					MOVE_BREAK_PT,
					NULL,
					NULL),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}
method LC_selection(IGRint *msg; struct GRlc_info *lc_info)
{
	struct IGRbsp_curve *bsp_curve;
	IGRlong long_rc,status;
	*msg = OM_S_SUCCESS;

	/* - Linear element is required for weld symbol
		with cross_section- */

	*msg = DMancestry_valid(lc_info->located_obj, OPP_GRbspline_class_id);

	if (*msg && (frm_weld.cross_section
	|| (me->state == STATE_P_FILLET_EDGE1)
	|| (me->state == STATE_P_FILLET_EDGE2)))
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

		*msg = (bsp_curve->order == 2);
		*msg = !DMancestry_valid(lc_info->located_obj, OPP_GR3dpoint_class_id);
		return(TRUE);
	}

	if (DMancestry_valid(lc_info->located_obj, OPP_GR3dtext_class_id))
		*msg= TRUE;

	return(OM_S_SUCCESS);
}
method display_dimension(
	IGRint level;
	IGRint control)
{
	IGRint status, rc;
	IGRshort dim_state;

	status =
	DMdisplay_dimension(
		&rc,
		level,
		control,
		&me->md_env,
		&me->weld_grid);
	dm$status(action = RET_STATUS);

	dim_state = (control & DISPLAY)?0:DIM_IN_PLACEMENT;

	status =
	om$send(msg = message COweld.set_dim_state(dim_state),
		targetid = my_id);
	dm$status(action = RET_STATUS);

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

	if(!me->dynamics_on && dynamics)
		return(OM_S_SUCCESS);
	/*^
		printf("dynamics flag:%d\n",dynamics);
		printf("data point:%lf:%lf:%lf\n",
			me->event1.event.button.x,
			me->event1.event.button.y,
			me->event1.event.button.z);
	*/

	status =
	DMinvoke_txdynamics(
		&rc,
		dynamics,
		&me->dyn_info,
		msgkey,
		preproc,
		postproc,
		prestate,
		poststate,
		FALSE,  /* copy flag */
		NULL,   /* cp_grid  */
		control,
		&me->dyn_env,
		&me->event1,
		&me->weld_grid);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method delete_dimension()
{
	IGRint status;

	if (me->weld_grid.objid == NULL_OBJID)
	{
		/*| No such dimension exists */
		return(OM_S_SUCCESS);
	}

	status =
	om$send( msg = message NDnode.NDdelete(&me->dyn_env),
		mode = OM_e_wrt_message,
		targetid = me->weld_grid.objid,
		targetos = me->weld_grid.osnum);
	if (!(status & 1))
	{
		/*"delete fails\n"*/
	}

	me->weld_grid.objid = NULL_OBJID;

	return(OM_S_SUCCESS);
}

method set_dim_attr()
{
	me->an_attr.dim_type	= me->mytype;
	me->an_attr.geom_type   = 0;
	me->an_attr.display	= 0;
	me->an_attr.dim_state	= DIM_IN_PLACEMENT | DIM_NEEDS_UPDATE;
	me->an_attr.leader 	= 0;
	me->an_attr.text_length = 0;
	me->an_attr.text_string = NULL;
	me->an_attr.num_brkpt  = 0;
	me->an_attr.dual_mode = 0;
	me->an_attr.brkpt      = NULL;
	me->an_attr.tol_symbol = 0;
	me->an_attr.bln_dir    =  0; 

	return(OM_S_SUCCESS);
}

method set_dim_state(IGRshort dim_state)
{
	IGRint status;

	status =
	om$send(msg = message DMroot.set_dim_state(BIT_SET, dim_state),
		targetid = me->weld_grid.objid,
		targetos = me->weld_grid.osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method place_dimension()
{
	IGRint status, rc;

	if (me->weld_grid.objid != NULL_OBJID)
		return(OM_S_SUCCESS);

	status =
	om$send(msg = message COweld.get_dim_plane(),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COweld.set_dim_attr(),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COweld.get_dim_param(),
		targetid = my_id);
	dm$status(action = RET_STATUS);


	/*^ printf("mytype:%d\n",me->mytype); */

	me->weld_grid.osnum = me->md_env.md_id.osnum;

	status =
	om$construct(
		classid = OPP_DMweld_class_id,
		p_objid = &me->weld_grid.objid,
		osnum = me->weld_grid.osnum,
		msg = message DMroot.DMplace(
					&rc,
					NO_TEXT_LEADER_ROOTS,
					me->list,
					(char *)&me->an_attr,
					&me->dyn_env));
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method create_arrow()
{
	IGRint status, src_type;
	IGRdouble *attr;
	
	status =
	om$send(msg = message COdim.load_obj_info(&me->loc_event, &me->arrow),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COweld.get_dim_plane(),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	attr = &me->arrow.lnproj[0];

	src_type = (frm_weld.cross_section)? DMkeypt:DMptdist;

	status=
	dm$create_root(
		type = src_type,
		count = 1,
		list  = &me->arrow.grid,
		context = &me->arrow.context,
		attr = attr,
		md_env = &me->md_env,
		p_root = &me->list[AN_ROOT_ELEM1]);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method delete(int f_defer_flag)
{
	IGRint status;

	if (me->weld_grid.objid != NULL_OBJID)
	{
		/*| delete dimension */
		status =
		om$send(msg = message COweld.delete_dimension(),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	/*|- delete form */

	delete_form(me->form);
	delete_form(me->subform1);
	delete_form(me->subform2);
	delete_form(me->subform3);
	delete_form(me->subform4);
	
	/*| delete wrt COdim*/

	status =
	om$send(msg = message COdim.delete(f_defer_flag),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method notify_form(
	int form_label;
	int label;
	double value;
	Form form)
{
	IGRint status;
	IGRboolean save_data, ignore_data;
	struct DMweld_param par_weld;

	dm$get_dim_param(type = DM_WELD_PARAM, p_data = (char *)&par_weld);

	status =
	DMprocess_weld_form(
		form_label,
		label,
		value,
		me->form,
		me->subform1,
		me->subform2,
		me->subform3,
		me->subform4,
		(me->weld_grid.objid == NULL_OBJID),
		&me->above_input,
		&me->form_display,
		FALSE,
		FALSE,
		&save_data,
		&ignore_data,
		&par_weld);
	dm$status(action = RET_STATUS);

	if (save_data)
	{
		dm$put_dim_param(type = DM_WELD_PARAM, p_data = (char *)&par_weld);

		if (me->weld_grid.objid != NULL_OBJID)
		{
			status =
			om$send(msg = message DMroot.set_dim_state(BIT_OR, DIM_NEEDS_UPDATE),
				senderid = NULL_OBJID,
				targetid = me->weld_grid.objid,
				targetos = me->weld_grid.osnum);
			dm$status(action = RET_STATUS);
		}
	}

	return(OM_S_SUCCESS);
}

method display_form()
{
	IGRint status;
	IGRboolean save_data, ignore_data;
	struct DMweld_param par_weld;

	dm$get_dim_param(type = DM_WELD_PARAM, p_data = (char *)&par_weld);

	status =
	DMprocess_weld_form(
		0,
		0,
		0.0,
		me->form,
		me->subform1,
		me->subform2,
		me->subform3,
		me->subform4,
		(me->weld_grid.objid == NULL_OBJID),
		&me->above_input,
		&me->form_display,
		TRUE,
		FALSE,
		&save_data,
		&ignore_data,
		&par_weld);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

end implementation COweld;

