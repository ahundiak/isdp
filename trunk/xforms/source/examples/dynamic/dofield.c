/*  void do_field()
 *
 */

#include <stdio.h>
#include "FI.h"
#include "FIdyn.h"
#include "ex2.h"
#include "ex2gvare.h"

void do_field()
{
  int sts;
  
  if ( ! field_defined ) {

/*
 *  If the field has not been created previously, do it now.
 */
    sts = FIg_new( ex2_form, FI_FIELD, FIELD_GADGET );
    if ( chkerror( sts, "creating field" ) )
      return;

    field_defined = TRUE;

/*
 *  Set up the standard variables structure with the needed
 *  values and call FIg_set_standard_variables.
 */
    std_var.xlo = 20;
    std_var.ylo = 430;
    std_var.xhi = 280;
    std_var.yhi = 445;
    std_var.bodysize = 14;
    std_var.fontname = "mono821";
    std_var.off_color = FI_BLACK;
    std_var.on_color = FI_YELLOW;

    sts = FIg_set_standard_variables( ex2_form, FIELD_GADGET,
                                      &std_var );
    if ( chkerror( sts, "setting field variables" ) )
      return;

/*
 *  Set the field attributes.
 */

    sts = FIfld_set_attr( ex2_form, FIELD_GADGET, 0,
                          FI_HORT_SCROLL );

    if ( chkerror( sts, "setting field attributes" ) )
      return;



/*
 *  Set the field type.
 */

   sts = FIfld_set_type( ex2_form, FIELD_GADGET, 0, FI_ALPHA );
   if ( chkerror( sts, "setting field type" ) )
     return;

/*
 *  Set the default text.
 */
   sts = FIfld_set_default_text( ex2_form,
                                 FIELD_GADGET,
                                 0,
                                 0,
                                 "this is a test",
                                 FALSE );
    if ( chkerror( sts, "setting default text" ) )
      return;
/*
 *  Set the maximum number of rows.
 */
   sts = FIfld_set_max_num_rows( ex2_form, FIELD_GADGET, 1 );
   if ( chkerror( sts, "setting max field rows" ) )
     return;

/*
 *  Let the forms system preload the needed fonts.
 */
    sts = FIg_activate( ex2_form, FIELD_GADGET );
    if ( chkerror( sts, "activating field" ) )
      return;

/*
 *  Set the number of rows.
 */
    sts = FIfld_set_num_rows( ex2_form, FIELD_GADGET, 1 );
    if ( chkerror( sts, "setting field rows" ) )
      return;
    
/*
 *  Put the field in our gadgets group for display, delete,
 *  and erase operations.
 */
    sts = FIg_add_to_group( ex2_form, FIELD_GADGET,
                            GADGET_GROUP );
    if ( chkerror( sts, "adding field to group" ) )
      return;

/*
 *  Display the gadget.
 */
    sts = FIg_reset(ex2_form, FIELD_GADGET);
    sts = FIg_display( ex2_form, FIELD_GADGET );
    if ( chkerror( sts, "displaying field" ) )
      return;

  }
}
