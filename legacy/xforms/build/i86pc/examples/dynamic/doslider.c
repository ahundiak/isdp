/*  void do_slider()
 *
 *  This function is an example of the dynamic creation of
 *  a slider gadget.  This slider will have all values displayed
 *  in a format of dd and have a range of 0 - 10.  The
 *  orientation of this slider will be horizontal.
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


void do_slider()
{
  int sts;
  
  if ( ! slider_defined ) {
  	
/*
 *  If the slider has not been created previously, do it now.
 */
    sts = FIg_new( ex2_form, FI_SLIDER, SLIDER_GADGET );
    if ( chkerror( sts, "creating slider" ) )
      return;

    slider_defined = TRUE;

/*
 *  Set up the standard variables structure with the needed
 *  values and call FIg_set_standard_variables.
 */
    std_var.xlo = 50;
    std_var.ylo = 350;
    std_var.xhi = 500;
    std_var.yhi = 400;
    std_var.bodysize = 20.0;
    std_var.fontname = "swiss742b";
    std_var.value = 50.0;
    std_var.off_color = FI_RED;
    std_var.on_color  = FI_BLACK;    

    sts = FIg_set_standard_variables( ex2_form, SLIDER_GADGET,
                                      &std_var );
    if ( chkerror( sts, "setting slider variables" ) )
      return;
    
/*
 *  Set the orientation of this slider to horizontal.
 */
    sts = FIg_set_orientation( ex2_form, SLIDER_GADGET,
                               FI_HORIZONTAL );
    if ( chkerror( sts, "setting slider orientation" ) )
      return;

/*
 *  Set the low value to 0.0 and the high value to 100.0.
 */
    sts = FIg_set_low_value( ex2_form, SLIDER_GADGET, 0.0 );
    if ( chkerror( sts, "setting slider low value" ) )
      return;
    
    sts = FIg_set_high_value( ex2_form, SLIDER_GADGET, 100.0 );
     if ( chkerror( sts, "setting slider high value" ) )
      return;

/*
 *  Tell the slider which values to display (all of them.)
 */
   sts = FIg_set_display( ex2_form, SLIDER_GADGET, DISPLAY_MASK );
    if ( chkerror( sts, "setting slider display" ) )
      return;

/*
 *  Set the format of the value display (2 integer places,
 *  none to right of decimal point.
 */
    sts = FIg_set_value_format( ex2_form, SLIDER_GADGET, 2, 0 );
    if ( chkerror( sts, "setting slider value format" ) )
      return;

/*
 *  Let the forms system preload the needed fonts.
 */
    sts = FIg_activate( ex2_form, SLIDER_GADGET );
    if ( chkerror( sts, "activating slider" ) )
      return;

/*
 *  Put the slider in our gadgets group for display, delete,
 *  and erase operations.
 */
    sts = FIg_add_to_group( ex2_form, SLIDER_GADGET,
                            GADGET_GROUP );
    if ( chkerror( sts, "adding slider to group" ) )
      return;

/*
 *  Display the gadget.
 */
    sts = FIg_display( ex2_form, SLIDER_GADGET );
    if ( chkerror( sts, "displaying slider" ) )
      return;

/*
 *  If the gauge is there, set up the datalink between this slider
 *  and the gauge.
 */
    if ( gauge_defined ) {
      sts = FIg_set_pass_data( ex2_form, SLIDER_GADGET,
                               GAUGE_GADGET );
      if ( chkerror( sts, "setting datalink (slider/gauge)" ) )
        return;
    }
  }
}
