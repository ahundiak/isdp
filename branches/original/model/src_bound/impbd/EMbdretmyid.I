/* ###################   APOGEE COMPILED   ################## */
class implementation EMSboundary;

#include <stdio.h>
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"

#define BLOCK_SIZE 20

method EMreturn_my_id (IGRlong *msg; IGRint *numobjs; GRobjid **objlist)
{
  IGRint numslots;
  IGRlong stat_OM;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (!objlist)
    goto ret_end;

  numslots = (*numobjs / BLOCK_SIZE) * BLOCK_SIZE + 
             (*numobjs % BLOCK_SIZE ? BLOCK_SIZE : 0);
  if (*numobjs + 1 > numslots)
    {
    if (!*objlist)
      *objlist = (GRobjid *) om$malloc (size = BLOCK_SIZE * sizeof (GRobjid));
    else
      *objlist = (GRobjid *) om$realloc (size = (numslots + BLOCK_SIZE) *
                  sizeof (GRobjid), ptr = (char *)*objlist);
    EMerr_hndlr (!*objlist, *msg, EMS_E_NoDynamicMemory, ret_end);
    }

  (*objlist)[*numobjs] = my_id;
  (*numobjs)++;

ret_end:
  if (EMSerror (*msg))
    fprintf (stderr, "EMSboundary.EMreturn_my_id - dynamic memory error");
  return (stat_OM);
}

end implementation EMSboundary;

