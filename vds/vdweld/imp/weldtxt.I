/* $Id: weldtxt.I,v 1.1.1.1 2001/01/04 21:09:33 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdweld/imp/weldtxt.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: weldtxt.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/12/09  16:17:14  pinnacle
# Replaced: vdweld/imp/weldtxt.I for:  by impd for vds
#
# Revision 1.1  1997/11/21  17:12:10  pinnacle
# Created: vdweld/imp/weldtxt.I by impd for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	11/21/97	  HF		Replacement at VDS level of method DMweld.make_weld_text
 *					Cooperates with file $VDS/config/weld_symbols in order
 *					to make placement of Welding Symbols user customizable
 * -------------------------------------------------------------------*/

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
#include "VDweldsym.h"

#define	VD_DEBUG
#include	<VDdebug.h>

from GRtext import GRreplace_text, GRgettxattr;

extern double tan();
extern double atof();
extern double fabs();

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*      ********************	GLOBAL VARIABLES  *****************************	*/
/* 	Defined in   :								*/
/*		vdweld/imp/weldsym.I						*/
/* 	Used also in :								*/
/*		vdweld/imp/weldtxt.I						*/
/*		vdweld/cmd/VDweldcmd.I						*/
/*		vdweld/cmd/weldform.I						*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

extern int				VDS_is_active_environment;

/* CURRENTLY NOT USED
extern int				weld_sym_initialized;
extern struct VDweld_gadget_sym		sym_char [MAX_WLD_SYM_SZ];
*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

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
    
  __enterMethod ( name = "make_weld_text", argfmt = "VDS_is_active_environment = %d", args = `VDS_is_active_environment` );

	dm$get_dim_param(type = DM_WELD_PARAM, p_data = &par_weld);

	f_str_len     =
	r_str_len     =
	i_str_len     = 0;

	if ((me->dim_state & DIM_IN_PLACEMENT)
	||  (me->dim_state & DIM_TEXT_NEEDS_UPDATE)) 

	{
		/*|- Update all the instance and txt value from global struct */

		me->above      = par_weld.above;
		me->below      = par_weld.below;
		me->center     = par_weld.center;
		me->flag       = par_weld.flag;
		me->circle     = par_weld.circle;
		if ( VDS_is_active_environment )
		{
		  me->leader   = 0;			// Never use dash_line ?!?!??
		}
		else
		{
		  me->leader   = par_weld.dash_line;
		}
		me->tol_symbol = par_weld.z_symb;
		me->tail       = par_weld.tail;
		me->ansi_weld  = par_weld.ansi_weld;

		if (me->above && me->below)
			me->dual_mode = TRUE;

		me->front_len = me->rear_len = me->inter_len = 0;

		__printf("above = %d, below = %d, center = %d", `par_weld.above,par_weld.below,par_weld.center` );
		__printf("tail  = %d, flag  = %d, circle = %d", `par_weld.tail,par_weld.flag,par_weld.circle` );
		__printf("atext.f = <%s>", `par_weld.atext.ftext` );
		__printf("atext.r = <%s>", `par_weld.atext.rtext` );
		__printf("atext.z = <%s>", `par_weld.atext.ztext` );
		__printf("btext.f = <%s>", `par_weld.btext.ftext` );
		__printf("btext.r = <%s>", `par_weld.btext.rtext` );
		__printf("btext.z = <%s>", `par_weld.btext.ztext` );
		__printf("aweld_symb = %d", `par_weld.atext.weld_symbol` );
		__printf("aweld_type = %d", `par_weld.atext.weld_type` );
		__printf("bweld_symb = %d", `par_weld.btext.weld_symbol` );
		__printf("bweld_type = %d", `par_weld.btext.weld_type` );
		__printf("cen_symb   = %d", `par_weld.cen_symb` );
		__printf("dash_line  = %d", `par_weld.dash_line` );

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
			if (me->ansi_weld)
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
	
					if ( VDS_is_active_environment )
					{
					  status =
					    VDget_weld_symbol_char(
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
						WL_BLANK,
						&weld_char);
					  dm$status(action = RET_STATUS);
					}
				}
				else
				{
					if ( VDS_is_active_environment )
					{
					  status =
					    VDget_weld_symbol_char(
						me->weld_symb1,
						me->weld_type1,
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
					}

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
			  if ( VDS_is_active_environment )
			  {
			    status =
			      VDget_weld_symbol_char(
					me->weld_symb1,
					me->weld_type1,
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
			  }

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
	
					if ( VDS_is_active_environment )
					{
					  status =
					    VDget_weld_symbol_char(
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
						WL_BLANK,
						&weld_char);
					  dm$status(action = RET_STATUS);
					}
				}
				else
				{
					if ( VDS_is_active_environment )
					{
					  status =
					    VDget_weld_symbol_char(
						par_weld.btext.weld_symbol,
						par_weld.btext.weld_type,
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
					}

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
			  if ( VDS_is_active_environment )
			  {
			    status =
			      VDget_weld_symbol_char(
					par_weld.btext.weld_symbol,
					par_weld.btext.weld_type,
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
			  }

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
    
  __exitMethod ( name = "make_weld_text" );

	*msg = OM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

end implementation DMweld;
