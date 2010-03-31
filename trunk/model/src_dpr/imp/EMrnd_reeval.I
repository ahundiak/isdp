/* ###################   APOGEE COMPILED   ################## */
/*
History
	Gupta	??/??/??	Creation.
	SM	28-Mar-89	Argument change in EMget_loops_for_imposition
				Function renamed as EMget_mapped_data().
*/
class implementation EMSsfround;

#include "EMS.h"
#include "OMmacros.h"
#include "EMSlm.h"
#include "EMSlmdef.h"
#include "EMSopt.h"
#include "bserr.h"
#include "emsmapdef.h"
#include "emsdattyp.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emsmacros.h"
#include "emsedgedef.h"
#include "emssfint.h"

#define FIX_TOL 0.1

extern OMuword OPP_EMSplane_class_id;

from EMSedge import EMendpts,
                    EMalter_geometry, 
                    EMreplace_edge;
		
method EMreevaluate_geometry (IGRlong                 *EMmsg;
                              struct GRmd_env         *my_env;
                              IGRint                  index;
                              IGRpoint                pt_area;
                              GRobjid                 my_surf_id;
                              GRobjid                 edge_id;
                              struct IGRbsp_curve     *edge_geom;
                              struct IGRbsp_surface   *edge_surf;
                              IGRint                  *num_pair_info; 
                              struct EMedge_con_info  *pair_info;
                              struct EMSpartolbasis   *partol)
{
 IGRlong                 stat_OM, msg;
 OMuword                 surf_classid;
 IGRint                  i;
 OMuword                 dum_os;
 IGRboolean              status, onSurf,
                         truncate_end0, truncate_end1;
 IGRint                  EMget_mapped_data();
 IGRint                  num_of_curves, num_loops;
 IGRdouble               uvbegpt[2], uvendpt[2];
 struct GRid             clip_ls;
 IGRushort       lp_options;
 GRobjid                 *loop_id = NULL,
                         new_edge;
 struct EMSsfintedpar    inters_begdata, inters_enddata;
 struct EMSedgebound     bound[2];
 OM_S_CHANSELECT         to_edges,
                         to_owner;

 /*-------------------------------------------------------------------*/

 stat_OM = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 truncate_end0 = TRUE;
 truncate_end1 = FALSE;

 clip_ls.objid = NULL_OBJID;
 clip_ls.osnum = OM_Gw_current_OS;
 loop_id = NULL;
 num_loops = 0;
 num_of_curves = 1;
 
 stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
 stat_OM = EMmake_chanselect (EMSedge_to_owner, &to_owner);
 if (! (1 & stat_OM)) goto wrapup;

 lp_options = NULL | EMMapBnd_WantBadCurves | EMMapBnd_StrokeIfNeeded |
              EMMapBnd_NoTraceClipFix | EMMapBnd_NoClip |
              EMMapBnd_NoValidate | EMMapBnd_NoFixing;

 /* If this is a plane or its subclass, set the appropriate bit on so 
    that mapping to uv space is optimised.
 */

 stat_OM = om$get_classid(objid = my_surf_id,
                          p_classid = &surf_classid);
 if (! (1 & stat_OM)) goto wrapup;

 if(surf_classid == OPP_EMSplane_class_id)
    lp_options |= EMMapBnd_SurfIsPlane;
 else
  {
   stat_OM = om$is_ancestry_valid(subclassid = surf_classid, 
                                  superclassid = OPP_EMSplane_class_id);
			
   if(stat_OM == OM_S_SUCCESS) lp_options |= EMMapBnd_SurfIsPlane;
  }

 {
  struct EMSgetlp_output	junk;
  junk.num_objs = 0;
  junk.objs = NULL;

  status = EMget_mapped_data(num_of_curves,
                       &edge_geom,
                       NULL,
                       NULL,
                       edge_surf,
                       &partol->tol,
                       my_env,
                       NULL, 
                       NULL,
                       &junk,
                       NULL,
                       clip_ls,
                       lp_options,
                       NULL, 
                       &msg);
  loop_id = junk.objs;
  num_loops = junk.num_objs;
  EMerr_hndlr (! status || ! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
 }
 stat_OM = om$get_objid_at_index(objid = *loop_id,
                                 p_chanselect = &to_edges,
                                 index = 0,
                                 objidaddr = &new_edge,
                                 osnumaddr = &dum_os);
 EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

 stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, uvbegpt, uvendpt,
                         bound, &bound[1], NULL),
                   targetid = new_edge);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

 inters_begdata.intloc = EMScvint_middle;
 inters_begdata.edgeid = new_edge;
 inters_begdata.info = NULL;
 inters_begdata.next = NULL;

 if ((uvbegpt[0] != 0.0) && (uvbegpt[0] != 1.0))
  {
   inters_begdata.edgepar.param = bound[0].param;
   inters_begdata.edgepar.span_inx = bound[0].span_inx;
   inters_begdata.point[0] = (uvbegpt[0] <= FIX_TOL) ? 0.0 : 1.0;
   inters_begdata.point[1] = uvbegpt[1];
   truncate_end0 = FALSE;
  }

 inters_enddata.intloc = EMScvint_middle;
 inters_enddata.edgeid = new_edge;
 inters_enddata.info = NULL;
 inters_enddata.next = NULL;

 if ((uvendpt[0] != 0.0) && (uvendpt[0] != 1.0))
  {
   inters_enddata.edgepar.param = bound[1].param;
   inters_enddata.edgepar.span_inx = bound[1].span_inx;
   inters_enddata.point[0] = (uvendpt[0] <= FIX_TOL) ? 0.0 : 1.0;
   inters_enddata.point[1] = uvendpt[1];
   truncate_end1 = TRUE;
  }

 if (! truncate_end0)
  {
   stat_OM = om$send (msg = message EMSedge.EMalter_geometry (&msg,
                            &inters_begdata, truncate_end0),
                      targetid = new_edge);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);
  }
 
 if (truncate_end1)
  {
   stat_OM = om$send (msg = message EMSedge.EMalter_geometry (&msg,
                            &inters_enddata, truncate_end1),
                      targetid = new_edge);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);
  }

 stat_OM = om$send (msg = message Root.disconnect (to_owner,
                          *loop_id, OM_Gw_current_OS, to_edges),
                    senderid = *loop_id,
                    targetid = new_edge);
 if (! (1 & stat_OM)) goto wrapup;
 
 stat_OM = om$send (msg = message Root.delete(1),
                    targetid = *loop_id);
 if (! (1 & stat_OM)) goto wrapup;

 for (i=0; i<(*num_pair_info); i++)
  {
   if (IF_EQ_OBJID(edge_id, pair_info[i].edge))
    {
     pair_info[i].edge = new_edge;
     break;
    }
   if (IF_EQ_OBJID(edge_id, pair_info[i].comm_edge))
    {
     pair_info[i].comm_edge = new_edge;
     break;
    }
  }


 stat_OM = om$send(msg = message EMSedge.EMreplace_edge(&msg, new_edge,
                         TRUE), 
                   targetid = edge_id);
 EMerr_hndlr (! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);

wrapup:

  if(loop_id) om$dealloc(ptr = loop_id);

  EMWRAPUP(*EMmsg, stat_OM, "In EMSsfround.EMreevaluate_geometry");
  return (stat_OM);
}

end implementation EMSsfround;
