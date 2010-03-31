/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include "EMSerrordef.h"
#include "EMSmsgdef.h"

method EMget_bottom_edge(IGRlong *EMmsg; GRobjid *bottom_edge)
/*
History

	RV	02/09/88	Creation Date

*/
{
  *EMmsg = EMS_S_Success;

  *bottom_edge = my_id;

  return(OM_S_SUCCESS);
}

end implementation EMSedge;
