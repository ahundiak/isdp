class implementation COdmcopy;

#define AS_DEBUG 1

#include "dpstruct.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"

from GRvg   import GRgenabsg;
from NDnode import NDget_objects, NDdisplay;
from NDnode import NDgive_structure, NDconnect, NDcopy;
from DMroot import DMplace, leader_needed, get_dim_attr, get_dim_type;
from DMroot import give_previous, set_trak_info, toggle_ter_loca;
from NDnode import NDdelete;

method init(int type; char *string_ptr)
{
	IGRint status;
	IGRint index;

	status =
	om$send(msg = message COdim.init(type, string_ptr),
		targetid = my_id,
		mode = OM_e_wrt_message);
	dm$status(action = RET_STATUS);

	me->msgnumb = DMC_M_DMCpDim;
	me->dim_grid.objid = NULL_OBJID;
	me->meas_grid.objid = NULL_OBJID;
	me->orig_grid.objid = NULL_OBJID;
	me->form_displayed = FALSE;
	me->annot_gt = FALSE;
	me->an_attr.num_brkpt =
	me->an_attr.text_length = FALSE;

	for (index=0; index<MAX_DIM_ROOTS; index++)
	{
		me->list[index].objid =
		me->context[index].objid = NULL_OBJID;
	}

	me->state = STATE_C_LOC_DIM;

	status =
	om$send(msg = message COdim.create_form(0, "DMCopyDim", &me->form),
		targetid = my_id);
	dm$status(action = RET_STATUS);

        ex$message(msgnumb = DM_I_StatFormAvForOpt);

	return(OM_S_SUCCESS);
}

method execute(int *response; char *response_data; int pos)
{
	IGRint status, rc;
	IGRint lockey, acckey, relkey;

	while (TRUE)
	{
		switch (me->state)
		{
		
			/*********************/
			case STATE_C_LOC_DIM:
			/*********************/

			me->dim_grid.objid = NULL_OBJID;

			if (me->annot_gt)
			{
				/*| Free an_attr memory */

				if (me->an_attr.num_brkpt)
				{
					om$dealloc(ptr = me->an_attr.brkpt);
					me->an_attr.num_brkpt = 0;
				}

				if (me->an_attr.text_length)
				{
					om$dealloc(ptr = me->an_attr.text_string);
					me->an_attr.text_length = 0;
				}

				me->annot_gt = FALSE;
			}

			if (me->is_a_complex)
				acckey = DM_P_LocFromC;
			else if (me->meas_needed)
				acckey = DM_P_LocFrom;
			else	acckey = DM_P_LocNewMeas;


			status =
			om$send(msg = message COdim.locate_parent(
							response,
							response_data,
							&me->dim_event,
							TRUE,
							DM_P_LocDim,
							acckey,
							DM_E_Obnofo),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (me->locate_rc == LC_OBJ_LOCATED)
				me->state = STATE_C_LOC_ORIG;
			break;

			/*********************/
			case STATE_C_LOC_ORIG:
			/*********************/

			relkey = DM_E_EltNotFound;

			if (me->annot_gt)
			{
				if (me->dim_type == LEADER_LINE)
				{
					lockey = DM_P_LocRunLdFr;
					acckey = DM_P_LocRunLdTo;
				}
				else
				{
					lockey = DM_P_IdAtt;
					acckey = DM_P_IdAtt;
				}
			}
			else if (me->is_a_complex)
			{
				lockey = DM_P_LocFromC;
				acckey = DM_P_LocTo;
			}
			else if (me->meas_needed)
			{
				lockey = DM_P_LocFrom;
				acckey = DM_P_LocTo;
			}
			else
			{
				lockey = DM_P_LocNewMeas;
				acckey = DM_P_LocNewMeas;
			}

			status =
			om$send(msg = message COdim.locate_parent(
							response,
							response_data,
							&me->orig_event,
							TRUE,
							lockey,
							acckey,
							relkey),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (me->locate_rc == LC_OBJ_LOCATED)
			{
				if (me->meas_needed)
				{
					me->state = STATE_C_LOC_MEAS;
					break;
				}

				status =
				om$send(msg = message COdmcopy.place_dimension(),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message COdmcopy.display_dimension(GRhe),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				me->dim_grid.objid = NULL_OBJID;
			}
			else if (*response == D_RESET)
				me->state = STATE_C_LOC_DIM;
			break;

			/*********************/
			case STATE_C_LOC_MEAS:
			/*********************/

			if (me->dim_type == LEADER_LINE)
			{
				lockey = DM_P_LocRunLdTo;
				acckey = DM_P_LocRunLdFr;
			}
			else
			{
				lockey = DM_P_LocTo;
				acckey = (me->is_a_complex)?
						DM_P_LocTo:
						DM_P_LocFrom;
			}

			relkey = DM_E_EltNotFound;

			status =
			om$send(msg = message COdim.locate_parent(
							response,
							response_data,
							&me->meas_event,
							TRUE,
							lockey,
							acckey,
							relkey),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (me->locate_rc == LC_OBJ_LOCATED)
			{
				status =
				om$send(msg = message COdmcopy.place_dimension(),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message COdmcopy.display_dimension(GRhe),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				if (!me->is_a_complex)
					me->state = STATE_C_LOC_ORIG;
				me->dim_grid.objid = NULL_OBJID;
			}
			else if (*response == D_RESET)
				me->state = STATE_C_LOC_ORIG;
			break;

			/******/
			default:
			/******/

			printf("COdmcopy: Unknown state %d\n", me->state);
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

			status =
			om$send(msg = message COdmcopy.display_form(),
				targetid = my_id);
			dm$status(action = RET_STATUS);
			break;

			case TERMINATE:

			if (me->dim_grid.objid != NULL_OBJID)
			{
				status =
				om$send(msg = message COdmcopy.display_dimension(GRbe),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				status =
				DMdelete_dimension(
					&rc,
					FALSE,
					&me->md_env,
					&me->dim_grid);
				dm$status(action = RET_STATUS);

				nd$exec_batch();
			}

			default:
			return(OM_S_SUCCESS);
		}
	}
}

method LC_preproc(IGRint *msg; struct GRlc_info *lc_info)
{
	IGRint status;
	IGRint acckey;
	struct GRid loc_dim;

	extern GRclassid
		OPP_DMdim_class_id,
		OPP_DMlincpx_class_id,
		OPP_DMsglpara_class_id,
		OPP_DMcirdia_class_id,
		OPP_DMlindia_class_id,
		OPP_DMradjog_class_id,
		OPP_DMcoordj_class_id,
		OPP_DMangular_class_id,
		OPP_DMcenline_class_id,
		OPP_DMtxldr_class_id,
		OPP_DMtxbln_class_id,
		OPP_DMleader_class_id,
		OPP_DMframe_class_id,
		OPP_DMsglarc_class_id,
		OPP_DMweld_class_id;


	me->event1.located_object[0] = *lc_info;

	switch (me->state)
	{
		/*******************/
		case STATE_C_LOC_DIM:
		/*******************/

		loc_dim = lc_info->located_obj;

		status =
		om$send(msg = message DMroot.get_dim_type(&me->dim_type),
			targetid = loc_dim.objid,
			targetos = loc_dim.osnum);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message NDnode.NDget_objects(
						ND_ROOT,
						me->list,
						MAX_DIM_ROOTS,
						NULL,
						0,
						MAX_DIM_ROOTS-1,
						&me->count),
			targetid = loc_dim.objid,
			targetos = loc_dim.osnum);
		dm$status(action = RET_STATUS);

		switch (me->dim_type)
		{
			case STACKED_LINEAR:
			case STRINGED_LINEAR:
			case SYMMETRICAL_DIAMETER:

			me->dim_classid = OPP_DMlincpx_class_id;
			me->is_a_complex = TRUE;
			me->orig_type = POINT_TYPE;
			me->meas_type = POINT_TYPE;
			me->meas_needed = TRUE;
			break;
			
			case STACKED_ANGULAR:
			case STRINGED_ANGULAR:

			me->dim_classid = OPP_DMangular_class_id;
			me->is_a_complex = TRUE;
			me->orig_type = LINE_TYPE;
			me->meas_type = LINE_TYPE;
			me->meas_needed = TRUE;
			break;

			case RADIAL:
			case RADIAL_DIAMETER:

			me->dim_classid = OPP_DMradjog_class_id;
			me->is_a_complex = FALSE;
			me->orig_type = ARC_TYPE;
			me->meas_needed = FALSE;
			break;

			case CIRCULAR_DIAMETER:

			me->dim_classid = OPP_DMcirdia_class_id;
			me->is_a_complex = FALSE;
			me->orig_type = ARC_TYPE;
			me->meas_needed = FALSE;
			break;

			case LINEAR_DIAMETER:

			me->dim_classid = OPP_DMlindia_class_id;
			me->is_a_complex = FALSE;
			me->orig_type = POINT_TYPE;
			me->meas_type = POINT_TYPE;
			me->meas_needed = TRUE;
			break;

			case CENTER_LINE:

			me->dim_classid = OPP_DMcenline_class_id;
			me->is_a_complex = FALSE;
			me->orig_type = ARC_TYPE;
			me->meas_needed = FALSE;
			break;

			case SINGLE_PARALLEL:

			me->dim_classid = OPP_DMsglpara_class_id;
			me->is_a_complex = FALSE;
			me->orig_type = LINE_TYPE;
			me->meas_needed = FALSE;
			break;

			case SINGLE_ARC_LENGTH:

			me->dim_classid = OPP_DMsglarc_class_id;
			me->is_a_complex = FALSE;
			me->orig_type = CIRC_ARC_TYPE;
			me->meas_needed = FALSE;
			break;

			case SINGLE_ARC_ANGLE:

			me->dim_classid = OPP_DMsglarc_class_id;
			me->is_a_complex = FALSE;
			me->orig_type = CIRC_ARC_TYPE;
			me->meas_needed = FALSE;
			break;

			case TEXT_WITH_LEADER:

			me->dim_classid = OPP_DMtxldr_class_id;
			me->is_a_complex = FALSE;
			me->orig_type = POINT_TYPE;
			me->meas_needed = FALSE;
			break;

			case LEADER_LINE:

			me->dim_classid = OPP_DMleader_class_id;
			me->is_a_complex = FALSE;
			me->orig_type = POINT_TYPE;
			me->meas_type = POINT_TYPE;
			me->meas_needed = TRUE;
			break;

			case TEXT_WITH_BALLOON:

			me->dim_classid = OPP_DMtxbln_class_id;
			me->is_a_complex = FALSE;
			me->orig_type = POINT_TYPE;
			me->meas_needed = FALSE;
			break;

			case FEATURE_CONTROL_FRAME:

			me->dim_classid = OPP_DMframe_class_id;
			me->is_a_complex = FALSE;
			me->orig_type = POINT_TYPE;
			me->meas_needed = FALSE;
			break;

			case DATUM_FRAME:

			me->dim_classid = OPP_DMframe_class_id;
			me->is_a_complex = FALSE;
			me->orig_type = POINT_TYPE;
			me->meas_needed = FALSE;
			break;

			case WELD:

			me->dim_classid = OPP_DMweld_class_id;
			me->is_a_complex = FALSE;
			me->orig_type = POINT_TYPE;
			me->meas_needed = FALSE;
			break;

			default:

			printf("LC_prproc: Unknown element selected\n");
			return(OM_E_ABORT);
		}

		me->annot_gt = FALSE;

		if (DMancestry_valid(loc_dim, OPP_DMdim_class_id))
		{
			me->orig_index = DIM_CPX_ORIG;
			me->meas_index = DIM_CPX_MEAS;
			me->attr = (char *)&me->dim_attr;
		}
		else if (DMancestry_valid(loc_dim, OPP_DMcenline_class_id))
		{
			me->orig_index = DIM_CEN_CURVE;
			me->attr = (char *)&me->cen_attr;
		}
		else
		{
			me->orig_index = AN_ROOT_ELEM1;
			me->meas_index = AN_ROOT_ELEM2;
			me->attr = (char *)&me->an_attr;
			me->annot_gt = TRUE;
		}

		status =
		om$send(msg = message DMroot.get_dim_attr(me->attr),
			targetid = loc_dim.objid,
			targetos = loc_dim.osnum);
		dm$status(action = RET_STATUS);

		if (me->dim_type == RADIAL
		||  me->dim_type == RADIAL_DIAMETER)
		{
			/* - Extension arc is always off
			     for the copy - */

			me->dim_attr.mea_trak = 0;
		}

		if (me->annot_gt)
		{
			if ((me->dim_type == WELD) && me->an_attr.leader)
				me->orig_type = LINE_TYPE;
			if (me->dim_type == LEADER_LINE)
				acckey = DM_P_LocRunLdFr;
			else	acckey = DM_P_IdAtt;
		}
		else if (me->is_a_complex)
			acckey = DM_P_LocFromC;
		else if (me->meas_needed)
			acckey = DM_P_LocFrom;
		else	acckey = DM_P_LocNewMeas;

		ex$message(msgnumb = acckey, buff = me->acc_prompt);

		break;

		/********************/
		case STATE_C_LOC_ORIG:
		/********************/

		me->orig_event = me->event1;

		status =
		om$send(msg = message COdmcopy.create_parent(),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		break;

		/*********************/
		case STATE_C_LOC_MEAS:
		/*********************/

		me->meas_event = me->event1;

		status =
		om$send(msg = message COdmcopy.create_parent(),
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

	if (me->dim_grid.objid == NULL_OBJID)
		return(OM_S_SUCCESS);

	if (me->event2.response == RESET ||
	    me->event2.response == D_RESET)
	{
		status =
		om$send(msg = message COdmcopy.display_dimension(GRbe),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message NDnode.NDdelete(&me->md_env),
			mode = OM_e_wrt_message,
			targetid = me->dim_grid.objid,
			targetos = me->dim_grid.osnum);
		if (!(status & 1))
		{
			/*"delete failed\n"*/
		}

		/*- Dimension deleted put back proper DMsrc in
		    orig grid from parent list */

/******************************* START FIX of TR *1759 ********************************/

		me->orig_grid = me->list[me->orig_index];

/********************************* END FIX of TR *1759********************************/

		me->dim_grid.objid = NULL_OBJID;

		nd$exec_batch();
	}

	return(OM_S_SUCCESS);
}

method LC_dynamics(
	IGRint *msg;
	struct GRid *obj;
	struct GRevent *event)
{
	IGRint status;

	switch (me->state)
	{
		case STATE_C_LOC_ORIG:

		if (me->meas_needed) break;

		case STATE_C_LOC_MEAS:

		if ((me->meas_needed) && (me->meas_grid.objid == NULL_OBJID))
			break;

		status =
		om$send(msg = message COdmcopy.place_dimension(),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message COdmcopy.display_dimension(GRhd),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		break;
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method LC_selection(IGRint *msg; struct GRlc_info *lc_info)
{
	IGRint status;
	IGRlong long_rc;
	IGRint sel_type;
	struct IGRbsp_curve *bsp_curve;
	IGRshort sdim_type;
	extern GRclassid OPP_DMroot_class_id;
	extern GRclassid OPP_GRbspline_class_id;

	if (me->state == STATE_C_LOC_DIM
	|| (me->state == STATE_C_LOC_ORIG && me->is_a_complex))
	{
		*msg = DMancestry_valid(
				lc_info->located_obj,
				OPP_DMroot_class_id);

		if (me->state == STATE_C_LOC_DIM)
			return(OM_S_SUCCESS);

		if (*msg)
		{
			status =
			om$send(msg = message DMroot.get_dim_type(&sdim_type),
				targetid = lc_info->located_obj.objid,
				targetos = lc_info->located_obj.osnum);
			dm$status(action = RET_STATUS);

			*msg = (sdim_type == me->dim_type);
			return(OM_S_SUCCESS);
		}
	}

	*msg = DMancestry_valid(lc_info->located_obj, OPP_GRbspline_class_id);
	sel_type = (me->state == STATE_C_LOC_ORIG)?me->orig_type:me->meas_type;

	if (*msg && (sel_type == LINE_TYPE || sel_type == ARC_TYPE))
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

		if (sel_type == LINE_TYPE)
		{
			/* - Linear element is required for single
			     parallel dimension - */

			*msg = (bsp_curve->order == 2 &&
				bsp_curve->num_poles >= 2);
		}
		else
		{
			/* - Curve with more than three poles is
			     required for measuring radius - */

			*msg = (bsp_curve->num_poles >= 3);
		}
	}

	/*"selection=%d\n", *msg*/

	return(OM_S_SUCCESS);
}

method place_dimension()
{
	IGRint status, rc;
	IGRboolean leader;
	IGRint cn_type;
	struct DMmisc_param par_misc;
	struct GRid original;

	if (me->dim_grid.objid != NULL_OBJID)
		return(OM_S_SUCCESS);

	me->dim_grid.osnum = me->md_env.md_id.osnum;
	me->list[me->orig_index] = me->orig_grid;

	if (me->meas_needed)
		me->list[me->meas_index] = me->meas_grid;

	if (me->annot_gt)
	{
		IGRlong long_rc;
		struct ret_struct rst;
		IGRvector diff_vec;
		IGRint i, j;
		IGRdouble *brkpt;

		if (me->dim_type == WELD)
		{
			original = me->dim_event.located_object[0].located_obj;

			status =
			om$send(msg = message NDnode.NDcopy(
						&long_rc,
						0,
						&me->md_env,
						&me->md_env,
						&me->dim_grid),
				targetid = original.objid,
				targetos = original.osnum);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message NDnode.NDconnect(
						me->count,
						me->list,
						original,
						ND_FULL),
				targetid = me->dim_grid.objid,
				targetos = me->dim_grid.osnum);
			dm$status(action = RET_STATUS);

			cn_type = ND_COMP;
			nd$wait_batch(
				type = GR_GEOM_POSTED,
				l_object = &me->dim_grid,
				l_obj_info = &cn_type,
				nb_obj = 1);

			nd$exec_batch();

			status =
			om$send(msg = message NDnode.NDdisplay(
						0,
						GRbd,
						&me->md_env),
				targetid = original.objid,
				targetos = original.osnum);
			dm$status(action = RET_STATUS);

			return(OM_S_SUCCESS);
		}

		status =
		om$send(msg = message NDnode.NDgive_structure(
						&long_rc,
						&rst,
						&me->md_env),
			targetid = me->list[AN_ROOT_ELEM1].objid,
			targetos = me->list[AN_ROOT_ELEM1].osnum);
		dm$status(action = RET_STATUS);

		for (j=0; j<3; j++)
		{
			diff_vec[j] =
			rst.var.point_st.pt[j] - me->an_attr.start_pt[j];
			me->an_attr.start_pt[j] = rst.var.point_st.pt[j];
		}

		for (i=0; i<me->an_attr.num_brkpt; i++)
		{
			brkpt = &me->an_attr.brkpt[3*i];
			for (j=0; j<3; j++)
				brkpt[j] += diff_vec[j];
		}		
	}
	else
	{
		original = me->dim_event.located_object[0].located_obj;
		dm$get_dim_param(
			type = DM_MISC_PARAM,
			dim_objid = original.objid,
			dim_osnum = original.osnum,
			p_data = (char *) &par_misc);
	}

	status =
	om$construct(classid = me->dim_classid,
		p_objid = &me->dim_grid.objid,
		osnum = me->dim_grid.osnum,
		msg = message DMroot.DMplace(
				&rc,
				me->count,
				me->list,
				me->attr,
				&me->md_env));
	dm$status(action = RET_STATUS);

	if (!me->annot_gt)
	{
		status =
		dm$put_dim_param(
			type = DM_MISC_PARAM,
			dim_objid = me->dim_grid.objid,
			dim_osnum = me->dim_grid.osnum,
			p_data = (char *) &par_misc);
		dm$status(action = RET_STATUS);
	}

	status =
	om$send(msg = message DMroot.leader_needed(&rc, &me->md_env, &leader),
		targetid = me->dim_grid.objid,
		targetos = me->dim_grid.osnum);
	dm$status(action = RET_STATUS);

	cn_type = ND_COMP;
	nd$wait_batch(
		type = GR_GEOM_POSTED,
		l_object = &me->dim_grid,
		l_obj_info = &cn_type,
		nb_obj = 1);

	nd$exec_batch();

	if (me->is_a_complex)
		me->orig_grid = me->dim_grid;

	/*- Clean up the meas_grid, so that next time a dimension
	    is created a proper DMsrc is created */

/*************************** START FIX of TR *1759 **************************************/

	me->meas_grid.objid = NULL_OBJID;

/****************************** END FIX  of TR *1759*************************************/

	return(OM_S_SUCCESS);
}

method display_dimension(enum GRdpmode mode)
{
	IGRint status;

	status =
	om$send(msg = message NDnode.NDdisplay(
					0,
					mode,
					&me->md_env),
		targetid = me->dim_grid.objid,
		targetos = me->dim_grid.osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method create_parent()
{
	IGRint status;
	struct GRevent *loc_event;
	IGRint par_type;
	struct DMobj_info *par_info;
	struct GRid *p_root;
	IGRint src_type;
	IGRint num_par;
	struct GRid parents[2];
	struct GRid context[2];
	IGRdouble src_attr[7];

	if (me->state == STATE_C_LOC_ORIG)
	{
		loc_event = &me->orig_event;
		par_type  = me->orig_type;
		par_info  = &me->orig;
		p_root	  = &me->orig_grid;
	}
	else
	{
		loc_event = &me->meas_event;
		par_type  = me->meas_type;
		par_info  = &me->meas;
		p_root	  = &me->meas_grid;
	}


	status =
	om$send(msg = message COdim.load_obj_info(loc_event, par_info),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (DMancestry_valid(par_info->grid, OPP_DMroot_class_id))
	{
		*p_root = par_info->grid;
		return(OM_S_SUCCESS);
	}

	if (me->annot_gt)
	{
		num_par = 1;
		src_type = (par_type == LINE_TYPE)? DMkeypt:DMptdist;
	}
	else if (par_type == ARC_TYPE)
	{
		num_par = 2;
		parents[1] = me->list[DIM_ROOT_PLAN];
		context[1].objid = NULL_OBJID;
		src_type = DMradcen;
	}
	else if (par_type == CIRC_ARC_TYPE)
	{
		num_par = 2;
		parents[1] = me->list[DIM_ROOT_PLAN];
		context[1].objid = NULL_OBJID;
		src_type = DMarc;
	}
	else
	{
		src_type = (par_type == LINE_TYPE)?DMkeyseg:DMkeypt;
		num_par = 1;
	}
	
	parents[0] = par_info->grid;
	context[0] = par_info->context;

	src_attr[0] = par_info->lnproj[0];
	src_attr[1] = par_info->lnproj[1];
	src_attr[2] = par_info->lnproj[2];

	status =
	dm$create_root(
		type = src_type,
		count = num_par,
		list = parents,
		context = context,
		attr = src_attr,
		md_env = &me->md_env,
		p_root = p_root);
	dm$status(action = RET_STATUS);

	/*^ print_grid("meas_grid", &me->meas_grid); */
      
	return(OM_S_SUCCESS);
}

method notify_form(
	int form_label;
	int label;
	double value;
	Form form)
{
	IGRint status, rc;
	IGRboolean first_in_cpx;
	struct GRid prev;

	status =
	FIg_set_value(form, label, 0.0);
	if (status != FI_SUCCESS)
	{
		/*|FIg_set_value fails*/
		return(OM_E_ABORT);
	}

	status =
	FIg_display(form, label);
	if (status != FI_SUCCESS)
	{
		/*|FIg_set_value fails*/
		return(OM_E_ABORT);
	}

	if (label == GAD_TOGGLE_TRAK)
	{
		if (me->dim_grid.objid == NULL_OBJID)
			return(OM_S_SUCCESS);

		status =
		om$send(msg = message DMroot.give_previous(
						&rc,
						&first_in_cpx,
						&prev),
			targetid = me->dim_grid.objid,
			targetos = me->dim_grid.osnum);
		dm$status(action = RET_STATUS);

		if (!first_in_cpx)
			return(OM_S_SUCCESS);

		status =
		om$send(msg = message DMroot.set_trak_info(TOG_TRAK_DIR, NULL),
			targetid = me->dim_grid.objid,
			targetos = me->dim_grid.osnum);
		dm$status(action = RET_STATUS);

		status = DMcomp_obj(me->dim_grid, &me->md_env);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message COdmcopy.display_dimension(GRhd),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else
	{
		status = FIf_erase(me->form);
		if (status != FI_SUCCESS)
		{
			/*|FIf_erase fails*/
			return(OM_E_ABORT);
		}

		me->form_displayed = FALSE;
	}

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

	if (me->form_displayed)
	{
		status = FIf_display(me->form);
		if (status != FI_SUCCESS)
		{
			/*|FIf_display fails*/
			return(OM_E_ABORT);
		}
	}

        ex$message(msgnumb = DM_I_StatFormAvForOpt);
        GRstatus_display_button(1);

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

	status = FIf_erase(me->form);
	if (status != FI_SUCCESS)
	{
		/*|FIf_erase fails*/
		return(OM_E_ABORT);
	}

        ex$message(msgnumb = GR_I_Clear);
        GRstatus_display_button(0);

	return(OM_S_SUCCESS);
}

method delete(int f_defer_flag)
{
	IGRint status;

	status =
	om$send(msg = message COdim.delete(f_defer_flag),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (me->annot_gt)
	{
		/*| Free an_attr memory */

		if (me->an_attr.num_brkpt)
		om$dealloc(ptr = me->an_attr.brkpt);

		if (me->an_attr.text_length)
		om$dealloc(ptr = me->an_attr.text_string);
	}

	status = FIf_delete(me->form);
	if (status != FI_SUCCESS)
	{
		/*|FIf_delete fails*/
		return(OM_E_ABORT);
	}

	return(OM_S_SUCCESS);
}

method display_form()
{
	IGRint status;

	if (me->form_displayed)
		return(OM_S_SUCCESS);

	status =
	FIg_set_value(
		me->form,
		GAD_CHECK,
		(double)0.0);
	if (status != FI_SUCCESS)
	{
		/*|FIg_set_value GAD_CHECK*/
		return(OM_E_ABORT);
	}

	status =
	FIg_set_value(
		me->form,
		GAD_TOGGLE_TRAK,
		(double)0.0);
	if (status != FI_SUCCESS)
	{
		/*|FIg_set_value TYPE*/
		return(OM_E_ABORT);
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

end implementation COdmcopy;
