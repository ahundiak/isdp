/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:30 $
$Locker:  $
$Log: weldtxt.I,v $
Revision 1.1.1.1  2001/12/17 22:39:30  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:07:28  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.1  1997/02/21  09:01:40  bsubbaia
# COMMENT : Place weld symbology enhancements
#
# Revision 330.0  1996/01/11  21:21:27  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.1  1995/10/24  06:32:04  gvk
# COMMENT : Updating weld symbols only on edit annotation text command
#
# Revision 320.0  1994/12/12  17:50:56  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.1  1994/11/01  10:12:01  gvk
# COMMENT : Included prototypes for BSfunctions and GRNUC calls which return double.
#
# Revision 240.0  1992/12/06  23:42:11  tim
# COMMENT : Initial checkin to 2.4 RCS
#
# Revision 220.0  1992/08/29  06:21:51  root
# COMMENT : Corresponds to Rel201.9 in 2.0.1 RCS
#
Revision 201.9  1992/07/20  05:31:08  poo
COMMENT : ANSI compilance, CR 91N0643, and correcting modified fuction calls.

Revision 201.6  1992/02/03  13:01:08  dimdp20
COMMENT : Dimensioning Fixes Release - S. Poovannan - Feb 3 1992

Revision 201.5  1992/01/28  10:37:53  dimdp20
COMMENT : Dimension Fixes Checkin - S. Poovannan - Jan 28 1992


*/

class implementation DMweld;

#define AS_DEBUG	1

#include "fielddef.h"
#include "dimweld.h"
#include "weldform.h"
#include "bsnorvec.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bscrossp.h"
#include "bsarc3pts.h"

from GRtext import GRreplace_text, GRgettxattr;

extern double tan();
extern double atof();
extern double fabs();

method make_weld_text(
	IGRint *msg;
	struct DMplan_info *plan_info;
	struct DMsenv_param *par_senv;
	struct GRid comp_grid[];
	struct GRmd_env *md_env)
{
	IGRint status, rc, i;
	IGRshort txt_length;
	IGRchar text_string[512], weld_char;
	IGRlong long_rc;
	IGRshort f_str_len, r_str_len, i_str_len;
	struct DMweld_param par_weld;

	/*|- get weld param */

	dm$get_dim_param(type = DM_WELD_PARAM, 
		p_data = &par_weld);

	f_str_len     =
	r_str_len     =
	i_str_len     = 0;

	if ((me->dim_state & DIM_IN_PLACEMENT)
	||  (me->dim_state & DIM_TEXT_NEEDS_UPDATE)) 

	{
		/*|- Update all the instance and txt value from global struct */

		me->above = par_weld.above;
		me->below = par_weld.below;
		me->center = par_weld.center;
		me->flag = par_weld.flag;
		me->circle = par_weld.circle;
		me->leader = par_weld.dash_line;
		me->tol_symbol = par_weld.z_symb;
		me->tail = par_weld.tail;
		me->ansi_weld = par_weld.ansi_weld;

		if (me->above && me->below)
			me->dual_mode = TRUE;

		me->front_len = me->rear_len = me->inter_len = 0;

	              /*	
			printf("above = %d, below = %d, center = %d\n",
				par_weld.above,par_weld.below,par_weld.center);
			printf("tail = %d, flag = %d, circle = %d\n",
				par_weld.tail,par_weld.flag,par_weld.circle);
			printf("atext.f = %s\n",par_weld.atext.ftext);
			printf("atext.r = %s\n",par_weld.atext.rtext);
			printf("atext.z = %s\n",par_weld.atext.ztext);
			printf("aweld_symb = %d\n",par_weld.atext.weld_symbol);
			printf("aweld_type = %d\n",par_weld.atext.weld_type);
			printf("btext.f = %s\n",par_weld.btext.ftext);
			printf("btext.r = %s\n",par_weld.btext.rtext);
			printf("btext.z = %s\n",par_weld.btext.ztext);
			printf("bweld_symb = %d\n",par_weld.btext.weld_symbol);
			printf("bweld_type = %d\n",par_weld.btext.weld_type);
			printf("cen_symb = %d\n", par_weld.cen_symb);
	
                      */
		status =
		om$send(msg = message DMweld.get_components(
						TRUE,
						comp_grid,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if (me->center||me->above)
		{
		 if(me->above)me->weld_symb1 = par_weld.atext.weld_symbol;
                 if(me->above)me->weld_type1 = par_weld.atext.weld_type;
			me->front_len = strlen(par_weld.atext.ftext);
			me->rear_len = strlen(par_weld.atext.rtext);

			if (me->front_len > 0)
			{
				txt_length = me->front_len;
				strcpy(text_string, par_weld.atext.ftext);
				status = DMappend_space(text_string, AN_AFTER, &txt_length, 1.75);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message GRtext.GRreplace_text(
								&long_rc,
								md_env,
								txt_length,
								(unsigned char *)text_string),
					targetid = comp_grid[AFTEXT].objid,
					targetos = comp_grid[AFTEXT].osnum);
				dm$status(action = RET_STATUS);
			}
			else
			{
				status =
				om$send(msg = message DMroot.delete_dim_go(
								&rc,
								AFTEXT,
								md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				comp_grid[AFTEXT].objid = NULL_OBJID;
			}

			if (me->rear_len > 0)
			{
				txt_length = me->rear_len;
				strcpy(text_string, par_weld.atext.rtext);
				status = DMappend_space(text_string, AN_BEFORE, &txt_length, 1.75);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message GRtext.GRreplace_text(
								&long_rc,
								md_env,
								txt_length,
								(unsigned char *)text_string),
					targetid = comp_grid[ARTEXT].objid,
					targetos = comp_grid[ARTEXT].osnum);
				dm$status(action = RET_STATUS);
			}
			else
			{
				status =
				om$send(msg = message DMroot.delete_dim_go(
								&rc,
								ARTEXT,
								md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				comp_grid[ARTEXT].objid = NULL_OBJID;
			}

			/*|- Place weld shape */
                        if(me->above)
                        {
			if (me->ansi_weld )
			{
				/*|- Text above symbol present*/

				text_string[0] = '\0';
				txt_length = 0;

				status =
				DMmake_weld_symbol(
					TRUE,
					OM_Gw_current_OS,
					&par_weld,
					par_senv,
					text_string,
					&txt_length);
				dm$status(action = RET_STATUS);

				if (txt_length > 0)
				{
					status =
					om$send(msg = message GRtext.GRreplace_text(
								&long_rc,
								md_env,
								txt_length,
								(unsigned char *)text_string),
						targetid = comp_grid[AATEXT].objid,
						targetos = comp_grid[AATEXT].osnum);
					dm$status(action = RET_STATUS);
	
					status =
					DMget_weld_symbol_char(
						me->weld_symb1,
						WL_BLANK,
						&weld_char);
					dm$status(action = RET_STATUS);
				}
				else
				{
					status =
					DMget_weld_symbol_char(
						me->weld_symb1,
						me->weld_type1,
						&weld_char);
					dm$status(action = RET_STATUS);

					status =
					om$send(msg = message DMroot.delete_dim_go(
									&rc,
									AATEXT,
									md_env),
						targetid = my_id);
					dm$status(action = RET_STATUS);

					comp_grid[AATEXT].objid = NULL_OBJID;
				}
			}
			else
			{
				status =
				DMget_weld_symbol_char(
					me->weld_symb1,
					me->weld_type1,
					&weld_char);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message DMroot.delete_dim_go(
								&rc,
								AATEXT,
								md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				comp_grid[AATEXT].objid = NULL_OBJID;
			}
                      

			/*|- Place Above symbol Text */

			text_string[0] = weld_char;
			text_string[1] = '\0';

			status =
			om$send(msg = message GRtext.GRreplace_text(
							&long_rc,
							md_env,
							1,
							(unsigned char *)text_string),
				targetid = comp_grid[SYMBOL1].objid,
				targetos = comp_grid[SYMBOL1].osnum);
			dm$status(action = RET_STATUS);
                      }		
                }
		else
		{
			for (i=0; i<3; i++)
			{
				status =
				om$send(msg = message DMroot.delete_dim_go(
								&rc,
								i,
								md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				comp_grid[i].objid = NULL_OBJID;
			}

			if (!me->center)
			{
				status =
				om$send(msg = message DMroot.delete_dim_go(
								&rc,
								SYMBOL1,
								md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				comp_grid[SYMBOL1].objid = NULL_OBJID;
			}
		}

		if (me->below ||me->center)
		{
			if (me->above)
			{
				me->weld_symb2 = par_weld.btext.weld_symbol;
				me->weld_type2 = par_weld.btext.weld_type;
			}
		        if(me->below)	
			{
				me->weld_symb1 = par_weld.btext.weld_symbol;
				me->weld_type1 = par_weld.btext.weld_type;
			}

			f_str_len = strlen(par_weld.btext.ftext);
			r_str_len = strlen(par_weld.btext.rtext);

			if (me->front_len < f_str_len)
				me->front_len = f_str_len;
			if (me->rear_len < r_str_len)
				me->rear_len = r_str_len;

			if (f_str_len > 0)
			{
				txt_length = f_str_len;
				strcpy(text_string, par_weld.btext.ftext);
				status = DMappend_space(text_string, AN_AFTER, &txt_length, 1.75);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message GRtext.GRreplace_text(
								&long_rc,
								md_env,
								txt_length,
								(unsigned char *)text_string),
					targetid = comp_grid[BFTEXT].objid,
					targetos = comp_grid[BFTEXT].osnum);
				dm$status(action = RET_STATUS);
			}
			else
			{
				status =
				om$send(msg = message DMroot.delete_dim_go(
								&rc,
								BFTEXT,
								md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				comp_grid[BFTEXT].objid = NULL_OBJID;
			}

			if (r_str_len > 0)
			{
				txt_length = r_str_len;
				strcpy(text_string, par_weld.btext.rtext);
				status = DMappend_space(text_string, AN_BEFORE, &txt_length, 1.75);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message GRtext.GRreplace_text(
								&long_rc,
								md_env,
								txt_length,
								(unsigned char *)text_string),
					targetid = comp_grid[BRTEXT].objid,
					targetos = comp_grid[BRTEXT].osnum);
				dm$status(action = RET_STATUS);
			}
			else
			{
				status =
				om$send(msg = message DMroot.delete_dim_go(
								&rc,
								BRTEXT,
								md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				comp_grid[BRTEXT].objid = NULL_OBJID;
			}

			/*|- Place weld shape */
                        if(me->below)
                        {
			if (me->ansi_weld)
			{
				/*|- Text below symbol present*/

				text_string[0] = '\0';
				txt_length = 0;

				status =
				DMmake_weld_symbol(
					FALSE,
					OM_Gw_current_OS,
					&par_weld,
					par_senv,
					text_string,
					&txt_length);
				dm$status(action = RET_STATUS);

				if (txt_length > 0)
				{
					status =
					om$send(msg = message GRtext.GRreplace_text(
								&long_rc,
								md_env,
								txt_length,
								(unsigned char *)text_string),
						targetid = comp_grid[BATEXT].objid,
						targetos = comp_grid[BATEXT].osnum);
					dm$status(action = RET_STATUS);
	
					status =
					DMget_weld_symbol_char(
						par_weld.btext.weld_symbol,
						WL_BLANK,
						&weld_char);
					dm$status(action = RET_STATUS);
				}
				else
				{
					status =
					DMget_weld_symbol_char(
						par_weld.btext.weld_symbol,
						par_weld.btext.weld_type,
						&weld_char);
					dm$status(action = RET_STATUS);

					status =
					om$send(msg = message DMroot.delete_dim_go(
								&rc,
								BATEXT,
								md_env),
						targetid = my_id);
					dm$status(action = RET_STATUS);

					comp_grid[BATEXT].objid = NULL_OBJID;
				}
			}
			else
			{
				status =
				DMget_weld_symbol_char(
					par_weld.btext.weld_symbol,
					par_weld.btext.weld_type,
					&weld_char);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message DMroot.delete_dim_go(
								&rc,
								BATEXT,
								md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				comp_grid[BATEXT].objid = NULL_OBJID;
			}

			/*|- Place Below symbol Text */

			text_string[0] = weld_char;
			text_string[1] = '\0';

			status =
			om$send(msg = message GRtext.GRreplace_text(
							&long_rc,
							md_env,
							1,
							(unsigned char *)text_string),
				targetid = comp_grid[SYMBOL2].objid,
				targetos = comp_grid[SYMBOL2].osnum);
			dm$status(action = RET_STATUS);
		       }
                }
		else
		{
			for (i=3; i<6; i++)
			{
				status =
				om$send(msg = message DMroot.delete_dim_go(
								&rc,
								i,
								md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				comp_grid[i].objid = NULL_OBJID;
			}

			status =
			om$send(msg = message DMroot.delete_dim_go(
							&rc,
							SYMBOL2,
							md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			comp_grid[SYMBOL2].objid = NULL_OBJID;
		}

		if (me->tol_symbol)
		{
			text_string[0] = 'Z';
			text_string[1] = '\0';

			status =
			om$send(msg = message GRtext.GRreplace_text(
							&long_rc,
							md_env,
							1,
							(unsigned char *)text_string),
				targetid = comp_grid[ZSTEXT].objid,
				targetos = comp_grid[ZSTEXT].osnum);
			dm$status(action = RET_STATUS);

			if (me->above)
			me->inter_len = strlen(par_weld.atext.ztext);
			
			if (me->inter_len > 0)
			{
				txt_length = me->inter_len;
				strcpy(text_string, par_weld.atext.ztext);
				status = DMappend_space(text_string, AN_BEFORE, &txt_length, 1.0);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message GRtext.GRreplace_text(
								&long_rc,
								md_env,
								txt_length,
								(unsigned char *)text_string),
					targetid = comp_grid[AZTEXT].objid,
					targetos = comp_grid[AZTEXT].osnum);
				dm$status(action = RET_STATUS);
			}
			else
			{
				status =
				om$send(msg = message DMroot.delete_dim_go(
								&rc,
								AZTEXT,
								md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				comp_grid[AZTEXT].objid = NULL_OBJID;
			}

			if (me->below)
			i_str_len = strlen(par_weld.btext.ztext);

			if (me->inter_len < i_str_len)
				me->inter_len = i_str_len;

			if (i_str_len > 0)
			{
				txt_length = i_str_len;
				strcpy(text_string, par_weld.btext.ztext);
				status = DMappend_space(text_string, AN_BEFORE, &txt_length, 1.0);
				dm$status(action = RET_STATUS);

				status =
				om$send(msg = message GRtext.GRreplace_text(
								&long_rc,
								md_env,
								txt_length,
								(unsigned char *)text_string),
					targetid = comp_grid[BZTEXT].objid,
					targetos = comp_grid[BZTEXT].osnum);
				dm$status(action = RET_STATUS);
			}
			else
			{
				status =
				om$send(msg = message DMroot.delete_dim_go(
								&rc,
								BZTEXT,
								md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				comp_grid[BZTEXT].objid = NULL_OBJID;
			}
		}
		else
		{
			for (i=8; i<11; i++)
			{
				status =
				om$send(msg = message DMroot.delete_dim_go(
								&rc,
								i,
								md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				comp_grid[i].objid = NULL_OBJID;
			}
		}

		if (me->center)
		{
			/*|- Place center Text */

			me->weld_symb1 = par_weld.cen_symb;

			if (par_weld.cen_symb == GAD_SYMBOL1_BZ)
				text_string[0] = 108;
			else	text_string[0] = 109;

			text_string[1] = '\0';

			status =
			om$send(msg = message GRtext.GRreplace_text(
							&long_rc,
							md_env,
							1,
							(unsigned char *)text_string),
				targetid = comp_grid[SYMBOL1].objid,
				targetos = comp_grid[SYMBOL1].osnum);
			dm$status(action = RET_STATUS);
		}
		else
		{
			if (!me->above)
			{
				status =
				om$send(msg = message DMroot.delete_dim_go(
								&rc,
								SYMBOL1,
								md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				comp_grid[SYMBOL1].objid = NULL_OBJID;
			}
		}

		if (me->tail)
		{
			txt_length = strlen(par_weld.tailtext);
			strcpy(text_string, par_weld.tailtext);
			status = DMappend_space(text_string, AN_AFTER, &txt_length, 1.0);
			dm$status(action = RET_STATUS);
			status = DMappend_space(text_string, AN_BEFORE, &txt_length, 1.0);
			dm$status(action = RET_STATUS);

			if (txt_length > 0)
			{
				status =
				om$send(msg = message GRtext.GRreplace_text(
								&long_rc,
								md_env,
								txt_length,
								(unsigned char *)text_string),
					targetid = comp_grid[TLTEXT].objid,
					targetos = comp_grid[TLTEXT].osnum);
				dm$status(action = RET_STATUS);
			}
			else
			{
				status =
				om$send(msg = message DMroot.delete_dim_go(
								&rc,
								TLTEXT,
								md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				comp_grid[TLTEXT].objid = NULL_OBJID;
			}
		}
		else
		{
			status =
			om$send(msg = message DMroot.delete_dim_go(
							&rc,
							TLTEXT,
							md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			comp_grid[TLTEXT].objid = NULL_OBJID;
		}


		if (me->flag)
		{
			/*|- Place Flag Text */

			text_string[0] = '1';
			text_string[1] = '\0';

			status =
			om$send(msg = message GRtext.GRreplace_text(
							&long_rc,
							md_env,
							1,
							(unsigned char *)text_string),
				targetid = comp_grid[FLAG].objid,
				targetos = comp_grid[FLAG].osnum);
			dm$status(action = RET_STATUS);
		}
		else
		{
			status =
			om$send(msg = message DMroot.delete_dim_go(
							&rc,
							FLAG,
							md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			comp_grid[FLAG].objid = NULL_OBJID;
		}

		if (me->circle)
		{
			/*|- Place circle Text */

			text_string[0] = 50;
			text_string[1] = '\0';

			status =
			om$send(msg = message GRtext.GRreplace_text(
							&long_rc,
							md_env,
							1,
							(unsigned char *)text_string),
				targetid = comp_grid[CIRCLE].objid,
				targetos = comp_grid[CIRCLE].osnum);
			dm$status(action = RET_STATUS);
		}
		else
		{
			status =
			om$send(msg = message DMroot.delete_dim_go(
							&rc,
							CIRCLE,
							md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			comp_grid[CIRCLE].objid = NULL_OBJID;
		}
	}

	/*"txt_lengths: f_len = %d, r_len = %d, i_len = %d\n",
		me->front_len, me->rear_len, me->inter_len*/

	*msg = OM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method position_weld_text(
	IGRint *msg;
	IGRdouble break_pt[3];
	IGRdouble tail_pt[3];
	IGRdouble flag_pt[3];
	struct GRid text_grid[];
	struct DMplan_info *plan_info;
	struct DMsenv_param *par_senv;
	struct GRmd_env *md_env)
{
	IGRint status, index, i, rc;
	IGRshort txt_just[16];
	IGRdouble *normal, *origin, norm[3], *txt_dir;
	IGRdouble weld_pt[3], z_pt[3], norm_o[3];
	IGRdouble weld_offset, z_offset, tail_offset;
	IGRdouble aweldpt[3], bweldpt[3];
	IGRdouble azpt[3], bzpt[3];
	IGRdouble asympt[3], bsympt[3];

	/*|- Set the justification of all the text */

	txt_just[AFTEXT] = RIGHT_BOTTOM;
	txt_just[ARTEXT] = LEFT_BOTTOM;
	txt_just[AATEXT] = CENTER_BOTTOM;
	txt_just[SYMBOL1] = (me->center)?CENTER_CENTER:CENTER_BASE;
	txt_just[BFTEXT] = RIGHT_TOP;
	txt_just[BRTEXT] = LEFT_TOP;
	txt_just[BATEXT] = CENTER_TOP;
	txt_just[SYMBOL2] = CENTER_BASE;
	txt_just[ZSTEXT] = CENTER_CENTER;
	txt_just[AZTEXT] = LEFT_BOTTOM;
	txt_just[BZTEXT] = LEFT_TOP;
	txt_just[TLTEXT] = (me->bln_dir == RIGHT_SIDE)?
				LEFT_CENTER:RIGHT_CENTER;
	txt_just[FLAG]	 = LEFT_BASE;
	txt_just[CIRCLE] = CENTER_CENTER;
	
	norm[0] = plan_info->win_plan.matrix[8];
	norm[1] = plan_info->win_plan.matrix[9];
	norm[2] = plan_info->win_plan.matrix[10];

	norm_o[0] = -norm[0];
	norm_o[1] = -norm[1];
	norm_o[2] = -norm[2];

	/*|- Compute text offsets */

	if (me->bln_dir == RIGHT_SIDE)
	{
		tail_offset = (me->front_len + me->rear_len + me->inter_len+ 5) * par_senv->txt_widt;
		z_offset = (me->front_len + me->rear_len + 4.5) * par_senv->txt_widt;
		weld_offset = (me->front_len + 2.5) * par_senv->txt_widt;
		txt_dir = plan_info->act_plan.vec_xpos;
	}
	else
	{
		tail_offset = (me->front_len + me->rear_len + me->inter_len+ 5) * par_senv->txt_widt;
		weld_offset = (me->inter_len + me->rear_len + 3.5) * par_senv->txt_widt;
		z_offset = (me->inter_len + 1.5) * par_senv->txt_widt;
		txt_dir = plan_info->act_plan.vec_xneg;
	}

	/*^ printf("tail_offset = %f, z_offset = %f, weld_offset = %f\n",
		tail_offset, z_offset, weld_offset); */

	/*|- Find the text points */

	for (i=0; i<3; i++)
	{
		tail_pt[i] = break_pt[i] + (txt_dir[i] * tail_offset);
		z_pt[i] = break_pt[i] + (txt_dir[i] * z_offset);
		weld_pt[i] = break_pt[i] + (txt_dir[i] * weld_offset);
	}

	/*^
		print_point("break_pt",break_pt);
		print_point("flag_pt",flag_pt);
		print_point("tail_pt",tail_pt);
		print_point("z_pt",z_pt);
		print_point("weld_pt",weld_pt);
	*/

	if (me->leader == ABOVE)
	{
		/*|- Dash Line present Move above text pt */
		
		for (i=0; i<3; i++)
		{
			aweldpt[i] = weld_pt[i] +
			(0.3 * par_senv->txt_heig * plan_info->act_plan.vec_ypos[i]);
			azpt[i] = z_pt[i] +
			(0.3 * par_senv->txt_heig * plan_info->act_plan.vec_ypos[i]);
		}

		vec_equal(weld_pt, bweldpt);
		vec_equal(z_pt, bzpt);
	}
	else if (me->leader == BELOW)
	{
		/*|- Dash Line present Move below text pt */
		
		for (i=0; i<3; i++)
		{
			bweldpt[i] = weld_pt[i] +
			(0.3 * par_senv->txt_heig * plan_info->act_plan.vec_yneg[i]);
			bzpt[i] = z_pt[i] +
			(0.3 * par_senv->txt_heig * plan_info->act_plan.vec_yneg[i]);
		}

		vec_equal(weld_pt, aweldpt);
		vec_equal(z_pt, azpt);
	}
	else
	{
		/*|- Dash Line absent */

		vec_equal(weld_pt, aweldpt);
		vec_equal(z_pt, azpt);
		vec_equal(weld_pt, bweldpt);
		vec_equal(z_pt, bzpt);
	}

	for (i=0; i<3; i++)
	{
		asympt[i] = aweldpt[i] +
		(2 * par_senv->txt_heig * plan_info->act_plan.vec_ypos[i]);
		bsympt[i] = bweldpt[i] +
		(2 * par_senv->txt_heig * plan_info->act_plan.vec_yneg[i]);
	}

	for (index=0; index<14; index++)
	{
		if (text_grid[index].objid != NULL_OBJID)
		{
			/*|- Text object present */

			if (index < AATEXT)
				origin = aweldpt;
			else if (index == AATEXT)
				origin = asympt;
			else if (index < BATEXT)
				origin = bweldpt;
			else if (index == BATEXT)
				origin = bsympt;
			else if (index == SYMBOL1)
				origin = (me->center)?weld_pt:aweldpt;
			else if (index == SYMBOL2)
				origin = bweldpt;
			else if (index == ZSTEXT)
				origin = z_pt;
			else if (index == AZTEXT)
				origin = azpt;
			else if (index == BZTEXT)
				origin = bzpt;
			else if (index == TLTEXT)
				origin = tail_pt;
			else	origin = flag_pt;

			normal = (index == SYMBOL2)?norm_o:norm;
				
			/*^
				printf("position_text: index = %d\n",index);
				print_grid("text_grid",&text_grid[index]);
				printf("txt_just = %d\n",txt_just[index]);
				print_point("origin",origin);
				print_point("normal",normal);
			*/

			status =
			om$send(msg = message DMroot.position_text(
						&rc,
						FALSE,
						DIM_NO_INDEX,
						&text_grid[index],
						md_env,
						txt_just[index],
						origin,
						plan_info->win_plan.vec_xpos,
						normal,
						NULL,
						NULL),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
	}

	*msg = OM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method place_weld_cs(
	IGRint *msg;
	struct DMplan_info *plan_info;
	struct GRmd_env *md_env)
{
	IGRint status, rc, i, index, num_points;
	IGRboolean arc_needed1, arc_needed2;
	IGRdouble h_axis[3], norm[3], src_dir[3];
	IGRdouble *base_pt1, *base_pt2, opp_pt[3];
	IGRdouble depth, relief, width, slant, x_factor;
	IGRdouble middle_pt1[3], middle_pt2[3], v_axis[3];
	IGRdouble cs1_pts[30], cs2_pts[30];
	IGRdouble arc_offset1, arc_offset2;
	IGRdouble start_pt[3], end_pt[3], dotp;
	struct GRid go_grid[4];
	BSrc	bs_rc;

	if (!me->cross_section)
	   return(OM_S_SUCCESS);

	arc_needed1 = arc_needed2 = FALSE;
	arc_offset2 = arc_offset1 = 0.0;

	for (i=0; i<4; i++)
	{
		if (i<2) index = DM_LINE_STR;
		else index = DM_ARC;

		status =
		om$send(msg = message DMroot.return_dim_go(
						&rc,
						i+18,
						TRUE,
						index,
						md_env,
						&go_grid[i]),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	for (i=0; i<3; i++)
	{
	    norm[i] = plan_info->win_plan.matrix[i+8];
	    v_axis[i] = me->vector[i];
	    src_dir[i] = me->break_pt[i+3] - me->break_pt[i];
	}

	BSnorvec(&bs_rc, src_dir);
	BSnorvec(&bs_rc, v_axis);

	if (me->cross_section != FILLET_CS)
	{
		/*^ print_point("vector", me->vector); */

		BScrossp(&bs_rc, v_axis, norm, h_axis);

		x_factor = 1.0;

		dotp = BSdotp(&bs_rc, src_dir, h_axis);

		/*^ printf("dotp = %f\n",dotp); */

		if (dotp < 0.0)
		   x_factor = -1.0;

		for (i=0; i<3; i++)
		    opp_pt[i] = me->break_pt[i] + me->vector[i];

		/*^ print_point("opp_pt", opp_pt); */

		if (me->above)
		{
			base_pt1 = opp_pt;
			base_pt2 = me->break_pt;
			math_v_opposite(v_axis, v_axis);
		}
		else
		{
			base_pt1 = me->break_pt;
			base_pt2 = opp_pt;
		}

		depth = BSlenvec(&bs_rc, me->vector);

		if (me->slant <= 0.)
		{
			if (me->dual_mode)
				slant = depth * 0.5;
			else	slant = depth;
		}
		else	slant = me->slant;

		width = fabs(slant / tan(me->angle/2.0)) + (me->relief /2.0);

		if(me->cross_section == VWELD_CS)
		{
			if (me->weld_type1 == WL_CONVEX)
				arc_offset1 = 0.2 * depth;
			else	arc_offset1 = 0.1 * depth;
	
			if (me->dual_mode)
			if (me->weld_type2 == WL_CONVEX)
				arc_offset2 = 0.2 * depth;
			else	arc_offset2 = 0.1 * depth;
		}
		else
		{
			if (me->dual_mode)
			{
				if (me->weld_type1 == WL_CONVEX)
					arc_offset1 = 0.05 * depth;
				else	arc_offset1 = 0.025 * depth;

				if (me->weld_type2 == WL_CONVEX)
					arc_offset2 = 0.05 * depth;
				else	arc_offset2 = 0.025 * depth;
			}
			else
			{
				if (me->weld_type1 == WL_CONVEX)
					arc_offset1 = 0.1 * depth;
				else	arc_offset1 = 0.05 * depth;
			}
		}

		/*^ printf("width = %f, me->relief = %f\n", width, me->relief); */		

		relief = x_factor * me->relief;
		width = x_factor * width;

		if ((me->weld_type1 == WL_CONVEX) || 
		    (me->weld_type1 == WL_CONCAVE))
			arc_needed1 = TRUE;
	
		if ((me->weld_type2 == WL_CONVEX) || 
		    (me->weld_type2 == WL_CONCAVE))
			arc_needed2 = TRUE;
	
		/*^
			printf("x_factor = %f\n", x_factor);
			print_point("v_axis", v_axis);
			print_point("h_axis", h_axis);
			print_point("src_dir", src_dir);
			printf("depth = %f\n",depth);
			printf("width = %f\n",width);
			printf("slant = %f\n",slant);
			printf("relief = %f\n",relief);
			printf("arc_offset1 = %f\n",arc_offset1);
			printf("arc_offset2 = %f\n",arc_offset2);
		*/

		if (arc_needed2)
		{
			if(me->weld_type2 == WL_CONCAVE)
			{
				for (i=0; i<3; i++)
			   	middle_pt2[i] =
				base_pt2[i] - v_axis[i] * arc_offset2;
			}
			else
			{
				for (i=0; i<3; i++)
			  	middle_pt2[i] =
				base_pt2[i] + v_axis[i] * arc_offset2;
			}
		}

		if (arc_needed1)
		{
			if (me->weld_type1 == WL_CONCAVE)
			{
				for (i=0; i<3; i++)
			   	middle_pt1[i] =
				base_pt1[i] + v_axis[i] * arc_offset1;
			}
			else
			{
				for (i=0; i<3; i++)
			   	middle_pt1[i] =
				base_pt1[i] - v_axis[i] * arc_offset1;
			}
		}

		/* construct the linestring */
	
		if (me->cross_section == VWELD_CS)
		{
			/*|------------ v_weld -------------*/
			if (me->dual_mode)
			{
			   for (i=0; i<3; i++)
			   {
				cs1_pts[i]   =
				cs1_pts[i+9] = base_pt1[i] - (h_axis[i] * (width));
				cs1_pts[i+3] = 
				cs1_pts[i+6] = base_pt1[i] - (h_axis[i] * (relief/2));
				cs2_pts[i]   =
				cs2_pts[i+9] = base_pt1[i] + (h_axis[i] * (width));
				cs2_pts[i+3] = 
				cs2_pts[i+6] = base_pt1[i] + (h_axis[i] * (relief/2));
			   }

			   for (i=0; i<3; i++)
			   {
				cs1_pts[i+3] = cs1_pts[i+3] + (v_axis[i] * slant);
				cs1_pts[i+6] = cs1_pts[i+6] + (v_axis[i] * (depth - slant));
				cs1_pts[i+9] = cs1_pts[i+9] + (v_axis[i] * depth);
				cs2_pts[i+3] = cs2_pts[i+3] + (v_axis[i] * (depth - slant));
				cs2_pts[i+6] = cs2_pts[i+6] + (v_axis[i] * slant);
				cs2_pts[i]   = cs2_pts[i]   + (v_axis[i] * depth);
			   }

			   /*^
				for (i=0; i<4; i++)
				{
					printf("i=%d, %f, %f, %f\n", i,
						cs1_pts[3*i],
						cs1_pts[3*i+1],
						cs1_pts[3*i+2]);
					printf("i=%d, %f, %f, %f\n", i,
						cs2_pts[3*i],
						cs2_pts[3*i+1],
						cs2_pts[3*i+2]);
				}
			   */

			   num_points = 4;

			   if (arc_needed2)
			   {
				/*|- Placing CS_ARC2 */

				status =
				DMmake_arc(
					&rc,
					&cs1_pts[9],
					middle_pt2,
					cs2_pts,
					&go_grid[3],
					md_env);
				dm$status(action = RET_STATUS);
			   }
			   else
			   {
				status =
				om$send(msg = message DMroot.delete_dim_go(
								&rc,
								CS_ARC2,
								md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				num_points = 5;
				for (i=0; i<3; i++)
				   cs1_pts[i+12] = cs2_pts[i];
			   }

			   /*|- Placing CS_LINE1 */

			   status =
			   om$send(msg = message DMroot.position_line_string(
							&rc,
							DIM_NO_INDEX,
							&go_grid[0],
							md_env,
							num_points,
							cs1_pts),
					targetid = my_id);
			   dm$status(action = RET_STATUS);
	
			   num_points = 4;

			   if (arc_needed1)
			   {
				/*|- Placing CS_ARC1 */

				/*^print_grid("CSARC1", &go_grid[2]);*/
				status =
				DMmake_arc(
					&rc,
					cs1_pts,
					middle_pt1,
					&cs2_pts[9],
					&go_grid[2],
					md_env);
				dm$status(action = RET_STATUS);
			   }
			   else
			   {
				status =
				om$send(msg = message DMroot.delete_dim_go(
								&rc,
								CS_ARC1,
								md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				num_points = 5;
				for (i=0; i<3; i++)
				   cs2_pts[i+12] = cs1_pts[i];
			   }

			   /*|- Placing CS_LINE1 */

			   status =
			   om$send(msg = message DMroot.position_line_string(
							&rc,
							DIM_NO_INDEX,
							&go_grid[1],
							md_env,
							num_points,
							cs2_pts),
					targetid = my_id);
			   dm$status(action = RET_STATUS);
			}
			else
			{
			   /*|- Single Mode */

			   for (i=0; i<3; i++)
			   {
				cs1_pts[i]    = base_pt1[i] - (h_axis[i] * (width));
				cs1_pts[i+3]  = 
				cs1_pts[i+6]  = base_pt1[i] - (h_axis[i] * (relief/2));
				cs1_pts[i+9]  = 
				cs1_pts[i+12] = base_pt1[i] + (h_axis[i] * (relief/2));
				cs1_pts[i+15] = base_pt1[i] + (h_axis[i] * (width));
			   }

			   for (i=0; i<3; i++)
			   {
				cs1_pts[i+3]  = cs1_pts[i+3] + (v_axis[i] * slant);
				cs1_pts[i+12] = cs1_pts[i+12] + (v_axis[i] * slant);
				cs1_pts[i+6]  = cs1_pts[i+6] + (v_axis[i] * depth);
				cs1_pts[i+9]  = cs1_pts[i+9] + (v_axis[i] * depth);
			   }

			   num_points = 6;

			   if (arc_needed1)
			   {
				status =
				DMmake_arc(
					&rc,
					cs1_pts,
					middle_pt1,
					&cs1_pts[15],
					&go_grid[2],
					md_env);
				dm$status(action = RET_STATUS);
			   }
			   else
			   {
				status =
				om$send(msg = message DMroot.delete_dim_go(
								&rc,
								CS_ARC1,
								md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				num_points = 7;
				
				for (i=0; i<3; i++)
				   cs1_pts[i+18] = cs1_pts[i];
			   }

			   status =
			   om$send(msg = message DMroot.position_line_string(
							&rc,
							DIM_NO_INDEX,
							&go_grid[0],
							md_env,
							num_points,
							cs1_pts),
					targetid = my_id);
			   dm$status(action = RET_STATUS);

			   status =
			   om$send(msg = message DMroot.delete_dim_go(
							&rc,
							CS_ARC2,
							md_env),
				targetid = my_id);
			   dm$status(action = RET_STATUS);

			   status =
			   om$send(msg = message DMroot.delete_dim_go(
			 				&rc,
							CS_LINE2,
							md_env),
				targetid = my_id);
			   dm$status(action = RET_STATUS);
			}
		   }
		   else
		   {
			/*| ------- bevel weld -----------*/

			if (me->dual_mode)
			{
			   for (i=0; i<3; i++)
			   {
				cs1_pts[i]   =
				cs1_pts[i+3] = base_pt1[i] - ( h_axis[i] * (relief/2));
			   }

			   for (i=0; i<3; i++)
				cs1_pts[i+3] = cs1_pts[i+3] + ( v_axis[i] * depth);

			   for (i=0; i<3; i++)
			   {
				cs2_pts[i]   = base_pt1[i] + (h_axis[i] * (width));
				cs2_pts[i+3] =
				cs2_pts[i+6] = base_pt1[i] + (h_axis[i] * (relief/2));
				cs2_pts[i+9] = base_pt1[i] + (h_axis[i] * (width));
			   }

			   for (i=0; i<3; i++)
			   {
				cs2_pts[i]   = cs2_pts[i] + (v_axis[i] * depth);
				cs2_pts[i+3] = cs2_pts[i+3] + (v_axis[i] * (depth - slant));
				cs2_pts[i+6] = cs2_pts[i+6] + (v_axis[i] * slant);
			   }

			   num_points = 2;

			   if (arc_needed2)
			   {
				status =
				DMmake_arc(
					&rc,
					&cs1_pts[3],
					middle_pt2,
					cs2_pts,
					&go_grid[3],
					md_env);
				dm$status(action = RET_STATUS);
			   }
			   else
			   {
				status =
				om$send(msg = message DMroot.delete_dim_go(
			 				&rc,
							CS_ARC2,
							md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				num_points = 3;
				
				for (i=0; i<3; i++)
				   cs1_pts[i+6] = cs2_pts[i];
			   }

			   status =
			   om$send(msg = message DMroot.position_line_string(
							&rc,
							DIM_NO_INDEX,
							&go_grid[0],
							md_env,
							num_points,
							cs1_pts),
					targetid = my_id);
			   dm$status(action = RET_STATUS);

			   num_points = 4;

			   if (arc_needed1)
			   {
				status =
				DMmake_arc(
					&rc,
					cs1_pts,
					middle_pt1,
					&cs2_pts[9],
					&go_grid[2],
					md_env);
				dm$status(action = RET_STATUS);
			   }
			   else
			   {
				status =
				om$send(msg = message DMroot.delete_dim_go(
			 				&rc,
							CS_ARC1,
							md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				num_points = 5;
				
				for (i=0; i<3; i++)
				   cs2_pts[i+12] = cs1_pts[i];
			   }

			   status =
			   om$send(msg = message DMroot.position_line_string(
							&rc,
							DIM_NO_INDEX,
							&go_grid[1],
							md_env,
							num_points,
							cs2_pts),
					targetid = my_id);
			   dm$status(action = RET_STATUS);
			}
			else
			{
			   for (i=0; i<3; i++)
			   {
				cs1_pts[i]    =
				cs1_pts[i+3]  = base_pt1[i] - (h_axis[i] * (relief/2));
				cs1_pts[i+6]  =
				cs1_pts[i+9]  = base_pt1[i] + (h_axis[i] * (relief/2));
				cs1_pts[i+12] = base_pt1[i] + (h_axis[i] * (width));
			   }

			   for (i=0; i<3; i++)
			   {
				cs1_pts[i+3] = cs1_pts[i+3] + (v_axis[i] * depth);
				cs1_pts[i+6] = cs1_pts[i+6] + (v_axis[i] * depth);
				cs1_pts[i+9] = cs1_pts[i+9] + (v_axis[i] * slant);
			   }

			   num_points = 5;

			   if (arc_needed1)
			   {
				status =
				DMmake_arc(
					&rc,
					cs1_pts,
					middle_pt1,
					&cs1_pts[12],
					&go_grid[2],
					md_env);
				dm$status(action = RET_STATUS);
			   }
			   else
			   {
				status =
				om$send(msg = message DMroot.delete_dim_go(
			 				&rc,
							CS_ARC1,
							md_env),
					targetid = my_id);
				dm$status(action = RET_STATUS);

				num_points = 6;
				for (i=0; i<3; i++)
				    cs1_pts[i+15] = cs1_pts[i];
			   }

			   status =
			   om$send(msg = message DMroot.position_line_string(
							&rc,
							DIM_NO_INDEX,
							&go_grid[0],
							md_env,
							num_points,
							cs1_pts),
					targetid = my_id);
			   dm$status(action = RET_STATUS);

			   status =
			   om$send(msg = message DMroot.delete_dim_go(
			 				&rc,
							CS_ARC2,
							md_env),
				targetid = my_id);
			   dm$status(action = RET_STATUS);

			   status =
			   om$send(msg = message DMroot.delete_dim_go(
			 				&rc,
							CS_LINE2,
							md_env),
				targetid = my_id);
			   dm$status(action = RET_STATUS);
			}
		}
	}
	else
	{
		/*|- Place Fillet Weld Cross_section */

		/*^
			print_point("src_dir", src_dir);
			print_point("vec 1", me->vector);
			printf("vec 2 = %f,%f,%f\n",me->vector[3],
				me->vector[4], me->vector[5]);
		*/
		
		if (BSdotp(&bs_rc, me->vector, src_dir) > 0.)
		{
			/*|- Vec1 on same side */

			for (i=0; i<3; i++)
			start_pt[i] = me->break_pt[i] +
					(me->vector[i] * me->slant);
		}
		else
		{
			/*|- Vec1 on opp side */

			for (i=0; i<3; i++)
			start_pt[i] = me->break_pt[i] -
					(me->vector[i] * me->slant);
		}

		if (BSdotp(&bs_rc, &me->vector[3], src_dir) > 0.)
		{
			/*|- Vec2 on same side */

			for (i=0; i<3; i++)
			end_pt[i] = me->break_pt[i] +
					(me->vector[i+3] * me->slant);
		}
		else
		{
			/*|- Vec2 on opp side */

			for (i=0; i<3; i++)
			end_pt[i] = me->break_pt[i] -
					(me->vector[i+3] * me->slant);
		}

		arc_needed1 = FALSE;

		for (i=0; i<3; i++)
		{
			cs1_pts[i] = start_pt[i];
			cs1_pts[i+3] = me->break_pt[i];
			cs1_pts[i+6] = end_pt[i];
			opp_pt[i] = (start_pt[i] + end_pt[i])*0.5;
		}

		for (i=0; i<3; i++)
		    src_dir[i] = opp_pt[i] - me->break_pt[i];
		BSnorvec(&bs_rc, src_dir);

		if ((me->weld_type1 == WL_CONVEX)
		||  (me->weld_type1 == WL_CONCAVE))
		{
			arc_needed1 = TRUE;

			if (me->weld_type1 == WL_CONVEX)
			{
				arc_offset1 = 0.2 * me->slant;
				for (i=0; i<3; i++)
				    middle_pt1[i] = opp_pt[i] +
					(src_dir[i] * arc_offset1);
			}
			else
			{
				arc_offset1 = 0.1 * me->slant;
				for (i=0; i<3; i++)
				    middle_pt1[i] = opp_pt[i] -
					(src_dir[i] * arc_offset1);
			}
		}

		num_points = 3;

		if (arc_needed1)
		{
			status =
			DMmake_arc(
				&rc,
				start_pt,
				middle_pt1,
				end_pt,
				&go_grid[2],
				md_env);
			dm$status(action = RET_STATUS);
		}
		else
		{
			status =
			om$send(msg = message DMroot.delete_dim_go(
			 				&rc,
							CS_ARC1,
							md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);

			for (i=0; i<3; i++)
			    cs1_pts[i+9] = start_pt[i];

			num_points = 4;
		}

		status =
		om$send(msg = message DMroot.position_line_string(
						&rc,
						DIM_NO_INDEX,
						&go_grid[0],
						md_env,
						num_points,
						cs1_pts),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMroot.delete_dim_go(
		 				&rc,
						CS_ARC2,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMroot.delete_dim_go(
		 				&rc,
						CS_LINE2,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}	

method set_cross_section(
	IGRint cross_section;
	IGRdouble weld_size;
	IGRdouble *vector)
{
	IGRint status, i;
	struct DMweld_param par_weld;

	dm$get_dim_param(type = DM_WELD_PARAM, 
		p_data = &par_weld);
	me->cross_section = cross_section;

	if (!me->cross_section)
	{
		status =
		om$vla_set_dimension(varray = me->vector, size = 0);
		dm$status(action = RET_STATUS);
	}
	else if (me->cross_section == FILLET_CS)
	{
		me->slant = weld_size;

		status =
		om$vla_set_dimension(varray = me->vector, size = 6);
		dm$status(action = RET_STATUS);

		for (i=0; i<6; i++)
		    me->vector[i] = vector[i];

		if (par_weld.above)
			me->weld_type1 = par_weld.atext.weld_type;

		if (par_weld.below)
		{
			if (par_weld.above)
			   me->weld_type2 = par_weld.btext.weld_type;
			else me->weld_type1 = par_weld.btext.weld_type;
		}
	}
	else
	{
		status =
		om$vla_set_dimension(varray = me->vector, size = 3);
		dm$status(action = RET_STATUS);

		for (i=0; i<3; i++)
		    me->vector[i] = vector[i];

		me->slant = 0.;
		me->angle = 90;
		me->relief = 0.;

		if (par_weld.above)
		{
			if (atof(par_weld.atext.ftext) > 0.)
			me->slant = atof(par_weld.atext.ftext);
			if (atof(par_weld.atext.text1) > 0.)
			me->relief = atof(par_weld.atext.text1);
			if (atof(par_weld.atext.text2) > 0.)
			me->angle = atof(par_weld.atext.text2);
			me->weld_type1 = par_weld.atext.weld_type;
		}

		if (par_weld.below)
		{
			if ((atof(par_weld.btext.ftext) > 0.)
			&&  (!par_weld.above))
			me->slant = atof(par_weld.btext.ftext);
			if ((atof(par_weld.btext.text1) > 0.)
			&&  (!par_weld.above))
			me->relief = atof(par_weld.btext.text1);
			if ((atof(par_weld.btext.text2) > 0.)
			&&  (!par_weld.above))
			me->angle = atof(par_weld.btext.text2);
			if (par_weld.above)
				me->weld_type2 = par_weld.btext.weld_type;
			else	me->weld_type1 = par_weld.btext.weld_type;
		}
	}

	return(OM_S_SUCCESS);
}

DMmake_arc (msg,start_pt,middle_pt,end_pt,arc_grid,md_env)
	 IGRint  *msg;
	 IGRdouble  start_pt[3];
	 IGRdouble  middle_pt[3];
	 IGRdouble  end_pt[3];
	 struct GRid  *arc_grid;
	 struct GRmd_env  *md_env;
/*.DMmake_arc*/
{
	IGRint status;
	IGRlong long_rc;
	IGRdouble poles[21],weights[7],knots[10];
	struct IGRbsp_curve *bsp_curve;
	struct GRpost_info post_info;

	/*"DMmake arc: arc_grid = %d, %d\n",arc_grid->objid, arc_grid->osnum*/

        status =
	om$send(msg = message GRvg.GRgenabsg(
                       		        &long_rc,
					&md_env->md_env.matrix_type,
                		        md_env->md_env.matrix,
                                	(char **)&bsp_curve),
		senderid = NULL_OBJID,
		targetid = arc_grid->objid,
        	targetos = arc_grid->osnum);
	dm$status( action = RET_STATUS);

	/*  we need to allocate memory for 7 poles, 7 knots
	    and 7 weights to take care of all cases */

	bsp_curve->poles = poles;
	bsp_curve->weights = weights;
	bsp_curve->knots = knots;

	/*^
		print_point("start_pt", start_pt);
		print_point("middle_pt", middle_pt);
		print_point("end_pt", end_pt);
	*/

	status =
	BSarc3pts(
		&long_rc,
		start_pt,
		middle_pt,
		end_pt,
		bsp_curve);
	dm$status(action = RET_STATUS);

	post_info.construct_flag = FALSE;

	status =
        om$send(msg = message GRvg.GRpostabsg(
					&long_rc,
	                                md_env,
                		        &post_info,
                        		(char *)bsp_curve,
                                	&arc_grid->objid),
		senderid = NULL_OBJID,
                targetid = arc_grid->objid,
	        targetos = arc_grid->osnum);
	dm$status( action = RET_STATUS);

	return(TRUE);
}
	
DMmake_weld_symbol (above,osnum,par_weld,par_senv,text_string,text_length)
	 IGRboolean  above;
	 IGRshort  osnum;
	 struct DMweld_param  *par_weld;
	 struct DMsenv_param  *par_senv;
	 IGRchar  *text_string;
	 IGRshort  *text_length;
/*.DMmake_weld_symbol*/
{
	IGRint status;
	IGRchar weld_char, *text1, *text2, *text3;
	IGRchar loc_string[512], *dummy;
	IGRshort loc_len, text1_len, text2_len, text3_len;

	loc_len = *text_length = 0;

	if (above)
	{
		/*|- Above text string */

		text1 = par_weld->atext.text1;
		text2 = par_weld->atext.text2;
		text3 = par_weld->atext.text3;

		text1_len = strlen(text1);
		text2_len = strlen(text2);
		text3_len = strlen(text3);

		/*^
			printf("text1 = %s\n",text1);
			printf("text2 = %s\n",text2);
			printf("text3 = %s\n",text3);
		*/

		if ((text1_len < 1)
		&&  (text2_len < 1)
		&&  (text3_len < 1))
		{
			return(TRUE);
		}

		if (text3_len > 0)
		{
			dummy = &text_string[*text_length];
			start_field(dummy, 1, 0, (*text_length));
			memcpy(dummy, text3, text3_len);
			*text_length += text3_len;
			dummy = &text_string[*text_length];
			end_field(dummy, (*text_length));
		}

		if (par_weld->atext.weld_type != WL_BLANK)
		{
			/*"above weld type = %d\n", par_weld->atext.weld_type*/

			if (*text_length > 0)
			DMadd_line_feed(text_string, text_length);
			dummy = &text_string[*text_length];
			start_field(dummy, 2, 0, (*text_length));

			if (par_weld->atext.weld_type == WL_FLUSH)
				weld_char = 91;
			else if (par_weld->atext.weld_type == WL_CONVEX)
				weld_char = 92;
			else	weld_char = 93;

			status =
			DMadd_weld_symbol(
				osnum,
				par_senv->text_font,
				weld_char,
				text_string,
				text_length);
			dm$status(action = RET_STATUS);

			dummy = &text_string[*text_length];
			end_field(dummy, (*text_length));
		}

		if (text2_len > 0)
		{
			if (*text_length > 0)
			DMadd_line_feed(text_string, text_length);

			dummy = &text_string[*text_length];
			start_field(dummy, 3, 0, (*text_length));
			memcpy(dummy, text2, text2_len);			
			*text_length += text2_len;
			dummy = &text_string[*text_length];
			end_field(dummy, (*text_length));
		}

		if (text1_len > 0)
		{
			if (*text_length > 0)
			DMadd_line_feed(text_string, text_length);

			dummy = &text_string[*text_length];
			start_field(dummy, 4, 0, (*text_length));
			memcpy(dummy, text1, text1_len);
			*text_length += text1_len;
			dummy = &text_string[*text_length];
			end_field(dummy, (*text_length));
		}
	}
	else
	{
		/*|- Below text string */

		text1 = par_weld->btext.text1;
		text2 = par_weld->btext.text2;
		text3 = par_weld->btext.text3;

		/*^
			printf("text1 = %s\n",text1);
			printf("text2 = %s\n",text2);
			printf("text3 = %s\n",text3);
		*/

		text1_len = strlen(text1);
		text2_len = strlen(text2);
		text3_len = strlen(text3);;

		if ((text1_len < 1)
		&&  (text2_len < 1)
		&&  (text3_len < 1))
		{
			return(TRUE);
		}

		if (text1_len > 0)
		{
			dummy = &loc_string[loc_len];
			start_field(dummy, 1, 0, loc_len);
			memcpy(dummy, text1, text1_len);
			loc_len += text1_len;
			dummy = &loc_string[loc_len];
			end_field(dummy, loc_len);
		}

		if (text2_len > 0)
		{
			if (loc_len > 0)
			DMadd_line_feed(loc_string, &loc_len);
			
			dummy = &loc_string[loc_len];
			start_field(dummy, 2, 0, loc_len);
			memcpy(&loc_string[loc_len], text2, text2_len);
			loc_len += text2_len;
			dummy = &loc_string[loc_len];
			end_field(dummy, loc_len);
		}

		if (par_weld->btext.weld_type != WL_BLANK)
		{
			/*"below weld type = %d\n", par_weld->btext.weld_type*/

			if (loc_len > 0)
			DMadd_line_feed(loc_string, &loc_len);

			dummy = &loc_string[loc_len];
			start_field(dummy, 3, 0, loc_len);
			
			if (par_weld->btext.weld_type == WL_FLUSH)
				weld_char = 91;
			else if (par_weld->btext.weld_type == WL_CONVEX)
				weld_char = 93;
			else	weld_char = 92;

			status =
			DMadd_weld_symbol(
				osnum,
				par_senv->text_font,
				weld_char,
				loc_string,
				&loc_len);
			dm$status(action = RET_STATUS);

			dummy = &loc_string[loc_len];
			end_field(dummy, loc_len);
		}

		if (text3_len > 0)
		{
			if (loc_len > 0)
			DMadd_line_feed(loc_string, &loc_len);

			dummy = &loc_string[loc_len];
			start_field(dummy, 4, 0, loc_len);
			memcpy(&loc_string[loc_len], text3, text3_len);
			loc_len += text3_len;
			dummy = &loc_string[loc_len];
			end_field(dummy, loc_len);
		}

		if (loc_len > 0)
		{
			memcpy(&text_string[*text_length], loc_string, loc_len);
			*text_length = loc_len;
		}
	}

	/*^
		printf("txt_length = %d\n",*text_length);
		analyse_string(text_string, *text_length);
	*/

	return(TRUE);
}

DMadd_weld_symbol (osnum,text_font,weld_char,string,length)
	 short  osnum;
	 short  text_font;
	 char  weld_char;
	 char  *string;
	 short  *length;
/*.DMadd_weld_symbol*/
{
	IGRint rc;
	short font_num;
	unsigned char *text_ptr;

	/*^
		printf("weld_char = %c\n", weld_char);
		printf("length = %d\n", *length);
	*/

	DMretrieve_font(&rc, osnum, "99", &font_num);
	if (rc != DIM_S_SUCCESS)
	{
		printf("Error retrieving font\n");
		return(FALSE);
	}

	text_ptr =(unsigned char *)&string[*length];
	change_font(text_ptr, font_num, *length);
	*text_ptr++ = weld_char;
	(*length)++;
	change_font(text_ptr,text_font,*length);

	/*^
		printf("txt_length = %d\n",*length);
		analyse_string(string, *length);
	*/

	return(TRUE);
}

DMappend_space (text_string,type,len,space)
	 char  *text_string;
	 int  type;
	 short  *len;
	 double  space;
/*.DMappend_space*/
{
	char string[10];
	double one;
	char loc_string[120];

	string[0] = 27;
	string[1] = 'h';
	one = space;

	memcpy(&string[2],&one,8);

	if(type == AN_AFTER)
		memcpy(&text_string[*len],string,10);
	else
	{
		memcpy( loc_string,text_string,*len);
		memcpy( text_string,string,10);
		memcpy( &text_string[10],loc_string,*len);
	}

	*len += 10;

	return(TRUE);
}

DMget_weld_symbol_char (symbol,weld_type,weld_char)
	 IGRint  symbol;
	 IGRint  weld_type;
	 IGRchar  *weld_char;
/*.DMget_weld_symbol_char*/
{
	/*"weld_symbol = %d, weld_type = %d",symbol,weld_type*/

	switch(symbol)
	{
		case GAD_SYMBOL1_BZ:
		if (weld_type == WL_FLUSH)
			*weld_char = 112;
		else if (weld_type == WL_CONVEX)
			*weld_char = 67;
		else if (weld_type == WL_CONCAVE)
			*weld_char = 80;
		else	*weld_char = 99;
		break;

		case GAD_SYMBOL2_BZ:
		if (weld_type == WL_FLUSH)
			*weld_char = 113;
		else if (weld_type == WL_CONVEX)
			*weld_char = 68;
		else if (weld_type == WL_CONCAVE)
			*weld_char = 81;
		else	*weld_char = 100;
		break;

		case GAD_SYMBOL3_BZ:
		if (weld_type == WL_FLUSH)
			*weld_char = 116;
		else if (weld_type == WL_CONVEX)
			*weld_char = 71;
		else if (weld_type == WL_CONCAVE)
			*weld_char = 84;
		else	*weld_char = 103;
		break;

		case GAD_SYMBOL4_BZ:
		if (weld_type == WL_FLUSH)
			*weld_char = 117;
		else if (weld_type == WL_CONVEX)
			*weld_char = 72;
		else if (weld_type == WL_CONCAVE)
			*weld_char = 85;
		else	*weld_char = 104;
		break;

		case GAD_SYMBOL5_BZ:
		if (weld_type == WL_FLUSH)
			*weld_char = 114;
		else if (weld_type == WL_CONVEX)
			*weld_char = 69;
		else if (weld_type == WL_CONCAVE)
			*weld_char = 82;
		else	*weld_char = 101;
		break;

		case GAD_SYMBOL6_BZ:
		if (weld_type == WL_FLUSH)
			*weld_char = 115;
		else if (weld_type == WL_CONVEX)
			*weld_char = 70;
		else if (weld_type == WL_CONCAVE)
			*weld_char = 83;
		else	*weld_char = 102;
		break;

		case GAD_SYMBOL7_BZ:
		if (weld_type == WL_FLUSH)
			*weld_char = 34;
		else if (weld_type == WL_CONVEX)
			*weld_char = 35;
		else if (weld_type == WL_CONCAVE)
			*weld_char = 36;
		else	*weld_char = 33;
		break;

		case GAD_SYMBOL8_BZ:
		if (weld_type == WL_FLUSH)
			*weld_char = 38;
		else if (weld_type == WL_CONVEX)
			*weld_char = 40;
		else if (weld_type == WL_CONCAVE)
			*weld_char = 39;
		else	*weld_char = 37;
		break;

		case GAD_SYMBOL9_BZ:
		if (weld_type == WL_FLUSH)
			*weld_char = 111;
		else if (weld_type == WL_CONVEX)
			*weld_char = 66;
		else if (weld_type == WL_CONCAVE)
			*weld_char = 79;
		else	*weld_char = 98;
		break;

		case GAD_SYMBOL10_BZ:
		if (weld_type == WL_FLUSH)
			*weld_char = 118;
		else if (weld_type == WL_CONVEX)
			*weld_char = 73;
		else if (weld_type == WL_CONCAVE)
			*weld_char = 86;
		else	*weld_char = 105;
		break;

		case GAD_SYMBOL11_BZ:
		if (weld_type == WL_FLUSH)
			*weld_char = 46;
		else if (weld_type == WL_CONVEX)
			*weld_char = 48;
		else if (weld_type == WL_CONCAVE)
			*weld_char = 47;
		else	*weld_char = 45;
		break;

		case GAD_SYMBOL12_BZ:
		if (weld_type == WL_FLUSH)
			*weld_char = 42;
		else if (weld_type == WL_CONVEX)
			*weld_char = 43;
		else if (weld_type == WL_CONCAVE)
			*weld_char = 44;
		else	*weld_char = 41;
		break;

		case GAD_SYMBOL13_BZ:
		if (weld_type == WL_FLUSH)
			*weld_char = 119;
		else if (weld_type == WL_CONVEX)
			*weld_char = 74;
		else if (weld_type == WL_CONCAVE)
			*weld_char = 87;
		else	*weld_char = 106;
		break;

		case GAD_SYMBOL14_BZ:
		if (weld_type == WL_FLUSH)
			*weld_char = 120;
		else if (weld_type == WL_CONVEX)
			*weld_char = 75;
		else if (weld_type == WL_CONCAVE)
			*weld_char = 88;
		else	*weld_char = 107;
		break;

		case GAD_SYMBOL15_BZ:
		if (weld_type == WL_FLUSH)
			*weld_char = 110;
		else if (weld_type == WL_CONVEX)
			*weld_char = 65;
		else if (weld_type == WL_CONCAVE)
			*weld_char = 78;
		else	*weld_char = 97;
		break;

		case GAD_SYMBOL16_BZ:
		if (weld_type == WL_FLUSH)
			*weld_char = 110;
		else if (weld_type == WL_CONVEX)
			*weld_char = 65;
		else if (weld_type == WL_CONCAVE)
			*weld_char = 78;
		else	*weld_char = 97;
		break;

		case GAD_SYMBOL17_BZ:
		if (weld_type == WL_FLUSH)
			*weld_char = 121;
		else if (weld_type == WL_CONVEX)
			*weld_char = 76;
		else if (weld_type == WL_CONCAVE)
			*weld_char = 89;
		else	*weld_char = 108;
		break;

		case GAD_SYMBOL18_BZ:
		if (weld_type == WL_FLUSH)
			*weld_char = 122;
		else if (weld_type == WL_CONVEX)
			*weld_char = 77;
		else if (weld_type == WL_CONCAVE)
			*weld_char = 90;
		else	*weld_char = 109;
		break;

		default:
		/*"get_weld_symbol_char: Invalid symbol = %d\n", symbol*/
		return(TRUE);
	}

	/*"weld_char = %d", *weld_char*/

	return(TRUE);
}

method get_weld_text(
	IGRint *msg;
	struct DMweld_param *par_weld;
	struct GRmd_env *md_env)
{
	IGRint status;
	struct GRid go_grid[24];

	/*|- Update all the global struct from instance and txt value*/

	par_weld->above = me->above;
	par_weld->below = me->below;
	par_weld->center = me->center;
	par_weld->flag = me->flag;
	par_weld->circle = me->circle;
	par_weld->dash_line = me->leader;
	par_weld->z_symb = me->tol_symbol;
	par_weld->tail = me->tail;
	par_weld->ansi_weld = me->ansi_weld;
	par_weld->cross_section = me->cross_section;

	if (me->cross_section)
	   par_weld->proj_method = TRUE;

	status =
	om$send(msg = message DMweld.get_components(
					FALSE,
					go_grid,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*|- Initialise the text string to NULL*/

	par_weld->tailtext[0] = '\0';
	par_weld->atext.ftext[0] = '\0';
	par_weld->atext.rtext[0] = '\0';
	par_weld->atext.ztext[0] = '\0';
	par_weld->atext.text1[0] = '\0';
	par_weld->atext.text2[0] = '\0';
	par_weld->atext.text3[0] = '\0';
	par_weld->btext.ftext[0] = '\0';
	par_weld->btext.rtext[0] = '\0';
	par_weld->btext.ztext[0] = '\0';
	par_weld->btext.text1[0] = '\0';
	par_weld->btext.text2[0] = '\0';
	par_weld->btext.text3[0] = '\0';

	if (me->above)
	{
		/*|- Above option is founr*/

		par_weld->atext.weld_symbol = me->weld_symb1;
		par_weld->atext.weld_type = me->weld_type1;

		if (go_grid[AFTEXT].objid != NULL_OBJID)
			DMextract_text(
				TRUE,
				FALSE,
				par_weld->atext.ftext,
				par_weld,
				go_grid[AFTEXT]);

		if (go_grid[ARTEXT].objid != NULL_OBJID)
			DMextract_text(
				TRUE,
				FALSE,
				par_weld->atext.rtext,
				par_weld,
				go_grid[ARTEXT]);


		if (go_grid[AZTEXT].objid != NULL_OBJID)
			DMextract_text(
				TRUE,
				FALSE,
				par_weld->atext.ztext,
				par_weld,
				go_grid[AZTEXT]);

		if (go_grid[AATEXT].objid != NULL_OBJID)
			DMextract_text(
				TRUE,
				TRUE,
				par_weld->atext.text1,
				par_weld,
				go_grid[AATEXT]);
	}

	if (me->below)
	{
		/*|- Below option is found*/

		if (me->dual_mode)
		{
			par_weld->btext.weld_symbol = me->weld_symb2;
			par_weld->btext.weld_type = me->weld_type2;
		}
		else
		{
			par_weld->btext.weld_symbol = me->weld_symb1;
			par_weld->btext.weld_type = me->weld_type1;
		}

		if (go_grid[BFTEXT].objid != NULL_OBJID)
			DMextract_text(
				FALSE,
				FALSE,
				par_weld->btext.ftext,
				par_weld,
				go_grid[BFTEXT]);

		if (go_grid[BRTEXT].objid != NULL_OBJID)
			DMextract_text(
				FALSE,
				FALSE,
				par_weld->btext.rtext,
				par_weld,
				go_grid[BRTEXT]);


		if (go_grid[BZTEXT].objid != NULL_OBJID)
			DMextract_text(
				FALSE,
				FALSE,
				par_weld->btext.ztext,
				par_weld,
				go_grid[BZTEXT]);

		if (go_grid[BATEXT].objid != NULL_OBJID)
			DMextract_text(
				FALSE,
				TRUE,
				par_weld->btext.text1,
				par_weld,
				go_grid[BATEXT]);
	}

	if (me->tail)
	   DMextract_text(
		FALSE,
		FALSE,
		par_weld->tailtext,
		par_weld,
		go_grid[TLTEXT]);

	if (me->center)
	   {
           par_weld->cen_symb = me->weld_symb1;
           if (go_grid[AFTEXT].objid != NULL_OBJID)
                        DMextract_text(
                                TRUE,
                                FALSE,
                                par_weld->atext.ftext,
                                par_weld,
                                go_grid[AFTEXT]);
 
                if (go_grid[ARTEXT].objid != NULL_OBJID)
                        DMextract_text(
                                TRUE,
                                FALSE,
                                par_weld->atext.rtext,
                                par_weld,
                                go_grid[ARTEXT]);
                if (go_grid[BFTEXT].objid != NULL_OBJID)
                        DMextract_text(
                                FALSE,
                                FALSE,
                                par_weld->btext.ftext,
                                par_weld,
                                go_grid[BFTEXT]);
 
                if (go_grid[BRTEXT].objid != NULL_OBJID)
                        DMextract_text(
                                FALSE,
                                FALSE,
                                par_weld->btext.rtext,
                                par_weld,
                                go_grid[BRTEXT]);
} 

	return(OM_S_SUCCESS);
}

IGRint DMextract_text (above,mul_text,text_string,par_weld,text_grid)
	 IGRboolean  above;
	 IGRboolean  mul_text;
	 IGRchar  *text_string;
	 struct DMweld_param  *par_weld;
	 struct GRid  text_grid;
/*.DMextract_text*/
{
	IGRint status;
	unsigned char *string = NULL;
	unsigned char *str[4];
	unsigned char str1[132], str2[132], str3[132], str4[132];
	short length, len[4], num_str;
	long long_rc;

	str[0] = str1;
	str[1] = str2;
	str[2] = str3;
	str[3] = str4;

	len[0] = len[1] = len[2] = len[3] = 0;

	/*^
		printf("text_grid = %d,%d\n", text_grid.objid, text_grid.osnum);
		printf("above = %d, mul_text = %d\n", above, mul_text);
	*/

	status =
	om$send(msg = message GRtext.GRgettxattr(
					&long_rc,
					NULL,
					&length,
					&string),
		senderid = NULL_OBJID,
		targetid = text_grid.objid,
		targetos = text_grid.osnum);
	dm$status(action = RET_STATUS);

	/*|- Remove Escape Chars*/

	status =
	DMret_disp_char(
		string,
		length,
		&num_str,
		str,
		len);

	/*^ printf("num_str = %d\n", num_str); */
		
	if (mul_text)
	{
		/*|- Mul text */

		if (above)
		{
			if (len[0] > 0)
			memcpy(par_weld->atext.text3, str1, len[0]);
			if (len[2] > 0)
			memcpy(par_weld->atext.text2, str3, len[2]);
			if (len[3] > 0)
			memcpy(par_weld->atext.text1, str4, len[3]);
		}
		else
		{
			if (len[0] > 0)
			memcpy(par_weld->btext.text1, str1, len[0]);
			if (len[1] > 0)
			memcpy(par_weld->btext.text2, str2, len[1]);
			if (len[3] > 0)
			memcpy(par_weld->btext.text3, str4, len[3]);
		}
	}
	else	memcpy(text_string, str1, len[0]);

	if (string) free(string);

	/*^
		printf("length: %d\n",length);
		analyse_string(string, length);
	*/

	return(TRUE);
}
end implementation DMweld;
