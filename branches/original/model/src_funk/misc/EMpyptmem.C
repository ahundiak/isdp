/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
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
#include "emsdef.h"
#include "emsdattyp.h"
#include "emserr.h"
#include "EMSerrnumdef.h"
#include "EMSerrordef.h"

/*
 * This function is the one that should be used when
 * allocating memory for elements of the linked list
 * made up of EMSpypoint(s). 
 * The "next" pointer is set to NULL;
 */

struct EMSpypoint *EMpypoint_malloc (msg, num)
IGRlong *msg;
IGRint num;
{
  IGRint i;
  struct EMSpypoint *pyptr, *temp_ptr;

  *msg = EMS_S_DynamicMemoryAllocated;

  pyptr = (struct EMSpypoint *) malloc (sizeof (struct EMSpypoint));
  EMerr_hndlr (!pyptr, *msg, EMS_E_DynamicMemoryAllocated, ret_end);

  pyptr->next = NULL;
  pyptr->props = EMS_PYPT_EMPTY | EMS_PYPT_MALLOCED;
  pyptr->info = NULL;

  temp_ptr = pyptr;
  for (i=1; i<num; i++)
    {
    temp_ptr->next = (struct EMSpypoint *) malloc (sizeof
             (struct EMSpypoint));
    EMerr_hndlr (!temp_ptr->next, *msg, EMS_E_DynamicMemoryAllocated, ret_end);

    temp_ptr->next->props = EMS_PYPT_EMPTY | EMS_PYPT_MALLOCED;
    temp_ptr->next->info = NULL;
    temp_ptr->next->next = NULL;

    temp_ptr = temp_ptr->next;
    }

ret_end:
  return (pyptr);
}


/*
 * This function should be used to free memory allocated
 * to the linked list - "pypts". The linked list is expected
 * to be NULL-terminated. 
 * The actual number of nodes processed is dependent on the argument -
 * "num". Only "num" number of nodes are processed in the linked list.
 * If the list terminates before "num" nodes, processing terminates,
 * having processed all the nodes. Also, if "num" is NULL, it is assumed that
 * the entire list is to be processed.
 */

void EMpypoint_free (pypts, num)
struct EMSpypoint *pypts;
IGRint num;
{
  IGRboolean flag;
  struct EMSpypoint *temp_pyptr;

  if (pypts)
    {
    flag = (num ? TRUE: FALSE);
    while ((flag ? num-- : TRUE) && pypts)
      {
          if(pypts->props & EMS_PYPT_MALLOCED)
          {
          temp_pyptr = pypts->next;
          free (pypts);
          pypts = temp_pyptr;
          }
          else break;
      }
    }
}

/*
 * This function collects all malloced nodes of a pypoint list and 
 * and rearranges them. It returns the beginning address of the malloced
 * list and null terminates the last node. If there are no malloced 
 * entities then a NULL is returned as the address of the beginning of the
 * list. It expects the incoming list to be null terminated.
 */

void EMcollect_mpy (pypts, mpyptr)
struct EMSpypoint *pypts, **mpyptr;
{
     IGRboolean headfound;
     struct EMSpypoint *endpy, *pyptr;

     endpy = pyptr = NULL;
     headfound = FALSE;
     *mpyptr = NULL;

     pyptr = pypts;
     while (pyptr)
     {
      if (pyptr->props & EMS_PYPT_MALLOCED)
      {
        if (!headfound)
        {
         *mpyptr = pyptr;
         headfound = TRUE;
        }
        else
         endpy->next = pyptr;
        endpy = pyptr; 
      }
      pyptr = pyptr->next;
     }
       if (headfound)
        endpy->next = NULL;

  return;
 }


