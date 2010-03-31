/* ###################   APOGEE COMPILED   ################## */
/*
  Abstract:

  This method computes the "area" intersection between a 2-dimensional 
  polyline and this edge bounding this area. The intersection computation
  is sensitive to the area that the edge is considered to be boundary of
  (area on the right-hand-side with a natural traversal). An intersection
  results if and only if the input line string has any part common with the 
  INTERIOR bounded by the edge.

  If the input polyline just "grazes" the edge, no intersection is output;
  if the polyline intersects the edge at one of it's vertex points, only one
  intersection is output; etc.

  At the endpoints of this object, ambiguity can arise as to extent to which
  the interior fans out. For this purpose a "previous" and a "subsequent"
  point are obtained, from it's previous and subsequent edges which now
  define the interior at the start and the endpoints, respectively.

  Theoretically, this is an n-squared algorithm, but practically it
  works out cheaper as there are two stages wherin non-intersections
  are trivially rejected.

  The output is a linked list of EMSpypoint  and EMintsfedge structures that
  stand for the intersections on the polyline. If output pointers (*polyinters
  and/or *myinters) are not NULL, this method assumes an existing linked-list
  and attaches it's output to the tail.


  If the caller has nulled-out the "partinfo" field, the method puts it's 
  data into a structure and passes it down for use eventually by the fulledge.
  If the incoming "partinfo" is not-NULL, this method behaves like
  a passon or a carrier.

History
        PP    12/02/87   Made changes for edge type
*/

class implementation EMSpartedge;

#include "EMS.h"
#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#include "OMmacros.h"
#include "emsmacros.h"

method EMedpytrimint (IGRlong *msg; struct IGRpolyline *inpoly;
                      IGRdouble *inpoly_range; 
                      struct EMSpartolbasis *partol_basis;
                      struct EMSpartedinfo *partinfo;
                      IGRushort options;
                      IGRint *num_inters;
                      struct EMSsfintedpar **myinters; 
                      struct EMSpypoint  **polyinters)
{
  IGRint stat_OM;
  struct EMSpartedinfo mypartinfo;
  OM_S_CHANSELECT chan_to_edge;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (!partinfo)
    {
     EMput_partinfo (mypartinfo);
     partinfo = &mypartinfo;
    }

  chan_to_edge.type = OM_e_addr;
  chan_to_edge.u_sel.addr = &ME.EMSbd_owner->to_comps;
  
  stat_OM = om$send (msg = message EMSedge.EMedpytrimint (msg, inpoly,
             inpoly_range, partol_basis, partinfo, options, num_inters, 
             myinters, polyinters), p_chanselect = &chan_to_edge);
  EMomerr_exit (stat_OM, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSpartedge.EMedpytrimint");
  return (stat_OM);
}

end implementation EMSpartedge;

