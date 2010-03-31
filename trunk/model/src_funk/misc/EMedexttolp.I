/* ###################   APOGEE COMPILED   ################## */
/* 
  Creation 09/16/88 : gupta

   Sudha   07/08/93   Modified for BSprototypes ansification


  This function projects the end_uv_point of dangling edge on to the
  loop. Finds the model space distance between the end_uv_point and
  the project point. If the distance is <= max_ext_dist, the
  dangling edge is extended. If the distance between the new end point
  of the dangling edge and the old end point is greater than max_ext_dist,
  this function returns FALSE.
*/

class implementation GRvg;

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emserr.h"
#include "emsmacros.h"
#include "emsdattyp.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSprop.h"
#include "EMSmsgdef.h"
#include "OMmacros.h"
#include "EMSbnd.h"
#include "emssfint.h"
#include "bssfeval.h"
#include "bsdistptpt.h"

from EMSboundary import EMgetsurface_info;
from EMSloop import EMptproject;
from EMSedge import EMextend_geom,
                    EMget_props,
                    EMpratpt,
                    EMalter_geometry,
                    EMendpts;

IGRboolean EMextend_edge_upto_loop (EMmsg,
                                    my_env,
                                    dangling_edge,
                                    extend_end,
                                    end_uv_point,
                                    trim_loop,
                                    max_ext_dist,
                                    partolbasis)

IGRlong 	             *EMmsg;
struct GRmd_env          *my_env;
GRobjid                  dangling_edge;
IGRint                   extend_end;
IGRdouble                *end_uv_point;
GRobjid                  trim_loop;
IGRdouble                max_ext_dist;
struct EMSpartolbasis    *partolbasis;

{
 IGRlong                 stat_OM, msg;
 IGRlong                 srf_size;
 IGRushort       edge_props;
 IGRdouble               uvbegpt[2], uvendpt[2];
 IGRpoint                pnts[3];
 GRobjid                 surface_id, nearest_edge;
 IGRboolean              onCurve;
 struct EMSproj_info     proj_info;
 struct EMSsfintedpar    inters_data;
 struct IGRbsp_surface   *surface_geom;

/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 surface_geom = NULL;

 stat_OM = om$send (msg = message EMSboundary.EMgetsurface_info (&msg,
                          &surface_id,
                          (! partolbasis->is_valid) ? partolbasis : NULL),
                    senderid = NULL_OBJID,
                    targetid = trim_loop);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);

 stat_OM = om$send (msg = message EMSloop.EMptproject (&msg, end_uv_point,
                          1, &proj_info, &nearest_edge, partolbasis),
                    senderid = NULL_OBJID,
                    targetid = trim_loop);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);

 stat_OM = om$send(msg = message GRvg.GRgetsize(&msg,
                         &my_env->md_env.matrix_type,
                         my_env->md_env.matrix, &srf_size),
                   senderid = NULL_OBJID,
                   targetid = surface_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
             
 surface_geom = (struct IGRbsp_surface *) om$malloc(size = (OMuint)
                                                         srf_size);
 EMerr_hndlr(! surface_geom, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  
 stat_OM = om$send(msg = message GRvg.GRgetgeom(&msg,
                         &my_env->md_env.matrix_type,
                         my_env->md_env.matrix, (IGRchar *)surface_geom),
                   senderid = NULL_OBJID,
                   targetid = surface_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

 BSsfeval(surface_geom, end_uv_point[0], end_uv_point[1], 0, (IGRpoint *)pnts[0],
          &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 BSsfeval(surface_geom, proj_info.proj_pt[0], proj_info.proj_pt[1], 0,
          (IGRpoint *)pnts[1], &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (BSdistptpt (&msg, pnts[0], pnts[1]) > max_ext_dist)
     return (FALSE);

 stat_OM = om$send(msg = message EMSedge.EMget_props(&msg,
                         &edge_props),
                   senderid = NULL_OBJID,
                   targetid = dangling_edge);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 if (edge_props & EMED_ISO)
  {
   stat_OM = om$send (msg = message EMSedge.EMextend_geom (&msg,
                            proj_info.proj_pt, &extend_end, FALSE, NULL,
                            NULL,NULL,partolbasis,NULL,NULL,NULL,NULL,
                            NULL),
                      senderid = NULL_OBJID,
                      targetid = dangling_edge);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
  }
 else
  {
   inters_data.point[0] = proj_info.proj_pt[0]; 
   inters_data.point[1] = proj_info.proj_pt[1];
   inters_data.intloc = (extend_end) ? EMScvint_rtend : EMScvint_lfend;
   inters_data.edgeid = dangling_edge;
   inters_data.info = NULL;
   inters_data.next = NULL;

   stat_OM = om$send (msg = message EMSedge.EMpratpt(&msg,
                            inters_data.point, 1,
                            &inters_data.edgepar, &onCurve, NULL,
                            partolbasis),
                      senderid = NULL_OBJID,
                      targetid = dangling_edge);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

   stat_OM = om$send (msg = message EMSedge.EMalter_geometry (&msg,
                            &inters_data, extend_end),
                      senderid = NULL_OBJID,
                      targetid = dangling_edge);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);
  }

 stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, uvbegpt, uvendpt,
                         NULL, NULL, NULL),
                   senderid = NULL_OBJID,
                   targetid = dangling_edge);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 if (((extend_end == BEGIN) && (! (edge_props & EMED_REVERSED))) ||
     ((extend_end == END) && (edge_props & EMED_REVERSED)))
  {
   BSsfeval(surface_geom, uvbegpt[0], uvbegpt[1], 0, (IGRpoint *)pnts[2], &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  }
 else
 if (((extend_end == END) && (! (edge_props & EMED_REVERSED))) ||
     ((extend_end == BEGIN) && (edge_props & EMED_REVERSED)))
  {
   BSsfeval(surface_geom, uvendpt[0], uvendpt[1], 0, (IGRpoint *)pnts[2], &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  }
 else
  {
   return (FALSE);
  }

 if (BSdistptpt (&msg, pnts[0], pnts[2]) > max_ext_dist)
     return (FALSE);

 wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "GRvg.EMextend_edge_upto_loop");
 if (surface_geom) om$dealloc(ptr = surface_geom);

 if (1 & stat_OM & *EMmsg) return (TRUE);
 else return (FALSE);

}
end implementation GRvg;
