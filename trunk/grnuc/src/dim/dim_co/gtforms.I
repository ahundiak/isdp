/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:30 $
$Locker:  $
$Log: gtforms.I,v $
Revision 1.1.1.1  2001/12/17 22:39:30  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:07:54  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:21:53  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:51:23  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.2  1993/08/03  13:25:03  samuel
# COMMENT : Fix for TR# 119300474 -samuel
#
# Revision 240.1  1992/12/28  15:10:34  gvk
# COMMENT : Dimension fixes.
#
Revision 201.3  1992/01/28  10:37:38  dimdp20
COMMENT : Dimension Fixes Checkin - S. Poovannan - Jan 28 1992

*/

class implementation COanplace;

#define AS_DEBUG   1
#include "dimdef.h"
#include "dim.h"
#include "dimfont.h"
#include "FI.h"
#include "dimformdef.h"
from  DMannot import put_dim_attr,get_edit_attr;
from DMframe import make_profile_sym;
from DMframe import set_profile_type,check_profile_type;
method get_gt_symbol(
	int form_label;
	int g_label;
	double value;
	Form form)
{
	IGRint status ,rc;
	struct DMsenv_param par_senv;
	IGRint symbol_num;
	IGRchar symb_type ,symb_char;
	IGRshort active_font;
	struct GTattr *gtattr;
	int updt_flag,Gad_state;
	struct annot_attr attr;
	IGRboolean dual_mode;
	IGRint bytes_affected, current_index, action, dummy;
	struct DMenv_param env_param;


	gtattr = &me->dyn_info.info.gtattr;

	if(form_label == SUB_FORM)
	{
		/*|call subform routine*/

		ANget_tol_symbol(g_label,&symbol_num,gtattr,form);

		status = FIf_erase(me->subform);
		fi$status(sts=status,comment = "FIf_erase");

		if( me->an_grid.objid != NULL_OBJID)
		{
			status =
			om$send( msg = message DMframe.check_profile_type( &rc,
									g_label,
									&me->dyn_env),
					targetid = me->an_grid.objid,
					targetos = me->an_grid.osnum);
			dm$status(action = RET_STATUS);

			if(!rc)
			{
				ex$message(msgnumb = DM_E_InvTol);
				return(OM_S_SUCCESS);
			}
			me->tol_sym = g_label;

			status=
			om$send(msg = message DMannot.get_edit_attr(0,&attr),
					targetid =me->an_grid.objid,
					targetos =me->an_grid.osnum);
			dm$status(action=RET_STATUS);
			me->dual_mode = attr.dual_mode;
			
			DMreplace_tol_sym(me->dyn_info.info.text_string,
					  &me->dyn_info.info.text_length,
					  gtattr->tol_symbol,
					  attr.dual_mode,
					  &me->dyn_info.info.text_st.estx,
					  gtattr);
			status =
			om$send(msg = message DMframe.set_profile_type( me->tol_sym),
					targetid = me->an_grid.objid,
					targetos = me->an_grid.osnum);
			dm$status(action = RET_STATUS);

			dm$get_dim_param( type = DM_SENV_PARAM , p_data = (char *) &par_senv);

			status =
			om$send(msg = message DMframe.make_profile_sym(
								&rc,
								&par_senv,
								&me->plan_info,
								&me->dyn_env),
					targetid = me->an_grid.objid,
					targetos = me->an_grid.osnum);
			dm$status(action = RET_STATUS);
		}
		else 
			me->tol_sym = g_label;

		status = FIg_set_symbol_index(
				me->form,
				TOL_SYMB_BUTTON,
				symbol_num);
		fi$status(sts = status, comment = "FIg_set_symbol_index");

		status = FIg_set_state(me->form,TOL_SYMB_BUTTON, 0);
		fi$status(sts = status,comment = "FIg_set_state");
			
		status = FIg_display(me->form, TOL_SYMB_BUTTON);
		fi$status(sts = status,comment = "FIg_display");
		
		return(OM_S_SUCCESS);
	}
	else
	{
		/*|MASTER FORM*/
		if( g_label == TOL_SYMB_BUTTON)
		{
			IGRint xpos, ypos;

/******************************START FIX of TR *0403***************************************/


			status = FIf_get_location(me->form,
						&xpos,&ypos);
			fi$status(sts = status,comment = "FIf_get_location");
			
			status = FIf_set_location(me->subform,
						xpos,ypos);
			fi$status(sts = status,comment = "FIf_set_location");

/****************************END FIX TR *0403******************************************/

			status = FIf_display(me->subform);

			fi$status(sts = status,comment = "FIf_display");
				
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
			symb_char =' ';
			active_font = 0;
			break;
		case TOL_SYMB_DUAL_LINE:
			symb_type = TOL_MODE;
			symb_char = ' ';
			break;
		case DIAMETER_SYMBOL:
                        dm$get_dim_param(
                        	type = DM_ENV_PARAM,
                                dim_objid = NULL_OBJID,
                                dim_osnum = OM_Gw_current_OS,
                                p_data = (char *) &env_param);

			symb_type = GEOM_SYMBOL;
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
                                DMmap_font ( me->an_grid.osnum, FONT_31);
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

		if(me->an_grid.objid == NULL_OBJID)
			return(OM_S_SUCCESS);

		 if(g_label == TOL_SYMB_DUAL_LINE)
		 {
			status = FIg_disable(me->form,g_label);
			if(status != FI_SUCCESS)
				printf("FIg_disable fails:%d\n",status);
			dual_mode = TRUE;
			attr.dual_mode = DUAL_MODE_ON;
			attr.dim_type = me->an_type;
			status=
			om$send(msg = message DMannot.put_dim_attr(&attr),
					targetid = me->an_grid.objid,
					targetos = me->an_grid.osnum);
			dm$status(action = RET_STATUS);
			
			status =
			om$send(msg = message COanplace.set_dim_state( DIM_NEEDS_UPDATE ),
					targetid = my_id);
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
				  dual_mode,
				  me->an_type,
				  me->dyn_info.info.par_misc.sixteen_bit_font,
				  &current_index,
				  &action,
				  dummy);

	}
	return(OM_S_SUCCESS);
}

ANget_tol_symbol (g_label,symbol_num,gtattr,form)
	 int  g_label;
	 int  *symbol_num;
	 struct GTattr  *gtattr;
	 Form  form;
/*.ANget_tol_symbol*/
{
	IGRint status;
	int	BrkTextNeeded;

	switch(g_label)
	{
	case STRAIGHTNESS:
		*symbol_num = 22;
		gtattr->tol_symbol = 'b';
		break;
	case FLATNESS:
		*symbol_num = 23;
		gtattr->tol_symbol = 'c';
		break;
	case CIRCULARITY:
		*symbol_num = 24;
		gtattr->tol_symbol = 'e';
		break;
	case CYLINDRICITY:
		*symbol_num = 25;
		gtattr->tol_symbol = 'g';
		break;
	case ANGULARITY:
		*symbol_num = 26;
		gtattr->tol_symbol = 'a';
		break;
	case PERPENDICULARITY:
		*symbol_num = 27;
		gtattr->tol_symbol = 'l';
		break;
	case PARALLELISM:
		*symbol_num = 28;
		gtattr->tol_symbol = 'f';
		break;
	case SYMMETRY:
		*symbol_num = 29;
		gtattr->tol_symbol = 'i';
		break;
	case PROFILE_LINE:
		*symbol_num = 30;
		gtattr->tol_symbol = 'k';
		break;
	case PROFILE_LINE_TOT:
		*symbol_num = 0;
		gtattr->tol_symbol = TOL_SYMBOL_NONE;
		BrkTextNeeded = TRUE;
		break;
	case PROFILE_SURFACE:
		*symbol_num = 31;
		gtattr->tol_symbol = 'd';
		break;
	case PROFILE_SURFACE_TOT:
		gtattr->tol_symbol = 'd';
		*symbol_num = 33;
/*
		*symbol_num = 33;
		BrkTextNeeded = TRUE;
		gtattr->tol_symbol = 'd';
*/
		break;
	case POSITION:
		*symbol_num = 34;
		gtattr->tol_symbol = 'j';
		break;
	case CONCENTRICITY:
		*symbol_num = 35;
		gtattr->tol_symbol = 'r';
		break;
	case CIRCULAR_RUNOUT:
		*symbol_num = 36;
		gtattr->tol_symbol = 'h';
		break;
	case TOTAL_RUNOUT:
		*symbol_num = 37;
		gtattr->tol_symbol = 'q';
		break;
	default:
		/*"tolerance label:%d\n",g_label*/
		break;
	}

	if(form)
	{
		status = FIg_set_state(form,g_label,1);
		if( status != FI_SUCCESS)
		{
			printf("set state failed:%d\n",status);
			return(OM_E_ABORT);
		}
	}

	return(TRUE);
}

end implementation COanplace;
