/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include "OMmacros.h"
#include "emsdattyp.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "emssfint.h"
#include "EMSopt.h"
#include "emsmacros.h"
#include "emsedgedef.h"

method EMshrink_geom (IGRlong               *EMmsg;
                      IGRboolean            my_stop;
                      GRobjid               other_loop;
                      IGRboolean            sender_atstop;
                      struct EMSpartolbasis *partol)
{
 IGRlong         stat_OM, msg;
 IGRdouble       end_pt[2];
 IGRboolean      onCurve;
 struct GRid     i_edge, j_edge;
 struct EMSsfintedpar    inters_data;
 OM_S_CHANSELECT to_edges;

/*-------------------------------------------------------------*/

 stat_OM = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);

 i_edge.objid = my_id;
 i_edge.osnum = OM_Gw_current_OS;

 stat_OM = om$get_objid_at_index(objid = other_loop,
                                 p_chanselect = &to_edges,
                                 index = 0,
                                 objidaddr = &j_edge.objid,
                                 osnumaddr = &j_edge.osnum);
 EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

 EMtrim_two_edges (&msg, &i_edge, &j_edge, my_stop, sender_atstop,
                   &partol->tol);
 EMerr_hndlr (! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);

 if (msg == EMS_I_NoIntersection)
  {
   stat_OM = om$send(msg = message EMSedge.EMendpts(&msg,
                           (sender_atstop) ? NULL : end_pt,
                           (sender_atstop) ? end_pt : NULL,
                           NULL, NULL, NULL),
                     targetid = j_edge.objid,
                     targetos = j_edge.osnum);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

   inters_data.point[0] = end_pt[0]; 
   inters_data.point[1] = end_pt[1];
   inters_data.intloc = EMScvint_middle;
   inters_data.edgeid = i_edge.objid;
   inters_data.info = NULL;
   inters_data.next = NULL;

   stat_OM = om$send (msg = message EMSedge.EMpratpt(&msg, end_pt, 1,
                            &inters_data.edgepar, &onCurve, NULL,
                            partol),
                      targetid = i_edge.objid);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

   stat_OM = om$send (msg = message EMSedge.EMalter_geometry (&msg,
                            &inters_data, my_stop),
                      targetid = i_edge.objid);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);
  }

wrapup:

  EMWRAPUP(*EMmsg, stat_OM, "In EMSedge.EMshrink_geom");
  return (stat_OM);
}

end implementation EMSedge;
