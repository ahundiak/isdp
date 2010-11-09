class implementation DMroot;

#define AS_DEBUG 1

%safe
#include "math.h"
%endsafe

#include <stdio.h>
#include <ctype.h>
#include "FI.h"
#include "FEI.h"
#include "CIforms.h"
#include "dimformdef.h"
#include "dimform.h"
#include "form_loc.h"
#include "form_env.h"
#include "igewindef.h"
#include "wl.h"
#include "igecolor.h"
#include "igecolordef.h"
#include "igecolmacros.h"
#include "adpdef.h"
#include "ctype.h"
#include "msdef.h"
#include "msmacros.h"
#include "DMmessages.h"

extern char *dim_units_label();
extern struct DMform_info DMform_list[FORM_COUNT+1];

IGRint DMinit_dim_params (dim_stan,osnum,par_env,par_loc,par_misc,par_senv,
                          par_glob,par_weld)
/*(
	 int  dim_stan,
	 OMuword  osnum,
	 struct DMenv_param  *par_env,
	 struct DMloc_param  *par_loc,
	 struct DMmisc_param  *par_misc,
	 struct DMsenv_param  *par_senv,
	 struct DMglobal_param  *par_glob,
	 struct DMweld_param  *par_weld
	)
*/
int dim_stan;
OMuword osnum;
struct DMenv_param *par_env;
struct DMloc_param *par_loc;
struct DMmisc_param *par_misc;
struct DMsenv_param *par_senv;
struct DMglobal_param *par_glob;
struct DMweld_param *par_weld;
/*.DMinit_dim_params*/
{
	int status;
	int index, line_no, len;
	char sts_msg[64];
	FILE *fp[2];
	char filename[16];
	char pathname[128];
	char sysname[128];
	char usrname[128];
	char line[128], *first, *last;
	struct DMkeyboard dm_keyboard;
	struct DM_data_st dm_gadget;
	int i, fcount;

	DMclean_data(DM_ENV_PARAM, (char *)par_env);
	DMclean_data(DM_LOC_PARAM, (char *)par_loc);
	DMclean_data(DM_MISC_PARAM, (char *)par_misc);
	DMclean_data(DM_SENV_PARAM, (char *)par_senv);
	DMclean_data(DM_GLOB_PARAM, (char *)par_glob);
	DMclean_data(DM_WELD_PARAM, (char *)par_weld);

	switch (dim_stan)
	{
		case DIM_STAN_ANS:	strcpy(filename, "DIM_ANSI"); break;
		case DIM_STAN_ISO:	strcpy(filename, "DIM_ISO"); break;
		case DIM_STAN_BSI:	strcpy(filename, "DIM_BSI"); break;
		case DIM_STAN_JIS:	strcpy(filename, "DIM_JIS"); break;
		case DIM_STAN_DIN:	strcpy(filename, "DIM_DIN"); break;
		default:
		printf("init_dim_params: Unknown standard %d\n", dim_stan);
		return(FALSE);
	}

	fp[0] = fp[1] = NULL;
	for (index=0;;index++)
	{
		status =
		ex$get_path(
			index = index,
			path = pathname,
			len = sizeof(pathname));
		if (!status)
		{
			if (fp[0] == NULL)
			{
                                ex$message(msgnumb = DM_I_FileMissFrConfig,
                                           type = "%s",
                                           var = `filename`);

				sprintf(sts_msg, "ERROR: File %s missing from config", filename);
				fprintf(stderr, "%s\n", sts_msg);
				return(FALSE);
			}

			break;
		}

		if (fp[0] == NULL)
		{
			len = sprintf(sysname, "%sconfig/%s", pathname, filename);
			sysname[len] = '\0';
			fp[0] = (FILE *)fopen(sysname, "r");
		}

		if (fp[1] == NULL)
		{
			len = sprintf(usrname, "%s%s", pathname, filename);
			usrname[len] = '\0';
			fp[1] = (FILE *)fopen(usrname, "r");
		}

		if (fp[0] && fp[1])
			break;
	}

	if (fp[1] == NULL)
	{
		/*| user override absent */
		fcount = 1;
	}
	else
	{
		/*"user override present @ <%s>\n", usrname*/
		fcount = 2;
	}

	par_misc->sixteen_bit_font = 0;
	par_misc->mod_comp = MOD_COMP_DYNAMIC;
	par_misc->dim_override[0] = '\0';

	par_senv->bln_size = 3.0;
	par_senv->num_sides = 6;
	par_senv->bln_type = BLN_TYPE_CIRCLE;
	par_senv->an_posn = ANNOT_JUST_BOTTOM;
	par_senv->an_orie = TXT_ORIE_HORIZONTAL;

	par_loc->ctxt_posn = TXT_POSN_EMBEDDED;
	par_misc->prefix[0] =
	par_misc->suffix[0] = '\0';

	par_loc->primary.label[0] =
	par_loc->primary.sub_label[0] =
	par_loc->secondary.label[0] =
	par_loc->secondary.sub_label[0] =
	par_loc->primary.sub_label[0] =
        par_loc->secondary.sub_label[0] = '\0';

	par_misc->unit_sel = UNIT_SEL_PRIMARY;
	par_misc->tole_dsp = TOLE_DSP_PRIMARY;
	par_misc->tog_term = FALSE;

	for (i=0; i<fcount; i++)
	{
		line_no=0;

		while (fgets(line, 80, fp[i]))
		{
			line_no++;
			len = strlen(line);
			first = line;
			last = &line[len - 1];

			while (isspace(*first))
				first++;

			while ((last < first) && (isspace(*last)))
				last--;

			if (last > first) *last = '\0';

			if ( (*first == '\0') || (*first == '#') || (*first == '\n'))
				continue;

			strcpy(dm_keyboard.response, first);

			if (!DMkeyboard_to_internal(&dm_keyboard, &dm_gadget))
			{
				printf("File %s, Line %d:%s\n",
				(i)?usrname:sysname, line_no, dm_keyboard.status);
			}

			DMprocess_keyin(
				TRUE,
				osnum,
				&dm_gadget,
				par_env,
				par_loc,
				par_misc,
				par_senv,
				par_glob,
				par_weld);
		}

		fclose(fp[i]);
	}

	par_env->dim_stan = dim_stan;
	par_env->dual_disp = DUAL_DISP_ABOVE;
	par_env->pnt_exte_r = 2.0;

	switch (dim_stan)
	{
		case DIM_STAN_ANS:
		case DIM_STAN_BSI:

		par_env->ter_heig_r = 1.0;
		par_env->ter_widt_r = 1.0;
		break;

		case DIM_STAN_ISO:
		case DIM_STAN_JIS:
		case DIM_STAN_DIN:

		par_env->ter_heig_r = 1.4;
		par_env->ter_widt_r = 1.0;
		break;

		default:
		printf("init_dim_params: Unknown standard %d\n", dim_stan);
		return(FALSE);
	}

	/*| Convert txt_heig and txt_weig to file units */

	{
		IGRdouble conv_factor;

		DMtxt_conv_fact(CONV_TO_FILE_UNITS, &conv_factor, par_env->pri_unit);
		par_env->txt_heig *= conv_factor;
		par_env->txt_widt *= conv_factor;
	}

	/*- Kludge added to include unit parmeter in par_senv
	    and initilaise this with par_env.pri_unit;
	*/

	par_senv->ter_disp = par_env->pri_unit;

	/*|- Initialise Weld param*/

	par_weld->above = (par_weld->proj_method)?FALSE:TRUE;
	par_weld->below = (par_weld->proj_method)?TRUE:FALSE;
	par_weld->center = FALSE;
	par_weld->flag = FALSE;
	par_weld->circle = FALSE;
	par_weld->cross_section = FALSE;
	par_weld->z_symb = FALSE;
	par_weld->tail = FALSE;
	par_weld->cen_symb = 11;
	par_weld->atext.weld_symbol = 25;
	par_weld->btext.weld_symbol = 25;
	par_weld->atext.weld_type = 11;
	par_weld->btext.weld_type = 11;
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
	par_weld->tailtext[0] = '\0';

	return(TRUE);
}

IGRint DMprocess_keyin (flag,osnum,p_dm_gadget,par_env,par_loc,par_misc,
                        par_senv,par_glob,par_weld)
/*(
	 IGRboolean  flag,
	 OMuword  osnum,
	 struct DM_data_st  *p_dm_gadget,
	 struct DMenv_param  *par_env,
	 struct DMloc_param  *par_loc,
	 struct DMmisc_param  *par_misc,
	 struct DMsenv_param  *par_senv,
	 struct DMglobal_param  *par_glob,
	 struct DMweld_param  *par_weld
	)
*/
IGRboolean flag;
OMuword osnum;
struct DM_data_st *p_dm_gadget;
struct DMenv_param *par_env;
struct DMloc_param *par_loc;
struct DMmisc_param *par_misc;
struct DMsenv_param *par_senv;
struct DMglobal_param *par_glob;
struct DMweld_param *par_weld;
/*.DMprocess_keyin*/
{
	IGRint status;
	IGRuchar *accuracy;

	switch(p_dm_gadget->form_no)
	{
		case NOT_ON_FORM:

		status =
		DMprocess_keyin_NOT_ON_FORM(
			flag,
			osnum,
			p_dm_gadget,
			par_env,
			par_loc,
			par_misc,
			par_senv,
			par_glob,
			par_weld);
		break;

		case FORM_ENVIRON:

		status =
		DMprocess_keyin_FORM_ENVIRON(
			flag,
			osnum,
			p_dm_gadget,
			par_env,
			par_loc,
			par_misc,
			par_glob);
		break;

		case FORM_LOCAL:

		status =
		DMprocess_keyin_FORM_LOCAL(
			flag,
			osnum,
			p_dm_gadget,
			par_env,
			par_loc,
			par_misc);
		break;

		case FORM_DISPLAY:

		status =
		DMprocess_keyin_FORM_DISPLAY(
			flag,
			osnum,
			p_dm_gadget,
			par_env,
			par_loc,
			par_misc);
		break;

		case FORM_DIMTERM:

		status =
		DMmap_gadget_value(
			flag,
			&par_env->ter_type,
			p_dm_gadget);
		if (flag)
			par_env->ter_type0 = par_env->ter_type;
		break;

		case FORM_FORMAT:

		status =
		DMmap_gadget_value(
			flag,
			&par_loc->tole_mode,
			p_dm_gadget);
		break;

		case FORM_DECACC_PRI:
		case FORM_DECACC_SEC:
		case FORM_DECACC_ANG:

		if (p_dm_gadget->form_no == FORM_DECACC_PRI)
			accuracy = &par_loc->primary.decacc;
		else if (p_dm_gadget->form_no == FORM_DECACC_SEC)
			accuracy = &par_loc->secondary.decacc;
		else	accuracy = &par_loc->angular.decacc;

		status =
		DMmap_gadget_value(
			flag,
			accuracy,
			p_dm_gadget);
		break;

		case FORM_FRAACC_PRI:
		case FORM_FRAACC_SEC:
		case FORM_FRAACC_ANG:

		if (p_dm_gadget->form_no == FORM_FRAACC_PRI)
			accuracy = &par_loc->primary.fraacc;
		else if (p_dm_gadget->form_no == FORM_FRAACC_SEC)
			accuracy = &par_loc->secondary.fraacc;
		else	accuracy = &par_loc->angular.fraacc;

		status =
		DMmap_gadget_value(
			flag,
			accuracy, 
			p_dm_gadget);
		break;

		case FORM_ANG_ROFF:

		store_double(
			flag,
			par_loc->angular.ang_roff_unit,
			p_dm_gadget);
		status = TRUE;
		break;

		default:

		printf("process_keyin: Error in form_no %d\n",
				p_dm_gadget->form_no);
		return(FALSE);
	}

	return(status);
}
#argsused
IGRint DMprocess_keyin_FORM_DISPLAY (flag,osnum,p_dm_gadget,par_env,par_loc,
                                     par_misc)
/*(
	 IGRboolean  flag,
	 OMuword  osnum,
	 struct DM_data_st  *p_dm_gadget,
	 struct DMenv_param  *par_env,
	 struct DMloc_param  *par_loc,
	 struct DMmisc_param  *par_misc
	)
*/
IGRboolean flag;
OMuword osnum;
struct DM_data_st *p_dm_gadget;
struct DMenv_param *par_env;
struct DMloc_param *par_loc;
struct DMmisc_param *par_misc;
/*.DMprocess_keyin_FORM_DISPLAY*/
{
	switch(p_dm_gadget->label)
	{
		case GAD_TXT_POSN:
		store_int(flag, par_loc->txt_posn, p_dm_gadget);
		break;

		case GAD_TXT_ORIE:
		store_int(flag, par_loc->txt_orie, p_dm_gadget);
		break;

		case GAD_ORI_DISP:
		if (flag)
		{
			if (val_int(p_dm_gadget))
				par_loc->proj_disp |= PROJ_DISP_ORI;
			else	par_loc->proj_disp &= (~PROJ_DISP_ORI);
		}
		else
		{
			if (par_loc->proj_disp & PROJ_DISP_ORI)
				val_int(p_dm_gadget) = TRUE;
			else	val_int(p_dm_gadget) = FALSE;
		}
		break;

		case GAD_MEA_DISP:
		if (flag)
		{
			if (val_int(p_dm_gadget))
				par_loc->proj_disp |= PROJ_DISP_MEA;
			else	par_loc->proj_disp &= (~PROJ_DISP_MEA);
		}
		else
		{
			if (par_loc->proj_disp & PROJ_DISP_MEA)
				val_int(p_dm_gadget) = TRUE;
			else	val_int(p_dm_gadget) = FALSE;
		}
		break;

		case GAD_PROJ_ANGL:
		store_double(flag, par_env->proj_angl, p_dm_gadget);
		break;

		case GAD_SCA_FACT:
		store_double(flag, par_env->sca_fact, p_dm_gadget);
		break;

		default:
		printf("process_keyin_FORM_DISPLAY: Unknown label %d\n",
				p_dm_gadget->label);
		return(FALSE);
	}

	return(TRUE);
}

IGRint DMprocess_keyin_NOT_ON_FORM (flag,osnum,p_dm_gadget,par_env,par_loc,
                                    par_misc,par_senv,par_glob,par_weld)
/*(
	 IGRboolean  flag,
	 OMuword  osnum,
	 struct DM_data_st  *p_dm_gadget,
	 struct DMenv_param  *par_env,
	 struct DMloc_param  *par_loc,
	 struct DMmisc_param  *par_misc,
	 struct DMsenv_param  *par_senv,
	 struct DMglobal_param  *par_glob,
	 struct DMweld_param  *par_weld
	)
*/
IGRboolean flag;
OMuword osnum;
struct DM_data_st *p_dm_gadget;
struct DMenv_param *par_env;
struct DMloc_param *par_loc;
struct DMmisc_param *par_misc;
struct DMsenv_param *par_senv;
struct DMglobal_param *par_glob;
struct DMweld_param *par_weld;
/*.DMprocess_keyin_NOT_ON_FORM*/
{
	int rc;
	struct vfont_entry font_info;

	/*"label=%d\n", p_dm_gadget->label*/

	switch(p_dm_gadget->label)
	{
		case KEY_POSS_VALUES:
		case KEY_ACT_VALUES:
		return(flag);

		case KEY_TXT_WIDT:
		store_double(flag, par_env->txt_widt, p_dm_gadget);
		break;

		case KEY_TERM_SIZE:
		store_double(flag, par_env->ter_heig_r, p_dm_gadget);
		break;

		case KEY_FRAC_FONT:

		if (flag)
		{
			DMretrieve_font(
				&rc,
				osnum,
				val_alpha(p_dm_gadget),
				&par_env->frac_font);
		}
		else
		{
			font$get_info(
				msg = &rc,
				font_num = &par_env->frac_font,
				font_info = &font_info);
			if (rc == MSFAIL)
			{
				/*"invalid FRAC_FONT %d\n", par_env->frac_font*/
				strcpy(val_alpha(p_dm_gadget), "deffrac");
			}
			else	strcpy(val_alpha(p_dm_gadget),
					(char *)font_info.vfontname);
		}
		break;

		case KEY_TER_TYPE0:
		store_int(flag, par_env->ter_type0, p_dm_gadget);
		break;

		case KEY_PRI_TOLE_UP:
		store_str9(flag, (char *)par_loc->primary.tole_up, p_dm_gadget);
		break;

		case KEY_PRI_TOLE_LOW:
		store_str9(flag, (char *)par_loc->primary.tole_low, p_dm_gadget);
		break;

		case KEY_SEC_TOLE_UP:
		store_str9(flag, (char *)par_loc->secondary.tole_up, p_dm_gadget);
		break;

		case KEY_SEC_TOLE_LOW:
		store_str9(flag, (char *)par_loc->secondary.tole_low, p_dm_gadget);
		break;

		case KEY_PRI_TOLE_SYM:
		store_str8(flag, par_misc->pri_tole_sym, p_dm_gadget);
		break;

		case KEY_SEC_TOLE_SYM:
		store_str8(flag, par_misc->sec_tole_sym, p_dm_gadget);
		break;

		case KEY_TER_DISP:
		store_int(flag, par_loc->ter_disp, p_dm_gadget);
		break;

		case KEY_PRI_UNITS:
		store_int(flag, par_env->pri_unit, p_dm_gadget);
		break;

		case KEY_PRI_LEADING:
		store_int(flag, par_loc->primary.leading, p_dm_gadget);
		break;

		case KEY_PRI_TRAILING:
		store_int(flag, par_loc->primary.trailing, p_dm_gadget);
		break;

		case KEY_SEC_UNITS:
		store_int(flag, par_env->sec_unit, p_dm_gadget);
		break;

		case KEY_SEC_LEADING:
		store_int(flag, par_loc->secondary.leading, p_dm_gadget);
		break;

		case KEY_SEC_TRAILING:
		store_int(flag, par_loc->secondary.trailing, p_dm_gadget);
		break;

		case KEY_PRI_LABEL:

		store_str9(flag, (char *)par_loc->primary.label, p_dm_gadget);
		break;

		case KEY_PRI_SUB_LABEL:
		store_str9(flag, (char *)par_loc->primary.sub_label, p_dm_gadget);
		break;

		case KEY_SEC_LABEL:
		store_str9(flag, (char *)par_loc->secondary.label, p_dm_gadget);
		break;

		case KEY_SEC_SUB_LABEL:
		store_str9(flag, (char *)par_loc->secondary.sub_label, p_dm_gadget);
		break;

		case KEY_BLN_TYPE:
		store_int(flag, par_senv->bln_type, p_dm_gadget);
		break;

		case KEY_BLN_SIZE:
		store_double(flag, par_senv->bln_size, p_dm_gadget);
		break;

		case KEY_NUM_SIDES:
		store_int(flag, par_senv->num_sides, p_dm_gadget);
		break;

		case KEY_ANNOT_POSN:
		store_int(flag, par_senv->an_posn, p_dm_gadget);
		break;

		case KEY_ANNOT_ORIE:
		store_int(flag, par_senv->an_orie, p_dm_gadget);
		break;

		case KEY_CTXT_POSN:
		store_int(flag, par_loc->ctxt_posn, p_dm_gadget);
		break;

		case KEY_AUT_SUPPRESS:
		store_int(flag, par_misc->aut_dia, p_dm_gadget);
		break;

		case KEY_DATUM_TERM:
		store_int(flag, par_senv->datum_ter_type, p_dm_gadget);
		break;

		case KEY_CAR_SPAC:
		store_double(flag, par_misc->std_param.dm_car_spac, p_dm_gadget);
		break;

		case KEY_LIN_SPAC:
		store_double(flag, par_misc->std_param.dm_lin_spac, p_dm_gadget);
		break;

		case GAP_TXT_CLEARANCE:
		store_double(flag, par_misc->std_param.dm_text_clear, p_dm_gadget);
		break;

		case GAP_PRE_SUFF:
		store_double(flag, par_misc->std_param.dm_pre_suf_gap, p_dm_gadget);
		break;

		case GAP_SYMBOL:
		store_double(flag, par_misc->std_param.dm_sym_gap, p_dm_gadget);
		break;

		case GAP_DUAL_DIM:
		store_double(flag, par_misc->std_param.dm_dual_off, p_dm_gadget);
		break;

		case GAP_TOL_HOR:
		store_double(flag, par_misc->std_param.dm_tol_hor_gap, p_dm_gadget);
		break;

		case GAP_TOL_VER:
		store_double(flag, par_misc->std_param.dm_tol_ver_gap, p_dm_gadget);
		break;

		case GAP_VER_LIMI:
		store_double(flag, par_misc->std_param.dm_lim_ver_gap, p_dm_gadget);
		break;

		case GAP_BOX_HOR:
		store_double(flag, par_misc->std_param.dm_box_hor_gap, p_dm_gadget);
		break;

		case GAP_BOX_VER:
		store_double(flag, par_misc->std_param.dm_box_ver_gap, p_dm_gadget);
		break;

		case KEY_REF_TYPE:
		store_int(flag, par_glob->ref_type, p_dm_gadget);
		/*^ printf("ref_type = %d\n", par_glob->ref_type); */
		break;

		case KEY_DIM_DISP:
		store_int(flag, par_glob->disp_type, p_dm_gadget);
		/*^ printf("disp_type = %d\n", par_glob->disp_type); */
		break;

		case KEY_VIEW_ANG:
		store_double(flag, par_glob->view_angle, p_dm_gadget);
		/*^ printf("max view ang = %f\n", par_glob->view_angle); */
		break;

		case KEY_PROJ_METHOD:
		store_int(flag, par_weld->proj_method, p_dm_gadget);
		/*^ printf("proj_method = %d\n", par_weld->proj_method); */
		break;

		case KEY_ANSI_WELD:
		store_int(flag, par_weld->ansi_weld, p_dm_gadget);
		/*^ printf("ansi_weld = %d\n", par_weld->ansi_weld); */
		break;

		case KEY_DASH_LINE:
		store_int(flag, par_weld->dash_line, p_dm_gadget);
		/*^ printf("dash_line = %d\n", par_weld->dash_line); */
		break;

		case SUPER_USER:
		break;

		default:
		printf("process_keyin_NOT_ON_FORM: Unknown key %d\n",
					p_dm_gadget->label);
		return(FALSE);
	}

	return(TRUE);
}

IGRint DMprocess_keyin_FORM_ENVIRON (flag,osnum,p_dm_gadget,par_env,par_loc,
                                     par_misc,par_glob)
/*(
	 IGRboolean  flag,
	 OMuword  osnum,
	 struct DM_data_st  *p_dm_gadget,
	 struct DMenv_param  *par_env,
	 struct DMloc_param  *par_loc,
	 struct DMmisc_param  *par_misc,
	 struct DMglobal_param  *par_glob
	)
*/
IGRboolean flag;
OMuword osnum;
struct DM_data_st *p_dm_gadget;
struct DMenv_param *par_env;
struct DMloc_param *par_loc;
struct DMmisc_param *par_misc;
struct DMglobal_param *par_glob;
/*.DMprocess_keyin_FORM_ENVIRON*/
{
	int rc;
	short color;
	struct vfont_entry font_info;
	IGRchar layer[16];

	switch (p_dm_gadget->label)
	{
		case GAD_DUAL_MODE:
		store_int(flag, par_env->dual_mode, p_dm_gadget);
		break;

		case GAD_ANG_UNITS:
		store_int(flag, par_env->ang_unit, p_dm_gadget);
		break;

		case GAD_DELIMITER:
		store_int(flag, par_loc->primary.deci_char, p_dm_gadget);
		break;

		case GAD_TXT_HEIG:
		store_double(flag, par_env->txt_heig, p_dm_gadget);
		break;

		case GAD_ASP_RATI:
		store_double(flag, par_misc->asp_rati_r, p_dm_gadget);
		break;

		case GAD_TXT_WEIG:
		store_int(flag, par_env->txt_weig, p_dm_gadget);
		break;

		case GAD_TOL_WEIG:
		store_int(flag, par_env->tol_weig, p_dm_gadget);
		break;

		case GAD_DIM_WEIG:
		store_int(flag, par_env->dim_weig, p_dm_gadget);
		break;

		case GAD_TXT_FONT:
		if (flag)
		{
			DMretrieve_font(
				&rc,
				osnum,
				val_alpha(p_dm_gadget),
				&par_env->text_font);
		}
		else
		{
			font$get_info(
				msg = &rc,
				font_num = &par_env->text_font,
				font_info = &font_info);
			if (rc == MSFAIL)
			{
				/*"invalid TEXT_FONT %d\n", par_env->text_font*/
				strcpy(val_alpha(p_dm_gadget), "default");
			}
			else	strcpy(val_alpha(p_dm_gadget),
					(char *)font_info.vfontname);
		}
		break;

		case GAD_DIM_COLR:
		if (flag)
		{
			process_color(&color, p_dm_gadget);
			par_glob->driven_color = color;
			par_env->dim_colr = color;
		}
		else
		{
		        if(par_glob->dim_mode == MODELING_MODE)
			  sprintf(val_alpha(p_dm_gadget),"%d",
				  par_glob->driven_color);
			else
			  sprintf(val_alpha(p_dm_gadget),"%d",
				  par_env->dim_colr);
			  
		}
		break;

		case GAD_DET_COLR:
		if (flag)
		{
			process_color(&color, p_dm_gadget);
			par_glob->detached_color = color;
			par_env->det_colr = color;
		}
		else
		{
			sprintf(val_alpha(p_dm_gadget),"%d", 
				par_glob->detached_color);
		}
		break;

		case GAD_DRVG_COLR:
		if (flag)
		{
			process_color(&color, p_dm_gadget);
			par_glob->driving_color = color;
		}
		else sprintf(val_alpha(p_dm_gadget),"%d", par_glob->driving_color);
		break;

		case GAD_DIM_LAYR:
		if(flag)
		  {
		    strcpy(layer,val_alpha(p_dm_gadget));
		    par_env->dim_layr = atoi(layer);
		  }
		else sprintf(val_alpha(p_dm_gadget),"%d", par_env->dim_layr);
		break;

		case GAD_DIM_MODE:
		store_int(flag, par_glob->dim_mode, p_dm_gadget);
		break;

		case GAD_PROJ_EXTN:
		store_double(flag, par_env->proj_extn_r, p_dm_gadget);
		break;

		case GAD_LIN_OFFS:
		store_double(flag, par_env->lin_offs_r, p_dm_gadget);
		break;

		case GAD_PROJ_OFFS:
		store_double(flag, par_env->proj_offs_r, p_dm_gadget);
		break;

		case GAD_TER_LIMIT:
		store_double(flag, par_misc->ter_limit_r, p_dm_gadget);
		break;

		case GAD_TXT_YOFF:
		store_double(flag, par_env->txt_yoff_r, p_dm_gadget);
		break;

		case GAD_TOL_SIZE:
		store_double(flag, par_env->tol_size_r, p_dm_gadget);
		break;

		case GAD_LIN_DISP:
		store_int(flag, par_loc->lin_disp, p_dm_gadget);
		break;

		case GAD_DIM_STAN:
		store_int(flag, par_env->dim_stan, p_dm_gadget);
		break;

		case GAD_COMM_ORIG:
		if (flag)
		{
			if (val_int(p_dm_gadget) == 0)
				par_env->comm_origin = TER_TYPE_DOT;
			else if (val_int(p_dm_gadget) == 1)
				par_env->comm_origin = TER_TYPE_CIRCLE;
			else	par_env->comm_origin = TER_TYPE_BLANK;

		}
		else
		{
			if (par_env->comm_origin == TER_TYPE_DOT)
				val_int(p_dm_gadget) = 0;
			if (par_env->comm_origin == TER_TYPE_CIRCLE)
				val_int(p_dm_gadget) = 1;
			else	val_int(p_dm_gadget) = 2;
		}
		break;

		case GAD_SYM_POSN:
		store_int(flag, par_env->sym_posn, p_dm_gadget);
		break;

		case GAD_MAX_SUB:
		store_int(flag, par_loc->max_sub, p_dm_gadget);
		break;

		default:
		printf("process_keyin_FORM_ENVIRON: Unknown label %d\n",
				p_dm_gadget->label);
		return(FALSE);
	}

	return(TRUE);
}
#argsused
IGRint DMprocess_keyin_FORM_LOCAL (flag,osnum,p_dm_gadget,par_env,par_loc,
                                   par_misc)
/*(
	 IGRboolean  flag,
	 OMuword  osnum,
	 struct DM_data_st  *p_dm_gadget,
	 struct DMenv_param  *par_env,
	 struct DMloc_param  *par_loc,
	 struct DMmisc_param  *par_misc
	)
*/
IGRboolean flag;
OMuword osnum;
struct DM_data_st *p_dm_gadget;
struct DMenv_param *par_env;
struct DMloc_param *par_loc;
struct DMmisc_param *par_misc;
/*.DMprocess_keyin_FORM_LOCAL*/
{
	switch (p_dm_gadget->label)
	{
		case GAD_TOG_TERM:
		return(flag);

		case GAD_PREFIX:
		store_str(flag, par_misc->prefix, p_dm_gadget);
		break;

		case GAD_PRE_DISP:
		store_int(flag, par_misc->prefix_disp, p_dm_gadget);
		break;

		case GAD_SUFFIX:
		store_str(flag, par_misc->suffix, p_dm_gadget);
		break;

		case GAD_SUF_DISP:
		store_int(flag, par_misc->suffix_disp, p_dm_gadget);
		break;

		case GAD_DECI_FRAC:
		store_int(flag, par_loc->deci_frac, p_dm_gadget);
		break;

		case GAD_NTS_ULINE:
		store_int(flag, par_env->nts_uline, p_dm_gadget);
		break;

		case GAD_OVERRIDE:
		if (flag)
		{
			strcpy(par_misc->dim_override, val_alpha(p_dm_gadget));
			if (par_misc->dim_override[0])
				par_misc->mod_comp = MOD_COMP_STATIC;
			else	par_misc->mod_comp = MOD_COMP_DYNAMIC;
		}
		else if (par_misc->mod_comp == MOD_COMP_STATIC)
			strcpy(val_alpha(p_dm_gadget), par_misc->dim_override);
		else	strcpy(val_alpha(p_dm_gadget), "");
		break;

		case GAD_AUT_CENT:
		store_int(flag, par_misc->aut_cent, p_dm_gadget);
		break;

		default:
		printf("process_keyin_FORM_LOCAL: Unknown label %d\n",
				p_dm_gadget->label);
		return(FALSE);
	}

	return(TRUE);
}

IGRint DMmap_gadget_value (flag,p_value,p_dm_gadget)
/*(
	 IGRboolean  flag,
	 IGRchar  *p_value,
	 struct DM_data_st  *p_dm_gadget
	)
*/
IGRboolean flag;
IGRchar *p_value;
struct DM_data_st *p_dm_gadget;
/*.DMmap_gadget_value*/
{
	int form_no, label, map_size, option, i;
	struct lab_val *map;

	if (flag && p_dm_gadget->type != DIM_INT)
	{
		/*"map_value: ERROR in gad_type %d\n", p_dm_gadget->type*/
		return(FALSE);
	}

	form_no = p_dm_gadget->form_no;
	label   = p_dm_gadget->label;
	map_size = DMform_list[form_no].map_size;
	map      = DMform_list[form_no].map;

	if (flag)
	{
		option = val_int(p_dm_gadget);
		if (option < 0 || option >= map_size)
		{
			/*"map_value: ERROR in option %d\n", option*/
			return(-1);
		}

		*p_value = map[option].ivalue;
	}
	else
	{
		for (i=0;
		     (i<map_size) && (map[i].ivalue != *p_value);
		     i++)
			;

		if (i == map_size)
		{
			/*"map_value: ERROR in value %d\n", *p_value*/
			return(FALSE);
		}

		val_int(p_dm_gadget) = i;
	}

	return(TRUE);
}

void clear_dbl (d,n)
/*(
	 double  *d,
	 int  n
	)
*/
IGRdouble *d;
int n;
{
	while (n) d[--n] = 0.0;
}

void clear_chr (c,n)
/*(
	 char  *c,
	 int  n
	)
*/
char *c;
int n;
{
	while (n) c[--n] = '\0';
}

process_color (color,p_dm_gadget)
/*(
	 IGRshort  *color,
	 struct DM_data_st  *p_dm_gadget
	)
*/
IGRshort *color;
struct DM_data_st *p_dm_gadget;
{
	IGRint sts;
	IGRchar string[20];
	IGRushort ushortnum;

 	strcpy(string, p_dm_gadget->val.alpha);
	if(isdigit(string[0]))
	{
		ushortnum = (IGRushort)atoi(string);
		if ((ushortnum >= GR_LO_COLOR)
		&&  (ushortnum <= GR_HI_COLOR))
		{
			*color = ushortnum;
		}
		else	*color = 0;
	}
	else
	{
		sts =
		ige$get_color_from_name(
				color = color,
				name = string);
		if(!sts) *color = 0;
	}
	return(TRUE);
}

end implementation DMroot;
