/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    Used to post the boundary on the partedge. It is the counter method
    to EMgetbounds.

  ARGUMENTS

    bounds			- Input: Boundary to be posted

  RETURN VALUE

    EMS_S_Success - always successful

  HISTORY

    SS  :  Creation  :  01/19/88
*/

class implementation EMSpartedge;

#include "EMS.h"
#include "OMmacros.h"

method EMputbounds (IGRlong *msg; struct EMSedgebound *bounds)
{
  *msg = EMS_S_Success;

  OM_BLOCK_MOVE (bounds, ME.EMSpartedge->boundary, 
   2 * sizeof (struct EMSedgebound));

ret_end:
  return (OM_S_SUCCESS);
}

end implementation EMSpartedge;
