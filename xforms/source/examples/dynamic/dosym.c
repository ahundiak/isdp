/*  void do_sym()
 *
 *  This function dynamically creates a simple symbol
 *  gadget.
 */

#include <stdio.h>
#include "FI.h"
#include "FIdyn.h"
#include "ex2.h"
#include "ex2gvare.h"

void do_sym()
{
  int sts;
  
  if ( ! sym_defined ) {

/*
 *  If the dial has not been created previously, do it now.
 */
    sts = FIg_new( ex2_form, FI_SYM, SYM_GADGET );
    if ( chkerror( sts, "creating sym" ) )
      return;

    sym_defined = TRUE;

/*
 *  Set up the standard variables structure with the needed
 *  values and call FIg_set_standard_variables.
 */
    std_var.xlo = 550;
    std_var.ylo = 70;
    std_var.fontname = "menusyms";
    std_var.symbol_index = TEST_SYM;
    std_var.off_color = FI_BLACK;

    sts = FIg_set_standard_variables( ex2_form, SYM_GADGET,
                                      &std_var );
    if ( chkerror( sts, "setting symbol variables" ) )
      return;

/*
 *  Let the forms system preload the needed symbol.
 */
    sts = FIg_activate( ex2_form, SYM_GADGET );
    if ( chkerror( sts, "activating sym" ) )
      return;
   
/*
 *  Put the dial in our gadgets group for display, delete,
 *  and erase operations.
 */
    sts = FIg_add_to_group( ex2_form, SYM_GADGET, GADGET_GROUP );
    if ( chkerror( sts, "adding sym to group" ) )
      return;

/*
 *  Display the gadget.
 */
    sts = FIg_display( ex2_form, SYM_GADGET );
    if ( chkerror( sts, "displaying sym" ) )
      return;

  }
}
