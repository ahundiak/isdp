/*
 *  switch_symbol( form, gadget_label, sym_index );
 *
 *  This function will erase the gadget, set the new symbol index, and 
 *  redisplay the gadget.
 *
 */

#include <FI.h>
#include <FIdyn.h>
#include "ex1.h"
#include "ex1gvare.h"

void switch_symbol( form, gadget_label, sym_index )
  Form form;
  int gadget_label;
  int sym_index;
{
  int sts;

/*
 *  Erase the old symbol.
 */
  sts = FIg_erase( form, gadget_label );
  if ( chkerror( sts, "erasing the symbol" ) )
    return;

/*
 *  Set the index of the new symbol.
 */
  sts = FIg_set_off_symbol_index( form, gadget_label, sym_index );
  if ( chkerror( sts, "setting the symbol index" ) )
    return;

/*
 *  Display the symbol.
 */
  sts = FIg_display( form, gadget_label );
  chkerror( sts, "displaying the symbol" );

}
