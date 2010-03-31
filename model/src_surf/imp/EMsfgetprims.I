/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"
#include "EMSdprquery.h"

method EMgetprimsfromtree(IGRlong *EMmsg; IGRint *count; GRobjid **prims)
/*
Description
    This method returns the all primitive object ids on the state tree.

Return Values
    EMS_S_Success if all is well.

Notes
    The 'prims' ptr should be set to NULL and the 'count' variable should
    be set to 0 before sending this message.

    Memory is allocated for the prims array using om$malloc.  The sender
    of this message is expected to free this memory using om$dealloc.

    The original user of this message is the Salvagnini D & M project who
    will only have solids as primitives.  However, single surfaces and
    composite surfaces are considered primitives and will be returned if
    they are on the tree.

History
    DLB 09/16/88 Creation.
*/
{
  IGRlong OM_stat=OM_S_SUCCESS;


  *EMmsg = EMS_S_Success;

  /*This method may only be accessed if I am a primitive so add me.*/

  EFrealloc_if_needed(EMmsg, prims, *count, DPR_BUFF_INCR, sizeof(GRobjid));
  if (!(1 & *EMmsg)) goto wrapup;

  (*prims)[*count] = my_id;
  (*count)++;

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "In EMSsurface.EMgetprimsfromtree")
    return(OM_stat);
}
end implementation EMSsurface;
