/*  void continuous_routine( form_label, gadget_label, value, form_ptr );
 *
 *  This is the routine which services the two wall dimension
 *  sliders.  The sliders are set to continuous notify mode with
 *  FIg_set_continuous_notify_on and the address of this routine
 *  was provided to the Form System with the function 
 *  FIg_set_continuous_routine.  The address of this routine
 *  was specified for both sliders.
 */
 
#include <stdio.h>
#include <FI.h>
#include <FIdyn.h>
#include "ex1.h"
#include "ex1gvare.h"


/* ARGSUSED */
void continuous_routine( form_label, gadget_label, value, form_ptr )
  int form_label;
  int gadget_label;
  double value;
  Form *form_ptr;
{
  char value_buf[25];

/*
 *  Since this rouitne is servicing more than one gadget,
 *  we will switch on the gadget label.
 */
  switch( gadget_label ) {

/*
 *  The height slider is being manipulated.
 */
    case HEIGHT_SLIDER:
/*
 *  Format the value in to a string, erase the old text,
 *  set the new text to the value string and display it.
 */
      sprintf( value_buf, "%4.1lf ft", value );
      FIg_erase( form_ptr, HEIGHT_TEXT );
      FIg_set_text( form_ptr, HEIGHT_TEXT, value_buf );
      FIg_display( form_ptr, HEIGHT_TEXT );
      break;

/*
 *  The length slider is being manipulated.
 */
    case LENGTH_SLIDER:

/*
 *  Format the value in to a string, erase the old text,
 *  set the new text to the value string and display it.
 */
      sprintf( value_buf, "%6.1lf ft", value );
      FIg_erase( form_ptr, LENGTH_TEXT );
      FIg_set_text( form_ptr, LENGTH_TEXT, value_buf );
      FIg_display( form_ptr, LENGTH_TEXT );
      break;

  }
}
