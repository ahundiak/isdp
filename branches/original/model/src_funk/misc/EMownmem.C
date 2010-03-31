/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
#include "OMprimitives.h"       /* OM primitives    */
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "dp.h"
#include "godef.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emserr.h"
#include "EMSmsgdef.h"

/*
 * This function is the one that should be used when
 * allocating memory for elements of the linked list
 * made up of EMSownercomp(s). 
 * The fields are initialized and the "next" pointer 
 * is set to NULL;
 */

struct EMSownercomp *EMownercomp_malloc (msg, num)
IGRlong *msg;
IGRint num;
{
  IGRint i;
  struct EMSownercomp *owptr, *temp_ptr;

  *msg = EMS_S_DynamicMemoryAllocated;

  owptr = (struct EMSownercomp *) om$malloc (size = 
           sizeof (struct EMSownercomp));
  EMerr_hndlr (!owptr, *msg, EMS_E_DynamicMemoryAllocated, ret_end);

  owptr->owner = NULL_OBJID;
  owptr->num_comps = 0;
  owptr->comps = NULL;
  owptr->ownerindex = NULL;
  owptr->next = NULL;
 
  temp_ptr = owptr;
  for (i=1; i<num; i++)
    {
    temp_ptr->next = (struct EMSownercomp *) om$malloc (size = sizeof
                      (struct EMSownercomp));
    EMerr_hndlr (!temp_ptr->next, *msg, EMS_E_DynamicMemoryAllocated, ret_end);
    temp_ptr = temp_ptr->next;

    temp_ptr->owner = NULL_OBJID;
    temp_ptr->num_comps = 0;
    temp_ptr->comps = NULL;
    temp_ptr->ownerindex = NULL;
    temp_ptr->next = NULL;
    }

ret_end:
  return (owptr);
}


/*
 * This function should be used to free memory allocated
 * to the linked list - "owner". The linked list is expected
 * to be NULL-terminated. 
 * The actual number of nodes processed is dependent on the argument -
 * "num". Only "num" number of nodes are processed in the linked list.
 * If the list terminates before "num" nodes, processing stops at this
 * point. Also, if "num" is NULL, it is assumed that the entire list is
 * to be processed.
 */

void EMownercomp_free (owner, num)
struct EMSownercomp *owner;
IGRint num;
{
  IGRboolean flag;
  struct EMSownercomp *temp_owptr;

  if (owner)
    {
    flag = (num ? TRUE: FALSE);
    while ((flag ? num-- : TRUE) && owner)
      {
      if (owner->comps)
        om$dealloc (ptr = owner->comps);
      if (owner->ownerindex)
        om$dealloc (ptr = owner->ownerindex); 
      temp_owptr = owner->next;
      om$dealloc (ptr = owner);
      owner = temp_owptr;
      }
    }
}
