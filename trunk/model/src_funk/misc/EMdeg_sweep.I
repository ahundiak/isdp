class implementation GRvg;

/*
   HISTORY

        Sudha   07/08/93        Modified for BSprototypes ansification
*/

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsdattyp.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSopt.h"
#include "EMSmsgdef.h"
#include "EMSlm.h"
#include "EMSlmdef.h"
#include "OMmacros.h"
#include "emssfint.h"
#include "bssfeval.h"
#include "bssf3o4cvtn.h"
#include "bsprptonsf.h"
#include "bsprptoncv.h"
#include "bsmkvec.h"
#include "bsmdstptcv.h"
#include "bsmdistptsf.h"
#include "bsmdistcvcv.h"
#include "bsfreecv.h"
#include "bsdotp.h"
#include "bsdistptpts.h"
#include "bsdistptpt.h"
#include "bscvarrevt.h"
#include "bsconstprcv.h"
#include "bschangepar.h"
#include "bscbftptswt.h"
#include "bsalloccv.h"

extern OMuword OPP_EMSgenbs_class_id;

from EMSsubbs import EMpartolbasis;
from EMSsubbs import EMget_edges;
from EMSsubbs import EMmake_bsedge_loop;
from EMSsubbs import EMintersect_plane_fillet;
from EMSsurface import EMmk_nat_bdry;
from EMSboundary import EMget_objid;
from EMSedge import EMget_bcxyz_geom,
                    EMpratpt,
                    EMendpts,
                    EMalter_geometry,
                    EMget_location;

IGRboolean EMdeg_swept_surface (EMmsg,
                                my_env,
                                construct_list,
                                my_info,
                                num_pair_info,
                                pair_info,
                                edge_index,
                                center_point,
                                other_edge_id,
                                other_surf_id,
                                swept_srf_id,
                                round_id)

IGRlong 	             *EMmsg;
struct GRmd_env          *my_env;
struct GRvg_construct    *construct_list;
struct EMedge_round_info *my_info;
IGRint                   *num_pair_info;
struct EMedge_con_info   *pair_info;
IGRint                   *edge_index;
IGRpoint                 center_point;
GRobjid                  other_edge_id, other_surf_id;
GRobjid                  *swept_srf_id;
GRobjid                  *round_id;

{
 
 IGRlong                 stat_OM, msg;
 IGRlong                 srf_size;
 GRspacenum              md_osnum;
 IGRshort                option;
 IGRboolean              status,
                         tst_planar,
                         truncate_end,
                         onSurf,
                         onCurve,
                         world, small_curve;
 IGRint                  i, j, num_int1, num_int2, num_entries;
 IGRint                  num_edges, num_par;
 IGRdouble               disp_fac, save_cht;
 IGRdouble               bas_tol, knot_tol, chdht_tol;
 IGRdouble               dist, dist1, dist2;
 IGRdouble               cv_par1, cv_par2;
 IGRdouble               *par1=NULL, *par2=NULL,
                         *par3=NULL, *par4=NULL;
 IGRdouble               pts[6], uvbegpt[2], uvendpt[2];
 IGRdouble               point_on_surf[2];
 IGRdouble               param[4], bnd0_param[2];
 IGRdouble               max_val, end_param[4];
 extern IGRdouble        fabs();
 IGRpoint                fs1_point, fs2_point;
 IGRpoint                base_point;
 IGRpoint                pla_point[2];
 IGRpoint                end_points[2];
 IGRpoint                *cv1_points, *cv2_points,
                         *cv3_points, *cv4_points;
 IGRvector               rel_vector, end_vectors[2];
 GRobjid                 good_id, other_edge, ss_edges[4];
 GRobjid                 spsf_edge, spsf_id, to_fix_edge;
 struct GRid             surf_GRid, edge_id;
 struct EMSsfintedpar    inters_data;
 struct EMvertex_curves  vertex_curves[4];
 struct IGRbsp_surface   *swept_surface;
 struct IGRbsp_surface   *surface, *spsf;
 struct IGRbsp_surface   **surfaces;
 struct IGRbsp_curve     *first_curve, *second_curve;
 struct IGRbsp_curve     other_edge_geom;
 struct IGRbsp_curve     proj_curve;
 struct IGRbsp_curve     **curves;
 struct IGRbsp_curve     *int_curve;
 struct EMSpartolbasis   surf_partol;
 OM_S_CHANSELECT         to_common_edge;

 typedef IGRpoint	 dummy[2];

/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 *swept_srf_id = NULL;
 world = TRUE;
 option = 0;
 tst_planar = TRUE;

 curves = NULL;
 surfaces = NULL;
 int_curve = NULL;
 surface = NULL;
 spsf = NULL;
 spsf_id = NULL_OBJID;
 num_edges = 3;
 md_osnum = my_env->md_id.osnum;

 cv1_points = cv2_points = NULL;
 cv3_points = cv4_points = NULL;

 surf_GRid.objid = other_surf_id;
 surf_GRid.osnum = my_env->md_id.osnum;
 max_val = MAXFLOAT;

 stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
 if (! (1 & stat_OM)) goto wrapup;

 for (i=0; i<4; i++)
  {
   vertex_curves[i].curve = NULL;
   vertex_curves[i].curves_surface = NULL;
  }
 
 vertex_curves[0].edge_id = NULL_OBJID;
 vertex_curves[1].edge_id = NULL_OBJID;

 BSEXTRACTPAR (&msg, BSTOLKNOT, knot_tol);
 BSEXTRACTPAR(&msg, BSTOLCHRDHT, chdht_tol);
 BSEXTRACTPAR(&msg, BSTOLLENVEC, bas_tol);

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
             &num_int1,
             &par1, &par2,
             &cv1_points,
             &cv2_points,
             &dist1,
             &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 BSmdistcvcv(my_info[edge_index[0]].comm_curve,
             &other_edge_geom,
             &num_int2,
             &par3, &par4,
             &cv3_points,
             &cv4_points,
             &dist2,
             &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 j=0;

 if (fabs(dist1) < fabs(dist2))
  {
   if (num_int1 > 1)
    {
     for (i=0; i<num_int1; i++)
      {
       dist = BSdistptpt(&msg, &cv1_points[i][0], center_point);
       if (dist < max_val)
        {
         max_val = dist;
         j=i;
        }
      }
    }

   if((dist1 > chdht_tol/2) && (! my_info[edge_index[0]].fillet_modified))
    {
     if ((par1[0] <= knot_tol) || (par1[0] >= 1 - knot_tol))
      {
       spsf_id = my_info[edge_index[0]].surface_id;
       spsf = my_info[edge_index[0]].surface;
       spsf_edge = my_info[edge_index[0]].edge_id;
      }
    }

   OM_BLOCK_MOVE (&cv1_points[j][0], fs1_point, sizeof (IGRpoint));
   first_curve = my_info[edge_index[0]].comm_curve;
  }
 else
  {
   if (num_int2 > 1)
    {
     for (i=0; i<num_int2; i++)
      {
       dist = BSdistptpt(&msg, &cv3_points[i][0], center_point);
       if (dist < max_val)
        {
         max_val = dist;
         j=i;
        }
      }
    }

   if((dist2 > chdht_tol/2) && (! my_info[edge_index[0]].fillet_modified))
    {
     if ((par3[0] <= knot_tol) || (par3[0] >= 1 - knot_tol))
      {
       spsf_id = my_info[edge_index[0]].comm_surface_id;
       stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                               &spsf_edge),
                         senderid = my_info[edge_index[0]].edge_id,
                         p_chanselect = &to_common_edge);
       EMerr_hndlr(! (1 & stat_OM & msg),*EMmsg, EMS_E_EdgeError, wrapup);

       stat_OM = om$send(msg = message GRvg.GRgetsize(&msg,
                               &my_env->md_env.matrix_type,
                               my_env->md_env.matrix,
                               &srf_size),
                         senderid = NULL_OBJID,
                         targetid = spsf_id);
       EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
             
       spsf = (struct IGRbsp_surface *) om$malloc(size =(OMuint)srf_size);
       EMerr_hndlr(! spsf, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  
       stat_OM = om$send(msg = message GRvg.GRgetgeom(&msg,
                               &my_env->md_env.matrix_type,
                               my_env->md_env.matrix,
                               (IGRchar *)spsf),
                       senderid = NULL_OBJID,
                       targetid = spsf_id);
       EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
      }
    }

   OM_BLOCK_MOVE (&cv3_points[j][0], fs1_point, sizeof (IGRpoint));
   first_curve = my_info[edge_index[0]].curve;
  }

 max_val = MAXFLOAT;
 j=0;

 BSmdistcvcv(my_info[edge_index[1]].curve,
             &other_edge_geom,
             &num_int1,
             &par1, &par2,
             &cv1_points,
             &cv2_points,
             &dist1,
             &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 BSmdistcvcv(my_info[edge_index[1]].comm_curve,
             &other_edge_geom,
             &num_int2,
             &par3, &par4,
             &cv3_points,
             &cv4_points,
             &dist2,
             &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (fabs(dist1) < fabs(dist2))
  {
   if (num_int1 > 1)
    {
     for (i=0; i<num_int1; i++)
      {
       dist = BSdistptpt(&msg, &cv1_points[i][0], center_point);
       if (dist < max_val)
        {
         max_val = dist;
         j=i;
        }
      }
    }

   if((dist1 > chdht_tol/2) && (! my_info[edge_index[1]].fillet_modified))
    {
     if ((par1[0] <= knot_tol) || (par1[0] >= 1 - knot_tol))
      {
       spsf_id = my_info[edge_index[1]].surface_id;
       spsf = my_info[edge_index[1]].surface;
       spsf_edge = my_info[edge_index[1]].edge_id;
      }
    }

   OM_BLOCK_MOVE (&cv1_points[j][0], fs2_point, sizeof (IGRpoint));
   second_curve = my_info[edge_index[1]].comm_curve;
  }
 else
  {
   if (num_int2 > 1)
    {
     for (i=0; i<num_int2; i++)
      {
       dist = BSdistptpt(&msg, &cv3_points[i][0], center_point);
       if (dist < max_val)
        {
         max_val = dist;
         j=i;
        }
      }
    }

   if((dist2 > chdht_tol/2) && (! my_info[edge_index[1]].fillet_modified))
    {
     if ((par3[0] <= knot_tol) || (par3[0] >= 1 - knot_tol))
      {
       spsf_id = my_info[edge_index[1]].comm_surface_id;

       stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                               &spsf_edge),
                         senderid = my_info[edge_index[1]].edge_id,
                         p_chanselect = &to_common_edge);
       EMerr_hndlr(! (1 & stat_OM & msg),*EMmsg, EMS_E_EdgeError, wrapup);

       stat_OM = om$send(msg = message GRvg.GRgetsize(&msg,
                               &my_env->md_env.matrix_type,
                               my_env->md_env.matrix,
                               &srf_size),
                         senderid = NULL_OBJID,
                         targetid = spsf_id);
       EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
             
       spsf = (struct IGRbsp_surface *) om$malloc(size =(OMuint)srf_size);
       EMerr_hndlr(! spsf, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  
       stat_OM = om$send(msg = message GRvg.GRgetgeom(&msg,
                               &my_env->md_env.matrix_type,
                               my_env->md_env.matrix,
                               (IGRchar *)spsf),
                       senderid = NULL_OBJID,
                       targetid = spsf_id);
       EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
      }
    }

   OM_BLOCK_MOVE (&cv3_points[j][0], fs2_point, sizeof (IGRpoint));
   second_curve = my_info[edge_index[1]].curve;
  }

 status = BSprptonsf (&msg, my_info[edge_index[0]].fillet_surface,
                      fs1_point,  &param[0], &param[1], &onSurf);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 BSalloccv (my_info[edge_index[0]].fillet_surface->u_order,
            my_info[edge_index[0]].fillet_surface->u_num_poles,
            my_info[edge_index[0]].fillet_surface->rational,
            NULL, &vertex_curves[0].curve, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 BSconstprcv (&msg, my_info[edge_index[0]].fillet_surface, &option,
              &param[1], &tst_planar, vertex_curves[0].curve);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if ((param[1] >= knot_tol) && (param[1] <= 1 - knot_tol))
  {
   if (vertex_curves[0].curve->rational)
    {
     for (i=0; i<3; i++)
      {
       pla_point[0][i] = vertex_curves[0].curve->poles[i] /
                         vertex_curves[0].curve->weights[0];
       pla_point[1][i] = (vertex_curves[0].curve->poles[3 *
                         (vertex_curves[0].curve->num_poles - 1)+i]) /
                         (vertex_curves[0].curve->weights[
                         vertex_curves[0].curve->num_poles - 1]);
      }
    }
   else
    {
     for (i=0; i<3; i++)
      {
       pla_point[0][i] = vertex_curves[0].curve->poles[i];
       pla_point[1][i] = vertex_curves[0].curve->poles[3 *
                         (vertex_curves[0].curve->num_poles - 1)+i];
      }
    }

   if (BSdistptpt(&msg, fs1_point, pla_point[0]) < 
       BSdistptpt(&msg, fs1_point, pla_point[1]))
       OM_BLOCK_MOVE(pla_point[1], end_points[0], sizeof (IGRpoint));
   else
       OM_BLOCK_MOVE(pla_point[0], end_points[0], sizeof (IGRpoint));

   stat_OM = om$send(msg = message EMSsubbs.EMintersect_plane_fillet(&msg,
                           my_env,
                           TRUE,
                           vertex_curves[0].curve,
                           &param[1],                         
                           &my_info[edge_index[0]],
                           FALSE,
                           center_point,
                           num_pair_info,
                           pair_info,
                           NULL,
                           &int_curve,
                           NULL,
                           &vertex_curves[0].edge_id,
                           round_id),
                     senderid = NULL_OBJID,
                     targetid = my_info[edge_index[0]].fillet_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);
  }

 vertex_curves[0].fillet_id = my_info[edge_index[0]].fillet_id;
 vertex_curves[0].curves_surface = my_info[edge_index[0]].fillet_surface;

 status = BSprptonsf (&msg, my_info[edge_index[1]].fillet_surface,
                      fs2_point, &param[2], &param[3], &onSurf);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 BSalloccv (my_info[edge_index[1]].fillet_surface->u_order,
            my_info[edge_index[1]].fillet_surface->u_num_poles,
            my_info[edge_index[1]].fillet_surface->rational,
            NULL, &vertex_curves[1].curve, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 BSconstprcv (&msg, my_info[edge_index[1]].fillet_surface, &option,
              &param[3], &tst_planar, vertex_curves[1].curve);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if ((param[3] >= knot_tol) && (param[3] <= 1 - knot_tol))
  {
   if (vertex_curves[1].curve->rational)
    {
     for (i=0; i<3; i++)
      {
       pla_point[0][i] = vertex_curves[1].curve->poles[i] /
                         vertex_curves[1].curve->weights[0];
       pla_point[1][i] = (vertex_curves[1].curve->poles[3 *
                         (vertex_curves[1].curve->num_poles - 1)+i]) /
                         (vertex_curves[1].curve->weights[
                         vertex_curves[1].curve->num_poles - 1]);
      }
    }
   else
    {
     for (i=0; i<3; i++)
      {
       pla_point[0][i] = vertex_curves[1].curve->poles[i];
       pla_point[1][i] = vertex_curves[1].curve->poles[3 *
                         (vertex_curves[1].curve->num_poles - 1)+i];
      }
    }

   if (BSdistptpt(&msg, fs2_point, pla_point[0]) < 
       BSdistptpt(&msg, fs2_point, pla_point[1]))
       OM_BLOCK_MOVE(pla_point[1], end_points[1], sizeof (IGRpoint));
   else
       OM_BLOCK_MOVE(pla_point[0], end_points[1], sizeof (IGRpoint));

   stat_OM = om$send(msg = message EMSsubbs.EMintersect_plane_fillet(&msg,
                           my_env,
                           TRUE,
                           vertex_curves[1].curve,
                           &param[3],                         
                           &my_info[edge_index[1]],
                           FALSE,
                           center_point,
                           num_pair_info,
                           pair_info,
                           NULL,
                           &int_curve,
                           NULL,
                           &vertex_curves[1].edge_id,
                           round_id),
                     senderid = NULL_OBJID,
                     targetid = my_info[edge_index[1]].fillet_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);
  }

 vertex_curves[1].fillet_id = my_info[edge_index[1]].fillet_id;
 vertex_curves[1].curves_surface = my_info[edge_index[1]].fillet_surface;

 end_param[0] = (param[0] <= knot_tol) ? 1.0 : 0.0;
 end_param[1] = param[1];

 end_param[2] = (param[2] <= knot_tol) ? 1.0 : 0.0;
 end_param[3] = param[3];

 if ((param[1] < knot_tol) || (param[1] > 1-knot_tol))
  {
   BSsfeval(my_info[edge_index[0]].fillet_surface, end_param[0],
            end_param[1], 0, (IGRpoint *)end_points[0], &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  }

 if ((param[3] < knot_tol) || (param[3] > 1-knot_tol))
  {
   BSsfeval(my_info[edge_index[1]].fillet_surface, end_param[2],
            end_param[3], 0, (IGRpoint *)end_points[1], &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  }

 BSmkvec (&msg, rel_vector, end_points[0], end_points[1]);

 status = BSprptoncv (&msg, first_curve, end_points[0], &cv_par1,
                      &onCurve);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (! onCurve)
  {
   BSmdstptcv(first_curve, end_points[0], &cv_par1, base_point, &dist1,
              &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  }

 num_par = 1;
 disp_fac = 1.0;

 BScvarrevt(first_curve, &cv_par1, num_par, disp_fac, (dummy *)pts, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 for (i=0; i<3; i++)
      end_vectors[0][i] = pts[3+i] - pts[i];

 status = BSprptoncv (&msg, second_curve, end_points[1], &cv_par2,
                      &onCurve);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (! onCurve)
  {
   BSmdstptcv(second_curve, end_points[1], &cv_par2, base_point, &dist1,
              &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  }

 BScvarrevt(second_curve, &cv_par2, num_par, disp_fac, (dummy *)pts, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 for (i=0; i<3; i++)
      end_vectors[1][i] = pts[3+i] - pts[i];

 if (BSdotp(&msg, rel_vector, end_vectors[0]) < 0)
  {
   for (i=0; i<3; i++)
        end_vectors[0][i] = -end_vectors[0][i];
  }   

 if (BSdotp(&msg, rel_vector, end_vectors[1]) < 0)
  {
   for (i=0; i<3; i++)
        end_vectors[1][i] = -end_vectors[1][i];
  }   

 num_par = 2;

 BSalloccv(4, 4, FALSE, 0, &vertex_curves[2].curve, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 BScbftptswt(num_par, end_points, end_vectors, tst_planar,
             vertex_curves[2].curve, &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 status = BSprptonsf (&msg, my_info[edge_index[0]].surface, end_points[0],
                      &bnd0_param[0], &bnd0_param[1], &onSurf);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

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

 if (! onSurf)
  {
   status = BSmdistptsf (&msg, 
                         surface,
                         end_points[0],
                         &point_on_surf[0],
                         &point_on_surf[1],
                         base_point,
                         &dist2);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   status = BSmdistptsf (&msg, 
                         my_info[edge_index[0]].surface,
                         end_points[0],
                         &bnd0_param[0],
                         &bnd0_param[1],
                         base_point,
                         &dist1);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   if (fabs(dist1) < fabs(dist2)) onSurf = TRUE;

   if (! onSurf)
    {
     bnd0_param[0] = point_on_surf[0];
     bnd0_param[1] = point_on_surf[1];
    }
  }
 
 if (! onSurf)
  {
   stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                           &other_edge),
                     senderid = my_info[edge_index[0]].edge_id,
                     p_chanselect = &to_common_edge);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
  }

 good_id = (onSurf) ? my_info[edge_index[0]].surface_id :
                      my_info[edge_index[0]].comm_surface_id;

 if (BSdistptpt(&msg, fs1_point, fs2_point) > 2 * knot_tol)
  {
   num_entries = 4; 

   BSalloccv(2, 2, FALSE, 0, &vertex_curves[3].curve, &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   vertex_curves[3].curve->order          = 2;
   vertex_curves[3].curve->periodic       = FALSE;
   vertex_curves[3].curve->non_uniform    = FALSE;
   vertex_curves[3].curve->num_poles      = 2;
   vertex_curves[3].curve->num_knots      = 4;
   vertex_curves[3].curve->rational       = FALSE;
   vertex_curves[3].curve->weights        = NULL;
   vertex_curves[3].curve->num_boundaries = 0;
   vertex_curves[3].curve->bdrys          = NULL;
   vertex_curves[3].curve->phy_closed     = FALSE;
   vertex_curves[3].curve->planar         = TRUE;

   vertex_curves[3].curve->knots[0] = 0.0;
   vertex_curves[3].curve->knots[1] = 0.0;
   vertex_curves[3].curve->knots[vertex_curves[3].curve->num_poles]=1;
   vertex_curves[3].curve->knots[vertex_curves[3].curve->num_poles + 1]=1;

   for (i=0; i<3; i++)
        vertex_curves[3].curve->poles[i] = fs1_point[i];
   for (i=3; i<6; i++)
        vertex_curves[3].curve->poles[i] = fs2_point[i-3];

   if (spsf_id != NULL_OBJID)
    {
     stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg,
                              &my_env->md_env.matrix_type,
                              my_env->md_env.matrix, &world, FALSE,
                              &surf_partol.tol),
                        senderid = NULL_OBJID,
                        targetid = spsf_id);
     EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg, EMS_E_SurfaceError, wrapup);

     surf_partol.in_world = TRUE;
     surf_partol.is_valid = TRUE;
     surf_partol.mattyp = &my_env->md_env.matrix_type;
     surf_partol.mat = my_env->md_env.matrix;

     stat_OM = om$send(msg = message EMSsubbs.EMmake_bsedge_loop(&msg,
                             my_env,
                             spsf,
                             vertex_curves[3].curve,
                             &surf_partol,
                             spsf_edge,
                             EMS_VERTEX_BND, FALSE,
                             center_point, &edge_id, round_id),
                       senderid = NULL_OBJID,
                       targetid = spsf_id);
     EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg, EMS_E_SurfaceError, wrapup);

     vertex_curves[3].edge_id = edge_id.objid;
     vertex_curves[3].fillet_id = spsf_id;
     vertex_curves[3].curves_surface = spsf;
     num_edges = 4;
    }
  }
 else
  {
   num_entries = 3;
   vertex_curves[3].curve = NULL;
  }

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
                         my_info[edge_index[0]].surface : surface,
                         vertex_curves[2].curve,
                         &surf_partol,
                         (onSurf) ? 
                         my_info[edge_index[0]].edge_id : other_edge,
                         EMS_VERTEX_BND, FALSE,
                         center_point, &edge_id, round_id),
                   senderid = NULL_OBJID,
                   targetid = good_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 vertex_curves[2].edge_id = edge_id.objid;
 vertex_curves[2].fillet_id = good_id;
 vertex_curves[2].curves_surface = (onSurf) ?
                                    my_info[edge_index[0]].surface :
                                    surface;

 curves = (struct IGRbsp_curve **) om$malloc(size = num_entries *
                                   sizeof (struct IGRbsp_curve *));
 surfaces = (struct IGRbsp_surface **) om$malloc(size = num_entries *
                                   sizeof (struct IGRbsp_surface *));

 for (i=0; i<num_entries; i++)
      curves[i] = vertex_curves[i].curve;

 surfaces[0] = my_info[edge_index[0]].fillet_surface;
 surfaces[1] = my_info[edge_index[1]].fillet_surface;
 surfaces[2] = (onSurf) ? my_info[edge_index[0]].surface : surface;
 surfaces[3] = (spsf_id == NULL_OBJID) ? NULL : spsf;

 if (! surfaces[2]->planar)
  {
   surf_GRid.objid = good_id;
   surf_GRid.osnum = my_env->md_id.osnum;

   proj_curve.weights = NULL;
   proj_curve.poles = NULL;
   proj_curve.knots = NULL;
   proj_curve.bdrys = NULL;

   stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg,
                           &my_env->md_env, &surf_GRid, surfaces[2], 0,
                           OM_K_MAXINT, FALSE, NULL, &proj_curve),
                     senderid = NULL_OBJID,   
                     targetid = edge_id.objid);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   if (BSdistptpts(&msg, &proj_curve.poles[0], end_points[0]) <
       BSdistptpts(&msg, &proj_curve.poles[0], end_points[1]))
    {
     OM_BLOCK_MOVE(end_points[0],&proj_curve.poles[0], sizeof (IGRpoint));
     OM_BLOCK_MOVE(end_points[1],
                   &proj_curve.poles[3*(proj_curve.num_poles-1)],
                   sizeof (IGRpoint));
    }
   else
    {
     OM_BLOCK_MOVE(end_points[1],&proj_curve.poles[0], sizeof (IGRpoint));
     OM_BLOCK_MOVE(end_points[0],
                   &proj_curve.poles[3*(proj_curve.num_poles-1)],
                   sizeof (IGRpoint));
    }

   curves[2] = &proj_curve;
   vertex_curves[2].curve = &proj_curve;   
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

 if (BSdistptpt(&msg, end_points[0], end_points[1]) > 2*chdht_tol)
  {
   /* fix the existing edge boundaries ---- FIRST */

   stat_OM = EMget_uedge_id(&msg, my_env, end_param[0], knot_tol,
                            my_info[edge_index[0]].fillet_id,
                            &to_fix_edge);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);

   stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, uvbegpt,
                           uvendpt, NULL, NULL, NULL),
                     senderid = NULL_OBJID,
                     targetid = to_fix_edge);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

   if(EM2ddistptpts(bnd0_param,uvbegpt) <
      EM2ddistptpts(bnd0_param,uvendpt))
      truncate_end = FALSE;
   else
      truncate_end = TRUE;
 
   stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, uvbegpt,
                           uvendpt, NULL, NULL, NULL),
                     senderid = NULL_OBJID,
                     targetid = vertex_curves[2].edge_id);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

   if(EM2ddistptpts(bnd0_param,uvbegpt) <
      EM2ddistptpts(bnd0_param,uvendpt))
    {
     inters_data.point[0] = uvbegpt[0]; 
     inters_data.point[1] = uvbegpt[1];
    }
   else
    {
     inters_data.point[0] = uvendpt[0]; 
     inters_data.point[1] = uvendpt[1];
    }

   inters_data.intloc = EMScvint_middle;
   inters_data.edgeid = to_fix_edge;
   inters_data.info = NULL;
   inters_data.next = NULL;

   stat_OM = om$send (msg = message EMSedge.EMpratpt(&msg,
                            inters_data.point, 1,
                            &inters_data.edgepar, &onCurve, NULL,
                            &surf_partol),
                      senderid = NULL_OBJID,
                      targetid = to_fix_edge);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

   stat_OM = om$send (msg = message EMSedge.EMalter_geometry (&msg,
                            &inters_data, truncate_end),
                      senderid = NULL_OBJID,
                      targetid = to_fix_edge);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

   /* fix the existing edge boundaries ---- SECOND */

   stat_OM = EMget_uedge_id(&msg, my_env, end_param[2], knot_tol,
                            my_info[edge_index[1]].fillet_id,
                            &to_fix_edge);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);

   stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, uvbegpt,
                           uvendpt, NULL, NULL, NULL),
                     senderid = NULL_OBJID,
                     targetid = to_fix_edge);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

   status = BSprptonsf (&msg, surfaces[2], end_points[1], &bnd0_param[0],
                        &bnd0_param[1], &onSurf);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   if(EM2ddistptpts(bnd0_param,uvbegpt) <
      EM2ddistptpts(bnd0_param,uvendpt))
      truncate_end = FALSE;
   else
      truncate_end = TRUE;
 
   stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, uvbegpt,
                           uvendpt, NULL, NULL, NULL),
                     senderid = NULL_OBJID,
                     targetid = vertex_curves[2].edge_id);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

   if(EM2ddistptpts(bnd0_param,uvbegpt) <
      EM2ddistptpts(bnd0_param,uvendpt))
    {
     inters_data.point[0] = uvbegpt[0]; 
     inters_data.point[1] = uvbegpt[1];
    }
   else
    {
     inters_data.point[0] = uvendpt[0]; 
     inters_data.point[1] = uvendpt[1];
    }

   inters_data.intloc = EMScvint_middle;
   inters_data.edgeid = to_fix_edge;
   inters_data.info = NULL;
   inters_data.next = NULL;

   stat_OM = om$send (msg = message EMSedge.EMpratpt(&msg,
                            inters_data.point, 1,
                            &inters_data.edgepar, &onCurve, NULL,
                            &surf_partol),
                      senderid = NULL_OBJID,
                      targetid = to_fix_edge);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

   stat_OM = om$send (msg = message EMSedge.EMalter_geometry (&msg,
                            &inters_data, truncate_end),
                      senderid = NULL_OBJID,
                      targetid = to_fix_edge);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);
  }

 if (vertex_curves[0].edge_id == NULL_OBJID)
  {
   IGRlong  EMget_vedge_id();

   stat_OM = EMget_vedge_id (&msg, my_env, param[1], knot_tol,
                             my_info[edge_index[0]].fillet_id,
                             &vertex_curves[0].edge_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);
  }

 if (vertex_curves[1].edge_id == NULL_OBJID)
  {
   IGRlong  EMget_vedge_id();

   stat_OM = EMget_vedge_id (&msg, my_env, param[3], knot_tol,
                             my_info[edge_index[1]].fillet_id,
                             &vertex_curves[1].edge_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);
  }

 small_curve = FALSE;
 if (BSdistptpt(&msg,
          &curves[2][0].poles[0],
          &curves[2][0].poles[(curves[2][0].num_poles-1)*3]) <= chdht_tol)
  {
   save_cht = chdht_tol;
   small_curve = TRUE;
   BSchangepar(&msg, BSTOLCHRDHT, bas_tol);
  }

 stat_OM = EMfill_pair_info(&msg, ss_edges, swept_surface, *swept_srf_id,
                            num_pair_info, pair_info, vertex_curves,
                            num_edges);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);

 if (small_curve)
  {
   BSchangepar(&msg, BSTOLCHRDHT, save_cht);
  }

 my_info[edge_index[0]].ends_free = FALSE;
 my_info[edge_index[1]].ends_free = FALSE;

wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "GRvg.EMdeg_swept_surface");

if (vertex_curves[0].curve) BSfreecv(&msg, vertex_curves[0].curve);
if (vertex_curves[1].curve) BSfreecv(&msg, vertex_curves[1].curve);
if (vertex_curves[3].curve) BSfreecv(&msg, vertex_curves[3].curve);

 if (curves) om$dealloc(ptr = curves);
 if (surfaces) om$dealloc(ptr = surfaces);

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

 return (stat_OM);

}

IGRlong EMget_vedge_id (EMmsg, my_env, param, knot_tol, fillet_id,
                               edge_id)

IGRlong         *EMmsg;
struct GRmd_env *my_env;
IGRdouble       param,
                knot_tol;
GRobjid         fillet_id,
                *edge_id;

{
 IGRlong     stat_OM, msg;
 IGRshort    edge_location;
 struct GRid *edges = NULL;
 IGRint      num_edges = 0,
             buf_size = 0;
 
/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 edges = NULL;

 stat_OM = om$send(msg = message EMSsubbs.EMget_edges(&msg, MAXINT,
                         EMS_OPT_CONNECTABLE, my_env, &edges, &buf_size,
                         &num_edges),
                   senderid = NULL_OBJID,
                   targetid = fillet_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError,wrapup);

 if (! num_edges)
  {
   edges = NULL;
   num_edges = 0,
   buf_size = 0;

   stat_OM = om$send(msg = message EMSsubbs.EMget_edges(&msg, MAXINT,
                           EMS_OPT_SEAM, my_env, &edges, &buf_size,
                           &num_edges),
                     senderid = NULL_OBJID,
                     targetid = fillet_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError,wrapup);

   if (num_edges >= 2)
    {
     stat_OM = om$send(msg = message EMSedge.EMget_location(&msg,
                              &edge_location),
                       senderid = NULL_OBJID,
                       targetid = edges[0].objid);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

     if (((param <= knot_tol) && (edge_location == 3)) ||
         ((param >= 1-knot_tol) && (edge_location == 1)))
          *edge_id = edges[0].objid;
     else
          *edge_id = edges[1].objid;
    }
   else
    {
     *EMmsg = EMS_I_InvalidArg;
     goto wrapup;
    }
  }
 else
  {
   if (num_edges > 2) 
    {
     *EMmsg = EMS_I_InvalidArg;
     goto wrapup;
    }
  
   *edge_id = (param <= knot_tol) ? edges[1].objid : edges[0].objid;
  }

 wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "GRvg.EMget_vedge_id");
 return (stat_OM);
}

end implementation GRvg;
