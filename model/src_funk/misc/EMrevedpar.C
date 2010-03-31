/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/*
  Given a linked list of EMsfintedpar(s), this function reverses the order
  of the first "num" elements of the list, in place. If "num" is NULL,
  the entire list is reversed.
*/

# include "OMprimitives.h" /* om$malloc and om$dealloc */
# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "OMminimum.h"
# include "igetypedef.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "EMSbnddef.h"
# include "emsdattyp.h"
# include "emsinter.h"
# include "EMSbnd.h"
# include "emssfint.h"
# include "emserr.h"
# include "emsdef.h"
# include "EMSerrnumdef.h"
# include "EMSerrordef.h"

void EMrevsfintedpar (msg, sfintedpar, num)
IGRlong *msg;
struct EMSsfintedpar **sfintedpar;
IGRint num;
{
  IGRboolean flag, null_terminate;
  IGRint i, j, num_flips, count, num_elems;
  struct EMSsfintedpar *sfintedpar_ptr, **sfintedpar_array, *sfintedpar_temp;

  *msg = EMS_S_Success;

  sfintedpar_array = NULL;
  if (sfintedpar)
    {
    /*
     * Obtain the number of elements in the
     * list that are to be reversed.
     */

    flag = num ? TRUE : FALSE;
    count = 0;
    sfintedpar_ptr = *sfintedpar;
    while ((flag ? num-- : TRUE) && sfintedpar_ptr)
      {
      count++;
      sfintedpar_ptr = sfintedpar_ptr->next;
      }
    if (sfintedpar_ptr) 
      null_terminate = FALSE;
    else
      null_terminate = TRUE;

    /*
     * Copy the pointers of each element into an
     * array.
     */
    
    num_elems = count + (!null_terminate ? 1 : 0);
    sfintedpar_array = (struct EMSsfintedpar **) om$malloc (size = num_elems *
               sizeof (struct EMSsfintedpar *));
    EMerr_hndlr (!sfintedpar_array, *msg,EMS_E_NoDynamicMemory, ret_end);

    sfintedpar_ptr = *sfintedpar;
    for (i=0; i<count + (!null_terminate ? 1 : 0); i++)
      {
      sfintedpar_array[i] = sfintedpar_ptr;
      sfintedpar_ptr = sfintedpar_ptr->next;
      }

    /*
     * Reverse this array of pointers and
     * make the new linked list, with this
     * changed order.
     */

    num_flips = count / 2;
    for (i=0, j=count-1; i<num_flips; i++, j--)
      {
      sfintedpar_temp = sfintedpar_array[i];
      sfintedpar_array[i] = sfintedpar_array[j];
      sfintedpar_array[j] = sfintedpar_temp;
      }
    *sfintedpar = sfintedpar_array[0];
    sfintedpar_ptr = *sfintedpar;
    for (i=1; i<count; i++)
      {
      sfintedpar_ptr->next = sfintedpar_array[i];
      sfintedpar_ptr = sfintedpar_ptr->next;
      }
    if (null_terminate)
      sfintedpar_ptr->next = NULL;
    else
      sfintedpar_ptr->next = sfintedpar_array[count];
    }
  else
    *msg = EMS_E_InvalidArg;

ret_end:
  if (sfintedpar_array) om$dealloc (ptr = sfintedpar_array);
}
