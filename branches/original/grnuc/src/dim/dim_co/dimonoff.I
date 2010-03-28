class implementation COdimonoff;

#define AS_DEBUG 1

#include "exfi.h"
#include "DMmsg.h"
#include "grmsg.h"
#include "DMcmd.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"

%safe
#include "math.h"
%endsafe

extern IGRboolean display_invisible_dims;
extern IGRboolean display_reffile_dims;
extern IGRboolean display_different_dims;
extern IGRboolean display_ref_diff_dims;
extern IGRint Imp_count, Disp_count, Dim_count;
extern struct DMglobal_param frm_glob;
extern GRclassid OPP_expression_class_id;
extern double fabs();

%safe
static char *standard[5] = {"ANSI", "ISO", "BSI", "JIS", "DIN"};
static char *format[5] = {"Nominal", "Up_low", "Symbol", "Limits", "Box"};
static char *fraction[7] = {"1", "1/2", "1/4", "1/8", "1/16", "1/32", "1/64"};
static char *decimal[9] = {"1", ".1", ".12", ".123", ".1234", ".12345", ".123456", ".1234567", "10"};
static char *lin_units[4] = {"ft-in", "meters", "mm", "inches"};
static char *ang_units[3] = {"Deg-Min-Sec", "Radians", "Degrees"};
static char *ang_roff_unit[3] = {"Degrees", "Minutes", "Seconds"};
static char *lin_roff[2] = {"Decimal", "Fraction"};
%endsafe

from GRgraphics import GRdisplay;
from DMroot     import set_display_type, set_geom_type;
from DMroot     import get_dim_type, inq_display_type;
from DMroot	import import_dimension, GLupdate;
from DMroot	import get_compare_info;
from DMdim	import get_dim_value;

from IGEgragad	import DPinrot;

#define STATE_INITIAL		0
#define STATE_LOC_DIM_FEATURE	1
#define STATE_LOC_DIM_FEATURE_2	2
#define STATE_LOC_FEATURE	3
#define STATE_LOC_FEATURE_2	4
#define STATE_LOC_DIM		5
#define STATE_LOC_DIM_2		6
#define STATE_ID_VIEW		7

method init(int type; char *string_ptr)
{
	IGRint status;

	status =
	om$send(msg = message COdim.init(type, string_ptr),
		targetid = my_id,
		mode = OM_e_wrt_message);
	dm$status(action = RET_STATUS);

	if (type == 0)		me->msgnumb = DMC_M_HdDm;
	else if (type == 1)	me->msgnumb = DMC_M_ShDm;
	else if (type == 2)	me->msgnumb = DMC_M_TgDmNmVl;
	else if (type == 3)	me->msgnumb = DMC_M_Retrieve;
	else if (type == 4)	me->msgnumb = DMC_M_DMCmDM;

	me->attr.owner_action = LC_RIGID_COMP | LC_RIGID_OWNER |
				LC_FLEX_COMP  | LC_NO_REF_HEADER |
				LC_HANDLES;

	me->attr.properties = LC_LC_ONLY | LC_DP_ONLY;
	me->display_flag = ALL_WINDOWS | ELEM_HILIGHT |
			   NO_PROJ_ACCEPT_POINT |
			   ACC_REJ_CYCLE | RELOCATE |
			   LC_REGULAR_HIGHLIGHT |
			   LC_ACCEPT_CURSOR;

	me->state = STATE_INITIAL;
	me->lc_dyn.GRlc_dyn = NULL;
	me->rel_key = DM_E_EltNotFound;
	me->namval = FALSE;
	me->form_displayed = FALSE;

	if (me->mytype == 3)
	   me->attr.owner_action |= LC_REF_OBJECTS;

	if (me->mytype == 4)
	{
		status =
		om$send(msg = message COdim.create_form(0, "DMCompare", &me->form),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	return(OM_S_SUCCESS);
}

method wakeup(int pos)
{
	IGRint status, type;

	ex$message(msgnumb = me->msgnumb);

	if (((me->mytype == 0) || (me->mytype == 1))
	&& (frm_glob.dim_mode == DETAILING_MODE))
		return(OM_S_SUCCESS);

	if (((me->mytype == 3) || (me->mytype == 4))
	&& (frm_glob.dim_mode == MODELING_MODE))
		return(OM_S_SUCCESS);

	if (((me->mytype == 1) &&
		((me->state == STATE_LOC_DIM) ||
		 (me->state == STATE_LOC_DIM_2)))
	|| (me->mytype == 3))
	{
		type = (me->mytype == 1)?DIMS_IN_CUROS:DIMS_IN_REFOS;

		DMdisplay_invisible(
			type,
			&me->md_env);
	}

	if (me->mytype == 4)
	{
		DMcompare_dim(FALSE, &me->md_env);

		status =
		DMdisplay_update(
			(char)'\0',
			(char)'\0',
			DIM_IS_DIFFERENT,
			DIM_IS_DIFFERENT,
			TRUE,
			TRUE,
			FALSE,
			GRhhd,
			NULL,
			PASS_TO_CUROS,
			&me->md_env);
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

	return( OM_S_SUCCESS);
}

method super_cmd.sleep(int pos)
{
	IGRint msg, status;

        ex$message(msgnumb = GR_P_Clear);
        ex$message(msgnumb = GRC_M_Clear);

	dp$erase_hilite(msg = &msg);
	display_invisible_dims = FALSE;
	display_reffile_dims = FALSE;
	display_different_dims = FALSE;

	if (me->mytype == 4)
	{
		DMcompare_dim(TRUE, &me->md_env);
	}

	if (me->form_displayed)
	{
		status = FIf_erase(me->form);
		if (status != FI_SUCCESS)
		{
			/*|FIf_erase fails*/
			return(OM_E_ABORT);
		}
	}

	return(OM_S_SUCCESS);
}

method execute(int *response; char *response_data; int pos)
{
	IGRint status, rc, num_win, num_found;
	IGRchar d_type, d_mask, disp_type_sav;
	IGRchar g_type, g_mask;
	IGRmatrix vw_rot;
	struct GRid win;

	if (((me->mytype == 3) || (me->mytype == 4))
	&& (frm_glob.dim_mode == MODELING_MODE))
	{
		ex$message(msgnumb = DM_I_SetDet);
		*response = TERMINATE;
		return(OM_S_SUCCESS);
	}

	if (((me->mytype == 0) || (me->mytype == 1))
	&& (frm_glob.dim_mode == DETAILING_MODE))
	{
		ex$message(msgnumb = DM_I_SetMod);
		*response = TERMINATE;
		return(OM_S_SUCCESS);
	}

	while (TRUE)
	{
	    switch (me->state)
	    {
		case STATE_INITIAL:

		me->acc_key = DM_P_AcDim;
		if (me->mytype == 0)
			me->loc_key = DM_P_LocDimFeaM;
		else if (me->mytype == 1)
		{
			me->loc_key = DM_P_LocFeaM;
			me->acc_key = DM_P_AcFea;
		}
		else if (me->mytype == 2)
			me->loc_key = (me->namval)?DM_P_LocDimFeaM:
						DM_P_LocFeaNam;
		else if (me->mytype == 3)
			me->loc_key = DM_P_LocDimRet;
		else if (me->mytype == 4)
			me->loc_key = DM_P_LocDim;

		break;

		case STATE_LOC_DIM_FEATURE:

		if (me->mytype == 2)
		{
		   me->loc_key = (me->namval)?DM_P_IdDimFeaV:
					DM_P_IdDimFeaN;
		   me->acc_key = DM_P_AcDimFea;
		}
		else	me->loc_key = DM_P_IdDimFeaM;
		me->acc_key = DM_P_AcFea;
		break;
		
		case STATE_LOC_FEATURE:

		me->loc_key = DM_P_IdFeaM;
		me->acc_key = DM_P_AcFea;
		break;

		case STATE_LOC_DIM:

		if (me->mytype == 1)
			me->loc_key = DM_P_LocDimM;
		else	me->loc_key = DM_P_LocDim;

		me->acc_key = DM_P_AcDim;
		break;

		case STATE_LOC_DIM_2:

		me->loc_key = DM_P_IdDimM;
		me->acc_key = DM_P_AcDim;
		break;
	   }

	   if (((me->mytype == 1) && ((me->state == STATE_LOC_DIM)
	   || (me->state == STATE_LOC_DIM_2)))
	   ||  (me->mytype == 3))
		me->display_flag |= LC_ERASE_LOC_ELEMENT;
	   else	me->display_flag &= (~LC_ERASE_LOC_ELEMENT);

	   if (me->state == STATE_ID_VIEW)
	   {
		win.objid = NULL_OBJID;

		/* Check the number of windows if only one
		   present skip this state */

		status =
		dp$get_gragad_id(
			msg = &rc,
			array_size=1,
			name= "*",
			total_num=&num_win,
			numberofids=&num_found,
			found_GRids=&win,
			type_gragad= IGE_GG|ACTIVE_GG);

		if (num_win > 1)
		{
			/*| - Identify Window */

			status =
			om$send(msg = message COdim.getevent(
						GR_P_IdWin,
						response,
						response_data,
						&me->event1),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			switch(me->event1.response)
			{
				case DATA:
				win.objid = me->event1.event.button.objid;
				win.osnum = me->event1.event.button.osnum;
				break;
	
				case TERMINATE:
				return(OM_S_SUCCESS);

				default:
				me->state = STATE_INITIAL;
				break;
			}
		}

		if (win.objid != NULL_OBJID)
		{
			status =
			om$send(msg = message IGEgragad.DPinrot(
						(IGRlong *) &rc,
						vw_rot),
				targetid = win.objid,
				targetos = win.osnum);
			dm$status(action = RET_STATUS);

			Dim_count = Disp_count = 0;
			disp_type_sav = frm_glob.disp_type;
			frm_glob.disp_type = DISPLAY_PARALLEL;

			status =
			DMdisplay_update(
				(char)'\0',
				(char)'\0',
				(char)'\0',
				(char)'\0',
				FALSE,
				TRUE,
				TRUE,
				GRhd,
				vw_rot,
				PASS_TO_REFOS,
				&me->md_env);
			dm$status(action = RET_STATUS);

			frm_glob.disp_type = disp_type_sav;

			if (Disp_count > 0)
			{
				status =
				om$send(msg = message COdim.getevent(
						DM_P_Ac,
						response,
						response_data,
						&me->event1),
						targetid = my_id);
				dm$status(action = RET_STATUS);

				dp$erase_hilite(msg = &rc);

				switch(me->event1.response)
				{
					case DATA:

					me->event1.event.button.objid = win.objid;
					me->event1.event.button.osnum = win.osnum;
	
					status =
					om$send(msg = message COdimonoff.set_dim_disp(TRUE),
						targetid = my_id);
					dm$status(action = RET_STATUS);
					break;
	
					case STRING:
					case CMD_STRING:
					case EX_CMD_KEY:
					case TERMINATE:
					return(OM_S_SUCCESS);
				}
			}

			DMdisplay_invisible(DIMS_IN_REFOS, &me->md_env);
			me->state = STATE_INITIAL;
		}
	    }
	    else
	    {
		/*| - Locate dim/feature */

		if (me->mytype == 4)
		{
			status =
			DMdisplay_update(
				(char)'\0',
				(char)'\0',
				DIM_IS_DIFFERENT,
				DIM_IS_DIFFERENT,
				FALSE,
				TRUE,
				FALSE,
				GRhhd,
				NULL,
				PASS_TO_CUROS,
				&me->md_env);
			dm$status(action = RET_STATUS);
		}

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

		/*^ printf("response = %d\n", *response); */

		if (me->locate_rc == LC_OBJ_LOCATED)
		{
			/*|- object Located */

			if (me->mytype != 4)
			{
				status =
				om$send(msg = message COdimonoff.set_dim_disp(FALSE),
					targetid = my_id);
				dm$status(action = RET_STATUS);
			}
		}
		else
		{
			/*|- object not located */
			if ((me->mytype == 4)
			&& (me->form_displayed)
			&& ((*response == DATA)
			||  (*response == RESET)
			||  (*response == D_RESET)))
			{
				/*|- Reset the Form */

				status =
				om$send(msg = message COdimonoff.show_difference(TRUE),
					targetid = my_id);
				dm$status(action = RET_STATUS);
			}
		}

		switch (*response)
		{
			case RESET:

			if (((me->state == STATE_INITIAL) && (me->mytype == 0))
			|| ((me->state == STATE_LOC_DIM) && (me->mytype == 1))
			|| ((me->state == STATE_INITIAL) && (me->mytype == 2)
				&& (me->namval)))
			{
				g_type = (me->mytype == 2)? DIM_BY_NAME:(char)'\0';
				g_mask = (me->mytype == 2)? DIM_BY_NAME:(char)'\0';
				d_type = (me->mytype == 1)? DIM_DISPLAY_OFF:(char)'\0';
				d_mask = (me->mytype == 1)? DIM_DISPLAY_OFF:(char)'\0';

				Dim_count = Disp_count = 0;

				status =
				DMdisplay_update(
					g_type,
					g_mask,
					d_type,
					d_mask,
					FALSE,
					TRUE,
					FALSE,
					GRhd,
					NULL,
					PASS_TO_CUROS,
					&me->md_env);
				dm$status(action = RET_STATUS);

				if (Disp_count > 0)
				{
					status =
					om$send(msg = message COdim.getevent(
							DM_P_Ac,
							response,
							response_data,
							&me->event1),
						targetid = my_id);
					dm$status(action = RET_STATUS);

					dp$erase_hilite(msg = &rc);
	
					/* 11924784 fix -- sampath */
					switch(*response)
					{
					case DATA:
					status =
					om$send(msg = message COdimonoff.set_dim_disp(TRUE),
						targetid = my_id);
					dm$status(action = RET_STATUS);

					me->state = STATE_INITIAL;
					break;

					case STRING:
					case CMD_STRING:
					case EX_CMD_KEY:
					case TERMINATE:
					return(OM_S_SUCCESS);

					default:
					status =
					DMdisplay_update(
						g_type,
						g_mask,
						d_type,
						d_mask,
						FALSE,
						TRUE,
						FALSE,
						GRbd,
						NULL,
						PASS_TO_CUROS,
						&me->md_env);
					dm$status(action = RET_STATUS);

					if ((me->mytype == 1)
					&& (me->event1.response == RESET))
					me->state = STATE_LOC_DIM_2;

					if ((me->mytype == 0)
					&& (me->event1.response == RESET))
					me->state = STATE_LOC_FEATURE;
					break;
					}
				}
				else	me->state = STATE_INITIAL;
			}
			else if (me->state == STATE_INITIAL)
			{
				if (me->mytype == 1)
				{
					DMdisplay_invisible(
						DIMS_IN_CUROS,
						&me->md_env);
					me->state = STATE_LOC_DIM;
				}
				else if (me->mytype == 2)
					me->namval = TRUE;
				else if (me->mytype == 3)
					me->state = STATE_ID_VIEW;
			}
			else if ((me->state == STATE_LOC_DIM_2)
			      || (me->state == STATE_LOC_FEATURE))
				me->state = STATE_INITIAL;
			else if (me->state == STATE_LOC_DIM_FEATURE)
			{
				me->state = STATE_INITIAL;
				if ((me->mytype == 2) && me->namval)
					me->namval = FALSE;
			}
			break;

			case D_RESET:

			if (me->state == STATE_LOC_DIM_2)
				me->state = STATE_LOC_DIM;
			else if ((me->state == STATE_LOC_DIM_FEATURE)
				|| (me->state == STATE_LOC_FEATURE)
				|| (me->state == STATE_LOC_DIM)
				|| (me->state == STATE_ID_VIEW))
				me->state = STATE_INITIAL;
			else if ((me->state == STATE_INITIAL) &&
				 (me->mytype == 2) && me->namval)
				me->namval = FALSE;
			break;

			case DATA:
			/*|- Data button given */
			case STATUS_DISP:
			break;

			case TERMINATE:
			default:
			return(OM_S_SUCCESS);
		}
	    }
	}
}

method set_dim_disp(IGRboolean all)
{
	IGRint status, rc, nb_root, size, i;
	struct GRid loc_obj, *p_root;
	struct GRmd_env loc_env;
	struct GRid copy;
	OM_S_OBJID win_id;
	OMuword    win_os;
	IGRboolean parallel_only;
	IGRmatrix vw_rot;
	OM_p_MESSAGE p_msg;

	loc_obj = me->loc_event.located_object[0].located_obj;
	loc_env = (all)?me->md_env:me->loc_event.located_object[0].module_info;

	/*^
		print_grid("md_id",&loc_env.md_id);
		print_matrix("env matrix", loc_env.md_env.matrix);
	*/

	if (me->mytype == 2)
	{
		p_msg = message DMroot.set_geom_type(
			(me->namval)?BIT_CLEAR:BIT_OR,
			DIM_BY_NAME,
			&loc_env);
	}
	else if (me->mytype == 3)
	{
		if (all)
		{
			parallel_only = TRUE;
			win_id = me->event1.event.button.objid;
			win_os = me->event1.event.button.osnum;
		}
		else
		{
			parallel_only = FALSE;
			win_id = me->loc_event.event.button.objid;
			win_os = me->loc_event.event.button.osnum;
		}

		status =
		om$send(msg = message IGEgragad.DPinrot(
					(IGRlong *) &rc,
					vw_rot),
			targetid = win_id,
			targetos = win_os);
		dm$status(action = RET_STATUS);

		/*^
			print_matrix("vw_matrix", vw_rot);
			print_grid("event win", &me->event1.event.button);
			print_grid("loc win", &me->loc_event.event.button);
		*/

		p_msg = message DMroot.import_dimension(
					&rc,
					parallel_only,
					vw_rot,
					&loc_env,
					&me->md_env,
					&copy);
	}
	else
	{
		p_msg = message DMroot.set_display_type(
				me->mytype?BIT_CLEAR:BIT_OR,
				DIM_DISPLAY_OFF,
				&loc_env);
	}

	if (all)
	{
		Imp_count = Dim_count = 0;

		status =
		dm$pass_message(
			msg = p_msg,
			target = (me->mytype == 3)?PASS_TO_REFOS:PASS_TO_CUROS,
			md_env = &loc_env,
			all_contexts = TRUE);
		dm$status(action = RET_STATUS);

		/*^
			printf("dim_count = %d\n", Dim_count);
			printf("import_count = %d\n", Imp_count);
		*/

		if (me->mytype == 3)
		{
			if ((Dim_count - Imp_count) > 0)
			{
                                ex$message(msgnumb = DM_I_DimNotRetrieved,
                                           type = "%d",
                                           var = `(Dim_count - Imp_count)`);
			}
		}

		return(OM_S_SUCCESS);
	}

	if (DMancestry_valid(loc_obj, OPP_DMroot_class_id))
	{
		status =
		om$send(msg = p_msg,
			targetid = loc_obj.objid,
			targetos = loc_obj.osnum);
		dm$status(action = RET_STATUS);
	}
	else if (DMancestry_valid(loc_obj, OPP_expression_class_id))
	{
		nb_root = size =0;
		p_root = NULL;

		status =
		DMget_components(
			loc_obj,
			&size,
			&p_root,
			&nb_root);
		dm$status(action = RET_STATUS);

		/*^
			printf("Roots:\n");
			for (i=0; i<nb_root; i++)
				printf("%d, %d\n",
					p_root[i].objid,
					p_root[i].osnum);
		*/

		for (i=0; i<nb_root; i++)
		{
			if (!DMancestry_valid(p_root[i], OPP_DMroot_class_id))
				continue;

			status =
			om$send(msg = p_msg,
				targetid = p_root[i].objid,
				targetos = p_root[i].osnum);
			dm$status(action = RET_STATUS);
		}

		om$dealloc(ptr = p_root);
	}
	else
	{
		status =
		DMpass_to_feadim(loc_obj, p_msg);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method LC_selection(IGRint *msg; struct GRlc_info *lc_info)
{
	IGRint status;
	IGRchar display;
	IGRboolean is_dim, in_ref;

	/*^
		IGRchar classname[OM_K_MAXCLASS_LEN];

		status =
		om$get_classname(
			osnum = lc_info->located_obj.osnum,
			objid = lc_info->located_obj.objid,
			classname = classname);
		dm$status(action = RET_STATUS);

		printf("go=(%d,%d)\n", lc_info->located_obj.objid, lc_info->located_obj.osnum);
		printf("classname=<%s>\n", classname);
	*/

	is_dim = DMancestry_valid(lc_info->located_obj, OPP_DMroot_class_id);

	if (me->mytype == 0)
	{
		*msg = TRUE;
		me->state = STATE_LOC_DIM_FEATURE;
	}
	else if (me->mytype == 1)
	{
		if ((me->state == STATE_INITIAL)
		||  (me->state == STATE_LOC_FEATURE))
		{
			*msg = !is_dim;
			me->state = STATE_LOC_FEATURE;
		}
		else
		{
			*msg = is_dim;
			me->state = STATE_LOC_DIM_2;
		}
	}
	else if (me->mytype == 2)
	{
		*msg = TRUE;
		me->state = STATE_LOC_DIM_FEATURE;
	}
	else if (me->mytype == 3)
	{
		*msg = is_dim;
		me->state = STATE_LOC_DIM;
	}
	else if (me->mytype == 4)
	{
		if(is_dim)
		{
			status =
			om$send(msg = message DMroot.inq_display_type(&display),
				targetid = lc_info->located_obj.objid,
				targetos = lc_info->located_obj.osnum);
			dm$status(action = RET_STATUS);

			*msg = (display & DIM_IS_DIFFERENT);
		}
		else *msg = FALSE;

		if((!*msg) && (me->form_displayed))
		{
			status =
			om$send(msg = message COdimonoff.show_difference(TRUE),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}
	else	*msg = TRUE;

	if (*msg)
	{
		in_ref =
		(lc_info->located_obj.osnum != me->md_env.md_id.osnum)
		|| (lc_info->module_info.md_env.matrix_type != MAIDMX);

		*msg = (me->mytype == 3)?in_ref:!in_ref;
	}

	return(OM_S_SUCCESS);
}

method LC_preproc(IGRint *msg; struct GRlc_info *lc_info)
{
	IGRint status, msg_key;
	struct GRid obj;
	OM_p_MESSAGE p_msg;
	IGRchar disp_type;

	me->event1.located_object[0] = *lc_info;
	me->loc_event = me->event1;

	if (me->mytype == 3) return(OM_S_SUCCESS);

	if (me->mytype == 4)
	{
		disp_type = (me->event1.response == DATA)?FALSE:TRUE;

		if (!disp_type || me->form_displayed)
		{
			status =
			om$send(msg = message COdimonoff.show_difference(disp_type),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}

		ex$message(msgnumb = DM_P_LocDim, buff = me->acc_prompt);

		*msg = DIM_S_SUCCESS;
		return(OM_S_SUCCESS);
	}

	obj = lc_info->located_obj;
	disp_type = (me->mytype == 1)?TRUE:FALSE;
	p_msg = message DMroot.GLupdate(
			(char)'\0',
			(char)'\0',
			DIM_DISPLAY_OFF,
			TRUE,
			FALSE,
			&me->md_env);
	if (!DMancestry_valid(obj, OPP_DMroot_class_id))
	{
		display_invisible_dims = disp_type;

		status =
		DMpass_to_feadim(obj, p_msg);
		dm$status(action = RET_STATUS);

		display_invisible_dims = FALSE;
	}

	if (me->state == STATE_LOC_DIM_FEATURE)
		msg_key = DM_P_AcDimFea;
	else if (me->state == STATE_LOC_FEATURE)
		msg_key = DM_P_AcFea;
	else	msg_key = DM_P_AcDim;

	ex$message(msgnumb = msg_key, buff = me->acc_prompt);

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method LC_dynamics(
	IGRint *msg;
	struct GRid *obj;
	struct GRevent *event)
{
	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method LC_postproc()
{
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

	if(me->mytype == 4)
	{
		status = FIf_delete(me->form);
		if (status != FI_SUCCESS)
		{
			/*|FIf_delete fails*/
			return(OM_E_ABORT);
		}
	}

	return(OM_S_SUCCESS);
}

method show_difference(IGRboolean reset_form)
{
	IGRint status, rc, row, index;
	IGRshort dim_type;
	IGRboolean compare;
	struct GRid loc_obj, parent_dim;
	struct GRmd_env mod_info;
	struct DMenv_param my_env, parent_env;
	struct DMloc_param my_loc, parent_loc;
	struct DMmisc_param my_misc, parent_misc;
	IGRdouble my_value, parent_value;
	
	struct dim_compare_data
	{
		IGRchar title[EXFI_STRLEN];
		IGRchar model[EXFI_STRLEN];
		IGRchar detail[EXFI_STRLEN];
	} dim_cmp_str[15];

	row = 0;

	if (!reset_form)
	{
		loc_obj = me->event1.located_object[0].located_obj;

		/*^ print_grid("loc_obj",&loc_obj); */

		status =
		om$send(msg = message DMroot.get_dim_type(&dim_type),
			targetid = loc_obj.objid,
			targetos = loc_obj.osnum);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMroot.get_compare_info(
						&rc,
						&compare,
						&parent_dim,
						&mod_info,
						&my_env,
						&parent_env,
						&my_loc,
						&parent_loc,
						&my_misc,
						&parent_misc),
			targetid = loc_obj.objid,
			targetos = loc_obj.osnum);
		dm$status(action = RET_STATUS);

		if (!compare)
		{
			/*"Error: compare dimension %d\n",rc*/
			return(OM_E_ABORT);
		}

		status =
		om$send(msg = message DMdim.get_dim_value(&parent_value),
			targetid = parent_dim.objid,
			targetos = parent_dim.osnum);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMdim.get_dim_value(&my_value),
			targetid = loc_obj.objid,
			targetos = loc_obj.osnum);
		dm$status(action = RET_STATUS);

		/*^
			printf("my_value = %f\n", my_value);
			printf("parent_value = %f\n", parent_value);
		*/

		if (fabs(my_value - parent_value) > 0.0001)
		{
			strcpy(dim_cmp_str[row].title, "dimension value");
			sprintf(dim_cmp_str[row].detail,"%f",parent_value);
			sprintf(dim_cmp_str[row].model,"%f", my_value);
			row++;
		}

		if (my_env.dim_stan != parent_env.dim_stan)
		{
			strcpy(dim_cmp_str[row].title, "standard");
			strcpy(dim_cmp_str[row].detail, standard[my_env.dim_stan]);
			strcpy(dim_cmp_str[row].model, standard[parent_env.dim_stan]);
			row++;
		}

		if (strcmp(my_misc.prefix, parent_misc.prefix) != 0)
		{
			strcpy(dim_cmp_str[row].title, "prefix");
			if(my_misc.prefix_disp)
			strcpy(dim_cmp_str[row].detail, my_misc.prefix);
			else strcpy(dim_cmp_str[row].detail,"");
			if(parent_misc.prefix_disp)
			strcpy(dim_cmp_str[row].model, parent_misc.prefix);
			else strcpy(dim_cmp_str[row].model,"");
			row++;
		}

		if (strcmp(my_misc.suffix, parent_misc.suffix) != 0)
		{
			strcpy(dim_cmp_str[row].title, "suffix");
			if (my_misc.suffix_disp)
			strcpy(dim_cmp_str[row].detail, my_misc.suffix);
			else strcpy(dim_cmp_str[row].detail, "");
			if (parent_misc.suffix_disp)
			strcpy(dim_cmp_str[row].model, parent_misc.suffix);
			else strcpy(dim_cmp_str[row].model, "");
			row++;
		}

		if (strlen(my_misc.dim_override) != 0)
		{
			strcpy(dim_cmp_str[row].title, "override");
			strcpy(dim_cmp_str[row].detail, my_misc.dim_override);
			strcpy(dim_cmp_str[row].model, "");
			row++;
		}
	
		if (my_loc.tole_mode != parent_loc.tole_mode)
		{
			strcpy(dim_cmp_str[row].title, "format");
			strcpy(dim_cmp_str[row].detail,format[my_loc.tole_mode]);
			strcpy(dim_cmp_str[row].model,format[parent_loc.tole_mode]);
			row++;
		}

		if ((parent_loc.tole_mode == TOLE_MODE_UP_LOW) ||
			(parent_loc.tole_mode == TOLE_MODE_LIMITS))
		{
			if ((my_loc.tole_mode == TOLE_MODE_UP_LOW) ||
			   (my_loc.tole_mode == TOLE_MODE_LIMITS))
			{
				if (strcmp((char *)my_loc.primary.tole_up,
				    (char *)parent_loc.primary.tole_up) != 0)
				{
				  strcpy(dim_cmp_str[row].title, "upper tolerance");
				  strcpy(dim_cmp_str[row].detail, (char *)my_loc.primary.tole_up);
				  strcpy(dim_cmp_str[row].model, (char *)parent_loc.primary.tole_up);
				  row++;
				}
	
				if (strcmp((char *)my_loc.primary.tole_low,
				    (char *)parent_loc.primary.tole_low) != 0)
				{
				  strcpy(dim_cmp_str[row].title, "lower tolerance");
				  strcpy(dim_cmp_str[row].detail, (char *)my_loc.primary.tole_low);
				  strcpy(dim_cmp_str[row].model, (char *)parent_loc.primary.tole_low);
				  row++;
				}
			}
			else
			{
				strcpy(dim_cmp_str[row].title, "upper tolerance");
				strcpy(dim_cmp_str[row].model, (char *)parent_loc.primary.tole_up);
				strcpy(dim_cmp_str[row].detail, "");
				row++;

				strcpy(dim_cmp_str[row].title, "lower tolerance");
				strcpy(dim_cmp_str[row].model, (char *)parent_loc.primary.tole_low);
				strcpy(dim_cmp_str[row].detail, "");
				row++;

				if (my_loc.tole_mode == TOLE_MODE_MIDDLE)
				{
				   strcpy(dim_cmp_str[row].title, "tolerance symbol");
				   strcpy(dim_cmp_str[row].detail, my_misc.pri_tole_sym);
				   strcpy(dim_cmp_str[row].model, "");
				   row++;
				}
			}
		}
		else if (parent_loc.tole_mode == TOLE_MODE_MIDDLE)
		{
			if ((my_loc.tole_mode == TOLE_MODE_UP_LOW) ||
			    (my_loc.tole_mode == TOLE_MODE_LIMITS))
			{
				strcpy(dim_cmp_str[row].title, "upper tolerance");
				strcpy(dim_cmp_str[row].detail, (char *)my_loc.primary.tole_up);
				strcpy(dim_cmp_str[row].model, "");
				row++;
	
				strcpy(dim_cmp_str[row].title, "lower tolerance");
				strcpy(dim_cmp_str[row].detail, (char *)my_loc.primary.tole_low);
				strcpy(dim_cmp_str[row].model, "");
				row++;

				if (parent_loc.tole_mode == TOLE_MODE_MIDDLE)
				{
				   strcpy(dim_cmp_str[row].title, "tolerance symbol");
				   strcpy(dim_cmp_str[row].model, parent_misc.pri_tole_sym);
				   strcpy(dim_cmp_str[row].detail, "");
				   row++;
				}
			}
			else
			{
				if (strcmp(my_misc.pri_tole_sym, parent_misc.pri_tole_sym) != 0)
				{
				   strcpy(dim_cmp_str[row].title, "tolerance symbol");
			           strcpy(dim_cmp_str[row].detail, my_misc.pri_tole_sym);
			           strcpy(dim_cmp_str[row].model, parent_misc.pri_tole_sym);
				   row++;
				}
			}
		}

		if ((1 << dim_type) & ANGULAR_MASK)
		{
		   /*|- Angular Dimension */

		   if (my_env.ang_unit != parent_env.ang_unit)
		   {
			strcpy(dim_cmp_str[row].title, "angular units");
			strcpy(dim_cmp_str[row].detail, ang_units[my_env.ang_unit]);
			strcpy(dim_cmp_str[row].model, ang_units[parent_env.ang_unit]);
			row++;
		   }

		   if ((my_env.ang_unit == ANG_UNIT_DEG) ||
		      (my_env.ang_unit == ANG_UNIT_RAD))
		   {
			if ((parent_env.ang_unit == ANG_UNIT_DEG) ||
			   (parent_env.ang_unit == ANG_UNIT_RAD))
			{
			   if (my_loc.deci_frac == DECIMAL_MODE)
			   {
				if (my_loc.angular.decacc !=
					parent_loc.angular.decacc)
				{
				   strcpy(dim_cmp_str[row].title, "angular decimal round off");
				   strcpy(dim_cmp_str[row].detail, decimal[my_loc.angular.decacc]);
				   strcpy(dim_cmp_str[row].model, decimal[parent_loc.angular.decacc]);
				   row++;
				}
			   }
			   else
			   {
				if (my_loc.angular.fraacc !=
					parent_loc.angular.fraacc)
				{
				   strcpy(dim_cmp_str[row].title, "angular fraction round off");
				   strcpy(dim_cmp_str[row].detail,fraction[my_loc.angular.fraacc]);
				   strcpy(dim_cmp_str[row].model,fraction[parent_loc.angular.fraacc]);
				   row++;
				}
			   }		
			}
			else
			{	
			   if (my_loc.deci_frac == DECIMAL_MODE)
			   {
				strcpy(dim_cmp_str[row].title, "angular decimal round off");
				strcpy(dim_cmp_str[row].detail,decimal[parent_loc.angular.decacc]);
				strcpy(dim_cmp_str[row].model, "");
				row++;
			   }
			   else
			   {
				strcpy(dim_cmp_str[row].title, "angular fractional round off");
				strcpy(dim_cmp_str[row].detail,fraction[parent_loc.angular.fraacc]);
				strcpy(dim_cmp_str[row].model, "");
				row++;
			   }

			   strcpy(dim_cmp_str[row].title, "angular round off units");
			   strcpy(dim_cmp_str[row].model, ang_roff_unit[parent_loc.angular.ang_roff_unit]);
			   strcpy(dim_cmp_str[row].detail, "");
			   row++;
			}
		   }
		   else
		   {
			if ((parent_env.ang_unit == ANG_UNIT_DEG) ||
			   (parent_env.ang_unit == ANG_UNIT_RAD))
			{
			   if (my_loc.deci_frac == DECIMAL_MODE)
			   {
				   strcpy(dim_cmp_str[row].title, "angular decimal round off");
				   strcpy(dim_cmp_str[row].model,decimal[parent_loc.angular.decacc]);
				   strcpy(dim_cmp_str[row].detail, "");
				   row++;
			   }
			   else
			   {
				   strcpy(dim_cmp_str[row].title, "angular fraction round off");
				   strcpy(dim_cmp_str[row].model,fraction[parent_loc.angular.fraacc]);
				   strcpy(dim_cmp_str[row].detail, "");
				   row++;
			   }		
			}
			else
			{	
			   if (my_loc.angular.ang_roff_unit !=
				parent_loc.angular.ang_roff_unit)
			   {
				strcpy(dim_cmp_str[row].title, "angular round off units");
				strcpy(dim_cmp_str[row].model,ang_roff_unit[my_loc.angular.ang_roff_unit]);
				strcpy(dim_cmp_str[row].model,ang_roff_unit[parent_loc.angular.ang_roff_unit]);
				row++;
			   }
			}
		   }
		}
		else
		{
		   /*|- Linear Dimensions */

		   if (my_env.pri_unit != parent_env.pri_unit)
		   {
			strcpy(dim_cmp_str[row].title, "linear units");
			strcpy(dim_cmp_str[row].detail,lin_units[my_env.pri_unit]);
			strcpy(dim_cmp_str[row].model,lin_units[parent_env.pri_unit]);
			row++;
		   }

		   if (my_loc.deci_frac != parent_loc.deci_frac)
		   {
			strcpy(dim_cmp_str[row].title, "round off type");
			strcpy(dim_cmp_str[row].detail,lin_roff[my_loc.deci_frac]);
			strcpy(dim_cmp_str[row].model,lin_roff[parent_loc.deci_frac]);
			row++;
		   }
	
		   if (my_loc.deci_frac == DECIMAL_MODE)
		   {
			if (my_loc.primary.decacc == DECI_ACC10)
				my_loc.primary.decacc = 8;

			if (parent_loc.deci_frac == DECIMAL_MODE)
			{
			   if (parent_loc.primary.decacc == DECI_ACC10)
				parent_loc.primary.decacc = 8;

			   if (my_loc.primary.decacc != parent_loc.primary.decacc)
			   {
				strcpy(dim_cmp_str[row].title, "primary decimal round off");
				strcpy(dim_cmp_str[row].detail,decimal[my_loc.primary.decacc]);
				strcpy(dim_cmp_str[row].model,decimal[parent_loc.primary.decacc]);
				row++;
			   }
			}
			else
			{
			   strcpy(dim_cmp_str[row].title, "primary decimal round off");
			   strcpy(dim_cmp_str[row].detail,decimal[my_loc.primary.decacc]);
			   strcpy(dim_cmp_str[row].model, "");
			   row++;
	
			   strcpy(dim_cmp_str[row].title, "primary fraction round off");
			   strcpy(dim_cmp_str[row].model,fraction[parent_loc.primary.fraacc]);
			   strcpy(dim_cmp_str[row].detail, "");
			   row++;
			}
		   }
		   else
		   {
			if (parent_loc.deci_frac == DECIMAL_MODE)
			{
			   strcpy(dim_cmp_str[row].title, "primary fraction round off");
			   strcpy(dim_cmp_str[row].detail,fraction[my_loc.primary.fraacc]);
			   strcpy(dim_cmp_str[row].model, "");
			   row++;

			   strcpy(dim_cmp_str[row].title, "primary decimal round off");
			   strcpy(dim_cmp_str[row].model,decimal[parent_loc.primary.decacc]);
			   strcpy(dim_cmp_str[row].detail, "");
			   row++;
			}
			else
			{
			   if (my_loc.primary.fraacc != parent_loc.primary.fraacc)
			   {
				strcpy(dim_cmp_str[row].title, "primary fraction round off");
				strcpy(dim_cmp_str[row].detail,fraction[my_loc.primary.fraacc]);
				strcpy(dim_cmp_str[row].model,fraction[parent_loc.primary.fraacc]);
				row++;
			   }
			}
		   }
		}

		me->prev_dim = loc_obj;
		me->prev_parent = parent_dim;
	}
	
	/*^ printf("row = %d\n",row); */

	status = FIfld_set_num_rows(me->form, 12, row);
	if(status != FI_SUCCESS) return(OM_E_ABORT);

	/*|- Fill the text info in Form */

	for(index = 0; index < row; index++)
	{
		/*"title = %s\n",dim_cmp_str[index].title*/

		status=
		FIfld_set_text(me->form,12,index,0,dim_cmp_str[index].title,1);
		if(status != FI_SUCCESS) return(OM_E_ABORT);

		/*"model = %s\n",dim_cmp_str[index].model*/

		status=
		FIfld_set_text(me->form,12,index,1,dim_cmp_str[index].model,1);
		if(status != FI_SUCCESS) return(OM_E_ABORT);

		/*"detail = %s\n",dim_cmp_str[index].detail*/

		status=
		FIfld_set_text(me->form,12,index,2,dim_cmp_str[index].detail,1);
		if(status != FI_SUCCESS) return(OM_E_ABORT);
	}

	/*|- Display the Form */

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
	IGRint status;

	status =
	FIg_set_value(form, label, 0.0);
	if (status != FI_SUCCESS)
	{
		/*|FIg_set_value fails*/
		return(OM_E_ABORT);
	}

	status = FIf_erase(me->form);
	if (status != FI_SUCCESS)
	{
		/*|FIf_erase fails*/
		return(OM_E_ABORT);
	}

	me->form_displayed = FALSE;

	return(OM_S_SUCCESS);
}

end implementation COdimonoff;

