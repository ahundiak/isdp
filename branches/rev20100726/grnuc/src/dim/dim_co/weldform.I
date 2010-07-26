/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:30 $
$Locker:  $
$Log: weldform.I,v $
Revision 1.1.1.1  2001/12/17 22:39:30  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:08:02  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.1  1997/02/21  09:01:38  bsubbaia
# COMMENT : Place weld symbology enhancements
#
# Revision 330.0  1996/01/11  21:22:02  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:51:31  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.0  1992/12/06  23:43:57  tim
# COMMENT : Initial checkin to 2.4 RCS
#
# Revision 220.0  1992/08/29  06:23:19  root
# COMMENT : Corresponds to Rel201.7 in 2.0.1 RCS
#
Revision 201.7  1992/07/19  16:13:33  poo
COMMENT : Inital Checkin of Jogged Dimension fuctionality.

Revision 201.5  1992/02/03  13:00:31  dimdp20
COMMENT : Dimensioning Fixes Release - S. Poovannan - Feb 3 1992

Revision 201.4  1992/01/22  07:35:19  dimdp20
COMMENT : Dimension Fixes Release - S. Poovannan - Jan. 22 1992.

Revision 201.3  92/01/22  06:46:54  dimdp20
COMMENT : Dimension Fixes Release - S. Poovannan - Jan 22 1992.

*/

class implementation COweld;


#include "dimweld.h"
#include "weldform.h"


#define GAD_QUIT	4

DMprocess_weld_form (form_label,label,value,form,subform1,subform2,subform3,
        subform4,toggle_x_section,above_input,form_display,display,edit_cmd,
        save_data,ignore_data,par_weld)
	 int  form_label;
	 int  label;
	 double  value;
	 Form  form;
	 Form  subform1;
	 Form  subform2;
	 Form  subform3;
	 Form  subform4;
	 IGRboolean  toggle_x_section;
	 IGRboolean  *above_input;
	 IGRint  *form_display;
	 IGRboolean  display;
	 IGRboolean  edit_cmd;
	 IGRboolean  *save_data;
	 IGRboolean  *ignore_data;
	 struct DMweld_param  *par_weld;
/*.DMprocess_weld_form*/
{
	IGRint symbol_num, hilite;
	IGRint label1, label2;

	if (edit_cmd)
		*save_data = FALSE;
	else	*save_data = TRUE;

	*ignore_data = FALSE;

	if (!display)
	{
		if (form_label != MAIN_FORM)
		{
			/*|- Process Sub Form */

			switch(form_label)
			{
				case SUB_FORM1:
				/*|- SUB_FORM for Above Weld Symbol*/

				erase_label(form, ABOVE_SYMBOL);
				get_weld_symbol(TRUE, label, &label1, &symbol_num);
				par_weld->atext.weld_symbol = label1;
				set_symbol_index(form,ABOVE_SYMBOL,symbol_num);
				display_label(form, ABOVE_SYMBOL);
				DMcheck_cs(FALSE, FALSE, TRUE, par_weld, form);
				erase_form(subform1);
				break;

				case SUB_FORM2:

				/*|- SUB_FORM for Below Weld Symbol*/

				erase_label(form, BELOW_SYMBOL);
				get_weld_symbol(FALSE, label, &label1, &symbol_num);
				par_weld->btext.weld_symbol = label1;
				set_symbol_index(form,BELOW_SYMBOL,symbol_num);
				display_label(form, BELOW_SYMBOL);
				DMcheck_cs(FALSE, FALSE, TRUE, par_weld, form);
				erase_form(subform2);
				break;

				case SUB_FORM3:

				/*|- Subform for Center Weld Symbol */
	
				erase_label(form, CENTER_SYMBOL);
				if ((label == 11) || (label == 13))
				{
					par_weld->cen_symb = GAD_SYMBOL1_BZ;
					symbol_num = 100;
				}
				else
				{
					par_weld->cen_symb = GAD_SYMBOL2_BZ;
					symbol_num = 56;
				}
				set_symbol_index(form,CENTER_SYMBOL,symbol_num);
				display_label(form, CENTER_SYMBOL);
				erase_form(subform3);
				break;

				case SUB_FORM4:

				/*|- Sub Form for weld shape */
	
				if (*above_input)
				{
					/*|- Input for above symbol*/

					par_weld->atext.weld_type = label;
					label1 = (par_weld->ansi_weld)?ABOVE_B2_SYM:ABOVE_B1_SYM;
					label2 = (par_weld->ansi_weld)?ABOVE_B2_TEXT:ABOVE_B1_TEXT;

					if (label == WL_BLANK)
					{
						erase_label(form, label1);
						display_label(form, label2);
					}
					else
					{
						erase_label(form, label2);
						erase_label(form, label1);

						if (label == WL_FLUSH)
							symbol_num = 22;
						else if (label == WL_CONCAVE)
							symbol_num = 111;
						else	symbol_num = 82;
	
						set_symbol_index(form,label1,symbol_num);
						display_label(form, label1);
					}
				}
				else
				{
					/*|- Input for below symbol*/
	
					par_weld->btext.weld_type = label;
					label1 = (par_weld->ansi_weld)?BELOW_B2_SYM:BELOW_B1_SYM;
					label2 = (par_weld->ansi_weld)?BELOW_B2_TEXT:BELOW_B1_TEXT;

					if (label == WL_BLANK)
					{
						erase_label(form, label1);
						display_label(form, label2);
					}
					else
					{
						erase_label(form, label2);
						erase_label(form, label1);
	
						if (label == WL_FLUSH)
							symbol_num = 22;
						else if (label == WL_CONCAVE)
							symbol_num = 82;
						else	symbol_num = 111;

						set_symbol_index(form,label1,symbol_num);
						display_label(form, label1);
					}
				}
				erase_form(subform4);
				break;

				default:
				/*"process_subform: Invalid subform label =%d\n",form_label*/
				return(OM_E_ABORT);
			}
		}
		else
		{
			/*"Process Main Form: Label = %d\n", label*/
	
			switch(label)
			{

			case ABOVE_BT:
			if (!(edit_cmd && par_weld->cross_section))
			{
				/*"value = %f\n", value*/
				if (!((int)value) && par_weld->below)
					par_weld->above = FALSE;
				else	par_weld->above = TRUE;
				par_weld->center = FALSE;
	
				DMoutput_group_above(form, par_weld);
			}
			else
			{
				set_value_NUMERIC(form, label, (IGRboolean)value);
				*save_data = FALSE;
			}
			break;

			case BELOW_BT:
			if (!(edit_cmd && par_weld->cross_section))
			{
				if (!((int)value) && par_weld->above)
					par_weld->below = FALSE;
				else	par_weld->below = TRUE;
				par_weld->center = FALSE;

				DMoutput_group_below(form, par_weld);
			}
			else
			{
				set_value_NUMERIC(form, label, (IGRboolean)value);
				*save_data = FALSE;
			}
			break;

			case CENTER_BT:
			par_weld->center = TRUE;
			par_weld->above = FALSE;
			par_weld->below = FALSE;
			DMoutput_group_center(form, par_weld);
			break;

			case HGAD_FLAG1:
			case HGAD_FLAG2:
			get_value_HILITE(form, label, &hilite);
			par_weld->flag = hilite;
			set_gadget_HILITE(form, HGAD_FLAG1, hilite);
			set_gadget_HILITE(form, HGAD_FLAG2, hilite);
			display_label(form, HGAD_FLAG1);
			display_label(form, HGAD_FLAG2);
			break;
	
			case HGAD_CIRCLE:
			get_value_HILITE(form, label, &hilite);
			par_weld->circle = hilite;
			set_gadget_HILITE(form, label, hilite);
			display_label(form, label);
			break;

			case HGAD_Z:
			get_value_HILITE(form, label, &hilite);
			par_weld->z_symb = hilite;
			set_gadget_HILITE(form, label, hilite);
			display_label(form, label);
			if (par_weld->z_symb)
			{
				if (par_weld->above)
				display_label(form, ABOVE_ZTEXT);
				if (par_weld->below)
				display_label(form, BELOW_ZTEXT);
			}
			else
			{
				if (par_weld->above)
				erase_label(form, ABOVE_ZTEXT);
				if (par_weld->below)
				erase_label(form, BELOW_ZTEXT);
			}
			break;

			case HGAD_TAIL:
			get_value_HILITE(form, label, &hilite);
			par_weld->tail = hilite;
			set_gadget_HILITE(form, label, hilite);
			display_label(form, label);
			if (par_weld->tail)
				display_label(form, TAIL_TEXT);
			else	erase_label(form, TAIL_TEXT);
			break;

			case ABOVE_FTEXT:
			get_value_ALPHA(form, label, (IGRuchar *)par_weld->atext.ftext);
			display_label(form, label);
			break;

			case ABOVE_RTEXT:
			get_value_ALPHA(form, label, (IGRuchar *)par_weld->atext.rtext);
			display_label(form, label);
			break;

			case ABOVE_ZTEXT:
			get_value_ALPHA(form, label, (IGRuchar *)par_weld->atext.ztext);
			display_label(form, label);
			break;

			case BELOW_FTEXT:
			get_value_ALPHA(form, label, (IGRuchar *)par_weld->btext.ftext);
			display_label(form, label);
			break;

			case BELOW_RTEXT:
			get_value_ALPHA(form, label, (IGRuchar *)par_weld->btext.rtext);
			display_label(form, label);
			break;

			case BELOW_ZTEXT:
			get_value_ALPHA(form, label, (IGRuchar *)par_weld->btext.ztext);
			display_label(form, label);
			break;

			case ABOVE_TEXT1:
			get_value_ALPHA(form, label, (IGRuchar *)par_weld->atext.text1);
			display_label(form, label);
			break;

			case ABOVE_TEXT2:
			get_value_ALPHA(form, label, (IGRuchar *)par_weld->atext.text2);
			display_label(form, label);
			break;

			case ABOVE_TEXT3:
			get_value_ALPHA(form, label, (IGRuchar *)par_weld->atext.text3);
			display_label(form, label);
			break;

			case BELOW_TEXT1:
			get_value_ALPHA(form, label, (IGRuchar *)par_weld->btext.text1);
			display_label(form, label);
			break;

			case BELOW_TEXT2:
			get_value_ALPHA(form, label, (IGRuchar *)par_weld->btext.text2);
			display_label(form, label);
			break;

			case BELOW_TEXT3:
			get_value_ALPHA(form, label, (IGRuchar *)par_weld->btext.text3);
			display_label(form, label);
			break;

			case TAIL_TEXT:
			get_value_ALPHA(form, label, (IGRuchar *)par_weld->tailtext);
			display_label(form, label);
			break;

			case ABOVE_SYMBOL:
			if (!(edit_cmd && par_weld->cross_section))
			   display_weldform(subform1);
			*save_data = FALSE;
			break;
	
			case BELOW_SYMBOL:
			if (!(edit_cmd && par_weld->cross_section))
			   display_weldform(subform2);
			*save_data = FALSE;
			break;

			case CENTER_SYMBOL:
			display_weldform(subform3);
			*save_data = FALSE;
			break;

			case TOGGLE_X_SECTION:

			if (toggle_x_section)
			{
				DMcheck_cs(
					TRUE,
					!par_weld->cross_section,
					TRUE,
					par_weld,
					form);
			}
			else
			{
				DMcheck_cs(FALSE,FALSE,FALSE,par_weld,form);
				*save_data = FALSE;
				return(TRUE);
			}
			break;

			case TOGGLE_DASH_LINE:
			if (par_weld->dash_line == ABOVE)
				par_weld->dash_line = BELOW;
			else	par_weld->dash_line = ABOVE;
                        display_label(form, label); 
			break;
		
			case ABOVE_B1:
			case ABOVE_B2:
			case ABOVE_B1_TEXT:
			case ABOVE_B1_SYM:
			case ABOVE_B2_TEXT:
			case ABOVE_B2_SYM:

			if (!(edit_cmd && par_weld->cross_section))
			   display_weldform(subform4);
			*above_input = TRUE;
			*save_data = FALSE;
			return(TRUE);

			case BELOW_B1:
			case BELOW_B2:
			case BELOW_B1_TEXT:
			case BELOW_B1_SYM:
			case BELOW_B2_TEXT:
			case BELOW_B2_SYM:

			if (!(edit_cmd && par_weld->cross_section))
			   display_weldform(subform4);
			*above_input = FALSE;
			*save_data = FALSE;
			return(TRUE);

			case GAD_CHECK:
			if (edit_cmd)
			{
				*save_data = TRUE;
				set_value_NUMERIC(form, label, FALSE);
			}
			else
			{
				*save_data = FALSE;
				set_value_NUMERIC(form, label, FALSE);
				erase_form(form);
				*form_display = FALSE;
			}
			return(TRUE);

			case GAD_QUIT:

			set_value_NUMERIC(form, label, FALSE);
			*ignore_data = TRUE;
			return(TRUE);

			default:

			/*"DMweld : Invalid Label = %d\n", label*/
			return(TRUE);
			}
		}
	}
	else
	{
		/*|- Display the Weld Form */

		set_gadget_HILITE(form, HGAD_FLAG1, par_weld->flag);
		set_gadget_HILITE(form, HGAD_FLAG2, par_weld->flag);
		set_gadget_HILITE(form, HGAD_CIRCLE, par_weld->circle);
		set_gadget_HILITE(form, HGAD_TAIL, par_weld->tail);
		set_gadget_HILITE(form, HGAD_Z, par_weld->z_symb);

		if (par_weld->center)
                	DMoutput_group_center(form, par_weld);
		else
		{      
			if (par_weld->above)
			DMoutput_group_above(form, par_weld);
			if (par_weld->below)
                        DMoutput_group_below(form, par_weld);
                }
		if (par_weld->tail)
		{
			set_value_ALPHA(form, TAIL_TEXT, (IGRuchar *)par_weld->tailtext);
			display_label(form, TAIL_TEXT);
		}
		else erase_label(form, TAIL_TEXT);

	        if (par_weld->dash_line)
		{        
			/*|- Dash line present */ 
			set_value_NUMERIC(
				form,
				TOGGLE_DASH_LINE,
				(par_weld->dash_line == ABOVE)?TRUE:FALSE);

			display_label(form, TOGGLE_DASH_LINE);
		}
		else	erase_label(form, TOGGLE_DASH_LINE);

		DMcheck_cs(FALSE, FALSE, TRUE, par_weld, form);

		if (!edit_cmd)
		erase_label(form, GAD_QUIT);

		display_weldform(form);
		*form_display = TRUE;
	}
	return(TRUE);
}

DMoutput_group_center (form,par_weld)
	 Form  form;
	 struct DMweld_param  *par_weld;
/*.DMoutput_group_center*/
{
	IGRint symbol_num;

	erase_group(ABOVE_BT, form);
	erase_group(BELOW_BT, form);
        set_value_ALPHA(form, ABOVE_FTEXT, (IGRuchar *)par_weld->atext.ftext);
        display_label(form, ABOVE_FTEXT);
        set_value_ALPHA(form, ABOVE_RTEXT, (IGRuchar *)par_weld->atext.rtext);
        display_label(form, ABOVE_RTEXT);
        set_value_ALPHA(form, BELOW_FTEXT, (IGRuchar *)par_weld->btext.ftext);
        display_label(form, BELOW_FTEXT);
        set_value_ALPHA(form, BELOW_RTEXT, (IGRuchar *)par_weld->btext.rtext);
        display_label(form, BELOW_RTEXT);
	par_weld->cross_section = FALSE;
	erase_label(form, TOGGLE_X_SECTION);
        
	if (par_weld->cen_symb == GAD_SYMBOL1_BZ)
		symbol_num = 100;
	else	symbol_num = 56;

	erase_label(form, CENTER_SYMBOL);
	set_symbol_index(form,CENTER_SYMBOL,symbol_num);
	display_label(form, CENTER_SYMBOL);

	set_value_NUMERIC(form, CENTER_BT, TRUE);

	return(TRUE);
}

DMoutput_group_above (form,par_weld)
	 Form  form;
	 struct DMweld_param  *par_weld;
/*.DMoutput_group_above*/
{
	IGRint symbol_num, label1, label2;

	erase_group(CENTER_BT, form);
	if (!par_weld->below) erase_group(BELOW_BT, form);
	if (!par_weld->above)
	{
		erase_group(ABOVE_BT, form);

		DMcheck_cs(FALSE, FALSE, TRUE, par_weld, form);
		return(TRUE);
	}

	/*|- display all above gadgets */

	set_value_ALPHA(form, ABOVE_FTEXT, (IGRuchar *)par_weld->atext.ftext);
	display_label(form, ABOVE_FTEXT);
	set_value_ALPHA(form, ABOVE_RTEXT, (IGRuchar *)par_weld->atext.rtext);
	display_label(form, ABOVE_RTEXT);
	if (par_weld->z_symb)
	{
		set_value_ALPHA(form, ABOVE_ZTEXT, (IGRuchar *)par_weld->atext.ztext);
		display_label(form, ABOVE_ZTEXT);
	}
	else	erase_label(form, ABOVE_ZTEXT);

	erase_label(form, ABOVE_SYMBOL);
	get_weld_symbol(
		TRUE,
		(IGRint)par_weld->atext.weld_symbol,
		&label1,
		&symbol_num);

	set_symbol_index(form,ABOVE_SYMBOL,symbol_num);
	display_label(form, ABOVE_SYMBOL);

	if (par_weld->ansi_weld)
	{
		/*|- Display Above B2 and related Gadgets */

		set_value_ALPHA(form, ABOVE_TEXT1, (IGRuchar *)par_weld->atext.text1);
		display_label(form, ABOVE_TEXT1);

		set_value_ALPHA(form, ABOVE_TEXT2, (IGRuchar *)par_weld->atext.text2);
		display_label(form, ABOVE_TEXT2);

		set_value_ALPHA(form, ABOVE_TEXT3, (IGRuchar *)par_weld->atext.text3);
		display_label(form, ABOVE_TEXT3);

		display_label(form, ABOVE_B2);
		display_label(form, ABOVE_DOT);
		display_label(form, ABOVE_LINE1);
		display_label(form, ABOVE_LINE2);
		display_label(form, ABOVE_LINE3);
		display_label(form, ABOVE_LINE4);
		display_label(form, ABOVE_LINE5);

		label1 = ABOVE_B2_TEXT;
		label2 = ABOVE_B2_SYM;

		erase_label(form, ABOVE_B1);
		erase_label(form, ABOVE_B1_TEXT);
		erase_label(form, ABOVE_B1_SYM);
	}
	else
	{
		display_label(form, ABOVE_B1);

		label1 = ABOVE_B1_TEXT;
		label2 = ABOVE_B1_SYM;

		erase_label(form, ABOVE_DOT);
		erase_label(form, ABOVE_LINE1);
		erase_label(form, ABOVE_LINE2);
		erase_label(form, ABOVE_LINE3);
		erase_label(form, ABOVE_LINE4);
		erase_label(form, ABOVE_LINE5);
		erase_label(form, ABOVE_TEXT1);
		erase_label(form, ABOVE_TEXT2);
		erase_label(form, ABOVE_TEXT3);
		erase_label(form, ABOVE_B2);
		erase_label(form, ABOVE_B2_TEXT);
		erase_label(form, ABOVE_B2_SYM);
	}

	if (par_weld->atext.weld_type == WL_BLANK)
	{
		erase_label(form, label2);
		display_label(form, label1);
	}
	else
	{
		erase_label(form, label1);
		erase_label(form, label2);

		if (par_weld->atext.weld_type == WL_FLUSH)
			symbol_num = 22;
		else if (par_weld->atext.weld_type == WL_CONCAVE)
			symbol_num = 111;
		else	symbol_num = 82;

		/*"symbol_num = %d\n", symbol_num*/

		set_symbol_index(form,label2,symbol_num);
		display_label(form, label2);
	}

	DMcheck_cs(FALSE, FALSE, TRUE, par_weld, form);

	set_value_NUMERIC(form, ABOVE_BT, TRUE);

	return(TRUE);
}

DMoutput_group_below (form,par_weld)
	 Form  form;
	 struct DMweld_param  *par_weld;
/*.DMoutput_group_below*/
{
	IGRint symbol_num, label1, label2;

	erase_group(CENTER_BT, form);
	if (!par_weld->above) erase_group(ABOVE_BT, form);
	if (!par_weld->below)
	{
		erase_group(BELOW_BT, form);

		DMcheck_cs(FALSE, FALSE, TRUE, par_weld, form);
		return(TRUE);
	}

	/*|- display all below gadgets */

	set_value_ALPHA(form, BELOW_FTEXT, (IGRuchar *)par_weld->btext.ftext);
	display_label(form, BELOW_FTEXT);
	set_value_ALPHA(form, BELOW_RTEXT, (IGRuchar *)par_weld->btext.rtext);
	display_label(form, BELOW_RTEXT);
	if (par_weld->z_symb)
	{
		set_value_ALPHA(form, BELOW_ZTEXT, (IGRuchar *)par_weld->btext.ztext);
		display_label(form, BELOW_ZTEXT);
	}
	else	erase_label(form, BELOW_ZTEXT);

	erase_label(form, BELOW_SYMBOL);
	get_weld_symbol(
		FALSE,
		(IGRint)par_weld->btext.weld_symbol,
		&label1,
		&symbol_num);

	set_symbol_index(form,BELOW_SYMBOL,symbol_num);
	display_label(form, BELOW_SYMBOL);

	if (par_weld->ansi_weld)
	{
		/*|- Display BELOW B2 and related Gadgets */

		set_value_ALPHA(form, BELOW_TEXT1, (IGRuchar *)par_weld->btext.text1);
		display_label(form, BELOW_TEXT1);
	
		set_value_ALPHA(form, BELOW_TEXT2, (IGRuchar *)par_weld->btext.text2);
		display_label(form, BELOW_TEXT2);

		set_value_ALPHA(form, BELOW_TEXT3, (IGRuchar *)par_weld->btext.text3);
		display_label(form, BELOW_TEXT3);

		display_label(form, BELOW_B2);

		label1 = BELOW_B2_TEXT;
		label2 = BELOW_B2_SYM;

		display_label(form, BELOW_DOT);
		display_label(form, BELOW_LINE1);
		display_label(form, BELOW_LINE2);
		display_label(form, BELOW_LINE3);
		display_label(form, BELOW_LINE4);
		display_label(form, BELOW_LINE5);

		erase_label(form, BELOW_B1);
		erase_label(form, BELOW_B1_TEXT);
		erase_label(form, BELOW_B1_SYM);
	}
	else
	{
		display_label(form, BELOW_B1);
		
		label1 = BELOW_B1_TEXT;
		label2 = BELOW_B1_SYM;
	
		erase_label(form, BELOW_DOT);
		erase_label(form, BELOW_LINE1);
		erase_label(form, BELOW_LINE2);
		erase_label(form, BELOW_LINE3);
		erase_label(form, BELOW_LINE4);
		erase_label(form, BELOW_LINE5);
		erase_label(form, BELOW_TEXT1);
		erase_label(form, BELOW_TEXT2);
		erase_label(form, BELOW_TEXT3);
		erase_label(form, BELOW_B2);
		erase_label(form, BELOW_B2_TEXT);
		erase_label(form, BELOW_B2_SYM);
	}

	if (par_weld->btext.weld_type == WL_BLANK)
	{
		erase_label(form, label2);
		display_label(form, label1);
	}
	else
	{
		erase_label(form, label1);
		erase_label(form, label2);

		if (par_weld->btext.weld_type == WL_FLUSH)
			symbol_num = 22;
		else if (par_weld->btext.weld_type == WL_CONCAVE)
			symbol_num = 82;
		else	symbol_num = 111;

		/*"symbol_num = %d\n", symbol_num*/

		set_symbol_index(form,label2,symbol_num);
		display_label(form, label2);
	}

	DMcheck_cs(FALSE, FALSE, TRUE, par_weld, form);

	set_value_NUMERIC(form, BELOW_BT, TRUE);

	return(TRUE);
}

get_value_ALPHA (form,label,weld_str)
	 Form  form;
	 IGRint  label;
	 IGRuchar  *weld_str;
{
	IGRint status;
	IGRuchar string[132];

	status =
	FIg_get_text(form, label, string);
	if (status != FI_SUCCESS)
	{
		printf("FIg_get_text Fails\n");
		return(OM_E_ABORT);
	}

	DMstrncpy((char *)weld_str, (char *)string, 32);
	return(TRUE);
}

set_value_ALPHA (form,label,weld_str)
	 Form  form;
	 IGRint  label;
	 IGRuchar  *weld_str;
{
	IGRint status;

	status =
	FIg_set_text(form, label, weld_str);
	if (status != FI_SUCCESS)
	{
		printf("FIg_set_text Fails\n");
		return(OM_E_ABORT);
	}

	return(TRUE);
}

set_symbol_index (form,label,symbol_num)
	 Form  form;
	 IGRint  label;
	 IGRint  symbol_num;
{
	IGRint status;

	status =
	FIg_set_symbol_index(form, label, symbol_num);
	if (status != FI_SUCCESS)
	{
		printf("FIg_set_symbol_index Fails\n");
		return(OM_E_ABORT);
	}

	return(TRUE);
}

set_value_NUMERIC (form,label,value)
	 Form  form;
	 IGRint  label;
	 IGRboolean  value;
{
	IGRint status;

	if (value)
	{
		status =
		FIg_set_value(form, label, 1.0);
		if (status != FI_SUCCESS)
		{
			printf("FIg_set_value Fails label = %d\n", label);
			return(OM_E_ABORT);
		}
	}
	else
	{
		status =
		FIg_set_value(form, label, 0.0);
		if (status != FI_SUCCESS)
		{
			printf("FIg_set_value Fails label = %d\n", label);
			return(OM_E_ABORT);
		}
	}

	return(TRUE);
}

get_value_HILITE (form,label,value)
	 Form  form;
	 IGRint  label;
	 IGRint  *value;
{
	IGRint status, mask;

	mask = 0;

	status =
	FIg_get_attr(form, label, &mask);
	if (status != FI_SUCCESS)
	{
		printf("FIg_get_attr Fails\n");
		return(OM_E_ABORT);
	}

	if(mask & FI_HILITED)
		*value = TRUE;
	else 	*value = FALSE;

	return(TRUE);
}

set_gadget_HILITE (form,label,value)
	 Form  form;
	 IGRint  label;
	 IGRint  value;
{
	IGRint status;

	if (value)
	{
		status = FIg_unhilite(form, label);
		if (status != FI_SUCCESS)
		{
			printf("FIg_unhilite Fails\n");
			return(OM_E_ABORT);
		}
	}
	else
	{
		status = FIg_hilite(form, label);
		if (status != FI_SUCCESS)
		{
			printf("FIg_hilite Fails\n");
			return(OM_E_ABORT);
		}
	}

	return(TRUE);
}

display_label (form,label)
	 Form  form;
	 IGRint  label;
{
	IGRint status;

	status =
	FIg_display(form, label);
	if (status != FI_SUCCESS)
	{
		printf("FIg_display Fails\n");
		return(OM_E_ABORT);
	}

	return(TRUE);
}

erase_label (form,label)
	 Form  form;
	 IGRint  label;
{
	IGRint status;

	status =
	FIg_erase(form, label);
	if (status != FI_SUCCESS)
	{
		printf("FIg_erase Fails\n");
		return(OM_E_ABORT);
	}

	return(TRUE);
}

get_weld_symbol (above,label,sym_label,symbol_num)
	 IGRboolean  above;
	 IGRint  label;
	 IGRint  *sym_label;
	 IGRint  *symbol_num;
{
	switch(label)
	{
		case GAD_SYMBOL1_BZ:
		case GAD_SYMBOL1_SM:
		case GAD_SYMBOL1_TX:

		*symbol_num = (above)?20:19;
		*sym_label = GAD_SYMBOL1_BZ;
		break;

		case GAD_SYMBOL2_BZ:
		case GAD_SYMBOL2_SM:
		case GAD_SYMBOL2_TX:

		*symbol_num = (above)?53:55;
		*sym_label = GAD_SYMBOL2_BZ;
		break;

		case GAD_SYMBOL3_BZ:
		case GAD_SYMBOL3_SM:
		case GAD_SYMBOL3_TX:

		*symbol_num = (above)?67:66;
		*sym_label = GAD_SYMBOL3_BZ;
		break;

		case GAD_SYMBOL4_BZ:
		case GAD_SYMBOL4_SM:
		case GAD_SYMBOL4_TX:

		*symbol_num = (above)?70:69;
		*sym_label = GAD_SYMBOL4_BZ;
		break;

		case GAD_SYMBOL5_BZ:
		case GAD_SYMBOL5_SM:
		case GAD_SYMBOL5_TX:

		*symbol_num = (above)?73:74;
		*sym_label = GAD_SYMBOL5_BZ;
		break;

		case GAD_SYMBOL6_BZ:
		case GAD_SYMBOL6_SM:
		case GAD_SYMBOL6_TX:

		*symbol_num = (above)?75:76;
		*sym_label = GAD_SYMBOL6_BZ;
		break;

		case GAD_SYMBOL7_BZ:
		case GAD_SYMBOL7_SM:
		case GAD_SYMBOL7_TX:

		*symbol_num = (above)?78:77;
		*sym_label = GAD_SYMBOL7_BZ;
		break;

		case GAD_SYMBOL8_BZ:
		case GAD_SYMBOL8_SM:
		case GAD_SYMBOL8_TX:

		*symbol_num = (above)?80:79;
		*sym_label = GAD_SYMBOL8_BZ;
		break;

		case GAD_SYMBOL9_BZ:
		case GAD_SYMBOL9_SM:
		case GAD_SYMBOL9_TX:

		*symbol_num = (above)?21:21;
		*sym_label = GAD_SYMBOL9_BZ;
		break;

		case GAD_SYMBOL10_BZ:
		case GAD_SYMBOL10_SM:
		case GAD_SYMBOL10_TX:

		*symbol_num = (above)?93:92;
		*sym_label = GAD_SYMBOL10_BZ;
		break;

		case GAD_SYMBOL11_BZ:
		case GAD_SYMBOL11_SM:
		case GAD_SYMBOL11_TX:

		*symbol_num = (above)?95:94;
		*sym_label = GAD_SYMBOL11_BZ;
		break;

		case GAD_SYMBOL12_BZ:
		case GAD_SYMBOL12_SM:
		case GAD_SYMBOL12_TX:

		*symbol_num = (above)?97:96;
		*sym_label = GAD_SYMBOL12_BZ;
		break;

		case GAD_SYMBOL13_BZ:
		case GAD_SYMBOL13_SM:
		case GAD_SYMBOL13_TX:

		*symbol_num = (above)?55:53;
		*sym_label = GAD_SYMBOL13_BZ;
		break;

		case GAD_SYMBOL14_BZ:
		case GAD_SYMBOL14_SM:
		case GAD_SYMBOL14_TX:

		*symbol_num = (above)?99:98;
		*sym_label = GAD_SYMBOL14_BZ;
		break;

		case GAD_SYMBOL15_BZ:
		case GAD_SYMBOL15_SM:
		case GAD_SYMBOL15_TX:

		*symbol_num = (above)?77:78;
		*sym_label = GAD_SYMBOL15_BZ;
		break;

		case GAD_SYMBOL16_BZ:
		case GAD_SYMBOL16_SM:
		case GAD_SYMBOL16_TX:

		*symbol_num = (above)?79:80;
		*sym_label = GAD_SYMBOL16_BZ;
		break;

		case GAD_SYMBOL17_BZ:
		case GAD_SYMBOL17_SM:
		case GAD_SYMBOL17_TX:

		*symbol_num = (above)?100:100;
		*sym_label = GAD_SYMBOL17_BZ;
		break;

		case GAD_SYMBOL18_BZ:
		case GAD_SYMBOL18_SM:
		case GAD_SYMBOL18_TX:

		*symbol_num = (above)?56:56;
		*sym_label = GAD_SYMBOL18_BZ;
		break;

		default:
		/*"get_weld_symbol: Invalid label = %d\n", label*/
		return(TRUE);
	}

	return(TRUE);
}

display_weldform (form)
	 Form  form;
{
	IGRint status;

	if (form)
	{
		status = FIf_display(form);
		if(status != FI_SUCCESS)
		{
			printf("FIf_display fails\n");
			return(OM_E_ABORT);
		}
	}

	return(TRUE);
}

delete_form (form)
	 Form  form;
{
	IGRint status;

	if (form)
	{
		status = FIf_delete(form);
		if (status != FI_SUCCESS)
		{
			printf("FIf_delete fails\n");
			return(OM_E_ABORT);
		}
	}

	return(TRUE);
}

erase_form (form)
	 Form  form;
{
	IGRint status;

	if (form)
	{
		status = FIf_erase(form);
		if(status != FI_SUCCESS)
		{
			printf("FIf_erase fails\n");
			return(OM_E_ABORT);
		}
	}

	return(TRUE);
}

erase_group (grp_num,form)
	 IGRint  grp_num;
	 Form  form;
 /*
IGRint grp_num;
Form form;
 */
{
	if (grp_num == CENTER_BT)
	{
		/*|- Disable Center Gadgets */

		erase_label(form, CENTER_SYMBOL);
		display_label(form, WELD_REF_LINE);
		set_value_NUMERIC(form, CENTER_BT, FALSE);
	}
	else if (grp_num == ABOVE_BT)
	{
		/*|- Disable all Above Gadgets */
		erase_label(form, ABOVE_FTEXT);
		erase_label(form, ABOVE_RTEXT);
		erase_label(form, ABOVE_ZTEXT);
		erase_label(form, ABOVE_SYMBOL);
		erase_label(form, ABOVE_B1);
		erase_label(form, ABOVE_B1_TEXT);
		erase_label(form, ABOVE_B1_SYM);
		erase_label(form, ABOVE_DOT);
		erase_label(form, ABOVE_LINE1);
		erase_label(form, ABOVE_LINE2);
		erase_label(form, ABOVE_LINE3);
		erase_label(form, ABOVE_LINE4);
		erase_label(form, ABOVE_LINE5);
		erase_label(form, ABOVE_B2);
		erase_label(form, ABOVE_B2_TEXT);
		erase_label(form, ABOVE_B2_SYM);
		erase_label(form, ABOVE_TEXT1);
		erase_label(form, ABOVE_TEXT2);
		erase_label(form, ABOVE_TEXT3);

		set_value_NUMERIC(form, ABOVE_BT, FALSE);
	}
	else
	{
		/*|- erase all BELOW gadgets */
		erase_label(form, BELOW_FTEXT);
		erase_label(form, BELOW_RTEXT);
		erase_label(form, BELOW_ZTEXT);
		erase_label(form, BELOW_SYMBOL);
		erase_label(form, BELOW_B1);
		erase_label(form, BELOW_B1_TEXT);
		erase_label(form, BELOW_B1_SYM);
		erase_label(form, BELOW_DOT);
		erase_label(form, BELOW_LINE1);
		erase_label(form, BELOW_LINE2);
		erase_label(form, BELOW_LINE3);
		erase_label(form, BELOW_LINE4);
		erase_label(form, BELOW_LINE5);
		erase_label(form, BELOW_B2);
		erase_label(form, BELOW_B2_TEXT);
		erase_label(form, BELOW_B2_SYM);
		erase_label(form, BELOW_TEXT1);		
		erase_label(form, BELOW_TEXT2);
		erase_label(form, BELOW_TEXT3);

		set_value_NUMERIC(form, BELOW_BT, FALSE);
	}

	return(TRUE);
}

DMcheck_cs (set,set_value,check,par_weld,form)
	 IGRboolean  set;
	 IGRboolean  set_value;
	 IGRboolean  check;
	 struct DMweld_param  *par_weld;
	 Form  form;
/*.DMcheck_cs*/
{
	IGRboolean x_section;

	x_section = TRUE;

	if (set) par_weld->cross_section = set_value;

	if (check && !(set && !set_value))
	{
		if (!par_weld->proj_method || par_weld->center)
			x_section = FALSE;
		else if (par_weld->above && par_weld->below)
		{
			int above_symbol, below_symbol;

			above_symbol = par_weld->atext.weld_symbol;
			below_symbol = par_weld->btext.weld_symbol;

			if (above_symbol == below_symbol)
			{
				if (above_symbol == VWELD)
				{
					if (par_weld->cross_section)
					par_weld->cross_section = VWELD_CS;
				}
				else if (below_symbol == BEVEL)
				{
					if (par_weld->cross_section)
					par_weld->cross_section = BEVEL_CS;
				}
				else	x_section = FALSE;
			}
			else	x_section = FALSE;
		}
		else
		{
			int symbol;

			if (par_weld->above)
			   symbol = par_weld->atext.weld_symbol;
			else if (par_weld->below)
			   symbol = par_weld->btext.weld_symbol;
			else	symbol = 0;

			if (symbol == VWELD)
			{
				if (par_weld->cross_section)
				    par_weld->cross_section = VWELD_CS;
			}
			else if (symbol == BEVEL)
			{
				if (par_weld->cross_section)
				    par_weld->cross_section = BEVEL_CS;
			}
			else if (symbol == FILLET)
			{
				if (par_weld->cross_section)
				    par_weld->cross_section = FILLET_CS;
			}
			else	x_section = FALSE;
		}
	}

	if (!x_section)
	{
		par_weld->cross_section = FALSE;
		erase_label(form, TOGGLE_X_SECTION);
		return(TRUE);
	}

	if (par_weld->cross_section)
		set_value_NUMERIC(form, TOGGLE_X_SECTION, TRUE);
	else	set_value_NUMERIC(form, TOGGLE_X_SECTION, FALSE);

	display_label(form, TOGGLE_X_SECTION);

	return(TRUE);
}

end implementation COweld;
