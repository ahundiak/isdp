/*  void do_mcf()
 *
 *  This function is an example of the dynamic creation of
 *  a multicolumn field gadget.
 */

#include "stdio.h"
#include "FI.h"
#include "FIdyn.h"
#include "ex2.h" 
#include "ex2gvare.h"

void do_mcf()
{
  int sts;

  if ( ! mcf_defined ) {

/*
 *  If the multicolumn field has not been created previously,
 *  do it now.
 */
    sts =  FIg_new( ex2_form, FI_MULTI_COL, MCF_GADGET );
    if ( chkerror( sts, "creating multicolumn field" ) )
      return;

    mcf_defined = TRUE;

/*
 *  Set up the standard variables structure with the needed
 *  values and call FIg_set_standard_variables.
 */
    std_var.xlo = 180;
    std_var.ylo = 40;
    std_var.xhi = 590;
    std_var.yhi = 172;
    std_var.bodysize = 14.0;
    std_var.fontname =  "mono821";
    std_var.off_color = FI_BLACK;
    std_var.on_color = FI_YELLOW;

    sts = FIg_set_standard_variables( ex2_form, MCF_GADGET,
                                      &std_var );
    if ( chkerror( sts, "setting multicolumn field variables" ) )
      return;

/*
 *  Set the number of columns to 2.
 */
    sts = FImcf_set_num_cols( ex2_form, MCF_GADGET, 2 );
    if ( chkerror( sts, "setting number of columns" ) )
      return;

/*
 *  Set the size of the columns.
 */
    sts = FImcf_set_col_size( ex2_form, MCF_GADGET, 0, 120, 128 );
    if ( chkerror( sts, "setting size of column 0" ) )
      return;
    sts = FImcf_set_col_size( ex2_form, MCF_GADGET, 1, 210, 128 );
    if ( chkerror( sts, "setting size of column 1" ) )
      return;

/*
 *  Set the mode of the columns.
 */
    sts = FIfld_set_mode( ex2_form, MCF_GADGET, 0,
                          FI_SINGLE_SELECT );
    if ( chkerror( sts, "setting mode of column 0" ) )
      return;
    sts = FIfld_set_mode( ex2_form, MCF_GADGET, 1,
                          FI_SINGLE_SELECT );
    if ( chkerror( sts, "setting mode of column 1" ) )
      return;

/*
 *  Set the type of the columns.
 */
    sts = FIfld_set_type( ex2_form, MCF_GADGET, 0, FI_ALPHA );
    if ( chkerror( sts, "setting type of column 0" ) )
      return;
    sts = FIfld_set_type( ex2_form, MCF_GADGET, 1, FI_ALPHA );
    if ( chkerror( sts, "setting type of column 1" ) )
      return;

/*
 *  Let the forms system preload the needed fonts.
 */
    sts =  FIg_activate( ex2_form, MCF_GADGET );
    if ( chkerror( sts, "activating multicolumn field" ) )
      return;

/*
 *  Set the maximum number of rows.
 */
    sts = FIfld_set_num_rows( ex2_form, MCF_GADGET, 11 );
    if ( chkerror( sts, "activating setting number of rows" ) )
      return;

/*
 *  Put some text in the rows of both columns.
 */
    sts = FIfld_set_text( ex2_form, MCF_GADGET, 0, 0,
                          "Burns, Bubba", FALSE );
    sts |= FIfld_set_text( ex2_form, MCF_GADGET, 1, 0,
                           "Calloway, Calvin", FALSE );
    sts |= FIfld_set_text( ex2_form, MCF_GADGET, 2, 0,
                           "Enis, Eugene", FALSE );
    sts |= FIfld_set_text( ex2_form, MCF_GADGET, 3, 0,
                           "Felder, Floyd", FALSE );
    sts |= FIfld_set_text( ex2_form, MCF_GADGET, 4, 0,
                           "Johnson, Joe Bob", FALSE );
    sts |= FIfld_set_text( ex2_form, MCF_GADGET, 5, 0,
                           "Kindly, Kevin", FALSE );
    sts |= FIfld_set_text( ex2_form, MCF_GADGET, 6, 0,
                           "Langley, Larry", FALSE );
    sts |= FIfld_set_text( ex2_form, MCF_GADGET, 7, 0,
                           "Langley, Daryl", FALSE );
    sts |= FIfld_set_text( ex2_form, MCF_GADGET, 8, 0,
                           "Langley, Daryl", FALSE );
    sts |= FIfld_set_text( ex2_form, MCF_GADGET, 9, 0,
                           "Newton, Ned", FALSE );
    sts |= FIfld_set_text( ex2_form, MCF_GADGET, 10, 0,
                           "Zoto, Zak", FALSE );

    sts |= FIfld_set_text( ex2_form, MCF_GADGET, 0, 1,
                           "Backward St., Babbit, AL", FALSE );
    sts |= FIfld_set_text( ex2_form, MCF_GADGET, 1, 1,
                           "Country Rd., Coolwater MS", FALSE );
    sts |= FIfld_set_text( ex2_form, MCF_GADGET, 2, 1,
                           "Eel Ave., Evans, AL", FALSE );
    sts |= FIfld_set_text( ex2_form, MCF_GADGET, 3, 1,
                           "Founders St., Flamingo, FL", FALSE );
    sts |= FIfld_set_text( ex2_form, MCF_GADGET, 4, 1,
                           "Jeff Rd., Jackson TN", FALSE );
    sts |= FIfld_set_text( ex2_form, MCF_GADGET, 5, 1,
                          "Kings Ave., Kingston, TN", FALSE );
    sts |= FIfld_set_text( ex2_form, MCF_GADGET, 6, 1,
                           "Lindburg Ave., Lynchburg, TN",
                           FALSE );
    sts |= FIfld_set_text( ex2_form, MCF_GADGET, 7, 1,
                           "Lindburg Ave., Lynchburg, TN",
                           FALSE );
    sts |= FIfld_set_text( ex2_form, MCF_GADGET, 8, 1,
                           "Lindburg Ave., Lynchburg, TN",
                           FALSE );
    sts |= FIfld_set_text( ex2_form, MCF_GADGET, 9, 1,
                           "Newberry Rd., Nextto, GA", FALSE );
    sts |= FIfld_set_text( ex2_form, MCF_GADGET, 10, 1,
                           "Zoo St., Zipcode, AL", FALSE );
    if ( chkerror( sts,
              "activating setting text in multicolumn field" ) )
      return;

/*
 *  Put the field in our gadgets group for display, delete,
 *  and erase operations.
 */
    sts = FIg_add_to_group( ex2_form, MCF_GADGET, GADGET_GROUP );
    if ( chkerror( sts, "adding multicolumn to group" ) )
      return;

/*
 *  Display the gadget.
 */
    sts = FIg_display( ex2_form, MCF_GADGET );
    if ( chkerror( sts, "displaying multicolumn" ) )
      return;

  }
}
