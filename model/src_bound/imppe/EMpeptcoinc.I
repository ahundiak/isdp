/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This message is used to detect if this edge has any other edge lying
    next to it (within the given tolerance) at a given point. The coincident
    edge, if one exists, is returned.

  HISTORY

    SS  :  11/21/88  :  Creation
*/

class implementation EMSpartedge;

#include "EMS.h"
#include "OMmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMptcoinc (IGRlong *msg; IGRdouble *at_point; 
                  GRobjid *coincedge; IGRshort *neighbor_loc1, *neighbor_loc2;
                  struct EMSpartedinfo *partinfo; 
                  struct EMSpartolbasis *partolb)
{
  IGRlong stat_OM;
  struct EMSpartedinfo mypartinfo;
  OM_S_CHANSELECT chan_to_edge;
  
  *msg = EMS_I_NotFound;
  stat_OM = OM_S_SUCCESS;

  stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &chan_to_edge);
  EMomerr_exit (stat_OM, ret_end);

  if (!partinfo)
    {
    mypartinfo.edprops = ME.EMSedge->ed_props;
    OM_BLOCK_MOVE (ME.EMSpartedge->boundary, mypartinfo.edbdry, 2 * 
     sizeof (struct EMSedgebound));
    mypartinfo.edid = my_id;
    partinfo = &mypartinfo;
    }

  stat_OM = om$send (msg = message EMSedge.EMptcoinc (msg, at_point,
             coincedge, neighbor_loc1, neighbor_loc2, partinfo, partolb), 
             p_chanselect = &chan_to_edge);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSpartedge.EMptcoinc");
  return (stat_OM);
}

end implementation EMSpartedge;
