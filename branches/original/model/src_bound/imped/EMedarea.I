/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION 
  
    This message can be used to determine the area enclosed by this edge
    If the edge is open, the area value returned is undefined for all
    practical purposes. Actually, it will be the area of the shape
    defined by joining the end-points of the open edge to the [0,0]
    point. A clockwise direction of the edge yields a positive area,
    whereas a counterclockwise direction yields a negative one.

  NOTES
 
    The area returning argument must be set to zero by the caller.
    The result of the area computation done here is simply added to
    tha incoming value.

  RETURN VALUE

    EMS_S_Success - if all went well,

    EMS_I_Open - If the edge is open

    EMS_E_NoDynamicMemory - Just that
    EMS_E_EdgeError - Just that
    
  HISTORY

    SS  :  05/23/88  :  Creation
*/

class implementation EMSedge;

#include "EMS.h"
#include "emsdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMarea (IGRlong *msg; IGRdouble *area)
{
  IGRushort ed_props;
  IGRlong stat_OM, msg_loc;
  IGRdouble locarea;
  struct IGRpolyline poly;
  void EM2dpyarea();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  poly.points = NULL;
  poly.num_points = 0;

  stat_OM = om$send (msg = message EMSedge.EMgetpygeom (&msg_loc, 0,
             MAXINT, FALSE, NULL, &poly, NULL, NULL), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (*msg), *msg, EMS_E_EdgeError, ret_end);

  EM2dpyarea (poly.num_points, poly.points, &locarea);
  *area += locarea;

  ed_props = ME.EMSedge->ed_props;
  EMerr_hndlr (ed_props & EMED_OPEN, *msg, EMS_I_Open, ret_end);

ret_end:
  if (poly.points)
    om$dealloc (ptr = poly.points);

  EMWRAPUP (*msg, stat_OM, "EMSedge.EMarea");
  return (stat_OM);
}

end implementation EMSedge;

