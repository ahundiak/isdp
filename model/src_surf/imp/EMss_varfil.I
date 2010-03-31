/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSlm.h"
#include "EMSlmdef.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "OMmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "bsvarfillsf.h"
#include "bssfkttol2.h"
#include "bsprptonsf.h"
#include "bsmdistptsf.h"
#include "bsfreecv.h"
#include "bsdistptpt.h"
#include "bscveval.h"
#include "bsconstprcv.h"
#include "bschangepar.h"
#include "bsalloccv.h"

extern OMuword OPP_EMSgenbs_class_id;

from EMSedge import EMstitch;

/*
  HISTORY
         ??  ?/?/?   Creation Date
         RC  1/31/90 Fixed a bug regarding call to EMget_point_in_area.
         NP 08/26/92 Modified for ANSI compliance. Changed "edg_count" variable 
		     to type "IGRuint".
       Sudha 7/07/93 Modified for BSprototypes ansification

 */

method EMvariable_fillet_surface(IGRlong                  *EMmsg;
                                 struct GRmd_env          *my_env;
                                 GRobjid                  *round_id;
                                 IGRboolean               s1_nat_norm,
                                                          s2_nat_norm;
                                 IGRpoint                 starting_point;
                                 IGRdouble                starting_radius;
                                 IGRpoint                 ending_point;
                                 IGRdouble                ending_radius;
                                 struct GRvg_construct    *construct_list;
                                 struct EMedge_round_info *my_info;
                                 GRobjid                  *fillet_id)

{


IGRlong                 stat_OM, msg;
IGRlong                 num_bytes;
IGRshort                option;
OMuword                 dum_os;
IGRboolean              tst_planar, stat, closed_curve = 0, on_sf;
IGRint                  i, j, num_loops;
IGRuint                 edg_count;

IGRdouble               v0_or_v1, dist1, dist2, dist_tol;
IGRdouble               crv_param, s1_param, s2_param;
IGRdouble               point_on_surf[2], pt_in_area[2], first_uv[2],
                        last_uv[2];
IGRdouble               default_rho, rho;

IGRpoint                point1, point2;
IGRpoint                base_point, first_pole, last_pole;
IGRpoint                s1_pnt, s2_pnt;

GRobjid                 f_edges[4], comm_edges[2];
GRobjid                 *loop_id, new_edge;
struct GRid             edges[2];
struct EMSpartolbasis   s1_partol, s2_partol;
struct EMSstitch_info   stitch_info;
struct IGRbsp_curve     *iso_curve0, *iso_curve1;
struct IGRbsp_curve     *s1_curve, *s2_curve;
struct IGRbsp_surface   *s1, *s2;
struct IGRbsp_surface   *fsurf;
OM_S_CHANSELECT         to_edges;

/*----------------------------------------------------------------------*/

stat_OM = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;

fsurf = NULL;
s1 = NULL; s2 = NULL;
tst_planar = TRUE;
option = 1;
iso_curve0 = NULL;
iso_curve1 = NULL;

ex$message(msgnumb = EMS_I_GeneratingFilletSurface)

(void) BSEXTRACTPAR (&msg, BSTOLLENVEC, dist_tol);

stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);

my_info->fillet_modified = FALSE;

BSEXTRACTPAR(&msg, BSRHO_VALUE, default_rho);
BSchangepar(&msg, BSRHO_VALUE, rho);

stat_OM = om$send(msg = message EMSsubbs.GRgetsize(
                        &msg,
                        &my_env->md_env.matrix_type, 
                        my_env->md_env.matrix, 
                        &num_bytes),
                  targetid = my_id);
EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

s1 = (struct IGRbsp_surface *) om$malloc(size = (OMuint) num_bytes);
EMerr_hndlr(!s1, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

/* Get the surface-1 geometry */

stat_OM = om$send(msg = message EMSsubbs.GRgetgeom(
                        &msg,
                        &my_env->md_env.matrix_type, 
                        my_env->md_env.matrix, 
                        (IGRchar *) s1),
                  targetid = my_id);
EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

stat_OM = om$send(msg = message EMSsubbs.GRgetsize(
                        &msg,
                        &my_env->md_env.matrix_type, 
                        my_env->md_env.matrix, 
                        &num_bytes),
                  targetid = my_info->comm_surface_id);
EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

s2 = (struct IGRbsp_surface *) om$malloc(size = (OMuint) num_bytes);
EMerr_hndlr(!s2, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

/* Get the surface-2 geometry */

stat_OM = om$send(msg = message EMSsubbs.GRgetgeom(
                        &msg,
                        &my_env->md_env.matrix_type, 
                        my_env->md_env.matrix, 
                        (IGRchar *) s2),
                  targetid = my_info->comm_surface_id);
EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);
 
/* get the partol for both the surfaces */

 BSsfkttol2(s1->u_order, s1->v_order, s1->u_knots, s1->v_knots,
            s1->u_num_poles, s1->v_num_poles, s1->poles, s1->weights,
            &s1_partol.tol, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 s1_partol.is_valid = TRUE;
 s1_partol.in_world = TRUE;
 s1_partol.mattyp = &my_env->md_env.matrix_type;
 s1_partol.mat = my_env->md_env.matrix;

 BSsfkttol2(s2->u_order, s2->v_order, s2->u_knots, s2->v_knots,
            s2->u_num_poles, s2->v_num_poles, s2->poles, s2->weights,
            &s2_partol.tol, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 s2_partol.is_valid = TRUE;
 s2_partol.in_world = TRUE;
 s2_partol.mattyp = &my_env->md_env.matrix_type;
 s2_partol.mat = my_env->md_env.matrix;

 my_info->surface = s1;
 
 BSvarfillsf(s1, s2, starting_radius, ending_radius, s1_nat_norm,
             s2_nat_norm, starting_point, ending_point, &fsurf, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 my_info->fillet_surface = fsurf;
 
 construct_list->geometry = (IGRchar *) fsurf;

 stat_OM = om$construct(classid = OPP_EMSgenbs_class_id,
                        p_objid = fillet_id,
                        msg = message GRgraphics.GRconstruct(
                        construct_list));
 EMerr_hndlr(! (1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

 /* construct the natural boundary for the surface fillet surface */

 stat_OM = om$send (msg = message EMSsurface.EMmk_nat_bdry(&msg,
                          &my_env->md_env, f_edges),
                    targetid = *fillet_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 v0_or_v1 = 0;
 BSalloccv (fsurf->v_order, fsurf->v_num_poles, fsurf->rational,
            NULL, &iso_curve0, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 BSconstprcv (&msg, fsurf, &option, &v0_or_v1, &tst_planar, iso_curve0);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 v0_or_v1 = 1;
 BSalloccv (fsurf->v_order, fsurf->v_num_poles, fsurf->rational,
            NULL, &iso_curve1, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 BSconstprcv (&msg, fsurf, &option, &v0_or_v1, &tst_planar, iso_curve1);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 crv_param = 0.5;

 BScveval (iso_curve0, crv_param, 0, (IGRpoint *)point1, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
 BScveval (iso_curve1, crv_param, 0, (IGRpoint *)point2, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 stat = BSmdistptsf (&msg, s1, point1, &point_on_surf[0],
                     &point_on_surf[1], base_point, &dist1);
 EMerr_hndlr(! stat || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 stat = BSmdistptsf (&msg, s1, point2, &point_on_surf[0],
                     &point_on_surf[1], base_point, &dist2);
 EMerr_hndlr(! stat || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (dist1 < dist2)
  {
   OM_BLOCK_MOVE(point1, s1_pnt, sizeof (IGRpoint));
   OM_BLOCK_MOVE(point2, s2_pnt, sizeof (IGRpoint));
   s1_curve = iso_curve0; s2_curve = iso_curve1;
   s1_param = 0; s2_param = 1.0;
  }
 else
  {
   OM_BLOCK_MOVE(point2, s1_pnt, sizeof (IGRpoint));
   OM_BLOCK_MOVE(point1, s2_pnt, sizeof (IGRpoint));
   s1_curve = iso_curve1; s2_curve = iso_curve0;
   s1_param = 1.0; s2_param = 0;
  }

  
 if (s1_curve->rational)
  {
   for (i=0; i<3; i++)
   {
     first_pole[i] = s1_curve->poles[i] / s1_curve->weights[0];
     last_pole[i] = s1_curve->poles[(s1_curve->num_poles-1)*3+i]/
                    s1_curve->weights[s1_curve->num_poles-1];
   }
  }
 else
  {
   for (i=0; i<3; i++)
   {
     first_pole[i] = s1_curve->poles[i];
     last_pole[i] = s1_curve->poles[(s1_curve->num_poles-1)*3+i];
   }
  }

 stat = BSprptonsf (&msg, s1, first_pole, &first_uv[0], &first_uv[1],
                    &on_sf);
 EMerr_hndlr(! stat || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 stat = BSprptonsf (&msg, s1, last_pole, &last_uv[0], &last_uv[1],
                    &on_sf);
 EMerr_hndlr(! stat || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if ((EM2ddistptpt(first_uv, last_uv) <= s1_partol.tol) &&
     (BSdistptpt(&msg, first_pole, last_pole) <= dist_tol))
      closed_curve = TRUE; /* closed in uv & model space */
   
 EFget_point_in_area (&msg, closed_curve, s1, s1_pnt, s2_pnt, pt_in_area);
 EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);
 
 num_loops = 0;
 loop_id = NULL;

 stat_OM = om$send (msg = message EMSsubbs.EMmake_edge_loop (&msg,
                          my_env, my_info, fsurf, s1, NULL, NULL, NULL,
                          s1_param, EMS_EDGE_BND, round_id,
                          my_info->edge_id, &s1_partol, TRUE, FALSE,
                          pt_in_area, &edges[0], &num_loops, &loop_id),
                    targetid = my_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);
 
 EMget_twin_edge(&msg, fsurf, first_pole, f_edges[0], f_edges[2], TRUE,
                 &comm_edges[0]);
 EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);

 for (i=0; i<num_loops; i++)
  {
   stat_OM = om$get_channel_count(objid = loop_id[i],
                                  p_chanselect = &to_edges,
                                  count = &edg_count);
   EMerr_hndlr(! (1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

   for (j=0; j<edg_count; j++)
    {
     stat_OM = om$get_objid_at_index(objid = loop_id[i],
                                     p_chanselect = &to_edges,
                                     index = j,
                                     objidaddr = &new_edge,
                                     osnumaddr = &dum_os);
     EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

     stitch_info.surf_geom0 = s1;
     stitch_info.edge_geom0 = NULL;
     stitch_info.surf_geom1 = fsurf;
     stitch_info.edge_geom1 = NULL;
     stitch_info.edge0 = new_edge;
     stitch_info.surf0 = my_id;
     stitch_info.edge1 = comm_edges[0];
     stitch_info.surf1 = *fillet_id;

     stitch_info.option = EMSstitch_NoMoveSurfs | EMSstitch_NoOrientSurfs;
            
     stat_OM = om$send(msg = message EMSedge.EMstitch(&msg,
                             &stitch_info, my_env, NULL,
                             NULL, NULL, NULL, NULL),
                       targetid = new_edge);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
    }
  }

 if (s2_curve->rational)
  {
   for (i=0; i<3; i++)
   {
     first_pole[i] = s2_curve->poles[i] / s2_curve->weights[0];
     last_pole[i] = s2_curve->poles[(s2_curve->num_poles-1)*3+i]/
                    s2_curve->weights[s2_curve->num_poles-1];
   }
  }
 else
  {
   for (i=0; i<3; i++)
   {
     first_pole[i] = s2_curve->poles[i];
     last_pole[i] = s2_curve->poles[(s2_curve->num_poles-1)*3+i];
   }
  }

 stat = BSprptonsf (&msg, s2, first_pole, &first_uv[0], &first_uv[1],
                    &on_sf);
 EMerr_hndlr(! stat || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 stat = BSprptonsf (&msg, s2, last_pole, &last_uv[0], &last_uv[1],
                    &on_sf);
 EMerr_hndlr(! stat || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if ((EM2ddistptpt(first_uv, last_uv) <= s2_partol.tol) &&
     (BSdistptpt(&msg, first_pole, last_pole) <= dist_tol))
      closed_curve = TRUE; /* closed in uv & model space */
   
 EFget_point_in_area (&msg, closed_curve, s2, s2_pnt, s1_pnt, pt_in_area);
 EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);
 
 num_loops = 0;
 loop_id = NULL;

 stat_OM = om$send (msg = message EMSsubbs.EMmake_edge_loop (&msg,
                          my_env, my_info, fsurf, s2, NULL, NULL, NULL,
                          s2_param, EMS_EDGE_BND, round_id, NULL_OBJID,
                          &s2_partol, TRUE, FALSE, pt_in_area, &edges[1],
                          &num_loops, &loop_id),
                    targetid = my_info->comm_surface_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 EMget_twin_edge(&msg, fsurf, first_pole, f_edges[0], f_edges[2], TRUE,
                 &comm_edges[1]);
 EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);

 for (i=0; i<num_loops; i++)
  {
   stat_OM = om$get_channel_count(objid = loop_id[i],
                                  p_chanselect = &to_edges,
                                  count = &edg_count);
   EMerr_hndlr(! (1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

   for (j=0; j<edg_count; j++)
    {
     stat_OM = om$get_objid_at_index(objid = loop_id[i],
                                     p_chanselect = &to_edges,
                                     index = j,
                                     objidaddr = &new_edge,
                                     osnumaddr = &dum_os);
     EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

     stitch_info.surf_geom0 = s2;
     stitch_info.edge_geom0 = NULL;
     stitch_info.surf_geom1 = fsurf;
     stitch_info.edge_geom1 = NULL;
     stitch_info.edge0 = new_edge;
     stitch_info.surf0 = my_info->comm_surface_id;
     stitch_info.edge1 = comm_edges[1];
     stitch_info.surf1 = *fillet_id;

     stitch_info.option = EMSstitch_NoMoveSurfs | EMSstitch_NoOrientSurfs;
            
     stat_OM = om$send(msg = message EMSedge.EMstitch(&msg,
                             &stitch_info, my_env, NULL,
                             NULL, NULL, NULL, NULL),
                       targetid = new_edge);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
    }
  }

 ex$message(msgnumb = EMS_I_ClearStatusField)

wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "EMSsubbs.EMvariable_fillet_surface");

 BSchangepar(&msg, BSRHO_VALUE, default_rho);
 if (s1) om$dealloc(ptr = s1);
 if (s2) om$dealloc(ptr = s2);
 if (iso_curve0) BSfreecv(&msg, iso_curve0);
 if (iso_curve1) BSfreecv(&msg, iso_curve1);
 return (stat_OM);
}

end implementation EMSsubbs;
