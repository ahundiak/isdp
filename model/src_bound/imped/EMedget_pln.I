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
#include "bssf3o4cvs.h"
#include "bsprptonsf.h"
#include "bsprptoncv.h"
#include "bspartofcv.h"
#include "bsmdstptcv.h"
#include "bsmdistcvcv.h"
#include "bsfreecv.h"
#include "bsdistptpts.h"
#include "bsconstprcv.h"
#include "bschgcvewts.h"
#include "bsalloccv.h"

extern OMuword OPP_EMSgenbs_class_id;

from GRconnector import GRrigidconn;
from EMSsurface import EMrevorient;
from EMSsurface import EMmk_nat_bdry;
from EMSsubbs import EMintersect_plane_fillet;

/*
History
    DLB     08/13/91    Put patch surfaces on end of comps chan.
    SM	    03/09/92    Changed NULL to 0.0 in call to BSpartofcv
*/    

method EMget_plane (IGRlong                  *EMmsg;
                    struct GRmd_env          *my_env;
                    IGRint                   end_condition;
                    IGRshort                 other_edge_type;
                    GRobjid                  *f_edges;
                    struct EMedge_round_info *my_info;
                    IGRint                   *num_pair_info;
                    struct EMedge_con_info   *pair_info;
                    struct IGRbsp_surface    *my_surf_geom,
                                             *other_surf_geom;
                    IGRpoint                 *points;
                    IGRpoint                 *pla_points;
                    GRobjid                  other_edge,
                                             *plane_id;
                    struct GRvg_construct    *construct_list;
                    struct GRid              *edge_id;
                    IGRboolean               *is_on_boundary;
                    GRobjid                  *round_id)
{
  IGRlong                 i=OM_K_MAXINT, stat_OM, msg;
  IGRint                  j, num_int;
  IGRlong                 num_pla_pnt = 3;
  IGRshort                option;
  IGRboolean              status, onCurve, tst_planar = TRUE;
  IGRboolean              trace_back, onSurf;
  GRobjid                 srf_edges[4];
  IGRdouble               cht_tol, knot_tol;
  IGRdouble               toler, v0_or_v1;
  IGRdouble               *par1, *par2;
  IGRdouble               point_on_surf[2];
  IGRdouble               begin_param;
  IGRdouble               dist;
  IGRpoint                *cv1_points, *cv2_points;
  IGRpoint                pl_point, pl_normal;
  IGRpoint                base_point;
  struct IGRbsp_curve     *loc_curve0, *loc_curve1,
                          *int_curve, *iso_curve;
  struct IGRbsp_curve     *mod_curve;
  struct IGRbsp_surface   *plane_geom;
  struct IGRplane         plane;
  IGRpoint                beg_point, end_point;
  struct GRid             temp_id;
  struct IGRbsp_curve     my_geom, other_geom;
  struct IGRbsp_curve     *lin_curve, *part_curve;

/*---------------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  loc_curve0 = NULL;
  loc_curve1 = NULL;
  int_curve = NULL;
  lin_curve = NULL;
  iso_curve = NULL;
  part_curve = NULL;
  mod_curve = NULL;

  temp_id.objid = *round_id;
  temp_id.osnum = OM_Gw_current_OS;

  is_on_boundary[0] = TRUE; is_on_boundary[1] = TRUE;
  trace_back = FALSE;

  my_geom.weights = NULL;
  my_geom.poles = NULL;
  my_geom.knots = NULL;
  my_geom.bdrys = NULL;

  stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg,
                          &my_env->md_env, NULL, my_surf_geom, 0,
                          OM_K_MAXINT, FALSE, NULL, &my_geom),
                    targetid = my_id);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

  other_geom.weights = NULL;
  other_geom.poles = NULL;
  other_geom.knots = NULL;
  other_geom.bdrys = NULL;

  stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg,
                          &my_env->md_env, NULL, other_surf_geom, 0,
                          OM_K_MAXINT, FALSE, NULL, &other_geom),
                    targetid = other_edge);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

  if (end_condition == EMS_NTRL_PATCH_VERTEX)
   {
    BSEXTRACTPAR(&msg, BSTOLKNOT, knot_tol);
    BSEXTRACTPAR(&msg, BSTOLLENVEC, toler);
    BSEXTRACTPAR(&msg, BSTOLCHRDHT, cht_tol);

    option = 1;
 
    par1 = par2 = NULL;
    cv1_points = cv2_points = NULL;


    OM_BLOCK_MOVE (points[2], pla_points[2], sizeof (IGRpoint));

    BSalloccv(2, 2, FALSE, 0, &lin_curve, &msg);
    EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    lin_curve->order          = 2;
    lin_curve->periodic       = FALSE;
    lin_curve->non_uniform    = FALSE;
    lin_curve->num_poles      = 2;
    lin_curve->num_knots      = 4;
    lin_curve->rational       = FALSE;
    lin_curve->weights        = NULL;
    lin_curve->num_boundaries = 0;
    lin_curve->bdrys          = NULL;
    lin_curve->phy_closed     = FALSE;
    lin_curve->planar         = TRUE;

    lin_curve->knots[0] = lin_curve->knots[1] = 0;
    lin_curve->knots[lin_curve->num_poles] = 1;
    lin_curve->knots[lin_curve->num_poles + 1] = 1;

    for (j=0; j<3; j++)
         lin_curve->poles[j] = points[2][j];

    BSalloccv (my_info->fillet_surface->v_order,
               my_info->fillet_surface->v_num_poles,
               my_info->fillet_surface->rational,NULL, &loc_curve0, &msg);
    EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

    v0_or_v1 = 0;
    BSconstprcv (&msg, my_info->fillet_surface, &option, &v0_or_v1,
                 &tst_planar, loc_curve0);
    EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    wrong_guess:

    BSmdistcvcv(loc_curve0, &my_geom, &num_int, &par1, &par2, &cv1_points,
                &cv2_points, &dist, &msg);
    EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  
    if ((trace_back) && (dist > cht_tol))
     {
       *EMmsg = EMS_E_InvalidArg;
       goto wrapup;
     }

    if (((dist <= cht_tol) && (other_edge_type != EMS_NEUTRAL_EDGE)) ||
        (trace_back))
     {
      is_on_boundary[1] = FALSE;

      status = BSprptonsf (&msg, my_info->fillet_surface, cv1_points[0],
                           &point_on_surf[0], &point_on_surf[1], &onSurf);
      EMerr_hndlr(! status || msg != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

      OM_BLOCK_MOVE (&cv2_points[0][0], pla_points[0], sizeof (IGRpoint));

      BSalloccv (my_info->fillet_surface->u_order,
                 my_info->fillet_surface->u_num_poles,
                 my_info->fillet_surface->rational,NULL,&int_curve, &msg);
      EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
    
      option = 0;

      BSconstprcv(&msg,my_info->fillet_surface,&option,&point_on_surf[1],
                  &tst_planar, int_curve);
      EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

      if (int_curve->rational)
       {
        if ((int_curve->weights[0] != 1.0) ||
            (int_curve->weights[int_curve->num_poles - 1] != 1.0))
         {
          BSalloccv (int_curve->order, int_curve->num_poles,
                   int_curve->rational, NULL, &mod_curve, &msg);
          EMerr_hndlr(msg != BSSUCC,*EMmsg,EMS_E_NoDynamicMemory, wrapup);

          BSchgcvewts (int_curve, mod_curve, &msg);
          EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

          if (int_curve) BSfreecv(&msg, int_curve);
          int_curve = mod_curve;
         }
       }

      if (int_curve->rational)
       {
        for (j=0; j<3; j++)
         {
          beg_point[j] = int_curve->poles[j] / int_curve->weights[0];
          end_point[j] = int_curve->poles[3*(int_curve->num_poles-1)+j] /
                         int_curve->weights[int_curve->num_poles - 1];  
         }
       }
      else
       {
        for (j=0; j<3; j++)
         {
          beg_point[j] = int_curve->poles[j];
          end_point[j] = int_curve->poles[3*(int_curve->num_poles-1)+j];
         }
       }

      if (BSdistptpts(&msg, pla_points[0], beg_point) <
          BSdistptpts(&msg, pla_points[0], end_point))
       {
        OM_BLOCK_MOVE (end_point, pla_points[1], sizeof (IGRpoint));
        for (j=0; j<3; j++)
             int_curve->poles[j] = pla_points[0][j];;
       }
      else
       {
        OM_BLOCK_MOVE (beg_point, pla_points[1], sizeof (IGRpoint));
        for (j=0; j<3; j++)
             int_curve->poles[3*(int_curve->num_poles-1)+j] =
                                                  pla_points[0][j];;
       }

      BSalloccv (my_geom.order,
                 my_geom.num_poles + 2 * my_geom.order - 1 ,
                 my_geom.rational, NULL, &part_curve, &msg);
      EMerr_hndlr (msg != BSSUCC,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

      status = BSprptoncv(&msg, &my_geom, points[2], &begin_param,
                          &onCurve);
      EMerr_hndlr(! status || msg != BSSUCC,*EMmsg,EMS_E_BSerror, wrapup);

      if (! onCurve)
       {
        BSmdstptcv(&my_geom, points[2], &begin_param, base_point, &dist,
                   &msg);
        EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
        for (j=0; j<3; j++)
             lin_curve->poles[j] = base_point[j];
       }

      status = BSpartofcv(&msg, &my_geom, begin_param, 0.0, par2[0],
                          part_curve);
      EMerr_hndlr(! status || msg != BSSUCC,*EMmsg,EMS_E_BSerror, wrapup);

      for (j=3; j<6; j++)
           lin_curve->poles[j] = pla_points[1][j-3];
     }
    else
     {
      is_on_boundary[0] = FALSE;
      par1 = par2 = NULL;
      cv1_points = cv2_points = NULL;

      BSmdistcvcv(loc_curve0, &other_geom, &num_int, &par1, &par2,
                  &cv1_points, &cv2_points, &dist, &msg);
      EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

      if (dist > cht_tol)
       {
        par1 = par2 = NULL;
        cv1_points = cv2_points = NULL;

        BSalloccv (my_info->fillet_surface->v_order,
                   my_info->fillet_surface->v_num_poles,
                   my_info->fillet_surface->rational, NULL, &loc_curve1,
                   &msg);
        EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory,wrapup);

        v0_or_v1 = 1;
        BSconstprcv (&msg, my_info->fillet_surface, &option, &v0_or_v1,
                     &tst_planar, loc_curve1);
        EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

        BSmdistcvcv(loc_curve1, &other_geom, &num_int, &par1, &par2,
                    &cv1_points, &cv2_points, &dist, &msg);
        EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

        if (dist > cht_tol)
         {
          trace_back = TRUE;
          goto wrong_guess;
         }
       }

      status = BSprptonsf (&msg, my_info->fillet_surface, cv1_points[0],
                           &point_on_surf[0], &point_on_surf[1], &onSurf);
      EMerr_hndlr(! status || msg != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

      OM_BLOCK_MOVE (&cv2_points[0][0], pla_points[1], sizeof (IGRpoint));

      BSalloccv (my_info->fillet_surface->u_order,
                 my_info->fillet_surface->u_num_poles,
                 my_info->fillet_surface->rational,NULL,&int_curve, &msg);
      EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
    
      option = 0;

      BSconstprcv(&msg, my_info->fillet_surface,&option,&point_on_surf[1],
                  &tst_planar, int_curve);
      EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

      if (int_curve->rational)
       {
        if ((int_curve->weights[0] != 1.0) ||
            (int_curve->weights[int_curve->num_poles - 1] != 1.0))
         {
          BSalloccv (int_curve->order, int_curve->num_poles,
                     int_curve->rational, NULL, &mod_curve, &msg);
          EMerr_hndlr(msg != BSSUCC,*EMmsg,EMS_E_NoDynamicMemory, wrapup);

          BSchgcvewts (int_curve, mod_curve, &msg);
          EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

          if (int_curve) BSfreecv(&msg, int_curve);
          int_curve = mod_curve;
         }
       }

      if (int_curve->rational)
       {
        for (j=0; j<3; j++)
         {
          beg_point[j] = int_curve->poles[j] / int_curve->weights[0];
          end_point[j] = int_curve->poles[3*(int_curve->num_poles-1)+j] /
                         int_curve->weights[int_curve->num_poles - 1];  
         }
       }
      else
       {
        for (j=0; j<3; j++)
         {
          beg_point[j] = int_curve->poles[j];
          end_point[j] = int_curve->poles[3*(int_curve->num_poles-1)+j];
         }
       }

      if (BSdistptpts(&msg, pla_points[1], beg_point) <
          BSdistptpts(&msg, pla_points[1], end_point))
       {
        OM_BLOCK_MOVE (end_point, pla_points[0], sizeof (IGRpoint));
        for (j=0; j<3; j++)
             int_curve->poles[j] = pla_points[1][j];;
       }
      else
       {
        OM_BLOCK_MOVE (beg_point, pla_points[0], sizeof (IGRpoint));
        for (j=0; j<3; j++)
             int_curve->poles[3*(int_curve->num_poles-1)+j] =
                                                  pla_points[1][j];;
       }

      BSalloccv (other_geom.order,
                 other_geom.num_poles + 2 * other_geom.order - 1 ,
                 other_geom.rational, NULL, &part_curve, &msg);
      EMerr_hndlr (msg != BSSUCC,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

      status = BSprptoncv(&msg, &other_geom, points[2], &begin_param,
                          &onCurve);
      EMerr_hndlr(! status || msg != BSSUCC,*EMmsg,EMS_E_BSerror, wrapup);

      if (! onCurve)
       {
        BSmdstptcv(&other_geom, points[2], &begin_param, base_point,
                   &dist, &msg);
        EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
        for (j=0; j<3; j++)
             lin_curve->poles[j] = base_point[j];
       }

      status = BSpartofcv(&msg, &other_geom, begin_param, 0.0, par2[0],
                          part_curve);
      EMerr_hndlr(! status || msg != BSSUCC,*EMmsg,EMS_E_BSerror, wrapup);

      for (j=3; j<6; j++)
           lin_curve->poles[j] = pla_points[0][j-3];
     }

    plane.point = &pl_point[0];
    plane.normal = &pl_normal[0];

    status = MAdetplane(&msg, (IGRdouble *)pla_points, &num_pla_pnt, &toler, &plane);
    EMerr_hndlr(! status || !(1&msg), *EMmsg, EMS_E_MAerror, wrapup);

    if ((point_on_surf[1] > knot_tol) && (point_on_surf[1] < 1-knot_tol))
     {
      stat_OM = om$send(msg = message EMSsubbs.EMintersect_plane_fillet (
                              &msg, my_env,FALSE, NULL, &point_on_surf[1],
                              my_info, FALSE, pla_points[2],num_pair_info,
                              pair_info, &plane, &iso_curve, NULL,
                              &pair_info[*num_pair_info].edge, round_id),
                        targetid = my_info->fillet_id);
      EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_SurfaceError,wrapup);
     }
    else
     {
      EMget_twin_edge(&msg, my_info->fillet_surface, points[0],f_edges[1],
                      f_edges[3], FALSE, &pair_info[*num_pair_info].edge);
      EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);
     }

    BSsf3o4cvs (int_curve, part_curve, lin_curve,NULL, &plane_geom, &msg);
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
    EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

    EMget_other_edge (&msg, plane_geom, pla_points, srf_edges,
                      &edge_id->objid);
    EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);

    edge_id->osnum = OM_Gw_current_OS;

    pair_info[*num_pair_info].comm_edge = edge_id->objid;
    pair_info[*num_pair_info].edge_surf = my_info->fillet_id;
    pair_info[*num_pair_info].comm_edge_surf = *plane_id;
    pair_info[*num_pair_info].align_normal = TRUE;
    pair_info[*num_pair_info].surf_geom = my_info->fillet_surface;
    pair_info[*num_pair_info].comm_surf_geom = plane_geom;
    (*num_pair_info)++;

    if (par1) om$dealloc(ptr = par1); par1 = NULL;
    if (par2) om$dealloc(ptr = par2); par2 = NULL;
    if (cv1_points) om$dealloc (ptr = cv1_points); cv1_points = NULL;
    if (cv2_points) om$dealloc (ptr = cv2_points); cv2_points = NULL;

   } /*  EMS_NTRL_PATCH_VERTEX */
  else
   {
    stat_OM = om$send(msg = message EMSedge.EMgeneral_patch(&msg,
                            my_env, &my_geom, &other_geom,
                            f_edges, end_condition, my_info,num_pair_info,
                            pair_info, points, pla_points, construct_list,
                            plane_id, edge_id, round_id),
                      targetid = my_id);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
   }

  stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg,
                           &temp_id, &i),
                     targetid = *plane_id,
                     targetos = OM_Gw_current_OS);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
  
wrapup:

  EMWRAPUP (*EMmsg, stat_OM, "EMSedge.EMget_plane");
  if (loc_curve0) om$dealloc(ptr = loc_curve0);
  if (loc_curve1) om$dealloc(ptr = loc_curve1);
  if (iso_curve) om$dealloc(ptr = iso_curve);
  if (int_curve) om$dealloc(ptr = int_curve);
  if (lin_curve) om$dealloc(ptr = lin_curve);
  if (part_curve) om$dealloc(ptr = part_curve);

  if (my_geom.weights) om$dealloc (ptr = my_geom.weights);
  if (my_geom.poles) om$dealloc (ptr = my_geom.poles);
  if (my_geom.knots) om$dealloc (ptr = my_geom.knots);
  if (my_geom.bdrys) om$dealloc (ptr = my_geom.bdrys);

  if (other_geom.weights) om$dealloc (ptr = other_geom.weights);
  if (other_geom.poles) om$dealloc (ptr = other_geom.poles);
  if (other_geom.knots) om$dealloc (ptr = other_geom.knots);
  if (other_geom.bdrys) om$dealloc (ptr = other_geom.bdrys);

  return (stat_OM);
}
end implementation EMSedge;
