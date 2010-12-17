/*  void do_dial()
 *
 *  This function dynamically creates a dial gadget.  It will
 *  have a range of 0 to 10.0 with current, low, and high
 *  values displayed.  It will have a shelf border.
 */

#include <stdio.h>
#include "FI.h"
#include "FIdyn.h"
#include "ex2.h"
#include "ex2gvare.h"

/* 
 *  This mask will be used in FIg_set_display.  This will cause
 *  the slider do display current, low and high values
 */
#define DISPLAY_MASK FI_LOW_VALUE | FI_VALUE | FI_HIGH_VALUE

void do_dial()
{
  int sts;
  
  if ( ! dial_defined ) {

/*
 *  If the dial has not been created previously, do it now.
 */
    sts = FIg_new( ex2_form, FI_DIAL, DIAL_GADGET );
    if ( chkerror( sts, "creating dial" ) )
      return;

    dial_defined = TRUE;

/*
 *  Set up the standard variables structure with the needed
 *  values and call FIg_set_standard_variables.
 */
    std_var.xlo = 550;
    std_var.ylo = 210;
    std_var.xhi = 750;
    std_var.yhi = 410;
    std_var.bodysize = 20.0;
    std_var.fontname = "swiss742b";
    std_var.value = 5.0;
    std_var.off_color = FI_BLACK;

    sts = FIg_set_standard_variables( ex2_form, DIAL_GADGET,
                                      &std_var );
    if ( chkerror( sts, "setting dial variables" ) )
      return;

/*
 *  Set the number of displayed ticks to 10.
 *  In the future, there will be major and minor ticks.
 */
    sts = FIg_set_minor_increments ( ex2_form, DIAL_GADGET, 10 );
    if ( chkerror( sts, "setting dial ticks" ) )
      return;

/*
 *  Set the orientation of dial rotation to clockwise.
 */
    sts = FIg_set_orientation( ex2_form, DIAL_GADGET, FI_CLOCKWISE );
    if ( chkerror( sts, "setting dial direction" ) )
      return;

/*
 *  Set the location of the zero point to 90 degrees (from
 *  3 o'clock.)
 */
    sts = FIdial_set_zero_location( ex2_form, DIAL_GADGET,
                                    90.0 );
    if ( chkerror( sts, "setting dial zero" ) )
      return;

/*
 *  Set the dial range (or high value) to 10.0.
 */
    sts = FIdial_set_range( ex2_form, DIAL_GADGET, 360.0 );
    if ( chkerror( sts, "setting dial range" ) )
      return;

/*
 *  Set the display mask (display all.)
 */
    sts = FIg_set_display( ex2_form, DIAL_GADGET, DISPLAY_MASK );
    if ( chkerror( sts, "setting dial display" ) )
      return;

/*
 *  Set the value format to 2 integral digits plus 1 digit
 *  to the right of the decimal point.
 */
    sts = FIg_set_value_format( ex2_form, DIAL_GADGET, 4, 1 );
    if ( chkerror( sts, "setting dial value format" ) )
      return;

/*
 *  Let the forms system preload the needed fonts.
 */
    sts = FIg_activate( ex2_form, DIAL_GADGET );
    if ( chkerror( sts, "activating dial" ) )
      return;
    
/*
 *  Put the dial in our gadgets group for display, delete,
 *  and erase operations.
 */
    sts = FIg_add_to_group( ex2_form, DIAL_GADGET,
                            GADGET_GROUP );
    if ( chkerror( sts, "adding dial to group" ) )
      return;

/*
 *  Display the gadget.
 */
    sts = FIg_display( ex2_form, DIAL_GADGET );
    if ( chkerror( sts, "displaying dial" ) )
      return;

/*
 *  If the scroll bar is there, set up the datalink between this
 *  scroll bar and the dial.
 */
    if ( scroll_defined ) {
      sts = FIg_set_pass_data( ex2_form, SCROLL_GADGET,
                               DIAL_GADGET );
      if ( chkerror( sts, "setting datalink (scroll/dial)" ) )
        return;
    }

    FIg_set_pass_data( ex2_form, DIAL_GADGET, SCROLL_GADGET );
  }
}
