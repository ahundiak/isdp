/*  void do_scroll()
 *
 *  This function is an example of the dynamic creation of
 *  a scroll gadget.
 */

#include <stdio.h>
#include "FI.h"
#include "FIdyn.h"
#include "ex2.h"
#include "ex2gvare.h"

void do_scroll()
{
  int sts;
  
  if ( ! scroll_defined ) {
  	
/*
 *  If the scroll has not been created previously, do it now.
 */
    sts = FIg_new( ex2_form, FI_SCROLL, SCROLL_GADGET );
    if ( chkerror( sts, "creating scroll" ) )
      return;

    scroll_defined = TRUE;

/*
 *  Set up the standard variables structure with the needed
 *  values and call FIg_set_standard_variables.
 */
    std_var.xlo = 550;
    std_var.ylo = 150;
    std_var.xhi = 750;
    std_var.yhi = 190;
    std_var.value = 5.0;
    std_var.off_color = FI_RED;

    sts = FIg_set_standard_variables( ex2_form, SCROLL_GADGET,
                                      &std_var );
    if ( chkerror( sts, "setting scroll variables" ) )
      return;
    
/*
 *  Set the orientation of this scroll to horizontal.
 */
    sts = FIg_set_orientation( ex2_form, SCROLL_GADGET,
                               FI_HORIZONTAL );
    if ( chkerror( sts, "setting scroll orientation" ) )
      return;

/*
 *  Set the low value to 0.0 and the high value to 10.0.
 */
    sts = FIg_set_low_value( ex2_form, SCROLL_GADGET, 0.0 );
    if ( chkerror( sts, "setting scroll low value" ) )
      return;
    
    sts = FIg_set_high_value( ex2_form, SCROLL_GADGET, 360.0 );
     if ( chkerror( sts, "setting scroll high value" ) )
      return;

/*
 *  Set the puck percentage to 10 percent.
 */
   sts = FIscrl_set_view( ex2_form, SCROLL_GADGET, 0.1 );
    if ( chkerror( sts, "setting scroll view percentage" ) )
      return;

/*
 *  Let the forms system preload the needed symbols.
 */
    sts = FIg_activate( ex2_form, SCROLL_GADGET );
    if ( chkerror( sts, "activating scroll" ) )
      return;

/*
 *  Put the scroll in our gadgets group for display, delete,
 *  and erase operations.
 */
    sts = FIg_add_to_group( ex2_form, SCROLL_GADGET,
                            GADGET_GROUP );
    if ( chkerror( sts, "adding scroll to group" ) )
      return;

/*
 *  Display the gadget.
 */
    sts = FIg_display( ex2_form, SCROLL_GADGET );
    if ( chkerror( sts, "displaying scroll" ) )
      return;

/*
 *  If the dial is there, set up the datalink between this scroll
 *  bar and the dial.
 */
    if ( dial_defined ) {
      sts = FIg_set_pass_data( ex2_form, SCROLL_GADGET,
                               DIAL_GADGET );
      if ( chkerror( sts, "setting datalink (scroll/dial)" ) )
        return;
    }

    FIg_set_pass_data( ex2_form, DIAL_GADGET, SCROLL_GADGET );
  }
}
