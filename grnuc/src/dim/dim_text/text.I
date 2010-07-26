/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:31 $
$Locker:  $
$Log: text.I,v $
Revision 1.1.1.1  2001/12/17 22:39:31  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:09:31  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:23:36  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:53:01  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.2  1993/06/04  19:41:27  jack
# COMMENT : Purify fixes(memory leaks and uninitialized memory reads)
#
# Revision 240.1  1992/12/31  15:14:32  mike
# COMMENT : TR119222870 - remove fi.h dependencies, use exfi.h definitions instead
#
# Revision 240.0  1992/12/06  23:48:11  tim
# COMMENT : Initial checkin to 2.4 RCS
#
# Revision 220.0  1992/08/29  06:26:52  root
# COMMENT : Corresponds to Rel201.18 in 2.0.1 RCS
#
Revision 201.18  1992/07/20  05:45:17  gvk
COMMENT : ANSI compilation, global modification of DMglobal to DM_global.

Revision 201.17  1992/07/02  11:17:09  allen
COMMENT : Added "#define DM_global DMglobal" because DMglobal has not been changed, well, globally.

Revision 201.16  1992/06/30  15:40:24  grnuc20
COMMENT : Commented out prototype include file.

Revision 201.15  1992/06/30  06:23:48  laxmi
COMMENT : Source code changed to comply with ANSI compilation.

Revision 201.13  1992/03/07  18:52:38  mike
COMMENT : Passing shorts instead of ints to text methods and functions.

Revision 201.12  1992/02/24  13:40:56  dimdp20
COMMENT : Bug in dm macro fixed for tol symbol dimension.

Revision 201.11  1992/01/20  07:58:37  dimdp20
COMMENT : Dimension Fixes Release - S. Poovannan - Jan 20 1992

*/

class implementation DMtext;

#define AS_DEBUG 1

#include "exfi.h"
#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"
#include "dimglobal.h"

#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "gotextdef.h"
#include "gotext.h"
#include "OMmacros.h"
#include "OMprimitives.h"
/* #include "DMtextp.h" Not ready for prototypes */

extern struct DMglobal DM_global;
extern struct DMglobal_param frm_glob;
extern double fabs();

method make_text_string(
	IGRdouble 		dimn_val;
	IGRint 			meas_type;
	struct DMloc_param	*loc_param;
	struct DMenv_param	*env_param;
	struct DMmisc_param	*misc_param;
	struct GRmd_env		*md_env)
{
	IGRint status;
	IGRlong long_rc;
	struct DMtxt_str	dim_text;
	IGRuchar	buffer[1024];
	char dim_override[EXFI_STRLEN];
	struct DMsymbol_info   *symbol_struct;
	struct DMstd_param	*std_param;
	struct GRdpb_text_symb text_symb;
	struct IGRdisplay display;
	OM_S_OBJID md_id_save;
	IGRuint attr_number;
	char format[10];
	IGRchar tole_mode,dual_mode,para_mode = 0; /* Initialized, fix umr (Purify.) */
	IGRboolean parens_on, suffix_on, subfix_on;
        IGRshort text_length;
	IGRint move_flag;
	double pri_cnv_factor,sec_cnv_factor,over_val;

	dim_text.length = 0;
	dim_text.str = buffer;
	symbol_struct = NULL;
	memcpy(dim_override, misc_param->dim_override, EXFI_STRLEN);
	std_param = &misc_param->std_param;

	/*|modify the dimension value depending on the dimension type */
	/*"dim type:%d\n",meas_type*/
	/*"dimn val:%lf\n",dimn_val*/

	if( meas_type == SYMMETRICAL_DIAMETER )
		dimn_val = 2 * dimn_val;

	if (misc_param->prefix_disp)
	DMpreproc_presuf(TRUE, misc_param->prefix);

	if (misc_param->suffix_disp)
	DMpreproc_presuf(TRUE, misc_param->suffix);

	if (!strlen(misc_param->dim_override)&&
	    meas_type != STACKED_ANGULAR   &&
	    meas_type != STRINGED_ANGULAR  &&
	    meas_type != SINGLE_ARC_ANGLE)
	{
		/*| scale the dimension value */
		dimn_val = dimn_val/ env_param->sca_fact;
	}

	/*| Intialise dim text attributes */

	text_symb.Active_font    = env_param->text_font;
	text_symb.Active_just    = -1;
	text_symb.Active_width   = env_param->txt_widt;
	text_symb.Active_height  = env_param->txt_heig;
	text_symb.Active_charspac= std_param->dm_car_spac;
	text_symb.Active_linespac= std_param->dm_lin_spac;

	tole_mode = loc_param->tole_mode;
	dual_mode = env_param->dual_mode;

	if ((tole_mode == TOLE_MODE_OFF
	||   tole_mode == TOLE_MODE_BOX)
	&&  (dual_mode == DUAL_MODE_OFF))
	{
		/*|make alter text string*/
		if( meas_type != STACKED_ANGULAR   &&
		    meas_type != STRINGED_ANGULAR  &&
		    meas_type != SINGLE_ARC_ANGLE)
		{
			DMget_cnv_factor((int)env_param->pri_unit,&pri_cnv_factor);
			dimn_val = pri_cnv_factor * dimn_val;
		}

		DMmake_alter_text(
			OM_Gw_current_OS,
			&dim_text,
			dimn_val,
			env_param,
			loc_param,
			misc_param,
			std_param,
			meas_type);
	}
	else
	{
		if (loc_param->tole_mode == TOLE_MODE_REF)
		{
			tole_mode = TOLE_MODE_OFF;
			dual_mode = DUAL_MODE_OFF;
			parens_on = (frm_glob.ref_type == REF_TYPE_PARENS);
			suffix_on = (frm_glob.ref_type == REF_TYPE_SUFFIX);
			subfix_on = (frm_glob.ref_type == REF_TYPE_SUBFIX);
		}
		else if( loc_param->tole_mode >= 100)
		{
			para_mode = loc_param->tole_mode;
			loc_param->tole_mode -= 100;
			suffix_on = subfix_on = FALSE;
			parens_on = TRUE;
		}
		else	parens_on = suffix_on = subfix_on = FALSE;

		DMstart_str(
			&dim_text,
			FNUM_DIM_START,
			std_param);

		if (misc_param->prefix_disp == DISP_ON
		&&  strlen(misc_param->prefix))
		{
			DMcompute_prefix(
				misc_param->prefix,
				&dim_text,
				FNUM_PREFIX_START,
				std_param,
				misc_param->sixteen_bit_font,
				env_param->text_font);
		}

		/* add the field for  dimension box*/

		DMtext_box(&dim_text, FNUM_DIM_FIELD);

		if (env_param->sym_posn != SYM_POSN_NONE)
		{
			symbol_struct = (meas_type == RADIAL)?NULL:
				&DM_global.symbol_info[env_param->dim_stan][SYM_TYPE_DIAMETER];
		}

		if (parens_on)
			DMadd_begin_paren_field(&dim_text, std_param,
						(para_mode >= 100)? "<<":"(");

		if(env_param->sym_posn == SYM_POSN_BEFORE)
		{
			DMcompute_symbol_text(
				OM_Gw_current_OS,
				symbol_struct,
				&dim_text,
				FNUM_SYMBOL_BEFORE,
				std_param,
				env_param->text_font);
		}

		/* Evaluate the dimension type    */

		if (tole_mode == TOLE_MODE_UP_LOW)
			DMget_plus_minus_flag(loc_param, &move_flag, PRIMARY_UNIT);
		else	move_flag = (tole_mode == TOLE_MODE_MIDDLE);

		if (meas_type == STACKED_ANGULAR
		||  meas_type == STRINGED_ANGULAR
		||  meas_type == SINGLE_ARC_ANGLE)
		{
			DMcompute_single_start(
				&dim_text,
				FNUM_SINGLE_START,
				std_param,
				loc_param);

			DMcompute_angular_text(
				OM_Gw_current_OS,
				&dim_text,
				dimn_val,
				env_param,
				loc_param,
				misc_param,
				std_param);

			DMcompute_single_end(
				&dim_text,
				FNUM_SINGLE_END,
				std_param,
				loc_param,
				move_flag);
		}
		else if (dual_mode == DUAL_MODE_OFF)
		{
			/*Add the single start code     */

			DMcompute_single_start(
				&dim_text,
				FNUM_SINGLE_START,
				std_param,
				loc_param);

			DMget_cnv_factor((int)env_param->pri_unit,&pri_cnv_factor);
			DMcompute_dim_text(
				OM_Gw_current_OS,
				&dim_text,
				FNUM_SINGLE_START,
				pri_cnv_factor * dimn_val,
				env_param,
				loc_param,
				misc_param,
				std_param,
				PRIMARY_UNIT);

			DMcompute_single_end(
				&dim_text,
				FNUM_SINGLE_END,
				std_param,
				loc_param,
				move_flag);
		}
		else
		{
			DMdual_above_start(
				&dim_text,
				FNUM_DUAL_START,
				std_param,
				env_param,
				loc_param);

			DMget_cnv_factor((int)env_param->pri_unit,&pri_cnv_factor);
			DMcompute_dim_text(
				OM_Gw_current_OS,
				&dim_text,
				FNUM_DUAL_START,
				pri_cnv_factor * dimn_val,
				env_param,
				loc_param,
				misc_param,
				std_param,
				PRIMARY_UNIT);

			if (parens_on)
			DMadd_end_paren_field(&dim_text, std_param,
					(para_mode >= 100)? ">>":")");

			DMdual_above_middle(
				&dim_text,
				FNUM_DUAL_MIDDLE,
				std_param,
				loc_param);

			if (parens_on)
			DMadd_begin_paren_field(&dim_text, std_param,
						(para_mode >= 100)? "<<":"(");

			DMget_cnv_factor((int)env_param->sec_unit, &sec_cnv_factor);
			if(misc_param->mod_comp == MOD_COMP_STATIC)
			{
				status = 
				sscanf(misc_param->dim_override,"%lf",&over_val);
				if(status >0)
				{
					over_val = over_val * sec_cnv_factor / pri_cnv_factor;
					format[0] = '%';
					format[1] = '.';
					format[2] = (loc_param->secondary.decacc - DECI_ACC1)+ '0';
					format[3] = 'l';
					format[4] = 'f';
					format[5] = '\0';
                			sprintf(misc_param->dim_override,
						format, over_val);
				}
			}

			DMcompute_dim_text(
				OM_Gw_current_OS,
				&dim_text,
				FNUM_DUAL_MIDDLE,
				sec_cnv_factor * dimn_val,
				env_param,
				loc_param,
				misc_param,
				std_param,
				SECONDARY_UNIT);

			memcpy(misc_param->dim_override,
				dim_override, EXFI_STRLEN);

			DMdual_above_end(
				&dim_text,
				FNUM_DUAL_END,
				std_param,
				loc_param);
		}

		if (env_param->sym_posn == SYM_POSN_AFTER)
		{
			DMcompute_symbol_text(
				OM_Gw_current_OS,
				symbol_struct,
				&dim_text,
				FNUM_SYMBOL_AFTER,
				std_param,
				env_param->text_font);
		}

		if (parens_on)
			DMadd_end_paren_field(&dim_text, std_param,
						(para_mode >= 100)? ">>":")");

		/* close the text box field*/

		DMtol_end(&dim_text);

		if (suffix_on)
		{
			DMcompute_ref_suffix_field(
				&dim_text,
				FNUM_REF_SUFFIX_SUBFIX,
				std_param);
		}

		if (misc_param->suffix_disp == DISP_ON
		&&  strlen(misc_param->suffix))
		{
			DMcompute_suffix(
				misc_param->suffix,
				&dim_text,
				FNUM_SUFFIX_START,
				std_param,
				misc_param->sixteen_bit_font,
				env_param->text_font);
		}

		if (subfix_on)
		{
			DMcompute_ref_subfix_field(
				&dim_text,
				FNUM_REF_SUFFIX_SUBFIX,
				(dual_mode == DUAL_MODE_ON),
				std_param);
		}

		DMend_dim(
			&dim_text,
			FNUM_DIM_END,
			std_param);
	}

	/*| Fill text */

	display.weight = env_param->txt_weig;
	display.style  = 0;

	DMfld_fil(
		dim_text.str,
		dim_text.length,
		&display,
		&text_symb);

	/*^ analyse_string(dim_text.str, dim_text.length); */

	/*| Replace text */

        text_length = dim_text.length;

	status =
	om$send(msg = message GRtext.GRreplace_text(
					&long_rc,
					md_env,
					text_length,
					dim_text.str),
		targetid = my_id);
	dm$status(action = RET_STATUS);

        attr_number = GRTEXT_FONT | GRTEXT_LN_SP |
		      GRTEXT_CHAR_SP | GRTEXT_HEIGHT | GRTEXT_WIDTH;

	md_id_save = md_env->md_id.objid;
	md_env->md_id.objid = NULL_OBJID;

	status =
	om$send(msg = message GRtext.GRchgtextattr(
						&long_rc,
						md_env,
						attr_number,
						&text_symb),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (misc_param->prefix_disp)
	DMpreproc_presuf(FALSE, misc_param->prefix);

	if (misc_param->suffix_disp)
	DMpreproc_presuf(FALSE, misc_param->suffix);

	md_env->md_id.objid = md_id_save;

	return(OM_S_SUCCESS);
}

method DMget_dim_fields(
	struct DMenv_param *p_env;
	struct DMloc_param *p_loc;
	struct DMmisc_param *p_misc)
{
	#define MAX_DIM_FIELDS 256

	int i;
	int alt_mode;
	int field_no;	
	int pri_unit, sec_unit, tole_mode;
	struct DMfield_def dmfields[MAX_DIM_FIELDS];

	p_misc->std_param.dm_car_spac = me->attr.char_spac;
	p_misc->std_param.dm_lin_spac = me->attr.line_spac;

	for (i=0; i<MAX_DIM_FIELDS; i++)
	    dmfields[i].start_char = 0;

	/* Initialize all the variables  */

	pri_unit = p_env->pri_unit;
	sec_unit = p_env->sec_unit;
	tole_mode = p_loc->tole_mode;
	p_loc->tole_mode -= (p_loc->tole_mode > 99) ? 100:0;

	p_misc->prefix_disp = DISP_OFF;
	p_misc->suffix_disp = DISP_OFF;
	p_misc->pri_tole_sym[0] = 0;
	p_misc->sec_tole_sym[0] = 0;
	alt_mode = FALSE;


	DMmake_fields(me->text_string, me->attr.text_length, dmfields);

	field_no = 1;   /*  starting field_no   */

	while( field_no  < MAX_DIM_FIELDS)
	{
		if(! dmfields[field_no].start_char)
		{
			field_no++;
			continue;
		}
		if(field_no == FNUM_DIM_ALT_START)
		{
			alt_mode = TRUE;
			field_no++;
			continue;
		}
		if( field_no == FNUM_PREFIX_START)
		{
		 	DMget_prefix_suffix_val(me->text_string,
		 	                    dmfields,
		 	                    p_misc,
			                    field_no);
			field_no++;
		}
		else if( field_no == FNUM_SINGLE_START || alt_mode)
		{
		 	DMget_dimn_string_val(
				      me->text_string,
		 		      dmfields,
		 		      p_misc,
				      p_loc,
				      p_env,
				      field_no,
				      FNUM_SINGLE_START);
			field_no++;
			alt_mode = FALSE;
		}
		else if( field_no == FNUM_DUAL_START)
		{
		 	DMget_dimn_string_val(me->text_string,
		 		    dmfields,
				    p_misc,
		 		    p_loc,
				    p_env,
		 		    field_no,
				    FNUM_DUAL_START);
			field_no++;
		}
		else if( field_no == FNUM_DUAL_MIDDLE)
		{
		 	DMget_dimn_string_val(me->text_string,
		 		    dmfields,
				    p_misc,
		 		    p_loc,
				    p_env,
		 		    field_no,
				    FNUM_DUAL_MIDDLE);
			field_no++;
		}
		else if( field_no == FNUM_SUFFIX_START)
		{
		 	DMget_prefix_suffix_val(me->text_string,
		 			    dmfields,
		 			    p_misc,
		 			    field_no);
			field_no++;
		}
		else	field_no++;
	}

	if (p_misc->prefix_disp)
	DMpreproc_presuf(FALSE, p_misc->prefix);

	if (p_misc->suffix_disp)
	DMpreproc_presuf(FALSE, p_misc->suffix);

	p_loc->tole_mode = tole_mode;

	return(TRUE);
}

end implementation DMtext;
