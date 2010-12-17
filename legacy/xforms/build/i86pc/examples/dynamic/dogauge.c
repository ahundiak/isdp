/*  void do_gauge()
 *
 *  This function dynamically creates a gauge gadget.  It will
 *  have a range of 0 to 100.0.
 */

#include <stdio.h>
#include "FI.h"
#include "FIdyn.h"
#include "ex2.h"
#include "ex2gvare.h"

void do_gauge()
{
  int sts;
  
  if ( ! gauge_defined ) {

/*
 *  If the gauge has not been created previously, do it now.
 */
    sts = FIg_new( ex2_form, FI_GAUGE, GAUGE_GADGET );
    if ( chkerror( sts, "creating gauge" ) )
      return;

    gauge_defined = TRUE;

/*
 *  Set up the standard variables structure with the needed
 *  values and call FIg_set_standard_variables.
 */
    std_var.xlo = 150;
    std_var.ylo = 200;
    std_var.xhi = 500;
    std_var.yhi = 340;
    std_var.value = 50.0;
    std_var.off_color = FI_BLACK;
    std_var.on_color = FI_RED;

    sts = FIg_set_standard_variables( ex2_form, GAUGE_GADGET,
                                      &std_var );
    if ( chkerror( sts, "setting gauge variables" ) )
      return;

/*
 *  Set the number of segments to 20.
 */
    sts = FIg_set_minor_increments( ex2_form, GAUGE_GADGET, 20 );
    if ( chkerror( sts, "setting gauge ticks" ) )
      return;

/*
 *  Set the gauge range (or high value) to 10.0.
 */
    sts = FIg_set_high_value( ex2_form, GAUGE_GADGET, 100.0 );
    if ( chkerror( sts, "setting gauge high value" ) )
      return;

/*
 *  Set the orientation of this gauge to horizontal.
 */
    sts = FIg_set_orientation( ex2_form, GAUGE_GADGET,
                               FI_HORIZONTAL );
    if ( chkerror( sts, "setting gauge orientation" ) )
      return;

/*
 *  Put the gauge in our gadgets group for display, delete,
 *  and erase operations.
 */
    sts = FIg_add_to_group( ex2_form, GAUGE_GADGET, GADGET_GROUP );
    if ( chkerror( sts, "adding gauge to group" ) )
      return;

/*
 *  Display the gadget.
 */
    sts = FIg_display( ex2_form, GAUGE_GADGET );
    if ( chkerror( sts, "displaying gauge" ) )
      return;

/*
 *  If the slider is there, set up the datalink between this slider
 *  and the gauge.
 */
    if ( slider_defined ) {
      sts = FIg_set_pass_data( ex2_form, SLIDER_GADGET,
                               GAUGE_GADGET );
      if ( chkerror( sts, "setting datalink (slider/gauge)" ) )
        return;
    }
  }
}
