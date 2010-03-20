/*  void do_button()
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

void do_button()
{
  int sts;
  
  if ( ! button_defined ) {

/*
 *  If the button has not been created previously, do it now.
 */
    sts = FIg_new( ex2_form, FI_BUTTON, BUTTON_GADGET );
    if ( chkerror( sts, "creating button" ) )
      return;

    button_defined = TRUE;

/*
 *  Set up the standard variables structure with the needed
 *  values and call FIg_set_standard_variables.
 */
    std_var.xlo = 40;
    std_var.ylo = 180;
    std_var.xhi = 110;
    std_var.yhi = 210;
    std_var.bodysize = 13;
    std_var.text = "Button";
    std_var.fontname = "swiss742b";
    std_var.value = 0.0;
    std_var.on_color = FI_GREEN;
    std_var.off_color = FI_BLACK;

    FIg_set_standard_variables( ex2_form, BUTTON_GADGET,
                                &std_var );
    if ( chkerror( sts, "setting button variables" ) )
      return;

/* 
 *  Set the button to auto pop up.
 */
    sts = FIbtn_set_auto_pop_up_on( ex2_form, BUTTON_GADGET );
    if ( chkerror( sts, "setting button to auto pop up" ) )
      return;

/*
 *  Let the forms system preload the needed fonts.
 */
    sts = FIg_activate( ex2_form, BUTTON_GADGET );
    if ( chkerror( sts, "activating button" ) )
      return;
    
/*
 *  Put the button in our gadgets group for display, delete,
 *  and erase operations.
 */
    sts = FIg_add_to_group( ex2_form, BUTTON_GADGET,
                            GADGET_GROUP );
    if ( chkerror( sts, "adding button to group" ) )
      return;

/*
 *  Display the gadget.
 */
    sts = FIg_display( ex2_form, BUTTON_GADGET );
    if ( chkerror( sts, "displaying button" ) )
      return;

  }
}
