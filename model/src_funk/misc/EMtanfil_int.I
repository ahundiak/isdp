/* ###################   APOGEE COMPILED   ################## */
/*           History : gupta : 1988           

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
#include "EMSlm.h"
#include "EMSlmdef.h"
#include "madetplan.h"
#include "bssfarrevn.h"
#include "bsprptonsf.h"
#include "bsmdistptsf.h"
#include "bsmdistcvcv.h"
#include "bsdistptpts.h"
#include "bsdistptpt.h"
#include "bsconstprcv.h"
#include "bsalloccv.h"

from EMSsubbs import EMintersect_plane_fillet;
from EMSedge import EMget_bcxyz_geom,
                    EMxyz_endpt;

IGRlong EMtangential_fillet_intersection (EMmsg,
                                          my_env,
                                          vtx_point,
                                          num_pair_info,
                                          pair_info,
                                          edge_geom,
                                          eval_pt,
                                          v_param,
                                          fill0_ext,
                                          fill1_ext,
                                          my_info,
                                          edge_index,
                                          parting_point,
                                          round_id)

IGRlong 	             *EMmsg;
struct GRmd_env          *my_env;
IGRpoint                 vtx_point;
IGRint                   *num_pair_info;
struct EMedge_con_info   *pair_info;
struct IGRbsp_curve      *edge_geom;
IGRpoint                 eval_pt;
IGRdouble                *v_param;
IGRboolean               fill0_ext, fill1_ext;
struct EMedge_round_info *my_info;
IGRint                   *edge_index;
IGRpoint                 parting_point;
GRobjid                  *round_id;

{
 
 IGRlong                 stat_OM, msg;
 IGRint                  i;
 IGRint                  num_int, count;
 IGRlong                 num_pla_pnt = 3;
 IGRshort                option;  /*DLB 10/23/91 - changed to short - SUN*/
 IGRint                  inx[2];
 IGRdouble               u_par, v_par0, v_par1, v_par2;
 IGRdouble               v0_or_v1, param[2];
 IGRdouble               *par1, *par2, *par3, *par4;
 IGRdouble               knot_tol, bas_tol, cht_tol;
 IGRdouble               dist1, dist2;
 extern IGRdouble        fabs();
 IGRpoint                *cv1_points, *cv2_points,
                         *cv3_points, *cv4_points;
 IGRboolean              status, onSurf, iso_edge,
                         trim_fill0, trim_fill1,
                         tst_planar, small_edge;
 IGRvector               norm_vec;
 IGRpoint                base_point;
 IGRpoint                pl_point, pl_normal;
 IGRpoint                pla_points[3];
 IGRpoint                end_points[2];
 IGRpoint                xyzbeg, xyzend;
 struct IGRplane         plane;
 struct IGRbsp_curve     *int_curve0, *int_curve1;
 struct IGRbsp_curve     *loc_curve0, *loc_curve1;
 struct IGRbsp_curve     *iso_curve;
 OM_S_CHANSELECT         to_common_edge;

/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 option = 1;
 tst_planar = TRUE;

 loc_curve0 = NULL;
 loc_curve1 = NULL;
 int_curve0 = NULL;
 int_curve1 = NULL;
 iso_curve = NULL;

 par1 = par2 = NULL;
 par3 = par4 = NULL;

 cv1_points = cv2_points = NULL;
 cv3_points = cv4_points = NULL;

 trim_fill0 = TRUE; trim_fill1 = TRUE;

 BSEXTRACTPAR(&msg, BSTOLLENVEC, bas_tol);
 BSEXTRACTPAR(&msg, BSTOLCHRDHT, cht_tol);
 BSEXTRACTPAR(&msg, BSTOLKNOT, knot_tol);

 inx[0] = edge_index[0];
 inx[1] = edge_index[1];

 stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
 if (! (1 & stat_OM)) goto wrapup;

 stat_OM = om$send(msg = message EMSedge.EMxyz_endpt(&msg, NULL,
                         &my_env->md_env, NULL, NULL, xyzbeg, xyzend,
                         &my_info[edge_index[1]].surface),
                   senderid = NULL_OBJID,
                   targetid = my_info[edge_index[1]].edge_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 /* for very small edges, it is necessary to take the iso curves on the
    same fillet if both the ends of the edge are tangential, else there
    is a possibility of the two iso curves crossing each other and
    making a mess of the boundary */

 small_edge = FALSE;

 if (BSdistptpt(&msg, xyzbeg, xyzend) <= 2*cht_tol) 
  {
   inx[0] = edge_index[1];
   inx[1] = edge_index[0];
   small_edge = TRUE;
   v0_or_v1 = v_param[0];
   v_param[0] = v_param[1];
   v_param[1] = v0_or_v1;
   status = fill0_ext;
   fill0_ext = fill1_ext;
   fill1_ext = status;
  }

 if (fill0_ext && fill1_ext)
  {
   BSalloccv (my_info[inx[0]].fillet_surface->v_order,
              my_info[inx[0]].fillet_surface->v_num_poles,
              my_info[inx[0]].fillet_surface->rational,
              NULL, &loc_curve0, &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   v0_or_v1 = 0;
   BSconstprcv (&msg, my_info[inx[0]].fillet_surface, &option, &v0_or_v1,
                &tst_planar, loc_curve0);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   BSalloccv (my_info[inx[0]].fillet_surface->v_order,
              my_info[inx[0]].fillet_surface->v_num_poles,
              my_info[inx[0]].fillet_surface->rational,
              NULL, &loc_curve1, &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   v0_or_v1 = 1.0;
   BSconstprcv (&msg, my_info[inx[0]].fillet_surface, &option, &v0_or_v1,
                &tst_planar, loc_curve1);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   BSmdistcvcv(loc_curve0, edge_geom, &num_int, &par1, &par2, &cv1_points,
               &cv2_points, &dist1, &msg);
   EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   BSmdistcvcv(loc_curve1, edge_geom, &num_int, &par3, &par4, &cv3_points,
               &cv4_points, &dist2, &msg);
   EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   if (dist1 < dist2)
     OM_BLOCK_MOVE (&cv1_points[0][0], pla_points[0], sizeof (IGRpoint));
   else
     OM_BLOCK_MOVE (&cv3_points[0][0], pla_points[0], sizeof (IGRpoint));

   if (par1) om$dealloc(ptr = par1); par1 = NULL;
   if (par2) om$dealloc(ptr = par2); par2 = NULL;
   if (par3) om$dealloc(ptr = par3); par3 = NULL;
   if (par4) om$dealloc(ptr = par4); par4 = NULL;
   if (cv1_points) om$dealloc (ptr = cv1_points); cv1_points = NULL;
   if (cv2_points) om$dealloc (ptr = cv2_points); cv2_points = NULL;
   if (cv3_points) om$dealloc (ptr = cv3_points); cv3_points = NULL;
   if (cv4_points) om$dealloc (ptr = cv4_points); cv4_points = NULL;
  }
 else
  {
   OM_BLOCK_MOVE (eval_pt, pla_points[0], sizeof (IGRpoint));
  }

 if (fill0_ext)
  { 
   status = BSprptonsf (&msg, my_info[inx[0]].fillet_surface,
                        pla_points[0], &u_par, &v_par0, &onSurf);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   if (! onSurf)
    {
     status = BSmdistptsf (&msg, 
                           my_info[inx[0]].fillet_surface,
                           pla_points[0],
                           &u_par,
                           &v_par0,
                           base_point,
                           &dist1);
     EMerr_hndlr(! status || msg != BSSUCC, *EMmsg,EMS_E_BSerror, wrapup);
    }
  }
 else
  {
   v_par0 = v_param[0];
  }

 if ((v_par0 <= knot_tol) || (v_par0 >= 1-knot_tol))
      trim_fill0 = FALSE;

 option = 0;

 BSalloccv (my_info[inx[0]].fillet_surface->u_order,
            my_info[inx[0]].fillet_surface->u_num_poles,
            my_info[inx[0]].fillet_surface->rational,
            NULL, &iso_curve, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 v0_or_v1 = v_par0;
 BSconstprcv (&msg, my_info[inx[0]].fillet_surface, &option, &v0_or_v1,
              &tst_planar, iso_curve);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (iso_curve->rational)
  {
   for (i=0; i<3; i++)
    {
     end_points[0][i] = iso_curve->poles[i] / iso_curve->weights[0];
     end_points[1][i] = iso_curve->poles[3 * (iso_curve->num_poles-1) + i]
                        / iso_curve->weights[iso_curve->num_poles - 1];  
    }
  }
 else
  {
   for (i=0; i<3; i++)
    {
     end_points[0][i] = iso_curve->poles[i];
     end_points[1][i] = iso_curve->poles[3 *(iso_curve->num_poles-1) + i];
    }
  }

 if (BSdistptpts(&msg, pla_points[0], end_points[0]) <
     BSdistptpts(&msg, pla_points[0], end_points[1]))
     OM_BLOCK_MOVE (end_points[1], pla_points[1], sizeof (IGRpoint));
 else
     OM_BLOCK_MOVE (end_points[0], pla_points[1], sizeof (IGRpoint));

 OM_BLOCK_MOVE (pla_points[1], parting_point, sizeof (IGRpoint));
 
 if (fill1_ext)
  {
   status = BSprptonsf (&msg,
                        my_info[inx[1]].fillet_surface,
                        pla_points[0], &u_par, &v_par1,
                        &onSurf);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   if (! onSurf)
    {
     status = BSmdistptsf (&msg, 
                           my_info[inx[1]].fillet_surface,
                           pla_points[0],
                           &u_par,
                           &v_par1,
                           base_point,
                           &dist1);
     EMerr_hndlr(! status || msg != BSSUCC, *EMmsg,EMS_E_BSerror, wrapup);
    }
  }
 else
  {
   v_par1 = v_param[1];
  }  

 if ((v_par1 <= knot_tol) || (v_par1 >= 1-knot_tol))
      trim_fill1 = FALSE;

 status = BSprptonsf (&msg,
                      my_info[inx[1]].fillet_surface,
                      pla_points[1], &u_par, &v_par2,
                      &onSurf);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if ((fabs (v_par1 - v_par2) <= knot_tol) && (onSurf))
  {
   iso_edge = TRUE;
  }
 else
  {
   iso_edge = FALSE;

   param[0] = 0.5; param[1] = v_par1;

   BSsfarrevn (&msg, my_info[inx[1]].fillet_surface, 1, &param[0], 1,
               &param[1], pla_points[2], norm_vec);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   if (iso_curve->order == 2)
    {
     for (i=0; i<3; i++)
          pla_points[2][i] = norm_vec[i] + pla_points[2][i];
    }

   plane.point = &pl_point[0];
   plane.normal = &pl_normal[0];

   status = MAdetplane(&msg, (IGRdouble *)pla_points, &num_pla_pnt, &bas_tol, &plane);
   EMerr_hndlr(! status || !(1&msg), *EMmsg, EMS_E_MAerror, wrapup);
  }

 if (trim_fill0)
  {
   stat_OM = om$send(msg = message EMSsubbs.EMintersect_plane_fillet(&msg,
                           my_env,
                           TRUE,
                           iso_curve,
                           &v_par0,
                           &my_info[inx[0]],
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
                     targetid = my_info[inx[0]].fillet_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);
  }
 else
  {
   stat_OM = EMget_vedge_id (&msg, my_env, v_par0, knot_tol, 
                             my_info[inx[0]].fillet_id,
                             &pair_info[*num_pair_info].edge);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

   stat_OM = om$get_channel_count (objid = pair_info[*num_pair_info].edge,
                                   p_chanselect = &to_common_edge,
                                   count = (OMuint *)&count);
   if (count)
    {
     stat_OM = om$send(msg = message Root.wild_disconnect(to_common_edge),
                       senderid = NULL_OBJID,
                       targetid = pair_info[*num_pair_info].edge);
     EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);
    }
  }

 pair_info[*num_pair_info].edge_surf = my_info[inx[0]].fillet_id;

 if (trim_fill1)
  {
   stat_OM = om$send(msg = message EMSsubbs.EMintersect_plane_fillet(&msg,
                           my_env,
                           iso_edge,
                           iso_curve,
                           &v_par1,
                           &my_info[inx[1]],
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
                     targetid = my_info[inx[1]].fillet_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);
  }
 else
  {
   stat_OM = EMget_vedge_id (&msg, my_env, v_par1, knot_tol, 
                             my_info[inx[1]].fillet_id,
                             &pair_info[*num_pair_info].comm_edge);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

   stat_OM = om$get_channel_count (
                            objid = pair_info[*num_pair_info].comm_edge,
                            p_chanselect = &to_common_edge,
                            count = (OMuint *)&count);
   if (count)
    {
     stat_OM = om$send(msg = message Root.wild_disconnect(to_common_edge),
                       senderid = NULL_OBJID,
                       targetid = pair_info[*num_pair_info].comm_edge);
     EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);
    }
  }

 pair_info[*num_pair_info].comm_edge_surf =
                                       my_info[inx[1]].fillet_id;

 pair_info[*num_pair_info].align_normal = FALSE;
 (*num_pair_info)++;

 wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "GRvg.EMtangential_fillet_intersection");

 if ((int_curve1) && (! iso_edge)) om$dealloc (ptr = int_curve1);
 if (iso_curve) om$dealloc (ptr = iso_curve);
 if (loc_curve0) om$dealloc (ptr = loc_curve0);
 if (loc_curve1) om$dealloc (ptr = loc_curve1);

 return (stat_OM);
}

end implementation GRvg;
