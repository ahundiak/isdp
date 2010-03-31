/* ###################   APOGEE COMPILED   ################## */
/*
   History: 1987:Creation ; gupta

   This message, if required, intersects self (fillet) with the incoming
   definition of a plane. If iso_edge is TRUE, merely store an iso edge
   for the fillet at the given parameter. If intersection is needed, a
   conic is derived from five equally spaced points from the intersection
   data. Also, on request, the intersection data is used to trim the
   plane.

   SM	07-Mar-92	Error out if no intersection found by BSsf_pl_int
			to prevent accessing NULL pointers.
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
#include "emsedgedef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSlm.h"
#include "EMSlmdef.h"
#include "OMmacros.h"

from EMSedge import EMset_type;

method EMintersect_plane_fillet (IGRlong                   *EMmsg;
                                 struct GRmd_env           *my_env;
                                 IGRboolean                iso_edge;
                                 struct IGRbsp_curve       *iso_geom;
                                 IGRdouble                 *param;
                                 struct EMedge_round_info  *my_info;
                                 IGRboolean                imp_on_plane;
                                 IGRpoint                  vtx_point;
                                 IGRint                    *num_pair_info;
                                 struct EMedge_con_info    *pair_info;
                                 struct IGRplane           *plane;
                                 struct IGRbsp_curve       **lin_curve;
                                 GRobjid                   plane_id;
                                 GRobjid                   *edges;
                                 GRobjid                   *round_id)

{
 IGRlong                 stat_OM, msg;
 IGRint                  type;
 IGRint                  num_groups, *num_points_in_group;
 IGRint                  i, grp_inx;
 IGRboolean              world;
 IGRboolean              status;
 extern  IGRboolean      BSconic50();
 IGRdouble               **xyz_pts,
                         **uv_pts,
                         **dummy;
 IGRdouble               point_in_area[2], ed_points[4];
 IGRdouble               check_dist, dist;
 extern IGRdouble        BSdistptpt();
 IGRpoint                conic_pnts[5];
 IGRvector               unit_plane_normal;
 struct GRid             plane_edge;
 struct IGRpolyline      poly; 
 struct EMSpartolbasis   partol;
 IGRdouble top, bot;
 extern  void            BSsf_pl_int();
 extern  void            BSalloccv();

/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 num_groups = 0;
 num_points_in_group = NULL;
 xyz_pts = NULL;
 uv_pts = NULL;
 poly.num_points = NULL;
 poly.points = NULL;
 world = TRUE;
 grp_inx = 0;

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

 if (! iso_edge)
  {
   /* intersect fillet with the plane */

   BSsf_pl_int (plane->point,
                plane->normal,
                my_info->fillet_surface,
                FALSE,
                &num_groups,
                &num_points_in_group,
                &xyz_pts,
                &dummy,
                &uv_pts,
                &msg);
   EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
   EMerr_hndlr(!num_groups || !num_points_in_group, *EMmsg, EMS_E_Fail,wrapup);

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
 
   /* get a 5-pt-conic only if we have atleast 5 intersection points */
 
   if (num_points_in_group[grp_inx] >= 5)
    {
     BSalloccv(BSORDERCONICGEN, BSPOLESMXCONICGEN,TRUE,0, lin_curve,&msg);
     EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
 
     OM_BLOCK_MOVE (&xyz_pts[grp_inx][0],conic_pnts[0],sizeof (IGRpoint));
     for (i=1; i<4; i++)
      {
       OM_BLOCK_MOVE(
       &xyz_pts[grp_inx][((IGRint)(num_points_in_group[grp_inx]/4*i)) *3],
       conic_pnts[i], sizeof (IGRpoint));
      }
     OM_BLOCK_MOVE(&xyz_pts[grp_inx][(num_points_in_group[grp_inx]- 1)*3],
                   conic_pnts[4], sizeof (IGRpoint));

     /* fit a 5-pt-conic thru the intersection data to reduce the
        geometry of the curve and subsequently the blend surface
     */

     status = BSconic50(&msg, 
                        conic_pnts[0],
                        conic_pnts[1],
                        conic_pnts[2],
                        conic_pnts[3], 
                        conic_pnts[4], 
                        *lin_curve,
                        unit_plane_normal, 
                        &type);
     if ( !status || msg != BSSUCC)
      {
       BSfreecv(&msg, *lin_curve);
       goto another_try;     
      }
    }
   else
    {
     /*
       if a conic is not possible, make a order-2 curve thru the points
     */

     another_try:
     BSalloccv(2, num_points_in_group[grp_inx], FALSE, 0, lin_curve,&msg);
     EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

     (*lin_curve)->order          = 2;
     (*lin_curve)->periodic       = FALSE;
     (*lin_curve)->non_uniform    = FALSE;
     (*lin_curve)->num_poles      = num_points_in_group[grp_inx];
     (*lin_curve)->poles          = (IGRdouble *) xyz_pts[grp_inx];
     (*lin_curve)->num_knots      = num_points_in_group[grp_inx] + 2;
     (*lin_curve)->rational       = FALSE;
     (*lin_curve)->weights        = NULL;
     (*lin_curve)->num_boundaries = 0;
     (*lin_curve)->bdrys          = NULL;
     (*lin_curve)->phy_closed     = FALSE;
     (*lin_curve)->planar         = TRUE;

     (*lin_curve)->knots[0] = (*lin_curve)->knots[1] = 0;
     (*lin_curve)->knots[(*lin_curve)->num_poles] = 1;
     (*lin_curve)->knots[(*lin_curve)->num_poles + 1] = 1;

     for (i = 2; i < num_points_in_group[grp_inx]; i++)
      {
       /* doing this to overcome stupid compiler problem */
       top = i-1;
       bot = num_points_in_group[grp_inx] - 1;
       lin_curve[0][0].knots[i] = top / bot;
      }
    }

   poly.num_points = num_points_in_group[grp_inx];
   poly.points = uv_pts[grp_inx];
  }
 else
  {
   /* decide the geometry of iso-edge */
   *lin_curve = iso_geom;
   if (*param <= partol.tol) *param = 2 * partol.tol;
   else if (*param >= 1-partol.tol) *param = 1 - 2*partol.tol;
   ed_points[0] = 0.0; ed_points[1] = *param;
   ed_points[2] = 1.0; ed_points[3] = *param;
   poly.num_points = 2;
   poly.points = ed_points;
  }

/************************************************************************
 stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, uvbegpt, uvendpt,
                         NULL, NULL, NULL),
                   targetid = my_info->edge_id);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

 BSsfeval(my_info->surface, uvbegpt[0], uvbegpt[1], 0, xyz_beg, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 BSsfeval(my_info->surface, uvendpt[0], uvendpt[1], 0, xyz_end, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (my_info->fillet_surface->u_phy_closed ||
     my_info->fillet_surface->v_phy_closed)
  {
   for (i=0; i<3; i++)
        ext_point[i] = (xyz_beg[i] + xyz_end[i]) / 2;
  }
 else
  {
   if (BSdistptpts(&msg, xyz_beg, vtx_point) <
       BSdistptpts(&msg, xyz_end, vtx_point))
       OM_BLOCK_MOVE (xyz_end, ext_point, sizeof (IGRpoint));
   else
       OM_BLOCK_MOVE (xyz_beg, ext_point, sizeof (IGRpoint));
  }

 status = BSmdistptsf (&msg, 
                       my_info->fillet_surface,
                       ext_point,
                       &point_in_area[0],
                       &point_in_area[1],
                       base_point,
                       &dist);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
***********************************************************************/

 point_in_area[0] = 0.5;
 point_in_area[1] = (poly.points[1] < 0.5) ? 1.0 : 0.0;

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
                           edges,
                           point_in_area),
                    targetid = my_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 if (iso_edge)
  {
   stat_OM = om$send(msg =  message EMSedge.EMset_type (&msg,
                            EMcircular_arc),
                     targetid = *edges);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
  }

 /* if the plane needs to be trimmed as well */

 if (imp_on_plane)
  {
   IGRboolean          tst_planar = FALSE;
   IGRshort            option = 0;

   stat_OM = om$send (msg =  message EMSsubbs.EMpartolbasis (&msg,
                             &my_env->md_env.matrix_type,
                             my_env->md_env.matrix, &world, FALSE,
                             &partol.tol),
                      targetid = plane_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError,wrapup);

   partol.in_world = TRUE;
   partol.is_valid = TRUE;
   partol.mattyp = &my_env->md_env.matrix_type;
   partol.mat = my_env->md_env.matrix;

   stat_OM = om$send (msg =  message EMSsubbs.EMmake_bsedge_loop (
                             &msg, my_env, NULL, iso_geom,
                             &partol, 
                             NULL_OBJID,
                             EMS_PATCH_BND,
                             TRUE, 
                             vtx_point, &plane_edge, round_id),
                      targetid = plane_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError,wrapup);

   pair_info[*num_pair_info].edge = *edges;
   pair_info[*num_pair_info].comm_edge = plane_edge.objid;
   pair_info[*num_pair_info].edge_surf = my_id;
   pair_info[*num_pair_info].comm_edge_surf = plane_id;
   pair_info[*num_pair_info].align_normal = FALSE;
   (*num_pair_info)++;

   *edges = plane_edge.objid;
  }

 wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "EMSsubbs.EMintersect_plane_fillet");
 return (stat_OM);

}

end implementation EMSsubbs;
