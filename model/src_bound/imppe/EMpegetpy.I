/* ###################   APOGEE COMPILED   ################## */
/*
   ABSTRACT:

    The purpose of this method is to provide flexible access to the
    edges "active" geometry in a polyline format. If the edge is internally
    represented in the B-spline curve format, it is stroked out with
    appropriate chord-height tolerance and converted to a polyline
    geometry.

    Random access to the spans of the edge polyline geometry is possible. The 
    geometry can be obtained either reversed or as is. If the caller
    has nulled-out the "partinfo" field, the method puts it's data into
    a structure and passes it down for use eventually by the fulledge.
    If the incoming "partinfo" is not-NULL, this method behaves like
    a passon or a carrier.

    If the caller nulls out the "points" field in the output IGRpolyline 
    structure, this method mallocs the memory. Else it assumes sufficient
    memory is present. The pointer "pygeom" should always point to a valid
    IGRpolyline structure on input.
*/

class implementation EMSpartedge;

#include "EMS.h"

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#include "OMmacros.h"
#include "emsmacros.h"

method EMgetpygeom (IGRlong *msg; IGRint from_spaninx; IGRint num_spans;
                    IGRboolean reverse; struct EMSpartedinfo *partinfo;
                    struct IGRpolyline *pygeom;
                    struct EMSpartolbasis *partolbasis;
                    IGRushort options)
{
  IGRchar errmsg[EMMAXERRMSG_LEN];
  IGRint stat_OM;
  struct EMSpartedinfo mypartinfo;
  OM_S_CHANSELECT chan_to_edge;
  
  *msg = MSSUCC;
  stat_OM = OM_S_SUCCESS;
  strcpy (errmsg, "EMSpartedge.EMgetgeom");

  stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &chan_to_edge);
  EMomerr_hndlr (stat_OM, ret_end, errmsg);
  
  if (!partinfo)
    {
     EMput_partinfo (mypartinfo);
     partinfo = &mypartinfo;
    }
  stat_OM = om$send (msg = message EMSedge.EMgetpygeom (msg, from_spaninx,
             num_spans, reverse, partinfo, pygeom, partolbasis, options), 
             p_chanselect = &chan_to_edge);
  EMomerr_hndlr (stat_OM, ret_end, errmsg);

ret_end:
  return (stat_OM);
}

end implementation EMSpartedge;
