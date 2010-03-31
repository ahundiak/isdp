/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    Used to generate any number of points on this edge that are internal
    (away from the endpoints). These points are centralized based on
    paramteric space (w-space) of the edge.
*/

class implementation EMSpartedge;

#include "EMS.h"
#include "OMmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMinternalpt (IGRlong *msg; IGRint numpts; struct EMSproj_info *prjpts;
                     IGRdouble *pts;
                     struct EMSpartedinfo *partinfo; 
                     struct EMSpartolbasis *partolbasis)
{
  IGRlong stat_OM, msg_loc;
  struct EMSpartedinfo mypartinfo;
  OM_S_CHANSELECT chan_to_edge;
  
  *msg = EMS_S_Success;
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

  stat_OM = om$send (msg = message EMSedge.EMinternalpt (&msg_loc, numpts,
             prjpts, pts, partinfo, partolbasis), 
             p_chanselect = &chan_to_edge);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSpartedge.EMinternalpt");
  return (stat_OM);
}

end implementation EMSpartedge;
