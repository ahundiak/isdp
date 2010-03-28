/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:30 $
$Locker:  $
$Log: gtedit.I,v $
Revision 1.1.1.1  2001/12/17 22:39:30  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:07:53  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.1  1997/02/28  15:43:55  bsubbaia
# COMMENT : Place Balloon :- Editing of second line of text
#
# Revision 330.0  1996/01/11  21:21:52  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.1  1995/10/24  06:32:03  gvk
# COMMENT : Updating weld symbols only on edit annotation text command
#
# Revision 320.0  1994/12/12  17:51:22  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.6  1994/08/10  21:52:38  grnuc40
# COMMENT : Upgrade due to Intel Solaris port
#
# Revision 240.5  1993/11/05  05:51:51  samuel
# COMMENT : Fix for TR 119311178 - Alt mode chars for balloon
#
# Revision 240.3  1993/08/03  13:25:01  samuel
# COMMENT : Fix for TR# 119300474 -samuel
#
# Revision 240.2  1993/03/01  19:38:59  mikel
# COMMENT : remove ms.h or change it to msmacros.h
#
# Revision 240.1  1993/01/10  22:54:37  pike
# COMMENT : port to NT.  make form display last thing done in wakeup
#
# Revision 240.0  1992/12/06  23:43:30  tim
# COMMENT : Initial checkin to 2.4 RCS
#
# Revision 220.1  1992/10/16  19:24:10  poo
# COMMENT : Checking in 2.1 Fixes to 2.2 RCS
#
Revision 201.19  1992/09/02  13:06:58  gvk
COMMENT : Fix for Feature control frame & vertical line angle.

Revision 201.17  1992/07/31  18:45:54  poo
COMMENT :

Revision 201.16  1992/07/23  19:53:50  doree
COMMENT : message subsystem compliance

Revision 201.15  1992/07/20  12:04:36  gvk
COMMENT : Added LC_HANDLES bit for locating constraints.

*/

class implementation COgtedit;

#include "igr.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "dpdef.h"
#include "dimfont.h"
#include "fontmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "grmsg.h"
#define AS_DEBUG	1 
#define UPDT_TEXT	0x0000
#define ck_status(a)	{if( a != FI_SUCCESS) return(OM_E_ABORT);}
#define FEA_FORM	5
#define FEA_SUBFORM	6

from GRvg   import GRgenabsg, GRgetgeom,GRgetsymb;
from GRtext import GRgettxattr, GRreplace_text;
from DMroot import replace_text, return_dim_go;
from NDnode import NDs_compute_node, NDdisplay;
from DMannot import get_edit_attr, put_dim_attr, make_an_text;
from DMframe import get_profile_type,check_profile_type,set_profile_type;
from DMframe import update_text_box, set_tol_mode;
from DMroot import set_dim_state;
from DMweld import get_weld_text;
from DMsurf import get_surf_text;

extern struct DMsurf_param frm_surf;
extern struct DMenv_param frm_env;
%safe
static int SecondText = 0;
%endsafe
method init(int type; char *string_ptr)
{
	IGRint status, rc;

	status =
	om$send(msg = message COdim.init(type, string_ptr),
		targetid = my_id,
		mode = OM_e_wrt_message);
	dm$status(action = RET_STATUS);

	me->msgnumb = DMC_M_DMEdFtCnFr;
	me->gt_grid.objid = NULL_OBJID;

	me->mask1 |= GRm_STRING;
	me->mask2 |= GRm_STRING;
	/* Do not Locate Driving Dims*/
	me->attr.owner_action &=(~LC_HANDLES);

	me->state = STATE_P_LOC_DIM;
	me->dyn_info.info.text_string = (IGRuchar *) malloc (1024);
	me->dyn_info.info.text_buff_size = 1024;
	me->dyn_info.info.text_length = 0;
	me->dyn_info.info.text_string[0] = '\0';
	me->dyn_info.info.gtattr.sep_symbol = 'l';

	DMretrieve_font(&rc, me->md_env.md_id.osnum,
		(IGRuchar *) "100",&me->dyn_info.info.gtattr.geom_font);
	DMretrieve_font(&rc, me->md_env.md_id.osnum,
	(IGRuchar *) "102",&me->dyn_info.info.gtattr.ter_font);

	/*|- Create Feature Forms */

  	status =
  	om$send(msg = message COdim.create_form(FEA_FORM,"DMFtCt",
  						&me->form),
  		targetid = my_id);
  	dm$status(action = RET_STATUS);

  	status =
  	om$send(msg = message COdim.create_form(FEA_SUBFORM,"DMFtCtSb",
  						&me->subform),
  		targetid = my_id);
  	dm$status(action = RET_STATUS);
	
	/*|- Create Weld Forms */

	status =
	om$send(msg = message COdim.create_form(MAIN_FORM,"DMWeld",
						&me->weldform),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COdim.create_form(SUB_FORM1,"DMWeldSbAbov",
						&me->weldform1),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COdim.create_form(SUB_FORM2,"DMWeldSbBlow",
						&me->weldform2),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COdim.create_form(SUB_FORM3,"DMWeldSbCntr",
						&me->weldform3),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COdim.create_form(SUB_FORM4,"DMWeldSub",
						&me->weldform4),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*|- Create Surface Texture Symbol Form */

	status =
        om$send(msg = message COdim.create_form(SURF_FORM,"DMSurf",
                                                &me->surfform),
                targetid = my_id);
        dm$status(action = RET_STATUS);

        status =
        om$send(msg = message COdim.create_form(SURF_SUB_FORM,"DMSubSurf",
                                                &me->surfform1),
                targetid = my_id);
        dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method execute(int *response; char *response_data; int pos)
{
	IGRint status;
	IGRlong long_rc;
	IGRint mod_batch, msgkey;
	IGRint updt_flag = 0;
	Form active_form;
	IGRshort current_index;

	while (TRUE)
	{
		switch (me->state)
		{
			/*********************/
			case STATE_P_LOC_DIM:
			/*********************/

			me->gt_grid.objid = NULL_OBJID;

			status =
			om$send(msg = message COdim.locate_parent(
							response,
							response_data,
							&me->dim_event,
							TRUE,
							DM_P_LocFrEd,
							DM_P_AccElt,
							DM_P_LocFrEd),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if (me->locate_rc == LC_OBJ_LOCATED)
			{
				me->state = STATE_P_POS_TEXT;
				me->gt_grid = 
				me->dim_event.located_object[0].located_obj;

                if (me->dim_type == TEXT_WITH_BALLOON) 
                { struct DMsenv_param par_senv;
                  dm$get_dim_param(type = DM_SENV_PARAM,
                                   dim_objid = me->dim_event.located_object[0].located_obj.objid,
                                   dim_osnum = me->dim_event.located_object[0].located_obj.osnum, 
                                   p_data = &par_senv );
                  if (par_senv.bln_type < 8)
                  {
                    SecondText = FALSE;
                    status=   
                                om$send(msg = message COgtedit.load_data(),  
                                        targetid = my_id);
                                dm$status(action = RET_STATUS); 
                  }
                  else
                  {
                   IGRint response;
                   IGRlong rc;
                   struct GRevent event;
                   char response_data[1024];
                   status = ex$clear_event_queue ( );
                   co$getevent(   
                                msg = &rc,  
                                event_mask = GRm_RJT_MOVEON | GRm_DATA,  
                                msgnum = GR_P_FrOrSe,  
                                response = &response,   
                                response_data = response_data,  
                                event = &event);
 
                   if (response == EX_RJT_MOVEON)
                   {
                    SecondText = TRUE;
                   }
                   else
                   {
                    SecondText = FALSE;
                   }

                  }
                }
                status=   
                                om$send(msg = message COgtedit.load_data(), 
                                        targetid = my_id);
                                dm$status(action = RET_STATUS);
				/*"dim type = %d\n", me->dim_type*/

				if(me->dim_type == FEATURE_CONTROL_FRAME)
				{
					status =
					om$send(msg = message DMframe.get_profile_type(
								&me->tol_sym),
						targetid = me->gt_grid.objid,
						targetos = me->gt_grid.osnum);
					dm$status(action = RET_STATUS);
						
					/*" get_profile type:%d\n", me->tol_sym*/
				}

				if ((me->dim_type == FEATURE_CONTROL_FRAME)
				||  (me->dim_type == WELD)
				||  (me->dim_type == SURF))
				{
					status =
					om$send(msg = message COgtedit.display_form(),
						targetid = my_id);
					dm$status(action = RET_STATUS);
				}

				if ((me->dim_type != TEXT_WITH_BALLOON)
				&&  (me->dim_type != WELD)
				&&  (me->dim_type != SURF))
				{
					status =
					om$send(msg = message COgtedit.get_char_under(&me->dim_event),
						targetid = my_id);
					dm$status(action = RET_STATUS);
				}
			}
			break;

			/*********************/
			case STATE_P_POS_TEXT:
			/*********************/
			dp$erase_hilite(msg = &long_rc);

			status =
			dm$get_dim_param(
				type = DM_MISC_PARAM,
				p_data = (char *) &me->dyn_info.info.par_misc);
			dm$status(action = RET_STATUS);

			if ((me->dim_type != WELD)
			&&  (me->dim_type != SURF)
			&&  (me->dim_type != TEXT_WITH_BALLOON))
			{
				status =
				om$send(msg =message COgtedit.position_cursor(),
						targetid = my_id);
				dm$status(action = RET_STATUS);
			}

			if ((me->dim_type == WELD)
			||  (me->dim_type == SURF))
			{
				me->mask1 &= ~GRm_STRING;
				me->mask2 &= ~GRm_STRING;
				msgkey = DM_P_ChgFormDataM;
			}
			else
			{
				me->mask1 |= GRm_STRING;
				me->mask2 |= GRm_STRING;
				msgkey = DM_P_EnSbTx;
			}

			status =
			om$send(msg = message COdim.getevent(
							msgkey,
							response,
							response_data,
							&me->event1),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			if ((*response == EX_CHAR) || (*response == EX_STRING))
			{
				/*^
                                        int i;
					printf(" response:%d\n",*response);
					for( i = 0; i<me->nbytes;i++)
					printf("byte[%d]:%d\n",i,response_data[i]);
				*/

				if ((me->dim_type != TEXT_WITH_BALLOON)
				&&  (me->dim_type != WELD)
				&&  (me->dim_type != SURF))
				{
					/*|- Make annot text*/

					DMmake_annot_text(me->dyn_info.info.text_string,
						  &me->dyn_info.info.text_length,
						  &me->dyn_info.info.text_buff_size,
						  &me->dyn_info.info.text_st.estx,
						  AN_NORMAL,
						  response_data,
						  me->nbytes,
						  &me->dyn_info.info.gtattr,
						  me->dual_mode,
						  me->dim_type,
						  (IGRshort)me->dyn_info.info.par_misc.sixteen_bit_font,
						  &current_index,
						  &updt_flag,
						  3); /* bln_limit */

					if(updt_flag == UPDT_TEXT)
					{
						updt_flag = 0;
						break;
					}
 					if( updt_flag & SET_SINGLE_MODE)
					{
						/*| set single mode */
						status=
						om$send(msg = message DMframe.set_tol_mode(DUAL_MODE_OFF),
								targetid = me->gt_grid.objid,
								targetos = me->gt_grid.osnum);
						dm$status(action = RET_STATUS);
						me->dual_mode = DUAL_MODE_OFF;
						status = FIg_enable(me->form,TOL_SYMB_DUAL_LINE);
						if(status != FI_SUCCESS)
							printf("FIg_enable fails:%d\n",status);
					}
					else if( updt_flag & SET_DUAL_MODE)
					{
						/*| set dual mode */
						status=
						om$send(msg = message DMframe.set_tol_mode(DUAL_MODE_ON),
								targetid = me->gt_grid.objid,
								targetos = me->gt_grid.osnum);
						dm$status(action = RET_STATUS);
						me->dual_mode = DUAL_MODE_ON;
						status = FIg_disable(me->form,TOL_SYMB_DUAL_LINE);
						if(status != FI_SUCCESS)
							printf("FIg_enable fails:%d\n",status);	

						if((me->dyn_info.info.text_length + 2) < me->dyn_info.info.text_buff_size)
						{
							int length;
							length = me->dyn_info.info.text_length;
							me->dyn_info.info.text_string[length++] = 27;
							me->dyn_info.info.text_string[length++] = 'E';
						 	me->dyn_info.info.text_length  = length;
							DMupdt_disp_chars(me->dyn_info.info.text_string,
									  &me->dyn_info.info.text_length,
									  &me->dyn_info.info.gtattr,
									  me->dual_mode,
									  FEATURE_CONTROL_FRAME);
						}
					}
				}

				mod_batch = ND_IMMEDIATE;
				status =
				DMmod_graph_batch_cp(GET_MODE | SET_MODE, NULL, NULL, &mod_batch);
				dm$status(action = RET_STATUS);
				
				if (me->dim_type == TEXT_WITH_BALLOON)
				{
					status =
					om$send(msg = message COgtedit.update_balloon(
								me->nbytes - 1,
								response_data),
						targetid = my_id);
					dm$status();
				}
				else if ((me->dim_type != WELD) && (me->dim_type != SURF))
				{
					status =
					om$send( msg = message COgtedit.update_feature(),
						targetid = my_id);
					dm$status(action = RET_STATUS);
				}

				updt_flag = 0;
				status =
				DMmod_graph_batch_cp(GET_MODE | SET_MODE, NULL, NULL, &mod_batch);
				dm$status(action = RET_STATUS);
			}
			else if(*response == DATA)
			{
				status =
				om$send(msg = message COgtedit.get_char_under(&me->event1),
					targetid = my_id);
				dm$status(action = RET_STATUS);
			}
			else if( *response == RESET)
			{
				if (me->form_display)
				{
					if (me->dim_type == WELD)
						active_form = me->weldform;
					else if (me->dim_type == SURF)
						active_form = me->surfform;
					else	active_form = me->form;

					status = FIf_erase(active_form);
					ck_status(status);
					me->form_display = FALSE;
				}

				status = dp$erase_hilite(msg= &long_rc);
				me->state = STATE_P_LOC_DIM;
				me->gt_grid.objid = NULL_OBJID;
			}
			break;

			/******/
			default:
			/******/

			printf("COgtedit: Unknown state %d\n", me->state);
			*response = TERMINATE;
			return(OM_S_SUCCESS);
		}

		switch (*response)
		{
			case DATA:
			case RESET:
			case D_RESET:
			case MOVE_ON:
			case EX_CHAR:
			case EX_STRING:
			break;

			case STATUS_DISP:
			break;

			case TERMINATE:

			if (me->gt_grid.objid != NULL_OBJID)
			{
				status =
				om$send(msg = message COgtedit.display_dimension(GRbd),
					targetid = my_id);
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
	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method LC_postproc()
{
	IGRint status, rc;

	if (me->gt_grid.objid == NULL_OBJID)
		return(OM_S_SUCCESS);

	if (me->event2.response == RESET ||
	    me->event2.response == D_RESET)
	{
		status =
		om$send(msg = message COgtedit.display_dimension(GRbe),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		DMdelete_dimension(
			&rc,
			FALSE,
			&me->md_env,
			&me->gt_grid);
		dm$status(action = RET_STATUS);

		me->gt_grid.objid = NULL_OBJID;

		nd$exec_batch();
	}

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

method LC_selection(IGRint *msg; struct GRlc_info *lc_info)
{
	IGRint status, rc=0;
	struct annot_attr sel_attr;
	extern GRclassid OPP_DMannot_class_id,
			 OPP_DMleader_class_id;

	*msg = DMancestry_valid(
			lc_info->located_obj,
			OPP_DMannot_class_id);
	if (*msg)
	{
		if (DMancestry_valid(lc_info->located_obj, OPP_DMleader_class_id))
		{
			*msg = FALSE;
			return(OM_S_SUCCESS);
		}

		status =
		om$send(msg = message DMannot.get_edit_attr(rc, &sel_attr),
			targetid = lc_info->located_obj.objid,
			targetos = lc_info->located_obj.osnum);
		dm$status(action = RET_STATUS);

		if (sel_attr.geom_type & DIM_DRIVING)
			*msg = FALSE;
		me->dim_type = sel_attr.dim_type;
		me->dual_mode = sel_attr.dual_mode;
	}

	/*^ printf("dim type:%d\n",me->dim_type);
	    printf("dual mode:%d\n",me->dual_mode);
	    printf("select:%d\n",*msg);
	*/

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
		targetid = me->gt_grid.objid,
		targetos = me->gt_grid.osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method notify_form(
	int form_label;
	int label;
	double value;
	Form form)
{
	IGRint status, rc;
	IGRboolean save_data, ignore_data, ansi;

	if (me->dim_type == WELD)
	{
		status =
		DMprocess_weld_form(
			form_label,
			label,
			value,
			me->weldform,
			me->weldform1,
			me->weldform2,
			me->weldform3,
			me->weldform4,
			FALSE,
			&me->above_input,
			&me->form_display,
			FALSE,
			TRUE,
			&save_data,
			&ignore_data,
			&me->par_weld);
		dm$status(action = RET_STATUS);

		if (save_data)
		{
			dm$put_dim_param(type = DM_WELD_PARAM, p_data = (char *)&me->par_weld);

			if (me->gt_grid.objid != NULL_OBJID)
			{
				status =
				om$send(msg = message DMroot.set_dim_state(BIT_OR, DIM_TEXT_NEEDS_UPDATE),
					senderid = NULL_OBJID,
					targetid = me->gt_grid.objid,
					targetos = me->gt_grid.osnum);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message COgtedit.update_weld(),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message DMroot.set_dim_state(BIT_CLEAR, DIM_TEXT_NEEDS_UPDATE),
					senderid = NULL_OBJID,
					targetid = me->gt_grid.objid,
					targetos = me->gt_grid.osnum);
				dm$status(action = RET_STATUS);
			}
		}

		if (ignore_data)
		{
			/*|- Refresh the Form*/

			status =
			om$send(msg = message DMweld.get_weld_text(
						&rc,
						&me->par_weld,
						&me->md_env),
				targetid = me->gt_grid.objid,
				targetos = me->gt_grid.osnum);
			dm$status(action = RET_STATUS);

			status =
			DMprocess_weld_form(
				0,
				0,
				0.0,
				me->weldform,
				me->weldform1,
				me->weldform2,
				me->weldform3,
				me->weldform4,
				FALSE,
				&me->above_input,
				&me->form_display,
				TRUE,
				TRUE,
				&save_data,
				&ignore_data,
				&me->par_weld);
			dm$status(action = RET_STATUS);
		}
	}
	else if (me->dim_type == SURF)
	{
		ansi = ((frm_env.pri_unit == MEA_UNIT_FEET_INCHES)
			|| (frm_env.pri_unit == MEA_UNIT_INCHES));

		status =
		DMprocess_surf_form(
			FALSE,
			&me->form_display,
			ansi,
			&save_data,
			&ignore_data,
			TRUE,
			form_label,
			label,
			value,
			me->surfform,
			me->surfform1,
			&frm_surf);
		dm$status(action = RET_STATUS);

		if (save_data)
		{
			if (me->gt_grid.objid != NULL_OBJID)
			{
				status =
				om$send(msg = message DMroot.set_dim_state(BIT_OR, DIM_IN_EDIT),
					senderid = NULL_OBJID,
					targetid = me->gt_grid.objid,
					targetos = me->gt_grid.osnum);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message COgtedit.update_surf(),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message DMroot.set_dim_state(BIT_CLEAR, DIM_IN_EDIT),
					senderid = NULL_OBJID,
					targetid = me->gt_grid.objid,
					targetos = me->gt_grid.osnum);
				dm$status(action = RET_STATUS);
			}
		}

		if (ignore_data)
		{
			/*|- Refresh the Form*/

			status =
			om$send(msg = message DMsurf.get_surf_text(
						&rc,
						&frm_surf,
						&me->md_env),
				targetid = me->gt_grid.objid,
				targetos = me->gt_grid.osnum);
			dm$status(action = RET_STATUS);

			status =
			DMprocess_surf_form(
				TRUE,
				&me->form_display,
				ansi,
				&save_data,
				&ignore_data,
				TRUE,
				0,
				0,
				0.0,
				me->surfform,
				me->surfform1,
				&frm_surf);
			dm$status(action = RET_STATUS);
		}
	}
	else
	{
		status=
		om$send(msg = message COgtedit.get_form_symbol(form_label,
							label,
							value,
							form),
				targetid = my_id);
		dm$status( action = RET_STATUS);

		if(me->gt_grid.objid != NULL_OBJID)
		{
			status =
			om$send(msg = message  DMroot.replace_text(
						&rc,
						DIM_TEXT,
						(struct GRid *)NULL,
						&me->md_env,
						me->dyn_info.info.text_length,
						(IGRuchar *)me->dyn_info.info.text_string),
				targetid = me->gt_grid.objid,
				targetos = me->gt_grid.osnum);
			dm$status(action = RET_STATUS);
		}
	}

	return(OM_S_SUCCESS);
}

method display_form()
{
	IGRint status,symbol_num;
	IGRboolean save_data, ignore_data, ansi;

	if (me->dim_type == WELD)
	{
		status =
		DMprocess_weld_form(
			0,
			0,
			0.0,
			me->weldform,
			me->weldform1,
			me->weldform2,
			me->weldform3,
			me->weldform4,
			FALSE,
			&me->above_input,
			&me->form_display,
			TRUE,
			TRUE,
			&save_data,
			&ignore_data,
			&me->par_weld);
		dm$status(action = RET_STATUS);
	}
	else if (me->dim_type == SURF)
	{
		ansi = ((frm_env.pri_unit == MEA_UNIT_FEET_INCHES)
			|| (frm_env.pri_unit == MEA_UNIT_INCHES));

		status =
		DMprocess_surf_form(
			TRUE,
			&me->form_display,
			ansi,
			&save_data,
			&ignore_data,
			TRUE,
			0,
			0,
			0.0,
			me->surfform,
			me->surfform1,
			&frm_surf);
		dm$status(action = RET_STATUS);
	}
	else
	{
		if( me->gt_grid.objid == NULL_OBJID)
		{
			status = FIg_erase(me->form, TOL_SYMB_BUTTON);
			ck_status(status);
		}
		else
		{
			ANget_tol_symbol(
				me->tol_sym,
				&symbol_num,
				&me->dyn_info.info.gtattr,
				me->subform);
			if((status = FIg_set_symbol_index(me->form,
						TOL_SYMB_BUTTON,
						symbol_num)) != FI_SUCCESS)
				return(OM_E_ABORT);
	
			status = FIg_display(me->form, TOL_SYMB_BUTTON);
			ck_status(status);
			if(me->dual_mode)
			{
				status = FIg_disable(me->form,TOL_SYMB_DUAL_LINE);
				if(status != FI_SUCCESS)
					printf("FIg_disable fails:%d\n",status);
			}
		}

		if( !me->form_display)
		{
			status = FIf_display(me->form);
			ck_status(status);
			me->form_display = TRUE;
		}
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

	status =
	dm$get_dim_param(
		type = DM_SENV_PARAM,
		dim_objid = me->gt_grid.objid,
		dim_osnum = me->gt_grid.osnum,
		p_data = (char *)&me->dyn_info.info.par_senv);
	dm$status(action = RET_STATUS);

	status =
	dm$get_dim_param(
		type = DM_WELD_PARAM,
		p_data = (char *)&me->par_weld_sav);
	dm$status(action = RET_STATUS);

	memcpy(&me->par_surf_sav, &frm_surf, sizeof(struct DMsurf_param));

	status =
	dm$get_dim_param(
		type = DM_MISC_PARAM,
		p_data = (char *) &me->dyn_info.info.par_misc);
	dm$status(action = RET_STATUS);

	if(me->form_display)
	{
		status =
		om$send(msg = message COgtedit.display_form(),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method super_cmd.sleep(int pos)
{
	IGRint status;
	Form active_form;

	status =
	om$send(msg = message COdim.sleep(pos),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if(me->form_display)
	{
		if (me->dim_type == WELD)
			active_form = me->weldform;
		else if (me->dim_type == SURF)
			active_form = me->surfform;
		else	active_form = me->form;

		status = FIf_erase(active_form);
		ck_status(status);
	}

	status =
	dm$put_dim_param(
		type = DM_WELD_PARAM,
		p_data = (char *)&me->par_weld_sav);
	dm$status(action = RET_STATUS);

	memcpy(&frm_surf, &me->par_surf_sav, sizeof(struct DMsurf_param));

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

	status =
	dm$put_dim_param(
		type = DM_WELD_PARAM,
		p_data = (char *)&me->par_weld_sav);
	dm$status(action = RET_STATUS);

	memcpy(&frm_surf, &me->par_surf_sav, sizeof(struct DMsurf_param));

	status = FIf_delete(me->form);
	ck_status(status);

	status = FIf_delete(me->subform);
	ck_status(status);

	status = FIf_delete(me->weldform);
	ck_status(status);

	status = FIf_delete(me->weldform1);
	ck_status(status);

	status = FIf_delete(me->weldform2);
	ck_status(status);

	status = FIf_delete(me->weldform3);
	ck_status(status);

	status = FIf_delete(me->weldform4);
	ck_status(status);


	status = FIf_delete(me->surfform);
	ck_status(status);

	status = FIf_delete(me->surfform1);
	ck_status(status);

	return(OM_S_SUCCESS);
}
method getevent(
	IGRint msgkey;
	IGRint *response;
	IGRchar *response_data;
	struct GRevent *event)
{
	IGRint status, rc, mode;

	if ((me->dim_type == TEXT_WITH_BALLOON)
	||  (me->dim_type == WELD))
		mode = EX_LINE_MODE;
	else	mode = EX_ALL_ASCII_MODE;

	status =
	co$getevent(
		msg = &rc,
		event_mask = me->mask1,
		msgnum = msgkey,
		mode = mode,
		nbytes = &me->nbytes,
		response = response,
		response_data = response_data,
		event = event);
	dm$status(action = RET_STATUS);

	if (rc != MSSUCC)
	{
		/*| co$getevent filter fails */
	}

	/*^
		printf("response = %d\n", *response);
		printf("event->response = %d\n", event->response);
	*/

	return(OM_S_SUCCESS);
}

method load_data()
{
	IGRint status,rc;
	IGRlong msg;
	IGRuchar *contents;

	if (me->dim_type == WELD)
	{
		/*|- Load Weld param data from weld symbol*/

		dm$get_dim_param(type = DM_WELD_PARAM, p_data = (char *) &me->par_weld);

		status =
		om$send(msg = message DMweld.get_weld_text(
						&rc,
						&me->par_weld,
						&me->md_env),
			targetid = me->gt_grid.objid,
			targetos = me->gt_grid.osnum);
		dm$status(action = RET_STATUS);

		return(OM_S_SUCCESS);
	}

	if (me->dim_type == SURF)
	{
		/*|- Load Surf param data from surf symbol*/

		status =
		om$send(msg = message DMsurf.get_surf_text(
						&rc,
						&frm_surf,
						&me->md_env),
			targetid = me->gt_grid.objid,
			targetos = me->gt_grid.osnum);
		dm$status(action = RET_STATUS);
        

		return(OM_S_SUCCESS);
	}

    if (me->dim_type != TEXT_WITH_BALLOON)
    {
	status=
	om$send(msg = message DMroot.return_dim_go(&rc,
					DIM_TEXT,
					FALSE,
					DM_TEXT,
					&me->md_env,
					&me->text_grid),
		targetid = me->gt_grid.objid,
		targetos = me->gt_grid.osnum);
	dm$status(action = RET_STATUS);
	if(rc == DIM_E_NO_OBJECT) return(OM_E_ABORT);
    }

	/*"text grid%d\t%d\n",me->text_grid.objid,me->text_grid.osnum*/
	if (me->dim_type == TEXT_WITH_BALLOON)
    {
        if (SecondText == TRUE)
        {
	      status=
	      om$send(msg = message DMroot.return_dim_go(&rc,
					DIM_TEXT2,
					FALSE,
					DM_TEXT,
					&me->md_env,
					&me->text_grid),
		      targetid = me->gt_grid.objid,
		      targetos = me->gt_grid.osnum);
	      dm$status(action = RET_STATUS);
	      if(rc == DIM_E_NO_OBJECT) return(OM_E_ABORT);
        }
        else
        {
	      status=
	      om$send(msg = message DMroot.return_dim_go(&rc,
					DIM_TEXT,
					FALSE,
					DM_TEXT,
					&me->md_env,
					&me->text_grid),
		      targetid = me->gt_grid.objid,
		      targetos = me->gt_grid.osnum);
	      dm$status(action = RET_STATUS);
	      if(rc == DIM_E_NO_OBJECT) return(OM_E_ABORT);
        }
		return(OM_S_SUCCESS);
    }

	status=
	om$send( msg = message GRtext.GRgettxattr( &msg,
					&me->dyn_info.info.text_st.estx,
					&me->dyn_info.info.text_length,
					&contents),
		targetid = me->text_grid.objid,
		targetos = me->text_grid.osnum);
	dm$status(action = RET_STATUS);

	if(contents)
	{
		memcpy(me->dyn_info.info.text_string,
		       contents,
		       me->dyn_info.info.text_length);
		 free(contents);
	}
	else
	{
		me->dyn_info.info.text_string[0] = 0;
		me->dyn_info.info.text_length = 0;
	}

	/*"text length:%d\n",me->dyn_info.info.text_length*/

	DMupdt_disp_chars(me->dyn_info.info.text_string,
			  &me->dyn_info.info.text_length,
			  &me->dyn_info.info.gtattr,
			  me->dual_mode,
			  me->dim_type);

	/*"num disp chars:%d\n",me->dyn_info.info.gtattr.num_disp_char*/

	return(OM_S_SUCCESS);
}

method get_char_under(struct GRevent *dt_event)
{
	IGRint status;
	IGRlong msg;
	struct GRmd_env *loc_env;
	struct GRsymbology active_symb;
	IGRpoint proj_pnt;
        IGRdouble tparms;
	struct IGResintx text_info;
	IGRint index;

	if ((me->dim_type == TEXT_WITH_BALLOON)
	||  (me->dim_type == WELD)
	||  (me->dim_type == SURF))
		return(OM_S_SUCCESS);

	me->dyn_info.info.gtattr.text_font = me->dyn_info.info.par_senv.text_font; 
	loc_env = &me->dim_event.located_object[0].module_info;
	
	ANget_disp_par(&me->dyn_info.info.par_senv,&me->dyn_info.info.text_st,loc_env->md_id.osnum);

	status=	
        om$send(mode = OM_e_wrt_object,
                msg = message GRvg.GRgetgeom(&msg,
					&loc_env->md_env.matrix_type,
					loc_env->md_env.matrix,
                                       (IGRchar *)&me->dyn_info.info.lbsys_geom),
                targetid = me->text_grid.objid,
                targetos = me->text_grid.osnum);
	dm$status(action= RET_STATUS);

        /*
        *  find the level and display attributes of the located
        *  text object
        */

	me->text_origin[0] = me->dyn_info.info.lbsys_geom.matrix[3];
	me->text_origin[1] = me->dyn_info.info.lbsys_geom.matrix[7];
	me->text_origin[2] = me->dyn_info.info.lbsys_geom.matrix[11];

	status =
        om$send(mode = OM_e_wrt_object,
                msg = message GRvg.GRgetsymb(&msg,
				   	     &active_symb),
                targetid = me->text_grid.objid,
                targetos = me->text_grid.osnum);
	dm$status(action = RET_STATUS);

        me->dyn_info.info.text_st.active_display = active_symb.display_attr;

        GRlbsplapproj(&msg,
		      &me->dyn_info.info.lbsys_geom,
                      &dt_event->event.button,
                      proj_pnt,&tparms);


         text_info.estx = &me->dyn_info.info.text_st.estx;
         text_info.font_id = me->md_env.md_id.osnum;
         text_info.text_string = (char *)me->dyn_info.info.text_string;
         text_info.prev_font = -1;
         text_info.flags = 0;

         status = 
	 dp$get_closest_char(msg = &msg,
                             lbsys = &me->dyn_info.info.lbsys_geom,
                             txt_ele = &text_info,
                             osnum = loc_env->md_id.osnum,
                             mod_objid = loc_env->md_id.objid,
                             point = proj_pnt,
                             which_char = &index);
	dm$status(action = RET_STATUS);
	/*"char posn:%d\n",index*/

	DMcompute_disp_char_posn(me->dyn_info.info.text_string,
				 &me->dyn_info.info.text_length,
				 &me->dyn_info.info.gtattr,
				 index,
				 me->dim_type);
	/*"disp char :%ld\n",me->dyn_info.info.gtattr.disp_char_index*/

	return(OM_S_SUCCESS);
}

method position_cursor()
{
	IGRint status;
	IGRlong long_rc;
	IGRshort CurrIndex;
	struct GRcc_info cc_info;
	enum GRdpmode draw_mode;
	IGRboolean line_mode;
	IGRuchar dummy_string[10];

	if ((me->dim_type == TEXT_WITH_BALLOON)
	||  (me->dim_type == WELD)
	||  (me->dim_type == SURF))
		return(OM_S_SUCCESS);

	status =
	om$send(msg = message COgtedit.load_data(),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	cc_info.field_position = 0;
	cc_info.ss_v_move = 0;
	/*^
	analyse_string(me->dyn_info.info.text_string,me->dyn_info.info.text_length);
	*/

	DMcompute_valid_index(me->dyn_info.info.text_string,
			      &me->dyn_info.info.text_length,
			      &CurrIndex,
			      &me->dyn_info.info.gtattr,
			      me->dim_type);

	/*"curr index:%d\n",CurrIndex*/

	status =
	GRchar_pos_info(&long_rc,
			(IGRuchar *)me->dyn_info.info.text_string,
			CurrIndex,
		   	FALSE,
        	        &me->dyn_info.info.text_st.estx,
                	&me->dyn_info.info.text_st.font_info,
			&me->dyn_info.info.text_st.active_display,
			&cc_info);
	dm$status();

	draw_mode = GRhd;
	line_mode = 1 ;	/* - Vertical before  */

	strcpy((char *)dummy_string,"        ");

	status=
	GRtext_cursor(&long_rc,
		      dummy_string,
		      &cc_info,
		      &me->dyn_info.info.text_st.estx,
		      &me->dyn_info.info.lbsys_geom,
		      &draw_mode,
		      &line_mode,
		      FALSE);
	dm$status(action = RET_STATUS);
	return(OM_S_SUCCESS);
}

method get_form_symbol(
	int form_label;
	int g_label;
	double value;
	Form form)
{
	IGRint status,rc;
	IGRint displayed,symbol_num;
	IGRchar symb_type = ' ',symb_char;
	IGRshort active_font = 0;
	struct GTattr *gtattr;
	int Gad_state;
	struct annot_attr attr;
	IGRboolean dual_mode;
	IGRint current_index, action,dummy;
	struct DMenv_param env_param;

	gtattr = &me->dyn_info.info.gtattr;

	if(form_label == FEA_SUBFORM)
	{
		/*|call subform routine*/

		me->tol_sym = g_label;
		ANget_tol_symbol(g_label,&symbol_num,gtattr,form);

		status = FIf_erase(me->subform);
		if( status != FI_SUCCESS)
			printf("FIf_erase fails:%d\n",status);
		status =
		om$send( msg = message DMframe.check_profile_type( &rc,
								g_label,
								&me->md_env),
				targetid = me->gt_grid.objid,
				targetos = me->gt_grid.osnum);
		dm$status(action = RET_STATUS);

		if(!rc)
		{
			ex$message(msgnumb = DM_E_InvTol);
			return(OM_S_SUCCESS);
		}


		status=
		om$send(msg = message DMannot.get_edit_attr(0,&attr),
				targetid =me->gt_grid.objid,
				targetos =me->gt_grid.osnum);
		dm$status(action=RET_STATUS);
	
		DMreplace_tol_sym(me->dyn_info.info.text_string,
				  &me->dyn_info.info.text_length,
				  gtattr->tol_symbol,
				  attr.dual_mode,
				  &me->dyn_info.info.text_st.estx,
				  gtattr);

		status =
		om$send(msg = message DMframe.set_profile_type(g_label),
				targetid = me->gt_grid.objid,
				targetos = me->gt_grid.osnum);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message COgtedit.update_feature(),
			targetid =my_id);
		dm$status(action = RET_STATUS);

		status = FIg_set_symbol_index(
				me->form,
				TOL_SYMB_BUTTON,
				symbol_num);
		if( status != FI_SUCCESS)
		{
			printf("FIf_erase fails:%d\n",status);return(OM_E_ABORT);
		}

		status = FIg_set_state(me->form,TOL_SYMB_BUTTON, 0);
		if( status != FI_SUCCESS)
		{
			printf("FIf_erase fails:%d\n",status);return(OM_E_ABORT);
		}
			
		status = FIg_display(me->form, TOL_SYMB_BUTTON);
		if( status != FI_SUCCESS)
		{
			printf("FIf_erase fails:%d\n",status);return(OM_E_ABORT);
		}
		
		nd$exec_batch();
		return(OM_S_SUCCESS);
	}
	else
	{
		if( g_label == TOL_SYMB_BUTTON)
		{
			status= FIf_is_displayed(me->subform,&displayed);
			if( status != FI_SUCCESS)
				printf("FIf_erase fails:%d\n",status);

			if(!displayed)
			{
				status = FIf_display(me->subform);
				if( status != FI_SUCCESS)
					printf("FIf_erase fails:%d\n",status);
			}
			return(OM_S_SUCCESS);
		}
		else if( g_label == GAD_CHECK)
		{
			if((status =FIf_erase(form)) != FI_SUCCESS)
			{
				/*|FIf_erase_fails */
				 return(OM_E_ABORT);
			}
			if((status = FIg_set_state(form,GAD_CHECK,0)) != FI_SUCCESS)
			{
				/*|FIg_set_state_fails*/
				return(OM_E_ABORT);
			}
			me->form_display = FALSE;
			return(OM_S_SUCCESS);
		}

		Gad_state = 1;
		switch(g_label)
		{

		case TOL_SYMB_SEPERATOR:
			symb_type = SEPERATOR;
			symb_char = ' ';
			active_font = 0;
			break;
		case TOL_SYMB_DUAL_LINE:
			symb_type = TOL_MODE;
			symb_char = ' ';
			break;
		case DIAMETER_SYMBOL:
			symb_type = GEOM_SYMBOL;
                        dm$get_dim_param(
                        	type = DM_ENV_PARAM,
                                dim_objid = NULL_OBJID,
                                dim_osnum = OM_Gw_current_OS,
                                p_data = (char *) &env_param);

                        if (( env_param.dim_stan == DIM_STAN_ANS ) ||
                                ( env_param.dim_stan == DIM_STAN_BSI ))
                        {
                                symb_char = 'W';
                                active_font = gtattr->ter_font;
                        }
                        else
                        {
                                symb_char = '`';
                                active_font =
                                DMmap_font ( me->gt_grid.osnum, FONT_31);
                        }
			break;
		case MAX_MAT_CONFN:
			symb_type = GEOM_SYMBOL;
			symb_char = 'm';
			active_font = gtattr->geom_font;
			break;
		case REGARDLESS_OF_FEATURE:
			symb_type = GEOM_SYMBOL;
			symb_char = 's';
			active_font = gtattr->geom_font;
			break;
		case LEAST_MAT_CONFN:
			symb_type = GEOM_SYMBOL;
			symb_char = 't';
			active_font = gtattr->geom_font;
			break;
		case PROJECTED_TOLERANCE:
			symb_type = GEOM_SYMBOL;
			symb_char = 'p';
			active_font = gtattr->geom_font;
			break;
		default:
			printf("gadget type:%d\n",g_label);
		}

		gtattr->active_font = active_font;
		dual_mode = 0;

		if(me->gt_grid.objid == NULL_OBJID)
			return(OM_S_SUCCESS);

		 if(g_label == TOL_SYMB_DUAL_LINE)
		 {
			status = FIg_disable(me->form,g_label);
			if(status != FI_SUCCESS)
				printf("FIg_disable fails:%d\n",status);
			me->dual_mode =
			dual_mode     = TRUE;
			attr.dual_mode = DUAL_MODE_ON;
			attr.dim_type = me->dim_type;
			status=
			om$send(msg = message DMannot.put_dim_attr(&attr),
					targetid = me->gt_grid.objid,
					targetos = me->gt_grid.osnum);
			dm$status(action = RET_STATUS);
		 }
		 else if(g_label != TOL_SYMB_BUTTON)
		 {
			 status = FIg_set_state(me->form,g_label,Gad_state);
			 if( status != FI_SUCCESS)
				printf("FIf_erase fails:%d\n",status);

			 status = FIg_set_state(me->form,g_label,0);
			 if( status != FI_SUCCESS)
				printf("FIf_erase fails:%d\n",status);
		 }

		DMmake_annot_text(me->dyn_info.info.text_string,
				  &me->dyn_info.info.text_length,
				  &me->dyn_info.info.text_buff_size,
				  &me->dyn_info.info.text_st.estx,
				  symb_type,
				  &symb_char,
				  1,
				  &me->dyn_info.info.gtattr,
				  me->dual_mode,
				  me->dim_type, /* tole mode*/
				  (IGRshort)&me->dyn_info.info.par_misc.sixteen_bit_font,
				  &current_index,
				  &action,&dummy);


		status =
		om$send(msg = message COgtedit.update_feature(),
			targetid =my_id);
		dm$status(action = RET_STATUS);
	}
	return(OM_S_SUCCESS);
}

method update_feature()
{
	IGRint status, rc;

	status =
	om$send(msg = message  NDnode.NDdisplay(
					0,
					GRbe,
					&me->md_env),
		targetid = me->gt_grid.objid,
		targetos = me->gt_grid.osnum);
	dm$status(action = RET_STATUS);

	DMfld_fil(
		me->dyn_info.info.text_string,
		me->dyn_info.info.text_length,
		&me->dyn_info.info.text_st.active_display,
		&me->dyn_info.info.text_st.active_symb);

	/*" gt grid:%d\t%d\n",me->gt_grid.objid,me->gt_grid.osnum*/
	/*" text grid:%d\t%d\n",me->text_grid.objid,me->text_grid.osnum*/
	/*^analyse_string((char *)me->dyn_info.info.text_string,
			  me->dyn_info.info.text_length);
	 */
	status =
	om$send(msg = message  DMroot.replace_text(
				        &rc,
					DIM_TEXT,
					&me->text_grid,
					&me->md_env,
					me->dyn_info.info.text_length,
					(IGRuchar *)me->dyn_info.info.text_string),
		targetid = me->gt_grid.objid,
		targetos = me->gt_grid.osnum);
	dm$status(action = RET_STATUS);

	status =
	dm$change_node(
		exec_batch = FALSE,
		as_grid = me->gt_grid,
		md_env = &me->md_env);
	dm$status(action = RET_STATUS);

	nd$exec_batch();

	return(OM_S_SUCCESS);
}

method update_balloon(
	IGRint text_length;
	IGRchar *text_string)
{
	IGRint status, rc;
	IGRint bytes_char, buflen;
	IGRchar buff[80];
	struct vfont_entry font_info;

	if (text_string[0] & 0x80)
	{
		/*| Kanji input */

		status =
		font$get_info(
			msg = &rc,
			font_num = &me->dyn_info.info.par_misc.sixteen_bit_font,
			font_info = &font_info);
		dm$status(action = RET_STATUS);

		if (!(font_info.flags & SIXTEEN_BIT))
		{
/* Fix for TR 119311178 
                        ex$message(field = MESSAGE_FIELD,
                                   msgnumb = GR_E_ActFntNotSxtnBit);

			return(OM_S_SUCCESS);
*/
  			/* Alt mode char */
			bytes_char = 1;
		}
		else
		{
			bytes_char = 2;
			text_length /= 2;
		}
	}
	else
	{
		/*| normal input */
		bytes_char = 1;
	}

	/*"bytes_char=%d, text_length=%d\n", bytes_char, text_length*/

	if (text_length > ((int)(me->dyn_info.info.par_senv.bln_size + 0.0001)))
	{
		text_length = (int)(me->dyn_info.info.par_senv.bln_size + 0.0001);
		text_string[text_length * bytes_char] = '\0';

                ex$message(msgnumb = DM_I_TextTooLongTrunc,
                           type = "%s",
                           var = `text_string`);
	}

	if (text_string[0] & 0x80)
	{
		if ((text_length + 4) > sizeof(buff))
		{
			ex$message(msgnumb = DM_I_TextTooLong);
			return(OM_S_SUCCESS);
		}

		buff[0] = ESC;
		buff[1] = 'f';
		memcpy(&buff[2], &me->dyn_info.info.par_misc.sixteen_bit_font, 2);
		memcpy(&buff[4], text_string, text_length * bytes_char);
		buflen = 4 + text_length * bytes_char;
	}
	else
	{
		if (text_length > sizeof(buff))
		{
			ex$message(msgnumb = DM_I_TextTooLong);
			return(OM_S_SUCCESS);
		}

		memcpy(buff, text_string, text_length);
		buflen = text_length;
	}

	status =
	om$send(msg = message COgtedit.display_dimension(GRbe),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message GRtext.GRreplace_text(
					(IGRlong *)&rc,
					&me->md_env,
					buflen,
					(IGRuchar *)buff),
		targetid = me->text_grid.objid,
		targetos = me->text_grid.osnum);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message NDnode.NDs_compute_node((IGRlong *)&rc, NULL, &me->md_env),
		targetid = me->gt_grid.objid,
		targetos = me->gt_grid.osnum);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COgtedit.display_dimension(GRbd),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	me->state = STATE_P_LOC_DIM;
	return(OM_S_SUCCESS);
}

method update_weld()
{
	IGRint status, rc;

	status =
	om$send(msg = message COgtedit.display_dimension(GRbe),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message NDnode.NDs_compute_node((IGRlong *)&rc, NULL, &me->md_env),
		targetid = me->gt_grid.objid,
		targetos = me->gt_grid.osnum);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COgtedit.display_dimension(GRbd),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	me->state = STATE_P_LOC_DIM;
	return(OM_S_SUCCESS);
}

method update_surf()
{
	IGRint status, rc;

	status =
	om$send(msg = message COgtedit.display_dimension(GRbe),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message NDnode.NDs_compute_node((IGRlong *)&rc, NULL, &me->md_env),
		targetid = me->gt_grid.objid,
		targetos = me->gt_grid.osnum);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message COgtedit.display_dimension(GRbd),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	me->state = STATE_P_LOC_DIM;
	return(OM_S_SUCCESS);
}

end implementation COgtedit;
