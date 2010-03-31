/* ###################   APOGEE COMPILED   ################## */
/*
History
	Gupta	??/??/??	Creation.
	SM	28-Mar-89	Argument change in EMget_loops_for_imposition
				Function renamed as EMget_mapped_data.
	SM	11-Mar-92	Error out if EFget_mapped_data() does not
				return any loops.
*/
class implementation EMSsubbs;

#include "EMS.h"
#include "bserr.h"
#include "emsdef.h"
#include "emsmacros.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSlm.h"
#include "EMSlmdef.h"
#include "emsmapdef.h"
#include "emslpinitdef.h"

extern OMuword OPP_EMSloop_class_id;
extern OMuword OPP_EMSlinedge_class_id;
extern OMuword OPP_EMSplane_class_id;

from EMSlinedge import EMleinit;
from EMSedge import EMendpts,
                    EMptproject,
                    EMset_props;
from EMSloop import EMlpinit;
from EMSsfround import EMloopset_add;
from EMSboundary import EMget_objid;
from EMSloop import EMget_edges;

method EMmake_edge_loop (IGRlong                  *EMmsg;
                         struct GRmd_env          *my_env;
                         struct EMedge_round_info *my_info;
                         struct IGRbsp_surface    *fsurf,
                                                  *impbnd_surf;
                         BSpair                   **par;
                         IGRint                   cind,
                                                  *numpnts;
                         IGRdouble                v0_or_v1;
                         IGRshort                 bnd_type;
                         GRobjid                  *round_id;
                         GRobjid                  rnd_edge_id;
                         struct EMSpartolbasis    *surf_partol;
                         IGRboolean               auto_trim;
                         IGRboolean               special_fillet;
                         IGRdouble                *point_in_area;
                         struct GRid              *edge_id;
                         IGRint                   *num_loops;
                         GRobjid                  **loop_id)
{
  IGRlong                stat_OM, msg, msg1;
  OMuword                surf_classid;
  GRobjid                loopset_id;
  struct GRid            *loop_ed;
  IGRushort      ed_props;
  IGRushort      lp_options;
  IGRshort               option;
  extern IGRint          EMget_mapped_data();
  extern IGRint          EMsend_loops();
  IGRint                 num_edges, array_size;
  IGRint                 i, num_of_curves, grp_inx;
  IGRushort      lp_props = 0;
  IGRboolean             tst_planar;
  struct IGRbsp_curve    *iso_curve;
  struct IGRpolyline     poly;
  struct EMboundary_info bound_info;
  IGRdouble              poly_points[4], check_dist;
  OM_S_CHANSELECT        to_owner,
                         to_edges,
                         to_loops,
                         to_loopset;
  struct GRid            clip_ls;
  struct EMSproj_info    proj_info;
  IGRboolean             status;
  extern IGRboolean      BSconstprcv();

/*--------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 tst_planar = TRUE;
 option = 1;
 iso_curve = NULL;
 ed_props = NULL;

 clip_ls.objid = NULL_OBJID;
 num_of_curves = 1;

 to_loopset.type = OM_e_addr;
 to_loopset.u_sel.addr = &ME.EMSsubbs->to_loopset;

 stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
 if (! (1 & stat_OM)) goto wrapup;

 BSalloccv (fsurf->v_order, fsurf->v_num_poles, fsurf->rational,
            NULL, &iso_curve, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 BSconstprcv (&msg, fsurf, &option, &v0_or_v1, &tst_planar, iso_curve);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (v0_or_v1) 
     my_info->comm_curve = iso_curve;
 else
     my_info->curve = iso_curve;

 if (fsurf->v_phy_closed)
  ed_props |= EMED_XYZ_CLOSED;

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

 if (((impbnd_surf->planar) && (! (lp_options & EMMapBnd_SurfIsPlane)))||
    ((lp_options & EMMapBnd_SurfIsPlane) && (iso_curve->order > 2)) ||
    (auto_trim) || (special_fillet))
  {
   if ((impbnd_surf->u_phy_closed) || (impbnd_surf->v_phy_closed) ||
       (special_fillet))
    {
     lp_options &= ~EMMapBnd_NoTraceClipFix;
     lp_options &= ~EMMapBnd_NoClip;
     lp_options &= ~EMMapBnd_NoFixing;
    } 
   
   {
    struct EMSgetlp_output		junk;

    junk.num_objs = 0;
    junk.objs = *loop_id;
    status = EMget_mapped_data(num_of_curves,
                               &iso_curve,
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
    *loop_id = junk.objs;
    *num_loops = junk.num_objs;
   }
   EMerr_hndlr (! status || ! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
   EMerr_hndlr (!(*num_loops) || !(*loop_id), *EMmsg, EMS_E_Fail, wrapup);
 
   if ((special_fillet) && (*num_loops > 1))
    {
     check_dist = MAXFLOAT;
     grp_inx = 0;
     for (i=0; i<*num_loops; i++)
      {
       stat_OM = om$send(msg = message EMSedge.EMptproject (&msg,
                               point_in_area, 1, &proj_info, NULL,
                               surf_partol),
                         senderid = (*loop_id)[i],
                         p_chanselect = &to_edges,
                         from = 0,
                         to = 0);
       EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

       if (proj_info.dist <= check_dist)
        {
         grp_inx = i;
         check_dist = proj_info.dist;
        }
      }
     (*loop_id)[0] = (*loop_id)[grp_inx];
    }

   loop_ed = NULL;
   array_size = NULL;
   num_edges = NULL;

   stat_OM = om$send(msg = message EMSloop.EMget_edges(&msg, MAXINT,
                           EMS_OPT_ALL, &loop_ed,
                           &array_size, &num_edges),
                     targetid = (*loop_id)[0]);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);
   edge_id->objid = loop_ed->objid;
   edge_id->osnum = loop_ed->osnum;

   if(loop_ed)
     {
/* fix for mlk */
     om$dealloc(ptr = loop_ed);
     loop_ed = NULL;
     }
   if ((ed_props & EMED_XYZ_CLOSED) && (*num_loops == 1) &&
       (num_edges == 1))
    {
     stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                             EMED_XYZ_CLOSED, EMS_O_ON),
                       targetid = edge_id->objid);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
    }

   stat_OM = om$send(msg = message EMSedge.EMendpts(&msg,
                           &bound_info.end_pts[0], &bound_info.end_pts[2],
                           NULL,NULL,NULL),
                     targetid = edge_id->objid);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);
  }
 else
  {
   *loop_id = (GRobjid *) om$malloc (size = sizeof(GRobjid));
   stat_OM = EMmake_chanselect (EMSedge_to_owner, &to_owner);
   if (! (1 & stat_OM)) goto wrapup;

   *num_loops = 1;
   if (iso_curve->order == 2)
    {
     poly_points[0] = par[cind][0][0];
     poly_points[1] = par[cind][0][1];
     poly_points[2] = par[cind][(*numpnts)-1][0];
     poly_points[3] = par[cind][(*numpnts)-1][1];

     poly.num_points = 2;
     poly.points = &poly_points[0];
    }
   else
    {
     poly.num_points = *numpnts;
     poly.points = par[cind][0];
    }        
   stat_OM = om$construct (classid = OPP_EMSloop_class_id,
                           p_objid = &(*loop_id)[0]);
   if (! (1 & stat_OM)) goto wrapup;

   stat_OM = om$construct (classid = OPP_EMSlinedge_class_id,
                           p_objid = &edge_id->objid,
                           msg = message EMSlinedge.EMleinit (&msg,
                                 ed_props, NULL, &poly, surf_partol,NULL, 
				 NULL_OBJID));
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
 
   edge_id->osnum = OM_Gw_current_OS;
   stat_OM = om$send(msg = message Root.connect(to_edges, NULL,
                           edge_id->objid,
                           OM_Gw_current_OS, to_owner, 0),
				     senderid = edge_id->objid,
                     targetid = (*loop_id)[0]);
   EMerr_hndlr (! (1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

   lp_props = EMLP_ACTIVE;
   lp_options = NULL | EMLpInit_NoLoopType;

   stat_OM = om$send(msg = message EMSloop.EMlpinit (&msg, lp_props,
                           surf_partol, lp_options),
                     targetid = (*loop_id)[0]);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);

   bound_info.end_pts[0] = par[cind][0][0];
   bound_info.end_pts[1] = par[cind][0][1];
   bound_info.end_pts[2] = par[cind][(*numpnts)-1][0];
   bound_info.end_pts[3] = par[cind][(*numpnts)-1][1];
  }

 /* fill the info */

 bound_info.bnd_type = bnd_type;
 bound_info.loop_id = (*loop_id)[0];

 bound_info.point_in_area[0] = point_in_area[0]; 
 bound_info.point_in_area[1] = point_in_area[1];

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
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopsetError, wrapup);

 if (auto_trim)
  {
   stat_OM = EMmake_chanselect (EMSloopset_to_loops, &to_loops);

   stat_OM = om$send (msg = message EMSboundary.EMget_objid(&msg,
                            &bound_info.rnd_loop_id),
                      senderid = loopset_id,
                      p_chanselect = &to_loops,
                      from = 0,
                      to = 0);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopsetError, wrapup);
  }

 stat_OM = om$send(msg = message EMSsfround.EMloopset_add (&msg,
                         bound_info, loopset_id),
                   targetid = *round_id);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopsetError, wrapup);

 if ((*num_loops > 1) && (! special_fillet))
  {
   for (i=1; i<*num_loops; i++)
    {
     loop_ed = NULL;
     array_size = NULL;
     num_edges = NULL;

     stat_OM = om$send(msg = message EMSloop.EMget_edges(&msg, MAXINT,
                             EMS_OPT_ALL, &loop_ed,
                             &array_size, &num_edges),
                       targetid = (*loop_id)[i]);
     EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);
     edge_id->objid = loop_ed->objid;
     edge_id->osnum = loop_ed->osnum;

     stat_OM = om$send(msg = message EMSedge.EMendpts(&msg,
                            &bound_info.end_pts[0],&bound_info.end_pts[2],
                             NULL,NULL,NULL),
                       targetid = edge_id->objid);
     EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

     bound_info.loop_id = (*loop_id)[i];

     stat_OM = om$send(msg = message EMSsfround.EMloopset_add (&msg,
                             bound_info, loopset_id),
                       targetid = *round_id);
     EMerr_hndlr (!(1 & stat_OM & msg),*EMmsg,EMS_E_LoopsetError, wrapup);
     if(loop_ed)
       {
       om$dealloc(ptr = loop_ed);
       loop_ed = NULL;
       }
    }
  }

wrapup:

  EMWRAPUP (*EMmsg, stat_OM, "EMSsubbs.EMmake_edge_loop");

  return (stat_OM);
}

end implementation EMSsubbs;
