/* $Id: weldform.I,v 1.1.1.1 2001/01/04 21:09:33 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdweld/cmd/weldform.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: weldform.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/12/09  16:22:18  pinnacle
# Replaced: vdweld/cmd/*.[IS] for:  by impd for vds
#
# Revision 1.2  1997/11/21  19:22:12  pinnacle
# Replaced: vdweld/cmd/weldform.I for:  by impd for vds
#
# Revision 1.1  1997/11/21  17:08:36  pinnacle
# Created: vdweld/cmd/weldform.I by impd for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	11/21/97	  HF		Override at VDS level of some COweld methods :
 *						init, execute, LC_selection
 *					Cooperates with file $VDS/config/weld_symbols in order
 *					to make placement of Welding Symbols user customizable
 *					The functions	VDprocess_weld_form
 *							VDoutput_group_above
 *							VDoutput_group_below
 *							VDget_weld_symbol
 *					replace the correseponding functions
 *							DMprocess_weld_form
 *							DMoutput_group_above
 *							DMoutput_group_below
 *							DMget_weld_symbol
 * -------------------------------------------------------------------*/

class implementation COweld;

#include "dimweld.h"
#include "weldform.h"

#define GAD_QUIT	4

#define	VD_DEBUG
#include	<VDdebug.h>

#include "VDweldsym.h"

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static Form	subfrm1, subfrm2;

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
extern struct VDweld_gadget_sym		sym_char[];

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static int	VDget_indx_offset ( int idx )
{
  int i0, sts = 0;

  __enterFunction ( name = ">>>>>>>>>> VDget_indx_offset", argfmt = "bezel : index  = %d", args = `idx` );

  for ( i0=0; i0 < MAX_WLD_SYM_SZ; i0++ )
  {
    if ( (int) sym_char [i0].bezel == (int) idx )
    {
      sts = (int)sym_char[i0].symbol;
      break;
    }
  }
  __exitFunction ( name = "<<<<<<<<<< VDget_indx_offset", argfmt = "bezel : symbol = %d", args = `sts` );
  return (sts);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static int     VDget_wld_symbol_data ( IGRint up_lw, IGRint label, IGRint *label1, IGRint *symbol_num )
{
  int	i0, sts = 0;
    
  __enterFunction ( name = ">>>>>>>>>> VDget_wld_symbol_data", argfmt = "up_lw = %d, label = %d", args = `up_lw, label` );

  for ( i0=0; i0 < (int)sym_char[0].fill ; i0++ )
  {
    if ( (int) sym_char[i0].symbol == (int) label )
    {
      *label1     = (int)sym_char[i0].bezel;		// Bezel_gadget_# corr. to "label" ( <<== Symbol_gadget_# )
      *symbol_num = (int)sym_char[i0].snr[up_lw];
      sts = 1;

      break;
    }
  }
    
  __exitFunction ( name = "<<<<<<<<<< VDget_wld_symbol_data",
		   argfmt = "sts = %d,bezel = %d, symbol = %d", args = `sts, *label1, *symbol_num` );
  return (sts);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDprocess_weld_form (form_label,label,value,form,subform1,subform2,subform3,subform4,
			 toggle_x_section,above_input,form_display,display,edit_cmd,
			 save_data,ignore_data,par_weld)
	 int			 form_label;
	 int			 label;
	 IGRdouble value;
	 Form			 form;
	 Form			 subform1;
	 Form			 subform2;
	 Form			 subform3;
	 Form			 subform4;
	 IGRboolean		 toggle_x_section;
	 IGRboolean		*above_input;
	 IGRint			*form_display;
	 IGRboolean		 display;
	 IGRboolean		 edit_cmd;
	 IGRboolean		*save_data;
	 IGRboolean		*ignore_data;
	 struct DMweld_param	*par_weld;
{
  IGRint symbol_num, hilite;
  IGRint label1, label2;
    
  __enterFunction ( name = "VDprocess_weld_form", argfmt = "form_label = %d, label = %d", args = `form_label,label` );

  if (edit_cmd)
        *save_data = FALSE;
  else	*save_data = TRUE;

  *ignore_data = FALSE;
	
  subfrm1 = subform1;
  subfrm2 = subform2;

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
	if ( VDS_is_active_environment )
	{
	  VDget_weld_symbol(subform1, 0, label, &label1, &symbol_num);
	}
	else
	{
	  get_weld_symbol(TRUE, label, &label1, &symbol_num);
	}
	par_weld->atext.weld_symbol = label1;
	set_symbol_index(form,ABOVE_SYMBOL,symbol_num);
	display_label(form, ABOVE_SYMBOL);
	DMcheck_cs(FALSE, FALSE, TRUE, par_weld, form);
	erase_form(subform1);
	break;

      case SUB_FORM2:

	/*|- SUB_FORM for Below Weld Symbol*/

	erase_label(form, BELOW_SYMBOL);

	if ( VDS_is_active_environment )
	{
	  VDget_weld_symbol(subform2, 1, label, &label1, &symbol_num);
	}
	else
	{
	  get_weld_symbol(FALSE, label, &label1, &symbol_num);
	}

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
	{
	  __exitFunction ( name = "VDprocess_weld_form", argfmt = "switch(form_label) default:" );
	  /*"process_subform: Invalid subform label =%d\n",form_label*/
	  return(OM_E_ABORT);
	}
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
	
	  VDoutput_group_above(form, par_weld);
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

	  VDoutput_group_below(form, par_weld);
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
	  goto quit;
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
	goto quit;

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
	goto quit;

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
	goto quit;

      case GAD_QUIT:

	set_value_NUMERIC(form, label, FALSE);
	*ignore_data = TRUE;
	goto quit;

      default:

	/*"DMweld : Invalid Label = %d\n", label*/
	goto quit;
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

    if (par_weld->center)	DMoutput_group_center(form, par_weld);
    else
    {      
      if (par_weld->above)	VDoutput_group_above(form, par_weld);
      if (par_weld->below)	VDoutput_group_below(form, par_weld);
    }
    if (par_weld->tail)
    {
      set_value_ALPHA(form, TAIL_TEXT, (IGRuchar *)par_weld->tailtext);
      display_label  (form, TAIL_TEXT);
    }
    else erase_label(form, TAIL_TEXT);

    if (par_weld->dash_line)
    {        
      /*|- Dash line present */ 
      set_value_NUMERIC(
			form,
			TOGGLE_DASH_LINE,
			(par_weld->dash_line == ABOVE)?TRUE:FALSE);
    }
    else
    {
      erase_label(form, TOGGLE_DASH_LINE);
    }
    
    DMcheck_cs(FALSE, FALSE, TRUE, par_weld, form);

    if (!edit_cmd)
      erase_label(form, GAD_QUIT);

    display_weldform(form);
    *form_display = TRUE;
  }
quit:    
  __exitFunction ( name = "VDprocess_weld_form" );
  return(TRUE);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDoutput_group_above (form,par_weld)
	 Form  form;
	 struct DMweld_param  *par_weld;
{
  IGRint symbol_num, label1, label2;

  char	frm_name[80];
  int	sts;
    
  __enterFunction ( name = "VDoutput_group_above" );

  sts = FIf_get_name ( subfrm1, frm_name );
  __printf ( "Form_name = <%s>", frm_name );

  erase_group(CENTER_BT, form);
  if (!par_weld->below) erase_group(BELOW_BT, form);
  if (!par_weld->above)
  {
    erase_group(ABOVE_BT, form);

    DMcheck_cs(FALSE, FALSE, TRUE, par_weld, form);

    __exitFunction ( name = "VDoutput_group_above" );
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

  if ( VDS_is_active_environment )
  {
    VDget_weld_symbol (	subfrm1, 0,
			//(IGRint)par_weld->atext.weld_symbol,
			VDget_indx_offset ( (IGRint)par_weld->atext.weld_symbol ),
			&label1,
			&symbol_num);
  }
  else
  {
    get_weld_symbol (	TRUE,
			(IGRint)par_weld->atext.weld_symbol,
			&label1,
			&symbol_num);
  }

  __printf ( "label1 = %d, symbol_num = %d", `label1, symbol_num` );

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

  __exitFunction ( name = "VDoutput_group_above" );

  return(TRUE);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDoutput_group_below (form,par_weld)
	 Form  form;
	 struct DMweld_param  *par_weld;
{
  IGRint symbol_num, label1, label2;

  char	frm_name[80];
  int	sts;
    
  __enterFunction ( name = "VDoutput_group_below" );

  sts = FIf_get_name ( subfrm2, frm_name );
  __printf ( "Form_name = <%s>", frm_name );

  erase_group(CENTER_BT, form);
  if (!par_weld->above) erase_group(ABOVE_BT, form);
  if (!par_weld->below)
  {
    erase_group(BELOW_BT, form);

    DMcheck_cs(FALSE, FALSE, TRUE, par_weld, form);

    __exitFunction ( name = "VDoutput_group_below" );
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

  if ( VDS_is_active_environment )
  {
    VDget_weld_symbol (	subfrm2, 1,
			//(IGRint)par_weld->btext.weld_symbol,
			VDget_indx_offset ( (IGRint)par_weld->btext.weld_symbol ),
			&label1,
			&symbol_num);
  }
  else
  {
    get_weld_symbol (	FALSE,
			(IGRint)par_weld->btext.weld_symbol,
			&label1,
			&symbol_num);
  }

  __printf ( "label1 = %d, symbol_num = %d", `label1, symbol_num` );

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

  __exitFunction ( name = "VDoutput_group_below" );

  return(TRUE);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDget_weld_symbol (form, up_lw, label, sym_label,symbol_num)
	 Form	 form;
	 IGRint  label, up_lw;
	 IGRint  *sym_label;
	 IGRint  *symbol_num;
{
  char	frm_name[80];
  int	sts;
    
  __enterFunction ( name = "VDget_weld_symbol" );

  sts = FIf_get_name ( form, frm_name );
  __printf ( "Form_name = <%s>, label = %d", `frm_name, label` );

  if ( sym_char[0].fill > 0 )
  {
    sts = VDget_wld_symbol_data( up_lw, label, sym_label, symbol_num );
    if (sts) goto quit;
  }

  /*
   * DEFAULT PROCESSING IN CASE THE FILE "$VDS/config/weld_symbols" DOES NOT EXIST
   */
  switch(label)
  {
  case GAD_SYMBOL1_BZ:
  case GAD_SYMBOL1_SM:
  case GAD_SYMBOL1_TX:
    {
      //*symbol_num = (above)?20:19;
      *sym_label  = GAD_SYMBOL1_BZ;
      FIg_get_symbol_index ( form, label, symbol_num );
      break;
    }
  case GAD_SYMBOL2_BZ:
  case GAD_SYMBOL2_SM:
  case GAD_SYMBOL2_TX:
    {
      //*symbol_num = (above)?53:55;
      *sym_label = GAD_SYMBOL2_BZ;
      FIg_get_symbol_index ( form, label, symbol_num );
      break;
    }
  case GAD_SYMBOL3_BZ:
  case GAD_SYMBOL3_SM:
  case GAD_SYMBOL3_TX:
    {
      //*symbol_num = (above)?67:66;
      *sym_label = GAD_SYMBOL3_BZ;
      FIg_get_symbol_index ( form, label, symbol_num );
      break;
    }
  case GAD_SYMBOL4_BZ:
  case GAD_SYMBOL4_SM:
  case GAD_SYMBOL4_TX:
    {
      //*symbol_num = (above)?70:69;
      *sym_label = GAD_SYMBOL4_BZ;
      FIg_get_symbol_index ( form, label, symbol_num );
      break;
    }
  case GAD_SYMBOL5_BZ:
  case GAD_SYMBOL5_SM:
  case GAD_SYMBOL5_TX:
    {
      //*symbol_num = (above)?73:74;
      *sym_label = GAD_SYMBOL5_BZ;
      FIg_get_symbol_index ( form, label, symbol_num );
      break;
    }
  case GAD_SYMBOL6_BZ:
  case GAD_SYMBOL6_SM:
  case GAD_SYMBOL6_TX:
    {
      //*symbol_num = (above)?75:76;
      *sym_label = GAD_SYMBOL6_BZ;
      FIg_get_symbol_index ( form, label, symbol_num );
      break;
    }
  case GAD_SYMBOL7_BZ:
  case GAD_SYMBOL7_SM:
  case GAD_SYMBOL7_TX:
    {
      //*symbol_num = (above)?78:77;
      *sym_label = GAD_SYMBOL7_BZ;
      FIg_get_symbol_index ( form, label, symbol_num );
      break;
    }
  case GAD_SYMBOL8_BZ:
  case GAD_SYMBOL8_SM:
  case GAD_SYMBOL8_TX:
    {
      //*symbol_num = (above)?80:79;
      *sym_label = GAD_SYMBOL8_BZ;
      FIg_get_symbol_index ( form, label, symbol_num );
      break;
    }
  case GAD_SYMBOL9_BZ:
  case GAD_SYMBOL9_SM:
  case GAD_SYMBOL9_TX:
    {
      //*symbol_num = (above)?21:21;
      *sym_label = GAD_SYMBOL9_BZ;
      FIg_get_symbol_index ( form, label, symbol_num );
      break;
    }
  case GAD_SYMBOL10_BZ:
  case GAD_SYMBOL10_SM:
  case GAD_SYMBOL10_TX:
    {
      //*symbol_num = (above)?93:92;
      *sym_label = GAD_SYMBOL10_BZ;
      FIg_get_symbol_index ( form, label, symbol_num );
      break;
    }
  case GAD_SYMBOL11_BZ:
  case GAD_SYMBOL11_SM:
  case GAD_SYMBOL11_TX:
    {
      //*symbol_num = (above)?95:94;
      *sym_label = GAD_SYMBOL11_BZ;
      FIg_get_symbol_index ( form, label, symbol_num );
      break;
    }
  case GAD_SYMBOL12_BZ:
  case GAD_SYMBOL12_SM:
  case GAD_SYMBOL12_TX:
    {
      //*symbol_num = (above)?97:96;
      *sym_label = GAD_SYMBOL12_BZ;
      FIg_get_symbol_index ( form, label, symbol_num );
      break;
    }
  case GAD_SYMBOL13_BZ:
  case GAD_SYMBOL13_SM:
  case GAD_SYMBOL13_TX:
    {
      //*symbol_num = (above)?55:53;
      *sym_label = GAD_SYMBOL13_BZ;
      FIg_get_symbol_index ( form, label, symbol_num );
      break;
    }
  case GAD_SYMBOL14_BZ:
  case GAD_SYMBOL14_SM:
  case GAD_SYMBOL14_TX:
    {
      //*symbol_num = (above)?99:98;
      *sym_label = GAD_SYMBOL14_BZ;
      FIg_get_symbol_index ( form, label, symbol_num );
      break;
    }
  case GAD_SYMBOL15_BZ:
  case GAD_SYMBOL15_SM:
  case GAD_SYMBOL15_TX:
    {
      //*symbol_num = (above)?77:78;
      *sym_label = GAD_SYMBOL15_BZ;
      FIg_get_symbol_index ( form, label, symbol_num );
      break;
    }
  case GAD_SYMBOL16_BZ:
  case GAD_SYMBOL16_SM:
  case GAD_SYMBOL16_TX:
    {
      //*symbol_num = (above)?79:80;
      *sym_label = GAD_SYMBOL16_BZ;
      FIg_get_symbol_index ( form, label, symbol_num );
      break;
    }
  case GAD_SYMBOL17_BZ:
  case GAD_SYMBOL17_SM:
  case GAD_SYMBOL17_TX:
    {
      //*symbol_num = (above)?100:100;
      *sym_label = GAD_SYMBOL17_BZ;
      FIg_get_symbol_index ( form, label, symbol_num );
      break;
    }
  case GAD_SYMBOL18_BZ:
  case GAD_SYMBOL18_SM:
  case GAD_SYMBOL18_TX:
    {
      //*symbol_num = (above)?56:56;
      *sym_label = GAD_SYMBOL18_BZ;
      FIg_get_symbol_index ( form, label, symbol_num );
      break;
    }
  default:
    {
      /*"get_weld_symbol: Invalid label = %d\n", label*/
      break;
    }
  }

quit:
  
  __exitFunction ( name = "VDget_weld_symbol" );

  return(TRUE);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

end implementation COweld;
