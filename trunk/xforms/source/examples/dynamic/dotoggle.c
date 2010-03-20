/*  void do_toggle()
 *
 *  This function will dynamically create a toggle gadget.
 *  The toggle will display text and will display it in
 *  green in the on state.  The initial value will be
 *  set the 0.0 which means it will be created in the
 *  off state.
 */
 
#include <stdio.h>
#include "FI.h"
#include "FIdyn.h"
#include "ex2.h"
#include "ex2gvare.h"

void do_toggle()
{
  int sts;
  
  if ( ! toggle_defined ) {

/*
 *  If the toggle has not been created previously, do it now.
 */
    sts = FIg_new( ex2_form, FI_TOGGLE, TOGGLE_GADGET );
    if ( chkerror( sts, "creating toggle" ) )
      return;

    toggle_defined = TRUE;
    
/*
 *  Set up the standard variables structure with the needed
 *  values and call FIg_set_standard_variables.
 */
    std_var.xlo = 40;
    std_var.ylo = 230;
    std_var.xhi = 110;
    std_var.yhi = 280;
    std_var.bodysize = 13;
    std_var.text = "Off";
    std_var.fontname = "swiss742b";
    std_var.value = 0.0;
    std_var.on_color = FI_GREEN;
    std_var.off_color = FI_BLACK;

    sts = FIg_set_standard_variables( ex2_form, TOGGLE_GADGET, &std_var );
    if ( chkerror( sts, "setting toggle variables" ) )
      return;

/*
 *  Set the text to be displayed when the toggle is in the
 *  on state.  (The off state text was set in the the text
 *  variable in the standard variables structure.)
 */
    sts = FIg_set_on_text( ex2_form, TOGGLE_GADGET, "On" );
    if ( chkerror( sts, "setting toggle on text" ) )
      return;
    
/*
 *  Let the forms system preload the needed fonts.
 */
    sts = FIg_activate( ex2_form, TOGGLE_GADGET );
    if ( chkerror( sts, "activating toggle" ) )
      return;
    
/*
 *  Put the button in our gadgets group for display, delete,
 *  and erase operations.
 */
    sts = FIg_add_to_group( ex2_form, TOGGLE_GADGET,
                            GADGET_GROUP );
    if ( chkerror( sts, "adding toggle to group" ) )
      return;
    
/*
 *  Display the gadget.
 */
    sts = FIg_display( ex2_form, TOGGLE_GADGET );
    if ( chkerror( sts, "displaying toggle" ) )
      return;

  }
}
