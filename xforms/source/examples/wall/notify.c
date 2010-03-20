/*  void notification_routine( form_label, gadget_label, value, form )
 *
 *  This is the function specified in the call to FIf_new and will
 *  be called by the forms system any time one of the gadgets from
 *  that form is manipulated.
 */

#include <stdio.h>
#include "FI.h"
#include "FIdyn.h"
#include "ex1.h"
#include "ex1gvare.h"


notification_routine ( form_label, gadget_label, value, form )
  int form_label;
  int gadget_label;
  double value;
  Form form;
{
  int select;
  int row_pos, sts;
  
/*  Since we are using this routine for more than one
 *  form, we must switch on the form label first.
 */
  switch ( form_label )
  {

/*
 *  It concerns a gadget on the wall design form.
 */
    case WALL_DESIGN_FORM:

/*
 *  Now, determine which gadget was manipulated.
 */
      switch ( gadget_label )
      {

/*
 *  The accept button was pressed.
 *  Print out the results, erase the form, and set the
 *  exit flag to TRUE.
 */
        case FI_ACCEPT:
          do_results();
          sts = FIf_erase ( form );
          chkerror( sts, "erasing wall design form" );
          break;		

/*
 *  The cancel button was pressed.
 *  Erase the form and set the exit flag to TRUE.
 */
        case FI_CANCEL:	
          sts = FIf_erase ( form );
          chkerror( sts, "erasing wall design form" );
          break;

/*
 *  The supplier button was pressed.
 *  Erase the material group and display the suppliers group
 *  so the user may now select the supplier options.  Also,
 *  set the text in the message field to reflect the current
 *  operation.
 */
        case SUPPLIER_BUTTON:
          sts = FIg_erase( wall_design, MATERIAL_GROUP );
          chkerror( sts, "erasing material group" );
          sts = FIg_display( wall_design, SUPPLIER_GROUP );
          chkerror( sts, "displaying supplier group" );
          sts = FIfld_set_text( wall_design,
                                MESSAGE_FIELD,
                                0,
                                0,
                                "Select Supplier(s)",
                                FALSE );
          chkerror( sts, "setting message field text" );
          break;

	
/* Toggle the supplier multi-column field between SINGLE and MULTI select */

	case SUPPLIER_TOGGLE:
		if ( value == 1.0 )
		{
			FIfld_set_mode ( wall_design, SUPPLIER_FIELD, 0, FI_MULTI_SELECT );
			FIfld_set_mode ( wall_design, SUPPLIER_FIELD, 1, FI_MULTI_SELECT );
		}
		else
		{
			FIfld_set_mode ( wall_design, SUPPLIER_FIELD, 0, FI_SINGLE_SELECT );
			FIfld_set_mode ( wall_design, SUPPLIER_FIELD, 1, FI_SINGLE_SELECT );
		}
		break;

/*
 *  The material button was pressed.
 *  Erase the suppliers group and display the materials group
 *  so the user may now select the materials options.  Also,
 *  set the text in the message field to reflect the current
 *  operation.
 */
        case MATERIAL_BUTTON:
          sts = FIg_erase( wall_design, SUPPLIER_GROUP );
          chkerror( sts, "erasing supplier group" );
          sts = FIg_display( wall_design, MATERIAL_GROUP );
          chkerror( sts, "displaying material group" );
          sts = FIfld_set_text( wall_design,
                                MESSAGE_FIELD,
                                0,
                                0,
                                "Choose Material",
                                FALSE );
          chkerror( sts, "setting message field text" );
          break;

/*
 *  The design accessories button was pressed.
 *  First, create the accessories design form.  Then
 *  erase both supplier and material groups since we don't
 *  know if/which one is displayed.  (Erasing an undisplayed
 *  group or gadget won't hurt anything, but it will solicit
 *  an error from the Forms System so we won't check the status
 *  return on those two calls.  Finally, set the message field
 *  to indicate the current operation.
 *
 *  NOTE:  a better plan would be to get the current values
 *  of the accessories parameters from our global structure
 *  and update the gadgets on this form to reflect since the
 *  user may have called up this form previously and changed
 *  some of the gadgets.  If time permits, this example will
 *  we updated to implement that plan.
 */
        case ACCESS_BUTTON:
          FIg_erase( wall_design, SUPPLIER_GROUP );
          FIg_erase( wall_design, MATERIAL_GROUP );
          sts = FIfld_set_text( wall_design,
                                MESSAGE_FIELD,
                                0,
                                0,
                                "Fill out design accessories form",
                                FALSE );
          chkerror( sts, "setting message field text" );
          if ( ! acc_created ) {
            acc_form();
            acc_created = TRUE;
          }
          break;

/*
 *  The sliders have been manipulated.
 *  Even though the Forms System has been continuously
 *  notifying us of the sliders' progress (through
 *  the function continuous routine), it will notify
 *  us through this routine when the user releases the
 *  button.
 */
        case LENGTH_SLIDER:
          wall.length = value;
          break;
        case HEIGHT_SLIDER:
          wall.height = value;
          break;

/*
 *  The wall name field has been changed.
 *  Just get the text from the field into the wall structure.
 */
        case NAME_FIELD:
          FIfld_get_text( wall_design,
                          NAME_FIELD,
                          0,
                          0,
                          40,
                          wall.name,
                          &select,
                          &row_pos );
          break;

      }
      break;

/*
 *  It concerns a gadget on the wall design form.
 */
    case ACC_DESIGN_FORM:

/*
 *  Now, determine which gadget was manipulated.
 */
      switch ( gadget_label )
      {
/*
 *  The accept or cancel button was pressed.
 *  Delete the accessories form, set the state of the buton which
 *  got us here to off, and update the message field.
 *
 *  NOTE: Normally, you would differenciate between the accept and
 *  cancel buttons and take different actions.  However,
 *  we are not saving the previous values these gadgets represent
 *  to be able to restore them in the event of the cancel button
 *  being changed.  That is the recommended course of action.  If
 *  time permits, this example will be changed to implement this.
 */
        case FI_ACCEPT:
        case FI_CANCEL:
          sts = FIf_delete( acc_design );
          chkerror( sts, "deleting accessories form" );

          sts = FIg_set_state_off( wall_design, ACCESS_BUTTON );
          chkerror( sts, "setting accessories button to off" );

          sts = FIg_set_text( wall_design,
                              MESSAGE_FIELD,
                              "Fill in wall design" );
          chkerror( sts, "setting message field text" );
          
          acc_created = FALSE;

          break;

/*
 *  The door/window design toggle has changed.
 *  We have two modes of operation:  door design
 *  and window design.  This will toggle that mode
 */
        case DESIGN_TOGGLE:

          if ( value == 1.0 ) {

/*
 *  The value is 1.0 which means we need to go to window
 *  design mode.  First, erase the door group and display
 *  the window group.  The window group currently on consists
 *  of the "Design Window" text gadget.  The swap the current
 *  window symbol for the current door symbol and the current
 *  window text for the current door text.  Last, set our
 *  design mode variable to DESIGN_WINDOW.
 */
            sts = FIg_erase( acc_design, DOOR_GROUP );
            chkerror( sts, "erasing door group" );

            sts = FIg_display( acc_design, WINDOW_GROUP );
            chkerror( sts, "displaying window group" );

            switch_symbol( acc_design, STYLE_SYMBOL,
                           window_styles[ window_style ].symbol );

            sts = FIfld_set_text( acc_design, STYLE_FIELD, 0, 0,
                            window_styles[ window_style ].desc, FALSE );
            chkerror( sts, "setting style text" );

            design_mode = DESIGN_WINDOW;

          }
          else {

/*
 *  The value is 0.0 which means we need to go to door
 *  design mode.  First, erase the window group and display
 *  the door  group.  The swap the current
 *  door symbol for the current window symbol and the current
 *  door text for the current window text.  Last, set our
 *  design mode variable to DESIGN_DOOR.
 */
            sts = FIg_erase( acc_design, WINDOW_GROUP );
            chkerror( sts, "erasing window group" );

            sts = FIg_display( acc_design, DOOR_GROUP );
            chkerror( sts, "displaying door group" );

            switch_symbol( acc_design, STYLE_SYMBOL,
                           door_styles[ door_style ].symbol );

            sts = FIfld_set_text( acc_design, STYLE_FIELD, 0, 0,
                              door_styles[ door_style ].desc, FALSE );
            chkerror( sts, "setting style text" );

            design_mode = DESIGN_DOOR;

          }
          break;

/*
 *  The right style button was pressed.
 *  This will have the effect of incrementing
 *  through the door/window styles.
 */
        case  RIGHT_STYLE_BUTTON:

            if ( design_mode == DESIGN_DOOR ) {

/*
 *  We are in design door mode so we need to increment
 *  the door style, using modular arithmetic to wrap,
 *  switch the style symbol and style text, and then
 *  store the new style in our global wall structure.
 */
              door_style = (door_style + 1) % MAX_DOOR_STYLES;

              switch_symbol( acc_design,
                             STYLE_SYMBOL,
                             door_styles[ door_style ].symbol );

              sts = FIfld_set_text( acc_design,
                                    STYLE_FIELD,
                                    0,
                                    0,
                                    door_styles[ door_style ].desc,
                                    FALSE );

              chkerror( sts, "setting style text" );

              wall.door_style = door_style;

            }
            else {

/*
 *  We are in design window mode so we need to increment
 *  the window style, using modular arithmetic to wrap,
 *  switch the style symbol and style text, and then
 *  store the new style in our global wall structure.
 */
              window_style = (window_style + 1) % MAX_WINDOW_STYLES;

              switch_symbol( acc_design,
                             STYLE_SYMBOL,
                             window_styles[ window_style ].symbol );

              sts = FIfld_set_text( acc_design,
                                    STYLE_FIELD,
                                    0,
                                    0,
                                    window_styles[ window_style ].desc,
                                    FALSE );

              wall.window_style = window_style;

            }
          break;

/*
 *  The left style button was pressed.
 *  This will have the effect of decrementing
 *  through the door/window styles.
 */
        case LEFT_STYLE_BUTTON:
        
            if ( design_mode == DESIGN_DOOR ) {

/*
 *  We are in design door mode so we need to increment
 *  the door style, using modular arithmetic to wrap,
 *  switch the style symbol and style text, and then
 *  store the new style in our global wall structure.
 */
              door_style -= 1;
              if ( door_style < 0 )
                door_style = MAX_DOOR_STYLES - 1;

              switch_symbol( acc_design,
                             STYLE_SYMBOL,
                             door_styles[ door_style ].symbol );

              sts = FIfld_set_text( acc_design,
                                    STYLE_FIELD,
                                    0,
                                    0,
                                    door_styles[ door_style ].desc,
                                    FALSE );
              chkerror( sts, "setting style text" );
              
              wall.door_style = door_style;

            }
            else {

/*
 *  We are in design window mode so we need to increment
 *  the window style, using modular arithmetic to wrap,
 *  switch the style symbol and style text, and then
 *  store the new style in our global wall structure.
 */
              window_style -= 1;
              if ( window_style < 0 )
                window_style = MAX_WINDOW_STYLES - 1;

              switch_symbol( acc_design,
                             STYLE_SYMBOL,
                             window_styles[ window_style ].symbol );

              sts = FIfld_set_text( acc_design,
                                    STYLE_FIELD,
                                    0,
                                    0,
                                    window_styles[ window_style ].desc,
                                    FALSE );
              chkerror( sts, "setting style text" );

              wall.window_style = window_style;

            }
          break;

/*
 *  The lock checklists have been changed.  Just store the
 *  new value in our global wall structure.
 *  Notice that we do not have to worry about unselecting
 *  the previous gadget since the group is set to single
 *  select.
 */
        case NONE_CHECKBOX:
          wall.lock = 0;
          break;
        case STANDARD_CHECKBOX:
          wall.lock = 1;
          break;
        case PADLOCK_CHECKBOX:
          wall.lock = 2;
          break;
        case DEADBOLT_CHECKBOX:
          wall.lock = 3;
          break;
        case CHAIN_CHECKBOX:
          wall.lock = 4;
          break;

      }
      break;

  }
}
