#include "FImin.h"

#include <math.h>
#include <values.h>   /* dmb:09/29/92: Added for M_PI in ANSI */
#include "FIdial.h"
#include "FIgraphic.h"
#include "FIrect.h"
#include "FIline.h"
#include "FIslider.h"
#include "FIgauge.h"
#include "FIscroll.h"
#include "FIbtn.h"
#include "FIfield.h"
#include "FImacros.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

int FIg_call_notification_routine (Form  form,
                                   int   label)
{
  struct FIform_obj   * form_ptr = (struct FIform_obj *) form;
  struct FIgadget_obj * gadget;

  gadget = _FI_g_get_id ( form_ptr, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( gadget->FIgadget.type == FI_GROUP )
    {
      _FI_grp_pass_on_int ( gadget, FIg_call_notification_routine,
								0, 0 );
    }
  else
    {
      int value = gadget->FIgadget.value;

	/************************************************/
	/* If the gadget is a field, then set the	*/
	/* value to be the active row of the field.	*/
	/************************************************/

      if (( gadget->FIgadget.type == FI_FIELD ) ||
		  ( gadget->FIgadget.type == FI_MULTI_COL ))
		  /* sml:07-06-93 MCF checked added for RAP (Doree Murray) */
	{
	  int row, pos;

	  FIfld_get_active_row ( form, label, &row, &pos );
	  value = row;
	}

      if ( form_ptr->notification_routine )
	{
					/*** JAJ:01/20/92 ***/
	  _FI_notification_type = FI_CALL_NOTIFICATION;

	  /********************************************************/
	  /*** Record notification before DOING it JAJ 08/30/90 ***/
	  /********************************************************/

	  if ( _FI_record_notification_routine )
	    {
	      _FI_record_notification_routine ( form_ptr->form_label,
			gadget->FIgadget.label,
			(double) value, form	);
	    }

	  form_ptr->notification_routine ( form_ptr->form_label,
			gadget->FIgadget.label,
			(double) value, form	);

		/************************************************/
		/* Make sure form and/or gadget were not	*/
		/* deleted by the form's notification routine.	*/
		/************************************************/

	  /* This is the last thing in the function, 		*/
	  /* so don't bother doing it.				*/
	  /*******************************************************
	  status = FIg_is_valid ( form, label );

	  if ( status != FI_SUCCESS )
	    {
	      return ( FI_SUCCESS );
	    }
	  *******************************************************/
	}
    }

  return ( FI_SUCCESS );
}



int FIdial_set_range (Form    form,
                      int     label,
                      double  range)
{
  struct FIdial_obj *dial;

  dial = (struct FIdial_obj *) _FI_g_get_id (
				(struct FIform_obj *) form, label );

  if ( ! dial )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( dial->FIgadget.type != FI_DIAL )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  dial->FIdial.scale = range / TWO_PI ;

  return ( FI_SUCCESS );
}



int FIdial_get_range (Form    form,
                      int     label,
                      float  *range)
{
  struct FIdial_obj *dial;

  dial = (struct FIdial_obj *) _FI_g_get_id (
				(struct FIform_obj *) form, label );

  if ( ! dial )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( dial->FIgadget.type != FI_DIAL )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  *range = (float) dial->FIdial.scale * TWO_PI;

  return ( FI_SUCCESS );
}


/*  double zero;  *** degrees, CCW rotation ***/

int FIdial_set_zero_location (Form    form,
                              int     label,
                              double  zero)
{
  struct FIdial_obj *dial;

  dial = (struct FIdial_obj *) _FI_g_get_id (
				(struct FIform_obj *) form, label );
  if ( ! dial )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( dial->FIgadget.type != FI_DIAL )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  dial->FIdial.offset = (float) ( zero / ( (double) 360.0 / TWO_PI ) );


  _FI_g_activate ( (struct FIgadget_obj *) dial ); /** JAJ:08/26/91 ***/

                                                /*** JAJ:08/26/91 ***/
  if ( ( IT_IS_DISPLAYED ( dial )) && ( XWINDOW ( dial ) != None ) )
    {
      _FI_g_display ( (struct FIgadget_obj *) dial, XWINDOW ( dial ) );
    }

  return ( FI_SUCCESS );
}



int FIdial_get_zero_location (Form    form,
                              int     label,
                              float  *zero)
{
  struct FIdial_obj *dial;

  dial = (struct FIdial_obj *) _FI_g_get_id (
				(struct FIform_obj *) form, label );
  if ( ! dial )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( dial->FIgadget.type != FI_DIAL )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  *zero = dial->FIdial.offset * ( (double) 360.0 / TWO_PI );

  return ( FI_SUCCESS );
}



int FIrect_set_style (Form  form,
                      int   label,
                      int   style)
{
  struct FIrect_obj *rect;

  rect = (struct FIrect_obj *) _FI_g_get_id (
				(struct FIform_obj *) form, label );
  if ( ! rect )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( rect->FIgadget.type != FI_RECT )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  rect->FIgadget.effect = style;

  return ( FI_SUCCESS );

}



int FIrect_get_style (Form  form,
                      int   label,
                      int  *style)
{
  struct FIrect_obj *rect;

  rect = (struct FIrect_obj *) _FI_g_get_id (
				(struct FIform_obj *) form, label );
  if ( ! rect )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( rect->FIgadget.type != FI_RECT )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  *style = rect->FIgadget.effect;

  return ( FI_SUCCESS );
}



int FIdial_set_border_style (Form  form,
                             int   label,
                             int   border_style)
{
  struct FIdial_obj *dial;

  dial = (struct FIdial_obj *) _FI_g_get_id (
				(struct FIform_obj *) form, label );
  if ( ! dial )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( dial->FIgadget.type != FI_DIAL )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  dial->FIdial.border_style = border_style;

  return ( FI_SUCCESS );
}



int FIdial_get_border_style (Form  form,
                             int   label,
                             int  *border_style)
{
  struct FIdial_obj *dial;

  dial = (struct FIdial_obj *) _FI_g_get_id (
				(struct FIform_obj *) form, label );
  if ( ! dial )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( dial->FIgadget.type != FI_DIAL )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  *border_style = dial->FIdial.border_style;

  return ( FI_SUCCESS );
}


/*****************************************************************/
/* FIg_add_to_group() adds the gadget to the specified group	 */
/*   removing it from its current group.			 */
/* If this function is invoked on a group gadget, the members of */
/* the group are added to the new group and removed from that	 */
/* group.							 */
/*								 */
/* NOTE: DO NOT call this from FIg_new();			 */
/*	call _FI_g_add_to_group() instead.			 */
/*****************************************************************/

int FIg_add_to_group (Form  form,
                      int   gadget_label,
                      int   group_label)
{
  struct FIgadget_obj *gadget;

  /*** get the gadget's id ***/

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, gadget_label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  return ( _FI_g_add_to_group ( gadget, group_label, 0 ) );
}



int FIg_set_erase_color (Form  form,
                         int   label,
                         int   color)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  switch ( gadget->FIgadget.type )
    {
      case FI_GROUP:
	_FI_grp_pass_on_int ( gadget, FIg_set_erase_color, color, 0 );
	break;

	/******* Moot due to new scrl_erase routine ************
        case FI_SCROLL:
	  _FI_scrl_set_erase_color( gadget, color );
	  break;
	***************************************************/

      case FI_FIELD:
	_FI_fld_set_erase_color ( (struct FIfld_obj *)gadget, color );
	break;

      case FI_MULTI_COL:
	_FI_mcf_set_erase_color ( (struct FImcf_obj *)gadget, color );
	break;

      default:
	gadget->FIgadget.erase_color = color;
	break;
    }

  return ( FI_SUCCESS );
}



int FIg_get_erase_color (Form  form,
                         int   label,
                         int  *erase_color)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  *erase_color = gadget->FIgadget.erase_color;

  return ( FI_SUCCESS );
}



int FIg_set_orientation (Form  form,
                         int   label,
                         int   orientation)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  switch ( gadget->FIgadget.type )
    {
      case FI_SLIDER:
	((struct FIsld_obj *) gadget )->FIslider.type = orientation;
	break;

      case FI_DIAL:
	((struct FIdial_obj *) gadget )->FIdial.direction = orientation;
	break;

      case FI_GAUGE:
	((struct FIgauge_obj *) gadget )->FIgauge.type = orientation;
	break;

      case FI_GROUP:
	_FI_grp_pass_on_int ( gadget, FIg_set_orientation,
						orientation, 0 );
	break;

      case FI_SCROLL:
	((struct FIscrl_obj *) gadget )->FIscroll.type = orientation;
	break;

      default:
	return ( FI_INVALID_GADGET_TYPE );
    }

  return ( FI_SUCCESS );
}



int FIg_get_orientation (Form  form,
                         int   label,
                         int  *orientation)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  switch ( gadget->FIgadget.type )
    {
      case FI_SLIDER:
	*orientation = ((struct FIsld_obj *) gadget)->FIslider.type;
	break;

      case FI_DIAL:
	*orientation = ((struct FIdial_obj *) gadget)->FIdial.direction;
	break;

      case FI_GAUGE:
	*orientation = ((struct FIgauge_obj *) gadget)->FIgauge.type;
	break;

      case FI_SCROLL:
	*orientation = ((struct FIscrl_obj *) gadget)->FIscroll.type;
	break;

      default:
	return ( FI_INVALID_GADGET_TYPE );
    }

  return ( FI_SUCCESS );
}



int FIg_set_minor_increments (Form   form,
                              int    label,
                              int    incrs)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  switch ( gadget->FIgadget.type )
    {
      case FI_DIAL:
	((struct FIdial_obj *) gadget)->FIdial.minor_tick_inc = incrs;
	break;

      case FI_GAUGE:
	((struct FIgauge_obj *) gadget)->FIgauge.minor_increments =
								incrs;
	break;

      case FI_GROUP:
	_FI_grp_pass_on_int ( gadget, FIg_set_minor_increments,
							incrs, 0 );
	break;

      default:
	return ( FI_INVALID_GADGET_TYPE );
    }

  return ( FI_SUCCESS );
}



int FIg_get_minor_increments (Form  form,
                              int   label,
                              int  *incrs)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  switch ( gadget->FIgadget.type )
    {
      case FI_DIAL:
	*incrs = ((struct FIdial_obj *) gadget)->FIdial.minor_tick_inc;
	break;

      case FI_GAUGE:
	*incrs = ((struct FIgauge_obj *) gadget)->
					      FIgauge.minor_increments;
	break;

      default:
	return ( FI_INVALID_GADGET_TYPE );
    }

  return ( FI_SUCCESS );
}



int FIg_set_increment (Form      form,
                       int      label,
                       double   increment)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( increment == 0.0 )
    {
      increment = 1.0;
    }
  else if ( increment < 0.0 )
    {
      increment = FABS ( increment );
    }


  switch ( gadget->FIgadget.type )
    {
      case FI_DIAL:
	((struct FIdial_obj *) gadget )->FIrange.increment = increment;
	break;

      case FI_SLIDER:
	((struct FIsld_obj *) gadget )->FIrange.increment = increment;
	break;

      case FI_GROUP:
	_FI_grp_pass_on_double ( gadget, FIg_set_increment, increment );
	break;

      default:
	return ( FI_INVALID_GADGET_TYPE );
    }

  return ( FI_SUCCESS );
}



int FIg_get_increment (Form    form,
                       int     label,
                       float  *increment)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  switch ( gadget->FIgadget.type )
    {
      case FI_DIAL:
	*increment = ((struct FIdial_obj *) gadget )->FIrange.increment;
	break;

      case FI_SLIDER:
	*increment = ((struct FIsld_obj *) gadget )->FIrange.increment;
	break;

      default:
	return ( FI_INVALID_GADGET_TYPE );
    }

  return ( FI_SUCCESS );
}



int FIg_get_notify (Form   form,
                    int    label,
                    int   *notify_flag)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  *notify_flag = IT_HAS_COMPLETE_NOTIFY ( gadget );

  return ( FI_SUCCESS );
}



int FIg_set_notify_on (Form  form,
                       int   label)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  return ( _FI_g_set_notify ( gadget, ON ) );
}



/********************************************************/
/* This function sets the gadget NOT to notify the form */
/* upon having the gadget manipulated by the user.	*/
/********************************************************/

int FIg_set_notify_off (Form  form,
                        int   label)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  return ( _FI_g_set_notify ( gadget, OFF ) );
}



int FIg_set_display (Form  form,
                     int   label,
                     int   display_mask)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  switch ( gadget->FIgadget.type )
    {
      case FI_GROUP:
	_FI_grp_pass_on_int ( gadget, FIg_set_display,
						display_mask, 0 );
	break;

      case FI_DIAL:
      case FI_GAUGE:
      case FI_SCROLL:
      case FI_SLIDER:
	gadget->FIrange.display_mask = display_mask;
	break;

      default:
	return ( FI_INVALID_GADGET_TYPE );
    }

  return ( FI_SUCCESS );
}



int FIg_get_display (Form  form,
                     int   label,
                     int  *display_mask)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  switch ( gadget->FIgadget.type )
    {
      case FI_DIAL:
      case FI_GAUGE:
      case FI_SCROLL:
      case FI_SLIDER:
	*display_mask = gadget->FIrange.display_mask;
	break;

      default:
	return ( FI_INVALID_GADGET_TYPE );
    }

  return ( FI_SUCCESS );
}



int FIg_set_continuous_routine (Form  form,
                                int   label,
                                int (*cont_routine)())
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  switch ( gadget->FIgadget.type )
    {
      case FI_GROUP:
	_FI_grp_pass_on_int ( gadget, FIg_set_continuous_routine,
					(int) cont_routine, 0 );
	break;

      case FI_DIAL:
      case FI_GAUGE:
      case FI_SCROLL:
      case FI_SLIDER:
        gadget->FIrange.cont_routine = cont_routine;
	break;

      default:
	return ( FI_INVALID_GADGET_TYPE );
    }

  return ( FI_SUCCESS );
}



int FIg_get_continuous_routine (Form    form,
                                int     label,
                                int  (**cont_routine)())
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  switch ( gadget->FIgadget.type )
    {
      case FI_DIAL:
      case FI_GAUGE:
      case FI_SCROLL:
      case FI_SLIDER:
	*cont_routine = gadget->FIrange.cont_routine;
	break;

      default:
	return ( FI_INVALID_GADGET_TYPE );
    }

  return ( FI_SUCCESS );
}



int FIg_get_default_value (Form     form,
                           int      label,
                           double  *default_value)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( gadget )
    {
      *default_value = gadget->FIgadget.default_value;
      return ( FI_SUCCESS );
    }
  else
    {
      return ( FI_NO_SUCH_GADGET );
    }
}



int FIg_set_default_value (Form    form,
                           int     label,
                           double  default_value)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( gadget->FIgadget.type == FI_GROUP )
    {
      _FI_grp_pass_on_double ( gadget, FIg_set_default_value,
							default_value );
    }
  else
    {
      gadget->FIgadget.default_value = default_value;
    }

  return ( FI_SUCCESS );
}


/* dmb:10/05/92:Added to correct interface without changing prototypes */
int FIg_get_font_ANSI (Form    form,
                       int     label,
                       char   *fontname,
                       double  *bodysize)
{
  int status = FI_SUCCESS;
  float float_bodysize = *bodysize;

  status = FIg_get_font (form, label, fontname, &float_bodysize);
  *bodysize = float_bodysize;

  return ( status );
}



int FIg_get_font (Form    form,
                  int     label,
                  char   *fontname,
                  float  *bodysize)
{
  struct FIform_obj   * form_ptr = (struct FIform_obj *) form;
  struct FIgadget_obj * gadget;
  float			delta_y;

  gadget = _FI_g_get_id ( form_ptr, label );

  if ( gadget )
    {
      strcpy ( fontname, gadget->FIgadget.fontname );

	/*************************************************************/
	/* 08/30/90 GMD fixed problem with returning proper bodysize */
	/* for dynamically created text gadgets.		     */
	/*************************************************************/

      if ( form_ptr->attr_mask & FI_NOT_SCALABLE )
	{
	  delta_y = 1.0;
	}
      else if ( form_ptr->orig_ysize != 0.0 )
	{
	  delta_y = ( float ) ( form_ptr->yhi - form_ptr->ylo ) /
					( float )  form_ptr->orig_ysize;

	  if (( delta_y < 0.0 ) || ( delta_y > 1000.0 ) )
	    {
	      delta_y = 1.0;
	    }
	}
      else
	{
	  delta_y = 1.0;
	}

      *bodysize = gadget->FIgadget.bodysize * delta_y;
      return ( FI_SUCCESS );
    }
  else
    {
      return ( FI_NO_SUCH_GADGET );
    }
}


int FIg_set_symbol_file (Form   form,
                         int    label,
                         char  *symbol_file)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  _FI_s_rep ( &gadget->FIgadget.fontname, symbol_file );

  /* free memory associated with the symbol */

  /***   being done in activate now   GMD 6/11/91 *****
  _FI_g_free_symbols ( gadget );
  ****************************************************/

  _FI_g_activate ( gadget );

  return ( FI_SUCCESS );
}





int FIg_get_symbol_file (Form   form,
                         int    label,
                         char  *symbol_file)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  strcpy (symbol_file, gadget->FIgadget.fontname );

  return ( FI_SUCCESS );
}




/* dmb:10/05/92:bodysize was float */
int FIg_set_font (Form   form,
                  int    label,
                  char  *fontname,
                  double  bodysize)
{
  struct FIgadget_obj	*gadget;
  struct FIfld_obj	*field;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  _FI_s_rep ( &gadget->FIgadget.fontname, fontname );

  gadget->FIgadget.bodysize = bodysize;

  switch ( gadget->FIgadget.type )
    {
      case FI_TEXT:
	_FI_txt_adjust ( (struct FItext_obj *)gadget, 1.0, 1.0 );
	break;

      case FI_MULTI_COL:
    /* dmb:10/10/92:Changed float to double and added cast for ANSI */
	_FI_grp_pass_on_int_double ( gadget, FIg_set_font,
				(int) fontname, (double)bodysize );
	break;

      case FI_FIELD:

		/*****************************************/
		/* If field has an associated list,	 */
		/* set its font as well.		 */
		/*****************************************/

	field = (struct FIfld_obj *) gadget;
	if ( field->FIfield.list_id )
	  {
	    _FI_s_rep ( & ( field->FIfield.list_id->FIgadget.fontname ),
							fontname );
	    field->FIfield.list_id->FIgadget.bodysize = bodysize;
	  }
	break;

      default:
	break;
    }

  _FI_g_activate ( gadget );

  return ( FI_SUCCESS );
}

int FIg_set_line_weight (Form  form,
                         int   label,
                         int   wt)
{
  int type;
  struct FIline_obj *line;

  line = (struct FIline_obj *) _FI_g_get_id (
				(struct FIform_obj *) form, label );
  if ( ! line )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  type = line->FIgadget.type;

  if ( type == FI_GROUP )
    {
      _FI_grp_pass_on_int ( (struct FIgadget_obj *) line,
				FIg_set_line_weight, wt, 0 );
    }
  else
    {
      if ( (type != FI_LINE ) && (type != FI_RECT ) )
        {
	  return ( FI_INVALID_GADGET_TYPE );
        }

      line->FIgraphic.line_weight = wt;
    }

  return ( FI_SUCCESS );
}




int FIg_get_line_weight (Form   form,
                         int    label,
                         int   *wt)
{
  struct FIline_obj *line;

  line = (struct FIline_obj *) _FI_g_get_id (
				(struct FIform_obj *) form, label );
  if ( ! line )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if (	(line->FIgadget.type != FI_LINE )	&&
	(line->FIgadget.type != FI_RECT )	 )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  *wt = line->FIgraphic.line_weight;

  return ( FI_SUCCESS );
}



/*****************************************/
/*** Still using old Env.V line styles ***/
/*****************************************/

int FIg_set_line_style (Form  form,
                        int   label,
                        int   style)
{
  struct FIline_obj *line;

  line = (struct FIline_obj *) _FI_g_get_id (
				(struct FIform_obj *) form, label );

  if ( ! line )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( line->FIgadget.type == FI_GROUP )
    {
      _FI_grp_pass_on_int ( (struct FIgadget_obj *) line,
				FIg_set_line_style, style, 0 );
    }
  else
    {
      if (	(line->FIgadget.type != FI_LINE )	&&
		(line->FIgadget.type != FI_RECT )	)
	{
	  return ( FI_INVALID_GADGET_TYPE );
	}

      line->FIgraphic.line_style = style;

     /** Translation to X **/

      _FI_graphic_activate ( & line->FIgraphic );
    }

  return ( FI_SUCCESS );
}



/*****************************************/
/*** Still using old Env.V line styles ***/
/*****************************************/

int FIg_get_line_style (Form  form,
                        int   label,
                        int  *style)
{
  struct FIline_obj *line;

  line = (struct FIline_obj *) _FI_g_get_id (
				(struct FIform_obj *) form, label );

  if ( ! line )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if (	(line->FIgadget.type != FI_LINE )	&&
	(line->FIgadget.type != FI_RECT )	 )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  *style = line->FIgraphic.line_style;

  return ( FI_SUCCESS );
}



int FIg_set_text_style (Form   form,
                        int    label,
                        int    style)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( gadget->FIgadget.type == FI_GROUP )
    {
      _FI_grp_pass_on_int ( gadget, FIg_set_text_style, style, 0 );
    }
  else
    {
      gadget->FIgadget.effect = style;
    }

  return ( FI_SUCCESS );
}



int FIg_get_text_style (Form  form,
                        int   label,
                        int  *style)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  *style = gadget->FIgadget.effect;

  return ( FI_SUCCESS );
}



int FIg_set_next_in_seq (Form   form,
                         int    label,
                         int    next_label)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  gadget->FIgadget.next_in_seq = next_label;

  return ( FI_SUCCESS );
}



int FIg_get_next_in_seq (Form  form,
                         int   label,
                         int  *next_label)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  *next_label = gadget->FIgadget.next_in_seq;

/******************************************************
  sml:10-04-93	Allow gadgets 1-10 to be in sequences	
	(BORROWED FROM I/FORMS)
*******************************************************/
  if ( *next_label < 1 /*11*/ )
    {
      *next_label = -1;
    }

  return ( FI_SUCCESS );
}



int FIg_set_pass_data (Form  form,
                       int   label,
                       int   next_label)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  gadget->FIgadget.pass_label = next_label;

  return ( FI_SUCCESS );
}



int FIg_get_pass_data (Form  form,
                       int   label,
                       int  *next_label)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  *next_label = gadget->FIgadget.pass_label;

  return ( FI_SUCCESS );
}



int FIg_set_value_format (Form  form,
                          int   label,
                          int   field_width,
                          int   decimal_accuracy)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  switch ( gadget->FIgadget.type )
    {
      case FI_GROUP:
	_FI_grp_pass_on_int ( gadget, FIg_set_value_format,
					field_width, decimal_accuracy );
	break;

      case FI_DIAL:
      case FI_SLIDER:

	if ( field_width > FI_MAX_VALUE_FORMAT )
	  {
	    return ( FI_ILLEGAL_VALUES );
          }
	gadget->FIrange.field_width = field_width;
	gadget->FIrange.decimal_accuracy = decimal_accuracy;
	break;

      default:
	return ( FI_INVALID_GADGET_TYPE );
    }

  return ( FI_SUCCESS );
}



int FIg_get_value_format (Form   form,
                          int    label,
                          int   *field_width,
                          int   *decimal_accuracy)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  switch ( gadget->FIgadget.type )
    {
      case FI_DIAL:
      case FI_SLIDER:

	*field_width = gadget->FIrange.field_width;
	*decimal_accuracy = gadget->FIrange.decimal_accuracy;

	break;

      default:
	return ( FI_INVALID_GADGET_TYPE );
    }

  return ( FI_SUCCESS );
}



int FIbtn_set_auto_pop_up_on (Form  form,
                              int   label)
{
  struct FIbtn_obj *btn;

  btn = (struct FIbtn_obj *) _FI_g_get_id (
				(struct FIform_obj *) form, label );
  if ( ! btn )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( btn->FIgadget.type == FI_GROUP )
    {
      _FI_grp_pass_on_int ( (struct FIgadget_obj *) btn,
				FIbtn_set_auto_pop_up_on, 0, 0 );
      return ( FI_SUCCESS );
    }

  if ( btn->FIgadget.type != FI_BUTTON )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  btn->FIbtn.auto_pop_up = TRUE;

  if ( btn->FIgadget.value == 1.0 )
    {
      btn->FIgadget.value = 0.0;

      if ( IT_IS_DISPLAYED ( btn ) )
	{
	  _FI_btn_display ( btn, XWINDOW ( btn ) );
	}
    }

  return ( FI_SUCCESS );
}



int FIbtn_set_auto_pop_up_off (Form  form,
                               int   label)
{
  struct FIbtn_obj *btn;

  btn = (struct FIbtn_obj *) _FI_g_get_id (
				(struct FIform_obj *) form, label );

  if ( ! btn )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( btn->FIgadget.type == FI_GROUP )
    {
      _FI_grp_pass_on_int ( (struct FIgadget_obj *) btn,
				FIbtn_set_auto_pop_up_off, 0, 0 );
      return ( FI_SUCCESS );
    }

  if ( btn->FIgadget.type != FI_BUTTON )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  btn->FIbtn.auto_pop_up = FALSE;

  return ( FI_SUCCESS );
}



int FIbtn_get_auto_pop_up_state (Form  form,
                                 int   label,
                                 int  *state)
{
  struct FIbtn_obj *btn;

  btn = (struct FIbtn_obj *) _FI_g_get_id (
				(struct FIform_obj *) form, label );

  if ( ! btn )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( btn->FIgadget.type != FI_BUTTON )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  *state = btn->FIbtn.auto_pop_up;

  return ( FI_SUCCESS );
}



int FIg_get_group_label (Form  form,
                         int   label,
                         int  *group_label)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  *group_label = gadget->FIgadget.group->FIgadget.label;

  return ( FI_SUCCESS );
}



int FIg_reset (Form  form,
               int   label)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  _FI_g_reset ( gadget );

  return ( FI_SUCCESS );
}



int FIscrl_get_view (Form     form,
                     int      label,
                     double  *view)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );
  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( gadget->FIgadget.type != FI_SCROLL )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  *view = ((struct FIscrl_obj *) gadget )->FIscroll.view;

  return ( FI_SUCCESS );
}


int FIscrl_set_view (Form    form,
                     int     label,
                     double  view)
{
  int value;
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );
  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( gadget->FIgadget.type != FI_SCROLL )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  ((struct FIscrl_obj *) gadget )->FIscroll.view = view;
  value = gadget->FIgadget.value;
  gadget->FIgadget.value = value - 1;

  _FI_scrl_set_value ( (struct FIscrl_obj *)gadget, value );

  return ( FI_SUCCESS );
}


/****************************************************************/
/* FIg_in_group() checks to see if the gadget is in the		*/
/* specified group ( at the top level, or anywhere within	*/
/* groups within the specified group ).				*/
/****************************************************************/

int FIg_in_group (Form  form,
                  int   gadget_label,
                  int   group_label,
                  int  *in_group)
{
  struct FIform_obj  * form_ptr = (struct FIform_obj *) form;
  struct FIgroup_obj * group;

  /*** initially assume gadget is NOT in group ***/
  *in_group = FALSE;

  /*** get the gadget id ***/

  if ( gadget_label == FI_FORM_GROUP )
    {
      return ( FI_NO_SUCH_GADGET );
    }


  /*** get the group id ***/
  if ( group_label == FI_FORM_GROUP )
    {
      group = form_ptr->group;
    }
  else
    {	/*** get the group ptr ***/

      group = (struct FIgroup_obj *) _FI_g_get_id ( form_ptr,
							group_label );

      if ( ! group || ! group->FIgadget.type != FI_GROUP )
        {
	  return ( FI_NO_SUCH_GROUP );
        }
    }

  if ( _FI_g_get_id_from_group ( group, gadget_label ) )
    {
      *in_group = TRUE;
    }

  return ( FI_SUCCESS );
}



int FIg_get_justification (Form  form,
                           int   label,
                           int  *just)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  *just = gadget->FIgadget.justification;

  return ( FI_SUCCESS );
}


/********************************************************************/
/*** This function will allow the programmer to tell what called  ***/
/*** the gadget's notification routine:				  ***/
/***   FI_COMPLETION_NOTIFICATION -	called from "regular"	  ***/
/***					notification routine	  ***/
/***   FI_INITIAL_NOTIFICATION -	called from initial	  ***/
/***					notification routine	  ***/
/***   FI_CALL_NOTIFICATION -	called from function	  	  ***/
/***				FIg_call_notification_routine	  ***/
/********************************************* JAJ:01/20/92  ********/

int FI_get_last_notification_type (int *notify_type)
{
  * notify_type = _FI_notification_type;

  return ( FI_SUCCESS );
}
