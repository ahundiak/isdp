/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
class implementation GRvg;

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "emserr.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSmsgdef.h"
#include "EMSlm.h"
#include "EMSlmdef.h"
#include "emsdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "bssur_sur.h"
#include "bssfeval.h"
#include "bsparameters.h"
#include "bsmdistptsf.h"
#include "bsdistptpts.h"
#include "bsdistptpt.h"

%safe
static IGRlong EFfix_poly();
%endsafe

from EMSsubbs import EMpartolbasis;
from EMSsubbs import EMmake_linedge_loop;
from EMSedge import EMendpts;

IGRlong EMvertex_curves_two_edges (EMmsg,
                                   my_env,
                                   construct_list,
                                   extended_inters,
                                   vtx_point,
                                   my_info,
                                   num_pair_info,
                                   pair_info,
                                   edge_index,
                                   num_rnd_edges,
                                   other_edge_id,
                                   other_surf_id,
                                   round_id)

IGRlong 	             *EMmsg;
struct GRmd_env          *my_env;
struct GRvg_construct    *construct_list;
IGRboolean               extended_inters;
IGRpoint                 vtx_point;
struct EMedge_round_info *my_info;
IGRint                   *num_pair_info;
struct EMedge_con_info   *pair_info;
IGRint                   *edge_index;
IGRint                   *num_rnd_edges;
GRobjid                  other_edge_id, other_surf_id;
GRobjid                  *round_id;

/* History
   Inasu    Mar 28,1990  TR 90N0428  : modified to take care of cases when 
                                       there are more than 1 intersection
                                       between filletting surfaces.
   Janaka: 12/08/1992 : Message sub-system complience.
    Sudha  07/08/93     Modified for BSprototypes ansification

*/

{
 
 IGRlong                 stat_OM, msg;
 IGRshort                edge_end;
 IGRint                  num_groups, *num_points_in_group;
 IGRint                  i,grp_inx;
 IGRboolean              world;
 IGRboolean              status;
 IGRdouble               **xyz_pts,
                         **my_uv_pts,
                         **other_uv_pts;
 IGRdouble               uvbegpt[2], uvendpt[2];
 IGRdouble               my_uv_tol, other_uv_tol;
 IGRdouble               chrdht_tol,
                         convg_tol;
 IGRdouble               dist;
 IGRdouble               point_in_area[2];
 GRobjid                 edges[2];
 IGRpoint                pnts[2];
 IGRpoint                base_point;
 struct IGRpolyline      my_poly, other_poly; 
 struct EMSpartolbasis   my_partol, other_partol;

/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 if (*num_rnd_edges != 2)
  {
   *EMmsg = EMS_E_InvalidArg;
   return (stat_OM);
  }
 if (my_info[edge_index[0]].radius != my_info[edge_index[1]].radius)
  {
   *EMmsg = EMS_E_RndGrExit;
   return (stat_OM);
  }

 num_groups = 0;
 num_points_in_group = NULL;
 xyz_pts = NULL;
 my_uv_pts = NULL;
 other_uv_pts = NULL; 
 my_poly.num_points = 0;
 my_poly.points = NULL;
 other_poly.num_points = 0;
 other_poly.points = NULL;
 world = TRUE;

 BSEXTRACTPAR (&msg, BSTOLCHRDHT, chrdht_tol);
 BSEXTRACTPAR (&msg, BSTOLQNWT, convg_tol);

 status = BSsur_sur (&msg,
                     my_info[edge_index[0]].fillet_surface,
                     my_info[edge_index[1]].fillet_surface,
                     &chrdht_tol,
                     &convg_tol,
                     &num_groups,
                     &num_points_in_group,
                     (IGRpoint ***)&xyz_pts,
                     (BSpair ***)&my_uv_pts,
                     (BSpair ***)&other_uv_pts);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (! num_groups)
  {
   EMextend_to_intersect (&msg,
                          my_env,
                          construct_list,
                          TRUE,
                          my_info,
                          num_pair_info,
                          pair_info,
                          edge_index,
                          vtx_point,
                          other_edge_id,
                          other_surf_id,
                          round_id);
   EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);

   goto wrapup;
  }

 stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg,
                          &my_env->md_env.matrix_type,
                          my_env->md_env.matrix, &world, FALSE,
                          &my_partol.tol),
                    senderid = NULL_OBJID,
                    targetid = my_info[edge_index[0]].fillet_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 my_partol.in_world = TRUE;
 my_partol.is_valid = TRUE;
 my_partol.mattyp = &my_env->md_env.matrix_type;
 my_partol.mat = my_env->md_env.matrix;

 EFextract_par(BSTOLLENVEC, my_partol.tol, &my_uv_tol, &msg);

 stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg,
                          &my_env->md_env.matrix_type,
                          my_env->md_env.matrix, &world, FALSE,
                          &other_partol.tol),
                    senderid = NULL_OBJID,
                    targetid = my_info[edge_index[1]].fillet_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 other_partol.in_world = TRUE;
 other_partol.is_valid = TRUE;
 other_partol.mattyp = &my_env->md_env.matrix_type;
 other_partol.mat = my_env->md_env.matrix;

/* The following lines were inserted to fix TR 90n0428                */
/* If there are more than one intersection , the following code would */
/* select the intersection group closer to the vertex                 */

   grp_inx = 0;   

   if (num_groups > 1)
  {
   IGRdouble check_dist;

   check_dist = MAXFLOAT;
   for (i=0; i<num_groups; i++)
    {
     dist = BSdistptpt(&msg, vtx_point, &xyz_pts[i][0]);
     if (dist <= check_dist)
      {
       grp_inx = i;
       check_dist = dist;
      }
    }
  }
/* Insertion over   TR 90n0428                      */

 my_poly.num_points = num_points_in_group[grp_inx];
 my_poly.points = my_uv_pts[grp_inx];

 {
   EFfix_poly (my_info, edge_index, &my_poly, my_uv_tol);

   other_poly.num_points = num_points_in_group[grp_inx];
   other_poly.points = other_uv_pts[grp_inx];

   EFextract_par(BSTOLLENVEC, other_partol.tol, &other_uv_tol, &msg);

   EFfix_poly (my_info, edge_index, &other_poly, other_uv_tol);
 }

 if (((my_uv_pts[grp_inx][0] >= my_uv_tol) && 
                       (my_uv_pts[grp_inx][0] <= 1-my_uv_tol)) ||
     ((my_uv_pts[grp_inx][2 * (num_points_in_group[grp_inx] - 1)] >= my_uv_tol)
    && (my_uv_pts[grp_inx][2 * (num_points_in_group[grp_inx] - 1)] <=
                                 1-my_uv_tol)) ||
     ((other_uv_pts[grp_inx][0] >= other_uv_tol) &&
      (other_uv_pts[grp_inx][0] <= 1-other_uv_tol)) ||
     ((other_uv_pts[grp_inx][2 * (num_points_in_group[grp_inx]-1)]
                                                      >= other_uv_tol) &&
     (other_uv_pts[grp_inx][2 * (num_points_in_group[grp_inx]-1)]
                                                        <= 1-other_uv_tol)))
  {
   ex$message( msgnumb = EMS_S_TrimFailedGenBln );

   EMtwo_edge_vertex_surface (&msg,
                              my_env,
                              construct_list,
                              other_edge_id,
                              other_surf_id,
                              my_info,
                              num_pair_info,
                              pair_info,
                              edge_index,
                              vtx_point,
                              round_id);                              
   EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
   goto wrapup;
  }

 stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, uvbegpt, uvendpt,
                         NULL,NULL,NULL),
                   senderid = NULL_OBJID,
                   targetid = my_info[edge_index[0]].edge_id);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

 BSsfeval(my_info[edge_index[0]].surface, uvbegpt[0], uvbegpt[1], 0,
          (IGRpoint *)pnts[0], &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 BSsfeval(my_info[edge_index[0]].surface, uvendpt[0], uvendpt[1], 0,
          (IGRpoint *)pnts[1], &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (BSdistptpts(&msg, vtx_point, pnts[0]) <
     BSdistptpts(&msg, vtx_point, pnts[1]))
     edge_end = EMS_EDGE_END_PT;
  else
     edge_end = EMS_EDGE_BEG_PT;     

 status = BSmdistptsf (&msg, 
                       my_info[edge_index[0]].fillet_surface,
                       (edge_end == EMS_EDGE_END_PT) ? pnts[1] : pnts[0],
                       &point_in_area[0],
                       &point_in_area[1],
                       base_point,
                       &dist);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 stat_OM = om$send (msg = message EMSsubbs.EMmake_linedge_loop (&msg,
                          FALSE,
                          &my_poly,
                          round_id,
                          &my_partol,
                          EMS_DUMMY_BND,
                          NULL_OBJID,
                          &edges[0],
                          point_in_area),
                    senderid = NULL_OBJID,
                    targetid = my_info[edge_index[0]].fillet_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, uvbegpt, uvendpt,
                         NULL,NULL,NULL),
                   senderid = NULL_OBJID,
                   targetid = my_info[edge_index[1]].edge_id);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

 BSsfeval(my_info[edge_index[1]].surface, uvbegpt[0], uvbegpt[1], 0,
          (IGRpoint *)pnts[0], &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 BSsfeval(my_info[edge_index[1]].surface, uvendpt[0], uvendpt[1], 0,
          (IGRpoint *)pnts[1], &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (BSdistptpts(&msg, vtx_point, pnts[0]) <
     BSdistptpts(&msg, vtx_point, pnts[1]))
     edge_end = EMS_EDGE_END_PT;
  else
     edge_end = EMS_EDGE_BEG_PT;     

 status = BSmdistptsf (&msg, 
                       my_info[edge_index[1]].fillet_surface,
                       (edge_end == EMS_EDGE_END_PT) ? pnts[1] : pnts[0],
                       &point_in_area[0],
                       &point_in_area[1],
                       base_point,
                       &dist);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 stat_OM = om$send (msg = message EMSsubbs.EMmake_linedge_loop (&msg,
                          FALSE,
                          &other_poly,
                          round_id,
                          &other_partol,
                          EMS_DUMMY_BND,
                          NULL_OBJID,
                          &edges[1],
                          point_in_area),
                    senderid = NULL_OBJID,
                    targetid = my_info[edge_index[1]].fillet_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 pair_info[*num_pair_info].edge = edges[0];
 pair_info[*num_pair_info].comm_edge = edges[1];
 pair_info[*num_pair_info].edge_surf = my_info[edge_index[0]].fillet_id;
 pair_info[*num_pair_info].comm_edge_surf =
                                       my_info[edge_index[1]].fillet_id;
 pair_info[*num_pair_info].align_normal = FALSE;
 (*num_pair_info)++;

 wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "GRvg.EMvertex_curves_two_edges");
 if (xyz_pts)
  {
   for (i = 0; i < num_groups; i++)
    {
     if (xyz_pts[i]) free(xyz_pts[i]);
    }
   free(xyz_pts);
  }
	return (stat_OM);

}

static IGRlong EFfix_poly (my_info, edge_index, poly, fix_tol)

struct EMedge_round_info *my_info;
IGRint *edge_index;
struct IGRpolyline *poly;
IGRdouble fix_tol;
{
 IGRlong stat_OM = OM_S_SUCCESS;
 if (my_info[edge_index[0]].radius != my_info[edge_index[1]].radius)
     return(stat_OM);
 else
  {
   if (poly->points[0] <= fix_tol) poly->points[0] = 0;  
   if (poly->points[2 * (poly->num_points - 1)] <= fix_tol)
       poly->points[2 * (poly->num_points - 1)] = 0;  
   
   if (poly->points[0] >= 1-fix_tol) poly->points[0] = 1;  
   if (poly->points[2 * (poly->num_points - 1)] >= 1 - fix_tol)
       poly->points[2 * (poly->num_points - 1)] = 1;  
   return(stat_OM);
  } 
}

end implementation GRvg;

