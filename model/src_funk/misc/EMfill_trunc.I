/* ###################   APOGEE COMPILED   ################## */
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
#include "EMSlm.h"
#include "EMSlmdef.h"
#include "madetplan.h"
#include "bssfarrevn.h"
#include "bsmdistptsf.h"
#include "bsmdistcvcv.h"
#include "bsconstprcv.h"
#include "bsalloccv.h"

from EMSsubbs import EMintersect_plane_fillet;
from EMSedge import EMget_bcxyz_geom;

/**
DLB 	10/23/91    Call bsconstprcv w/ short not long - SUN problem.
Sudha   07/08/93    Modified for BSprototypes ansification
**/

IGRlong EMtruncate_fillet_surface (EMmsg,
                                   my_env,
                                   edge1_id,
                                   edge1_surf_geom,
                                   edge2_id,
                                   edge2_surf_geom,
                                   my_info,
                                   num_pair_info,
                                   pair_info,
                                   vtx_point,
                                   round_id)

IGRlong 	             *EMmsg;
struct GRmd_env          *my_env;
GRobjid                  edge1_id, edge2_id;
struct IGRbsp_surface    *edge1_surf_geom, *edge2_surf_geom;
struct EMedge_round_info *my_info;
IGRint                   *num_pair_info;
struct EMedge_con_info   *pair_info;
IGRpoint                 vtx_point;
GRobjid                  *round_id;

{
 
 IGRlong                 stat_OM, msg;
 IGRint                  i;
 IGRint                  num_int;
 IGRlong                 num_pla_pnt = 3;
 IGRshort                option;  /*Chg'd to short DLB 10/23/91*/
 IGRdouble               u_par, v_par;
 IGRdouble               v0_or_v1;
 IGRdouble               *par1, *par2, *par3, *par4;
 IGRdouble               toler, chdht_tol;
 IGRdouble               dist1, dist2;
 IGRpoint                *cv1_points, *cv2_points,
                         *cv3_points, *cv4_points;
 IGRboolean              stat,
                         tst_planar;
 IGRvector               norm_vec;
 IGRpoint                mid_point, base_point;
 IGRpoint                pl_point, pl_normal;
 IGRpoint                pla_point[3];
 GRobjid                 int_edge_id;
 struct IGRplane         plane;
 struct IGRbsp_curve     edge1_geom, edge2_geom;
 struct IGRbsp_curve     *int_curve;
 struct IGRbsp_curve     *loc_curve0, *loc_curve1;

/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 option = 1;
 tst_planar = TRUE;

 loc_curve0 = NULL;
 loc_curve1 = NULL;

 par1 = par2 = NULL;
 par3 = par4 = NULL;

 cv1_points = cv2_points = NULL;
 cv3_points = cv4_points = NULL;

 edge1_geom.weights = NULL;
 edge1_geom.poles = NULL;
 edge1_geom.knots = NULL;
 edge1_geom.bdrys = NULL;

 edge2_geom.weights = NULL;
 edge2_geom.poles = NULL;
 edge2_geom.knots = NULL;
 edge2_geom.bdrys = NULL;
 
 BSEXTRACTPAR(&msg, BSTOLLENVEC, toler);
 BSEXTRACTPAR(&msg, BSTOLCHRDHT, chdht_tol);

 BSalloccv (my_info->fillet_surface->v_order,
            my_info->fillet_surface->v_num_poles,
            my_info->fillet_surface->rational,
            NULL, &loc_curve0, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 v0_or_v1 = 0;
 BSconstprcv (&msg, my_info->fillet_surface, &option, &v0_or_v1,
              &tst_planar, loc_curve0);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 BSalloccv (my_info->fillet_surface->v_order,
            my_info->fillet_surface->v_num_poles,
            my_info->fillet_surface->rational,
            NULL, &loc_curve1, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 v0_or_v1 = 1.0;
 BSconstprcv (&msg, my_info->fillet_surface, &option, &v0_or_v1,
              &tst_planar, loc_curve1);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg,
                         &my_env->md_env, NULL, edge1_surf_geom, 0,
                         OM_K_MAXINT, FALSE, NULL, &edge1_geom),
                   senderid = NULL_OBJID,
                   targetid = edge1_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg,
                         &my_env->md_env, NULL, edge2_surf_geom, 0,
                         OM_K_MAXINT, FALSE, NULL, &edge2_geom),
                   senderid = NULL_OBJID,
                   targetid = edge2_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 BSmdistcvcv(loc_curve0, &edge1_geom, &num_int, &par1, &par2, &cv1_points,
             &cv2_points, &dist1, &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 BSmdistcvcv(loc_curve0, &edge2_geom, &num_int, &par3, &par4, &cv3_points,
             &cv4_points, &dist2, &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (dist1 < dist2)
     OM_BLOCK_MOVE (&cv1_points[0][0], pla_point[0], sizeof (IGRpoint));
 else
     OM_BLOCK_MOVE (&cv3_points[0][0], pla_point[0], sizeof (IGRpoint));

 if (par1) om$dealloc(ptr = par1); par1 = NULL;
 if (par2) om$dealloc(ptr = par2); par2 = NULL;
 if (par3) om$dealloc(ptr = par3); par3 = NULL;
 if (par4) om$dealloc(ptr = par4); par4 = NULL;
 if (cv1_points) om$dealloc (ptr = cv1_points); cv1_points = NULL;
 if (cv2_points) om$dealloc (ptr = cv2_points); cv2_points = NULL;
 if (cv3_points) om$dealloc (ptr = cv3_points); cv3_points = NULL;
 if (cv4_points) om$dealloc (ptr = cv4_points); cv4_points = NULL;

 BSmdistcvcv(loc_curve1, &edge1_geom, &num_int, &par1, &par2, &cv1_points,
             &cv2_points, &dist1, &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 BSmdistcvcv(loc_curve1, &edge2_geom, &num_int, &par3, &par4, &cv3_points,
             &cv4_points, &dist2, &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (dist1 < dist2)
     OM_BLOCK_MOVE (&cv1_points[0][0], pla_point[1], sizeof (IGRpoint));
 else
     OM_BLOCK_MOVE (&cv3_points[0][0], pla_point[1], sizeof (IGRpoint));

 for (i=0; i<3; i++)
   mid_point[i] = (pla_point[0][i] + pla_point[1][i]) / 2;

 stat = BSmdistptsf (&msg, 
                     my_info->fillet_surface,
                     mid_point,
                     &u_par,
                     &v_par,
                     pla_point[2],
                     &dist1);
 EMerr_hndlr(! stat || msg != BSSUCC, *EMmsg,EMS_E_BSerror, wrapup);

 if (dist1 <= 2 * chdht_tol)
  {
   BSsfarrevn (&msg, my_info->fillet_surface, 1, &u_par, 1, &v_par,
               base_point, norm_vec);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   for (i=0; i<3; i++)
        pla_point[2][i] = norm_vec[i] + base_point[i];         
  }

 plane.point = &pl_point[0];
 plane.normal = &pl_normal[0];

 stat = MAdetplane(&msg, (IGRdouble *)pla_point, &num_pla_pnt, &toler, &plane);
 EMerr_hndlr(! stat || !(1&msg), *EMmsg, EMS_E_MAerror, wrapup);

 stat_OM = om$send(msg = message EMSsubbs.EMintersect_plane_fillet(&msg,
                         my_env,
                         FALSE,
                         NULL,
                         &v_par,
                         my_info,
                         FALSE,
                         vtx_point,
                         num_pair_info,
                         pair_info,
                         &plane,
                         &int_curve,
                         NULL,
                         &int_edge_id,
                         round_id),
                   senderid = NULL_OBJID,
                   targetid = my_info->fillet_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "GRvg.EMtruncate_fillet_surface");

 if (int_curve) om$dealloc (ptr = int_curve);
 if (loc_curve0) om$dealloc (ptr = loc_curve0);
 if (loc_curve1) om$dealloc (ptr = loc_curve1);
 if (par1) om$dealloc(ptr = par1);
 if (par2) om$dealloc(ptr = par2);
 if (par3) om$dealloc(ptr = par3);
 if (par4) om$dealloc(ptr = par4);

 if (cv1_points) om$dealloc (ptr = cv1_points);
 if (cv2_points) om$dealloc (ptr = cv2_points);
 if (cv3_points) om$dealloc (ptr = cv3_points);
 if (cv4_points) om$dealloc (ptr = cv4_points);

 if (edge1_geom.weights) om$dealloc (ptr = edge1_geom.weights);
 if (edge1_geom.poles) om$dealloc (ptr = edge1_geom.poles);
 if (edge1_geom.knots) om$dealloc (ptr = edge1_geom.knots);
 if (edge1_geom.bdrys) om$dealloc (ptr = edge1_geom.bdrys);

 if (edge2_geom.weights) om$dealloc (ptr = edge2_geom.weights);
 if (edge2_geom.poles) om$dealloc (ptr = edge2_geom.poles);
 if (edge2_geom.knots) om$dealloc (ptr = edge2_geom.knots);
 if (edge2_geom.bdrys) om$dealloc (ptr = edge2_geom.bdrys);

 return (stat_OM);
}

end implementation GRvg;
