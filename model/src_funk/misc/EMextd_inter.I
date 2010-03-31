/* ###################   APOGEE COMPILED   ################## */
/*         History : 

	gupta   1988      
        Sudha   07/08/93        Modified for BSprototypes ansification
*/

class implementation GRvg;

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsdef.h"
#include "emsmacros.h"
#include "emserr.h"
#include "EMSopt.h"
#include "EMSmsgdef.h"
#include "OMmacros.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSlm.h"
#include "bssfeval.h"
#include "bsprptonsf.h"
#include "bsmdistptsf.h"
#include "bsmdistcvcv.h"

from EMSsubbs import EMpartolbasis;
from EMSsubbs import EMget_edges;
from EMSsubbs import EMextend_fillet;
from EMSedge import EMextend_geometry;
from EMSboundary import EMget_objid;
from EMSsfround import EMget_boundary_in_model_space;
from EMSsfround import EMreevaluate_geometry;
from EMSedge import EMget_bcxyz_geom;

IGRboolean EMextend_to_intersect (EMmsg,
                                  my_env,
                                  construct_list,
                                  neutral_edge,
                                  my_info,
                                  num_pair_info,
                                  pair_info,
                                  edge_index,
                                  center_point,
                                  other_edge_id,
                                  other_surf_id,
                                  round_id)

IGRlong 	             *EMmsg;
struct GRmd_env          *my_env;
struct GRvg_construct    *construct_list;
IGRboolean               neutral_edge;
struct EMedge_round_info *my_info;
IGRint                   *num_pair_info;
struct EMedge_con_info   *pair_info;
IGRint                   *edge_index;
IGRpoint                 center_point;
GRobjid                  other_edge_id, other_surf_id;
GRobjid                  *round_id;

{
 
 IGRlong                 stat_OM, msg;
 IGRlong                 srf_size;
 IGRint                  index;
 IGRint                  num_int;
 IGRint                  num_rnd_edges;
 IGRdouble               *par1=NULL, *par2=NULL,
                         *par3=NULL, *par4=NULL;
 IGRdouble               dist, knot_tol, bas_tol, cht_tol;
 IGRdouble               dist1, dist2, d1, d2, v_param[2];
 extern IGRdouble        fabs();
 IGRboolean              status,
                         world,
                         boundary_exists,
                         onSurf,
                         fill0_extended, fill1_extended;
 IGRpoint                start_point, base_point;
 IGRpoint                fs1_point, fs2_point, eval_pt;
 IGRpoint                pt_area;
 IGRpoint                *cv1_points, *cv2_points,
                         *cv3_points, *cv4_points;
 IGRpoint                parting_point;
 IGRdouble               param[2];
 IGRdouble               end_param[4];
 IGRdouble               point_on_surf[2];
 GRobjid                 to_extend_edge1, to_extend_edge2,
                         boundary_edge,
                         rnd_comm_edge,
                         good_id;
 struct GRid             surf_GRid;
 struct IGRbsp_curve     *edge_geom;
 struct IGRbsp_curve     other_edge_geom;
 struct IGRbsp_surface   *surface,
                         *fill0_surf_pointer,
                         *fill1_surf_pointer,
                         *extended_surface;
 struct EMSpartolbasis   surf_partol,
                         s1_partol,
                         s2_partol;
 OM_S_CHANSELECT         to_common_edge; 

/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;
 surface = NULL;
 extended_surface = NULL;
 num_rnd_edges = 2;
 fill0_extended = fill1_extended = FALSE;

 fill0_surf_pointer = my_info[edge_index[0]].fillet_surface;
 fill1_surf_pointer = my_info[edge_index[1]].fillet_surface;

 surf_GRid.objid = other_surf_id;
 surf_GRid.osnum = my_env->md_id.osnum;

 cv1_points = cv2_points = NULL;
 cv3_points = cv4_points = NULL;
 
 if (my_info[edge_index[0]].radius != my_info[edge_index[1]].radius)
  {
   *EMmsg = EMS_E_RndGrExit;
   return(stat_OM);
  }

 if (my_info[edge_index[0]].fillet_surface->v_phy_closed)
     my_info[edge_index[0]].fillet_modified = TRUE;
 if (my_info[edge_index[1]].fillet_surface->v_phy_closed)
     my_info[edge_index[1]].fillet_modified = TRUE;

 BSEXTRACTPAR (&msg, BSTOLKNOT, knot_tol);
 BSEXTRACTPAR(&msg, BSTOLCHRDHT, cht_tol);
 BSEXTRACTPAR(&msg, BSTOLLENVEC, bas_tol);
 
 stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
 if (! (1 & stat_OM)) goto wrapup;

 other_edge_geom.weights = NULL;
 other_edge_geom.poles = NULL;
 other_edge_geom.knots = NULL;
 other_edge_geom.bdrys = NULL;

 stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg,
                         &my_env->md_env, &surf_GRid, NULL, 0,
                         OM_K_MAXINT, FALSE, NULL, &other_edge_geom),
                   senderid = NULL_OBJID,
                   targetid = other_edge_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 BSmdistcvcv(my_info[edge_index[0]].curve,
             &other_edge_geom,
             &num_int,
             &par1, &par2,
             &cv1_points,
             &cv2_points,
             &dist1,
             &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (dist1 < bas_tol)
  {
   OM_BLOCK_MOVE (&cv1_points[0][0], fs1_point, sizeof (IGRpoint));
   d1 = dist1;
  }
 else
  {
   BSmdistcvcv(my_info[edge_index[0]].comm_curve,
               &other_edge_geom,
               &num_int,
               &par3, &par4,
               &cv3_points,
               &cv4_points,
               &dist2,
               &msg);
   EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   if (fabs(dist1) < fabs(dist2))
    {
     OM_BLOCK_MOVE (&cv1_points[0][0], fs1_point, sizeof (IGRpoint));
     d1 = dist1;
    }
   else
    {
     OM_BLOCK_MOVE (&cv3_points[0][0], fs1_point, sizeof (IGRpoint));
     d1 = dist2;
    }
  }

 OM_BLOCK_MOVE (fs1_point, eval_pt, sizeof (IGRpoint));

 BSmdistcvcv(my_info[edge_index[1]].curve,
             &other_edge_geom,
             &num_int,
             &par1, &par2,
             &cv1_points,
             &cv2_points,
             &dist1,
             &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (dist1 < bas_tol)
  {
   OM_BLOCK_MOVE (&cv1_points[0][0], fs2_point, sizeof (IGRpoint));
   d2 = dist1;
  }
 else
  {
   BSmdistcvcv(my_info[edge_index[1]].comm_curve,
               &other_edge_geom,
               &num_int,
               &par3, &par4,
               &cv3_points,
               &cv4_points,
               &dist2,
               &msg);
   EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   if (fabs(dist1) < fabs(dist2))
    {
     OM_BLOCK_MOVE (&cv1_points[0][0], fs2_point, sizeof (IGRpoint));
     d2 = dist1;
    }
   else
    {
     OM_BLOCK_MOVE (&cv3_points[0][0], fs2_point, sizeof (IGRpoint));
     d2 = dist2;
    }
  }

 if (d2 < d1)
     OM_BLOCK_MOVE (fs2_point, eval_pt, sizeof (IGRpoint));
 
 status = BSprptonsf (&msg, my_info[edge_index[0]].fillet_surface,
                      fs1_point,  &param[0], &param[1], &onSurf);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 v_param[0] = param[1];

 end_param[0] = (param[0] < 0.5) ? 1 : 0;
 end_param[1] = param[1];

 BSsfeval(my_info[edge_index[0]].fillet_surface, end_param[0],
          end_param[1], 0, (IGRpoint *)start_point, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (! my_info[edge_index[0]].fillet_modified)
  {
   edge_geom = NULL;

   stat_OM = om$send(msg=message EMSsfround.EMget_boundary_in_model_space(
                         &msg, my_env, my_info[edge_index[0]].fillet_id,
                         my_info[edge_index[0]].fillet_surface,
                         &boundary_edge, &edge_geom, pt_area, &index,
                         &boundary_exists),
                      senderid = NULL_OBJID,
                      targetid = *round_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

   stat_OM = om$send (msg = message EMSsubbs.EMextend_fillet(&msg, my_env,
                            my_info[edge_index[0]].radius, param,
                            my_info[edge_index[0]].fillet_surface,
                            &extended_surface),
                      senderid = NULL_OBJID,
                      targetid = my_info[edge_index[0]].fillet_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

   my_info[edge_index[0]].fillet_surface = extended_surface;
   my_info[edge_index[0]].fillet_modified = TRUE;

   if (my_info[edge_index[0]].ends_free)
    {
     param[1] = (param[1] < 0.5) ? 1 : 0;
     extended_surface = NULL;
     
     stat_OM = om$send (msg = message EMSsubbs.EMextend_fillet(&msg,
                              my_env,my_info[edge_index[0]].radius, param,
                              my_info[edge_index[0]].fillet_surface,
                              &extended_surface),
                        senderid = NULL_OBJID,
                        targetid = my_info[edge_index[0]].fillet_id);
     EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError,wrapup);


     my_info[edge_index[0]].fillet_surface = extended_surface;
    } 
   if (boundary_exists)
    {
     stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg,
                              &my_env->md_env.matrix_type,
                              my_env->md_env.matrix, &world, FALSE,
                              &s1_partol.tol),
                        senderid = NULL_OBJID,
                        targetid = my_info[edge_index[0]].fillet_id);
     EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg, EMS_E_SurfaceError, wrapup);

     s1_partol.in_world = TRUE;
     s1_partol.is_valid = TRUE;
     s1_partol.mattyp = &my_env->md_env.matrix_type;
     s1_partol.mat = my_env->md_env.matrix;

     stat_OM = om$send(msg = message EMSsfround.EMreevaluate_geometry(
                             &msg, my_env, index, pt_area, 
                             my_info[edge_index[0]].fillet_id,
                             boundary_edge, edge_geom, 
                             my_info[edge_index[0]].fillet_surface,
                             num_pair_info, pair_info, &s1_partol),
                       senderid = NULL_OBJID,
                       targetid = *round_id);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

     if (edge_geom) om$dealloc(ptr = edge_geom);
    }
   fill0_extended =
       (my_info[edge_index[0]].fillet_surface != fill0_surf_pointer) ?
                                                        TRUE : FALSE;
  }

 status = BSprptonsf (&msg, my_info[edge_index[1]].fillet_surface,
                      fs2_point, &param[0], &param[1], &onSurf);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 v_param[1] = param[1];

 end_param[2] = (param[0] < 0.5) ? 1 : 0;
 end_param[3] = param[1];

 if (! my_info[edge_index[1]].fillet_modified)
  {
   edge_geom = NULL;

   stat_OM = om$send(msg=message EMSsfround.EMget_boundary_in_model_space(
                         &msg, my_env, my_info[edge_index[1]].fillet_id,
                         my_info[edge_index[1]].fillet_surface,
                         &boundary_edge, &edge_geom, pt_area, &index,
                         &boundary_exists),
                      senderid = NULL_OBJID,
                      targetid = *round_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

   extended_surface = NULL;
   stat_OM = om$send (msg = message EMSsubbs.EMextend_fillet(&msg, my_env,
                            my_info[edge_index[1]].radius, param,
                            my_info[edge_index[1]].fillet_surface,
                            &extended_surface),
                      senderid = NULL_OBJID,
                      targetid = my_info[edge_index[1]].fillet_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);
  
   my_info[edge_index[1]].fillet_surface = extended_surface;
   my_info[edge_index[1]].fillet_modified = TRUE;

   if (my_info[edge_index[1]].ends_free)
    {
     param[1] = (param[1] < 0.5) ? 1 : 0;
     extended_surface = NULL;

     stat_OM = om$send (msg = message EMSsubbs.EMextend_fillet(&msg,
                              my_env,my_info[edge_index[1]].radius, param,
                              my_info[edge_index[1]].fillet_surface,
                              &extended_surface),
                        senderid = NULL_OBJID,
                        targetid = my_info[edge_index[1]].fillet_id);
     EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError,wrapup);
     my_info[edge_index[1]].fillet_surface = extended_surface;
    } 
   if (boundary_exists)
    {
     stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg,
                              &my_env->md_env.matrix_type,
                              my_env->md_env.matrix, &world, FALSE,
                              &s2_partol.tol),
                        senderid = NULL_OBJID,
                        targetid = my_info[edge_index[1]].fillet_id);
     EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg, EMS_E_SurfaceError, wrapup);

     s2_partol.in_world = TRUE;
     s2_partol.is_valid = TRUE;
     s2_partol.mattyp = &my_env->md_env.matrix_type;
     s2_partol.mat = my_env->md_env.matrix;

     stat_OM = om$send(msg = message EMSsfround.EMreevaluate_geometry(
                             &msg, my_env, index, pt_area, 
                             my_info[edge_index[1]].fillet_id,
                             boundary_edge, edge_geom, 
                             my_info[edge_index[1]].fillet_surface,
                             num_pair_info, pair_info, &s2_partol),
                       senderid = NULL_OBJID,
                       targetid = *round_id);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

     if (edge_geom) om$dealloc(ptr = edge_geom);
    }
   fill1_extended =
       (my_info[edge_index[1]].fillet_surface != fill1_surf_pointer) ?
                                                        TRUE : FALSE;
  }

 if (neutral_edge)
  {
   EMtangential_fillet_intersection (&msg,
                                     my_env,
                                     center_point,
                                     num_pair_info,
                                     pair_info,
                                     &other_edge_geom,
                                     eval_pt,
                                     v_param,
                                     fill0_extended,
                                     fill1_extended,
                                     my_info,
                                     edge_index,
                                     parting_point,
                                     round_id);
   EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);
  }
 else
  {
   EMvertex_curves_two_edges (&msg,
                              my_env,
                              construct_list,
                              TRUE,
                              center_point,
                              my_info,
                              num_pair_info,
                              pair_info,
                              edge_index,
                              &num_rnd_edges,
                              other_edge_id,
                              other_surf_id,
                              round_id);
   EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);
  }

 status = BSprptonsf (&msg, my_info[edge_index[0]].surface,
                      start_point,  &point_on_surf[0], &point_on_surf[1],
                      &onSurf);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (! onSurf)
  {
   status = BSmdistptsf (&msg, 
                         my_info[edge_index[0]].surface,
                         start_point,
                         &point_on_surf[0],
                         &point_on_surf[1],
                         base_point,
                         &dist);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   onSurf = (dist <= cht_tol) ? TRUE : FALSE;
  }

 if (! onSurf)
  {
   stat_OM = om$send(msg = message GRvg.GRgetsize(&msg,
                           &my_env->md_env.matrix_type,
                           my_env->md_env.matrix,
                           &srf_size),
                     senderid = NULL_OBJID,
                     targetid = my_info[edge_index[0]].comm_surface_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
             
   surface = (struct IGRbsp_surface *) om$malloc(size =(OMuint) srf_size);
   EMerr_hndlr(! surface, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  
   stat_OM = om$send(msg = message GRvg.GRgetgeom(&msg,
                           &my_env->md_env.matrix_type,
                           my_env->md_env.matrix,
                           (IGRchar *)surface),
                     senderid = NULL_OBJID,
                     targetid = my_info[edge_index[0]].comm_surface_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
  }
 
 good_id = (onSurf) ? my_info[edge_index[0]].surface_id :
                      my_info[edge_index[0]].comm_surface_id;

 stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg,
                          &my_env->md_env.matrix_type,
                          my_env->md_env.matrix, &world, FALSE,
                          &surf_partol.tol),
                    senderid = NULL_OBJID,
                    targetid = good_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 surf_partol.in_world = TRUE;
 surf_partol.is_valid = TRUE;
 surf_partol.mattyp = &my_env->md_env.matrix_type;
 surf_partol.mat = my_env->md_env.matrix;

 if (fill0_extended)
  {
   IGRlong  EMget_uedge_id();

   stat_OM = EMget_uedge_id (&msg, my_env, end_param[0], knot_tol,
                             my_info[edge_index[0]].fillet_id,
                             &to_extend_edge1);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);

   if (! onSurf)
    {
     stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                             &rnd_comm_edge),
                       senderid = my_info[edge_index[0]].edge_id,
                       p_chanselect = &to_common_edge);
     EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
    }

   stat_OM = om$send (msg = message EMSedge.EMextend_geometry(&msg,
                            (onSurf) ? my_info[edge_index[0]].edge_id :
                                       rnd_comm_edge,
                            my_info[edge_index[0]].fillet_id,
                            good_id,
                            (onSurf) ? my_info[edge_index[0]].surface :
                                       surface,
                            &surf_partol,
                            round_id,
                            my_env),
                      senderid = NULL_OBJID,
                      targetid = to_extend_edge1);
   EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError, wrapup);
  }

 if ((my_info[edge_index[0]].surface_id !=
      my_info[edge_index[1]].surface_id) &&
     (my_info[edge_index[0]].comm_surface_id !=
      my_info[edge_index[1]].comm_surface_id))
  {
   status = BSprptonsf (&msg, my_info[edge_index[1]].surface, start_point,
                      &point_on_surf[0], &point_on_surf[1], &onSurf);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   if (! onSurf)
    {
     stat_OM = om$send(msg = message GRvg.GRgetsize(&msg,
                             &my_env->md_env.matrix_type,
                             my_env->md_env.matrix,
                             &srf_size),
                       senderid = NULL_OBJID,
                       targetid = my_info[edge_index[1]].comm_surface_id);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
             
     surface=(struct IGRbsp_surface *) om$malloc(size =(OMuint) srf_size);
     EMerr_hndlr(! surface, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  
     stat_OM = om$send(msg = message GRvg.GRgetgeom(&msg,
                             &my_env->md_env.matrix_type,
                             my_env->md_env.matrix,
                             (IGRchar *)surface),
                       senderid = NULL_OBJID,
                       targetid = my_info[edge_index[1]].comm_surface_id);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
    }
 
   good_id = (onSurf) ? my_info[edge_index[1]].surface_id :
                        my_info[edge_index[1]].comm_surface_id;

   stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg,
                            &my_env->md_env.matrix_type,
                            my_env->md_env.matrix, &world, FALSE,
                            &surf_partol.tol),
                      senderid = NULL_OBJID,
                      targetid = good_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

   surf_partol.in_world = TRUE;
   surf_partol.is_valid = TRUE;
   surf_partol.mattyp = &my_env->md_env.matrix_type;
   surf_partol.mat = my_env->md_env.matrix;
  }

 if (fill1_extended)
  {
   IGRlong  EMget_uedge_id();

   stat_OM = EMget_uedge_id (&msg, my_env, end_param[2], knot_tol,
                             my_info[edge_index[1]].fillet_id,
                             &to_extend_edge2);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);

   if (! onSurf)
    {
     stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                             &rnd_comm_edge),
                       senderid = my_info[edge_index[1]].edge_id,
                       p_chanselect = &to_common_edge);
     EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
    }

   stat_OM = om$send (msg = message EMSedge.EMextend_geometry(&msg,
                            (onSurf) ? my_info[edge_index[1]].edge_id :
                                       rnd_comm_edge,
                            my_info[edge_index[1]].fillet_id,
                            good_id,
                            (onSurf) ? my_info[edge_index[1]].surface :
                                       surface,
                            &surf_partol,
                            round_id,
                            my_env),
                      senderid = NULL_OBJID,
                      targetid = to_extend_edge2);
   EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError, wrapup);
  }

 if (neutral_edge)
  {
   IGRlong  EMget_uedge_id();

   stat_OM = EMget_uedge_id (&msg, my_env, end_param[0], knot_tol,
                             my_info[edge_index[0]].fillet_id,
                             &to_extend_edge1);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);

   stat_OM = EMget_uedge_id (&msg, my_env, end_param[2], knot_tol,
                             my_info[edge_index[1]].fillet_id,
                             &to_extend_edge2);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);

   stat_OM = EMfix_two_edges (&msg,
                   my_env,
                   my_info,
                   edge_index,
                   good_id,
                   (onSurf) ? my_info[edge_index[0]].surface : surface,
                   parting_point,
                   to_extend_edge1,
                   to_extend_edge2,
                   &surf_partol);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);
  }

 wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "GRvg.EMextend_to_intersect");

 if (par1) om$dealloc(ptr = par1);
 if (par2) om$dealloc(ptr = par2);
 if (par3) om$dealloc(ptr = par3);
 if (par4) om$dealloc(ptr = par4);

 if (cv1_points) om$dealloc (ptr = cv1_points);
 if (cv2_points) om$dealloc (ptr = cv2_points);
 if (cv3_points) om$dealloc (ptr = cv3_points);
 if (cv4_points) om$dealloc (ptr = cv4_points);

 if (other_edge_geom.weights) om$dealloc (ptr = other_edge_geom.weights);
 if (other_edge_geom.poles) om$dealloc (ptr = other_edge_geom.poles);
 if (other_edge_geom.knots) om$dealloc (ptr = other_edge_geom.knots);
 if (other_edge_geom.bdrys) om$dealloc (ptr = other_edge_geom.bdrys);

 if (surface) om$dealloc (ptr = surface);
 return (stat_OM);

}

IGRlong EMget_uedge_id (EMmsg, my_env, param, knot_tol, fillet_id,
                               extend_edge_id)

IGRlong         *EMmsg;
struct GRmd_env *my_env;
IGRdouble       param,
                knot_tol;
GRobjid         fillet_id,
                *extend_edge_id;

/* History 
   Inasu: Dec 7,90 : Changed the option EMS_OPT_STITCHED to a new option
		     EMS_OPT_STITCHED_ALL.
*/
{
 IGRlong         stat_OM, msg;
 GRobjid         edge_id;
 struct GRid     *edges = NULL;
 IGRint          num_edges = 0,
                 buf_size = 0;
 OM_S_CHANSELECT to_common_edge; 

/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;
 
 edges = NULL;

 stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
 if (! (1 & stat_OM)) goto wrapup;

 stat_OM = om$send(msg = message EMSsubbs.EMget_edges(&msg, MAXINT,
                         EMS_OPT_STITCHED_ALL, my_env, &edges, &buf_size,
                         &num_edges),
                   senderid = NULL_OBJID,
                   targetid = fillet_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError,wrapup);

 if (num_edges > 2) 
  {
   *EMmsg = EMS_I_InvalidArg;
   goto wrapup;
  }

 edge_id = (param <= knot_tol) ? edges[0].objid : edges[1].objid;

 stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                         extend_edge_id),
                   senderid = edge_id,
                   p_chanselect = &to_common_edge);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "GRvg.EMget_uedge_id");
 return (stat_OM);
}

end implementation GRvg;
