
#include "FImin.h"
#include "FIscroll.h"
#include "FIbtn.h"
#include "FIfield.h"
#include "FImcf.h"

#include "FEI.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

static char _FI_pass_buffer[FI_DATA_LEN];


int _FI_g_receive_data (struct FIgadget_obj  *gadget,
                        double                value)
{
  struct FIform_obj *form = gadget->FIgadget.form;
  struct FImcf_obj *mcf = NULL;
  struct FIfld_obj *field = NULL;

  int		receive_type = gadget->FIgadget.type;
  int		label = gadget->FIgadget.label;
  int		col = 0;
  int		wasDisplayable;


  if ( *_FI_pass_buffer )
    {
      value = atof ( _FI_pass_buffer );
    }

	/* This is where a gadget receives data from another gadget */

  switch ( receive_type )
    {
      case FI_GROUP:
	_FI_grp_pass_on_id_int_always ( gadget,
					 _FI_g_receive_data, 0, 0 );
	break;

      case FI_MULTI_COL:
	mcf = (struct FImcf_obj *) gadget;
	col = mcf->FIgroup.current_active_gadget;
	field = (struct FIfld_obj *) mcf->FIgroup.gadgets[col];

      case FI_FIELD:
	if ( ! mcf )
	  {
	    field = (struct FIfld_obj *) gadget;
	  }

	if ( field->FIfield.field_type == FI_ALPHA )
	  {
	    FIfld_set_text ( (Form)form, label, field->FIfield.ar, col,
						 _FI_pass_buffer, 0 );
	  }
	else
	  {
	    FIfld_set_value ( (Form)form, label, field->FIfield.ar, col,
						 value, 0 );
	  }
	break;

      case FI_TEXT:

	wasDisplayable = IT_IS_DISPLAYABLE ( gadget );

	_FI_g_erase ( gadget );

	FIg_set_off_text ( (Form)form, label, _FI_pass_buffer );

	if ( wasDisplayable )
	  {
            _FI_g_set_displayable (gadget);   /* GMD 3/23/92 */
	    _FI_g_display ( gadget, XWINDOW ( gadget ));
	  }
	break;

      case FI_SLIDER:
	_FI_sld_set_value ( (struct FIsld_obj *)gadget, value );
	break;

      case FI_DIAL:
	_FI_dial_set_value ( (struct FIdial_obj *)gadget, value );
	break;

      case FI_GAUGE:
	_FI_gauge_set_value ( (struct FIgauge_obj *)gadget, value );
	break;

      case FI_SCROLL:
	_FI_scrl_set_value ( (struct FIscrl_obj *)gadget, value );
	break;

      case FI_TOGGLE:	/** state gadgets **/
      case FI_BUTTON:
      case FI_CHECKLIST:
	_FI_g_set_state ( gadget, value );
	break;
    }
  return ( FI_SUCCESS );
}


void _FI_g_pass_data (struct FIgadget_obj *gadget)
{
  struct FIform_obj *form	= gadget->FIgadget.form;
  struct FImcf_obj  *mcf	= NULL;
  struct FIfld_obj  *field	= NULL;
  int		col = 0, sel, pos;

  /** This prevent infinite recursion for gadgets in a loop **/

  if ( gadget->FIgadget.just_received_passed_data )
    {
      return;
    }

  gadget->FIgadget.just_received_passed_data = 1; /** Turn off later **/

  if ( gadget->FIgadget.pass_label > -1 )
    {
      struct FIgadget_obj *pass_gadget = _FI_g_get_id ( form,
					 gadget->FIgadget.pass_label );

	/* Let the gadget receive the data */

      if ( pass_gadget )
	{
	  *_FI_pass_buffer = '\0';

		/* Format data that will be received by gadget */

	  switch ( gadget->FIgadget.type )
	    {
	      case FI_MULTI_COL:
		mcf = (struct FImcf_obj *) gadget;
		col = mcf->FIgroup.current_active_gadget;
		field = (struct FIfld_obj *) mcf->FIgroup.gadgets[col];

	      case FI_FIELD:
		if ( ! mcf )
		  {
		    field = (struct FIfld_obj *) gadget;
		  }

		FIfld_get_text ( (Form)form, gadget->FIgadget.label,
				 field->FIfield.ar, col, FI_DATA_LEN,
				 (unsigned char *)_FI_pass_buffer, &sel, &pos );
		break;


	      case FI_TEXT:
		strncpy ( _FI_pass_buffer, (char *) gadget->FIgadget.text,
							 FI_DATA_LEN );
		_FI_pass_buffer[FI_DATA_LEN - 1]= '\0';
		break;

	      default:
		switch ( pass_gadget->FIgadget.type )
		  {
		    case FI_FIELD:
		    case FI_TEXT:
		    case FI_MULTI_COL:
		      _FI_format_string ( gadget, _FI_pass_buffer,
					 gadget->FIgadget.value );
		  }
	    }

	/*** Sanity check:  don't set the value if the gadget	***/
	/*** is masked.  ( Don't want to reset the gadget that	***/
	/*** is being tracked. )				***/

  	  if ( ! pass_gadget->FIgadget.just_received_passed_data )
	    {
	      _FI_g_receive_data ( pass_gadget,
					 gadget->FIgadget.value );
	    }
	}
    }

  gadget->FIgadget.just_received_passed_data = 0;
}
