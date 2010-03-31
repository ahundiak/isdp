/* ###################   APOGEE COMPILED   ################## */
/*
   ABSTRACT:

    The purpose of this method is to provide a flexible means of "posting"
    the edges geometry. The input is in a B-spline format. If the edge is
    internally represented as a line-string, the input is first
    converted to a compatible format (polyline) using the appropriate 
    chord-height tolerance. Thus geometry may be inserted into the existing
    geometry at any place. This method is intended to be the reverse of
    "EMgetbcgeom". But restrictions apply.

    This method is applicable only on those edges that fulfil the following
    criteria:
    i) It is not a part-edge or a natural-edge,
    ii) No part-edge is connected to it,
    iii) The geometry to be added will not cause the edge to cross the
         uv-domain fo the surface.

    Geometry may be inserted anywhere in the existing geometry by
    specifying the span ("from_spaninx") soon after which the insertion
    is to take place. If the reverse flag is set, "from_spaninx" applies
    to the reversed edge and the input geometry is inserted in the
    reverse order. The simplest way to think about this is to visual this
    method as a negation of the "get" method. If the "get" method
    were to actually remove from the edge, the geometry that it was 
    returning, then calling this method with the same arguments
    (from_spaninx and reverse) and the "got" geometry, would neutralize
    the effect.
*/

class implementation EMSlinedge;

#include "EMS.h"
method EMputbcgeom (IGRlong *msg; IGRint from_spaninx; 
                    IGRboolean reverse;
                    struct IGRbsp_curve *inbcgeom)
{
  IGRchar errmsg[EMMAXERRMSG_LEN];
  IGRint stat_OM;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  strcpy (errmsg, "EMSlinedge.EMputbcgeom");

ret_end:
  return (stat_OM);
}

end implementation EMSlinedge;
