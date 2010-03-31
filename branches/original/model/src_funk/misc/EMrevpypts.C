/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/*
  Given a linked list of EMpypoint(s), this function reverses the order
  of the first "num" elements of the list, in place. If "num" is NULL,
  the entire list is reversed.
*/

#include "OMprimitives.h"   /* OM primitives    */

/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */

/* gr.h replacement */

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

/* end of gr.h replacement */
#include "msdef.h"
#include "emsdattyp.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSerrnumdef.h"
#include "EMSerrordef.h"

void EMrevpypts (msg, pypts, num)
IGRlong *msg;
struct EMSpypoint **pypts;
IGRint num;
{
  IGRboolean flag, null_terminate;
  IGRint i, j, num_flips, count, num_elems;
  struct EMSpypoint *pyptr, **pyarray, *pytemp;

  *msg = MSSUCC;

  pyarray = NULL;
  if (pypts)
    {
    /*
     * Obtain the number of elements in the
     * list that are to be reversed.
     */

    flag = num ? TRUE : FALSE;
    count = 0;
    pyptr = *pypts;
    while ((flag ? num-- : TRUE) && pyptr)
      {
      count++;
      pyptr = pyptr->next;
      }
    if (pyptr) 
      null_terminate = FALSE;
    else
      null_terminate = TRUE;

    /*
     * Copy the pointers of each element into an
     * array.
     */
    
    num_elems = count + (!null_terminate ? 1 : 0);
    pyarray = (struct EMSpypoint **) om$malloc (size = num_elems *
               sizeof (struct EMSpypoint *));
    EMerr_hndlr (!pyarray, *msg, MSNOMEM, ret_end);

    pyptr = *pypts;
    for (i=0; i<count + (!null_terminate ? 1 : 0); i++)
      {
      pyarray[i] = pyptr;
      pyptr = pyptr->next;
      }

    /*
     * Reverse this array of pointers and
     * make the new linked list, with this
     * changed order.
     */

    num_flips = count / 2;
    for (i=0, j=count-1; i<num_flips; i++, j--)
      {
      pytemp = pyarray[i];
      pyarray[i] = pyarray[j];
      pyarray[j] = pytemp;
      }
    *pypts = pyarray[0];
    pyptr = *pypts;
    for (i=1; i<count; i++)
      {
      pyptr->next = pyarray[i];
      pyptr = pyptr->next;
      }
    if (null_terminate)
      pyptr->next = NULL;
    else
      pyptr->next = pyarray[count];
    }
  else
    *msg = MSINARG;

ret_end:
  if (pyarray) om$dealloc (ptr = pyarray);
}
