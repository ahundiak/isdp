/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
class implementation GRvg;

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emserr.h"
#include "emsmacros.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "OMmacros.h"
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
#include "bsfreecv.h"
#include "bsdistptpt.h"
#include "bsconstprcv.h"
#include "bschgdeppar.h"
#include "bschgcvewts.h"
#include "bsalloccv.h"

%safe
static IGRlong EFfix_xyz_curve();
%endsafe

from EMSsubbs import EMintersect_plane_fillet;

/* History 

Tapadia  2/14/91 - Fixed TR 91n0251. 
Sudha   07/08/93   Modified for BSprototypes ansification

*/

IGRlong EMvertex_curves_all_edges (EMmsg,
                                   my_env,
                                   construct_list,
                                   vertex_type,
                                   vtx_point,
                                   my_info,
                                   num_pair_info,
                                   pair_info,
                                   edge_index,
                                   num_rnd_edges,
                                   round_id,
                                   vertex_curves,
                                   swept_surf_id)

IGRlong 	             *EMmsg;
struct GRmd_env          *my_env;
struct GRvg_construct    *construct_list;
IGRshort                 vertex_type;
IGRpoint                 vtx_point;
struct EMedge_round_info *my_info;
IGRint                   *num_pair_info;
struct EMedge_con_info   *pair_info;
IGRint                   *edge_index;
IGRint                   *num_rnd_edges;
GRobjid                  *round_id;
struct EMvertex_curves   *vertex_curves;
GRobjid                  *swept_surf_id;

{
 IGRlong                 stat_OM, msg;
 IGRshort                option = 0;
 IGRint                  i, j;
 IGRint                  num_int_inx;
 IGRint                  num_int;
 IGRlong                 num_pla_pnt=3;
 IGRint                  loc_inx0, loc_inx1, inx;
 IGRint                  *info_index, index;
 IGRboolean              swpt_srf_ret = FALSE;
 IGRboolean              status, onSurf0, onSurf1,
                         *iso_edge,
                         same_radius;
 IGRboolean              tst_planar = TRUE;
 IGRdouble               *plane_pointers;
 IGRdouble               toler;
 IGRdouble               chdht_tol;
 IGRdouble               new_tol, fix_tol;
 IGRdouble               min_dist, dist;
 IGRdouble               u_par, other_par;
 IGRdouble               *v_par;
 IGRdouble               *par1, *par2,
                         *over1, *over2;
 IGRpoint                *cv1_points, *cv2_points;
 IGRpoint                *intersect_pnt;
 IGRpoint                mid_point, beg_pt;
 IGRpoint                pla_pnt[3];
 IGRpoint                base_point;
 IGRvector               norm_vec;
 struct IGRplane         *plane;
 struct IGRbsp_surface   **surface_geom;
 struct IGRbsp_curve     *iso_curve, *mod_c2;
 IGRboolean              vtx_uniform;
/*
 IGRlong                 EFfix_xyz_curve();
*/

/*-------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 intersect_pnt = NULL;
 plane = NULL;
 plane_pointers = NULL;
 info_index = NULL;
 surface_geom = NULL;
 iso_edge = NULL;
 v_par = NULL;
 num_int_inx = 0;
 inx = 0;

 BSEXTRACTPAR(&msg, BSTOLLENVEC, toler);
 BSEXTRACTPAR(&msg, BSTOLCHRDHT, chdht_tol);

 fix_tol = .003;

 intersect_pnt = (IGRpoint *) om$malloc (size = (*num_rnd_edges + 1) *
                                        sizeof (IGRpoint));
 surface_geom = (struct IGRbsp_surface **) om$malloc (size = 
                     (*num_rnd_edges) * sizeof (struct IGRbsp_surface *));
 info_index = (IGRint *) om$malloc (size =  (*num_rnd_edges) *
                                                        sizeof (IGRint));
 plane = (struct IGRplane *) om$malloc (size = (*num_rnd_edges) *
                                       sizeof (struct IGRplane));
 iso_edge = (IGRboolean *) om$malloc (size = (*num_rnd_edges) *
                                       sizeof (IGRboolean));
 EMerr_hndlr(! intersect_pnt || ! surface_geom || ! plane || ! iso_edge,
             *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 v_par = (IGRdouble *) om$malloc(size = (*num_rnd_edges) *
                                      sizeof (IGRdouble));

 plane_pointers = (IGRdouble *) om$malloc(size = (*num_rnd_edges)*6 *
                                sizeof (IGRdouble));
 EMerr_hndlr(!v_par || ! plane_pointers, *EMmsg, EMS_E_NoDynamicMemory,
             wrapup);

 for (i=0; i<(*num_rnd_edges); i++)
  {
   iso_edge[i] = FALSE;
   plane[i].point = &plane_pointers[6*i];
   plane[i].normal = &plane_pointers[6*i + 3];
  }

 new_tol = 100 * toler;
 BSchgdeppar(new_tol, &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 for (i=0; i<=(*num_rnd_edges); i++)
  {
   par1 = NULL;
   par2 = NULL;
   over1 = NULL;
   over2 = NULL;
   cv1_points = NULL;
   cv2_points = NULL;

   if (i != (*num_rnd_edges))
    {
     /* Fixed TR 91n0251 - Defective model returned null curve */
     if(my_info[edge_index[i]].other_curve == NULL) {
		*EMmsg = EMS_E_Fail ;
		goto wrapup;
     }
     BSmdistcvcv(my_info[edge_index[i]].curve,
                 my_info[edge_index[i]].other_curve,
                 &num_int,
                 &par1,
                 &par2,
                 &cv1_points,
                 &cv2_points,
                 &dist,
                 &msg);
     EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

     index = 0;
     if (num_int > 1)
      {
       min_dist = MAXFLOAT;       
       for (j=0; j<num_int; j++)
        {
         if (BSdistptpt(&msg, vtx_point, &cv1_points[j][0]) < min_dist)
          {
           min_dist = BSdistptpt(&msg, vtx_point, &cv1_points[j][0]);
           index = j;
          }
        }
      }

     if ((num_int) && (dist <= 10 * chdht_tol))
      {
       OM_BLOCK_MOVE(&cv1_points[index][0],&intersect_pnt[num_int_inx][0],
                     sizeof (IGRpoint));
      }
     else
      {
       for (j=0; j<3; j++)
        intersect_pnt[num_int_inx][j] = 0.0;
      }

     num_int_inx++;
    }
   else
    {
     for (j=0; j<3; j++)
      {
       intersect_pnt[num_int_inx][j] = intersect_pnt[0][j];
      }
    }

   if ((vertex_type == EMS_3CVX_VTX) || (vertex_type == EMS_3CNV_VTX))
    {
     if (i)
      {
       loc_inx0 = (i == (*num_rnd_edges)) ? 0 : num_int_inx-2;
       loc_inx1 = (i == (*num_rnd_edges)) ? 0 : i;
    
       status = BSprptonsf (&msg,
                            my_info[edge_index[loc_inx1]].fillet_surface,
                            intersect_pnt[loc_inx0],
                            &u_par, &v_par[inx],
                            &onSurf0);
       EMerr_hndlr(!status || msg != BSSUCC,*EMmsg,EMS_E_BSerror, wrapup);

       status = BSprptonsf (&msg,
                            my_info[edge_index[loc_inx1]].fillet_surface,
                            intersect_pnt[num_int_inx - 1],
                            &u_par, &other_par,
                            &onSurf1);
       EMerr_hndlr(!status || msg != BSSUCC,*EMmsg,EMS_E_BSerror, wrapup);

       if (onSurf0 && onSurf1 && (fabs(v_par[inx]-other_par) <= toler))
        {
         iso_edge[inx] = TRUE;
        }
       else
        {
         iso_edge[inx] = FALSE;
    
         for (j=0; j<3; j++)
          {
           mid_point[j] = (intersect_pnt[loc_inx0][j] +
                           intersect_pnt[num_int_inx - 1][j]) / 2;
          }
     
         status = BSmdistptsf (&msg, 
                             my_info[edge_index[loc_inx1]].fillet_surface,
                             mid_point,
                             &u_par,
                             &v_par[inx],
                             base_point,
                             &dist);
         EMerr_hndlr (! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror,
                      wrapup);

         if (dist <= 2 * chdht_tol)
          {
           BSsfarrevn (&msg, my_info[edge_index[loc_inx1]].fillet_surface,
                       1, &u_par, 1, &v_par[inx], beg_pt, norm_vec);
           EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
           for (j=0; j<3; j++)
                base_point[j] = norm_vec[j] + beg_pt[j];         
          }

         OM_BLOCK_MOVE (&intersect_pnt[loc_inx0][0], pla_pnt[0],
                        sizeof (IGRpoint));
         OM_BLOCK_MOVE (&intersect_pnt[num_int_inx-1][0], pla_pnt[1],
                        sizeof (IGRpoint));
         OM_BLOCK_MOVE (base_point, pla_pnt[2], sizeof (IGRpoint));
   
         status = MAdetplane(&msg, (IGRdouble *)pla_pnt, &num_pla_pnt, &toler,
                           &plane[inx]);
         EMerr_hndlr(! status || !(1&msg), *EMmsg, EMS_E_MAerror, wrapup);
        }

       surface_geom[inx] = my_info[edge_index[loc_inx1]].fillet_surface;
       info_index[inx] = edge_index[loc_inx1];
       vertex_curves[inx].fillet_id = 
                                my_info[edge_index[loc_inx1]].fillet_id;
       inx++;
      }
    }
   if (par1) om$dealloc(ptr = par1);
   if (par2) om$dealloc(ptr = par2);
   if (over1) om$dealloc(ptr = over1);
   if (over2) om$dealloc(ptr = over2);
   if (cv1_points) om$dealloc (ptr = cv1_points);
   if (cv2_points) om$dealloc (ptr = cv2_points);
  }

 BSchgdeppar(toler, &msg);
 EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 same_radius = TRUE;
 for (j=1; j<(*num_rnd_edges); j++)
  {
   if (my_info[edge_index[0]].radius != my_info[edge_index[j]].radius)
    {
     same_radius = FALSE;
     break;
    }
  }

 vtx_uniform = FALSE;

 /* vtx_uniform = EMis_vertex_uniform(&msg,
                                      my_info,
                                      edge_index,
                                      num_rnd_edges);
    EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
 */

 if ((vertex_type == EMS_1CVX_2CNV_VTX) ||
     (vertex_type == EMS_1CNV_2CVX_VTX))
  {
   swpt_srf_ret = EMswept_surface (&msg,
                                   my_env,
                                   construct_list,
                                   vertex_type,
                                   vtx_point,
                                   my_info,
                                   num_pair_info,
                                   pair_info,
                                   edge_index,
                                   &num_int_inx,
                                   intersect_pnt,
                                   swept_surf_id,
                                   round_id);
   EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
  }
 else
  { 
   if (same_radius)
    {
     for (i=0; i<num_int_inx; i++)
      {
       iso_curve = NULL;
       mod_c2 = NULL;

       if (iso_edge[i])
        {
         BSalloccv (surface_geom[i]->u_order,surface_geom[i]->u_num_poles,
                    surface_geom[i]->rational, NULL, &iso_curve, &msg);
         EMerr_hndlr(msg != BSSUCC,*EMmsg, EMS_E_NoDynamicMemory, wrapup);

         BSconstprcv (&msg, surface_geom[i], &option, &v_par[i],
                      &tst_planar, iso_curve);
         EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

         if (iso_curve->rational)
          {
           if ((iso_curve->weights[0] != 1.0) ||
               (iso_curve->weights[iso_curve->num_poles - 1] != 1.0))
            {
             BSalloccv (iso_curve->order, iso_curve->num_poles,
                        iso_curve->rational, NULL, &mod_c2, &msg);
             EMerr_hndlr(msg != BSSUCC,*EMmsg,EMS_E_NoDynamicMemory,
                         wrapup);

             BSchgcvewts (iso_curve, mod_c2, &msg);
             EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  
             if (iso_curve) BSfreecv(&msg, iso_curve);
             iso_curve = mod_c2;
            }
          }
        }

       vertex_curves[i].curve = NULL;
       stat_OM = om$send(msg = message EMSsubbs.EMintersect_plane_fillet(
                               &msg,
                               my_env,
                               iso_edge[i],
                               iso_curve,
                               &v_par[i],
                               &my_info[info_index[i]],
                               FALSE,
                               vtx_point,
                               num_pair_info,
                               pair_info,
                               &plane[i],
                               &vertex_curves[i].curve,
                               NULL,
                               &vertex_curves[i].edge_id,
                               round_id),
                         senderid = NULL_OBJID,
                         targetid = vertex_curves[i].fillet_id);
       EMerr_hndlr(!(1& stat_OM & msg),*EMmsg,EMS_E_SurfaceError, wrapup);
       vertex_curves[i].curves_surface = surface_geom[i];

       {
        IGRlong    EFfix_xyz_curve();

        EFfix_xyz_curve (intersect_pnt, num_int_inx, fix_tol,
                         vertex_curves[i].curve);
       }
      }
     goto wrapup;
    } /* same_radius */
   else
   if (*num_rnd_edges == 3)
    {
     swpt_srf_ret = EMswept_surface (&msg,
                                     my_env,
                                     construct_list,
                                     vertex_type,
                                     vtx_point,
                                     my_info,
                                     num_pair_info,
                                     pair_info,
                                     edge_index,
                                     &num_int_inx,
                                     intersect_pnt,
                                     swept_surf_id,
                                     round_id);
     EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);

     if (! swpt_srf_ret && ! same_radius)
      {
       for (i=0; i<num_int_inx; i++)
         {
          iso_curve = NULL;
          mod_c2 = NULL;

          if (iso_edge[i])
           {
            BSalloccv (surface_geom[i]->u_order,
                       surface_geom[i]->u_num_poles,
                       surface_geom[i]->rational, NULL, &iso_curve, &msg);
            EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory,
                         wrapup);

            BSconstprcv (&msg, surface_geom[i], &option, &v_par[i],
                         &tst_planar, iso_curve);
            EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

            if (iso_curve->rational)
             {
              if ((iso_curve->weights[0] != 1.0) ||
                  (iso_curve->weights[iso_curve->num_poles - 1] != 1.0))
               {
                BSalloccv (iso_curve->order, iso_curve->num_poles,
                           iso_curve->rational, NULL, &mod_c2, &msg);
                EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory,
                             wrapup);

                BSchgcvewts (iso_curve, mod_c2, &msg);
                EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   
                if (iso_curve) BSfreecv(&msg, iso_curve);
                iso_curve = mod_c2;
               }
             }
           }

          vertex_curves[i].curve = NULL;

          stat_OM=om$send(msg = message EMSsubbs.EMintersect_plane_fillet(
                                  &msg,
                                  my_env,
                                  iso_edge[i],
                                  iso_curve,
                                  &v_par[i],
                                  &my_info[info_index[i]],
                                  FALSE,
                                  vtx_point,
                                  num_pair_info,
                                  pair_info,
                                  &plane[i],
                                  &vertex_curves[i].curve,
                                  NULL,
                                  &vertex_curves[i].edge_id,
                                  round_id),
                            senderid = NULL_OBJID,
                            targetid = vertex_curves[i].fillet_id);
          EMerr_hndlr(!(1&stat_OM&msg),*EMmsg,EMS_E_SurfaceError,wrapup);
          vertex_curves[i].curves_surface = surface_geom[i];
  
          EFfix_xyz_curve (intersect_pnt, num_int_inx, fix_tol,
                           vertex_curves[i].curve);
         }
      }  
    }
  }

 wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "GRvg.EMvertex_curves_all_edges");
 if (v_par) om$dealloc(ptr = v_par);
 if (iso_edge) om$dealloc(ptr = iso_edge);
 if (plane) om$dealloc(ptr = plane);
 if (plane_pointers) om$dealloc(ptr = plane_pointers);
 if (surface_geom) om$dealloc(ptr = surface_geom);
 if (info_index) om$dealloc(ptr = info_index);
 if (intersect_pnt) om$dealloc(ptr = intersect_pnt);

 return (stat_OM);

}

static IGRlong EFfix_xyz_curve (intersect_pnt, num_int_inx, fix_tol,curve)

IGRpoint                *intersect_pnt;
IGRint                  num_int_inx;
IGRdouble               fix_tol;
struct IGRbsp_curve     *curve;

{
 IGRlong             msg;
 IGRint              i,j;

 for (i=0; i<num_int_inx; i++)
  {
   if (BSdistptpt(&msg, intersect_pnt[i], &curve->poles[0]) <= fix_tol)
    {
     for (j=0; j<3; j++)
      curve->poles[j] = intersect_pnt[i][j];
    }
   else
   if (BSdistptpt(&msg, intersect_pnt[i],
                  &curve->poles[3*(curve->num_poles-1)]) <= fix_tol)
    {
     for (j=0; j<3; j++)
      curve->poles[3*(curve->num_poles-1) + j] = intersect_pnt[i][j];
    }
  }
 return(OM_S_SUCCESS);
}

end implementation GRvg;
