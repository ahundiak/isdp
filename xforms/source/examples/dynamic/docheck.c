/*  void do_check()
 *
 *  This function dynamically creates a simple checklist gadget.
 */

#include <stdio.h>
#include "FI.h"
#include "FIdyn.h"
#include "ex2.h"
#include "ex2gvare.h"

void do_check()
{
  int sts;
  
  if ( ! check_defined ) {

/*
 *  If the button has not been created previously, do it now.
 */
    sts = FIg_new( ex2_form, FI_CHECKLIST, CHECK_GADGET );
    if ( chkerror( sts, "creating checklist" ) )
      return;
    check_defined = TRUE;

/*
 *  Set up the standard variables structure with the needed
 *  values and call FIg_set_standard_variables.
 */
    std_var.xlo = 40;
    std_var.ylo = 300;
    std_var.bodysize = 13;
    std_var.text = "Checklist";
    std_var.fontname = "swiss742b";
    std_var.value = 0.0;
    std_var.on_color = FI_BLACK;

    sts = FIg_set_standard_variables( ex2_form, CHECK_GADGET,
                                      &std_var );
    if ( chkerror( sts, "setting checklist variables" ) )
      return;

/*
 *  Let the forms system preload the needed fonts.
 */
    sts = FIg_activate( ex2_form, CHECK_GADGET );
    if ( chkerror( sts, "activating checklist" ) )
      return;

/*
 *  Put the checklist in our gadgets group for display, delete,
 *  and erase operations.
 */
    sts = FIg_add_to_group( ex2_form, CHECK_GADGET,
                            GADGET_GROUP );
    if ( chkerror( sts, "adding checklist to group" ) )
      return;

/*
 *  Display the gadget.
 */
    sts = FIg_display( ex2_form, CHECK_GADGET );
    if ( chkerror( sts, "displaying checklist" ) )
      return;

  }
}
