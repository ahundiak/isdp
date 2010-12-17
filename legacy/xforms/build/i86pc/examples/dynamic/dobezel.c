/*  void do_bezel()
 *
 *  This function will create a bezel gadget with
 *  a raised look.
 */

#include <stdio.h>
#include "FI.h"
#include "FIdyn.h"
#include "ex2.h"
#include "ex2gvare.h"

  
void do_bezel()
{
  int sts;
  if ( ! bezel_defined ) {
  	
/*
 *  If the dial has not been created previously, do it now.
 */
    sts = FIg_new( ex2_form, FI_BEZEL, BEZEL_GADGET );
    if ( chkerror( sts, "creating bezel" ) )
      return;

    bezel_defined = TRUE;

/*
 *  Set up the standard variables structure with the needed values
 *  and call FIg_set_standard_variables.
 */
    std_var.xlo = 20;
    std_var.ylo = 40;
    std_var.xhi = 160;
    std_var.yhi = 160;
    std_var.value = 0.0;
    std_var.text = "bezeltext";
    std_var.off_color = FI_LT_GREY;

    sts = FIg_set_standard_variables( ex2_form, BEZEL_GADGET,
                                      &std_var );
    if ( chkerror( sts, "setting bezel variables" ) )
      return;
    
/*
 *  Put the dial in our gadgets group for display, delete,
 *  and erase operations.
 */
    sts = FIg_add_to_group( ex2_form, BEZEL_GADGET,
                            GADGET_GROUP );
    if ( chkerror( sts, "adding bezel " ) )
      return;

/*
 *  Display the gadget.
 */
    sts = FIg_display( ex2_form, BEZEL_GADGET );
    if ( chkerror( sts, "displaying bezel" ) )
      return;

  }
}
