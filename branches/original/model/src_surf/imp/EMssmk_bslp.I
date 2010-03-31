/* ###################   APOGEE COMPILED   ################## */
/*
History
	Gupta	??/??/??	Creation.
	SM	28-Mar-1989	Argument change in EMget_loops_for_imposotion.
				Function renamed as EMget_mapped_data().
	SM	11-Mar-92	Error out if EFget_mapped_data() does not
				return any loops.
        NP      26-Aug-92	Modified for ANSI compliance.
*/
class implementation EMSsubbs;

#include "EMS.h"
#include "msdef.h"
#include "bserr.h"
#include "emsdef.h"
#include "emsmacros.h"
#include "EMSlmdef.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "emsmapdef.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "gocmacros.h"

extern OMuword OPP_EMSplane_class_id;

from EMSslround import EMloopset_add;
from EMSboundary import EMget_objid;
from EMSedge import EMendpts;
from EMSloop import EMget_edges;

method EMmake_bsedge_loop (IGRlong               *EMmsg;
                           struct GRmd_env       *my_env;
                           struct IGRbsp_surface *impbnd_surf;
                           struct IGRbsp_curve   *xyz_curve;
                           struct EMSpartolbasis *surf_partol;
                           GRobjid               rnd_edge_id;
                           IGRshort              bnd_type;
                           IGRboolean            pt_outside;
                           IGRpoint              vtx_point;
                           struct GRid           *edge_id;
                           GRobjid               *round_id)
{
  IGRlong                stat_OM, msg, msg1;
  OMuword                surf_classid;
  IGRint                 i;
  GRobjid                loopset_id, *loop_id = NULL;
  struct GRid            clip_ls;
  struct GRid            *loop_ed;
  IGRushort      lp_options;
  extern IGRdouble       BSdistptpt();
  IGRdouble              dist, inc_factor;
  IGRpoint               mid_point, new_point, base_point;
  extern   IGRboolean             BSprptonsf();
  IGRboolean             status, onsurf = FALSE;
  IGRint                 EMsend_loops();
  IGRint                 num_loops;
  IGRint                 num_of_curves;
  IGRint                 num_edges, array_size;
  extern IGRint          EMget_mapped_data();
  IGRlong                num_of_bad_points,
                         num_of_bad_curves,
                         bad_curve_indices;
  IGRpoint               *bad_points;
  struct EMboundary_info bound_info;
  OM_S_CHANSELECT        to_loopset;

/*--------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 clip_ls.objid = NULL_OBJID;
 loop_id = NULL;
 bad_points = NULL;
 num_loops = 0;
 num_of_bad_curves = 0;
 num_of_bad_points = 0;
 num_of_curves = 1;

 to_loopset.type = OM_e_addr;
 to_loopset.u_sel.addr = &ME.EMSsubbs->to_loopset;

 if (! impbnd_surf)
  {
   GRgetabsg (&msg, &my_env->md_env.matrix_type, my_env->md_env.matrix,
              (IGRchar **)&impbnd_surf, i);  
   EMerr_hndlr (! (1 & msg), *EMmsg, msg, wrapup);
  }

 lp_options = NULL | EMMapBnd_WantBadCurves | EMMapBnd_StrokeIfNeeded |
              EMMapBnd_NoValidate | EMMapBnd_NoTraceClipFix |
              EMMapBnd_NoClip | EMMapBnd_NoFixing;

 /* If this is a plane or its subclass, set the appropriate bit on so 
    that mapping to uv space is optimised.
 */

 stat_OM = om$get_classid(objid = my_id,
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
                      &xyz_curve,
                      NULL,
                      NULL,
                      impbnd_surf,
                      &surf_partol->tol,
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
 }
 EMerr_hndlr (! status || ! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
 EMerr_hndlr (!num_loops || !loop_id, *EMmsg, EMS_E_Fail, wrapup);
 
 loop_ed = NULL;
 array_size = NULL;
 num_edges = NULL;

 stat_OM = om$send(msg = message EMSloop.EMget_edges(&msg, MAXINT,
                         EMS_OPT_ALL, &loop_ed,
                         &array_size, &num_edges),
                   targetid = *loop_id);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);

 edge_id->objid = loop_ed->objid;
 edge_id->osnum = loop_ed->osnum;

 /* fill the info */

 bound_info.bnd_type = bnd_type;
 bound_info.loop_id = *loop_id;

 stat_OM = om$send(msg = message EMSedge.EMendpts(&msg,
                         &bound_info.end_pts[0], &bound_info.end_pts[2],
                         NULL,NULL,NULL),
                   targetid = edge_id->objid);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

 if (pt_outside)
  {
   bound_info.point_in_area[0] = 0; 
   bound_info.point_in_area[1] = 0;
  }
 else
  {
   if (xyz_curve->rational)
    { 
     for (i=0; i<3; i++)
      mid_point[i] = (xyz_curve->poles[i]/xyz_curve->weights[0]) +
                     ((xyz_curve->poles[3*(xyz_curve->num_poles-1) + i]/
                     xyz_curve->weights[xyz_curve->num_poles - 1]) -
                     (xyz_curve->poles[i]/xyz_curve->weights[0])) / 2;
    }
   else
    {
     for (i=0; i<3; i++)
      mid_point[i] = xyz_curve->poles[i] +
                     (xyz_curve->poles[3*(xyz_curve->num_poles-1) + i] -
                     xyz_curve->poles[i]) / 2;
    }
   
   dist = BSdistptpt(&msg, mid_point, vtx_point);

   inc_factor = dist/20;
   for (i=0; i<3; i++)
        new_point[i] = (mid_point[i] * (inc_factor + dist) -
                            inc_factor * vtx_point[i]) / dist;

   status = BSmdistptsf (&msg, 
                         impbnd_surf,
                         new_point,
                         &bound_info.point_in_area[0],
                         &bound_info.point_in_area[1],
                         base_point,
                         &dist);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  }

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

  if(loop_id) om$dealloc(ptr = loop_id);

  EMWRAPUP (*EMmsg, stat_OM, "EMSsubbs.EMmake_bsedge_loop");
  return (stat_OM);
}

end implementation EMSsubbs;
