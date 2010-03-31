/* ###################   APOGEE COMPILED   ################## */
/*           History : gupta : 09/22/89            

    Sudha  07/09/93  :  Modified for BSprototypes anisfication

*/

class implementation GRvg;

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsdef.h"
#include "emsmacros.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "OMmacros.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "EMSlm.h"
#include "EMSlmdef.h"
#include "madetplan.h"
#include "bssfeval.h"
#include "bsprptonsf.h"
#include "bsmdistptsf.h"
#include "bsdistptpts.h"
#include "bsconstprcv.h"
#include "bsalloccv.h"

from EMSsubbs import EMintersect_plane_fillet;
from EMSsubbs import EMpartolbasis;
from EMSedge import EMendpts;
from EMSedge import EMset_props;

IGRlong EMtrim_vertex_with_only_two_edges (EMmsg,
                                           my_env,
                                           num_vtx_edges,
                                           edge_ids,
                                           right_vtx,
                                           num_pair_info,
                                           pair_info,
                                           edge_index,
                                           my_info,
                                           round_id)

IGRlong 	             *EMmsg;
struct GRmd_env          *my_env;
IGRint                   num_vtx_edges;
GRobjid                  *edge_ids;
IGRboolean               *right_vtx;
IGRint                   *num_pair_info;
struct EMedge_con_info   *pair_info;
IGRint                   *edge_index;
struct EMedge_round_info *my_info;
GRobjid                  *round_id;

{
 
 IGRlong                 stat_OM, msg;
 IGRlong                 srf_size;
 IGRint                  i, j;
 IGRlong                 num_pla_pnt = 3;
 IGRshort                option=0;  /*changed to short DLB 10/23/91 - SUN*/
 IGRdouble               u_par, v_par;
 IGRdouble               edge_uv_end[2];
 IGRdouble               bas_tol, cht_tol, knot_tol;
 IGRdouble               dist, end_param[4];
 IGRdouble               point_on_surf[2];
 IGRboolean              status, onSurf, ON_Surf, world, tst_planar=FALSE;
 IGRpoint                pla_points[3], pointa, pointb;
 IGRpoint                vtx_point, base_point;
 IGRpoint                pl_point, pl_normal;
 GRobjid                 to_extend_edge1, to_extend_edge2,
                         good_id;
 struct IGRplane         plane;
 struct IGRbsp_curve     *int_curve0, *int_curve1;
 struct IGRbsp_curve     *iso_curve;
 struct IGRbsp_surface   *surface;
 struct EMSpartolbasis   surf_partol;

/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 int_curve0 = NULL;
 int_curve1 = NULL;
 iso_curve = NULL;
 
 if (my_info[edge_index[0]].radius != my_info[edge_index[1]].radius)
  {
   *EMmsg = EMS_E_RndGrExit;
   return(stat_OM);
  }

 BSEXTRACTPAR (&msg, BSTOLLENVEC, bas_tol);
 BSEXTRACTPAR (&msg, BSTOLCHRDHT, cht_tol);
 BSEXTRACTPAR (&msg, BSTOLKNOT, knot_tol);

 for (i=0; i<num_vtx_edges; i++)
  {
   if (IF_EQ_OBJID (edge_ids[i], my_info[edge_index[0]].edge_id))
    {
     stat_OM = om$send(msg = message EMSedge.EMendpts(&msg,
                             (right_vtx[i]) ? NULL : edge_uv_end,
                             (right_vtx[i]) ? edge_uv_end : NULL,
                             NULL, NULL, NULL),
                       senderid = NULL_OBJID,
                       targetid = edge_ids[i]);
     EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

     BSsfeval (my_info[edge_index[0]].surface, edge_uv_end[0],
               edge_uv_end[1], 0, (IGRpoint *)vtx_point, &msg);
     EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     break;
    }
  }

 status = BSmdistptsf (&msg, 
                       my_info[edge_index[0]].fillet_surface,
                       vtx_point,
                       &u_par,
                       &v_par,
                       pla_points[0],
                       &dist);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg,EMS_E_BSerror, wrapup);

 if (dist <= 2 * cht_tol)     /* possible chamfer */
  {
   for (i=0; i<3; i++)
     pla_points[0][i] = vtx_point[i];
  }

 BSalloccv (my_info[edge_index[0]].fillet_surface->u_order,
            my_info[edge_index[0]].fillet_surface->u_num_poles,
            my_info[edge_index[0]].fillet_surface->rational,
            NULL, &iso_curve, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 BSconstprcv (&msg, my_info[edge_index[0]].fillet_surface, &option,
              &v_par, &tst_planar, iso_curve);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (iso_curve->rational)
  {
   for (i=0; i<3; i++)
    {
     pla_points[1][i] = iso_curve->poles[i] / iso_curve->weights[0];
     pla_points[2][i] = iso_curve->poles[3 * (iso_curve->num_poles-1) + i]
                        / iso_curve->weights[iso_curve->num_poles - 1];  
    }
  }
 else
  {
   for (i=0; i<3; i++)
    {
     pla_points[1][i] = iso_curve->poles[i];
     pla_points[2][i] = iso_curve->poles[3 *(iso_curve->num_poles-1) + i];
    }
  }

 if ((v_par >= knot_tol) && (v_par <= 1 - knot_tol))
  {
   stat_OM = om$send(msg = message EMSsubbs.EMintersect_plane_fillet(&msg,
                           my_env,
                           TRUE,
                           iso_curve,
                           &v_par,
                           &my_info[edge_index[0]],
                           FALSE,
                           vtx_point,
                           num_pair_info,
                           pair_info,
                           NULL,
                           &int_curve0,
                           NULL,
                           &pair_info[*num_pair_info].edge,
                           round_id),
                     senderid = NULL_OBJID,
                     targetid = my_info[edge_index[0]].fillet_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);
  }
 else
  {
   stat_OM = EMget_vedge_id (&msg, my_env, v_par, knot_tol,
                             my_info[edge_index[0]].fillet_id,
                             &pair_info[*num_pair_info].edge);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);
  }

 pair_info[*num_pair_info].edge_surf = my_info[edge_index[0]].fillet_id;

 status = BSmdistptsf (&msg, 
                       my_info[edge_index[1]].fillet_surface,
                       vtx_point,
                       &u_par,
                       &v_par,
                       base_point,
                       &dist);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg,EMS_E_BSerror, wrapup);

 if ((v_par >= knot_tol) && (v_par <= 1 - knot_tol))
  {
   plane.point = &pl_point[0];
   plane.normal = &pl_normal[0];

   status = MAdetplane(&msg, (IGRdouble *)pla_points, &num_pla_pnt, &bas_tol, &plane);
   EMerr_hndlr(! status || !(1&msg), *EMmsg, EMS_E_MAerror, wrapup);

   stat_OM = om$send(msg = message EMSsubbs.EMintersect_plane_fillet(&msg,
                           my_env,
                           FALSE,
                           NULL,
                           &v_par,
                           &my_info[edge_index[1]],
                           FALSE,
                           vtx_point,
                           num_pair_info,
                           pair_info,
                           &plane,
                           &int_curve1,
                           NULL,
                           &pair_info[*num_pair_info].comm_edge,
                           round_id),
                     senderid = NULL_OBJID,
                     targetid = my_info[edge_index[1]].fillet_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);
  }
 else
  {
   stat_OM = EMget_vedge_id (&msg, my_env, v_par, knot_tol,
                             my_info[edge_index[1]].fillet_id,
                             &pair_info[*num_pair_info].comm_edge);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);
  }
 pair_info[*num_pair_info].comm_edge_surf =
                                       my_info[edge_index[1]].fillet_id;

 pair_info[*num_pair_info].align_normal = FALSE;
 (*num_pair_info)++;

 for (i=1; i<3; i++)
  {
   surface = NULL;

   status = BSprptonsf (&msg, my_info[edge_index[0]].surface,
                        pla_points[i], &point_on_surf[0],
                        &point_on_surf[1], &onSurf);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   if (! onSurf)
    {
     status = BSmdistptsf (&msg, 
                           my_info[edge_index[0]].surface,
                           pla_points[i],
                           &point_on_surf[0],
                           &point_on_surf[1],
                           base_point,
                           &dist);
     EMerr_hndlr(! status || msg != BSSUCC, *EMmsg,EMS_E_BSerror, wrapup);

     if (dist <= cht_tol) onSurf = TRUE;
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
             
     surface=(struct IGRbsp_surface *) om$malloc(size =(OMuint) srf_size);
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

   status = BSprptonsf (&msg, my_info[edge_index[0]].fillet_surface,
                        pla_points[i], &end_param[0], &end_param[1],
                        &ON_Surf);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   if (int_curve1->rational)
    {
     for (j=0; j<3; j++)
      {
        pointa[j] = int_curve1->poles[j] / int_curve1->weights[0];
        pointb[j] = (int_curve1->poles[3*(int_curve1->num_poles - 1)+j]) /
                    (int_curve1->weights[int_curve1->num_poles - 1]);
      }
    }
   else
    {
     for (j=0; j<3; j++)
      {
       pointa[j] = int_curve1->poles[j];
       pointb[j] = int_curve1->poles[3 * (int_curve1->num_poles - 1)+j];
      }
    }

   if (BSdistptpts(&msg, pla_points[i], pointa) <
       BSdistptpts(&msg, pla_points[i], pointb))
    {
     OM_BLOCK_MOVE(pointa, vtx_point, sizeof (IGRpoint));
    }
   else
    {
     OM_BLOCK_MOVE(pointb, vtx_point, sizeof (IGRpoint));
    }

   status = BSprptonsf (&msg, my_info[edge_index[1]].fillet_surface,
                        vtx_point, &end_param[2], &end_param[3],
                        &ON_Surf);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   stat_OM = EMget_uedge_id (&msg, my_env, end_param[0], knot_tol,
                             my_info[edge_index[0]].fillet_id,
                             &to_extend_edge1);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);

   if (! my_info[edge_index[0]].fillet_modified)
    {
     stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                             EMED_END_ROUNDED,
                             EMS_O_ON),
                       senderid = NULL_OBJID,
                       targetid = to_extend_edge1);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
    }

   stat_OM = EMget_uedge_id (&msg, my_env, end_param[2], knot_tol,
                             my_info[edge_index[1]].fillet_id,
                             &to_extend_edge2);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);

   if (! my_info[edge_index[1]].fillet_modified)
    {
     stat_OM = om$send(msg = message EMSedge.EMset_props(&msg,
                             EMED_END_ROUNDED,
                             EMS_O_ON),
                       senderid = NULL_OBJID,
                       targetid = to_extend_edge2);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
    }

   stat_OM = EMfix_two_edges (&msg,
                              my_env,
                              my_info,
                              edge_index,
                              good_id,
                              (onSurf) ? my_info[edge_index[0]].surface :
                                         surface,
                              pla_points[i],
                              to_extend_edge1,
                              to_extend_edge2,
                              &surf_partol);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);

   if (surface) om$dealloc (ptr = surface);
  }

 wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "GRvg.EMtrim_vertex_with_only_two_edges");

 if (iso_curve) om$dealloc (ptr = iso_curve);
 if (int_curve1) om$dealloc (ptr = int_curve1);

 return (stat_OM);
}

end implementation GRvg;
