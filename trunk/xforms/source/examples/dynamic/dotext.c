/*  void do_text()
 *
 *  This function will create a text simple text gadget.
 */

#include <stdio.h>
#include "FI.h"
#include "FIdyn.h"
#include "ex2.h"
#include "ex2gvare.h"

void do_text()
{
  int sts;
  
  if ( ! text_defined ) {
  	
/*
 *  If the text has not been created previously, do it now.
 */
    sts = FIg_new( ex2_form, FI_TEXT, TEXT_GADGET );
    if ( chkerror( sts, "creating text" ) )
      return;

    text_defined = TRUE;
    
/*
 *  Set up the standard variables structure with the needed
 *  values and call FIg_set_standard_variables.
 */
    std_var.xlo = 10;
    std_var.ylo = 10;
    std_var.xhi = 200;
    std_var.yhi = 50;
    std_var.bodysize = 24;
    std_var.text = "Example 2";
    std_var.fontname = "swiss742b";
    std_var.on_color = FI_BLACK;
    std_var.off_color = FI_BLACK;

    sts = FIg_set_standard_variables( ex2_form, TEXT_GADGET,
                                      &std_var );
    if ( chkerror( sts, "setting text variables" ) )
      return;

/*
 *  Let the forms system preload the needed fonts.
 */
    sts = FIg_activate( ex2_form, TEXT_GADGET );
    if ( chkerror( sts, "activating text" ) )
      return;
    
/*
 *  Put the text in our gadgets group for display, delete,
 *  and erase operations.
 */
    FIg_add_to_group( ex2_form, TEXT_GADGET, GADGET_GROUP );
    if ( chkerror( sts, "adding text to group" ) )
      return;

/*
 *  Display the gadget.
 */
    sts = FIg_display( ex2_form, TEXT_GADGET );
    if ( chkerror( sts, "display text" ) )
      return;

  }
}
