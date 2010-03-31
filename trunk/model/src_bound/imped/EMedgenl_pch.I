/* ###################   APOGEE COMPILED   ################## */

/*
   History

	Sudha	06/04/93	modified to include BSprototype header files
*/

class implementation EMSedge;

#include "EMS.h"
#include "EMSlm.h"
#include "EMSlmdef.h" 
#include "bserr.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "OMmacros.h"
#include "madetplan.h"
#include "bssfeval.h"
#include "bssf3o4cvs.h"
#include "bsprptonsf.h"
#include "bsprptoncv.h"
#include "bspartofcv.h"
#include "bsmdistcvcv.h"
#include "bsdistptpts.h"
#include "bsdistptpt.h"
#include "bsconstprcv.h"
#include "bsalloccv.h"

extern OMuword OPP_EMSgenbs_class_id;

from EMSsurface import EMmk_nat_bdry;
from EMSsubbs import EMintersect_plane_fillet;

method EMgeneral_patch (IGRlong                  *EMmsg;
                        struct GRmd_env          *my_env;
                        struct IGRbsp_curve      *my_geom,
                                                 *other_geom;
                        GRobjid                  *f_edges;
                        IGRboolean               end_condition;
                        struct EMedge_round_info *my_info;
                        IGRint                   *num_pair_info;
                        struct EMedge_con_info   *pair_info;
                        IGRpoint                 *points;
                        IGRpoint                 *pla_points;
                        struct GRvg_construct    *construct_list;
                        GRobjid                  *plane_id;
                        struct GRid              *edge_id;
                        GRobjid                  *round_id)
{
  IGRlong                 stat_OM, msg;
  IGRint                  num_int, inx0, inx1;
  IGRlong                 num_pla_pnt = 3;
  IGRshort                option;
  extern IGRdouble        fabs();
  IGRboolean              status, onCurve, tst_planar = TRUE;
  IGRboolean              onSurf;
  GRobjid                 srf_edges[4];
  IGRdouble               toler, v0_or_v1, mid_param;
  IGRdouble               *par1, *par2, *par3, *par4;
  IGRdouble               point_on_surf[2];
  IGRdouble               begin_param, end0_param, end1_param;
  IGRdouble               dist1, dist2;
  IGRpoint                *cv1_points, *cv2_points,
                          *cv3_points, *cv4_points;
  IGRpoint                pl_point, pl_normal;
  struct IGRbsp_curve     *loc_curve0, *loc_curve1,
                          *int_curve;
  struct IGRbsp_curve     *curve0, *curve1;
  struct IGRbsp_surface   *plane_geom;
  struct IGRplane         plane;

/*---------------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  
  loc_curve0 = NULL;
  loc_curve1 = NULL;
  int_curve = NULL;
  curve0 = NULL;
  curve1 = NULL;

  option = 1;

  par1 = par2 = NULL;
  par3 = par4 = NULL;
  cv1_points = cv2_points = NULL;
  cv3_points = cv4_points = NULL;

  BSEXTRACTPAR(&msg, BSTOLLENVEC, toler);

  BSalloccv (my_info->fillet_surface->v_order,
             my_info->fillet_surface->v_num_poles,
             my_info->fillet_surface->rational, NULL, &loc_curve0, &msg);
  EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

  v0_or_v1 = 0;
  BSconstprcv (&msg, my_info->fillet_surface, &option, &v0_or_v1,
               &tst_planar, loc_curve0);
  EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  BSalloccv (my_info->fillet_surface->v_order,
            my_info->fillet_surface->v_num_poles,
            my_info->fillet_surface->rational, NULL, &loc_curve1, &msg);
  EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

  v0_or_v1 = 1.0;
  BSconstprcv (&msg, my_info->fillet_surface, &option, &v0_or_v1,
               &tst_planar, loc_curve1);
  EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  inx0 = inx1 = 0;

  BSmdistcvcv(loc_curve0, my_geom, &num_int, &par1, &par2, &cv1_points,
              &cv2_points, &dist1, &msg);
  EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  if ((num_int > 1) && (loc_curve0->phy_closed))
   {
    if (BSdistptpts(&msg, points[2], cv1_points[1]) <
        BSdistptpts(&msg, points[2], cv1_points[0]))
        inx0 = 1;
   }

  BSmdistcvcv(loc_curve1, my_geom, &num_int, &par3, &par4, &cv3_points,
              &cv4_points, &dist2, &msg);
  EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  if ((num_int > 1) && (loc_curve1->phy_closed))
   {
    if (BSdistptpts(&msg, points[2], cv3_points[1]) <
        BSdistptpts(&msg, points[2], cv3_points[0]))
        inx1 = 1;
   }

  if (fabs(dist1) < fabs(dist2))
   {
    OM_BLOCK_MOVE(&cv1_points[inx0][0], pla_points[0], sizeof (IGRpoint));
    end0_param = par2[inx0];
   }
  else
   {
    OM_BLOCK_MOVE(&cv3_points[inx1][0], pla_points[0], sizeof (IGRpoint));
    end0_param = par4[inx1];
   }

  if (par1) om$dealloc(ptr = par1); par1 = NULL;
  if (par2) om$dealloc(ptr = par2); par2 = NULL;
  if (par3) om$dealloc(ptr = par3); par3 = NULL;
  if (par4) om$dealloc(ptr = par4); par4 = NULL;
  if (cv1_points) om$dealloc (ptr = cv1_points); cv1_points = NULL;
  if (cv2_points) om$dealloc (ptr = cv2_points); cv2_points = NULL;
  if (cv3_points) om$dealloc (ptr = cv3_points); cv3_points = NULL;
  if (cv4_points) om$dealloc (ptr = cv4_points); cv4_points = NULL;

  inx0 = inx1 = 0;

  BSmdistcvcv(loc_curve0, other_geom, &num_int, &par1, &par2,
              &cv1_points, &cv2_points, &dist1, &msg);
  EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  if ((num_int > 1) && (loc_curve0->phy_closed))
   {
    if (BSdistptpts(&msg, points[2], cv1_points[1]) <
        BSdistptpts(&msg, points[2], cv1_points[0]))
        inx0 = 1;
   }

  BSmdistcvcv(loc_curve1, other_geom, &num_int, &par3, &par4,
              &cv3_points, &cv4_points, &dist2, &msg);
  EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  if ((num_int > 1) && (loc_curve1->phy_closed))
   {
    if (BSdistptpts(&msg, points[2], cv3_points[1]) <
        BSdistptpts(&msg, points[2], cv3_points[0]))
        inx1 = 1;
   }

  if (fabs(dist1) < fabs(dist2))
   {
    OM_BLOCK_MOVE(&cv1_points[inx0][0], pla_points[1], sizeof (IGRpoint));
    end1_param = par2[inx0];
   }
  else
   {
    OM_BLOCK_MOVE(&cv3_points[inx1][0], pla_points[1], sizeof (IGRpoint));
    end1_param = par4[inx1];
   }

  OM_BLOCK_MOVE (points[2], pla_points[2], sizeof (IGRpoint));

  BSalloccv (my_geom->order,
             my_geom->num_poles + 2 * my_geom->order - 1 ,
             my_geom->rational, NULL, &curve0, &msg);
  EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

  status = BSprptoncv(&msg, my_geom, points[2], &begin_param, &onCurve);
  EMerr_hndlr (! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  mid_param = (begin_param + end0_param)/2.0;

  status = BSpartofcv(&msg, my_geom, begin_param, mid_param, end0_param,
                      curve0);
  EMerr_hndlr (! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror,wrapup);

  BSalloccv (other_geom->order,
             other_geom->num_poles + 2 * other_geom->order - 1 ,
             other_geom->rational, NULL, &curve1, &msg);
  EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

  status = BSprptoncv(&msg, other_geom,points[2], &begin_param, &onCurve);
  EMerr_hndlr (! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  mid_param = (begin_param + end1_param)/2.0;

  status = BSpartofcv(&msg, other_geom, begin_param, mid_param,end1_param,
                      curve1);
  EMerr_hndlr (! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror,wrapup);

  if (end_condition == EMS_PATCH_VERTEX)
   {
    status = BSprptonsf (&msg, my_info->fillet_surface, points[0],
                       &point_on_surf[0], &point_on_surf[1], &onSurf);
    EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    BSalloccv (my_info->fillet_surface->u_order,
               my_info->fillet_surface->u_num_poles,
               my_info->fillet_surface->rational, NULL, &int_curve, &msg);
    EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
    
    option = 0;

    BSconstprcv(&msg, my_info->fillet_surface, &option, &point_on_surf[1],
                &tst_planar, int_curve);
    EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    EMget_twin_edge(&msg, my_info->fillet_surface, points[0], f_edges[1],
                    f_edges[3], FALSE, &pair_info[*num_pair_info].edge);
    EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);
   }
  else
   {
    plane.point = &pl_point[0];
    plane.normal = &pl_normal[0];

    status = MAdetplane(&msg, (IGRdouble *)pla_points, &num_pla_pnt, &toler, &plane);
    EMerr_hndlr(! status || !(1&msg), *EMmsg, EMS_E_MAerror, wrapup);

    stat_OM = om$send(msg = message EMSsubbs.EMintersect_plane_fillet (
                            &msg, my_env, FALSE, NULL, &v0_or_v1, my_info,
                            FALSE, pla_points[2], num_pair_info,
                            pair_info, &plane, &int_curve, NULL,
                            &pair_info[*num_pair_info].edge, round_id),
                      targetid = my_info->fillet_id);
    EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);
   }
 
  BSsf3o4cvs (int_curve, curve0, curve1, NULL, &plane_geom, &msg);
  EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  construct_list->geometry = (IGRchar *) plane_geom;

  stat_OM = om$construct(classid = OPP_EMSgenbs_class_id,
                         p_objid = plane_id,
                         msg = message GRgraphics.GRconstruct(
                         construct_list));
  EMerr_hndlr(! (1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

  /* construct the natural boundary for the general patch */

  stat_OM = om$send (msg = message EMSsurface.EMmk_nat_bdry(&msg,
                           &my_env->md_env, srf_edges),
                     targetid = *plane_id);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

  {
    IGRlong EMget_other_edge();

    EMget_other_edge (&msg, plane_geom, pla_points, srf_edges,
                      &edge_id->objid);
    EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
  }

  edge_id->osnum = OM_Gw_current_OS;

  pair_info[*num_pair_info].comm_edge = edge_id->objid;
  pair_info[*num_pair_info].edge_surf = my_info->fillet_id;
  pair_info[*num_pair_info].comm_edge_surf = *plane_id;
  pair_info[*num_pair_info].align_normal = TRUE;
  pair_info[*num_pair_info].surf_geom = my_info->fillet_surface;
  pair_info[*num_pair_info].comm_surf_geom = plane_geom;
  (*num_pair_info)++;

wrapup:

  if (int_curve) om$dealloc (ptr = int_curve);
  if (curve0) om$dealloc (ptr = curve0);
  if (curve1) om$dealloc (ptr = curve1);
  if (loc_curve0) om$dealloc (ptr = loc_curve0);
  if (loc_curve1) om$dealloc (ptr = loc_curve1);

  if (par1) om$dealloc(ptr = par1); par1 = NULL;
  if (par2) om$dealloc(ptr = par2); par2 = NULL;
  if (par3) om$dealloc(ptr = par3); par3 = NULL;
  if (par4) om$dealloc(ptr = par4); par4 = NULL;
  if (cv1_points) om$dealloc (ptr = cv1_points); cv1_points = NULL;
  if (cv2_points) om$dealloc (ptr = cv2_points); cv2_points = NULL;
  if (cv3_points) om$dealloc (ptr = cv3_points); cv3_points = NULL;
  if (cv4_points) om$dealloc (ptr = cv4_points); cv4_points = NULL;

  EMWRAPUP (*EMmsg, stat_OM, "EMSedge.EMgeneral_patch");
  return (stat_OM);
}

IGRlong EMget_other_edge (EMmsg, surface, points, edges, 
                                 right_edge)
 
IGRlong *EMmsg;
struct IGRbsp_surface *surface;
IGRpoint *points;
GRobjid *edges;
GRobjid *right_edge;

{
 IGRlong               stat_OM, msg;
 IGRpoint              pnts[4];
 IGRdouble             bas_tol_sq;
 IGRdouble             parm0, parm1;
 GRobjid               degn_edge = NULL_OBJID;
 IGRboolean            EFtest_for_match();

/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 BSEXTRACTPAR(&msg, BSTOLSQLENVEC, bas_tol_sq);

 parm0 = 0; parm1 = 0;
 BSsfeval(surface, parm0, parm1, 0, (IGRpoint *)pnts[0], &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 parm0 = 0; parm1 = 1;
 BSsfeval(surface, parm0, parm1, 0, (IGRpoint *)pnts[1], &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (BSdistptpt(&msg, pnts[0], pnts[1]) <= bas_tol_sq)
     degn_edge = edges[0]; 
 if(EFtest_for_match(pnts[0], pnts[1], points[0], points[1]))
  {
   *right_edge = edges[0];
  }
 else
  {
   parm0 = 1; parm1 = 1;
   BSsfeval(surface, parm0, parm1, 0, (IGRpoint *)pnts[2], &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   if (BSdistptpt(&msg, pnts[1], pnts[2]) <= bas_tol_sq)
      degn_edge = edges[1]; 
   if(EFtest_for_match(pnts[1], pnts[2], points[0], points[1]))
    {
     *right_edge = edges[1];
    }
   else
    {
     parm0 = 1; parm1 = 0;
     BSsfeval(surface, parm0, parm1, 0, (IGRpoint *)pnts[3], &msg);
     EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     if (BSdistptpt(&msg, pnts[2], pnts[3]) <= bas_tol_sq)
         degn_edge = edges[2]; 

     if(EFtest_for_match(pnts[2], pnts[3], points[0], points[1]))
      {
       *right_edge = edges[2];
      }
     else
      {
       if (BSdistptpt(&msg, pnts[3], pnts[0]) <= bas_tol_sq)
           degn_edge = edges[3]; 
       *right_edge = edges[3];
      }
    }
  }

 if (degn_edge != NULL_OBJID)
  {
   stat_OM = om$send(msg = message EMSedge.EMset_props (&msg,
                           EMED_DEGENERATE, EMS_O_ON),
                     senderid = NULL_OBJID,
                     targetid = degn_edge);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
  }

 wrapup:

  EMWRAPUP (*EMmsg, stat_OM, "EMget_other_edge"); 
  return(stat_OM);
 
} 

end implementation EMSedge;
