/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
/*
  DESCRIPTION

    This function is to be used when extending an existing or a NULL
    list. The element added is intialized with the input passed in. 
    This function picks out the appropriate EMSownercomp node, if it exists 
    (that node that has the input owner-id) and updates it. If such a node
    does not exist it allocates a new node which might start of the list or
    be linked to the end (depends on whether the input list ptr is NULL or
    not).

    An attempt to add to the components buffer on a given node, possibly 
    results in a realloc, as it might overflow the existing buffer. The 
    existing buffer size is known only in this file, implied by a combination 
    of the number of components already present and the increment size.

  NOTES

    The only options currently supported are, whether the component information
    should be added at the beginning of the component array or at the end
    of it. The former is performed if the option is set to EMS_O_Begin
    (see EMSopt.h). The latter is the default action, and the lack of 
    EMS_O_Start is assumed to mean EMS_O_Stop.

  HISTORY

    SS  :  early 87  :  Creation
*/

#include "EMS.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "godef.h"
#include "dp.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSmsgdef.h"
#include "EMSopt.h"
#include "emsdef.h"
#include "emserr.h"

#define BUFF_INC 3

void EMmkownlist (msg, ownlist, ownerid, ownerindex, compid, options,
                  list_extended) 
IGRlong *msg;
struct EMSownercomp **ownlist;
GRobjid ownerid;
IGRint ownerindex;
GRobjid compid;
IGRushort options;
IGRboolean *list_extended;
{
  IGRboolean in_list, add_atstart;
  IGRint blksize;
  IGRlong msg_loc;
  struct EMSownercomp *ownptr;
  struct EMSownercomp *EMownercomp_malloc();

  *msg = EMS_S_Success;

  if (!ownlist)
    goto ret_end;

  add_atstart = options & EMS_O_Start;

  /*
   * Positioning and allocating
   * if necessary.
   */
  
  *list_extended = FALSE;
  if (*ownlist)
    {
    in_list = FALSE;
    ownptr = *ownlist;
    while (!(in_list = IF_EQ_OBJID (ownptr->owner, ownerid)) &&
           ownptr->next)
      ownptr = ownptr->next;
    if (!in_list)
      {
      ownptr->next = EMownercomp_malloc (&msg_loc, 1);
      EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
      *list_extended = TRUE;
      ownptr = ownptr->next;
      }
    }
  else
    {
    *ownlist = EMownercomp_malloc (&msg_loc, 1);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
    *list_extended = TRUE;
    ownptr = *ownlist;
    }
  
  /* 
   * Initializing the node.
   */

  ownptr->owner = ownerid;

  if (! (ownptr->num_comps % BUFF_INC))
    {
    blksize = (ownptr->num_comps + BUFF_INC) * sizeof (GRobjid);
    if (! ownptr->comps)
      ownptr->comps = (GRobjid *) om$malloc (size = blksize);
    else
      ownptr->comps = (GRobjid *) om$realloc (ptr = (IGRchar *)ownptr->comps, 
                      size = blksize);

    blksize = (ownptr->num_comps + BUFF_INC) * sizeof (IGRint);
    if (! ownptr->ownerindex)
      ownptr->ownerindex = (IGRint *) om$malloc (size = blksize);
    else
      ownptr->ownerindex = (IGRint *) om$realloc (ptr = 
		(IGRchar *)ownptr->ownerindex, size = blksize);
    EMerr_hndlr (!ownptr->comps || !ownptr->ownerindex, *msg, 
     EMS_E_NoDynamicMemory, ret_end);
    }
  if (!add_atstart || !ownptr->num_comps)
    ownptr->comps[ownptr->num_comps] = compid;
  else
    {
    OM_BLOCK_MOVE (&ownptr->comps[0], &ownptr->comps[1],
     ownptr->num_comps * sizeof (GRobjid));
    ownptr->comps[0] = compid;
    }

  ownptr->ownerindex[ownptr->num_comps] = ownerindex;   

  ownptr->num_comps++;

ret_end:;
}

