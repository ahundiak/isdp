/*  void do_line()
 *
 *  This function will create a simple line gadget.
 */
 
#include <stdio.h>
#include "FI.h"
#include "FIdyn.h"
#include "ex2.h"
#include "ex2gvare.h"


void do_line()
{
  int sts;
  
  if ( ! line_defined ) {

/*
 *  If the line has not been created previously, do it now.
 */
    sts = FIg_new( ex2_form, FI_LINE, LINE_GADGET );
    if ( chkerror( sts, "creating line" ) )
      return;
    line_defined = TRUE;

/*
 *  Set up the standard variables structure with the needed
 *  values and call FIg_set_standard_variables.
 */
    std_var.xlo = 120;
    std_var.ylo = 28;
    std_var.xhi = 600;
    std_var.yhi = 28;
    std_var.off_color = FI_BLACK;

    sts = FIg_set_standard_variables( ex2_form, LINE_GADGET,
                                      &std_var );
    if ( chkerror( sts, "setting line variables" ) )
      return;

/*
 *  Set the line depth to 3-D (simulated).
 */
    sts = FIg_set_line_depth( ex2_form, LINE_GADGET, FI_3D_LINE );
    if ( chkerror( sts, "setting line depth" ) )
      return;

/*
 *  Set the line style to a solid pattern (0xFFFFFFFF = all bits).
 */
    sts = FIg_set_line_style( ex2_form, LINE_GADGET, 0xFFFFFFFF );
    if ( chkerror( sts, "setting line style" ) )
      return;

/*
 *  Set the line weight (0 = 1 pixel.)
 */
    sts = FIg_set_line_weight( ex2_form, LINE_GADGET, 0 );
    if ( chkerror( sts, "setting line weight" ) )
      return;

/*
 *  Put the line in our gadgets group for display, delete,
 *  and erase operations.
 */
    sts = FIg_add_to_group( ex2_form, LINE_GADGET, GADGET_GROUP );
    if ( chkerror( sts, "adding line to group" ) )
      return;

/*
 *  Display the gadget.
 */
    sts = FIg_display( ex2_form, LINE_GADGET );
    if ( chkerror( sts, "displaying line" ) )
      return;

  }
}
