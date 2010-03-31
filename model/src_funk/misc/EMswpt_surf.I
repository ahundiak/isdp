/* ###################   APOGEE COMPILED   ################## */
class implementation GRvg;

/*
  HISTORY

    Sudha  07/09/93  :  Modified for BSprototypes anisfication
*/

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
#include "OMmacros.h"
#include "emsdef.h"
#include "madetplan.h"
#include "bssfarrevn.h"
#include "bssf3o4cvtn.h"
#include "bsprptonsf.h"
#include "bsnorvec.h"
#include "bsmovecrs.h"
#include "bsmkvec.h"
#include "bsmdistptsf.h"
#include "bslininter.h"
#include "bsfreecv.h"
#include "bsdotp.h"
#include "bsdistptpts.h"
#include "bsdistptpt.h"
#include "bsdirectcv.h"
#include "bscvarrevc.h"
#include "bsconstprcv.h"
#include "bschgcvewts.h"
#include "bsalloccv.h"

extern OMuword OPP_EMSgenbs_class_id;

from EMSsubbs import EMpartolbasis;
from EMSsubbs import EMintersect_plane_fillet;
from EMSsubbs import EMmake_bsedge_loop;
from EMSsurface import EMmk_nat_bdry;
from EMSboundary import EMget_objid;
from EMSedge import EMget_bcxyz_geom;

IGRboolean EMswept_surface (EMmsg,
                            my_env,
                            construct_list,
                            vertex_type,
                            vtx_point,
                            my_info,
                            num_pair_info,
                            pair_info,
                            edge_index,
                            num_ints,
                            intersect_pnts,
                            swept_srf_id,
                            round_id)

IGRlong 	             *EMmsg;
struct GRmd_env          *my_env;
struct GRvg_construct    *construct_list;
IGRshort                 vertex_type;
IGRpoint                 vtx_point;
struct EMedge_round_info *my_info;
IGRint                   *num_pair_info;
struct EMedge_con_info   *pair_info;
IGRint                   *edge_index;
IGRint                   *num_ints;
IGRpoint                 *intersect_pnts;
GRobjid                  *swept_srf_id;
GRobjid                  *round_id;

{
 
 IGRlong                 stat_OM, msg;
 GRspacenum              md_osnum;
 IGRshort                option;
 IGRint                  i;
 IGRint                  inx_a, inx_b, inx_c, inx_d, inx_e, inx_f;
 IGRint                  num_entries=4;
 IGRlong                 srf_size, num_pla_pnt=3;
 extern IGRdouble        fabs();
 IGRdouble               dist, max_disp, kurv, rad_c;
 IGRdouble               knot_tol, bas_tol, cht_tol;
 IGRdouble               param[2], point_on_surf[2];
 IGRboolean              swept_surf_ret,
                         status, iso_edge,
                         tst_planar,
                         onSurf,
                         world;
 IGRpoint                beg_pt, rc_pnt[1][2],
                         mid_point;
 IGRpoint                pl_point, pl_normal;
 IGRpoint                pla_point[3];
 IGRpoint                base_point,
                         point, pointa, pointb,
                         point0,
                         point1;
 IGRvector               vec1, vec2,
                         norm_vec;
 struct GRid             edge_id, surf_GRid;
 GRobjid                 good_id;
 GRobjid                 other_edge;
 GRobjid                 ss_edges[4];
 struct IGRplane         plane;
 struct EMvertex_curves  vertex_curves[4];
 struct IGRbsp_surface   *swept_surface;
 struct IGRbsp_surface   *surface,
                         **surfaces;
 struct IGRbsp_curve     *int_curve,
                         proj_curve,
                         **curves,
                         *mod_c0, *mod_c1, *mod_c2,
                         *loc_curve0,
                         *loc_curve1;
 struct IGRbsp_curve     *rev_curve0,
                         *rev_curve1,
                         *rev_curve2;
 struct EMSpartolbasis   surf_partol;
 OM_S_CHANSELECT         to_common_edge;

/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 swept_surf_ret = FALSE;
 *swept_srf_id = NULL_OBJID;
 world = TRUE;
 option = 0;
 tst_planar = TRUE;

 int_curve = NULL;
 loc_curve0 = NULL;
 loc_curve1 = NULL;
 rev_curve0 = NULL;
 rev_curve1 = NULL;
 rev_curve2 = NULL;
 mod_c0 = NULL;
 mod_c1 = NULL;
 mod_c2 = NULL;
 surface = NULL;
 swept_surface = NULL;

 proj_curve.weights = NULL;
 proj_curve.poles = NULL;
 proj_curve.knots = NULL;
 proj_curve.bdrys = NULL;

 curves = NULL;
 surfaces = NULL;
 
 md_osnum = my_env->md_id.osnum;

 for (i=0; i<4; i++)
  {
   vertex_curves[i].curve = NULL;
   vertex_curves[i].curves_surface = NULL;
  }
 
 switch (vertex_type)
  {
   case EMS_3CVX_VTX:
   case EMS_3CNV_VTX:
    if ((my_info[edge_index[0]].radius > my_info[edge_index[1]].radius)&& 
        (my_info[edge_index[0]].radius > my_info[edge_index[2]].radius))
        {inx_a = inx_d = 1; inx_b = inx_e = 2; inx_c = inx_f = 0;}
    else
    if ((my_info[edge_index[1]].radius > my_info[edge_index[0]].radius)&& 
        (my_info[edge_index[1]].radius > my_info[edge_index[2]].radius))
        {inx_a = inx_d = 2; inx_b = inx_e = 0; inx_c = inx_f = 1;}
    else
    if ((my_info[edge_index[2]].radius > my_info[edge_index[0]].radius)&& 
        (my_info[edge_index[2]].radius > my_info[edge_index[1]].radius))
        {inx_a = inx_d = 0; inx_b = inx_e = 1; inx_c = inx_f = 2;}
    else
     {
      swept_surf_ret = FALSE;
      goto wrapup;
     }

    status = BSmdistptsf (&msg, 
                        my_info[edge_index[inx_f]].fillet_surface,
                        intersect_pnts[inx_a],
                        &point_on_surf[0],
                        &point_on_surf[1],
                        base_point,
                        &dist);
    EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    BSmkvec (&msg, vec1, base_point, intersect_pnts[inx_a]);
    EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    status = BSnorvec(&msg, vec1);

    (void) BSsfarrevn (&msg, my_info[edge_index[inx_f]].fillet_surface, 1,
                       &point_on_surf[0], 1, &point_on_surf[1],
                       beg_pt, norm_vec);
    EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    if (! (my_info[edge_index[inx_f]].fillet_surface->pos_orient))
     {
      for (i=0; i<3; i++)
           norm_vec[i] = -norm_vec[i];
     }
    if (BSdotp(&msg, vec1, norm_vec) < 0)
        swept_surf_ret = TRUE;

    if (! swept_surf_ret)
     {
      if (my_info[edge_index[inx_a]].radius ==
          my_info[edge_index[inx_b]].radius)
          swept_surf_ret = TRUE;
     }
    break;
   
   case EMS_1CVX_2CNV_VTX:

    if (my_info[edge_index[0]].edge_type == EMS_CONVEX_EDGE) 
        {inx_a = inx_d = 1; inx_b = inx_e = 2; inx_c = inx_f = 0;}
    else
    if (my_info[edge_index[1]].edge_type == EMS_CONVEX_EDGE)
        {inx_a = inx_d = 2; inx_b = inx_e = 0; inx_c = inx_f = 1;}
    else
    if (my_info[edge_index[2]].edge_type == EMS_CONVEX_EDGE)
        {inx_a = inx_d = 0; inx_b = inx_e = 1; inx_c = inx_f = 2;}
    else
     {
      swept_surf_ret = FALSE;
      goto wrapup;
     }
    swept_surf_ret = TRUE;
    break;
 
   case EMS_1CNV_2CVX_VTX:
    if (my_info[edge_index[0]].edge_type == EMS_CONCAVE_EDGE) 
        {inx_a = inx_d = 1; inx_b = inx_e = 2; inx_c = inx_f = 0;}
    else
    if (my_info[edge_index[1]].edge_type == EMS_CONCAVE_EDGE)
        {inx_a = inx_d = 2; inx_b = inx_e = 0; inx_c = inx_f = 1;}
    else
    if (my_info[edge_index[2]].edge_type == EMS_CONCAVE_EDGE)
        {inx_a = inx_d = 0; inx_b = inx_e = 1; inx_c = inx_f = 2;}
    else
     {
      swept_surf_ret = FALSE;
      goto wrapup;
     }
    swept_surf_ret = TRUE;
    break;

   default:
    swept_surf_ret = FALSE;
    goto wrapup;   
  }

 if (swept_surf_ret)
  {
   BSEXTRACTPAR(&msg, BSTOLLENVEC, bas_tol);
   BSEXTRACTPAR(&msg, BSTOLCHRDHT, cht_tol);
   BSEXTRACTPAR (&msg, BSTOLKNOT, knot_tol);

   status = BSprptonsf(&msg, my_info[edge_index[inx_f]].fillet_surface,
                       intersect_pnts[inx_b], &point_on_surf[0],
                       &point_on_surf[1], &onSurf);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   status = BSprptonsf(&msg, my_info[edge_index[inx_f]].fillet_surface,
                       intersect_pnts[inx_c], &param[0], &param[1],
                       &onSurf);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   
   if ((fabs (point_on_surf[1] - param[1]) <= knot_tol) && (onSurf))
    {
     iso_edge = TRUE;

     BSalloccv (my_info[edge_index[inx_f]].fillet_surface->u_order,
                my_info[edge_index[inx_f]].fillet_surface->u_num_poles,
                my_info[edge_index[inx_f]].fillet_surface->rational,
                NULL, &int_curve, &msg);
     EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

     BSconstprcv (&msg, my_info[edge_index[inx_f]].fillet_surface,
                  &option, &point_on_surf[1], &tst_planar, int_curve);
     EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

     if (int_curve->rational)
      {
       if ((int_curve->weights[0] != 1.0) ||
           (int_curve->weights[int_curve->num_poles - 1] != 1.0))
        {
         BSalloccv (int_curve->order, int_curve->num_poles,
                    int_curve->rational, NULL, &mod_c2, &msg);
         EMerr_hndlr (msg != BSSUCC,*EMmsg,EMS_E_NoDynamicMemory, wrapup);

         BSchgcvewts (int_curve, mod_c2, &msg);
         EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

         if (int_curve) BSfreecv(&msg, int_curve);
         int_curve = mod_c2;
        }
      }
    }
   else
    {
     iso_edge = FALSE;
     int_curve = NULL;

     for (i=0; i<3; i++)
       mid_point[i] = intersect_pnts[inx_b][i]+(intersect_pnts[inx_c][i] -
                      intersect_pnts[inx_b][i]) / 2;

     status = BSmdistptsf (&msg, 
                           my_info[edge_index[inx_f]].fillet_surface,
                           mid_point,
                           &point_on_surf[0],
                           &point_on_surf[1],
                           base_point,
                           &dist);
     EMerr_hndlr(!status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

     if ((vertex_type == EMS_1CVX_2CNV_VTX) ||
         (vertex_type == EMS_1CNV_2CVX_VTX))
      {
       (void) BSsfarrevn (&msg, my_info[edge_index[inx_f]].fillet_surface,
                          1, &point_on_surf[0], 1, &point_on_surf[1],
                          beg_pt, norm_vec);
       EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   
       if (dist <= 2 * cht_tol)
        {
         for (i=0; i<3; i++)
              base_point[i] = norm_vec[i] + beg_pt[i];
        }
      }
     else if (dist <= 2 * cht_tol)
      {
       (void) BSsfarrevn (&msg, my_info[edge_index[inx_f]].fillet_surface,
                          1, &point_on_surf[0], 1, &point_on_surf[1],
                          beg_pt, norm_vec);
       EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

       for (i=0; i<3; i++)
            base_point[i] = norm_vec[i] + beg_pt[i];
      }
  
     plane.point = &pl_point[0];
     plane.normal = &pl_normal[0];

     OM_BLOCK_MOVE (&intersect_pnts[inx_b][0], pla_point[0],
                    sizeof (IGRpoint));
     OM_BLOCK_MOVE (&intersect_pnts[inx_c][0], pla_point[1],
                    sizeof (IGRpoint));
     OM_BLOCK_MOVE (base_point, pla_point[2], sizeof (IGRpoint));
   
     status = MAdetplane(&msg, (IGRdouble *)pla_point, &num_pla_pnt, &bas_tol, &plane);
     EMerr_hndlr(! status || !(1&msg), *EMmsg, EMS_E_MAerror, wrapup);
    }

   stat_OM = om$send(msg = message EMSsubbs.EMintersect_plane_fillet(&msg,
                           my_env,
                           iso_edge,
                           int_curve,
                           &point_on_surf[1],
                           &my_info[edge_index[inx_f]],
                           FALSE,
                           vtx_point,
                           num_pair_info,
                           pair_info,
                           &plane,
                           &vertex_curves[2].curve,
                           NULL,
                           &vertex_curves[2].edge_id,
                           round_id),
                     senderid = NULL_OBJID,
                     targetid = my_info[edge_index[inx_f]].fillet_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

   if (! iso_edge) int_curve = vertex_curves[2].curve;

   vertex_curves[2].fillet_id = my_info[edge_index[inx_f]].fillet_id;
   vertex_curves[2].curves_surface =
                              my_info[edge_index[inx_f]].fillet_surface;

   status = BSprptonsf (&msg, my_info[edge_index[inx_e]].fillet_surface,
                      intersect_pnts[inx_b], &point_on_surf[0],
                      &point_on_surf[1], &onSurf);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   if (! onSurf)
    {
     status = BSmdistptsf (&msg, 
                         my_info[edge_index[inx_e]].fillet_surface,
                         intersect_pnts[inx_b],
                         &point_on_surf[0],
                         &point_on_surf[1],
                         base_point,
                         &dist);
     EMerr_hndlr(! status || msg != BSSUCC,*EMmsg, EMS_E_BSerror, wrapup);
    }

   BSalloccv (my_info[edge_index[inx_e]].fillet_surface->u_order,
              my_info[edge_index[inx_e]].fillet_surface->u_num_poles,
              my_info[edge_index[inx_e]].fillet_surface->rational,
              NULL, &vertex_curves[0].curve, &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   param[0] = point_on_surf[1];

   BSconstprcv (&msg, my_info[edge_index[inx_e]].fillet_surface,
                &option, &point_on_surf[1], &tst_planar,
                vertex_curves[0].curve);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   if (vertex_curves[0].curve->rational)
    {
     if ((vertex_curves[0].curve->weights[0] != 1.0) ||
         (vertex_curves[0].curve->weights[
                           vertex_curves[0].curve->num_poles - 1] != 1.0))
      {
       BSalloccv (vertex_curves[0].curve->order,
                  vertex_curves[0].curve->num_poles,
                  vertex_curves[0].curve->rational,
                  NULL, &mod_c0, &msg);
       EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

       BSchgcvewts (vertex_curves[0].curve, mod_c0, &msg);
       EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

       if (vertex_curves[0].curve) BSfreecv(&msg, vertex_curves[0].curve);
       vertex_curves[0].curve = mod_c0;
      }
    }

   status = BSprptonsf (&msg, my_info[edge_index[inx_d]].fillet_surface,
                      intersect_pnts[inx_c], &point_on_surf[0],
                      &point_on_surf[1], &onSurf);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   if (! onSurf)
    {
     status = BSmdistptsf (&msg, 
                         my_info[edge_index[inx_d]].fillet_surface,
                         intersect_pnts[inx_c],
                         &point_on_surf[0],
                         &point_on_surf[1],
                         base_point,
                         &dist);
     EMerr_hndlr(! status || msg != BSSUCC,*EMmsg, EMS_E_BSerror, wrapup);
    }

   BSalloccv (my_info[edge_index[inx_d]].fillet_surface->u_order,
              my_info[edge_index[inx_d]].fillet_surface->u_num_poles,
              my_info[edge_index[inx_d]].fillet_surface->rational,
              NULL, &vertex_curves[1].curve, &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   param[1] = point_on_surf[1];

   BSconstprcv (&msg, my_info[edge_index[inx_d]].fillet_surface,
                &option, &point_on_surf[1], &tst_planar,
                vertex_curves[1].curve);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   if (vertex_curves[1].curve->rational)
    {
     if ((vertex_curves[1].curve->weights[0] != 1.0) ||
         (vertex_curves[1].curve->weights[
                           vertex_curves[1].curve->num_poles - 1] != 1.0))
      {
       BSalloccv (vertex_curves[1].curve->order,
                  vertex_curves[1].curve->num_poles,
                  vertex_curves[1].curve->rational,
                  NULL, &mod_c1, &msg);
       EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

       BSchgcvewts (vertex_curves[1].curve, mod_c1, &msg);
       EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

       if (vertex_curves[1].curve) BSfreecv(&msg, vertex_curves[1].curve);
       vertex_curves[1].curve = mod_c1;
      }
    }

   BSalloccv(vertex_curves[0].curve->order,
             vertex_curves[0].curve->num_poles,
             vertex_curves[0].curve->rational,
             0,
             &rev_curve0,
             &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   status = BSdirectcv(&msg,
                     intersect_pnts[inx_b],
                     vertex_curves[0].curve,
                     rev_curve0);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   
   BSalloccv(vertex_curves[1].curve->order,
             vertex_curves[1].curve->num_poles,
             vertex_curves[1].curve->rational,
             0,
             &rev_curve1,
             &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   status = BSdirectcv(&msg,
                     intersect_pnts[inx_c],
                     vertex_curves[1].curve,
                     rev_curve1);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   
   BSalloccv(vertex_curves[2].curve->order,
             vertex_curves[2].curve->num_poles,
             vertex_curves[2].curve->rational,
             0,
             &rev_curve2,
             &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   status = BSdirectcv(&msg,
                     intersect_pnts[inx_b],
                     vertex_curves[2].curve,
                     rev_curve2);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   
   BSmovecrs(rev_curve0,
              rev_curve1,
              rev_curve2,
              NULL,
              FALSE,
              TRUE,
              NULL, NULL, NULL, NULL, NULL,
              &swept_surface,
              &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   stat_OM = om$send(msg = message EMSsubbs.EMintersect_plane_fillet(&msg,
                           my_env,
                           TRUE,
                           vertex_curves[0].curve,
                           &param[0],
                           &my_info[edge_index[inx_e]],
                           FALSE,
                           vtx_point,
                           num_pair_info,
                           pair_info,
                           NULL,
                           &loc_curve0,
                           NULL,
                           &vertex_curves[0].edge_id,
                           round_id),
                     senderid = NULL_OBJID,
                     targetid = my_info[edge_index[inx_e]].fillet_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

   vertex_curves[0].fillet_id = my_info[edge_index[inx_e]].fillet_id;
   vertex_curves[0].curves_surface =
                                my_info[edge_index[inx_e]].fillet_surface;

   stat_OM = om$send(msg = message EMSsubbs.EMintersect_plane_fillet(&msg,
                           my_env,
                           TRUE,
                           vertex_curves[1].curve,
                           &param[1],
                           &my_info[edge_index[inx_d]],
                           FALSE,
                           vtx_point,
                           num_pair_info,
                           pair_info,
                           NULL,
                           &loc_curve1,
                           NULL,
                           &vertex_curves[1].edge_id,
                           round_id),
                     senderid = NULL_OBJID,
                     targetid = my_info[edge_index[inx_d]].fillet_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

   vertex_curves[1].fillet_id = my_info[edge_index[inx_d]].fillet_id;
   vertex_curves[1].curves_surface =
                                my_info[edge_index[inx_d]].fillet_surface;

   BSalloccv (swept_surface->v_order,
              swept_surface->v_num_poles,
              swept_surface->rational,
              NULL, &vertex_curves[3].curve, &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   point_on_surf[0] = 0;
   option = 1;
   BSconstprcv (&msg, swept_surface, &option, &point_on_surf[0],
                &tst_planar, vertex_curves[3].curve);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   if (vertex_curves[3].curve->rational)
    {
     for (i=0; i<3; i++)
      point[i] = vertex_curves[3].curve->poles[i] /
                 vertex_curves[3].curve->weights[0];
    }
   else
    {
     for (i=0; i<3; i++)
      point[i] = vertex_curves[3].curve->poles[i];
    }

   for (i=0; i<3; i++)
    {
     point0[i] = int_curve->poles[i];
     point1[i] = (int_curve->poles[3*(int_curve->num_poles - 1) + i]); 
    }
 
   if ((BSdistptpt(&msg, point, point0) <=
                                  my_info[edge_index[inx_d]].radius) ||
       (BSdistptpt(&msg, point, point1) <= 
                                  my_info[edge_index[inx_d]].radius))
    {
     point_on_surf[0] = 1;
     BSconstprcv (&msg, swept_surface, &option, &point_on_surf[0],
                  &tst_planar, vertex_curves[3].curve);   
     EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
    }
   
   if ((vertex_curves[3].curve->order != 2) &&
       (my_info[edge_index[inx_f]].edge_type == EMS_CONCAVE_EDGE))
    {
     /* if this curve intersects the edges being rounded, trimming
        will be invalid -- hence replace this curve with something
        which does not intersect the edges */

     i = 1; dist = 0.5; max_disp = MAXFLOAT;
     
     BScvarrevc(vertex_curves[3].curve, i, &dist, max_disp, &kurv, &rad_c,
                rc_pnt, &msg);
     EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

     BSmkvec (&msg, vec1, rc_pnt[0][0], rc_pnt[0][1]);
     status = BSnorvec(&msg, vec1);
     BSmkvec (&msg, vec2, rc_pnt[0][0], vtx_point);
     status = BSnorvec(&msg, vec2);

     if (BSdotp (&msg, vec1, vec2) < 0)
      {
       if (vertex_curves[3].curve->rational)
        {
         for (i=0; i<3; i++)
          {
           pla_point[0][i] = vertex_curves[3].curve->poles[i] /
                             vertex_curves[3].curve->weights[0];
           pla_point[2][i] = vertex_curves[3].curve->poles[
                             3*(vertex_curves[3].curve->num_poles-1)+i] /
                             vertex_curves[3].curve->weights[
                             vertex_curves[3].curve->num_poles-1];
           
          }
        }
       else
        {
         for (i=0; i<3; i++)
          {
           pla_point[0][i] = vertex_curves[3].curve->poles[i];
           pla_point[2][i] = vertex_curves[3].curve->poles[
                             3*(vertex_curves[3].curve->num_poles-1)+i];
           
          }
        }

       dist = BSdistptpt(&msg, vtx_point, rc_pnt[0][0]);
       for (i=0; i<3; i++)
            pla_point[1][i] = (vtx_point[i] *
                 (1.15*my_info[edge_index[inx_a]].radius + dist) -
                 1.15*my_info[edge_index[inx_a]].radius*rc_pnt[0][0][i]) /
                 dist;

       if (vertex_curves[3].curve) BSfreecv(&msg, vertex_curves[3].curve);
       BSalloccv (2, 3, FALSE, NULL, &vertex_curves[3].curve, &msg);
       EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

       status = BSlininter(&msg, (IGRint *)&num_pla_pnt, &pla_point[0][0],
                           vertex_curves[3].curve, vec1);
       EMerr_hndlr(! status || msg != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
      }
    }

   for (i=0; i<3; i++)
    point[i] = vertex_curves[3].curve->poles[i];

   status = BSprptonsf (&msg, my_info[edge_index[inx_d]].surface,
                        point, &point_on_surf[0], &point_on_surf[1],
                        &onSurf);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   if (! onSurf)
    {
     status = BSmdistptsf (&msg, 
                           my_info[edge_index[inx_d]].surface,
                           point,
                           &point_on_surf[0],
                           &point_on_surf[1],
                           base_point,
                           &dist);
     EMerr_hndlr(! status || msg != BSSUCC,*EMmsg, EMS_E_BSerror, wrapup);
   
     onSurf = (dist <= 100*bas_tol) ? TRUE : FALSE;
    }

   if (! onSurf)
    {
     stat_OM = om$send(msg = message GRvg.GRgetsize(&msg,
                             &my_env->md_env.matrix_type,
                             my_env->md_env.matrix,
                             &srf_size),
                       senderid = NULL_OBJID,
                   targetid = my_info[edge_index[inx_d]].comm_surface_id);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
             
     surface = (struct IGRbsp_surface *) om$malloc(size =(OMuint)
                        srf_size);
     EMerr_hndlr(! surface, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  
     stat_OM = om$send(msg = message GRvg.GRgetgeom(&msg,
                             &my_env->md_env.matrix_type,
                             my_env->md_env.matrix,
                             (IGRchar *)surface),
                       senderid = NULL_OBJID,
                   targetid = my_info[edge_index[inx_d]].comm_surface_id);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

     stat_OM = EMmake_chanselect(EMSedge_to_common_edge, &to_common_edge);
     if (! (1 & stat_OM)) goto wrapup;

     stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                             &other_edge),
                       senderid = my_info[edge_index[inx_d]].edge_id,
                       p_chanselect = &to_common_edge);
     EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
    }
 
   good_id = (onSurf) ? my_info[edge_index[inx_d]].surface_id :
                        my_info[edge_index[inx_d]].comm_surface_id;

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

   stat_OM = om$send(msg = message EMSsubbs.EMmake_bsedge_loop(&msg,
                           my_env,
                           (onSurf) ? 
                           my_info[edge_index[inx_d]].surface : surface,
                           vertex_curves[3].curve,
                           &surf_partol,
                           (onSurf) ? 
                           my_info[edge_index[inx_d]].edge_id :other_edge,
                           EMS_VERTEX_BND, FALSE,
                           vtx_point, &edge_id, round_id),
                     senderid = NULL_OBJID,
                     targetid = good_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

   vertex_curves[3].edge_id = edge_id.objid;
   vertex_curves[3].fillet_id = good_id;
   vertex_curves[3].curves_surface = (onSurf) ? 
                             my_info[edge_index[inx_d]].surface : surface;

   if (swept_surface) om$dealloc(ptr = swept_surface);
   swept_surface = NULL;
   
   surf_GRid.objid = good_id;
   surf_GRid.osnum = my_env->md_id.osnum;

   stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom (&msg,
                           &my_env->md_env, &surf_GRid, NULL, 0,
                           OM_K_MAXINT, FALSE, NULL, &proj_curve),
                     senderid = NULL_OBJID,   
                     targetid = edge_id.objid);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   if (vertex_curves[3].curve->rational)
    {
     for (i=0; i<3; i++)
      {
        pointa[i] = vertex_curves[3].curve->poles[i] /
                    vertex_curves[3].curve->weights[0];
        pointb[i] = (vertex_curves[3].curve->poles[3 *
                    (vertex_curves[3].curve->num_poles - 1)+i]) /
                    (vertex_curves[3].curve->weights[
                     vertex_curves[3].curve->num_poles - 1]);
      }
    }
   else
    {
     for (i=0; i<3; i++)
      {
       pointa[i] = vertex_curves[3].curve->poles[i];
       pointb[i] = vertex_curves[3].curve->poles[3 *
                   (vertex_curves[3].curve->num_poles - 1)+i];
      }
    }

   if (BSdistptpts(&msg, &proj_curve.poles[0], pointa) <
       BSdistptpts(&msg, &proj_curve.poles[0], pointb))
    {
     OM_BLOCK_MOVE(pointa,&proj_curve.poles[0], sizeof (IGRpoint));
     OM_BLOCK_MOVE(pointb,&proj_curve.poles[3*(proj_curve.num_poles-1)],
                   sizeof (IGRpoint));
    }
   else
    {
     OM_BLOCK_MOVE(pointb,&proj_curve.poles[0], sizeof (IGRpoint));
     OM_BLOCK_MOVE(pointa,&proj_curve.poles[3*(proj_curve.num_poles-1)],
                   sizeof (IGRpoint));
    }

   curves = (struct IGRbsp_curve **) om$malloc(size = num_entries *
                                     sizeof (struct IGRbsp_curve *));
   surfaces = (struct IGRbsp_surface **) om$malloc(size = num_entries *
                                     sizeof (struct IGRbsp_surface *));

   for (i=0; i<num_entries-1; i++)
        curves[i] = vertex_curves[i].curve;

   curves[3] = &proj_curve;
   vertex_curves[3].curve = &proj_curve;   

   surfaces[0] = my_info[edge_index[inx_e]].fillet_surface;
   surfaces[1] = my_info[edge_index[inx_d]].fillet_surface;
   surfaces[2] = my_info[edge_index[inx_f]].fillet_surface;
   surfaces[3] = (onSurf) ? my_info[edge_index[inx_d]].surface :
                                                       surface;

   /* fix the end poles so that they form a closed contour */

   if (BSdistptpts(&msg, intersect_pnts[inx_b],
                   &vertex_curves[2].curve->poles[0]) <
       BSdistptpts(&msg, intersect_pnts[inx_b], 
                   &vertex_curves[2].curve->poles[3 * 
                   (vertex_curves[2].curve->num_poles - 1)]))
    {
     OM_BLOCK_MOVE (intersect_pnts[inx_b],
                    &vertex_curves[2].curve->poles[0],
                    sizeof (IGRpoint));
     OM_BLOCK_MOVE (intersect_pnts[inx_c],
                    &vertex_curves[2].curve->poles[3 * 
                    (vertex_curves[2].curve->num_poles - 1)],
                    sizeof (IGRpoint));
    }
   else
    {
     OM_BLOCK_MOVE (intersect_pnts[inx_c],
                    &vertex_curves[2].curve->poles[0],
                    sizeof (IGRpoint));
     OM_BLOCK_MOVE (intersect_pnts[inx_b],
                    &vertex_curves[2].curve->poles[3 * 
                    (vertex_curves[2].curve->num_poles - 1)],
                    sizeof (IGRpoint));
    }

   if (BSdistptpts(&msg, intersect_pnts[inx_b],
                   &vertex_curves[0].curve->poles[0]) <
       BSdistptpts(&msg, intersect_pnts[inx_b], 
                   &vertex_curves[0].curve->poles[3 * 
                   (vertex_curves[0].curve->num_poles - 1)]))
    {
     OM_BLOCK_MOVE (intersect_pnts[inx_b],
                    &vertex_curves[0].curve->poles[0],
                    sizeof (IGRpoint));
    }
   else
    {
     OM_BLOCK_MOVE (intersect_pnts[inx_b],
                    &vertex_curves[0].curve->poles[3 * 
                    (vertex_curves[0].curve->num_poles - 1)],
                    sizeof (IGRpoint));
    }

   if (BSdistptpts(&msg, intersect_pnts[inx_c],
                   &vertex_curves[1].curve->poles[0]) <
       BSdistptpts(&msg, intersect_pnts[inx_c], 
                   &vertex_curves[1].curve->poles[3 * 
                   (vertex_curves[1].curve->num_poles - 1)]))
    {
     OM_BLOCK_MOVE (intersect_pnts[inx_c],
                    &vertex_curves[1].curve->poles[0],
                    sizeof (IGRpoint));
    }
   else
    {
     OM_BLOCK_MOVE (intersect_pnts[inx_c],
                    &vertex_curves[1].curve->poles[3 * 
                    (vertex_curves[1].curve->num_poles - 1)],
                    sizeof (IGRpoint));
    }


   BSsf3o4cvtn(num_entries, curves, surfaces, &swept_surface, &msg);
   EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   swept_surface->pos_orient = FALSE;

   construct_list->geometry = (IGRchar *) swept_surface;

   stat_OM = om$construct(classid = OPP_EMSgenbs_class_id,
                          obj_osnum = NULL,
                          osnum = md_osnum,
                          p_objid = swept_srf_id,
                          msg = message GRgraphics.GRconstruct(
                          construct_list));
   EMerr_hndlr(! (1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

   /* construct the natural boundary for the swept surface */

   stat_OM  = om$send (msg = message EMSsurface.EMmk_nat_bdry(&msg,
                             &my_env->md_env, ss_edges),
                       senderid = NULL_OBJID,
                       targetid = *swept_srf_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

   stat_OM = EMfill_pair_info(&msg, ss_edges, swept_surface,*swept_srf_id,
                              num_pair_info, pair_info, vertex_curves,
                              4);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);
  }

 wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "GRvg.EMswept_surface");

 if (curves) om$dealloc(ptr = curves);
 if (surfaces) om$dealloc(ptr = surfaces);

 for (i=0; i<3; i++)
  {
   if (vertex_curves[i].curve) BSfreecv(&msg, vertex_curves[i].curve);
  }
 if (rev_curve0) BSfreecv(&msg, rev_curve0);
 if (rev_curve1) BSfreecv(&msg, rev_curve1);
 if (rev_curve2) BSfreecv(&msg, rev_curve2);

 if (proj_curve.weights) om$dealloc (ptr = proj_curve.weights);
 if (proj_curve.poles) om$dealloc (ptr = proj_curve.poles);
 if (proj_curve.knots) om$dealloc (ptr = proj_curve.knots);
 if (proj_curve.bdrys) om$dealloc (ptr = proj_curve.bdrys);

 return (swept_surf_ret);

}

end implementation GRvg;

