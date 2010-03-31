/* ###################   APOGEE COMPILED   ################## */
class implementation GRvg;

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsdef.h"
#include "emsdattyp.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "emsmacros.h"
#include "emserr.h"
#include "EMSopt.h"
#include "EMSmsgdef.h"
#include "OMmacros.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSlm.h"
#include "EMSlmdef.h"
#include "emssfint.h"
#include "EMSprop.h"
#include "bssfarrevn.h"
#include "bsprptonsf.h"
#include "bsprptoncv.h"
#include "bspolyxtdst.h"
#include "bspartofcv.h"
#include "bsnorkts.h"
#include "bsmodshpcvg.h"
#include "bsmdstptcv.h"
#include "bsmdistptsf.h"
#include "bsmdistcvcv.h"
#include "bsfreecv.h"
#include "bsdotp.h"
#include "bsdistptpts.h"
#include "bsdistptpt.h"
#include "bscvcv_int.h"
#include "bsconstprcv.h"
#include "bschgcvewts.h"
#include "bsalloccv.h"
#include "bs2sfb4cvtn.h"

%safe
static void		 EMfreecv();
%endsafe

extern OMuword OPP_EMSgenbs_class_id;
extern GRclassid OPP_EMSbsedge_class_id;

from EMSsubbs import EMpartolbasis;
from EMSsubbs import EMmake_bsedge_loop;
from EMSsubbs import EMintersect_plane_fillet;
from EMSsurface import EMmk_nat_bdry;
from EMSedge import EMget_bcxyz_geom,
                    EMendpts,
                    EMpratpt,
                    EMextend_geom,
                    EMalter_geometry;
from EMSboundary import EMget_objid;
from EMSdpr import EMget_dpr_props;

/**
DLB 10/23/91	pass short option to BSconstprcv not long - SUN problem.
SM  24-Feb-92   The curve memory was being freed quite liberally even
	        if it was input and not allocated here. Added a static
	        function EMfreecv() which basically calls BSfreecv after
	        making sure that the curve can be freed. Replaced all calls
	        to BSfreecv in the main function with EMfreecv.        
DLB 05/27/92    put sf on inx 0 or 1 of dpr depending on if un uneval mode.
Sudha7/08/93    Modified for BSprototypes ansification
**/


IGRlong EMtwo_edge_vertex_surface (EMmsg,
                                   my_env,
                                   construct_list,
                                   other_edge,
                                   other_edge_surf,
                                   my_info,
                                   num_pair_info,
                                   pair_info,
                                   edge_index,
                                   vtx_point,
                                   round_id)

IGRlong 	             *EMmsg;
struct GRmd_env          *my_env;
struct GRvg_construct    *construct_list;
GRobjid                  other_edge, other_edge_surf;
struct EMedge_round_info *my_info;
IGRint                   *num_pair_info;
struct EMedge_con_info   *pair_info;
IGRint                   *edge_index;
IGRpoint                 vtx_point;
GRobjid                  *round_id;

{
 
 IGRlong                 stat_OM, msg;
 IGRlong                 num_crv, size, srf_size;
 IGRlong                 max_poles;
 IGRshort                order, s_option;
 IGRushort               option1;
 GRspacenum              md_osnum;
 IGRint                  i, inx;
 IGRint                  num_int, num_entries;
 IGRint                  option;
 IGRdouble               uvbegpt[2], uvendpt[2], c_parm[2], to_move_par;
 IGRdouble               cv_par1, cv_par2, cv_par3, cv_par4;
 IGRdouble               bnd0_param[2], bnd1_param[2], knot_tol;
 IGRdouble               *par1=NULL, *par2=NULL,
                         *par3=NULL, *par4=NULL,
                         *over1=NULL, *over2=NULL,
                         *end_pts=NULL;
 IGRdouble               *int_pts=NULL;
 IGRdouble               mid_par, chk_dist, dist;
 IGRboolean              status, inters_found,
                         truncate_end,
                         rational,
                         world,
                         tst_planar,
                         first_info_valid, second_info_valid,
                         onSurf, onCurve;
 IGRvector               norm_vec, blend_norm;
 IGRpoint                common_point;
 IGRpoint                first_point, second_point;
 IGRpoint                base_point;
 IGRpoint                *cv1_points, *cv2_points,
                         *cv3_points, *cv4_points;
 IGRpoint                end_point_curve1, end_point_curve2;
 IGRpoint                avg_point, pla_point[2];
 IGRdouble               point_on_surf[2];
 GRobjid                 first_srf_id, second_srf_id,
                         bs0_edges[4], bs1_edges[4],
                         blend_srf0_id, blend_srf1_id, comm_edge;
 GRobjid                 to_fix_edge;
 GRclassid               classid1, classid2;
 struct GRid             temp_id, surf_GRid;
 struct GRid             edge_id;
 struct EMSsfintedpar    inters_data;
 struct EMvertex_curves  vertex_curves[4];
 struct IGRbsp_curve     edge_geom, *ext_curve1, *ext_curve2;
 struct IGRbsp_curve     *mod_c1, *mod_c2;
 struct IGRbsp_curve     *first_curve, *second_curve;
 struct IGRbsp_curve     *part_curve0, *part_curve1;
 struct IGRbsp_curve     **curves;
 struct IGRbsp_curve     *loc_curve0, *loc_curve1;
 struct IGRbsp_surface   *blend_surface[2];
 struct IGRbsp_surface   **surfaces;
 struct EMSpartolbasis   surf_partol, other_surf_partol;
 OM_S_CHANSELECT         to_common_edge;

/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 world = TRUE;
 inters_found = TRUE;
 option = 0;
 tst_planar = TRUE;
 inx = 0;

 for (i=0; i<4; i++)
  {
   vertex_curves[i].curve = NULL;
   vertex_curves[i].curves_surface = NULL;
  }

 first_curve = NULL;
 second_curve = NULL;
 mod_c1 = NULL;
 mod_c2 = NULL;
 ext_curve1 = NULL;
 ext_curve2 = NULL;
 curves = NULL; 
 surfaces = NULL;
 loc_curve0 = NULL;
 loc_curve1 = NULL;
 part_curve0 = NULL;
 part_curve1 = NULL;
 blend_surface[0] = NULL;
 blend_surface[1] = NULL;

 par1 = par2 = NULL;
 par3 = par4 = NULL;
 cv1_points = cv2_points = NULL;
 cv3_points = cv4_points = NULL;

 md_osnum = my_env->md_id.osnum;
 temp_id.objid = *round_id;
 temp_id.osnum = md_osnum;
 size = 3 * sizeof (IGRdouble);

 BSEXTRACTPAR(&msg, BSTOLKNOT, knot_tol);

 stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
 if (! (1 & stat_OM)) goto wrapup;

 status = BScvcv_int(&msg, my_info[edge_index[0]].curve,
                   my_info[edge_index[1]].curve, &num_int, &int_pts,
                   &par1, &par2, &num_crv, &end_pts, &over1, &over2);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (num_int)
  {
   first_curve = my_info[edge_index[0]].comm_curve;
   second_curve = my_info[edge_index[1]].comm_curve;
   first_srf_id = my_info[edge_index[0]].comm_surface_id;
   second_srf_id = my_info[edge_index[1]].comm_surface_id;
   first_info_valid = second_info_valid = FALSE;
   goto proceed;
  }

 status = BScvcv_int(&msg, my_info[edge_index[0]].curve,
                   my_info[edge_index[1]].comm_curve, &num_int, &int_pts,
                   &par1, &par2, &num_crv, &end_pts, &over1, &over2);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (num_int)
  {
   first_curve = my_info[edge_index[0]].comm_curve;
   second_curve = my_info[edge_index[1]].curve;
   first_srf_id = my_info[edge_index[0]].comm_surface_id;
   second_srf_id = my_info[edge_index[1]].surface_id;
   first_info_valid = FALSE; second_info_valid = TRUE;

   goto proceed;
  }

 status = BScvcv_int(&msg, my_info[edge_index[0]].comm_curve,
                   my_info[edge_index[1]].curve, &num_int, &int_pts,
                   &par1, &par2, &num_crv, &end_pts, &over1, &over2);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (num_int)
  {
   first_curve = my_info[edge_index[0]].curve;
   second_curve = my_info[edge_index[1]].comm_curve;
   first_srf_id = my_info[edge_index[0]].surface_id;
   second_srf_id = my_info[edge_index[1]].comm_surface_id;
   first_info_valid = TRUE; second_info_valid = FALSE;

   goto proceed;
  }

 status = BScvcv_int(&msg, my_info[edge_index[0]].comm_curve,
                   my_info[edge_index[1]].comm_curve, &num_int, &int_pts,
                   &par1, &par2, &num_crv, &end_pts, &over1, &over2);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if ((num_int) && (my_info[edge_index[0]].surface_id ==
                   my_info[edge_index[1]].surface_id))
     num_int = 0;

 if (num_int)
  {
   first_curve = my_info[edge_index[0]].curve;
   second_curve = my_info[edge_index[1]].curve;
   first_srf_id = my_info[edge_index[0]].surface_id;
   second_srf_id = my_info[edge_index[1]].surface_id;
   first_info_valid = second_info_valid = TRUE;

   goto proceed;
  }
 else
  {
   inters_found = FALSE;
   BSmdistcvcv(my_info[edge_index[0]].curve,
               my_info[edge_index[1]].curve,
               &num_int,
               &par1, &par2,
               (IGRpoint **)&int_pts,
               &cv1_points,
               &dist,
               &msg);
   EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   first_curve = my_info[edge_index[0]].comm_curve;
   second_curve = my_info[edge_index[1]].comm_curve;
   first_srf_id = my_info[edge_index[0]].comm_surface_id;
   second_srf_id = my_info[edge_index[1]].comm_surface_id;
   first_info_valid = second_info_valid = FALSE;
  }

 proceed:

 if (num_int > 1)
  {
   chk_dist = MAXFLOAT;
   for (i=0; i<num_int; i++)
    {
     dist =  BSdistptpt (&msg, &int_pts[3*i], vtx_point);
     if (dist < chk_dist)
      {
       chk_dist = dist;
       inx = 3*i;
      }     
    }   
  }

 OM_BLOCK_MOVE (&int_pts[inx], common_point, sizeof (IGRpoint));

 if (first_curve->rational)
  {
   if ((first_curve->weights[0] != 1.0) ||
       (first_curve->weights[first_curve->num_poles - 1] != 1.0))
    {
     BSalloccv (first_curve->order, first_curve->num_poles,
                first_curve->rational, NULL, &mod_c1, &msg);
     EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     BSchgcvewts (first_curve, mod_c1, &msg);
     EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

     if (first_curve) /*BSfreecv(&msg, first_curve);*/
       EMfreecv(&msg, my_info, edge_index, first_curve);
     first_curve = mod_c1;
    }
  }

 if (second_curve->rational)
  {
   if ((second_curve->weights[0] != 1.0) ||
       (second_curve->weights[second_curve->num_poles - 1] != 1.0))
    {
     BSalloccv (second_curve->order, second_curve->num_poles,
                second_curve->rational, NULL, &mod_c2, &msg);
     EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     BSchgcvewts (second_curve, mod_c2, &msg);
     EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

     if (second_curve) /* BSfreecv(&msg, second_curve); */
      EMfreecv(&msg, my_info, edge_index, second_curve);
     second_curve = mod_c2;
    }
  }

 /*      FIRST CURVE     */

 status = BSprptonsf (&msg, my_info[edge_index[0]].fillet_surface,
                    common_point,  &point_on_surf[0], &point_on_surf[1],
                    &onSurf);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (! onSurf)
  {
   status = BSmdistptsf (&msg, 
                         my_info[edge_index[0]].fillet_surface,
                         common_point,
                         &point_on_surf[0],
                         &point_on_surf[1],
                         base_point,
                         &dist);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  }

 bnd0_param[0] = (point_on_surf[0] <= knot_tol) ? 1 : 0;
 bnd0_param[1] = point_on_surf[1];

 BSalloccv (my_info[edge_index[0]].fillet_surface->u_order,
            my_info[edge_index[0]].fillet_surface->u_num_poles,
            my_info[edge_index[0]].fillet_surface->rational,
            NULL, &vertex_curves[0].curve, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 s_option = option;  /*DLB 10/23/91	short option not int option - SUN*/
 BSconstprcv (&msg, my_info[edge_index[0]].fillet_surface, &s_option,
              &point_on_surf[1], &tst_planar, vertex_curves[0].curve);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 point_on_surf[0] = 0.5;

 BSsfarrevn (&msg, my_info[edge_index[0]].fillet_surface, 1,
             &point_on_surf[0],1,&point_on_surf[1], base_point, norm_vec);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (! (my_info[edge_index[0]].fillet_surface->pos_orient))
  {
   for (i=0; i<3; i++)
        norm_vec[i] = -norm_vec[i];
  }

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

 if (BSdistptpts(&msg, common_point, pla_point[0]) <=
     BSdistptpts(&msg, common_point, pla_point[1]))
     OM_BLOCK_MOVE (pla_point[1], first_point, size);
 else
     OM_BLOCK_MOVE (pla_point[0], first_point, size);

 stat_OM = om$send(msg = message EMSsubbs.EMintersect_plane_fillet(&msg,
                         my_env,
                         TRUE,
                         vertex_curves[0].curve,
                         &point_on_surf[1],                         
                         &my_info[edge_index[0]],
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
                   targetid = my_info[edge_index[0]].fillet_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 vertex_curves[0].fillet_id = my_info[edge_index[0]].fillet_id;
 vertex_curves[0].curves_surface = my_info[edge_index[0]].fillet_surface;

 /*      SECOND CURVE     */

 if (! inters_found)
  {
   OM_BLOCK_MOVE (&cv1_points[0][0], common_point, sizeof (IGRpoint));
   cv1_points = NULL;
  }

 status = BSprptonsf (&msg, my_info[edge_index[1]].fillet_surface,
                    common_point,  &point_on_surf[0], &point_on_surf[1],
                    &onSurf);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (! onSurf)
  {
   status = BSmdistptsf (&msg, 
                         my_info[edge_index[1]].fillet_surface,
                         common_point,
                         &point_on_surf[0],
                         &point_on_surf[1],
                         base_point,
                         &dist);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  }

 bnd1_param[0] = (point_on_surf[0] <= knot_tol) ? 1 : 0;
 bnd1_param[1] = point_on_surf[1];
 
 BSalloccv (my_info[edge_index[1]].fillet_surface->u_order,
            my_info[edge_index[1]].fillet_surface->u_num_poles,
            my_info[edge_index[1]].fillet_surface->rational,
            NULL, &vertex_curves[1].curve, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 s_option = option;  /*DLB 10/23/91	short option not int option - SUN*/
 BSconstprcv (&msg, my_info[edge_index[1]].fillet_surface,
              &s_option, &point_on_surf[1], &tst_planar,
              vertex_curves[1].curve);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

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

 if (BSdistptpts(&msg, common_point, pla_point[0]) <=
     BSdistptpts(&msg, common_point, pla_point[1]))
     OM_BLOCK_MOVE (pla_point[1], second_point, size);
 else
     OM_BLOCK_MOVE (pla_point[0], second_point, size);

 stat_OM = om$send(msg = message EMSsubbs.EMintersect_plane_fillet(&msg,
                         my_env,
                         TRUE,
                         vertex_curves[1].curve,
                         &point_on_surf[1],                         
                         &my_info[edge_index[1]],
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
                   targetid = my_info[edge_index[1]].fillet_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 vertex_curves[1].fillet_id = my_info[edge_index[1]].fillet_id;
 vertex_curves[1].curves_surface = my_info[edge_index[1]].fillet_surface;

 if (! inters_found)
  {
   status = BSprptoncv (&msg, loc_curve1, common_point, &to_move_par,
                        &onCurve);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   vertex_curves[1].curve = NULL;
   BSmodshpcvg (loc_curve1, to_move_par, &int_pts[inx], FALSE, FALSE,
                &vertex_curves[1].curve, &msg);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  }

 status = BSprptoncv (&msg, first_curve, first_point, &cv_par1, &onCurve);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
 BSmdstptcv(first_curve, second_point, &cv_par2, base_point, &dist, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
 status = BSprptoncv(&msg,second_curve, second_point, &cv_par3, &onCurve);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
 BSmdstptcv(second_curve, first_point, &cv_par4, base_point, &dist, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (cv_par2 > cv_par1)
     OM_BLOCK_MOVE (&first_curve->poles[(first_curve->num_poles-1)*3],
                    end_point_curve1, size);
 else
     OM_BLOCK_MOVE (&first_curve->poles[0], end_point_curve1, size);

 if (cv_par4 > cv_par3)
     OM_BLOCK_MOVE (&second_curve->poles[(second_curve->num_poles-1)*3],
                    end_point_curve2, size);
 else
     OM_BLOCK_MOVE (&second_curve->poles[0], end_point_curve2, size);

 order = first_curve->order;
 max_poles = first_curve->num_poles + first_curve->order -1;
 rational = (first_curve->rational) ? TRUE : FALSE;
 BSalloccv (order, max_poles, rational, 0, &ext_curve1, &msg);
 dist = 2.0 * my_info[edge_index[0]].radius;

 if (BSdistptpt(&msg, &first_curve->poles[0],
     &first_curve->poles[(first_curve->num_poles-1)*3]) <= 2*dist)
     dist = dist/20;

 BSpolyxtdst (first_curve, end_point_curve1, dist, ext_curve1, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 status = BSnorkts(&msg, &ext_curve1->order, &ext_curve1->num_poles,
                 ext_curve1->knots);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 order = second_curve->order;
 max_poles = second_curve->num_poles + second_curve->order -1;
 rational = (second_curve->rational) ? TRUE : FALSE;
 BSalloccv (order, max_poles, rational, 0, &ext_curve2, &msg);
 dist = 2.0 * my_info[edge_index[1]].radius;

 if (BSdistptpt(&msg, &second_curve->poles[0],
     &second_curve->poles[(second_curve->num_poles-1)*3]) <= 2*dist)
     dist = dist/20;

 BSpolyxtdst (second_curve, end_point_curve2, dist, ext_curve2, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 status = BSnorkts(&msg, &ext_curve2->order, &ext_curve2->num_poles,
                 ext_curve2->knots);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 surf_GRid.objid = other_edge_surf;
 surf_GRid.osnum = OM_Gw_current_OS;

 edge_geom.weights = NULL;
 edge_geom.poles = NULL;
 edge_geom.knots = NULL;
 edge_geom.bdrys = NULL;

 stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg,
                         &my_env->md_env, &surf_GRid, NULL, 0,
                         OM_K_MAXINT, FALSE, NULL, &edge_geom),
                   senderid = NULL_OBJID,
                   targetid = other_edge);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 BSmdistcvcv(ext_curve1, &edge_geom, &num_int, &par1, &par2, &cv1_points,
             &cv2_points, &dist, &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
 BSmdistcvcv(ext_curve2, &edge_geom, &num_int, &par3, &par4, &cv3_points,
             &cv4_points, &dist, &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 for (i=0; i<3; i++)
  avg_point[i] = (cv2_points[0][i] + cv4_points[0][i]) / 2;

 status = BSprptoncv (&msg, ext_curve1, first_point, &cv_par1, &onCurve);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 BSalloccv (ext_curve1->order, 
            ext_curve1->num_poles + 2 * ext_curve1->order - 1, 
            ext_curve1->rational, 0, &part_curve0, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 mid_par = (par1[0] + cv_par1)/2;

 status = BSpartofcv (&msg, ext_curve1, par1[0], mid_par, cv_par1,
                    part_curve0);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 status = BSprptoncv(&msg,part_curve0, first_point,&to_move_par,&onCurve);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 to_move_par = (to_move_par <= 0.5) ? 1 : 0;

 BSmodshpcvg (part_curve0, to_move_par, avg_point, FALSE, FALSE,
              &vertex_curves[2].curve, &msg);
 if (msg == BSDGENRAT)
  {
   msg = BSSUCC;
   vertex_curves[2].curve = part_curve0;
  }
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 status = BSprptoncv (&msg, ext_curve2, second_point, &cv_par2, &onCurve);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 BSalloccv (ext_curve2->order, 
            ext_curve2->num_poles + 2 * ext_curve2->order - 1, 
            ext_curve2->rational, 0, &part_curve1, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 mid_par = (par3[0] + cv_par2)/2;

 status = BSpartofcv (&msg, ext_curve2, par3[0], mid_par, cv_par2,
                    part_curve1);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 status = BSprptoncv(&msg,part_curve1,second_point,&to_move_par,&onCurve);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 to_move_par = (to_move_par <= 0.5) ? 1 : 0;

 BSmodshpcvg (part_curve1, to_move_par, avg_point, FALSE, FALSE,
              &vertex_curves[3].curve, &msg);
 if (msg == BSDGENRAT)
  {
   msg = BSSUCC;
   vertex_curves[3].curve = part_curve1;
  }
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 stat_OM = om$send(msg = message GRvg.GRgetsize(&msg,
                         &my_env->md_env.matrix_type,
                         my_env->md_env.matrix,
                         &srf_size),
                   senderid = NULL_OBJID,
                   targetid = first_srf_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
             
 vertex_curves[2].curves_surface = (struct IGRbsp_surface *) 
                                    om$malloc(size =(OMuint) srf_size);
 EMerr_hndlr(! vertex_curves[2].curves_surface, *EMmsg,
             EMS_E_NoDynamicMemory, wrapup);
  
 stat_OM = om$send(msg = message GRvg.GRgetgeom(&msg,
                         &my_env->md_env.matrix_type,
                         my_env->md_env.matrix,
                         (IGRchar *)vertex_curves[2].curves_surface),
                   senderid = NULL_OBJID,
                   targetid = first_srf_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

 stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg,
                          &my_env->md_env.matrix_type,
                          my_env->md_env.matrix, &world, FALSE,
                          &surf_partol.tol),
                    senderid = NULL_OBJID,
                    targetid = first_srf_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 surf_partol.in_world = TRUE;
 surf_partol.is_valid = TRUE;
 surf_partol.mattyp = &my_env->md_env.matrix_type;
 surf_partol.mat = my_env->md_env.matrix;

 if (! first_info_valid)
  {
   stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                           &comm_edge),
                     senderid = my_info[edge_index[0]].edge_id,
                     p_chanselect = &to_common_edge);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
  }

 stat_OM = om$send(msg = message EMSsubbs.EMmake_bsedge_loop(&msg,my_env,
                         vertex_curves[2].curves_surface,
                         vertex_curves[2].curve, &surf_partol,
                         (first_info_valid) ? 
                         my_info[edge_index[0]].edge_id : comm_edge,
                         EMS_EDGE_BND, FALSE, vtx_point, &edge_id,
                         round_id),
                   senderid = NULL_OBJID,
                   targetid = first_srf_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 vertex_curves[2].edge_id = edge_id.objid;
 vertex_curves[2].fillet_id = first_srf_id;

 stat_OM = om$send(msg = message GRvg.GRgetsize(&msg,
                         &my_env->md_env.matrix_type,
                         my_env->md_env.matrix,
                         &srf_size),
                   senderid = NULL_OBJID,
                   targetid = second_srf_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
             
 vertex_curves[3].curves_surface = (struct IGRbsp_surface *) 
                                    om$malloc(size =(OMuint) srf_size);
 EMerr_hndlr(! vertex_curves[3].curves_surface, *EMmsg,
             EMS_E_NoDynamicMemory, wrapup);
  
 stat_OM = om$send(msg = message GRvg.GRgetgeom(&msg,
                         &my_env->md_env.matrix_type,
                         my_env->md_env.matrix,
                         (IGRchar *)vertex_curves[3].curves_surface),
                   senderid = NULL_OBJID,
                   targetid = second_srf_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

 stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg,
                          &my_env->md_env.matrix_type,
                          my_env->md_env.matrix, &world, FALSE,
                          &other_surf_partol.tol),
                    senderid = NULL_OBJID,
                    targetid = second_srf_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 other_surf_partol.in_world = TRUE;
 other_surf_partol.is_valid = TRUE;
 other_surf_partol.mattyp = &my_env->md_env.matrix_type;
 other_surf_partol.mat = my_env->md_env.matrix;

 if (! second_info_valid)
  {
   stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                           &comm_edge),
                     senderid = my_info[edge_index[1]].edge_id,
                     p_chanselect = &to_common_edge);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
  }

 stat_OM = om$send(msg = message EMSsubbs.EMmake_bsedge_loop(&msg,my_env,
                         vertex_curves[3].curves_surface,
                         vertex_curves[3].curve, &other_surf_partol,
                         (second_info_valid) ?
                         my_info[edge_index[1]].edge_id : comm_edge,
                         EMS_EDGE_BND,FALSE,vtx_point,&edge_id,round_id),
                   senderid = NULL_OBJID,
                   targetid = second_srf_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 vertex_curves[3].edge_id = edge_id.objid;
 vertex_curves[3].fillet_id = second_srf_id;

 num_entries = 4;
 curves = (struct IGRbsp_curve **) om$malloc(size = num_entries *
                                   sizeof (struct IGRbsp_curve *));
 surfaces = (struct IGRbsp_surface **) om$malloc(size = num_entries *
                                   sizeof (struct IGRbsp_surface *));

 for (i=0; i<num_entries; i++)
  {
   curves[i] = vertex_curves[i].curve;
   surfaces[i] = vertex_curves[i].curves_surface;
  }

 BS2sfb4cvtn(curves, surfaces, blend_surface, &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 point_on_surf[0] = point_on_surf[1] = 0.5;

 for (i=0; i<2; i++)
  {
   BSsfarrevn (&msg, blend_surface[i], 1, &point_on_surf[0], 1,
               &point_on_surf[1], base_point, blend_norm);
   EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

   if (BSdotp(&msg, norm_vec, blend_norm) > 0)
       blend_surface[i]->pos_orient = TRUE;
   else
       blend_surface[i]->pos_orient = FALSE;
  }
 construct_list->geometry = (IGRchar *) blend_surface[0];

 stat_OM = om$construct(classid = OPP_EMSgenbs_class_id,
                        obj_osnum = NULL,
                        osnum = md_osnum,
                        p_objid = &blend_srf0_id,
                        msg = message GRgraphics.GRconstruct(
                        construct_list));
 EMerr_hndlr(! (1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

 /* construct the natural boundary for the swept surface */

 stat_OM  = om$send (msg = message EMSsurface.EMmk_nat_bdry(&msg,
                           &my_env->md_env, bs0_edges),
                     senderid = NULL_OBJID,
                     targetid = blend_srf0_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 construct_list->geometry = (IGRchar *) blend_surface[1];

 stat_OM = om$construct(classid = OPP_EMSgenbs_class_id,
                        obj_osnum = NULL,
                        osnum = md_osnum,
                        p_objid = &blend_srf1_id,
                        msg = message GRgraphics.GRconstruct(
                        construct_list));
 EMerr_hndlr(! (1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

 /* construct the natural boundary for the swept surface */

 stat_OM  = om$send (msg = message EMSsurface.EMmk_nat_bdry(&msg,
                           &my_env->md_env, bs1_edges),
                     senderid = NULL_OBJID,
                     targetid = blend_srf1_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);

 {
   /*Get the props of the round.  If UNEVAL'd then put on index 1 & 2 else
    * index 0 & 1.
    */
   IGRushort dpr_props;

   stat_OM = om$send(msg = message EMSdpr.EMget_dpr_props(&msg, &dpr_props),
                   senderid = NULL_OBJID,
                   targetid = temp_id.objid,
                   targetos = temp_id.osnum); 
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);   

   if (dpr_props & EMS_UNEVAL_STATE) i = 1;
   else i = 0;
 }

 stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg,
                          &temp_id, (IGRlong *)&i),
                    senderid = NULL_OBJID,
                    targetid = blend_srf0_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

 i++;
 stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg,
                          &temp_id, (IGRlong *)&i),
                    senderid = NULL_OBJID,
                    targetid = blend_srf1_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

 /* fix the existing edge boundaries ---- FIRST */

 stat_OM = EMget_uedge_id(&msg, my_env, bnd0_param[0], knot_tol,
                          my_info[edge_index[0]].fillet_id, &to_fix_edge);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);

 stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, uvbegpt, uvendpt,
                         NULL, NULL, NULL),
                   senderid = NULL_OBJID,
                   targetid = to_fix_edge);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

 status = BSprptonsf (&msg, vertex_curves[2].curves_surface, first_point,
                    &bnd0_param[0], &bnd0_param[1], &onSurf);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if(EM2ddistptpts(bnd0_param,uvbegpt) < EM2ddistptpts(bnd0_param,uvendpt))
   truncate_end = FALSE;
 else
   truncate_end = TRUE;
 
 stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, uvbegpt, uvendpt,
                         NULL, NULL, NULL),
                   senderid = NULL_OBJID,
                   targetid = vertex_curves[2].edge_id);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

 if(EM2ddistptpts(bnd0_param,uvbegpt) < EM2ddistptpts(bnd0_param,uvendpt))
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

 if (vertex_curves[2].curves_surface->planar)
  {
   stat_OM = om$get_classid (osnum = md_osnum, objid = to_fix_edge,
                             p_classid = &classid1);
   if (! (1 & stat_OM)) goto wrapup;

   stat_OM = om$get_classid (osnum = md_osnum,
                             objid = vertex_curves[2].edge_id,
                             p_classid = &classid2);
   if (! (1 & stat_OM)) goto wrapup;

   if ((classid1 == OPP_EMSbsedge_class_id) && 
       (classid2 == OPP_EMSbsedge_class_id))
    {
     stat_OM = om$send(msg = message EMSedge.EMendpts(&msg,
                             (truncate_end) ? NULL : c_parm,
                             (truncate_end) ? c_parm : NULL,
                              NULL, NULL, NULL),
                       senderid = NULL_OBJID,
                       targetid = to_fix_edge);
     EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

     if (EM2ddistptpt(c_parm, inters_data.point) > surf_partol.tol)
      {
       option1 = NULL | EMS_ROUND_OPR;

       base_point[0] = inters_data.point[0];
       base_point[1] = inters_data.point[1];
       base_point[2] = 0.0;

       option = (truncate_end) ? END : BEGIN;

       stat_OM = om$send(msg = message EMSedge.EMextend_geom (&msg,
                               base_point, &option, TRUE, NULL,
                               NULL, NULL, &surf_partol, option1, NULL,
                               NULL, NULL, NULL),
                         senderid = NULL_OBJID,
                         targetid = to_fix_edge);
       EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);
      }
    }
  }

 /* fix the existing edge boundaries ---- SECOND */

 stat_OM = EMget_uedge_id(&msg, my_env, bnd1_param[0], knot_tol,
                          my_info[edge_index[1]].fillet_id, &to_fix_edge);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);

 stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, uvbegpt, uvendpt,
                         NULL, NULL, NULL),
                   senderid = NULL_OBJID,
                   targetid = to_fix_edge);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

 status = BSprptonsf (&msg, vertex_curves[3].curves_surface, second_point,
                    &bnd1_param[0], &bnd1_param[1], &onSurf);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if(EM2ddistptpts(bnd1_param,uvbegpt) < EM2ddistptpts(bnd1_param,uvendpt))
   truncate_end = FALSE;
 else
   truncate_end = TRUE;
 
 stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, uvbegpt, uvendpt,
                         NULL, NULL, NULL),
                   senderid = NULL_OBJID,
                   targetid = vertex_curves[3].edge_id);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

 if(EM2ddistptpts(bnd1_param,uvbegpt) < EM2ddistptpts(bnd1_param,uvendpt))
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
                          &other_surf_partol),
                    senderid = NULL_OBJID,
                    targetid = to_fix_edge);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

 stat_OM = om$send (msg = message EMSedge.EMalter_geometry (&msg,
                          &inters_data, truncate_end),
                    senderid = NULL_OBJID,
                    targetid = to_fix_edge);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

 if (vertex_curves[3].curves_surface->planar)
  {
   stat_OM = om$get_classid (osnum = md_osnum, objid = to_fix_edge,
                             p_classid = &classid1);
   if (! (1 & stat_OM)) goto wrapup;

   stat_OM = om$get_classid (osnum = md_osnum,
                             objid = vertex_curves[3].edge_id,
                             p_classid = &classid2);
   if (! (1 & stat_OM)) goto wrapup;

   if ((classid1 == OPP_EMSbsedge_class_id) && 
       (classid2 == OPP_EMSbsedge_class_id))
    {
     stat_OM = om$send(msg = message EMSedge.EMendpts(&msg,
                             (truncate_end) ? NULL : c_parm,
                             (truncate_end) ? c_parm : NULL,
                              NULL, NULL, NULL),
                       senderid = NULL_OBJID,
                       targetid = to_fix_edge);
     EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

     if (EM2ddistptpt(c_parm, inters_data.point) > other_surf_partol.tol)
      {
       option1 = NULL | EMS_ROUND_OPR;

       base_point[0] = inters_data.point[0];
       base_point[1] = inters_data.point[1];
       base_point[2] = 0.0;

       option = (truncate_end) ? END : BEGIN;

       stat_OM = om$send(msg = message EMSedge.EMextend_geom (&msg,
                               base_point, &option, TRUE, NULL, NULL,
                               NULL, &other_surf_partol, option1, NULL,
                               NULL, NULL, NULL),
                         senderid = NULL_OBJID,
                         targetid = to_fix_edge);
       EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);
      }
    }
  }

 /* fill pairing info for topology -- this info is generated with known 
    orientation of surfaces returned by math */

 pair_info[*num_pair_info].edge = vertex_curves[0].edge_id;
 pair_info[*num_pair_info].comm_edge = bs0_edges[3];
 pair_info[*num_pair_info].edge_surf = vertex_curves[0].fillet_id;
 pair_info[*num_pair_info].comm_edge_surf = blend_srf0_id;
 pair_info[*num_pair_info].align_normal = FALSE;
  (*num_pair_info)++;

 pair_info[*num_pair_info].edge = vertex_curves[1].edge_id;
 pair_info[*num_pair_info].comm_edge = bs1_edges[1];
 pair_info[*num_pair_info].edge_surf = vertex_curves[1].fillet_id;
 pair_info[*num_pair_info].comm_edge_surf = blend_srf1_id;
 pair_info[*num_pair_info].align_normal = FALSE;
 (*num_pair_info)++;

 pair_info[*num_pair_info].edge = vertex_curves[2].edge_id;
 pair_info[*num_pair_info].comm_edge = bs0_edges[0];
 pair_info[*num_pair_info].edge_surf = vertex_curves[2].fillet_id;
 pair_info[*num_pair_info].comm_edge_surf = blend_srf0_id;
 pair_info[*num_pair_info].align_normal = FALSE;
 (*num_pair_info)++;

 pair_info[*num_pair_info].edge = vertex_curves[3].edge_id;
 pair_info[*num_pair_info].comm_edge = bs1_edges[0];
 pair_info[*num_pair_info].edge_surf = vertex_curves[3].fillet_id;
 pair_info[*num_pair_info].comm_edge_surf = blend_srf1_id;
 pair_info[*num_pair_info].align_normal = FALSE;
 (*num_pair_info)++;

 pair_info[*num_pair_info].edge = bs0_edges[1];
 pair_info[*num_pair_info].comm_edge = bs1_edges[3];
 pair_info[*num_pair_info].edge_surf = blend_srf0_id;
 pair_info[*num_pair_info].comm_edge_surf = blend_srf1_id;
 pair_info[*num_pair_info].align_normal = FALSE;
 (*num_pair_info)++;

 wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "GRvg.EMtwo_edge_vertex_surface");

 for (i=0; i<4; i++)
  {
   if (vertex_curves[i].curve) /*BSfreecv(&msg, vertex_curves[i].curve);*/
    EMfreecv(&msg, my_info, edge_index, vertex_curves[i].curve);
  }

 if (ext_curve1) om$dealloc(ptr = ext_curve1);
 if (ext_curve2) om$dealloc(ptr = ext_curve2);
 if (part_curve0) om$dealloc (ptr = part_curve0);
 if (part_curve1) om$dealloc (ptr = part_curve1);
 if (curves) om$dealloc(ptr = curves);
 if (surfaces) om$dealloc(ptr = surfaces);
 if (par1) om$dealloc(ptr = par1);
 if (par2) om$dealloc(ptr = par2);
 if (par3) om$dealloc(ptr = par3);
 if (par4) om$dealloc(ptr = par4);
 if (over1) om$dealloc(ptr = over1);
 if (over2) om$dealloc(ptr = over2);
 if (int_pts) om$dealloc(ptr = int_pts);
 if (end_pts) om$dealloc(ptr = end_pts);
 if (cv1_points) om$dealloc (ptr = cv1_points);
 if (cv2_points) om$dealloc (ptr = cv2_points);
 if (cv3_points) om$dealloc (ptr = cv3_points);
 if (cv4_points) om$dealloc (ptr = cv4_points);
 return (stat_OM);
}


static void EMfreecv(rc, my_info, edge_index, cvptr)
IGRlong *rc;
struct EMedge_round_info *my_info;
IGRint *edge_index;
struct IGRbsp_curve *cvptr;
{
 IGRint i;
 struct EMedge_round_info *this_info;
 IGRboolean no_no = FALSE;

 *rc = BSSUCC;

 for(i=0; i<2; i++)
  {
   this_info = &my_info[edge_index[i]];
   if( (cvptr == this_info->curve) || (cvptr == this_info->comm_curve) ||
       (cvptr == this_info->other_curve))
    {
     no_no = TRUE;
     break;
    }
  }

 if(!no_no) BSfreecv(rc, cvptr);
}

end implementation GRvg;
