/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:30 $
$Locker:  $
$Log: surfco.I,v $
Revision 1.1.1.1  2001/12/17 22:39:30  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:07:57  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:21:56  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:51:25  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.5  1994/11/01  10:12:05  gvk
# COMMENT : Included prototypes for BSfunctions and GRNUC calls which return double.
#
# Revision 240.4  1994/08/10  21:52:42  grnuc40
# COMMENT : Upgrade due to Intel Solaris port
#
# Revision 240.3  1993/08/16  13:35:45  mike
# COMMENT : Hilite the Status Display Button.
#
# Revision 240.2  1993/06/07  05:12:30  laxmi
# COMMENT : Dimesioning fixes checkin. Laxmi 7 June 1993.
#
# Revision 220.1  1992/10/30  23:35:46  poo
# COMMENT : Command Terminated properly(2.1 fix into 2.2)
#
# Revision 201.7  1992/10/28  20:58:57  gvk
# COMMENT : Send supercmd without checks
#
# Revision 201.6  1992/10/06  20:52:56  poo
# COMMENT : Fix for Surface Texture Symbol placed on polygon
#
# Revision 201.5  1992/10/06  17:44:05  poo
# COMMENT : Prompt change for Surface Texture Symbol.
#
# Revision 201.4  1992/09/30  04:25:25  laxmi
# COMMENT : Made fixes for the trs in surface texture symb
#
*/

class implementation COsurf;

#define AS_DEBUG 1

#include "bsvalues.h"
#include "dimannot.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"

extern IGRboolean 	BSproj1();

#define STATE_P_LOC_ELEMENT 0
#define STATE_P_GET_EVENT 1

extern GRclassid OPP_DMsurf_class_id;
extern GRclassid OPP_GRbspline_class_id;
extern GRclassid OPP_GR3dpoint_class_id;

from GRvg import GRgenabsg;
from DMroot import DMplace;
from DMroot import set_dim_state;
from NDnode import NDdelete;
from NDnode import NDs_compute_node;
from DMannot import ANadd_delete_vertex;
from DMsrc import DMdisplay_source, DMmodify;
IGRboolean first;

method init(int type; char *string_ptr)
{
	IGRint status;
	IGRint index;

	status = 
	om$send(msg = message COdim.init(type, string_ptr),
		targetid = my_id,
		mode = OM_e_wrt_message);
	dm$status(action = RET_STATUS);

	me->leader = TRUE;
	me->form_display = FALSE;
	me->state = STATE_P_LOC_ELEMENT;
	me->surf_grid.objid = NULL_OBJID;
	me->prev_surf.objid = NULL_OBJID;

	me->mask1 |= GRm_STRING;
	me->mask2 |= GRm_STRING;

        for (index=0; index < NO_TEXT_LEADER_ROOTS; index++)
        {
                me->list[index].objid =
                me->context[index].objid = NULL_OBJID;
        }

	status =
        om$send(msg = message COdim.create_form(SURF_FORM,"DMSurf",
                                                &me->form),
                targetid = my_id);
        dm$status(action = RET_STATUS);

        status =
        om$send(msg = message COdim.create_form(SURF_SUB_FORM,"DMSubSurf",
                                                &me->subform),
                targetid = my_id);
        dm$status(action = RET_STATUS);

	status =
        om$send(msg = message COsurf.init_type(),
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

        me->msgnumb = DMC_M_DMPlSrTxSy;
        me->loc_key = DM_P_LocElLd;
        me->acc_key = DM_P_PosBrkPtR;
        me->rel_key = DM_E_EltNotFound;

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

        if(me->form_display)
        {
                me->form_display = FALSE;

                status =
                om$send(msg = message COsurf.display_form(),
                                targetid = my_id);
                dm$status(action = RET_STATUS);

		ex$message(msgnumb = DM_I_StatFormAvForOpt);
                GRstatus_display_button(1);
        }

        set_inq = 1;
        DPdynflags(&msg,&set_inq,&me->dynamics_on,NULL);

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

        if (me->form_display)
	{
		status =
		FIf_erase(me->form);
		if (status != FI_SUCCESS)
		{
			printf("FIf_erase() failed\n");
			return(OM_E_ABORT);
		}
	}

	ex$message(msgnumb = GR_I_Clear);
        GRstatus_display_button(0);

        return(OM_S_SUCCESS);
}

method delete(int f_defer_flag)
{
        IGRint status;


        if (me->form)
        {
                status = FIf_delete(me->form);
                if (status != FI_SUCCESS)
                {
                        /*|FIf_delete fails*/
                        return(OM_E_ABORT);
                }
        }
        if (me->subform)
        {
                status = FIf_delete(me->subform);
                if (status != FI_SUCCESS)
                {
                        /*|FIf_delete fails*/
                        return(OM_E_ABORT);
                }
        }

        if (me->surf_grid.objid != NULL_OBJID)
        {
                status =
                om$send(msg = message COsurf.delete_dimension(),
                        targetid = my_id);
                dm$status(action = RET_STATUS);
        }

        /*| delete dimension */
        status =
        om$send(msg = message COdim.delete(f_defer_flag),
        	targetid = my_id,
		mode = OM_e_wrt_message);
        dm$status(action = RET_STATUS);
	return(OM_S_SUCCESS);
}
   
method LC_selection(IGRint *msg; struct GRlc_info *lc_info)
{
        struct IGRbsp_curve *bsp_curve;
        IGRlong long_rc,status;
        *msg = OM_S_SUCCESS;

       
        *msg = DMancestry_valid(lc_info->located_obj, OPP_GRbspline_class_id);

	if( *msg && !me->leader)
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

                /*"order=%d, nump=%d\n", bsp_curve->order, bsp_curve->num_poles */

                *msg = (bsp_curve->order == 2);
		if (*msg)
                *msg = !(DMancestry_valid(lc_info->located_obj, OPP_GR3dpoint_class_id));
        }
        return(OM_S_SUCCESS);
}

method LC_preproc(
	IGRint *msg;
	struct GRlc_info *lc_info)
{
	IGRint status;

	me->event1.located_object[0] = *lc_info;
	me->loc_event = me->event1;

	if(me->state == STATE_P_LOC_ELEMENT)
	{		
		status =
		om$send(msg = message COsurf.create_arrow(),
			targetid = my_id);
		dm$status(action = RET_STATUS);
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
		/*|- Deleting dimension */

		status =
		om$send(msg = message COsurf.delete_dimension(),
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
		if (me->surf_grid.objid == NULL_OBJID)
		{
			status =
			om$send(msg = message COsurf.place_dimension(),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}	

		status =
		om$send(msg = message COsurf.set_dim_state(
					DIM_IN_PLACEMENT |
					DIM_NEEDS_UPDATE),
			targetid = my_id);
		dm$status(action = RET_STATUS);
		
		status =
		om$send(msg = message COsurf.position_dim(
					(me->leader)?DM_P_PosBrkPtR:DM_P_DataPt,
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

method place_dimension()
{
	IGRint status, rc;

	if (me->surf_grid.objid != NULL_OBJID)
		return(OM_S_SUCCESS);

	status =
	om$send(msg = message COsurf.get_dim_plane(),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COsurf.set_dim_attr(),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COsurf.get_dim_param(),
		targetid = my_id);
	dm$status(action = RET_STATUS);


	/*^ printf("mytype:%d\n",me->mytype); */

	me->surf_grid.osnum = me->md_env.md_id.osnum;

	status =
	om$construct(
		classid = OPP_DMsurf_class_id,
		p_objid = &me->surf_grid.objid,
		osnum = me->surf_grid.osnum,
		msg = message DMroot.DMplace(
					&rc,
					NO_TEXT_LEADER_ROOTS,
					me->list,
					(char *)&me->an_attr,
					&me->dyn_env));
	dm$status(action = RET_STATUS);

	me->prev_surf.objid = NULL_OBJID;

	return(OM_S_SUCCESS);
}

method set_dim_state(IGRshort dim_state)
{
	IGRint status;

	if (me->surf_grid.objid != NULL_OBJID)
	{
		status =
		om$send(msg = message DMroot.set_dim_state(BIT_SET, dim_state),
			targetid = me->surf_grid.objid,
			targetos = me->surf_grid.osnum);
		dm$status(action = RET_STATUS);
	}

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
		dim_grid = &me->surf_grid,
		event = &me->event1);
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

method set_dim_attr()
{
	me->an_attr.dim_type	= me->mytype;
	me->an_attr.geom_type   = 0;
	me->an_attr.display	= 0;
	me->an_attr.dim_state	= DIM_IN_PLACEMENT | DIM_NEEDS_UPDATE;
	me->an_attr.leader 	= me->leader;
	me->an_attr.text_length = 0;
	me->an_attr.text_string = NULL;
	me->an_attr.num_brkpt  = 0;
	me->an_attr.dual_mode = 0;
	me->an_attr.brkpt      = NULL;
	me->an_attr.tol_symbol = 0;
	me->an_attr.bln_dir    =  0; 

	return(OM_S_SUCCESS);
}

method get_dim_param()
{
	IGRint status;

	status =
	dm$get_dim_param(type = DM_SENV_PARAM, 
		p_grid = &me->list[DIM_ROOT_SENV]);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method create_arrow()
{
	IGRint status;
	IGRdouble *attr;
	
	status =
	om$send(msg = message COdim.load_obj_info(&me->loc_event, &me->arrow),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COsurf.get_dim_plane(),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	attr = &me->arrow.lnproj[0];

	status=
	dm$create_root(
		type = DMptdist,
		count = 1,
		list  = &me->arrow.grid,
		context = &me->arrow.context,
		attr = attr,
		md_env = &me->md_env,
		p_root = &me->list[AN_ROOT_ELEM1]);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method delete_dimension()
{
	IGRint status;

	if (me->surf_grid.objid == NULL_OBJID)
	{
		/*| No such dimension exists */
		return(OM_S_SUCCESS);
	}

	status =
	om$send( msg = message NDnode.NDdelete(&me->dyn_env),
		mode = OM_e_wrt_message,
		targetid = me->surf_grid.objid,
		targetos = me->surf_grid.osnum);
	if (!(status & 1))
	{
		/*"delete fails\n" */
	}

	me->surf_grid.objid = NULL_OBJID;

	return(OM_S_SUCCESS);
}

method execute(int *response; char *response_data; int pos)
{
	IGRint status, rc;
	IGRint msgkey;
	IGRlong long_rc;
	IGRchar string[128];
	extern struct DMsurf_param frm_surf;

	while(TRUE)
	{
		if ((me->event1.response == EX_SINIT) &&
                        (me->surf_grid.objid != NULL_OBJID))
                {
                        /*|- Erase the dimension, cmd restarted*/

                        status =
                        DMdisplay_dimension(
                                &rc,
                                ROOT | CHILDREN,
                                ERASE | REMWRNG,
                                &me->md_env,
                                &me->surf_grid);
                        dm$status(action = RET_STATUS);
                }
		
                switch(me->state)
                {
                        /*************************/
                        case STATE_P_LOC_ELEMENT:
                        /*************************/

			first = TRUE;
			if (me->leader)
				me->loc_key = DM_P_LocElLd;
			else	me->loc_key = DM_P_LocRunLdFr;

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
			else if(*response == RESET)
				me->leader = FALSE;
			else if(*response == D_RESET)
			{
				if( me->prev_surf.objid != NULL_OBJID)
				{
					me->surf_grid.objid = me->prev_surf.objid;
					me->surf_grid.osnum = me->prev_surf.osnum;
					me->prev_surf.objid = NULL_OBJID;
					me->state = STATE_P_GET_EVENT;

                		        status =
		                        DMdisplay_dimension(
                                		&rc,
                		                ROOT | CHILDREN,
		                                ERASE | REMWRNG,
                                		&me->md_env,
                		                &me->surf_grid);
		                        dm$status(action = RET_STATUS);
				}
				else	me->leader = TRUE;
			}
			
			break;

			/*********************/
			case STATE_P_GET_EVENT:
			/*********************/

			if (me->leader)
				msgkey = DM_P_PosBrkPtM;
			else	msgkey = DM_P_DataPt;			

			status =
			om$send(msg = message COsurf.place_dimension(),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message COsurf.position_dim(
						msgkey,
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
							msgkey,
							response,
							response_data,
							&me->event1),
				targetid = my_id);
			dm$status(action = RET_STATUS);
			if (first)
			{
				first = FALSE;
				strcpy(response_data,"\0");
			}
			
			/*^printf("getevnt : data point:%lf:%lf:%lf\n",me->event1.event.button.x,
							me->event1.event.button.y,
							me->event1.event.button.z);*/
						
			if( *response == DATA)
			{
				/*|- response is DATA */

				status =
				om$send(msg = message COsurf.position_dim(
							msgkey,
							FALSE,
							NULL,
							NULL,
							MOVE_BREAK_PT,
							NULL,
							NULL),
					targetid = my_id);
				dm$status(action=RET_STATUS);
				
				if (me->leader)
				{
					/*| - Add a vertex */

					status = 
					om$send(msg = message DMannot.ANadd_delete_vertex(
								&rc,
								ADD_VERTEX,
								NULL,
								&me->dyn_env),
						targetid = me->surf_grid.objid,
						targetos = me->surf_grid.osnum);
					dm$status(action= RET_STATUS);
					
					status =
					om$send(msg = message COsurf.set_dim_state(
								DIM_IN_PLACEMENT |
								DIM_NEEDS_UPDATE ),
						targetid = my_id);
					dm$status(action = RET_STATUS);
				}
				else
				{
					status =
					om$send(msg = message COsurf.update_src
								(&me->event1),
						targetid = my_id);
					dm$status(action = RET_STATUS);

					om$send(msg = message NDnode.NDs_compute_node(
							&long_rc,
							0,
							&me->dyn_env),
						targetid = me->surf_grid.objid,
						targetos = me->surf_grid.osnum);
					dm$status(action = RET_STATUS);

					status =
					om$send(msg = message COsurf.display_dimension(
							ROOT,
							DISPLAY | ADDWRNG),
						targetid = my_id);
					dm$status(action = RET_STATUS);

					me->prev_surf.objid = me->surf_grid.objid;
					me->prev_surf.osnum = me->surf_grid.osnum;
					me->surf_grid.objid = NULL_OBJID;
					me->state = STATE_P_LOC_ELEMENT;
					me->leader = TRUE;
				}
			}
			else if (*response == RESET)
			{
				if (me->leader)
				{
					/*| - Delete Vertex  */

					status = 
					om$send(msg = message DMannot.ANadd_delete_vertex(
								&rc,
								DELETE_VERTEX,
								NULL,
								&me->dyn_env),
						targetid = me->surf_grid.objid,
						targetos = me->surf_grid.osnum);
					dm$status(action= RET_STATUS);

					status =
					om$send(msg = message NDnode.NDs_compute_node(
								&long_rc,
								0,
								&me->dyn_env),
						targetid = me->surf_grid.objid,
						targetos = me->surf_grid.osnum);
					dm$status(action = RET_STATUS);

					status =
					om$send(msg = message COsurf.display_dimension(
								ROOT,
								DISPLAY | ADDWRNG),
						targetid = my_id);
					dm$status(action = RET_STATUS);

					me->prev_surf.objid = me->surf_grid.objid;
					me->prev_surf.osnum = me->surf_grid.osnum;
					me->surf_grid.objid = NULL_OBJID;
					me->state = STATE_P_LOC_ELEMENT;
				}
			}
			else if (*response == D_RESET)
			{
				if (me->leader)
				{
					status = 
					om$send(msg = message DMannot.ANadd_delete_vertex(
							&rc,
							DELETE_VERTEX,
							NULL,
							&me->dyn_env),
						targetid = me->surf_grid.objid,
						targetos = me->surf_grid.osnum);
					dm$status(action= RET_STATUS);
				
					if (!rc) me->state = STATE_P_LOC_ELEMENT;
				}
				else
				{
					status =
					om$send(msg = message COsurf.delete_dimension(),
						targetid = my_id);
					dm$status(action = RET_STATUS);

					if (me->prev_surf.objid != NULL_OBJID)
					{
						me->surf_grid.objid = me->prev_surf.objid;
						me->surf_grid.osnum = me->prev_surf.osnum;
						me->prev_surf.objid = NULL_OBJID;

        	        		        status =
			                        DMdisplay_dimension(
                                			&rc,
                			                ROOT | CHILDREN,
		        	                        ERASE | REMWRNG,
                	                		&me->md_env,
        	        		                &me->surf_grid);
			                        dm$status(action = RET_STATUS);
					}
					else
					{
						me->leader = TRUE;
						me->state = STATE_P_LOC_ELEMENT;
					}
				}
			}
			break;

			default:
			printf("COsurf: Unknown state %d\n", me->state);
			*response = TERMINATE;
			return(OM_S_SUCCESS);
		}

		switch (*response)
		{
			case STRING:
		        case EX_CMD_KEY:
                        case CMD_STRING:

                        strcpy(string, response_data);
                        DMupper_to_lower(string);

                        /*"response_data = <%s>\n", response_data*/

                        if (DMstrequ(string, "invert"))
                        {
				if ( frm_surf.sym_posn == SURF_ABOVE )
					frm_surf.sym_posn = SURF_BELOW;
				else    frm_surf.sym_posn = SURF_ABOVE;

                		status =
                		om$send(msg = message COsurf.set_dim_state(
                               		         DIM_NEEDS_UPDATE |
                               		         DIM_IN_PLACEMENT),
                        		targetid = my_id);
                		dm$status(action = RET_STATUS);
				strcpy(response_data,"\0");

				break;
			}

			return(OM_S_SUCCESS);

			case DATA:
			case RESET:
			case D_RESET:
			case MOVE_ON:
			break;

			case TERMINATE:

			if (me->surf_grid.objid != NULL_OBJID)
			{
				status =
				om$send(msg = message COsurf.delete_dimension(),
					targetid = my_id);
				dm$status(action = RET_STATUS);
			}
			return(OM_S_SUCCESS);

			case STATUS_DISP:

			status = 
			om$send(msg = message COsurf.display_form(),
					targetid = my_id);
			dm$status(action = RET_STATUS);
			break;

			default:
			/*^ printf("response:%d\n",*response); */
			return(OM_S_SUCCESS);

		}
	}
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
		&me->surf_grid);
	dm$status(action = RET_STATUS);

	dim_state = (control & DISPLAY)?0:DIM_IN_PLACEMENT;

	status =
	om$send(msg = message COsurf.set_dim_state(dim_state),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method display_form()
{
	IGRint status;
	IGRboolean update, ignore, ansi;
	extern struct DMenv_param frm_env;
	extern struct DMsurf_param frm_surf;

	ansi = ((frm_env.pri_unit == MEA_UNIT_FEET_INCHES)
		|| (frm_env.pri_unit == MEA_UNIT_INCHES));

	status =
	DMprocess_surf_form(
			TRUE,
			&me->form_display,
			ansi,
			&update,
			&ignore,
			FALSE,
			0,
			0,
			0.0,
			me->form,
			me->subform,
			&frm_surf);
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
	IGRboolean update, ignore, ansi;
	extern struct DMenv_param frm_env;
	extern struct DMsurf_param frm_surf;

	ansi = ((frm_env.pri_unit == MEA_UNIT_FEET_INCHES)
		|| (frm_env.pri_unit == MEA_UNIT_INCHES));

	status =
	DMprocess_surf_form(
			FALSE,
			&me->form_display,
			ansi,
			&update,
			&ignore,
			FALSE,
			form_label,
			label,
			value,
			me->form,
			me->subform,
			&frm_surf);
	dm$status(action = RET_STATUS);

	if (update)
	{
		status =
		om$send(msg = message COsurf.set_dim_state(
					DIM_NEEDS_UPDATE |
					DIM_IN_PLACEMENT),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method update_src(struct GRevent *event)
{
	IGRint status, rc, display, project;
	struct IGRline boreline;
	struct GRid win_grid;
	IGRdouble point2[3], point1[3], tolerance;
	struct dim_ret_struct dim_str;
	
	/* fill the window grid from event */
	win_grid.objid = event->event.button.objid;
	win_grid.osnum = event->event.button.osnum;

	/* get the tolerance band from the current window */

	DMget_dit_tol(&win_grid, &tolerance);

	status =
	om$send(msg = message COsurf.get_dim_plane(),
		targetid= my_id);
	dm$status(action=RET_STATUS);

	status =
	DMsrc_give_structure(
		&rc,
		DIM_NO_INDEX,
		ORIG_INFO,
		FALSE,
		FALSE,
		me->list[AN_ROOT_ELEM1].objid,
		me->surf_grid.objid,
		me->list[AN_ROOT_ELEM1].osnum,
		&me->md_env,
		&dim_str);
	dm$status(action = RET_STATUS);

	status =
	BSproj1(&rc,
		&event->event.button.x,
		&me->plan_info.win_plan.matrix[8],
		dim_str.var.dm_ptdist.point,
		point1);
	dm$status(action = RET_STATUS);

	boreline.point1 = point1;

	point2[0] = boreline.point1[0] +
				me->plan_info.act_plan.matrix[8];
	point2[1] = boreline.point1[1] +
				me->plan_info.act_plan.matrix[9];
	point2[2] = boreline.point1[2] +
				me->plan_info.act_plan.matrix[10];

	boreline.point2 = point2;
		
	/*^
		print_point("boreline pt1",boreline.point1); 
	    	print_point("boreline pt2",boreline.point2);
	 */

	status =
	om$send(msg = message DMsrc.DMdisplay_source(
						&rc,
						&tolerance,
						&boreline,
						&display,
						&me->md_env),
		targetid = me->list[AN_ROOT_ELEM1].objid,
		targetos = me->list[AN_ROOT_ELEM1].osnum);
	dm$status(action = RET_STATUS);

	if( display )
		project = 0;
	else	project = 1;

	status =
	om$send(msg = message DMsrc.DMmodify(
					&rc,
					&me->md_env,
					project,
					me->leader,
					&boreline),
		targetid = me->list[AN_ROOT_ELEM1].objid,
		targetos = me->list[AN_ROOT_ELEM1].osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

end implementation COsurf;
