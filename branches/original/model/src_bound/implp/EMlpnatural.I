/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

#include "EMS.h"
/*
Notes

        If the caller wishes to set any of the following edge
        properties, they sould be sent in an array of edge_props.
        The elements in the array edge_props should correspond
        to natural edge locations.

        The properties that can be sent in are:
        EMED_DEGENERATE
        EMED_XYZ_CLOSED
        EMED_SEAM
        EMED_REVERSE_CONNECT
             
        The seam edges are connected across common edge channel.

History
         AIC     02/27/87       Creation Date
         RC      07/28/87       Modified such that if the surface
                                geometry is not sent in, it gets the
                                geometry provided surface id is sent in.
         RC      11/04/87       Modified for version 1.1.0
         RC      11/10/87       Changed arguments.
Algorithm

        This method constructs natural edges and connects them to the
        loop (me). A garphic data  object is constructed 
        and connected to the loop.
*/


#include <stdio.h>
#include "emserr.h"
%safe
#include "math.h"
%endsafe
#include "bsparameters.h"
#include "bserr.h"

#define NO_OF_NAT_EDGES 4
#define U0EDGE 0
#define V1EDGE 1
#define U1EDGE 2
#define V0EDGE 3

from EMSnatedge import EMmake_natural_edge;

extern OMuword	OPP_EMSnatedge_class_id;

method EMmake_natural_loop(
   IGRlong                *EMmsg; 
   IGRuchar       *curve_type;
   IGRushort      *edge_props;
   GRobjid                *edges)
{
  IGRlong               OM_stat;
  IGRlong               mthd_stat;
  IGRint                i;
  OM_S_CHANSELECT       to_edges, to_owner, cm_ed_chan;
  GRobjid               edge_id_buffer[NO_OF_NAT_EDGES];
  extern OM_S_OBJID     current_creator;

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  ME.EMSboundary->creator_id = current_creator;
  
  if(! edges) edges = edge_id_buffer;

  OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
  EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_OMerror, wrapup);

  OM_stat = EMmake_chanselect (EMSedge_to_owner, &to_owner);
  EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_OMerror, wrapup);

  ME.EMSloop->lp_props = EMLP_EXTERNAL | EMLP_PLOOP | EMLP_NATURAL | 
			   EMLP_ACTIVE;

  ME.EMSloop->range[0] = 0;
  ME.EMSloop->range[1] = 0;
  ME.EMSloop->range[2] = 1.0;
  ME.EMSloop->range[3] = 1.0;

  /*
   * Construct the natural edges and connect them to me.
   */
  
  for(i = 0; i < NO_OF_NAT_EDGES; i ++)
  {
    IGRuchar	location;

    location = (IGRuchar) i;

    OM_stat = om$construct(classid = OPP_EMSnatedge_class_id, 
                   p_objid = &edges[i],
                   msg = message EMSnatedge.EMmake_natural_edge (
                    &mthd_stat, location, 
                     (curve_type ? &curve_type[i] : NULL),
                     (edge_props ? &edge_props[i] : NULL)));
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

    OM_stat = om$send(msg = message Root.connect(to_owner, i, my_id,
		  OM_Gw_current_OS, to_edges, 0), targetid = edges[i]);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  } /* for(i = 0; i < NO_OF_NAT_EDGES; i ++) */

  if(edge_props)
  {
     OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
     EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

     for (i = 0; i < 2; i++)
     {
       if (edge_props[i] & EMED_SEAM)
       {

          OM_stat = om$send (msg = message Root.connect (cm_ed_chan, 0,
                       edges[i], OM_Gw_current_OS, cm_ed_chan, 0),
                      targetid = edges[i+2]);
          EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

       } /*if (edges_props[i] & EMED_SEAM) */

     } /* for (i = 0; i < 2; i++) */

  } /* if(edge_props) */

wrapup:

  EMWRAPUP (*EMmsg, OM_stat, "In EMSloop.EMmake_natural_loop");

  return(OM_stat);
}

end implementation EMSloop;
