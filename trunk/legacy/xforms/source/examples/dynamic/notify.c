/*  void notification_routine( form_label, gadget_label, value,
 *                             form )
 *
 *  This is the function specified in the call to FIf_new and
 *  will be called by the forms system any time one of the
 *  gadgets from that form is manipulated.
 */

#include <stdio.h>
#include "FI.h"
#include "FIdyn.h"
#include "ex2.h"
#include "ex2gvare.h"


/* ARGSUSED */
void notification_routine ( form_label, gadget_label, value,
                            form )
  int    form_label;
  int    gadget_label;
  double value;
  Form   form;
{
  int sts;

/*
 *  If this notification routine was being used to service
 *  more than one form, it would first need to switch on 
 *  the form label, but since that is not the case, we
 *  won't even worry about it.
 *  Switch on the gadget label to determine what to do.
 */

  switch ( gadget_label )
  {

/*
 *  If our delete gadgets button was pressed, call FIg_delete
 *  giving it the label of our gadgets group.  All gadgets in
 *  that group should be deleted, while leaving our group gadget
 *  intact.  ( to delete a group gadget, use FIgrp_delete.)
 */
    case DELETE_GADGETS:
/*
 *  Only do this if the form has been created since that is when
 *  the group gadget is created.
 */
      if ( form_created )
      {
        sts = FIg_delete( ex2_form, GADGET_GROUP );
        if ( chkerror( sts, "deleting gadget group" ) )
          return;
          
        sts = FIg_delete( ex2_form, FI_CTRL_GROUP );
        if ( chkerror( sts, "deleting control bar gadgets" ) )
          return;
/*
 *  Set all defined flags to FALSE to indicate that they
 *  may now be created again.
 */
        field_defined = FALSE;
        check_defined = FALSE;
        text_defined = FALSE;
        sym_defined = FALSE;
        button_defined = FALSE;
        toggle_defined = FALSE;
        dial_defined = FALSE;
        slider_defined = FALSE;
        line_defined = FALSE;
        bezel_defined = FALSE;
        gauge_defined = FALSE;
        mcf_defined = FALSE;
        scroll_defined = FALSE;
        cbar_defined = FALSE;

      }

/*
 *  Set the state of the delete gadgets button to off
 *  since it was not defined as an auto pop up.
 */
      sts = FIg_set_state_off( ex2_form, DELETE_GADGETS );
      if ( chkerror( sts,
                     "setting delete gadgets button to off" ) )
        return;
      break;

/*
 *  If our display gadgets button was pressed, call FIg_display
 *  giving it the label of our gadgets group.  All gadgets in
 *  that group will be displayed, unless they are already
 *  displayed, in which case, nothing will happen.
 */
    case DISPLAY_GADGETS:
/*
 *  Only do this if the form is created and displayed.
 */
      if ( form_created && form_displayed )
	{
          sts = FIg_display( ex2_form, GADGET_GROUP );
          if ( chkerror( sts, "displaying gadget group" ) )
            return;

          sts = FIg_display( ex2_form, FI_CTRL_GROUP );
          if ( chkerror( sts, "displaying control bar gadget group" ) )
            return;
	}
        
/*
 *  Set the state of the display gadgets button to off
 *  since it was not defined as an auto pop up.
 */
      sts = FIg_set_state_off( ex2_form, DISPLAY_GADGETS );
      if ( chkerror( sts, "setting display gadgets button to off" ) )
        return;
      break;

/*
 *  If our erase gadgets button was pressed, call FIg_display
 *  giving it the label of our gadgets group.  All gadgets in
 *  that group will be erased, unless they are not displayed,
 *  in which case, nothing will happen.  The gadget are still
 *  intact, they are just not visible.  An FIg_display will
 *  bring them back.
 */
    case ERASE_GADGETS:
/*
 *  Only do this if the form is created and displayed.
 */
      if ( form_created && form_displayed )
	{
          sts = FIg_erase( ex2_form, GADGET_GROUP );
          if ( chkerror( sts, "erasing gadget group" ) )
            return;

          sts = FIg_erase( ex2_form, FI_CTRL_GROUP );
          if ( chkerror( sts, "erasing control bar gadget group" ) )
            return;
	}

/*
 *  Set the state of the display gadgets button to off
 *  since it was not defined as an auto pop up.
 */
      sts = FIg_set_state_off( ex2_form, ERASE_GADGETS );
      if ( chkerror( sts,
                     "setting erase gadgets button to off" ) )
        return;
      break;
  }
}
