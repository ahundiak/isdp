/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
class implementation GRvg;

/*
  HISTORY

        Sudha   07/08/93        Modified for BSprototypes ansification
*/

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSopt.h"
#include "EMSmsgdef.h"
#include "EMSlm.h"
#include "EMSlmdef.h"
#include "OMmacros.h"
#include "madetplan.h"
#include "bssfarrevn.h"
#include "bssf_pl_int.h"
#include "bssf3o4cvtn.h"
#include "bsprptonsf.h"
#include "bsmdistptsf.h"
#include "bsmdistcvcv.h"
#include "bsfreecv.h"
#include "bsdistptpt.h"
#include "bschangepar.h"
#include "bsalloccv.h"

%safe
static IGRlong EMget_int_edge();
%endsafe

extern OMuword OPP_EMSgenbs_class_id;

from EMSsubbs import    EMmake_linedge_loop,
                        EMintersect_plane_fillet;
from EMSsurface import  EMmk_nat_bdry;
from EMSboundary import EMget_objid,
                        EMgetsurface_info;
from EMSedge import     EMget_bcxyz_geom,
                        EMget_sf_geom,
                        EMendpts,
                        EMget_sf_edges;

IGRlong EM4ed_vertex_blend (EMmsg,
                            my_env,
                            construct_list,
                            my_info,
                            num_pair_info,
                            pair_info,
                            edge_index,
                            center_point,
                            num_vtx_edges,
                            edge_ids,
                            right_vtx,
                            blend_srf_id,
                            round_id)

IGRlong 	             *EMmsg;
struct GRmd_env          *my_env;
struct GRvg_construct    *construct_list;
struct EMedge_round_info *my_info;
IGRint                   *num_pair_info;
struct EMedge_con_info   *pair_info;
IGRint                   *edge_index;
IGRpoint                 center_point;
IGRint                   num_vtx_edges;
GRobjid                  *edge_ids;
IGRboolean               *right_vtx;
GRobjid                  *blend_srf_id;
GRobjid                  *round_id;

{
 
 IGRlong                 stat_OM, msg;
 GRspacenum              md_osnum;
 IGRboolean              status, onSurf, end_of_edge;
 IGRboolean              blend_generated;
 IGRboolean              small_curve;
 IGRshort                option;
 IGRint                  i, j, num_int1, num_int2, num_entries;
 IGRlong                 num_pla_pnt=3;
 IGRint                  num_groups, *num_points_in_group;
 IGRdouble               top, bot, max_val;
 IGRdouble               knot_tol, bas_tol, chdht_tol;
 IGRdouble               save_cht;
 IGRdouble               dist, dist1, dist2;
 IGRdouble               *par1=NULL, *par2=NULL,
                         *par3=NULL, *par4=NULL;
 IGRdouble               point_on_surf[2];
 IGRdouble               param[2];
 IGRdouble               **xyz_pts,
                         **uv_pts,
                         **dummy;
extern IGRdouble fabs() ;
 IGRpoint                fs1_point, fs2_point;
 IGRpoint                mid_point, beg_pt;
 IGRpoint                pl_point, pl_normal;
 IGRpoint                pla_point[3];
 IGRpoint                *cv1_points, *cv2_points,
                         *cv3_points, *cv4_points;
 IGRvector               norm_vec;
 GRobjid                 bs_edges[4];
 GRobjid                 edge_surf_id, comm_edge;
 struct GRid             surf_GRid, int_edges[2];
 struct IGRplane         plane;
 struct IGRpolyline      poly; 
 struct EMvertex_curves  vertex_curves[4];
 struct IGRbsp_surface   *blend_surface;
 struct IGRbsp_surface   *int_surface;
 struct IGRbsp_surface   **surfaces;
 struct IGRbsp_curve     *int_curve;
 struct IGRbsp_curve     *first_curve, *second_curve;
 struct IGRbsp_curve     int_edge0_geom, int_edge1_geom;
 struct IGRbsp_curve     **curves;
 struct EMSpartolbasis   surf_partol;
 OM_S_CHANSELECT         to_common_edge;

/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 *blend_srf_id = NULL_OBJID;
 blend_generated = TRUE;

 curves = NULL;
 surfaces = NULL;
 int_surface = NULL;
 int_curve = NULL;

 num_groups = 0;
 num_points_in_group = NULL;
 xyz_pts = NULL;
 uv_pts = NULL;
 poly.num_points = NULL;
 poly.points = NULL;
 max_val = MAXFLOAT;

 md_osnum = my_env->md_id.osnum;

 cv1_points = cv2_points = NULL;
 cv3_points = cv4_points = NULL;

 for (i=0; i<4; i++)
  {
   vertex_curves[i].curve = NULL;
   vertex_curves[i].curves_surface = NULL;
  }

 plane.point = &pl_point[0];
 plane.normal = &pl_normal[0];

 stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
 if (! (1 & stat_OM)) goto wrapup;

 if (my_info[edge_index[0]].surface_id ==
     my_info[edge_index[1]].surface_id)
  {
   stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                           &comm_edge),
                     senderid = my_info[edge_index[0]].edge_id,
                     p_chanselect = &to_common_edge);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   EMget_int_edge(&msg, comm_edge, edge_ids, num_vtx_edges, right_vtx,
                  &int_edges[0]);
   EMerr_hndlr (! (1 & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                           &comm_edge),
                     senderid = my_info[edge_index[1]].edge_id,
                     p_chanselect = &to_common_edge);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   EMget_int_edge(&msg, comm_edge, edge_ids, num_vtx_edges, right_vtx,
                  &int_edges[1]);
   EMerr_hndlr (! (1 & msg), *EMmsg, EMS_E_EdgeError, wrapup);
  }
 else
 if (my_info[edge_index[0]].surface_id ==
     my_info[edge_index[1]].comm_surface_id)
  {
   IGRlong  EMget_int_edge();

   stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                           &comm_edge),
                     senderid = my_info[edge_index[0]].edge_id,
                     p_chanselect = &to_common_edge);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   EMget_int_edge(&msg, comm_edge, edge_ids, num_vtx_edges, right_vtx,
                  &int_edges[0]);
   EMerr_hndlr (! (1 & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   EMget_int_edge(&msg, my_info[edge_index[1]].edge_id, edge_ids,
                  num_vtx_edges, right_vtx, &int_edges[1]);
   EMerr_hndlr (! (1 & msg), *EMmsg, EMS_E_EdgeError, wrapup);
  }
 else
 if (my_info[edge_index[0]].comm_surface_id ==
     my_info[edge_index[1]].surface_id)
  {
   IGRlong  EMget_int_edge();

   EMget_int_edge(&msg, my_info[edge_index[0]].edge_id, edge_ids,
                  num_vtx_edges, right_vtx, &int_edges[0]);
   EMerr_hndlr (! (1 & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                           &comm_edge),
                     senderid = my_info[edge_index[1]].edge_id,
                     p_chanselect = &to_common_edge);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   EMget_int_edge(&msg, comm_edge, edge_ids, num_vtx_edges, right_vtx,
                  &int_edges[1]);
   EMerr_hndlr (! (1 & msg), *EMmsg, EMS_E_EdgeError, wrapup);
  }
 else
  {
   IGRlong  EMget_int_edge();

   EMget_int_edge(&msg, my_info[edge_index[0]].edge_id, edge_ids,
                  num_vtx_edges, right_vtx, &int_edges[0]);
   EMerr_hndlr (! (1 & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   EMget_int_edge(&msg, my_info[edge_index[1]].edge_id, edge_ids,
                  num_vtx_edges, right_vtx, &int_edges[1]);
   EMerr_hndlr (! (1 & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   if (my_info[edge_index[0]].comm_surface_id !=
       my_info[edge_index[1]].comm_surface_id)
       blend_generated = FALSE;
  }

 BSEXTRACTPAR(&msg, BSTOLCHRDHT, chdht_tol);
 BSEXTRACTPAR(&msg, BSTOLLENVEC, bas_tol);

 stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                         (&msg, &edge_surf_id, NULL),
                   senderid = NULL_OBJID,
                   targetid = int_edges[0].objid);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 surf_GRid.objid = edge_surf_id;
 surf_GRid.osnum = my_env->md_id.osnum;

 int_edge0_geom.weights = NULL;
 int_edge0_geom.poles = NULL;
 int_edge0_geom.knots = NULL;
 int_edge0_geom.bdrys = NULL;

 stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg,
                         &my_env->md_env, &surf_GRid, NULL, 0,
                         OM_K_MAXINT, FALSE, NULL, &int_edge0_geom),
                   senderid = NULL_OBJID,   
                   targetid = int_edges[0].objid);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 BSmdistcvcv(my_info[edge_index[0]].curve,
             &int_edge0_geom,
             &num_int1,
             &par1, &par2,
             &cv1_points,
             &cv2_points,
             &dist1,
             &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 BSmdistcvcv(my_info[edge_index[0]].comm_curve,
             &int_edge0_geom,
             &num_int2,
             &par3, &par4,
             &cv3_points,
             &cv4_points,
             &dist2,
             &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 j=0;

 if (fabs(dist1) < fabs(dist2))
  {
   if (num_int1 > 1)
    {
     for (i=0; i<num_int1; i++)
      {
       dist = BSdistptpt(&msg, &cv1_points[i][0], center_point);
       if (dist < max_val)
        {
         max_val = dist;
         j=i;
        }
      }
    }

   OM_BLOCK_MOVE (&cv1_points[j][0], fs1_point, sizeof (IGRpoint));
   first_curve = my_info[edge_index[0]].comm_curve;
  }
 else
  {
   if (num_int2 > 1)
    {
     for (i=0; i<num_int2; i++)
      {
       dist = BSdistptpt(&msg, &cv3_points[i][0], center_point);
       if (dist < max_val)
        {
         max_val = dist;
         j=i;
        }
      }
    }

   OM_BLOCK_MOVE (&cv3_points[j][0], fs1_point, sizeof (IGRpoint));
   first_curve = my_info[edge_index[0]].curve;
  }

 max_val = MAXFLOAT;
 j=0;

 stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                         (&msg, &edge_surf_id, NULL),
                   senderid = NULL_OBJID,
                   targetid = int_edges[1].objid);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 surf_GRid.objid = edge_surf_id;
 surf_GRid.osnum = my_env->md_id.osnum;

 int_edge1_geom.weights = NULL;
 int_edge1_geom.poles = NULL;
 int_edge1_geom.knots = NULL;
 int_edge1_geom.bdrys = NULL;

 stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg,
                         &my_env->md_env, &surf_GRid, NULL, 0,
                         OM_K_MAXINT, FALSE, NULL, &int_edge1_geom),
                   senderid = NULL_OBJID,   
                   targetid = int_edges[1].objid);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 BSmdistcvcv(my_info[edge_index[1]].curve,
             &int_edge1_geom,
             &num_int1,
             &par1, &par2,
             &cv1_points,
             &cv2_points,
             &dist1,
             &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 BSmdistcvcv(my_info[edge_index[1]].comm_curve,
             &int_edge1_geom,
             &num_int2,
             &par3, &par4,
             &cv3_points,
             &cv4_points,
             &dist2,
             &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (fabs(dist1) < fabs(dist2))
  {
   if (num_int1 > 1)
    {
     for (i=0; i<num_int1; i++)
      {
       dist = BSdistptpt(&msg, &cv1_points[i][0], center_point);
       if (dist < max_val)
        {
         max_val = dist;
         j=i;
        }
      }
    }

   OM_BLOCK_MOVE (&cv1_points[j][0], fs2_point, sizeof (IGRpoint));
   second_curve = my_info[edge_index[1]].comm_curve;
  }
 else
  {
   if (num_int2 > 1)
    {
     for (i=0; i<num_int2; i++)
      {
       dist = BSdistptpt(&msg, &cv3_points[i][0], center_point);
       if (dist < max_val)
        {
         max_val = dist;
         j=i;
        }
      }
    }

   OM_BLOCK_MOVE (&cv3_points[j][0], fs2_point, sizeof (IGRpoint));
   second_curve = my_info[edge_index[1]].curve;
  }

 stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                         &comm_edge),
                   senderid = int_edges[0].objid,
                   p_chanselect = &to_common_edge);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 
 if ((BSdistptpt(&msg, fs1_point, fs2_point) <= bas_tol) ||
     (! blend_generated) ||
     (int_edges[1].objid == comm_edge))
  {
   option = 0;

   BSEXTRACTPAR (&msg, BSTOLKNOT, knot_tol);

   status = BSprptonsf (&msg, my_info[edge_index[0]].fillet_surface,
                        fs1_point,  &param[0], &param[1], &onSurf);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   if ((param[1] >= knot_tol) && (param[1] <= 1 - knot_tol))
    {
     stat_OM = om$send(msg = message EMSsubbs.EMintersect_plane_fillet(
                             &msg,
                             my_env,
                             TRUE,
                             NULL,
                             &param[1],
                             &my_info[edge_index[0]],
                             FALSE,
                             center_point,
                             num_pair_info,
                             pair_info,
                             NULL,
                             &int_curve,
                             NULL,
                             &pair_info[*num_pair_info].edge,
                             round_id),
                       senderid = NULL_OBJID,
                       targetid = my_info[edge_index[0]].fillet_id);
     EMerr_hndlr(! (1 & stat_OM & msg),*EMmsg,EMS_E_SurfaceError, wrapup);
    }
   else
    {
     stat_OM = EMget_vedge_id (&msg, my_env, param[1], knot_tol,
                               my_info[edge_index[0]].fillet_id,
                               &pair_info[*num_pair_info].edge);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);
    }

   status = BSprptonsf (&msg, my_info[edge_index[1]].fillet_surface,
                        fs2_point,  &param[0], &param[1], &onSurf);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   if ((param[1] >= knot_tol) && (param[1] <= 1 - knot_tol))
    {
     stat_OM = om$send(msg = message EMSsubbs.EMintersect_plane_fillet(
                             &msg,
                             my_env,
                             TRUE,
                             NULL,
                             &param[1],
                             &my_info[edge_index[1]],
                             FALSE,
                             center_point,
                             num_pair_info,
                             pair_info,
                             NULL,
                             &int_curve,
                             NULL,
                             &pair_info[*num_pair_info].comm_edge,
                             round_id),
                       senderid = NULL_OBJID,
                       targetid = my_info[edge_index[1]].fillet_id);
     EMerr_hndlr(! (1 & stat_OM & msg),*EMmsg,EMS_E_SurfaceError, wrapup);
    }
   else
    {
     stat_OM = EMget_vedge_id (&msg, my_env, param[1], knot_tol,
                               my_info[edge_index[1]].fillet_id,
                               &pair_info[*num_pair_info].comm_edge);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);
    }

   pair_info[*num_pair_info].edge_surf = my_info[edge_index[0]].fillet_id;
   pair_info[*num_pair_info].comm_edge_surf =
                                         my_info[edge_index[1]].fillet_id;
   pair_info[*num_pair_info].align_normal = FALSE;
   (*num_pair_info)++;
   goto wrapup;
  }

 BSmdistcvcv(first_curve,
             second_curve,
             &num_int1,
             &par3, &par4,
             &cv3_points,
             &cv4_points,
             &dist1,
             &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 OM_BLOCK_MOVE (&cv3_points[0][0], pla_point[0], sizeof (IGRpoint));
 OM_BLOCK_MOVE (fs1_point, pla_point[1], sizeof (IGRpoint));

 for (i=0; i<3; i++)
  {
   mid_point[i] = (pla_point[0][i] + pla_point[1][i]) / 2.0;
  }

 status = BSmdistptsf (&msg, 
                       my_info[edge_index[0]].fillet_surface,
                       mid_point,
                       &param[0],
                       &param[1],
                       pla_point[2],
                       &dist1);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
 
 if (dist1 <= 2 * chdht_tol)
  {
   BSsfarrevn (&msg, my_info[edge_index[0]].fillet_surface, 1,
               &param[0], 1, &param[1], beg_pt, norm_vec);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   for (i=0; i<3; i++)
        pla_point[2][i] = norm_vec[i] + beg_pt[i];
  }

 status = MAdetplane(&msg, (IGRdouble *)pla_point, &num_pla_pnt, &bas_tol, &plane);
 EMerr_hndlr(! status || !(1&msg), *EMmsg, EMS_E_MAerror, wrapup);

 stat_OM = om$send(msg = message EMSsubbs.EMintersect_plane_fillet(&msg,
                         my_env,
                         FALSE,
                         NULL,
                         &param[1],
                         &my_info[edge_index[0]],
                         FALSE,
                         center_point,
                         num_pair_info,
                         pair_info,
                         &plane,
                         &vertex_curves[0].curve,
                         NULL,
                         &vertex_curves[0].edge_id,
                         round_id),
                     senderid = NULL_OBJID,
                     targetid = my_info[edge_index[0]].fillet_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);
 
 vertex_curves[0].fillet_id = my_info[edge_index[0]].fillet_id;
 vertex_curves[0].curves_surface = my_info[edge_index[0]].fillet_surface;

 OM_BLOCK_MOVE (fs2_point, pla_point[1], sizeof (IGRpoint));

 for (i=0; i<3; i++)
  {
   mid_point[i] = (pla_point[0][i] + pla_point[1][i]) / 2.0;
  }

 status = BSmdistptsf (&msg, 
                       my_info[edge_index[1]].fillet_surface,
                       mid_point,
                       &point_on_surf[0],
                       &point_on_surf[1],
                       pla_point[2],
                       &dist1);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
 
 if (dist1 <= 2 * chdht_tol)
  {
   BSsfarrevn (&msg, my_info[edge_index[1]].fillet_surface, 1,
               &point_on_surf[0], 1, &point_on_surf[1], beg_pt, norm_vec);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   for (i=0; i<3; i++)
        pla_point[2][i] = norm_vec[i] + beg_pt[i];
  }

 status = MAdetplane(&msg, (IGRdouble *)pla_point, &num_pla_pnt, &bas_tol, &plane);
 EMerr_hndlr(! status || !(1&msg), *EMmsg, EMS_E_MAerror, wrapup);

 stat_OM = om$send(msg = message EMSsubbs.EMintersect_plane_fillet(&msg,
                         my_env,
                         FALSE,
                         NULL,
                         &point_on_surf[1],
                         &my_info[edge_index[1]],
                         FALSE,
                         center_point,
                         num_pair_info,
                         pair_info,
                         &plane,
                         &vertex_curves[1].curve,
                         NULL,
                         &vertex_curves[1].edge_id,
                         round_id),
                     senderid = NULL_OBJID,
                     targetid = my_info[edge_index[1]].fillet_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 vertex_curves[1].fillet_id = my_info[edge_index[1]].fillet_id;
 vertex_curves[1].curves_surface = my_info[edge_index[1]].fillet_surface;

 for (i=0; i<num_vtx_edges; i++)
  {
   if (comm_edge == edge_ids[i])
    {
     end_of_edge = right_vtx[i];
     break;
    }
  }

 surf_partol.is_valid = FALSE;
 surf_partol.in_world = FALSE;
 surf_partol.mattyp = &my_env->md_env.matrix_type;
 surf_partol.mat = my_env->md_env.matrix;
 
 stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                         (&msg, &edge_surf_id, &surf_partol),
                   senderid = NULL_OBJID,
                   targetid = comm_edge);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 surf_GRid.objid = edge_surf_id;
 surf_GRid.osnum = my_env->md_id.osnum;

 stat_OM = om$send(msg = message EMSedge.EMget_sf_geom(&msg, &surf_GRid,
                         &int_surface, &my_env->md_env),
                   senderid = NULL_OBJID,
                   targetid = comm_edge);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);
                    
 OM_BLOCK_MOVE (fs1_point, pla_point[0], sizeof (IGRpoint));
 OM_BLOCK_MOVE (fs2_point, pla_point[1], sizeof (IGRpoint));

 for (i=0; i<3; i++)
  {
   mid_point[i] = (pla_point[0][i] + pla_point[1][i]) / 2.0;
  }

 status = BSmdistptsf (&msg, 
                       int_surface,
                       mid_point,
                       &point_on_surf[0],
                       &point_on_surf[1],
                       pla_point[2],
                       &dist1);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
 
 if (dist1 <= 2 * chdht_tol)
  {
   BSsfarrevn (&msg, int_surface, 1, &point_on_surf[0], 1,
               &point_on_surf[1], beg_pt, norm_vec);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   for (i=0; i<3; i++)
        pla_point[2][i] = norm_vec[i] + beg_pt[i];
  }

 status = MAdetplane(&msg, (IGRdouble *)pla_point, &num_pla_pnt, &bas_tol, &plane);
 EMerr_hndlr(! status || !(1&msg), *EMmsg, EMS_E_MAerror, wrapup);

 stat_OM = om$send(msg = message EMSedge.EMendpts(&msg,
                         end_of_edge ? point_on_surf : NULL,
                         end_of_edge ? NULL : point_on_surf,
                         NULL, NULL, NULL),
                   senderid = NULL_OBJID,
                   targetid = comm_edge);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

 BSsf_pl_int (plane.point,
              plane.normal,
              int_surface,
              FALSE,
              &num_groups,
              &num_points_in_group,
              (IGRpoint ***)&xyz_pts,
              (IGRvector ***)&dummy,
              (BSpair ***)&uv_pts,
              &msg);

 /* AMD : 04/01/92 : Fix for TR 92n2716 */
 EMerr_hndlr(msg != BSSUCC || (!num_groups) || (!num_points_in_group),
             *EMmsg, EMS_E_Fail, wrapup);

 poly.num_points = num_points_in_group[0];
 poly.points = uv_pts[0];

 stat_OM = om$send (msg = message EMSsubbs.EMmake_linedge_loop (&msg,
                          FALSE,
                          &poly,
                          round_id,
                          &surf_partol,
                          EMS_EDGE_BND,
                          comm_edge,
                          &vertex_curves[2].edge_id,
                          point_on_surf),
                    senderid = NULL_OBJID,
                    targetid = edge_surf_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 vertex_curves[2].fillet_id = edge_surf_id;
 vertex_curves[2].curves_surface = int_surface;

 BSalloccv(2, num_points_in_group[0], FALSE, 0, &vertex_curves[2].curve,
           &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 vertex_curves[2].curve->order          = 2;
 vertex_curves[2].curve->periodic       = FALSE;
 vertex_curves[2].curve->non_uniform    = FALSE;
 vertex_curves[2].curve->num_poles      = num_points_in_group[0];
 vertex_curves[2].curve->poles          = (IGRdouble *) xyz_pts[0];
 vertex_curves[2].curve->num_knots      = num_points_in_group[0] + 2;
 vertex_curves[2].curve->rational       = FALSE;
 vertex_curves[2].curve->weights        = NULL;
 vertex_curves[2].curve->num_boundaries = 0;
 vertex_curves[2].curve->bdrys          = NULL;
 vertex_curves[2].curve->phy_closed     = FALSE;
 vertex_curves[2].curve->planar         = TRUE;

 vertex_curves[2].curve->knots[0] = vertex_curves[2].curve->knots[1] = 0;
 vertex_curves[2].curve->knots[vertex_curves[2].curve->num_poles] = 1;
 vertex_curves[2].curve->knots[vertex_curves[2].curve->num_poles + 1] = 1;

 for (i=2; i<num_points_in_group[0]; i++)
  {
   top = i-1;
   bot = num_points_in_group[0] - 1;
   vertex_curves[2].curve->knots[i] = top / bot;
  }

 num_entries = 3;
 curves = (struct IGRbsp_curve **) om$malloc(size = num_entries *
                                   sizeof (struct IGRbsp_curve *));
 surfaces = (struct IGRbsp_surface **) om$malloc(size = num_entries *
                                   sizeof (struct IGRbsp_surface *));

 for (i=0; i<num_entries; i++)
      curves[i] = vertex_curves[i].curve;

 surfaces[0] = my_info[edge_index[0]].fillet_surface;
 surfaces[1] = my_info[edge_index[1]].fillet_surface;
 surfaces[2] = int_surface;

 BSsf3o4cvtn(num_entries, curves, surfaces, &blend_surface, &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 blend_surface->pos_orient = FALSE;

 construct_list->geometry = (IGRchar *) blend_surface;

 stat_OM = om$construct(classid = OPP_EMSgenbs_class_id,
                        obj_osnum = NULL,
                        osnum = md_osnum,
                        p_objid = blend_srf_id,
                        msg = message GRgraphics.GRconstruct(
                        construct_list));
 EMerr_hndlr(! (1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

 /* construct the natural boundary for the blend surface */

 stat_OM  = om$send (msg = message EMSsurface.EMmk_nat_bdry(&msg,
                           &my_env->md_env, bs_edges),
                     senderid = NULL_OBJID,
                     targetid = *blend_srf_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 small_curve = FALSE;
 if (BSdistptpt(&msg, fs1_point, fs2_point) <= chdht_tol)
  {
   save_cht = chdht_tol;
   small_curve = TRUE;
   BSchangepar(&msg, BSTOLCHRDHT, bas_tol);
  }

 stat_OM = EMfill_pair_info(&msg, bs_edges, blend_surface, *blend_srf_id,
                            num_pair_info, pair_info, vertex_curves, 3);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);

 if (small_curve)
  {
   BSchangepar(&msg, BSTOLCHRDHT, save_cht);
  }

 my_info[edge_index[0]].ends_free = FALSE;
 my_info[edge_index[1]].ends_free = FALSE;

wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "GRvg.EM4ed_vertex_blend");

 for (i=0; i<4; i++)
  {
   if (vertex_curves[i].curve) BSfreecv(&msg, vertex_curves[i].curve);
  }
 if (curves) om$dealloc(ptr = curves);
 if (surfaces) om$dealloc(ptr = surfaces);

 if (par1) om$dealloc(ptr = par1);
 if (par2) om$dealloc(ptr = par2);
 if (par3) om$dealloc(ptr = par3);
 if (par4) om$dealloc(ptr = par4);

 if (cv1_points) om$dealloc (ptr = cv1_points);
 if (cv2_points) om$dealloc (ptr = cv2_points);
 if (cv3_points) om$dealloc (ptr = cv3_points);
 if (cv4_points) om$dealloc (ptr = cv4_points);

 if (int_edge0_geom.weights) om$dealloc (ptr = int_edge0_geom.weights);
 if (int_edge0_geom.poles) om$dealloc (ptr = int_edge0_geom.poles);
 if (int_edge0_geom.knots) om$dealloc (ptr = int_edge0_geom.knots);
 if (int_edge0_geom.bdrys) om$dealloc (ptr = int_edge0_geom.bdrys);

 if (int_edge1_geom.weights) om$dealloc (ptr = int_edge1_geom.weights);
 if (int_edge1_geom.poles) om$dealloc (ptr = int_edge1_geom.poles);
 if (int_edge1_geom.knots) om$dealloc (ptr = int_edge1_geom.knots);
 if (int_edge1_geom.bdrys) om$dealloc (ptr = int_edge1_geom.bdrys);

 return (stat_OM);

}

static IGRlong EMget_int_edge (EMmsg, my_edge_id, edge_ids, num_vtx_edges,
                               right_vtx, next_edge_id)

IGRlong         *EMmsg;
GRobjid         my_edge_id,
                *edge_ids;
IGRint          num_vtx_edges;
IGRboolean      *right_vtx;
struct GRid     *next_edge_id;

{
 IGRlong     stat_OM, msg;
 IGRboolean  end_of_edge;
 IGRint      i, num_ed;

/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 for (i=0; i<num_vtx_edges; i++)
  {
   if (my_edge_id == edge_ids[i])
    {
     end_of_edge = right_vtx[i];
     break;
    }
  }

 stat_OM = om$send (msg = message EMSedge.EMget_sf_edges(&msg, 
                          end_of_edge ? EMS_EDGE_END_PT : EMS_EDGE_BEG_PT,
                          next_edge_id, &num_ed),
                    senderid = NULL_OBJID,
                    targetid = my_edge_id);  
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "GRvg.EMget_int_edge");
 return (stat_OM);
}

end implementation GRvg;
