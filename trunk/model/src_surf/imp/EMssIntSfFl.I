/* ###################   APOGEE COMPILED   ################## */
/*
   History: 1987:Creation ; gupta

            12/06/90 : gupta : if surface (self) is a special plane
                               then make a bs-edge.

   This message, intersects a fillet with the incoming surface geometry.
   The intersection data is then used to create boundaries for both the
   surfaces, fillet and self.
*/

class implementation EMSsubbs;

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsconic.h"
#include "bsconicgenx.h"
#include "emserr.h"
#include "emsdef.h"
#include "emsmacros.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emsedgedef.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSlm.h"
#include "EMSlmdef.h"
#include "OMmacros.h"
#include "gocmacros.h" /* GRgetabsg */

from EMSedge import EMset_type;

extern OMuword OPP_EMSplane_class_id;

method EMintersect_surface_fillet(IGRlong                  *EMmsg;
                                  struct GRmd_env          *my_env;
                                  IGRpoint                 vtx_point;
                                  IGRint                   *num_pair_info;
                                  struct EMedge_con_info   *pair_info;
                                  struct EMedge_round_info *my_info;
                                  IGRboolean               pt_outside;
                                  GRobjid                  my_edge_id,
                                                           *round_id;
                                  IGRpoint                 beg_xyz,
                                                           end_xyz)
 
{
 IGRlong                 stat_OM, msg, msg1;
 IGRlong                 num_bytes;
 IGRint                  num_groups, *num_points_in_group;
 IGRint                  i, mid_index;
 IGRint                  grp_inx;
 OMuword                 surf_classid;
 IGRboolean              world, special_plane,
                         status,
                         onSurf, iso_edge;
 IGRboolean	             EMis_iso_edge(), EFextract_par();
 extern IGRboolean       BSmdistptsf();
 extern IGRboolean       BSprptonsf();
 extern IGRdouble        BSdistptpt();
 extern IGRdouble        fabs();
 IGRdouble               dist, inc_factor;
 IGRdouble               partollen, iso_buf[4];
 IGRdouble               chrdht_tol,
                         knot_tol,
                         convg_tol;
 IGRdouble               **xyz_pts,
                         **my_uv_pts,
                         **other_uv_pts;
 IGRdouble               fillet_point[2], surf_point[2];
 IGRdouble               check_dist;
 IGRpoint                mid_point, ext_point, base_point;
 struct GRid             edge_id;
 GRobjid                 edges[2];
 struct IGRpolyline      poly;
 struct EMSpartolbasis   partol;
 struct IGRbsp_surface   *my_geom=NULL;
 extern IGRboolean       BSsur_sur();
 extern  void            BSalloccv();

/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 special_plane = FALSE;
 iso_edge = FALSE;
 num_groups = 0;
 num_points_in_group = NULL;
 xyz_pts = NULL;
 my_uv_pts = NULL;
 other_uv_pts = NULL; 
 poly.num_points = NULL;
 poly.points = NULL;
 world = TRUE;
 grp_inx = 0;

 BSEXTRACTPAR (&msg, BSTOLCHRDHT, chrdht_tol);
 BSEXTRACTPAR (&msg, BSTOLQNWT, convg_tol);

 stat_OM = om$send(msg =  message EMSsubbs.GRgetsize (&msg,
                          &my_env->md_env.matrix_type,
                          my_env->md_env.matrix, &num_bytes),
                   targetid = my_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 my_geom = (struct IGRbsp_surface *) om$malloc(size = (OMuint) num_bytes);
 EMerr_hndlr(!my_geom, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

 stat_OM = om$send(msg =  message EMSsubbs.GRgetgeom (&msg,
                          &my_env->md_env.matrix_type, 
                          my_env->md_env.matrix, (IGRchar *) my_geom),
                  targetid = my_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);
 
 /* get the intersection between fillet and self */

 status = BSsur_sur (&msg,
                     my_geom,
                     my_info->fillet_surface,
                     &chrdht_tol,
                     &convg_tol,
                     &num_groups,
                     &num_points_in_group,
                     &xyz_pts,
                     &my_uv_pts,
                     &other_uv_pts);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (! num_groups)
  {
   *EMmsg = EMS_I_NoIntersection;
   return (OM_S_SUCCESS);
  }

 /*
    If more than one intersection group is found, select one which is
    closer to the vertex.
 */

 if (num_groups > 1)
  {
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
 
 for (i=0; i<3; i++)
  {
   beg_xyz[i] = xyz_pts[grp_inx][i];
   end_xyz[i] = xyz_pts[grp_inx][(num_points_in_group[grp_inx]-1)*3 + i];
  }

 poly.num_points = num_points_in_group[grp_inx];
 poly.points = my_uv_pts[grp_inx];

 stat_OM = om$send (msg =  message EMSsubbs.EMpartolbasis (&msg,
                          &my_env->md_env.matrix_type,
                          my_env->md_env.matrix, &world, FALSE,
                          &partol.tol),
                    targetid = my_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 partol.in_world = TRUE;
 partol.is_valid = TRUE;
 partol.mattyp = &my_env->md_env.matrix_type;
 partol.mat = my_env->md_env.matrix;

 /*
   get the point-in-area to correctly orient the boundary on myself.
   This is done by projecting an exterior point on a line passing thru
   the mid-point of the intersection data and the vertex point.
 */

 if (pt_outside)
  {
   status = BSprptonsf (&msg, my_geom, vtx_point, &surf_point[0],
                        &surf_point[1], &onSurf);
   EMerr_hndlr(! status || msg != BSSUCC,*EMmsg, EMS_E_BSerror, wrapup);
  }
 else
  {
   if (num_points_in_group[grp_inx] <= 2)
    {
     for (i=0; i<3; i++)
      mid_point[i] = (xyz_pts[grp_inx][i] + xyz_pts[grp_inx][3+i]) / 2;
    }
   else
    {
     mid_index = (IGRint) (num_points_in_group[grp_inx]/2);
     for (i=0; i<3; i++)
          mid_point[i] = xyz_pts[grp_inx][mid_index*3 + i];
    }

   dist = BSdistptpt (&msg, vtx_point, mid_point);
  
   inc_factor = dist;
   for (i=0; i<3; i++)
        ext_point[i] = (mid_point[i] * (inc_factor + dist) -
                        inc_factor * vtx_point[i]) / dist;

   status = BSmdistptsf (&msg, 
                         my_geom,
                         ext_point,
                         &surf_point[0],
                         &surf_point[1],
                         base_point,
                         &dist);
   EMerr_hndlr(! status || msg != BSSUCC,*EMmsg, EMS_E_BSerror, wrapup);
  }

 /* Store the boundary for int surface to be trimmed eventually. */

 stat_OM = om$get_classid(objid = my_id,
                          p_classid = &surf_classid);
 if (! (1 & stat_OM)) goto wrapup;

 if(surf_classid == OPP_EMSplane_class_id)
    special_plane = TRUE;
 else
  {
   stat_OM = om$is_ancestry_valid(subclassid = surf_classid, 
                                  superclassid = OPP_EMSplane_class_id);
	
   if(stat_OM == OM_S_SUCCESS) special_plane = TRUE;
  }

 if ((special_plane) && (poly.num_points >= 5))
  {
   extern  IGRboolean      BSconic50();
   IGRpoint                conic_pnts[5];
   IGRvector               unit_plane_normal;
   IGRint                  type;
   struct IGRbsp_curve     *bs_curve;

   bs_curve = NULL;

   BSalloccv(BSORDERCONICGEN, BSPOLESMXCONICGEN,TRUE, 0, &bs_curve, &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
 
   OM_BLOCK_MOVE (&xyz_pts[grp_inx][0], conic_pnts[0], sizeof (IGRpoint));
   for (i=1; i<4; i++)
    {
     OM_BLOCK_MOVE(
       &xyz_pts[grp_inx][((IGRint)(num_points_in_group[grp_inx]/4*i)) *3],
       conic_pnts[i], sizeof (IGRpoint));
    }
   OM_BLOCK_MOVE(&xyz_pts[grp_inx][(num_points_in_group[grp_inx]- 1)*3],
                 conic_pnts[4], sizeof (IGRpoint));

   /* Fit a 5-pt-conic thru the intersection data to reduce the
      geometry of the curve and subsequently the blend surface
   */

   status = BSconic50(&msg, 
                      conic_pnts[0],
                      conic_pnts[1],
                      conic_pnts[2],
                      conic_pnts[3], 
                      conic_pnts[4], 
                      bs_curve,
                      unit_plane_normal, 
                      &type);
   if ( !status || msg != BSSUCC)
    {
     BSfreecv(&msg, bs_curve);
     goto another_try;     
    }
   else
    {
     stat_OM = om$send(msg =  message EMSsubbs.EMmake_bsedge_loop(&msg,
                              my_env,
                              my_geom,
                              bs_curve,
                              &partol,
                              my_edge_id,
                              EMS_VERTEX_BND, FALSE,
                              vtx_point, &edge_id, round_id),
                       targetid = my_id);
     EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg, EMS_E_SurfaceError,wrapup);
     edges[0] = edge_id.objid;
    }
  }
 else
  {
   another_try:
   stat_OM = om$send (msg =  message EMSsubbs.EMmake_linedge_loop (&msg,
                             FALSE,
                             &poly,
                             round_id,
                             &partol,
                             EMS_VERTEX_BND,
                             my_edge_id,
                             &edges[0],
                             surf_point),
                      targetid = my_id);
   EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);
  }

 poly.num_points = num_points_in_group[grp_inx];
 poly.points = other_uv_pts[grp_inx];

 if (chrdht_tol < 1.0)
  {
   if (poly.points[0] <= chrdht_tol) poly.points[0] = 0;  
   if (poly.points[2 * (poly.num_points - 1)] <= chrdht_tol)
       poly.points[2 * (poly.num_points - 1)] = 0;  
   if (poly.points[0] >= 1-chrdht_tol) poly.points[0] = 1;  
   if (poly.points[2 * (poly.num_points - 1)] >= 1 - chrdht_tol)
       poly.points[2 * (poly.num_points - 1)] = 1;  
  }

 stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg,
                          &my_env->md_env.matrix_type,
                          my_env->md_env.matrix, &world, FALSE,
                          &partol.tol),
                    targetid = my_info->fillet_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

/************************************************************************
 stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, uvbegpt, uvendpt,
                         NULL, NULL, NULL),
                   targetid = my_info->edge_id);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

 BSsfeval(my_info->surface, uvbegpt[0], uvbegpt[1], 0, xyz_beg, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 BSsfeval(my_info->surface, uvendpt[0], uvendpt[1], 0, xyz_end, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (BSdistptpts(&msg, xyz_beg, vtx_point) <
     BSdistptpts(&msg, xyz_end, vtx_point))
     OM_BLOCK_MOVE (xyz_end, ext_point, sizeof (IGRpoint));
 else
     OM_BLOCK_MOVE (xyz_beg, ext_point, sizeof (IGRpoint));

 status = BSmdistptsf (&msg, 
                       my_info->fillet_surface,
                       ext_point,
                       &fillet_point[0],
                       &fillet_point[1],
                       base_point,
                       &dist);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (my_info->fillet_surface->v_phy_closed)
  {
   BSEXTRACTPAR (&msg, BSTOLKNOT, knot_tol);

   if ((fillet_point[1] <= knot_tol) || (fillet_point[1] >= 1-knot_tol))
    {
     for (i=0; i<3; i++)
       mid_point[i] = (xyz_beg[i] + xyz_end[i]) / 2;

     status = BSmdistptsf (&msg, 
                           my_info->fillet_surface,
                           mid_point,
                           &fillet_point[0],
                           &fillet_point[1],
                           base_point,
                           &dist);
     EMerr_hndlr(! status || msg != BSSUCC,*EMmsg, EMS_E_BSerror,wrapup);
    }
  }
*************************************************************************/

 fillet_point[0] = 0.5;
 fillet_point[1] = (poly.points[1] < 0.5) ? 1.0 : 0.0;

 if (special_plane)
  {
   stat_OM = EFextract_par(BSTOLLENVEC, partol.tol, &partollen, &msg);
   iso_edge = EMis_iso_edge (poly.num_points, poly.points, partollen,
                             iso_buf);
  }

 /*
   Store the boundary for fillet surface to be trimmed eventually. The
   point-in-area needed to orient this boundary is being decided
   trivially because the fillet is expected to have atleast two trimming
   boundaries. the average of the v-parameter endpoints of these 
   boundaries is taken as the point-in-area. The above code has been
   commented for this reason and if the need arises to trim the fillet
   with only one boundary, the above technique should be adopted.
 */

 stat_OM = om$send (msg =  message EMSsubbs.EMmake_linedge_loop (&msg,
                           iso_edge,
                           &poly,
                           round_id,
                           &partol,
                           EMS_DUMMY_BND,
                           NULL_OBJID,
                           &edges[1],
                           fillet_point),
                    targetid = my_info->fillet_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 if (iso_edge)
  {
   stat_OM = om$send(msg =  message EMSedge.EMset_type (&msg,
                            EMcircular_arc),
                     targetid = edges[0]);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   stat_OM = om$send(msg =  message EMSedge.EMset_type (&msg,
                            EMcircular_arc),
                     targetid = edges[1]);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
  }

 /* store the topology info */

 pair_info[*num_pair_info].edge = edges[0];
 pair_info[*num_pair_info].comm_edge = edges[1];
 pair_info[*num_pair_info].edge_surf = my_id;
 pair_info[*num_pair_info].comm_edge_surf = my_info->fillet_id;
 pair_info[*num_pair_info].align_normal = FALSE;
 (*num_pair_info)++;

 wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "EMSsubbs.EMintersect_surface_fillet");
 if(my_geom)
   {
   om$dealloc(ptr = my_geom);
   my_geom = NULL;
   }
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

end implementation EMSsubbs;
