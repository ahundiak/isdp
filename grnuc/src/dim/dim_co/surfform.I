/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:30 $
$Locker:  $
$Log: surfform.I,v $
Revision 1.1.1.1  2001/12/17 22:39:30  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:07:58  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:21:58  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:51:27  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.0  1992/12/06  23:44:09  tim
# COMMENT : Initial checkin to 2.4 RCS
#
# Revision 220.0  1992/08/29  06:23:28  root
# COMMENT : Corresponds to Rel201.2 in 2.0.1 RCS
#
# Revision 201.2  1992/08/26  11:31:25  poo
# COMMENT : Corrected Symbol text positions, modified prompts, fixed backup problem.
#
*/

class implementation COsurf;

#include "FI.h"

/* Gadgets */

#define FTEXT_A		13
#define FTEXT_BA	12
#define FTEXT_BM	28
#define FTEXT_CA	27
#define FTEXT_CM	26
#define FTEXT_D		16
#define FTEXT_EA	15
#define FTEXT_EM	32
#define FTEXT_F		14
#define BSYMBOL_1	21
#define BSYMBOL_2       22
#define BSYMBOL_3       24
#define SYMBOL_POSN	18
#define SURF_DIR	31
#define SURF_FM_BLANK	29
#define SURF_FM_LINE	19

/*- Sub Form symbol gadgets */

#define SURF_FM_E       12
#define SURF_FM_T       13
#define SURF_FM_X       14
#define SURF_FM_M       15
#define SURF_FM_C       16
#define SURF_FM_R       17
#define SURF_FM_P       18
#define SURF_FM_NONE    19

#define form_sts(a)	{if( a != FI_SUCCESS) return(OM_E_ABORT);}

#define AS_DEBUG 1

/* Externs */

extern int FIg_get_text_length();
extern int FIg_get_text();

IGRint DMprocess_surf_form(
	display,
	form_display,
	ansi,
	update,
	ignore,
	edit,
	f_label,
	g_label,
	value,
	form,
	sub_form,
	par_surf)
IGRboolean display, ansi, *update, *ignore, edit;
IGRint *form_display;
IGRint     f_label;       /* The label of the form   */
IGRint     g_label;       /* The label of the gadget */
IGRdouble  value;         /* The value of the gadget */
Form    form;            /* Pointer to the form     */
Form    sub_form;        /* Pointer to the sub form */
struct DMsurf_param *par_surf;
/*.DMprocess_surf_form*/
{
	IGRint status, symbol_num, mask, label;
	IGRint posit_x, posit_y;

	if (edit)
		*update = FALSE;
	else	*update = TRUE;

	*ignore = FALSE;

	if (display)
	{
		/*|- Set basic symbol Type */

		if (par_surf->basic_sym == SURF_TRIANGLE)
			label = BSYMBOL_2;
		else if (par_surf->basic_sym == SURF_ANGLE)
			label = BSYMBOL_1;
		else	label = BSYMBOL_3;

		status =
		FIg_set_value(form, label, 1.0);
		if (status != FI_SUCCESS)
		{
			printf("FIg_set_value Fails label = %d\n", label);
			return(OM_E_ABORT);
		}

		/*|- Set symbol position */

		status =
		FIg_set_value(form, SYMBOL_POSN, 0.0);
		form_sts(status);

		/*|- Set direction of lay symbol */

		switch(par_surf->dir_sym)
		{
			case SURF_DIR_R:
			symbol_num = 74;
			break;

			case SURF_DIR_M:
			symbol_num = 73;
			break;

			case SURF_DIR_E:
			symbol_num = 77;
			break;

			case SURF_DIR_C:
			symbol_num = 72;
			break;

			case SURF_DIR_X:
			symbol_num = 75;
			break;

			case SURF_DIR_P:
			symbol_num = 78;
			break;

			case SURF_DIR_T:
			symbol_num = 71;
			break;

			case SURF_DIR_NONE:
			symbol_num = 0;
			break;

			default:
			/*"Illegal symbol type %d\n",par_surf->dir_sym*/
			return(OM_E_ABORT);
		}

		status =
		FIg_set_symbol_index(form, SURF_DIR, symbol_num);
		form_sts(status);

		if (par_surf->dir_sym == SURF_DIR_NONE)
		{
			status =
			FIg_erase(form, SURF_DIR);
			form_sts(status);

			status =
			FIg_display(form, SURF_DIR);
			form_sts(status);

			status =
			FIg_display(form, SURF_FM_BLANK);
			form_sts(status);
		}
		else
		{
			status =
			FIg_erase(form, SURF_FM_BLANK);
			form_sts(status);

			status =
			FIg_display(form, SURF_DIR);
			form_sts(status);
		}

		/*|- Set the line on-off*/

		if (par_surf->line_on)
		{
			status = FIg_unhilite(form, SURF_FM_LINE);
			form_sts(status);
		}
		else
		{
			status = FIg_hilite(form, SURF_FM_LINE);
			form_sts(status);
		}

		/*|- Display the correct text field depending on units*/

		status =
		DMsurf_settxt(form, FTEXT_A, par_surf->text_a);
		dm$status(action = RET_STATUS);

		status =
		DMsurf_settxt(form, (ansi)?FTEXT_BA:FTEXT_BM, par_surf->text_b);
		dm$status(action = RET_STATUS);

		status =
		DMsurf_settxt(form, (ansi)?FTEXT_CA:FTEXT_CM, par_surf->text_c);
		dm$status(action = RET_STATUS);

		status =
		DMsurf_settxt(form, FTEXT_D, par_surf->text_d);
		dm$status(action = RET_STATUS);

		status =
		DMsurf_settxt(form, (ansi)?FTEXT_EA:FTEXT_EM, par_surf->text_e);
		dm$status(action = RET_STATUS);

		status =
		DMsurf_settxt(form, FTEXT_F, par_surf->text_f);
		dm$status(action = RET_STATUS);

		if (ansi)
		{
			/*|- erasing FTEXT_BM*/

			status =
			FIg_erase(form, FTEXT_BM);
			form_sts(status);

			/*|- erasing FTEXT_BA*/

			status =
			FIg_display(form, FTEXT_BA);
			form_sts(status);

			status =
			FIg_erase(form, FTEXT_CM);
			form_sts(status);

			status =
			FIg_display(form, FTEXT_CA);
			form_sts(status);

			status =
			FIg_erase(form, FTEXT_EM);
			form_sts(status);

			status =
			FIg_display(form, FTEXT_EA);
			form_sts(status);
		}
		else
		{
			status =
			FIg_erase(form, FTEXT_BA);
			form_sts(status);

			status =
			FIg_display(form, FTEXT_BM);
			form_sts(status);

			status =
			FIg_erase(form, FTEXT_CA);
			form_sts(status);

			status =
			FIg_display(form, FTEXT_CM);
			form_sts(status);

			status =
			FIg_erase(form, FTEXT_EA);
			form_sts(status);

			status =
			FIg_display(form, FTEXT_EM);
			form_sts(status);
		}

		/*|- Set value for check */

		status =
		FIg_set_value(form, FI_ACCEPT, 0.0);
		form_sts(status);

		/*|- Erase the cancel if not edit */

		if (!edit)
		{
			status =
			FIg_erase(form, FI_CANCEL);
			form_sts(status);
		}
		else
		{
			status =
			FIg_set_value(form, FI_CANCEL, 0.0);
			form_sts(status);
		}

		/*|- Now send a display */

		status =
		FIf_display(form);
		form_sts(status);

		*form_display = TRUE;
	}
	else
	{
		if (f_label == SURF_SUB_FORM)
		{
			/*|- Process Sub Form*/

			switch (g_label)
			{
				case SURF_FM_E:
				par_surf->dir_sym = SURF_DIR_E;
				symbol_num = 77;
				break;

				case SURF_FM_T:
				par_surf->dir_sym = SURF_DIR_T;
				symbol_num = 71;
				break;

				case SURF_FM_M:
				par_surf->dir_sym = SURF_DIR_M;
				symbol_num = 73;
				break;

				case SURF_FM_X:
				par_surf->dir_sym = SURF_DIR_X;
				symbol_num = 75;
				break;

				case SURF_FM_R:
				par_surf->dir_sym = SURF_DIR_R;
				symbol_num = 74;
				break;

				case SURF_FM_P:
				par_surf->dir_sym = SURF_DIR_P;
				symbol_num = 78;
				break;

				case SURF_FM_C:
				par_surf->dir_sym = SURF_DIR_C;
				symbol_num = 72;
				break;

				case SURF_FM_NONE:
				par_surf->dir_sym = SURF_DIR_NONE;
				symbol_num = 0;
				break;

				default:
				/*"Illegal sub_form gadget %d\n", g_label*/
				return(OM_E_ABORT);
			}

			status =
			FIf_erase(sub_form);
			form_sts(status);

			/*|- Set the symbol display properly */

			status =
			FIg_set_value(form, SURF_DIR, 0.0);
			form_sts(status);

			status =
			FIg_set_symbol_index(form, SURF_DIR , symbol_num);
			form_sts(status);

			if (g_label == SURF_FM_NONE)
			{
				status =
				FIg_erase(form, SURF_DIR);
				form_sts(status);

				status =
				FIg_display(form, SURF_DIR);
				form_sts(status);

				status =
				FIg_display(form, SURF_FM_BLANK);
				form_sts(status);

			}
			else
			{
				status =
				FIg_erase(form, SURF_FM_BLANK);
				form_sts(status);

				status =
				FIg_display(form, SURF_DIR);
				form_sts(status);
			}

			return(OM_S_SUCCESS);
		}
	
		switch (g_label)
		{
		case FTEXT_BM:
		case FTEXT_BA:

		/*" FTEXT_B label = %d\n", g_label*/

		status =
		DMsurf_gettxt (form, g_label, par_surf->text_b);
		dm$status(action = RET_STATUS);

		break;

		case FTEXT_A:

		status =
		DMsurf_gettxt (form, g_label, par_surf->text_a);
		dm$status(action = RET_STATUS);

		break;

		case FTEXT_CA:
		case FTEXT_CM:

		status =
		DMsurf_gettxt (form, g_label, par_surf->text_c);
		dm$status(action = RET_STATUS);

		break;

		case FTEXT_D:

		status =
		DMsurf_gettxt (form, g_label, par_surf->text_d);
		dm$status(action = RET_STATUS);

		status =
		DMsurf_check_line(form, par_surf);
		dm$status(action = RET_STATUS);

		break;

		case FTEXT_EA:
		case FTEXT_EM:

		status =
		DMsurf_gettxt (form, g_label, par_surf->text_e);
		dm$status(action = RET_STATUS);

		status =
		DMsurf_check_line(form, par_surf);
		dm$status(action = RET_STATUS);

		break;

		case FTEXT_F:

		status =
		DMsurf_gettxt (form, g_label, par_surf->text_f);
		dm$status(action = RET_STATUS);

		status =
		DMsurf_check_line(form, par_surf);
		dm$status(action = RET_STATUS);

	        break;

		case BSYMBOL_1:

		par_surf->basic_sym = SURF_ANGLE;
		break;

		case BSYMBOL_2:

		par_surf->basic_sym = SURF_TRIANGLE;
		break;

		case BSYMBOL_3:

		par_surf->basic_sym = SURF_CIRCLE;
		break;

		case FI_CANCEL:

		*ignore = TRUE;
		status =
		FIg_set_value(form, g_label, 0.0);
		form_sts(status);
	        break;

		case FI_ACCEPT:

		/*|- Erase the Form*/

		status =
		FIg_set_value(form, g_label, 0.0);
		form_sts(status);

		if (edit)
			*update = TRUE;
		else
		{
			*update = FALSE;
			status =
		        FIf_erase(form);
			form_sts(status);
			*form_display = FALSE;
		}
	        break;

		case SYMBOL_POSN:
	
		status =
		FIg_set_value(form, SYMBOL_POSN, 0.0);
		form_sts(status);

		par_surf->sym_posn = !par_surf->sym_posn;
		break;

		case SURF_DIR:

		/*|- Display the sub_form*/

		*update = FALSE;
		status =
		FIf_get_location(form,&posit_x,&posit_y);
		form_sts(status);

		status =
		FIf_set_location(sub_form,posit_x+342,posit_y+109);
		form_sts(status);

		status =
		FIf_display(sub_form);
		form_sts(status);

		break;

		case SURF_FM_LINE:

		mask = 0;

		status =
		FIg_get_attr(form, g_label, &mask);
		form_sts(status);

		if(mask & FI_HILITED)
			par_surf->line_on = TRUE;
		else 	par_surf->line_on = FALSE;

		if (par_surf->line_on)
		{
			status = FIg_unhilite(form, SURF_FM_LINE);
			form_sts(status);
		}
		else
		{
			status = FIg_hilite(form, SURF_FM_LINE);
			form_sts(status);
		}

		break;

		default:
		/*"Unknown Gadget type = %d\n", g_label*/
		break;

		} /* END switch ( g_label ) */
	}/* Notification label*/

	return(OM_S_SUCCESS);
}

IGRint DMsurf_check_line(form, par_surf)
Form form;
struct DMsurf_param *par_surf;
/*.DMsurf_check_line*/
{
	IGRint len1, len2, len3, status;

	len1 = strlen(par_surf->text_d);
	len2 = strlen(par_surf->text_e);
	len3 = strlen(par_surf->text_f);

	if ((len1 > 0) || (len2 > 0) || (len3 > 0))
	{
		par_surf->line_on = TRUE;
		status = FIg_unhilite(form, SURF_FM_LINE);
		form_sts(status);
	}
	else
	{
		par_surf->line_on = FALSE;
		status = FIg_hilite(form, SURF_FM_LINE);
		form_sts(status);

	}

	return(TRUE);
}

IGRint DMsurf_gettxt(fp, g_label, text)
       Form    fp;            /* Pointer to the form     */
       int     g_label;       /* The label of the gadget */
       char  * text;          /* The text contained in the field */
/*.DMsurf_gettxt*/
{
	int status;
	int text_len;
	int field_type;
	int select_flag;
	int row = 0;
	int col = 0;
	int pos = 0;

	/*"label = %d\n", g_label*/

	FIg_get_type ( fp, g_label, &field_type );
	if ( field_type == FI_MULTI_COL )
	{
        	/*|- Get the col for the MCF */

		FImcf_get_active_col ( fp, g_label, &col, &pos );
	}

	/*| Get the row for the field or MCF */

	FIfld_get_active_row ( fp, g_label, &row, &pos );
	FIfld_get_text_length ( fp, g_label, row, col, &text_len );

	text_len++;
	/*"Text len:%d\n",text_len*/
	if (text_len > 30)
	{
		printf(" Text Too large\n");
		return(FALSE);
	}

	/*"row = %d, col = %d, text_len = %d\n", row, col, text_len*/

	status = FIfld_get_text ( fp, g_label, row, col, 30,
                            text, &select_flag, &pos );
	form_sts(status);

	return (TRUE);
}

IGRint DMsurf_settxt(fp, g_label, text)
       Form    fp;            /* Pointer to the form     */
       int     g_label;       /* The label of the gadget */
       char  * text;          /* The text contained in the field */
/*.DMsurf_settxt*/
{
	int status;
	int field_type;
	int row = 0;
	int col = 0;
	int pos = 0;

	/*"label = %d,text = %s\n", g_label,text*/

	FIg_get_type ( fp, g_label, &field_type );
	if ( field_type == FI_MULTI_COL )
	{
        	/*|- Get the col for the MCF */

		FImcf_get_active_col ( fp, g_label, &col, &pos );
	}

	/*| Get the row for the field or MCF */

	FIfld_get_active_row ( fp, g_label, &row, &pos );

	/*"row = %d, col = %d\n", row, col*/

	status = FIfld_set_text ( fp, g_label, row, col, text, FALSE);
	form_sts(status);

	return (TRUE);
}

end implementation COsurf;
