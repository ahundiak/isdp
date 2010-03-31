/* ###################   APOGEE COMPILED   ################## */
/*
   ABSTRACT:

    This method gets the bspline geometry of the part edge.  If the poles,
    weights, knots fields in bsgeom are set to null, the method appropriately
    allocated memory for the same.  Otherwise it assumes that memory has
    been allocated.  

    For a bspline geometry there exists only one span and the span index for
    the same is 0.  Number of spans is always one.  (The meaning of span is
    in keeping with that developed for the implementation of linear edges 
    for boolean operations and does not correspond to a bezier span of a 
    bspline). 

    PP    12/02/87   Made changes for edge type
    PP   : 05/11/87               Design date
*/

class implementation EMSpartedge;

#include "EMS.h"
#include "emsmacros.h"
#include "OMmacros.h"
#include "EMSerrordef.h"

method EMgetbcgeom (IGRlong *EMmsg; IGRint from_spaninx; IGRint num_spans;
                    IGRboolean reverse; struct EMSpartedinfo *partinfo;
                    struct IGRbsp_curve *bsgeom;
                    struct EMSpartolbasis *partolbasis;
                    IGRushort options)

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
  status = om$send (msg = message EMSedge.EMgetbcgeom (EMmsg, from_spaninx,
             num_spans, reverse, partinfo, bsgeom, partolbasis, options), 
             p_chanselect = &chan_to_edge);
  EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

wrapup:
  EMWRAPUP (*EMmsg, status, "In EMSpartedge:EMgetbcgeom error");
  return (status);
}

end implementation EMSpartedge;
