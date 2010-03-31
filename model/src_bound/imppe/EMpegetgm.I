/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpartedge;

#include "EMS.h"
#include "OMmacros.h"
#include "EMSerrordef.h"
#include "emsmacros.h"
#include "emsdattyp.h"

method EMgetgeom (IGRlong *EMmsg; IGRint from_spaninx; IGRint num_spans;
                    IGRboolean reverse; struct EMSpartedinfo *partinfo;
                    struct EMSaltdataselect *geom)

{
  IGRint status;
  struct EMSpartedinfo mypartinfo;
  OM_S_CHANSELECT chan_to_edge;
  
  *EMmsg = EMS_S_Success;
  status = OM_S_SUCCESS;

  status = EMmake_chanselect (EMSbd_owner_to_comps, &chan_to_edge);
  EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
  
  if (!partinfo)
    {
     EMput_partinfo (mypartinfo);
    partinfo = &mypartinfo;
    }
  status = om$send (msg = message EMSedge.EMgetgeom (EMmsg, from_spaninx,
             num_spans, reverse, partinfo, geom), 
             p_chanselect = &chan_to_edge);
  EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

wrapup:
  EMWRAPUP (*EMmsg, status, "In EMSpartedge:EMgetgeom error");
  return (status);
}

end implementation EMSpartedge;
