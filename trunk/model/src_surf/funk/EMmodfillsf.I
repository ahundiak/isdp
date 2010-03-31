/*
  DESCRIPTION
 
    This function extends or retracts the fillet relative to an edge, so that
    the fillet will be suitable to be utilized in all the vertex processing 
    functions.

    The extension or the retraction of the fillet is limited to twice the
    radius of the fillet (unless otherwise noted).  This is expected to
    yeild an acceptable fillet in most cases.

  ARGUMENTS

    edge_rnd_info:  information concerning the edge the fillet is on.

  HISTORY
  
  Jeffrey/
  Aditya : 12/06/95      : Fixes for TRs 119603376 & 119603919. Changes to
                           fillet extent determination in cases of intersection
                           with both previous and next edge at a vertex.
  KNAP   : March'21 1995 : Re-write.
                           Made extension/retraction criterion deterministic.
                           Replaced extension to a point by distance.
                           Added the function EMget_fillet_edge_intpt (), to
                           compute the fillet-edge intersection.
*/

class implementation  EMSedge;


#include <math.h>
#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsdattyp.h"
#include "EMSasnuc.h"
#include "EMSrnd.h"
#include "bsgeom_cvsf.h"
#include "bssrmktsncg.h"
#include "bssnorkts.h"
#include "bssfxtdst0.h"
#include "bsreparmsf.h"
#include "bssfeval.h"
#include "bssfarrevt.h"
#include "bsprptarrsf.h"
#include "bspartofsf.h"
#include "bsmdistptsf.h"
#include "bsfreesf.h"
#include "bsfreecv.h"
#include "bsallocsf.h"
#include "bsdotp.h"

#define CONST_U	  1

#define U0	  0.0
#define U1	  1.0
#define V0	  0.0
#define V1	  1.0

#define U	  0
#define V	  1

#define START	  0
#define STOP	  1

#define FIRST	  0
#define SECOND	  1

#define V_LEFT	  2
#define V_RIGHT	  3

#define WBC_USE_NEW_MATH 1

%safe
static IGRboolean EMget_fillet_edge_intpt();
%endsafe

from GRvg import GRpostabsg;
extern IGRlong EMget_edge_tangents_at_rnd_vtx();

#argsused

IGRlong EMmodify_fillet (msg, options, md_env, edge_rnd_info)
IGRlong                 *msg;
IGRushort               options;
struct GRmd_env         *md_env;
struct EMSedge_rnd_info *edge_rnd_info;
{
  IGRint        i, j, num_pts, prev, next, v_side[2], ed_inx[2];
  IGRushort     fillet_props;
  IGRboolean    extend_fillet[2], end_degenerate[2], extract_fillet = FALSE,
                flag1, flag2,flag3=0, fillet_pos_orient, process_vtx[2], all_on_surf,
	        prev_int, next_int, edge_stops = FALSE, do_not_extend[2];
  IGRlong       msg_loc, stat;
  IGRdouble     mid_pt_uv[2], extent_pts_uv[2][2], cht_tol, distance, 
                dist_tol, ext_dist, fillet_ext_factor[2], dotp,
                intpts_uv[2][2][2], vtx_uv[2][2];
  IGRpoint      mid_pt_xyz, dumpt;
  IGRvector     tan_vecs[2];

  struct IGRbsp_surface         *fsrf, *surf_ptr, *reduced_surf, *mod_surf[3];
  struct EMSvtx_rnd_info        *vtx_rnd_info;
  struct BSgeom_bsp_surf        geom_surface, *geom_surf_ptr;

  extern void EFinit_geom_surface() ;
  extern void EMextract_partial_fillet();

  *msg = EMS_S_Success;
  stat = OM_S_SUCCESS;

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht_tol);
  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, dist_tol);
  geom_surf_ptr = NULL;
  geom_surface.sfgen_cv = NULL;
  num_pts = 1;

  for (i=0; i<3; i++)
     mod_surf[i] = NULL;

  end_degenerate[0]= end_degenerate[1]= FALSE;
  reduced_surf = NULL;
  surf_ptr = NULL;
  fsrf = edge_rnd_info->fill_surf;
  fillet_props = edge_rnd_info->props;
  fillet_pos_orient = fsrf->pos_orient;
#if WBC_USE_NEW_MATH
  EFinit_geom_surface (&msg_loc, fsrf, edge_rnd_info->fill_id,
                       md_env->md_id.osnum, &geom_surface);
  EMerr_hndlr (!(msg_loc & 1), *msg, msg_loc, wrapup);

  geom_surf_ptr = &geom_surface;
#endif

  /*
   * Under following conditions, the fillet does not require
   * modifications.
   *    . Edge on which the fillet is on is closed in XYZ.
   * Determine whether the fillet needs to be modfied and record
   * that information in 'process_vtx'.
   */

   process_vtx[START] = process_vtx[STOP] = FALSE;
   extend_fillet[START] = extend_fillet[STOP] = FALSE;


   /*
    * Get the internal point of the edge, which will be used to determine
    * the direction point for extraction of the fillet.
    */

   stat = om$send( msg = message EMSedge.EMinternalpt (&msg_loc, 1, NULL,
                                                       mid_pt_uv, NULL, NULL),
                                 targetid = edge_rnd_info->edge_id,
                                 targetos = md_env->md_id.osnum,
                                 senderid = NULL_OBJID);
   EMerr_hndlr (!(1 & stat & msg_loc), *msg, EMS_E_EdgeError, wrapup);

   BSsfeval (edge_rnd_info->surf, mid_pt_uv[0], mid_pt_uv[1], (IGRint)0,
             (IGRpoint *)mid_pt_xyz, &msg_loc);
   EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, wrapup);

#if WBC_USE_NEW_MATH
   BSprptarrsf (&geom_surface, dist_tol, 2, 2, &num_pts, mid_pt_xyz,
                &mid_pt_uv[0], dumpt, &all_on_surf, NULL, &msg_loc);
   EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, wrapup);
#else
   BSmdistptsf (&msg_loc, fsrf, mid_pt_xyz, &mid_pt_uv[0], &mid_pt_uv[1],
                dumpt, &distance);
   EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, wrapup);
#endif


   if (!(fillet_props & EMSfillet_ed_is_xyz_closed))
   {
     for (i=START; i<=STOP; i++)
     {
       do_not_extend[i] = FALSE;
       /*
        * If this end is degenerate, record it for later use.
        */
       flag1 = i == START ? 0x1 : 0x0;
       flag2 = fillet_props & EMSfillet_v0_closeto_start_end ? 0x1 : 0x0;
       if (flag1 ^ flag2)
       {
         if (fillet_props & EMSfillet_v1_is_degenerate)
         {
           extent_pts_uv[i][V] = 1.0;
           end_degenerate[i] = TRUE;
         }
       }
       else if (fillet_props & EMSfillet_v0_is_degenerate)
       {
         extent_pts_uv[i][V] = 0.0;
         end_degenerate[i] = TRUE;
       }
       if (end_degenerate[i])
       {
         process_vtx[i] = FALSE;
         continue;
       }
         
       /* 
        * Get the neighbouring edges, previous and next
        * at the vertices of the round edge. Compute the
        * fillet-iso and edge intersection. If there is 
        * an intersection for both previous and next edges,
        * if the fillet is v_phy_closed, the fillet requires
        * extraction, and then extension by 2*radius.
        * Else the fillet does not require any modification
        * at this end of the fillet.
        */
       vtx_rnd_info = i == START ? edge_rnd_info->start_vtx
                                 : edge_rnd_info->stop_vtx;

       if (vtx_rnd_info->vtx_config == EMSvertex_single_patch)
         fillet_ext_factor[i] = 1.75;
       else
         fillet_ext_factor[i] = 2.0;

       BSmdistptsf (&msg_loc, fsrf, vtx_rnd_info->vtx_pt, &vtx_uv[i][0],
                    &vtx_uv[i][1], dumpt, &distance );
       EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, wrapup);
       /*
        * Get the previous and next edge indices for the fillet under 
        * consideration.
        */

       for (j=0;j<vtx_rnd_info->num_edges;j++)
         if (vtx_rnd_info->edge_ids[j] == edge_rnd_info->edge_id)
         {
           edge_stops = vtx_rnd_info->edge_stops[j];
           break;
         }

       prev = (j==0) ? (vtx_rnd_info->num_edges -1): (j-1);
       next = (j== (vtx_rnd_info->num_edges -1)) ? 0 : (j+1);

       prev_int = EMget_fillet_edge_intpt (&msg_loc, md_env, 
                    edge_rnd_info, vtx_rnd_info->edge_ids[prev],
                    vtx_rnd_info->vtx_pt, intpts_uv[i][FIRST]);
       EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_NoIntersection, wrapup);

       next_int = EMget_fillet_edge_intpt (&msg_loc, md_env, 
                    edge_rnd_info, vtx_rnd_info->edge_ids[next],
                    vtx_rnd_info->vtx_pt, intpts_uv[i][SECOND]);
       EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_NoIntersection, wrapup);

       /*
        * Determination of extract points is done such that they
        * enclose the largest extent of the fillet. If the vertex is
        * v1 end, then the extent point is the one close to v1. And
        * if the vertex is v0 end, then the extent point is the one 
        * close to v0. If there is no intersection for both the 
        * previous and next edges, then use the projected point of 
        * the vertex onto the fillet. Also, note the extension if
        * required will be done for V_RIGHT and/or V_LEFT.
        */ 

       if (fsrf->v_phy_closed)
       {
         v_side[i] = i + 2; 
         if (!prev_int && !next_int)
         {
           intpts_uv[i][FIRST][V] = vtx_uv[i][V];
           intpts_uv[i][SECOND][V] = vtx_uv[i][V];
         }
         else if (!prev_int && next_int)
           intpts_uv[i][FIRST][V] = intpts_uv[i][SECOND][V]; 
         else if (prev_int && !next_int)
           intpts_uv[i][SECOND][V] = intpts_uv[i][FIRST][V]; 

         extent_pts_uv[i][V] = intpts_uv[i][FIRST][V];

         /*
          * If intersections are obtained with both the prev and next
          * edges then use the coordinates of the intersection that will
          * give a larger extent.
          */
  	 if(prev_int && next_int)
         {
           flag3 = intpts_uv[i][FIRST][V] < intpts_uv[i][SECOND][V] ? 1 : 0;

           if((flag1 && flag2) || (!flag1 && !flag2))
           {
             if(flag3) extent_pts_uv[i][V] = intpts_uv[i][FIRST][V];
             else extent_pts_uv[i][V] = intpts_uv[i][SECOND][V];
           }
           else
           {
             if(flag3) extent_pts_uv[i][V] = intpts_uv[i][SECOND][V];
             else extent_pts_uv[i][V] = intpts_uv[i][FIRST][V];
           }
         }

         /*
          * Following tests are required.
          *   
          * o If the round edge and either of the prev/next edges are
          *   tangent continuous, then, the fillet could be truncated 
          *   to the intersection of the fillet and pre/next/edges.
          *   In such a situation, take the projected point of the vertex 
          *   on to the fillet as the extract point. Extend the fillet 
          *   thereon.
          * o If the fillet interacts with the same edge at both the ends
          *   then also, take the projected point of the vertex on to the
          *   fillet.
          */

         if (prev_int)
         {
           ed_inx[0] = j; ed_inx[1] = prev;
           stat = EMget_edge_tangents_at_rnd_vtx (&msg_loc, md_env, 
                                             vtx_rnd_info, ed_inx, tan_vecs);
           EMerr_hndlr (!(1 & stat & msg_loc), *msg, EMS_E_Fail, wrapup);
    
           dotp = BSdotp (&msg_loc, tan_vecs[FIRST], tan_vecs[SECOND]);
           EMerr_hndlr( msg_loc != BSSUCC, *msg, EMS_E_BSerror, wrapup );
           if (1.0 - fabs(dotp) < 100*dist_tol)
             extent_pts_uv[i][V] = vtx_uv[i][V];
         }
         if (next_int)
         {
           ed_inx[0] = j; ed_inx[1] = next;
           stat = EMget_edge_tangents_at_rnd_vtx (&msg_loc, md_env, 
                                             vtx_rnd_info, ed_inx, tan_vecs);
           EMerr_hndlr (!(1 & stat & msg_loc), *msg, EMS_E_Fail, wrapup);
    
           dotp = BSdotp (&msg_loc, tan_vecs[FIRST], tan_vecs[SECOND]);
           EMerr_hndlr( msg_loc != BSSUCC, *msg, EMS_E_BSerror, wrapup );
           if (1.0 - fabs(dotp) < 100*dist_tol)
             extent_pts_uv[i][V] = vtx_uv[i][V];
         }

         if (i) /* test for the same edge intersection at both ends */
         {
           if (fabs(extent_pts_uv[1][V] - extent_pts_uv[0][V]) < dist_tol)
           {
             extent_pts_uv[0][V] = vtx_uv[0][V];
             extent_pts_uv[1][V] = vtx_uv[1][V];
           }
         }

         /*
          * Get the largest extent by comparing the extent that is obtained
          * from the intpts with the vtx pt.
          */
         if(flag2)
         {
           if( (extent_pts_uv[i][V] < vtx_uv[i][V] && !flag1) ||
               (extent_pts_uv[i][V] > vtx_uv[i][V] && flag1))
           {
             extent_pts_uv[i][V] = vtx_uv[i][V];
           }
         }
         else
         {
           if( (extent_pts_uv[i][V] > vtx_uv[i][V] && !flag1) ||
               (extent_pts_uv[i][V] < vtx_uv[i][V] && flag1))
           {
             extent_pts_uv[i][V] = vtx_uv[i][V];
           }
         }
       }
       else
       {
         if (!prev_int && next_int)
           intpts_uv[i][FIRST][V] = intpts_uv[i][SECOND][V]; 
         else if (prev_int && !next_int)
           intpts_uv[i][SECOND][V] = intpts_uv[i][FIRST][V]; 

         if (edge_stops)
         {

           if (flag2) /* =>v0 is close to start end */
           {

             v_side[i] = V_RIGHT;
             if (intpts_uv[i][FIRST][V] < intpts_uv[i][SECOND][V])
               extent_pts_uv[i][V] = intpts_uv[i][SECOND][V];
             else
               extent_pts_uv[i][V] = intpts_uv[i][FIRST][V];

             if(vtx_uv[i][V] > extent_pts_uv[i][V])
               extent_pts_uv[i][V] = vtx_uv[i][V];
           }
           else
           {
             v_side[i] = V_LEFT;
             if (intpts_uv[i][FIRST][V] < intpts_uv[i][SECOND][V])
               extent_pts_uv[i][V] = intpts_uv[i][FIRST][V];
             else
               extent_pts_uv[i][V] = intpts_uv[i][SECOND][V];

             if(vtx_uv[i][V] < extent_pts_uv[i][V])
               extent_pts_uv[i][V] = vtx_uv[i][V];
           }
         }
         else
         {
           if (flag2) /* =>v0 is close to start end */
           {
             v_side[i] = V_LEFT;
             if (intpts_uv[i][FIRST][V] < intpts_uv[i][SECOND][V])
               extent_pts_uv[i][V] = intpts_uv[i][FIRST][V];
             else
               extent_pts_uv[i][V] = intpts_uv[i][SECOND][V];

             if(vtx_uv[i][V] < extent_pts_uv[i][V])
               extent_pts_uv[i][V] = vtx_uv[i][V];
           }
           else
           {
             v_side[i] = V_RIGHT;
             if (intpts_uv[i][FIRST][V] < intpts_uv[i][SECOND][V])
               extent_pts_uv[i][V] = intpts_uv[i][SECOND][V];
             else
               extent_pts_uv[i][V] = intpts_uv[i][FIRST][V];

             if(vtx_uv[i][V] > extent_pts_uv[i][V])
               extent_pts_uv[i][V] = vtx_uv[i][V];
           }
         }
       }
       extent_pts_uv[i][U] = (IGRdouble)i;

       if (fsrf->v_phy_closed)
       {
         process_vtx[i] = TRUE;
         extract_fillet = TRUE;
       }
       else
       {

         if (prev_int && next_int)
           process_vtx[i] = FALSE;

         if (vtx_rnd_info->vtx_config == EMSvertex_general_blend)
           if (vtx_rnd_info->num_edges ==3)
             if (prev_int && next_int)
               do_not_extend[i]=TRUE;

         if (vtx_rnd_info->vtx_config == EMSvertex_tangent_trim)
         {
           if (vtx_rnd_info->num_edges == 2)
             process_vtx[i] = FALSE;
           else if (vtx_rnd_info->num_edges ==3)
           {
             process_vtx[i] = TRUE;
             extract_fillet = TRUE;
             if (!prev_int && !next_int)
               process_vtx[i] = FALSE;
             else if (prev_int && next_int)
             {
               if ((vtx_rnd_info->edge_configs[prev] == EMSedge_neutral) ||
                  (vtx_rnd_info->edge_configs[prev] == EMSedge_neutral_convex)||
                  (vtx_rnd_info->edge_configs[prev] == EMSedge_neutral_concave))
                 extent_pts_uv[i][V]= intpts_uv[i][FIRST][V];

               if ((vtx_rnd_info->edge_configs[next] == EMSedge_neutral) ||
                  (vtx_rnd_info->edge_configs[next] == EMSedge_neutral_convex)||
                  (vtx_rnd_info->edge_configs[next] == EMSedge_neutral_concave))
                 extent_pts_uv[i][V]= intpts_uv[i][SECOND][V];
             }
           }
           else if (vtx_rnd_info->num_edges == 4)
             if (!prev_int || !next_int)
               process_vtx[i] = TRUE;
         }
    
         if (vtx_rnd_info->vtx_config == EMSvertex_2edge_cx_1edge_cv)
           if (!prev_int && !next_int)
             process_vtx[i] = TRUE;
  
         if (vtx_rnd_info->vtx_config == EMSvertex_3edge_rolling_ball)
         {
           enum EMSedge_config edge_config;
           IGRboolean homogeneous_vtx;
  
           homogeneous_vtx = TRUE;
           edge_config = vtx_rnd_info->edge_configs[0];
           for (j = 1; j < vtx_rnd_info->num_edges; j++ )
              if( vtx_rnd_info->edge_configs[j] != edge_config )
              {
                 homogeneous_vtx = FALSE;
                 break;
              }
           if (!homogeneous_vtx)
             process_vtx[i] = TRUE;
         }

         if (vtx_rnd_info->vtx_config == EMSvertex_single_patch)
           if (!prev_int && !next_int)
              process_vtx[i] = TRUE;
       }
     }
   }

   if (!process_vtx[START] && !process_vtx[STOP])
     goto wrapup;


   if (extract_fillet)
   {
     EMextract_partial_fillet (&msg_loc, (IGRushort) 0, fsrf,
                               geom_surf_ptr, extent_pts_uv, NULL,
                               mid_pt_uv, &mod_surf[0]);
     EMerr_hndlr (!(1 & msg_loc), *msg, msg_loc, wrapup);
     process_vtx[0] = process_vtx[1] = 1;

     if (end_degenerate[0] || do_not_extend[0])
       process_vtx[0] = FALSE;
     if (end_degenerate[1] || do_not_extend[1])
       process_vtx[1] = FALSE;
   }
   else
     mod_surf[0] = fsrf;

   /*
    * Do the extension. After extension reparameterise the surface.
    */

   j=0;
   for (i=START; i <= STOP; i++)
   {
     if (process_vtx[i])
     {
       ext_dist = edge_rnd_info->radius * fillet_ext_factor[i];
       BSsfxtdst0 (mod_surf[j], ext_dist, v_side[i],
                   &mod_surf[j+1], &distance, &msg_loc);
       EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, wrapup);

       BSreparmsf (mod_surf[j+1], (IGRshort)2, 0.0, 1.0, 0.0, 1.0, 
                   mod_surf[j+1], &msg_loc);
       EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, wrapup);

       extend_fillet[i] = TRUE;
       j++;
     }
   }

   for (i=2; i >=0; i--)
     if (mod_surf[i])
     {
       surf_ptr = mod_surf[i];
       mod_surf[i] = NULL;
       break;
     }

   /*
    * Clean up the characteristics of the modified surface.
    * Determine degeneracy of the modified fillet on v=0.
    * First, turn off the degeneracy bit on V0.
    */
   edge_rnd_info->props &= ~EMSfillet_v0_is_degenerate;
 
   if (EFpts_degenerate (surf_ptr->u_num_poles, surf_ptr->poles,
	          surf_ptr->weights, 3, cht_tol))
     edge_rnd_info->props |= EMSfillet_v0_is_degenerate;

   /*
    * Determine degeneracy of the modified fillet on V=1.
    * First, turn off the degeneracy bit on V1.
    */
   edge_rnd_info->props &= ~EMSfillet_v1_is_degenerate;

   i = ( surf_ptr->v_num_poles - 1 ) * surf_ptr->u_num_poles;
   if (EFpts_degenerate (surf_ptr->u_num_poles, &surf_ptr->poles[i*3],
                         surf_ptr->weights ? &surf_ptr->weights[i] : NULL,
                         3, cht_tol))
     edge_rnd_info->props |= EMSfillet_v1_is_degenerate;
       
   /*
    * If the surface has been extended, reduce the superfluous data.
    */
   if (extend_fillet[START] == TRUE || extend_fillet[STOP] == TRUE)
   {
     IGRdouble       *knots = NULL;
     IGRint          u_num_knots, v_num_knots;

     BSallocsf (surf_ptr->u_order, surf_ptr->v_order, surf_ptr->u_num_poles,
                surf_ptr->v_num_poles, surf_ptr->rational,
                surf_ptr->num_boundaries, &reduced_surf, &msg_loc);
     EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, wrapup);

     u_num_knots = surf_ptr->u_num_poles + surf_ptr->u_order;
     v_num_knots = surf_ptr->v_num_poles + surf_ptr->v_order;
     knots = (IGRdouble *)om$malloc (size = (u_num_knots + v_num_knots) *
                                     sizeof(IGRdouble));
     EMerr_hndlr (!knots, *msg, EMS_E_NoDynamicMemory, wrapup);

     /*
      * Reduce the data on the extended surface.
      */
     BSsrmktsncg (surf_ptr, FALSE, ( IGRdouble ) 0.0, ( IGRint ) 1,
                  reduced_surf, &u_num_knots, &v_num_knots, &knots[0],
                  &knots[ u_num_knots ], &msg_loc);
     EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, wrapup);

     BSfreesf (&msg_loc, surf_ptr);
     surf_ptr = reduced_surf;
     reduced_surf = NULL;
   }

   /*
    * Math does not copy the following property (it should) from the
    * old fillet geometry, to the new one.
    */
   surf_ptr->pos_orient = fillet_pos_orient;

   /*
    * Post the new geometry into the fillet object.
    */
   {
     GRobjid			temp_objid;
     struct GRpost_info		post_info;

     post_info.construct_flag = FALSE;
     stat = om$send (msg = message GRvg.GRpostabsg (&msg_loc, md_env,
                                        &post_info, (IGRchar*) surf_ptr,
                                        &temp_objid),
                                   senderid = NULL_OBJID,
                                   targetid = edge_rnd_info->fill_id);
     EMerr_hndlr (!(msg_loc & stat & 1),*msg, EMS_E_SurfaceError,wrapup);

     GRabsg_del_by_objid (&edge_rnd_info->fill_id, &md_env->md_id.osnum);
   }

   /*
    * Now, allocate the new surface to the fillet object.
    */
    edge_rnd_info->fill_surf = surf_ptr;
    if ((fsrf != edge_rnd_info->fill_surf) && fsrf)
      BSfreesf (&msg_loc, fsrf);
    fsrf = surf_ptr = NULL;

wrapup:

   /*
    * If the arlgorithm succeeded, then mod_surf[i] would be NULL.
    */
    for( i = 0; i< 3; i++ )
       if( mod_surf[i] && mod_surf[i] != fsrf )
          BSfreesf( &msg_loc, mod_surf[i] );

    if( surf_ptr && surf_ptr != fsrf )
       BSfreesf( &msg_loc, surf_ptr );

    if( reduced_surf )
       BSfreesf( &msg_loc, reduced_surf );

    if (geom_surface.sfgen_cv)
       BSfreecv(&msg_loc, geom_surface.sfgen_cv);

  if (!msg_loc)  
    msg_loc = stat;

  EMWRAPUP( *msg, stat, "EMmodify_fillet");
  return(stat);
}

/*
  DESCRIPTION
 
   Given two extent parameters, this function extracts a partial surface
   from a fillet.  The bounds of the extracted surface is u0, u1, and the
   two v-constant iso lines at each of the extent parameters.

  ARGUMENTS
   fillet_geom         :The fillet surface from which a partial
                        surface is to be extracted.
   fillet_surf_geom    :The structure containing the geometric
                        definition of the fillet surface from which
                        a partial surface is to be extracted.  This
                        argument is optional - may pass in NULL.
   extent_points       :u,v parameters of two points that defines
                        the extent of the new surface.
   direction_point_XYZ :If the fillet is v_physically_closed, then
   direction_point_UV   one of these is used to resolve the
                        ambiguity of which section of the fillet is 
                        required.
                        The XYZ point need not be a point on the
                        fillet.  It can be a point in the visinity of
                        the fillet section that is to be retained.
                        The UV of course must be a pair on the
                        fillet (indicating which section is to be
                        kept).  It is illegal to specify both, or
                        specify NULL for both.

   new_surface         :The extracted surface. If *new_surface
                        == NULL on entry, then memory is allocated.
                        The caller should utilize BSfreesf(), when
                        freeing that memory [thus, if the caller is
                        passing in a surface, then that surface
                        should be allocated using BSalloc()]. If
                        NULL was passed in, then the output surface
                        will be assigned only on no errors.

  History:
	Janaka	: June 17, 1992 : Genesis
        WBC     : 01/12/92      : Added the optional argument fillet_surf_geom.
*/
#argsused

void EMextract_partial_fillet( msg, options, fillet_geom,
                               fillet_surf_geom,
 		               extent_pts_uv, direction_point_XYZ,
			       direction_point_UV, new_surface )
IGRlong			*msg;
IGRushort		options;
struct IGRbsp_surface	**new_surface, *fillet_geom;
struct BSgeom_bsp_surf  *fillet_surf_geom;
IGRdouble		extent_pts_uv[2][2], *direction_point_XYZ,
			*direction_point_UV;
{
   IGRlong			u_num_poles, v_num_poles, msg_loc;
   IGRdouble			distance, local_dir_point_UV[2];
   IGRpoint			min_dist_point;
   struct IGRbsp_surface	*temp_surf_ptr;

   *msg = EMS_S_Success;

   if( ( !direction_point_XYZ && !direction_point_UV ) ||
       ( direction_point_XYZ && direction_point_UV ) )
   {
      *msg = EMS_E_InvalidArg;
      goto wrapup;
   }
   temp_surf_ptr = *new_surface;

   /*
    * If needed, allocated memory for the new surfae.
    */
   if( !temp_surf_ptr )
   {
      u_num_poles = fillet_geom->u_num_poles;
      v_num_poles = fillet_geom->v_num_poles + 2 * fillet_geom->v_order - 1;
      BSallocsf( fillet_geom->u_order, fillet_geom->v_order, u_num_poles,
                 v_num_poles, fillet_geom->rational, ( IGRshort ) 0,
                 &temp_surf_ptr, &msg_loc );
      EMerr_hndlr( msg_loc != BSSUCC, *msg, EMS_E_NoDynamicMemory, wrapup);
   }

   /*
    * If needed, evaluate the direction point UV.
    */
   if( direction_point_XYZ )
   {
      if (fillet_surf_geom)
      {
        IGRdouble       dist_tol;
        IGRint          num_pts = 1;
        IGRboolean      all_on_surf;

        BSEXTRACTPAR( &msg_loc, BSTOLLENVEC, dist_tol );

        BSprptarrsf(fillet_surf_geom, dist_tol, 0, 2, &num_pts,
                    direction_point_XYZ, &local_dir_point_UV[0], NULL,
                    &all_on_surf, NULL, &msg_loc);
        EMerr_hndlr( msg_loc != BSSUCC, *msg, EMS_E_BSerror, wrapup );
      }
      else
      {
        BSmdistptsf( &msg_loc, fillet_geom, direction_point_XYZ,
                     &local_dir_point_UV[0], &local_dir_point_UV[1],
                     min_dist_point, &distance );
        EMerr_hndlr( msg_loc != BSSUCC, *msg, EMS_E_BSerror, wrapup );
      }
   }
   else
      OM_BLOCK_MOVE( direction_point_UV, local_dir_point_UV,
                     2 * sizeof( IGRdouble ) );
   /*
    * Do the extraction, and clean up the new surface.
    */
   BSpartofsf( fillet_geom,
               extent_pts_uv[0][V] < extent_pts_uv[1][V]
               ? extent_pts_uv[0] : extent_pts_uv[1],
               local_dir_point_UV,
               extent_pts_uv[0][V] < extent_pts_uv[1][V]
               ? extent_pts_uv[1] : extent_pts_uv[0],
               ( IGRint ) 1, temp_surf_ptr, &msg_loc );
   EMerr_hndlr( msg_loc != BSSUCC, *msg, EMS_E_BSerror, wrapup );

   /*
    * Normalize the knot vector.
    */
   BSsnorkts( temp_surf_ptr->u_order, temp_surf_ptr->v_order,
              temp_surf_ptr->u_num_poles, temp_surf_ptr->v_num_poles,
              temp_surf_ptr->u_knots, temp_surf_ptr->v_knots,
              ( IGRint ) 1, &msg_loc );
   EMerr_hndlr( msg_loc != BSSUCC, *msg, EMS_E_BSerror, wrapup );

   /*
    * Assign output.
    */
   if( !( *new_surface ) )
      *new_surface = temp_surf_ptr;

wrapup:
   return;
}

static IGRboolean EMget_fillet_edge_intpt (msg, md_env, ed_info, edge, vtx_pt,
                                           uvpt)
IGRlong    *msg;
struct GRmd_env *md_env;
struct EMSedge_rnd_info *ed_info;
GRobjid  edge;
IGRpoint vtx_pt;
IGRdouble uvpt[2];
{
  IGRshort isodir;
  IGRboolean found = FALSE, tst_plan;
  IGRint index, num_int_pts=0;
  IGRuint count = 0;
  IGRlong msg_loc, stat;
  IGRdouble  cht_tol, *int_par1, *int_par2, min_dist, u_val;
  IGRpoint  *int_pts1, *int_pts2, dumpt;
  GRspacenum os;
  GRobjid   comm_edge, edge_sf, comm_edge_sf, proc_edge;
  OM_S_CHANSELECT chan_to_common;
  OM_S_OBJECT_LINKAGE objlist;
  struct IGRbsp_curve  ed_geom, *alloc_crv = NULL;
  struct IGRbsp_surface  *fsrf = NULL;

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht_tol);

  ed_geom.poles = ed_geom.knots = ed_geom.weights = NULL;
  edge_sf = comm_edge_sf = NULL_OBJID;
  os = md_env->md_id.osnum;
  fsrf = ed_info->fill_surf;
  
  edge_sf = NULL_OBJID;
  om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
   &edge_sf, NULL), targetid = edge, targetos = os, senderid = NULL_OBJID);
  EMerr_hndlr (IF_NULL_OBJID (edge_sf), *msg, EMS_E_InvalidCase, wrapup);

  EMmake_chanselect (EMSedge_to_common_edge, &chan_to_common);
  count = 0;
  om$get_channel_objects (objid = edge, osnum = os,
   p_chanselect = &chan_to_common, list = &objlist, size = 1,
   count = &count);
  EMerr_hndlr (!count, *msg, EMS_E_InvalidCase, wrapup);
  comm_edge = objlist.S_objid;

  comm_edge_sf = NULL_OBJID;
  om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
   &comm_edge_sf, NULL), targetid = comm_edge, targetos = os,
   senderid = NULL_OBJID);
  EMerr_hndlr (IF_NULL_OBJID (comm_edge_sf), *msg, EMS_E_InvalidCase, wrapup);

  if (ed_info->surf_id == edge_sf || ed_info->surf_id == comm_edge_sf)
    {
    if (ed_info->surf_id == edge_sf)
      proc_edge = edge;
    else
      proc_edge = comm_edge;
    u_val = 0.0;
    }
  else if (ed_info->com_surf_id == edge_sf ||
           ed_info->com_surf_id == comm_edge_sf)
    {
    if (ed_info->com_surf_id == edge_sf)
      proc_edge = edge;
    else
      proc_edge = comm_edge;
    u_val = 1.0;
    }
  else
    goto wrapup;
  stat = om$send( msg = message EMSedge.EMget_bcxyz_geom (&msg_loc,
                                        &md_env->md_env, NULL, NULL, 0,
                                        MAXINT, FALSE, NULL, &ed_geom),
                              senderid = NULL_OBJID,
                              targetid = proc_edge, targetos = os);
  EMerr_hndlr (!(msg_loc & stat & 1), *msg, EMS_E_EdgeError, wrapup);
  BSalloccv (fsrf->v_order, fsrf->v_num_poles, fsrf->rational, 0,
             &alloc_crv, &msg_loc);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, wrapup);

  tst_plan = TRUE;
  isodir = CONST_U;
  BSconstprcv (&msg_loc, fsrf, &isodir, &u_val, &tst_plan, alloc_crv);
  EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, wrapup);

  BSmdistcvcv (&ed_geom, alloc_crv, &num_int_pts, &int_par1, &int_par2,
               &int_pts1, &int_pts2, &min_dist, &msg_loc);
  if (msg_loc != BSSUCC || num_int_pts == 0)
    found = FALSE;
  else if (min_dist < 2*cht_tol)
    found = TRUE;

  index = 0;
  if (num_int_pts > 1)
  {
    EFfind_the_closest_pt (&msg_loc, (IGRint)3, vtx_pt, num_int_pts, int_pts1,
                           &index, dumpt);
    EMerr_hndlr (!(1 & msg_loc), *msg, EMS_E_Fail, wrapup);
  }
  uvpt[0] = u_val;
  uvpt[1] = int_par2[index];
  *msg = EMS_S_Success;

wrapup:
  if (ed_geom.poles)
    om$dealloc (ptr = ed_geom.poles);
  if (ed_geom.knots)
    om$dealloc (ptr = ed_geom.knots);
  if (ed_geom.weights)
    om$dealloc (ptr = ed_geom.weights);
  return (found);
}

end implementation EMSedge;

