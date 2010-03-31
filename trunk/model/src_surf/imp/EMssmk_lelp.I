/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include "bserr.h"
#include "emsmacros.h"
#include "EMSprop.h"
#include "emsdattyp.h"
#include "emsedgedef.h"

extern OMuword OPP_EMSloop_class_id;
extern OMuword OPP_EMSlinedge_class_id;

from EMSlinedge import EMleinit;
from EMSedge import EMset_props;
from EMSloop import EMlpinit;
from EMSslround import EMloopset_add;
from EMSboundary import EMget_objid;

method EMmake_linedge_loop (IGRlong               *EMmsg;
                            IGRboolean            iso_edge;
                            struct IGRpolyline    *poly;
                            GRobjid               *round_id;
                            struct EMSpartolbasis *surf_partol;
                            IGRshort              bnd_type;
                            GRobjid               rnd_edge_id;
                            GRobjid               *edge_id;
                            IGRdouble             *point_in_area)
{
  IGRlong                stat_OM, msg, msg1;
  GRobjid                loopset_id, loop_id;
  IGRushort      lp_props = 0;
  IGRushort      ed_props;
  IGRint                 EMsend_loops();
  struct EMboundary_info bound_info;
  OM_S_CHANSELECT        to_owner,
                         to_edges,
                         to_loopset;

/*--------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
 if (! (1 & stat_OM)) goto wrapup;
 stat_OM = EMmake_chanselect (EMSedge_to_owner, &to_owner);
 if (! (1 & stat_OM)) goto wrapup;

 to_loopset.type = OM_e_addr;
 to_loopset.u_sel.addr = &ME.EMSsubbs->to_loopset;

 stat_OM = om$construct (classid = OPP_EMSloop_class_id,
                         p_objid = &loop_id);
 if (! (1 & stat_OM)) goto wrapup;

 ed_props = (iso_edge) ? EMED_ISO : NULL;

 stat_OM = om$construct (classid = OPP_EMSlinedge_class_id,
                         p_objid = edge_id,
                         msg = message EMSlinedge.EMleinit (&msg,
                               ed_props, NULL, poly, surf_partol,NULL,
                               NULL_OBJID));
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 stat_OM = om$send(msg = message Root.connect(to_edges, NULL, *edge_id,
                         OM_Gw_current_OS, to_owner, 0),
				   senderid = *edge_id,
                   targetid = loop_id);
 EMerr_hndlr(! (1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

 lp_props = EMLP_ACTIVE;

 stat_OM = om$send(msg = message EMSloop.EMlpinit (&msg, lp_props,
                         surf_partol, NULL),
                   targetid = loop_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);

 /* fill the info */

 bound_info.loop_id = loop_id;

 bound_info.bnd_type = bnd_type;

 bound_info.point_in_area[0] = point_in_area[0]; 
 bound_info.point_in_area[1] = point_in_area[1];

 bound_info.end_pts[0] = poly->points[0];
 bound_info.end_pts[1] = poly->points[1];
 bound_info.end_pts[2] = poly->points[2*poly->num_points - 2];
 bound_info.end_pts[3] = poly->points[2*poly->num_points - 1];

 if (rnd_edge_id == NULL_OBJID)
  {
   bound_info.rnd_loop_id = NULL_OBJID;
   bound_info.rnd_edge_id = NULL_OBJID;
  }
 else
  {
   bound_info.rnd_edge_id = rnd_edge_id;

   stat_OM = EMsend_loops(&msg, message EMSboundary.EMget_objid(&msg1,
                          &bound_info.rnd_loop_id), rnd_edge_id, 0,
                          OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
   EMerr_hndlr (! (1 & stat_OM & msg & msg1), *EMmsg, EMS_E_LoopError, 
                wrapup);
  }

 stat_OM = om$send (msg = message EMSboundary.EMget_objid(&msg,
                          &loopset_id),
                    p_chanselect = &to_loopset);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopsetError, wrapup);

 stat_OM = om$send(msg = message EMSslround.EMloopset_add (&msg,
                         bound_info, loopset_id),
                   targetid = *round_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopsetError, wrapup);

wrapup:
  EMWRAPUP (*EMmsg, stat_OM, "EMSsubbs.EMmake_linedge_loop");
  return (stat_OM);
}

end implementation EMSsubbs;
