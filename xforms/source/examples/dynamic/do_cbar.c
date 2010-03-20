/*  void do_cbar()
 *
 *  This function will dynamically create a button gadget
 *  with text displayed and a color of green when on.  It will
 *  also be set to auto pop up.  The button will have an
 *  initial value of 0.0 which means that it will not be
 *  displayed in the on state.
 */

#include <stdio.h>
#include "FI.h"
#include "FIdyn.h"
#include "ex2.h"
#include "ex2gvare.h"

#define CBAR_FROM_EDGE		 5
#define CBAR_BUTTON_WIDTH	30

void do_cbar()
{
  int sts;
  int x_size, y_size;
  int cbar_start_x;
  
  if ( ! cbar_defined )
    {
/*
 *  If the control bar buttons have not been created previously,
 *  do it now.
 */
    sts = FIg_new( ex2_form, FI_BUTTON, FI_ACCEPT );
    if ( chkerror( sts, "creating accept button" ) )
      return;

    sts = FIg_new( ex2_form, FI_BUTTON, FI_CANCEL );
    if ( chkerror( sts, "creating cancel button" ) )
      return;

    sts = FIg_new( ex2_form, FI_BUTTON, FI_HELP );
    if ( chkerror( sts, "creating help button" ) )
      return;

    cbar_defined = TRUE;


/*
 *  Set up the standard variables structure with the needed
 *  values and call FIg_set_standard_variables.
 */
	/*******************************/
	/*** see how big the form is ***/
	/*******************************/
    FIf_get_size ( ex2_form, & x_size, & y_size );

	/********************************************************/
	/*** start placing control bar buttons from the right ***/
	/*** edge of the form                                 ***/
	/********************************************************/
    cbar_start_x = x_size - CBAR_BUTTON_WIDTH - CBAR_FROM_EDGE;

	/***********************************/
	/*** set up the FI_ACCEPT button ***/
	/***********************************/
    std_var.xlo = cbar_start_x;
    std_var.ylo = CBAR_FROM_EDGE;
    std_var.xhi = std_var.xlo + CBAR_BUTTON_WIDTH;
    std_var.yhi = std_var.ylo + CBAR_BUTTON_WIDTH;
    std_var.text = 0;
    std_var.fontname = "FIsym";
    std_var.value = 0.0;
    std_var.on_color = FI_GREEN;
    std_var.off_color = FI_BLACK;
    std_var.symbol_index = 11;

    FIg_set_standard_variables( ex2_form, FI_ACCEPT, &std_var );
    if ( chkerror( sts, "setting accept button variables" ) )
      return;


	/***********************************/
	/*** set up the FI_CANCEL button ***/
	/***********************************/
    cbar_start_x -= CBAR_BUTTON_WIDTH;

    std_var.xlo = cbar_start_x;
    std_var.ylo = CBAR_FROM_EDGE;
    std_var.xhi = std_var.xlo + CBAR_BUTTON_WIDTH;
    std_var.yhi = std_var.ylo + CBAR_BUTTON_WIDTH;
    std_var.text = 0;
    std_var.fontname = "FIsym";
    std_var.value = 0.0;
    std_var.on_color = FI_GREEN;
    std_var.off_color = FI_BLACK;
    std_var.symbol_index = 8;

    FIg_set_standard_variables( ex2_form, FI_CANCEL, &std_var );
    if ( chkerror( sts, "setting cancel button variables" ) )
      return;


	/***********************************/
	/*** set up the FI_CANCEL button ***/
	/***********************************/
    cbar_start_x -= CBAR_BUTTON_WIDTH;

    std_var.xlo = cbar_start_x;
    std_var.ylo = CBAR_FROM_EDGE;
    std_var.xhi = std_var.xlo + CBAR_BUTTON_WIDTH;
    std_var.yhi = std_var.ylo + CBAR_BUTTON_WIDTH;
    std_var.text = 0;
    std_var.fontname = "FIsym";
    std_var.value = 0.0;
    std_var.on_color = FI_GREEN;
    std_var.off_color = FI_BLACK;
    std_var.symbol_index = 12;

    FIg_set_standard_variables( ex2_form, FI_HELP, &std_var );
    if ( chkerror( sts, "setting help button variables" ) )
      return;
    
/*
 *  Put the control bar buttons in the control bar gadgets group
 *  for display, delete, and erase operations.
 */
    sts = FIg_add_to_group( ex2_form, FI_ACCEPT, FI_CTRL_GROUP );
    if ( chkerror( sts, "adding accept button to group" ) )
      return;

    sts = FIg_add_to_group( ex2_form, FI_CANCEL, FI_CTRL_GROUP );
    if ( chkerror( sts, "adding cancel button to group" ) )
      return;

    sts = FIg_add_to_group( ex2_form, FI_HELP, FI_CTRL_GROUP );
    if ( chkerror( sts, "adding help button to group" ) )
      return;

/*
 *  Make the help button automatically pop up
 */
    sts = FIbtn_set_auto_pop_up_on( ex2_form, FI_HELP );
    if ( chkerror( sts, "turn on auto pop up" ) )
      return;


/*
 *  Set the control bar buttons' attributes.
 */
    sts = FIg_set_attr ( ex2_form, FI_CTRL_GROUP, 0 );
    if ( chkerror( sts, "setting control bar gadget attributes" ) )
      return;


/*
 *  Let the forms system preload the needed symbols.
 */
    sts = FIg_activate( ex2_form, FI_CTRL_GROUP );
    if ( chkerror( sts, "activating control bar" ) )
      return;


/*
 *  Display the gadgets.
 */
    sts = FIg_display( ex2_form, FI_CTRL_GROUP );
    if ( chkerror( sts, "displaying control bar buttons" ) )
      return;

  }
}
