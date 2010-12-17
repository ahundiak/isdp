/*  void do_form( action )
 *
 *  This function will do several thing regarding our form
 *  depending on the action.  The actions are defined in ex2.h.
 *
 *  CREATE_FORM:  create the form and group gadget but do not
 *                display.
 *
 *  DISPLAY_FORM: display the form and any displayed gadgets on
 *                the form.
 *
 *  ERASE_FORM:   erase the form.
 */

#include "FI.h"
#include "ex2.h"
#include "ex2gvare.h"

void notification_routine();

void do_form( action )
  int action;
{
  int sts;

  switch( action ) {

/*
 *  If the form has not been previously created, create it
 *  and the group gadget.  Nothing is displayed.
 */
    case CREATE_FORM:
      if ( ! form_created )
      {

/*
 *  Create the form.  The form label (used when referring to
 *  the form) is EX2_form, #defined in ex2.h.  The form is in a
 *  file called ex2form.new.  The routine called by the forms
 *  system when gadgets on it are manipulated is called
 *  notification_routine.
 */
        sts = FIf_new ( EX2_FORM, "ex2form.new",
                        notification_routine, &ex2_form );
        if ( chkerror( sts, "creating form" ) )
           return;

/*  Move the form down 150 pixels */

        {
           int xpos, ypos;

           FIf_get_location ( ex2_form, &xpos, &ypos );
           FIf_set_location ( ex2_form, xpos, ypos + 150 );
        }

/*
 *  Set our flag to TRUE so we won't try to create it twice.
 */
        form_created = TRUE;

/*
 *  Create the group gadget to which we will add all the
 *  gadgets subsequently created, just for the purpose of
 *  deleting, erasing and displaying them all at once with one
 *  function call.
 */
        sts = FIg_new( ex2_form, FI_GROUP, GADGET_GROUP );
        chkerror( sts, "creating gadget group" );

	/*** create a group to hold the control bar buttons ***/
        sts = FIg_new( ex2_form, FI_GROUP, FI_CTRL_GROUP );
        chkerror( sts, "creating control bar group" );
      }

      break;


/*
 *  If the form has been created, display it and all gadgets
 *  created on it and set to display.
 */
    case DISPLAY_FORM:
      if ( form_created && !form_displayed ) {

        sts = FIf_display ( ex2_form );
        if ( chkerror( sts, "displaying form" ) )
          return;

	FIf_set_resize_off ( ex2_form );
/*
 *  Set the form displayed flag to TRUE so we don't try
 *  to display it again, although it wouldn't hurt anything
 *  to do so.
 */
        form_displayed = TRUE;
      }
      break;

/*
 *  Erase the form if it is displayed.  When re-displayed, the
 *  gadgets which were displayed before this will be displayed
 *  and those which were erased previously will not.
 */
    case ERASE_FORM:
      if ( form_created && form_displayed ) {

        sts = FIf_erase ( ex2_form );
        if ( chkerror( sts, "erasing form" ) )
          return;

/*
 *  Set the form displayed flag to FALSE so we will not try to
 *  erase it twice, although it wouldn't hurt anything to do so.
 */
        form_displayed = FALSE;
      }
      break;

/*
 *  If the form has been created, delete it and all gadgets
 *  associated
 *  with it.
 */
    case DELETE_FORM:
      if ( form_created ) {

        sts = FIf_delete( ex2_form );
        if ( chkerror( sts, "deleting form" ) )
          return;
/*
 *  Set the form created and displayed flags to FALSE so
 *  we will be able to create and display it later.
 */
        form_created = FALSE;
        form_displayed = FALSE;
      }
      break;

  }
}
