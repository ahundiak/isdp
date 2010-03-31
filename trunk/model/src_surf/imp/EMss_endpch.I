/* ###################   APOGEE COMPILED   ################## */
/*
   gupta : 1987       Creation
   NP    : 08/26/92   Modified for ANSI compliance. Moved declaration of static 
		      functions EMbnd_to_close_loop(), EMbnd_to_close_loop(), 
		      EMdecide_end_condition(), EMmodify_edge_geometry(), 
		      EMclose_fillet_inters(), EMmultiple_end_surface() to global
		      scope.
                      Also, parameters "s1_partol" and "s2_partol" were declared
		      as pointer to IGRdouble, when they should have been  declared 
		      as pointers to "struct EMSpartolbasis" in the static functions
		      EMbnd_to_close_loop() & EMdecide_end_condition(). Corrected it.
   Janaka: 12/08/92   Message sub_system complience.
   Sudha : 07/07/93   Modified for BSprototypes ansification

*/
class implementation EMSsubbs;

#include "EMS.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emsinterdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfint.h"
#include "EMSlmdef.h"
#include "EMSlm.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "emsedgedef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "OMmacros.h"
#include "emsmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "bssfkttol2.h"
#include "bssfeval.h"
#include "bsprptonsf.h"
#include "bsparameters.h"
#include "bsmdistptsf.h"
#include "bsdistptpts.h"

extern GRclassid OPP_EMSdumedge_class_id;

from EMSedge import EMget_plane,
                    EMgetvtxedges,
                    EMget_props,
                    EMget_props_type,
                    EMptproject,
                    EMedge_config,
                    EMpratpt,
                    EMptatpr,
                    EMendpts,
                    EMalter_geometry,
                    EMget_sf_edges,
                    EMextend_geometry;
from EMSloop import EMset_props,
                    EMpt_location;
from EMSboundary import EMget_objid,
                        EMobint,
                        EMgetsurface_info;
from EMSsfround import EMget_boundary_in_model_space,
                       EMreevaluate_geometry;

%safe
static  IGRlong  EMbnd_to_close_loop();
static  IGRlong  EMbnd_to_close_loop();
static  IGRlong  EMdecide_end_condition();
static  IGRlong  EMmodify_edge_geometry();
static  IGRlong  EMclose_fillet_inters();
static  IGRlong  EMmultiple_end_surface();
%endsafe

method EMend_patches (IGRlong                  *EMmsg;
                      struct GRmd_env          *my_env;
                      GRobjid                  *round_id;
                      struct GRvg_construct    *construct_list;
                      struct EMSpartolbasis    *s1_partol,
                                               *s2_partol;
                      struct IGRbsp_surface    *s2;
                      GRobjid                  fillet_id;
                      IGRpoint                 *bpnt;
                      IGRdouble                *params;
                      GRobjid                  *f_edges;
                      struct IGRbsp_curve      *first_arc,
                                               *last_arc;
                      struct EMedge_round_info *my_info;
                      IGRint                   *num_def_info;
                      struct EMdef_con_info    *def_info;
                      IGRint                   *num_pair_info;
                      struct EMedge_con_info   *pair_info;
                      IGRint                   num_round_edges;
                      GRobjid                  *rnd_edge_ids;
                      struct GRid              bnd_edge_ids[])
{
 IGRlong               stat_OM, msg;
 IGRlong               blksize;
 IGRint                j, k, num_ed, edge_end;
 IGRint                index, num_vtx_edges, lp_count;
 IGRint                END_condition, num_entries;
 IGRshort              other_edge_type;
 IGRshort              option, prev_option;
 IGRushort     edprops;
 IGRuchar      curve_type;
 GRclassid             edge_class;
 IGRboolean            world, status,
                       IS_end_needed, trim_vertex,
                       patch_vertex,
                       multiple_intersection,
                       boundary_exists,
                       is_on_boundary[2],
                       onSurf, opt,
                       *right_vtx,
                       edge_ends_free,
                       begin_start,
                       s1_interior;
 IGRboolean            DO_NOT_extend_2;
 IGRdouble             uvbegpt[2], uvendpt[2],
                       cuvbegpt[2], cuvendpt[2],
                       s1end_point[2], s2end_point[2],
                       s1other_param[2], s2other_param[2],
                       d1, d2,
                       end_param[2],
                       ext_param[2],
                       other_uv[2],
                       dist, knot_tol, dist_sqtol;
 IGRpoint              pla_points[3];
 IGRpoint              pnts[2], pt_area;
 IGRpoint              beg_xyz, end_xyz;
 IGRpoint              base_point;
 IGRpoint              points[3];
 GRobjid               next_surf_id, other_surf_id,
                       boundary_edge,
                       edge_ids[2],
                       to_extend_edge,
                       rnd_comm_edge,
                       *vtx_edge_ids,
                       comm_edge,
                       saved_edge, new_edge,
                       dum_own_edge1, dum_own_edge2,
                       com_edge1, com_edge2;
 struct GRid           next_edges[2],
                       edges1,
                       edges2,
                       other_edge,
                       temp_id;
 struct EMSpartolbasis next_surf_tol, fl_partol,
                       other_surf_tol,
                       partol0,
                       partol1;
 struct EMSproj_info   proj_info;
 struct IGRbsp_curve   *edge_geom, *which_arc;
 struct IGRbsp_surface *save_surf, *extended_surface;
 OM_S_CHANSELECT       to_common_edge, to_comps;

/*--------------------------------------------------------------------*/

 stat_OM = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;    

 BSEXTRACTPAR(&msg, BSTOLSQLENVEC, dist_sqtol);

 temp_id.objid = *round_id;
 temp_id.osnum = OM_Gw_current_OS;
 my_info->ends_free = TRUE;
 DO_NOT_extend_2 = FALSE;

 stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
 stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_comps);
 if (! (1 & stat_OM)) goto wrapup;

 stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                         &rnd_comm_edge),
                   senderid = my_info->edge_id,
                   p_chanselect = &to_common_edge);
 EMerr_hndlr (!(1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);

 stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, uvbegpt, uvendpt,
                         NULL,NULL,NULL),
                   targetid = my_info->edge_id);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

 stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, cuvbegpt,
                         cuvendpt, NULL,NULL,NULL),
                   senderid = my_info->edge_id,
                   p_chanselect = &to_common_edge);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

 BSsfeval(my_info->surface, uvbegpt[0], uvbegpt[1], 0, (IGRpoint *)pnts[0], &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 BSsfeval(my_info->surface, uvendpt[0], uvendpt[1], 0, (IGRpoint *)pnts[1], &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 d1 = BSdistptpts(&msg, bpnt[0], pnts[0]);
 d2 = BSdistptpts(&msg, bpnt[0], pnts[1]);
  
 begin_start = (d1<d2) ? TRUE : FALSE;
 prev_option = (d1 < d2) ? EMS_EDGE_BEG_PT : EMS_EDGE_END_PT;

 stat_OM = om$send(msg = message EMSedge.EMget_sf_edges(&msg, prev_option,
                         &next_edges[0], &num_ed),
                   targetid = my_info->edge_id);  
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

 d1 = BSdistptpts(&msg, bpnt[1], pnts[0]);
 d2 = BSdistptpts(&msg, bpnt[1], pnts[1]);
  
 option = (d1 < d2) ? EMS_EDGE_BEG_PT : EMS_EDGE_END_PT;

 /* possibly the fillet is closed for an open edge */

 if (option == prev_option)
  {
   if (prev_option == EMS_EDGE_BEG_PT)
    {
     option = EMS_EDGE_END_PT; d1=2; d2=1;
    }
   else
    {
     option = EMS_EDGE_BEG_PT; d1=1; d2=2;
    }
  }
 
 stat_OM = om$send(msg = message EMSedge.EMget_sf_edges(&msg, option,
                         &next_edges[1], &num_ed),
                   targetid = my_info->edge_id);  
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);
                     
 stat_OM = om$send(msg = message EMSedge.EMget_props_type (&msg, 
                         &edprops, &curve_type),
                   targetid = my_info->edge_id);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);
     
 if (((d1<d2) && (! (edprops & EMED_REVERSE_CONNECT))) ||
     ((d2<d1) && (edprops & EMED_REVERSE_CONNECT)))
      option = EMS_EDGE_END_PT;
 else
      option = EMS_EDGE_BEG_PT;
 prev_option = option;
 blksize = 2*sizeof (IGRdouble);

 for (edge_end=0; edge_end<2; edge_end++)
  {
   num_vtx_edges = 0;
   vtx_edge_ids = NULL;
   right_vtx = NULL;
   trim_vertex = patch_vertex = TRUE;
   multiple_intersection = FALSE;
   com_edge1 = com_edge2 = NULL_OBJID;

   stat_OM = om$send (msg = message EMSedge.EMget_sf_edges(&msg, 
                            option, &other_edge, &num_ed),
                     senderid = my_info->edge_id,
                     p_chanselect = &to_common_edge);  
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

   if (begin_start)
    {
     OM_BLOCK_MOVE (pnts[0], points[2], sizeof (IGRpoint));
     OM_BLOCK_MOVE (uvbegpt, s1end_point, blksize);
     if (option == EMS_EDGE_BEG_PT)
         OM_BLOCK_MOVE (cuvbegpt, s2end_point, blksize);
     else
         OM_BLOCK_MOVE (cuvendpt, s2end_point, blksize);
     begin_start = FALSE;
    }
   else
    {
     OM_BLOCK_MOVE (pnts[1], points[2], sizeof (IGRpoint));
     OM_BLOCK_MOVE (uvendpt, s1end_point, blksize);

     if (option == EMS_EDGE_BEG_PT)
         OM_BLOCK_MOVE (cuvbegpt, s2end_point, blksize);
     else
         OM_BLOCK_MOVE (cuvendpt, s2end_point, blksize);
     begin_start = TRUE;
    }
 
   if (! edge_end)
    {
     s1other_param[0] = params[0]; s1other_param[1] = params[1];
     s2other_param[0] = params[2]; s2other_param[1] = params[3];
     which_arc = first_arc;
    }
   else
    {
     s1other_param[0] = params[4]; s1other_param[1] = params[5];
     s2other_param[0] = params[6]; s2other_param[1] = params[7];
     which_arc = last_arc;
    }

   stat_OM = om$get_classid (objid = next_edges[edge_end].objid,
              p_classid = &edge_class);
   if (! (1 & stat_OM)) goto wrapup;

   if (edge_class == OPP_EMSdumedge_class_id)
    {
     stat_OM = om$send(msg = message EMSedge.EMget_objid(&msg,
                             &dum_own_edge1),
                       senderid = next_edges[edge_end].objid,
                       p_chanselect = &to_comps);
     EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

     stat_OM = EMcount_loops(&msg, dum_own_edge1, &lp_count, NULL,
                             EMLP_ACTIVE, NULL, NULL);
     EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);

     if (lp_count)
         next_edges[edge_end].objid = dum_own_edge1;
    }

   stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                           &com_edge1),
                     senderid = next_edges[edge_end].objid,
                     p_chanselect = &to_common_edge);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   stat_OM = om$get_classid (objid = other_edge.objid,
              p_classid = &edge_class);
   if (! (1 & stat_OM)) goto wrapup;

   if (edge_class == OPP_EMSdumedge_class_id)
    {
     stat_OM = om$send(msg = message EMSedge.EMget_objid(&msg,
                             &dum_own_edge2),
                       senderid = other_edge.objid,
                       p_chanselect = &to_comps);
     EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
 
     stat_OM = EMcount_loops(&msg, dum_own_edge2, &lp_count, NULL,
                             EMLP_ACTIVE, NULL, NULL);
     EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);

     if (lp_count)
         other_edge.objid = dum_own_edge2;
    }

   stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                           &com_edge2),
                     senderid = other_edge.objid,
                     p_chanselect = &to_common_edge);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   edge_ends_free = ((com_edge1==NULL_OBJID)||(com_edge2==NULL_OBJID)) ?
                                                           TRUE : FALSE;

   opt = (option == EMS_EDGE_END_PT) ? TRUE : FALSE;

   stat_OM = om$send(msg = message EMSedge.EMgetvtxedges(&msg,
                           EMSvtxedges_nodegenerate, opt, 0, 
                           &num_vtx_edges, &vtx_edge_ids, &right_vtx),
                     senderid = my_info->edge_id,
                     p_chanselect = &to_common_edge);  
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   num_entries = 0;

   for (j=0; j<num_round_edges; j++)
    {
     for (k=0; k<num_vtx_edges; k++)
      {
       if (IF_EQ_OBJID(rnd_edge_ids[j], vtx_edge_ids[k]))
           num_entries ++;
      }
    }

   {
    IGRlong EMdecide_end_condition();

    EMdecide_end_condition(&msg, my_env, my_info, next_edges[edge_end],
                          other_edge, s1other_param, s2other_param,
                          num_vtx_edges,&num_entries,s1_partol, s2_partol,
                          &s1_interior, edge_ends_free, &other_edge_type, 
                          rnd_comm_edge, &END_condition);
    EMerr_hndlr (! (1 & msg), *EMmsg, msg, wrapup);
   }

NO_intersection_FOUND:

   if (edge_ends_free)
    {
     if ((END_condition == EMS_EXTD_TRIM_VERTEX) ||
         (END_condition == EMS_EXTD_PATCH_VERTEX)) goto composite_case;
    }

   IS_end_needed = (num_entries > 1) ? FALSE : TRUE;

   if((! IS_end_needed)||(com_edge1==NULL_OBJID)||(com_edge2==NULL_OBJID))
    {
     option = (prev_option == EMS_EDGE_BEG_PT) ? EMS_EDGE_END_PT :
                                                  EMS_EDGE_BEG_PT;
     if ((END_condition == EMS_INT_TRIM_VERTEX) ||
         (END_condition == EMS_INT_PATCH_VERTEX))
      {
       IGRlong  EMmodify_edge_geometry();

       stat_OM = EMmodify_edge_geometry(&msg, bnd_edge_ids, s1other_param,
                               s2other_param, my_info->edge_id,
                               rnd_comm_edge, next_edges[edge_end].objid,
                               other_edge.objid, s1end_point, s2end_point,
                               s1_partol, s2_partol);
       EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

       if (edge_ends_free)
        {
         EMtruncate_fillet_surface (&msg, my_env,
                           next_edges[edge_end].objid, my_info->surface,
                           other_edge.objid, s2, my_info, num_pair_info,
                           pair_info, points[2], round_id);
         EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
        }
      }
     if (END_condition == EMS_EXTD_TRIM_VERTEX) trim_vertex = FALSE;
     else
     if ((END_condition == EMS_EXTD_PATCH_VERTEX) &&
         (num_vtx_edges > 6)) patch_vertex = FALSE;
     else 
       {
       if (vtx_edge_ids) om$dealloc (ptr = vtx_edge_ids);
       if (right_vtx) om$dealloc (ptr = right_vtx);
       vtx_edge_ids = NULL;
       right_vtx = NULL;
       continue;
       }
    }

   if ((END_condition != EMS_PATCH_VERTEX) &&
       (END_condition != EMS_INT_PATCH_VERTEX) &&
       (END_condition != EMS_EXTD_PATCH_VERTEX) &&
       (END_condition != EMS_NTRL_PATCH_VERTEX))
    {
     stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                             (&msg, &next_surf_id, NULL),
                       senderid = next_edges[edge_end].objid, 
                       p_chanselect = &to_common_edge);
     EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

     stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                             (&msg, &other_surf_id, NULL),
                       senderid = other_edge.objid, 
                       p_chanselect = &to_common_edge);
     EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

     if (next_surf_id != other_surf_id)
      {
       multiple_intersection = TRUE;
       if (END_condition == EMS_TRIM_VERTEX)
           END_condition = EMS_PATCH_VERTEX;
      }
    }
     
 composite_case:

   if (which_arc->rational)
    {
     for (j=0; j<3; j++)
      {
       points[0][j] = which_arc->poles[j] / which_arc->weights[0];
       points[1][j] = which_arc->poles[3 * (which_arc->num_poles-1) + j] /
                      which_arc->weights[which_arc->num_poles - 1];  
      }
    }
   else
    {
     for (j=0; j<3; j++)
      {
       points[0][j] = which_arc->poles[j];
       points[1][j] = which_arc->poles[3 * (which_arc->num_poles-1) + j];
      }
    }

   if (BSdistptpts (&msg, points[0], points[1]) <= dist_sqtol)
       goto switch_option;

   my_info->ends_free = FALSE;

   if (END_condition == EMS_TRIM_VERTEX)
    {
     if ((edge_end) && (my_info->fillet_modified))
         END_condition = EMS_INT_TRIM_VERTEX;
    }

   switch (END_condition)
    {
     case EMS_NTRL_PATCH_VERTEX:

       ex$message( msgnumb = EMS_S_GenInternalPatch );

       if ((other_edge_type == EMS_NEUTRAL_EDGE) && (num_vtx_edges > 6))
            other_edge_type = EMS_CONCAVE_EDGE;

       stat_OM = om$send (msg = message EMSedge.EMget_plane (&msg,
                                my_env,
                                END_condition,
                                other_edge_type,
                                f_edges,
                                my_info,
                                num_pair_info,
                                pair_info,
                                my_info->surface,
                                s2,
                                points,
                                pla_points,
                                other_edge.objid,
                                &next_surf_id,
                                construct_list,
                                &edges1,
                                is_on_boundary,
                                round_id),
                          targetid = next_edges[edge_end].objid,
                          targetos = next_edges[edge_end].osnum);
       EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError, wrapup);

       if (! edge_end) DO_NOT_extend_2 = TRUE;

       break;

     case EMS_PATCH_VERTEX:

       ex$message( msgnumb = EMS_S_GenEndPatch );

       if (edge_ends_free) 
         {
         if (vtx_edge_ids) om$dealloc (ptr = vtx_edge_ids);
         if (right_vtx) om$dealloc (ptr = right_vtx);
         vtx_edge_ids = NULL;
         right_vtx = NULL;
         continue;
         }

       stat_OM = om$send (msg = message EMSedge.EMget_plane (&msg,
                                my_env,
                                END_condition,
                                other_edge_type,
                                f_edges,
                                my_info,
                                num_pair_info,
                                pair_info,
                                my_info->surface,
                                s2,
                                points,
                                pla_points,
                                other_edge.objid,
                                &next_surf_id,
                                construct_list,
                                &edges1,
                                is_on_boundary,
                                round_id),
                          targetid = next_edges[edge_end].objid,
                          targetos = next_edges[edge_end].osnum);
       EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError, wrapup);

       break;

     case EMS_INT_PATCH_VERTEX:

       ex$message( msgnumb = EMS_S_GenEndPatchWithInt );

       {
        IGRlong EMmodify_edge_geometry();

        stat_OM = EMmodify_edge_geometry(&msg, bnd_edge_ids, s1other_param,
                               s2other_param, my_info->edge_id,
                               rnd_comm_edge, next_edges[edge_end].objid,
                               other_edge.objid, s1end_point, s2end_point,
                               s1_partol, s2_partol);
        EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
       }

       if (edge_ends_free)  
          {
          if (vtx_edge_ids) om$dealloc (ptr = vtx_edge_ids);
          if (right_vtx) om$dealloc (ptr = right_vtx);
          vtx_edge_ids = NULL;
          right_vtx = NULL;
          continue;
          }

       stat_OM = om$send (msg = message EMSedge.EMget_plane (&msg,
                                my_env,
                                END_condition,
                                other_edge_type,
                                f_edges,
                                my_info,
                                num_pair_info,
                                pair_info,
                                my_info->surface,
                                s2,
                                points,
                                pla_points,
                                other_edge.objid,
                                &next_surf_id,
                                construct_list,
                                &edges1,
                                is_on_boundary,
                                round_id),
                          targetid = next_edges[edge_end].objid,
                          targetos = next_edges[edge_end].osnum);
       EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
      
       break;

     case EMS_EXTD_PATCH_VERTEX:

       if (patch_vertex)
           ex$message( msgnumb = EMS_S_ExtFilToGenEndPtch );
 
       BSEXTRACTPAR (&msg, BSTOLKNOT, knot_tol);

       status = BSprptonsf (&msg, my_info->fillet_surface, points[0],
                          &end_param[0], &end_param[1], &onSurf);
       EMerr_hndlr(! status || msg != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
       
       if (! my_info->fillet_modified)
        {
         stat_OM = om$send (msg = message EMSsubbs.EMextend_fillet(&msg,
                                  my_env, my_info->radius, end_param,
                                  my_info->fillet_surface,
                                  &extended_surface),
                            targetid = my_info->fillet_id);
         EMerr_hndlr(!(1 &stat_OM &msg),*EMmsg,EMS_E_SurfaceError,wrapup);

         my_info->fillet_surface = extended_surface;

         if (edge_end == 0)
          {
           ext_param[0] = end_param[0];
           ext_param[1] = (end_param[1] <= knot_tol) ? 1 : 0;

           stat_OM = om$send (msg = message EMSsubbs.EMextend_fillet(&msg,
                                    my_env,
                                    my_info->radius,
                                    ext_param,
                                    my_info->fillet_surface,
                                    &extended_surface),
                              targetid = my_info->fillet_id);
           EMerr_hndlr(!(1&stat_OM&msg),*EMmsg,EMS_E_SurfaceError,wrapup);
           my_info->fillet_surface = extended_surface;
          }
         else
          {
           edge_geom = NULL;

           stat_OM = om$send(
                   msg = message EMSsfround.EMget_boundary_in_model_space(
                         &msg,
                         my_env,
                         my_info->fillet_id,
                         my_info->fillet_surface,
                         &boundary_edge,
                         &edge_geom,
                         pt_area,
                         &index,
                         &boundary_exists),
                   senderid = NULL_OBJID,
                   targetid = *round_id);
           EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

           if (boundary_exists)
            {
             stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis(&msg,
                                      &my_env->md_env.matrix_type,
                                      my_env->md_env.matrix,&world, FALSE,
                                      &fl_partol.tol),
                                senderid = NULL_OBJID,
                                targetid = my_info->fillet_id);
             EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError,
                         wrapup);

             fl_partol.in_world = TRUE;
             fl_partol.is_valid = TRUE;
             fl_partol.mattyp = &my_env->md_env.matrix_type;
             fl_partol.mat = my_env->md_env.matrix;

             stat_OM = om$send(
                       msg = message EMSsfround.EMreevaluate_geometry(
                             &msg,
                             my_env,
                             index,
                             pt_area, 
                             my_info->fillet_id,
                             boundary_edge,
                             edge_geom,
                             my_info->fillet_surface,
                             num_pair_info,
                             pair_info,
                             &fl_partol),
                       senderid = NULL_OBJID,
                       targetid = *round_id);
             EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg, EMS_E_Fail, wrapup);

             if (edge_geom) om$dealloc(ptr = edge_geom);
            }
          }

         my_info->fillet_modified = TRUE;
        }

       if (patch_vertex)
        {
         if (! edge_ends_free)
          {
           stat_OM = om$send (msg = message EMSedge.EMget_plane (&msg,
                                    my_env,
                                    END_condition,
                                    other_edge_type,
                                    f_edges,
                                    my_info,
                                    num_pair_info,
                                    pair_info,
                                    my_info->surface,
                                    s2,
                                    points,
                                    pla_points,
                                    other_edge.objid,
                                    &next_surf_id,
                                    construct_list,
                                    &edges1,
                                    is_on_boundary,
                                    round_id),
                              targetid = next_edges[edge_end].objid,
                              targetos = next_edges[edge_end].osnum);
           EMerr_hndlr(!(1&stat_OM & msg),*EMmsg,EMS_E_EdgeError, wrapup);
          }
         else
          {
           EMtruncate_fillet_surface (&msg, my_env,
                             next_edges[edge_end].objid, my_info->surface,
                             other_edge.objid, s2, my_info, num_pair_info,
                             pair_info, points[2], round_id);
           EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
          }
        }

       if ((curve_type == EMlinesegment)||(curve_type == EMcircular_arc))
            goto proc_over;

       if (! s1_interior)
        {
         status = BSprptonsf (&msg, my_info->fillet_surface, points[1],
                            &end_param[0], &end_param[1], &onSurf);
         EMerr_hndlr(!status || msg!= BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
        }

       stat_OM = EMget_uedge_id (&msg, my_env, end_param[0], knot_tol,
                                 my_info->fillet_id, &to_extend_edge);
       EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);

       stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                               &saved_edge),
                         senderid = to_extend_edge,
                         p_chanselect = &to_common_edge);
       EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

       stat_OM = om$send (msg = message EMSedge.EMextend_geometry(&msg,
                                (s1_interior) ? my_info->edge_id : 
                                                rnd_comm_edge,
                                my_info->fillet_id,
                                (s1_interior) ? my_info->surface_id :
                                                my_info->comm_surface_id,
                                (s1_interior) ? my_info->surface : s2,
                                (s1_interior) ? s1_partol : s2_partol,
                                round_id,
                                my_env),
                          targetid = to_extend_edge);
       EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError, wrapup);
        
       stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                               &new_edge),
                         senderid = saved_edge,
                         p_chanselect = &to_common_edge);
       EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
       
       for (j=0; j<2; j++) 
        {
         if (bnd_edge_ids[j].objid == to_extend_edge)
          {
           bnd_edge_ids[j].objid = new_edge;
           break;
          }
        }

       proc_over:      
       if (! patch_vertex)
           goto switch_option;
       else
           break;

     case EMS_TRIM_VERTEX:
        
       ex$message( msgnumb = EMS_S_TrimmingVertex );
 
       world = TRUE;
       stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg,
                                &my_env->md_env.matrix_type,
                                my_env->md_env.matrix, &world, FALSE,
                                &next_surf_tol.tol),
                          targetid = next_surf_id); 
       EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_SurfaceError,wrapup);
 
       next_surf_tol.in_world = TRUE;
       next_surf_tol.is_valid = TRUE;
       next_surf_tol.mattyp = &my_env->md_env.matrix_type;
       next_surf_tol.mat = my_env->md_env.matrix;

       stat_OM = om$send(msg = message EMSsubbs.EMmake_bsedge_loop(&msg,
                               my_env,
                               NULL,
                               which_arc,
                               &next_surf_tol, 
                               com_edge1,
                               EMS_VERTEX_BND,
                               FALSE,
                               points[2],
                               &edges1,
                               round_id),
                         targetid = next_surf_id);
       EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_SurfaceError,wrapup);

       if (multiple_intersection)
        {
         world = TRUE;
         stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg,
                                  &my_env->md_env.matrix_type,
                                  my_env->md_env.matrix, &world, FALSE,
                                  &other_surf_tol.tol),
                            targetid = other_surf_id); 
         EMerr_hndlr(!(1& stat_OM& msg),*EMmsg,EMS_E_SurfaceError,wrapup);
 
         other_surf_tol.in_world = TRUE;
         other_surf_tol.is_valid = TRUE;
         other_surf_tol.mattyp = &my_env->md_env.matrix_type;
         other_surf_tol.mat = my_env->md_env.matrix;

         stat_OM = om$send(msg = message EMSsubbs.EMmake_bsedge_loop(&msg,
                                 my_env,
                                 NULL,
                                 which_arc,
                                 &other_surf_tol, 
                                 com_edge2,
                                 EMS_VERTEX_BND,
                                 FALSE,
                                 points[2],
                                 &edges2,
                                 round_id),
                           targetid = other_surf_id);
         EMerr_hndlr(!(1 &stat_OM &msg),*EMmsg,EMS_E_SurfaceError,wrapup);
        }

       EMget_twin_edge(&msg, my_info->fillet_surface, points[0],
                       f_edges[1], f_edges[3], FALSE, &comm_edge);
       EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);

       pair_info[*num_pair_info].edge = edges1.objid;
       pair_info[*num_pair_info].comm_edge = comm_edge;
       pair_info[*num_pair_info].edge_surf = next_surf_id;
       pair_info[*num_pair_info].comm_edge_surf = fillet_id;
       pair_info[*num_pair_info].align_normal = FALSE;
       (*num_pair_info)++;

       if (edge_end) goto wrapup;
       else goto switch_option;

     case EMS_INT_TRIM_VERTEX:

       ex$message( msgnumb = EMS_S_TrimmingVtxWithInt );
 
       stat_OM = om$send(msg = message EMSsubbs.EMintersect_surface_fillet
                               (&msg, my_env, points[2], num_pair_info,
                               pair_info, my_info, FALSE, com_edge1,
                               round_id, beg_xyz, end_xyz),
                         targetid = next_surf_id); 
       EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_SurfaceError,wrapup);

       if (msg == EMS_I_NoIntersection)
        {
         END_condition = EMS_NTRL_PATCH_VERTEX;
         goto NO_intersection_FOUND;
        }

       {
        IGRlong EMmultiple_end_surface();

       stat_OM = EMmultiple_end_surface(&msg, my_info->surface, s2,
                            beg_xyz, end_xyz, num_vtx_edges, right_vtx,
                            next_edges[edge_end].objid, other_edge.objid,
                            &multiple_intersection, &other_surf_id);
       EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
       }

       if (multiple_intersection)
        {
         IGRlong    EMclose_fillet_inters();

         stat_OM = om$send(msg=message EMSsubbs.EMintersect_surface_fillet
                               (&msg, my_env, points[2], num_pair_info,
                               pair_info, my_info, FALSE, com_edge2,
                               round_id, beg_xyz, end_xyz),
                           targetid = other_surf_id); 
         EMerr_hndlr(!(1& stat_OM& msg),*EMmsg,EMS_E_SurfaceError,wrapup);

         EMclose_fillet_inters(&msg, num_pair_info, pair_info,
                               my_info->fillet_surface, my_info->surface,
                               s2, my_env);
         EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
        }

        {
          IGRlong   EMmodify_edge_geometry();

       stat_OM = EMmodify_edge_geometry(&msg, bnd_edge_ids, s1other_param,
                               s2other_param, my_info->edge_id,
                               rnd_comm_edge, next_edges[edge_end].objid,
                               other_edge.objid, s1end_point, s2end_point,
                               s1_partol, s2_partol);
       EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
        }

       if (edge_end) goto wrapup;
       else goto switch_option;

     case EMS_EXTD_TRIM_VERTEX:

       if (trim_vertex) ex$message( msgnumb = EMS_S_ExtFilToTrimVtx );
 
       BSEXTRACTPAR (&msg, BSTOLKNOT, knot_tol);

       status = BSprptonsf (&msg, my_info->fillet_surface, points[0],
                          &end_param[0], &end_param[1], &onSurf);
       EMerr_hndlr(! status || msg != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
       
       if (! my_info->fillet_modified)
        {
         save_surf = my_info->fillet_surface;

         stat_OM = om$send (msg = message EMSsubbs.EMextend_fillet(&msg,
                                  my_env,
                                  my_info->radius,
                                  end_param,
                                  my_info->fillet_surface,
                                  &extended_surface),
                            targetid = my_info->fillet_id);
         EMerr_hndlr(!(1 &stat_OM &msg),*EMmsg,EMS_E_SurfaceError,wrapup);

         my_info->fillet_surface = extended_surface;

         if (! DO_NOT_extend_2)
          {
           ext_param[0] = end_param[0];
           ext_param[1] = (end_param[1] <= knot_tol) ? 1 : 0;

           stat_OM = om$send (msg = message EMSsubbs.EMextend_fillet(&msg,
                                    my_env, my_info->radius, ext_param,
                                    my_info->fillet_surface,
                                    &extended_surface),
                              targetid = my_info->fillet_id);
           EMerr_hndlr(!(1&stat_OM&msg),*EMmsg,EMS_E_SurfaceError,wrapup);

           my_info->fillet_surface = extended_surface;
          }

         edge_geom = NULL;

         stat_OM = om$send(
                   msg = message EMSsfround.EMget_boundary_in_model_space(
                         &msg,
                         my_env,
                         my_info->fillet_id,
                         save_surf,
                         &boundary_edge,
                         &edge_geom, 
                         pt_area,
                         &index,
                         &boundary_exists),
                   senderid = NULL_OBJID,
                   targetid = *round_id);
         EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

         if (boundary_exists)
          {
           stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis(&msg,
                                    &my_env->md_env.matrix_type,
                                    my_env->md_env.matrix,&world, FALSE,
                                    &fl_partol.tol),
                              senderid = NULL_OBJID,
                              targetid = my_info->fillet_id);
           EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError,
                       wrapup);

           fl_partol.in_world = TRUE;
           fl_partol.is_valid = TRUE;
           fl_partol.mattyp = &my_env->md_env.matrix_type;
           fl_partol.mat = my_env->md_env.matrix;

           stat_OM = om$send(
                     msg = message EMSsfround.EMreevaluate_geometry(
                           &msg,
                           my_env,
                           index,
                           pt_area, 
                           my_info->fillet_id,
                           boundary_edge,
                           edge_geom,
                           my_info->fillet_surface,
                           num_pair_info,
                           pair_info,
                           &fl_partol),
                     senderid = NULL_OBJID,
                     targetid = *round_id);
           EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg, EMS_E_Fail, wrapup);

           if (edge_geom) om$dealloc(ptr = edge_geom);
          }

         my_info->fillet_modified = TRUE;
        }

       if (! trim_vertex) goto skip_trimming;

       if (! edge_ends_free)
        {
         stat_OM=om$send(msg = message EMSsubbs.EMintersect_surface_fillet
                               (&msg, my_env, points[2], num_pair_info,
                               pair_info, my_info, FALSE, com_edge1,
                               round_id, beg_xyz, end_xyz),
                         targetid = next_surf_id); 
         EMerr_hndlr(!(1& stat_OM& msg),*EMmsg,EMS_E_SurfaceError,wrapup);

         if (msg == EMS_I_NoIntersection)
          {
           END_condition = EMS_NTRL_PATCH_VERTEX;
           goto NO_intersection_FOUND;
          }

         {
            IGRlong EMmultiple_end_surface();

         stat_OM = EMmultiple_end_surface(&msg, my_info->surface, s2,
                             beg_xyz, end_xyz, num_vtx_edges, right_vtx,
                             next_edges[edge_end].objid, other_edge.objid,
                             &multiple_intersection, &other_surf_id);
         EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
         }

         if (multiple_intersection)
          {
           IGRlong  EMclose_fillet_inters();

           stat_OM=om$send(msg=message EMSsubbs.EMintersect_surface_fillet
                               (&msg, my_env, points[2], num_pair_info,
                               pair_info, my_info, FALSE, com_edge2,
                               round_id, beg_xyz, end_xyz),
                           targetid = other_surf_id); 
           EMerr_hndlr(!(1&stat_OM&msg),*EMmsg,EMS_E_SurfaceError,wrapup);

           EMclose_fillet_inters(&msg, num_pair_info, pair_info,
                                my_info->fillet_surface, my_info->surface,
                                s2, my_env);
           EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
          }
        }
       else
        {
         EMtruncate_fillet_surface (&msg, my_env,
                           next_edges[edge_end].objid, my_info->surface,
                           other_edge.objid, s2, my_info, num_pair_info,
                           pair_info, points[2], round_id);
         EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
        }

       skip_trimming:

       if ((curve_type == EMlinesegment)||(curve_type == EMcircular_arc))
            goto proc_over1;

       if (! s1_interior)
        {
         status = BSprptonsf (&msg, my_info->fillet_surface, points[1],
                            &end_param[0], &end_param[1], &onSurf);
         EMerr_hndlr(!status || msg!= BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
        }

       stat_OM = EMget_uedge_id (&msg, my_env, end_param[0], knot_tol,
                                 my_info->fillet_id, &to_extend_edge);
       EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail,wrapup);

       stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                               &saved_edge),
                         senderid = to_extend_edge,
                         p_chanselect = &to_common_edge);
       EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

       stat_OM = om$send (msg = message EMSedge.EMextend_geometry(&msg,
                                (s1_interior) ? my_info->edge_id : 
                                                rnd_comm_edge,
                                my_info->fillet_id,
                                (s1_interior) ? my_info->surface_id :
                                                my_info->comm_surface_id,
                                (s1_interior) ? my_info->surface : s2,
                                (s1_interior) ? s1_partol : s2_partol,
                                round_id,
                                my_env),
                          targetid = to_extend_edge);
       EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError, wrapup);
        
       stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                               &new_edge),
                         senderid = saved_edge,
                         p_chanselect = &to_common_edge);
       EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
       
       for (j=0; j<2; j++) 
        {
         if (bnd_edge_ids[j].objid == to_extend_edge)
          {
           bnd_edge_ids[j].objid = new_edge;
           break;
          }
        }

       proc_over1:
       if (edge_end) goto wrapup;
       else goto switch_option;
     
     default:
       *EMmsg = EMS_E_InvalidArg;
       goto wrapup;

    }

   def_info[*num_def_info].com_edge1 = com_edge1;
   def_info[*num_def_info].c_e1_split = TRUE;
   def_info[*num_def_info].com_edge2 = com_edge2;
   def_info[*num_def_info].c_e2_split = TRUE;
   def_info[*num_def_info].edge_surf[0] = next_surf_id; 

   partol0.is_valid = FALSE;
   partol0.in_world = FALSE;
   partol0.mattyp = &my_env->md_env.matrix_type;
   partol0.mat = my_env->md_env.matrix;

   partol1.is_valid = FALSE;
   partol1.in_world = FALSE;
   partol1.mattyp = &my_env->md_env.matrix_type;
   partol1.mat = my_env->md_env.matrix;

   stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info (&msg,
                           &def_info[*num_def_info].edge_surf[1],
                           &partol0),
                     targetid = def_info[*num_def_info].com_edge1);
   EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info (&msg,
                           &def_info[*num_def_info].edge_surf[2],
                           &partol1),
                       targetid = def_info[*num_def_info].com_edge2);
   EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   def_info[*num_def_info].def_edge = edges1.objid; 
  
   if (END_condition == EMS_NTRL_PATCH_VERTEX)
    {

     stat_OM =  EMbnd_to_close_loop (&msg,
                                     s2,
                                     s1end_point,
                                     s2end_point,
                                     s1other_param,
                                     s2other_param,
                                     pla_points,
                                     s1_partol,
                                     s2_partol,
                                     my_info,
                                     bnd_edge_ids,
                                     round_id,
                                     next_edges[edge_end].objid,
                                     other_edge.objid,
                                     edge_ids,
                                     is_on_boundary);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, msg, wrapup);
    }

   if (! is_on_boundary[0])
    {
     def_info[*num_def_info].com_edge1 = edge_ids[0];
     def_info[*num_def_info].edge_surf[1] = my_info->surface_id;
     def_info[*num_def_info].c_e1_split = FALSE;
    }
   else
    {
     stat_OM = om$send(msg = message EMSsubbs.EMpratmpt(&msg,
                             &my_env->md_env.matrix_type,
                             my_env->md_env.matrix, 1,
                             pla_points[0], other_uv, &dist, base_point),
                       targetid = def_info[*num_def_info].edge_surf[1]);
     EMerr_hndlr(! (1&stat_OM&msg),*EMmsg,EMS_E_SurfaceError, wrapup);

     stat_OM = om$send(msg = message EMSedge.EMptproject (&msg,
                             other_uv, 1, &proj_info,
                             NULL, &partol0),
                       targetid = com_edge1);
     EMerr_hndlr(! (1&stat_OM&msg), *EMmsg, EMS_E_EdgeError, wrapup);

     def_info[*num_def_info].ce1_param.param = proj_info.param.param;
     def_info[*num_def_info].ce1_param.span_inx =
                                            proj_info.param.span_inx;
    }

   if (! is_on_boundary[1])
    {
     def_info[*num_def_info].com_edge2 = edge_ids[1];
     def_info[*num_def_info].edge_surf[2] = my_info->comm_surface_id;
     def_info[*num_def_info].c_e2_split = FALSE;
    }
   else
    {
     stat_OM = om$send(msg = message EMSsubbs.EMpratmpt(&msg,
                             &my_env->md_env.matrix_type,
                             my_env->md_env.matrix, 1,
                             pla_points[1], other_uv, &dist, base_point),
                       targetid = def_info[*num_def_info].edge_surf[2]);
     EMerr_hndlr(! (1&stat_OM&msg),*EMmsg,EMS_E_SurfaceError, wrapup);

     stat_OM = om$send(msg = message EMSedge.EMptproject (&msg,
                             other_uv, 1, &proj_info,
                             NULL, &partol1),
                       targetid = com_edge2);
     EMerr_hndlr(! (1&stat_OM&msg), *EMmsg, EMS_E_EdgeError, wrapup);

     def_info[*num_def_info].ce2_param.param = proj_info.param.param;
     def_info[*num_def_info].ce2_param.span_inx =
                                            proj_info.param.span_inx;
    }

   (*num_def_info)++;

   switch_option:

   option = (prev_option == EMS_EDGE_BEG_PT) ? EMS_EDGE_END_PT :
                                               EMS_EDGE_BEG_PT;
   if (vtx_edge_ids) om$dealloc (ptr = vtx_edge_ids);
   if (right_vtx) om$dealloc (ptr = right_vtx);
  }

UI_status(" ");
wrapup:
  EMWRAPUP (*EMmsg, stat_OM, "EMSsubbs.EMend_patches");
   if (vtx_edge_ids) om$dealloc (ptr = vtx_edge_ids);
   if (right_vtx) om$dealloc (ptr = right_vtx);
  return (stat_OM);
}

static IGRlong EMbnd_to_close_loop(EMmsg, s2, s1end_pt, s2end_pt,
                                   s1other_pt, s2other_pt, pla_points,
                                   s1_partol, s2_partol, my_info,
                                   bnd_edge_ids, round_id, next_edge,
                                   other_edge, edges, is_on_boundary)

IGRlong                  *EMmsg;
struct IGRbsp_surface    *s2;
IGRdouble                s1end_pt[], s2end_pt[];
IGRdouble                s1other_pt[], s2other_pt[];
IGRpoint                 *pla_points;
struct EMSpartolbasis    *s1_partol, *s2_partol;
struct EMedge_round_info *my_info;
struct GRid              *bnd_edge_ids;
GRobjid                  *round_id,
                         next_edge,
                         other_edge,
                         *edges;
IGRboolean               *is_on_boundary;

{
 IGRlong               stat_OM, msg;
 IGRdouble             point_in_area[2],
                       poly_points[4];
 IGRboolean            status, onSurf;
 struct EMSproj_info   proj_info;
 struct IGRpolyline    poly;

 /*------------------------------------------------------------------*/

 stat_OM = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 if (! is_on_boundary[0]) 
  {
   poly_points[0] = s1end_pt[0];
   poly_points[1] = s1end_pt[1];

   status = BSprptonsf (&msg, my_info->surface, pla_points[0],
                        &point_in_area[0], &point_in_area[1], &onSurf);
   EMerr_hndlr(! status || msg != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

   stat_OM = om$send(msg = message EMSedge.EMptproject (&msg,
                           point_in_area, 1, &proj_info, NULL, s1_partol),
                     senderid = NULL_OBJID,
                     targetid = bnd_edge_ids[0].objid);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   poly_points[2] = proj_info.proj_pt[0];
   poly_points[3] = proj_info.proj_pt[1];

   poly.num_points = 2;
   poly.points = &poly_points[0];

   point_in_area[0] = s1other_pt[0];
   point_in_area[1] = s1other_pt[1];

   stat_OM = om$send (msg = message EMSsubbs.EMmake_linedge_loop (&msg,
                            FALSE,
                            &poly,
                            round_id,
                            s1_partol,
                            EMS_EDGE_BND,                            
                            next_edge,
                            &edges[0],
                            point_in_area),
                      senderid = NULL_OBJID,
                      targetid = my_info->surface_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);
  }

 if (! is_on_boundary[1])  
  {
   poly_points[0] = s2end_pt[0];
   poly_points[1] = s2end_pt[1];

   status = BSprptonsf (&msg, s2, pla_points[1], &point_in_area[0],
                        &point_in_area[1], &onSurf);
   EMerr_hndlr(! status || msg != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

   stat_OM = om$send(msg = message EMSedge.EMptproject (&msg,
                           point_in_area, 1, &proj_info, NULL, s2_partol),
                     senderid = NULL_OBJID,
                     targetid = bnd_edge_ids[1].objid);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

   poly_points[2] = proj_info.proj_pt[0];
   poly_points[3] = proj_info.proj_pt[1];

   poly.num_points = 2;
   poly.points = &poly_points[0];

   point_in_area[0] = s2other_pt[0];
   point_in_area[1] = s2other_pt[1];

   stat_OM = om$send (msg = message EMSsubbs.EMmake_linedge_loop (&msg,
                            FALSE,
                            &poly,
                            round_id,
                            s2_partol,
                            EMS_EDGE_BND,
                            other_edge,
                            &edges[1],
                            point_in_area),
                      senderid = NULL_OBJID,
                      targetid = my_info->comm_surface_id);
   EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_SurfaceError, wrapup);
  }
 wrapup:

   EMWRAPUP (*EMmsg, stat_OM, "EMSsubbs.EMbnd_to_close_loop");
   return (stat_OM);
}

static IGRlong EMdecide_end_condition(EMmsg, my_env, my_info, next_edge,
                                      other_edge, s1other_pt, s2other_pt,
                                      num_vtx_edges, num_entries,
                                      s1_partol, s2_partol,
                                      s1_interior, edge_ends_free, 
                                      other_edge_type, rnd_comm_edge,
                                      end_condition)
IGRlong                  *EMmsg;
struct GRmd_env          *my_env;
struct EMedge_round_info *my_info;
struct GRid              next_edge;
struct GRid              other_edge;
IGRdouble                s1other_pt[], s2other_pt[];
IGRint                   num_vtx_edges, *num_entries;
struct EMSpartolbasis    *s1_partol, *s2_partol;
IGRboolean               *s1_interior, edge_ends_free;
IGRshort                 *other_edge_type;
GRobjid                  rnd_comm_edge;
IGRint                   *end_condition;

{
  IGRlong                  stat_OM, msg, msg1;
  IGRint                   EMsend_loops();
  IGRdouble                check_tol;
  IGRshort                 next_edge_type;
  IGRpoint                 point_on_edge;
  struct EMSptloc_info     pt_loc1, pt_loc2;
  IGRvector                av_normal;

 /*------------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (! edge_ends_free)
   {
    check_tol = 0.005;
    stat_OM = om$send(msg = message EMSedge.EMedge_config (&msg, my_env,
                            point_on_edge, my_info->surface_id, NULL,
                            av_normal, NULL, check_tol, &next_edge_type),
                      senderid = NULL_OBJID,
                      targetid = next_edge.objid);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

    stat_OM = om$send(msg = message EMSedge.EMedge_config (&msg, my_env,
                            point_on_edge, my_info->comm_surface_id, NULL,
                            av_normal, NULL, check_tol, other_edge_type),
                      senderid = NULL_OBJID,
                      targetid = other_edge.objid);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
   }
  else
   {
    *end_condition = EMS_TRIM_VERTEX;
    goto further_decision;
   }

  if ((num_vtx_edges <= 6) && ((next_edge_type == EMS_NEUTRAL_EDGE) ||
      (*other_edge_type == EMS_NEUTRAL_EDGE) ||
      (*other_edge_type != next_edge_type)))
   {
      *end_condition = EMS_NTRL_PATCH_VERTEX;
      goto wrapup;
   }
  else
  if (my_info->edge_type == EMS_CONVEX_EDGE)
   {
    if ((next_edge_type == EMS_CONVEX_EDGE) &&
        (*other_edge_type == EMS_CONVEX_EDGE))
      *end_condition = EMS_TRIM_VERTEX;
    else
      *end_condition = EMS_PATCH_VERTEX;
   }
  else
  if (my_info->edge_type == EMS_CONCAVE_EDGE)
   {
    if ((next_edge_type == EMS_CONCAVE_EDGE) &&
       (*other_edge_type == EMS_CONCAVE_EDGE))
        *end_condition = EMS_TRIM_VERTEX;
    else
        *end_condition = EMS_PATCH_VERTEX;
   }
  else
   {
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
   }

 further_decision:

  pt_loc1.location = EMS_L_UNKNWN;
  pt_loc1.options = EMS_PTLOC_ACTLOOP | EMS_PTLOC_BOXCHECK;

  stat_OM = EMsend_loops(&msg,
                         message EMSloop.EMpt_location(&msg1,s1other_pt,
                         &pt_loc1, s1_partol),
                         next_edge.objid, 0, OM_K_MAXINT, EMLP_ACTIVE,
                         NULL, NULL);
  EMerr_hndlr(! (1 & stat_OM & msg & msg1), *EMmsg, EMS_E_LoopError,
              wrapup);

  pt_loc2.location = EMS_L_UNKNWN;
  pt_loc2.options = EMS_PTLOC_ACTLOOP | EMS_PTLOC_BOXCHECK;

  stat_OM = EMsend_loops(&msg,
                         message EMSloop.EMpt_location(&msg1,s2other_pt,
                         &pt_loc2, s2_partol),
                         other_edge.objid, 0, OM_K_MAXINT, EMLP_ACTIVE,
                         NULL, NULL);
  EMerr_hndlr(! (1 & stat_OM & msg & msg1), *EMmsg, EMS_E_LoopError,
              wrapup);

  if (*end_condition == EMS_PATCH_VERTEX)
   {
    if ((pt_loc1.location == EMS_L_INSIDE) &&
        (pt_loc2.location == EMS_L_INSIDE))
     {
      if (num_vtx_edges < 6)
       {
        *end_condition = EMS_EXTD_PATCH_VERTEX;
       }
      else
       {
        *end_condition = EMS_PATCH_VERTEX;
       }
     }
    else 
    if ((pt_loc1.location == EMS_L_OUTSIDE) &&
        (pt_loc2.location == EMS_L_OUTSIDE))
         *end_condition = EMS_INT_PATCH_VERTEX;
    else 
    if ((pt_loc1.location == EMS_L_ONEDGE) &&
        (pt_loc2.location == EMS_L_ONEDGE))
     {
      *end_condition = EMS_EXTD_PATCH_VERTEX;
      if ((pt_loc1.edge[0].edge_id != next_edge.objid) ||
          (pt_loc2.edge[0].edge_id != other_edge.objid))
           *end_condition = EMS_INT_PATCH_VERTEX;
     }
    else 
    if ((pt_loc1.location == EMS_L_OUTSIDE) &&
        (pt_loc2.location == EMS_L_INSIDE) &&
        (pt_loc2.edge[0].edge_id != other_edge.objid) &&
        (pt_loc2.edge[0].edge_id != rnd_comm_edge))
         *end_condition = EMS_INT_PATCH_VERTEX;
    else 
    if ((pt_loc1.location == EMS_L_INSIDE) &&
        (pt_loc2.location == EMS_L_OUTSIDE) &&
        (pt_loc1.edge[0].edge_id != next_edge.objid) &&
        (pt_loc1.edge[0].edge_id != my_info->edge_id))
         *end_condition = EMS_INT_PATCH_VERTEX;
    else 
    if ((pt_loc1.location == EMS_L_OUTSIDE) &&
        (pt_loc2.location == EMS_L_ONEDGE))
     {
      *end_condition = EMS_INT_PATCH_VERTEX;
      if (pt_loc2.edge[0].edge_id != other_edge.objid)
          *end_condition = EMS_NTRL_PATCH_VERTEX;
     }
    else 
    if ((pt_loc1.location == EMS_L_ONEDGE) &&
        (pt_loc2.location == EMS_L_OUTSIDE))
     {
      *end_condition = EMS_INT_PATCH_VERTEX;
      if (pt_loc1.edge[0].edge_id != next_edge.objid)
          *end_condition = EMS_NTRL_PATCH_VERTEX;
     }
    else 
    if ((pt_loc1.location == EMS_L_ONEDGE) &&
        (pt_loc2.location == EMS_L_INSIDE) &&
        (pt_loc1.edge[0].edge_id != next_edge.objid))
     {
      *end_condition = EMS_INT_PATCH_VERTEX;
     }
    else 
    if ((pt_loc1.location == EMS_L_INSIDE) &&
        (pt_loc2.location == EMS_L_ONEDGE) &&
        (pt_loc2.edge[0].edge_id != other_edge.objid))
     {
      *end_condition = EMS_INT_PATCH_VERTEX;
     }
    else 
    if ((pt_loc1.location == EMS_L_ONEDGE) &&
        (pt_loc2.location == EMS_L_INSIDE) &&
        (pt_loc1.edge[0].edge_id == next_edge.objid) &&
        (num_vtx_edges > 6))
     {
      *end_condition = (*num_entries > 1) ? EMS_EXTD_PATCH_VERTEX :
                                            EMS_NTRL_PATCH_VERTEX;
     }
    else 
    if ((pt_loc1.location == EMS_L_INSIDE) &&
        (pt_loc2.location == EMS_L_ONEDGE) &&
        (pt_loc2.edge[0].edge_id == other_edge.objid) &&
        (num_vtx_edges > 6))
     {
      *end_condition = (*num_entries > 1) ? EMS_EXTD_PATCH_VERTEX :
                                            EMS_NTRL_PATCH_VERTEX;
     }
    else
     {
      *end_condition = EMS_EXTD_PATCH_VERTEX;
      if (pt_loc1.location == EMS_L_INSIDE)
          *s1_interior = TRUE;
      else
          *s1_interior = FALSE;
     }
   }
  else if (*end_condition == EMS_TRIM_VERTEX)
   {
    if ((pt_loc1.location == EMS_L_INSIDE) &&
        (pt_loc2.location == EMS_L_INSIDE))
     {
      if (num_vtx_edges < 6)
       {
        *end_condition = EMS_EXTD_TRIM_VERTEX;
       }
      else
       {
        *end_condition = EMS_PATCH_VERTEX;
       }
     }
    else 
    if ((pt_loc1.location == EMS_L_OUTSIDE) &&
        (pt_loc2.location == EMS_L_OUTSIDE))
     {
      if ((next_edge_type == EMS_CONCAVE_EDGE) &&
          (*other_edge_type == EMS_CONCAVE_EDGE))
           *end_condition = EMS_INT_PATCH_VERTEX;
      else
           *end_condition = EMS_INT_TRIM_VERTEX;
     }
    else 
    if ((pt_loc1.location == EMS_L_ONEDGE) &&
        (pt_loc2.location == EMS_L_ONEDGE))
     {
      *end_condition = EMS_EXTD_TRIM_VERTEX;
      if ((pt_loc1.edge[0].edge_id != next_edge.objid) ||
          (pt_loc2.edge[0].edge_id != other_edge.objid))
           *end_condition = EMS_INT_TRIM_VERTEX;
     }
    else 
    if ((pt_loc1.location == EMS_L_OUTSIDE) &&
        (pt_loc2.location == EMS_L_INSIDE) &&
        (pt_loc2.edge[0].edge_id != other_edge.objid) &&
        (pt_loc2.edge[0].edge_id != rnd_comm_edge))
         *end_condition = EMS_INT_TRIM_VERTEX;
    else 
    if ((pt_loc1.location == EMS_L_INSIDE) &&
        (pt_loc2.location == EMS_L_OUTSIDE) &&
        (pt_loc1.edge[0].edge_id != next_edge.objid) &&
        (pt_loc1.edge[0].edge_id != my_info->edge_id))
         *end_condition = EMS_INT_TRIM_VERTEX;
    else 
    if ((pt_loc1.location == EMS_L_OUTSIDE) &&
        (pt_loc2.location == EMS_L_ONEDGE))
         *end_condition = EMS_INT_TRIM_VERTEX;
    else 
    if ((pt_loc1.location == EMS_L_ONEDGE) &&
        (pt_loc2.location == EMS_L_OUTSIDE))
         *end_condition = EMS_INT_TRIM_VERTEX;
    else 
    if ((pt_loc1.location == EMS_L_ONEDGE) &&
        (pt_loc2.location == EMS_L_INSIDE) &&
        (pt_loc1.edge[0].edge_id != next_edge.objid))
         *end_condition = EMS_INT_TRIM_VERTEX;
    else 
    if ((pt_loc1.location == EMS_L_INSIDE) &&
        (pt_loc2.location == EMS_L_ONEDGE) &&
        (pt_loc2.edge[0].edge_id != other_edge.objid))
         *end_condition = EMS_INT_TRIM_VERTEX;
    else
     {
      *end_condition = (my_info->fillet_surface->v_phy_closed) ?
                        EMS_INT_TRIM_VERTEX : EMS_EXTD_TRIM_VERTEX;
      if (pt_loc1.location == EMS_L_INSIDE)
          *s1_interior = TRUE;
      else
          *s1_interior = FALSE;
     }
   }

 wrapup:
   EMWRAPUP (*EMmsg, stat_OM, "EMSsubbs.EMdecide_end_condition");
   return (stat_OM);
}

static IGRlong  EMmodify_edge_geometry(EMmsg, bnd_edge_ids, s1_param,
                                     s2_param, my_edge, comm_edge, 
                                     next_edge, comm_next_edge,
                                     s1end_point, s2end_point, s1_partol,
                                     s2_partol)
IGRlong               *EMmsg;
struct GRid           bnd_edge_ids[];
IGRdouble             s1_param[2], s2_param[2];
GRobjid               my_edge, comm_edge;
GRobjid               next_edge, comm_next_edge;
IGRdouble             s1end_point[], s2end_point[];
struct EMSpartolbasis *s1_partol, *s2_partol;

{
 IGRlong              stat_OM, msg;
 IGRushort    edge_prop;
 IGRint               num_inters;
 IGRboolean           at_stop, off_edge;
 IGRdouble            my_parms[2];
 struct EMSproj_info  proj_info;
 struct EMSedgebound  end_param, bound[2], mid_param;
 struct EMSsfintedpar *rt_inters, *inters1, *inters2;
 void                 EMsfintedpar_free();

 /*------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 num_inters = 0;
 inters1 = NULL;
 inters2 = NULL;

 stat_OM = om$send (msg = message EMSboundary.EMobint (&msg, s1_partol,
                          bnd_edge_ids[0].objid, s1_partol,
                          EMS_INTER_CUTTING,
                          &num_inters, &inters1,
                          &inters2),
                    senderid = NULL_OBJID,
                    targetid = next_edge); 
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
 EMerr_hndlr (num_inters > 2, *EMmsg, EMS_E_InvalidArg, wrapup);
 
 rt_inters = inters2;
 if (num_inters > 1)
  {
   if (EM2ddistptpts(inters2->next->point, s1end_point) <
       EM2ddistptpts(inters2->point, s1end_point))
       rt_inters = inters2->next;
  }

 if ((num_inters) && (rt_inters->intloc == EMScvint_middle))
  {
   stat_OM = om$send (msg = message EMSedge.EMpratpt(&msg, s1_param, 1,
                            &end_param, &off_edge, NULL, s1_partol),
                      senderid = NULL_OBJID,
                      targetid = bnd_edge_ids[0].objid);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

   if ((end_param.span_inx > rt_inters->edgepar.span_inx) ||
      ((end_param.span_inx == rt_inters->edgepar.span_inx) &&
      (end_param.param > rt_inters->edgepar.param)))
      at_stop = TRUE;
   else
      at_stop = FALSE;

   stat_OM = om$send(msg = message EMSedge.EMget_props(&msg, &edge_prop),
                     senderid = NULL_OBJID,
                     targetid = bnd_edge_ids[0].objid);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

   if (edge_prop & EMED_XYZ_CLOSED)
    {
     stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, NULL, NULL,
                             bound, &bound[1], NULL),
                       senderid = NULL_OBJID,
                       targetid = my_edge); 
     EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

     if (bound[0].span_inx == bound[1].span_inx)
         mid_param.span_inx = bound[0].span_inx;
     else
         mid_param.span_inx =
                      (IGRint) (bound[0].span_inx + bound[1].span_inx)/2;

     mid_param.param = (bound[0].param + bound[1].param) / 2;

     stat_OM = om$send(msg = message EMSedge.EMptatpr(&msg, 1, &mid_param,
                             NULL, my_parms),
                       senderid = NULL_OBJID,
                       targetid = my_edge);
     EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

     stat_OM = om$send(msg = message EMSedge.EMptproject (&msg, my_parms,
                             1, &proj_info, NULL, s1_partol),
                       senderid = NULL_OBJID,
                       targetid = bnd_edge_ids[0].objid);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

     if ((rt_inters->edgepar.span_inx > proj_info.param.span_inx) ||
        ((rt_inters->edgepar.span_inx == proj_info.param.span_inx) &&
        (rt_inters->edgepar.param > proj_info.param.param)))
         at_stop = TRUE;
     else
         at_stop = FALSE;
    }

   stat_OM = om$send (msg = message EMSedge.EMalter_geometry (&msg,
                            &rt_inters[0], at_stop),
                      senderid = NULL_OBJID,
                      targetid = bnd_edge_ids[0].objid); 
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

   if (inters1) EMsfintedpar_free (inters1, NULL);
   if (inters2) EMsfintedpar_free (inters2, NULL);
  }
 else
  *EMmsg = EMS_I_NoIntersection;

 num_inters = 0;
 inters1 = NULL;
 inters2 = NULL;
 
 stat_OM = om$send (msg = message EMSboundary.EMobint (&msg, s2_partol,
                          bnd_edge_ids[1].objid, s2_partol,
                          EMS_INTER_CUTTING,
                          &num_inters, &inters1,
                          &inters2),
                    senderid = NULL_OBJID,
                    targetid = comm_next_edge); 
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
 EMerr_hndlr (num_inters > 2, *EMmsg, EMS_E_InvalidArg, wrapup);

 rt_inters = inters2;
 if (num_inters > 1)
  {
   if (EM2ddistptpts(inters2->next->point, s2end_point) <
       EM2ddistptpts(inters2->point, s2end_point))
       rt_inters = inters2->next;
  }
 
 if ((num_inters) && (rt_inters->intloc == EMScvint_middle))
  {
   stat_OM = om$send (msg = message EMSedge.EMpratpt(&msg, s2_param, 1,
                            &end_param, &off_edge, NULL, s2_partol),
                      senderid = NULL_OBJID,
                      targetid = bnd_edge_ids[1].objid);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

   if ((end_param.span_inx > rt_inters->edgepar.span_inx) ||
      ((end_param.span_inx == rt_inters->edgepar.span_inx) &&
      (end_param.param > rt_inters->edgepar.param)))
      at_stop = TRUE;
   else
      at_stop = FALSE;

   stat_OM = om$send(msg = message EMSedge.EMget_props(&msg, &edge_prop),
                     senderid = NULL_OBJID,
                     targetid = bnd_edge_ids[1].objid);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

   if (edge_prop & EMED_XYZ_CLOSED)
    {
     stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, NULL, NULL,
                             bound, &bound[1], NULL),
                       senderid = NULL_OBJID,
                       targetid = comm_edge); 
     EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

     if (bound[0].span_inx == bound[1].span_inx)
         mid_param.span_inx = bound[0].span_inx;
     else
         mid_param.span_inx =
                      (IGRint) (bound[0].span_inx + bound[1].span_inx)/2;

     mid_param.param = (bound[0].param + bound[1].param) / 2;

     stat_OM = om$send(msg = message EMSedge.EMptatpr(&msg, 1, &mid_param,
                             NULL, my_parms),
                       senderid = NULL_OBJID,
                       targetid = comm_edge);
     EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

     stat_OM = om$send(msg = message EMSedge.EMptproject (&msg, my_parms,
                             1, &proj_info, NULL, s2_partol),
                       senderid = NULL_OBJID,
                       targetid = bnd_edge_ids[1].objid);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

     if ((rt_inters->edgepar.span_inx > proj_info.param.span_inx) ||
        ((rt_inters->edgepar.span_inx == proj_info.param.span_inx) &&
        (rt_inters->edgepar.param > proj_info.param.param)))
         at_stop = TRUE;
     else
         at_stop = FALSE;
    }

   stat_OM = om$send (msg = message EMSedge.EMalter_geometry (&msg,
                            &rt_inters[0], at_stop),
                      senderid = NULL_OBJID,
                      targetid = bnd_edge_ids[1].objid); 
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

   if (inters1) EMsfintedpar_free (inters1, NULL);
   if (inters2) EMsfintedpar_free (inters2, NULL);
  }
 else
  *EMmsg = EMS_I_NoIntersection;

 wrapup:
   EMWRAPUP (*EMmsg, stat_OM, "EMSsubbs.EMmodify_edge_geometry");
   return (stat_OM);
}

static IGRlong  EMclose_fillet_inters(EMmsg, num_pair_info, pair_info,
                                      fillet_surface, s1, s2, my_env)

IGRlong                  *EMmsg;
IGRint                   *num_pair_info;
struct EMedge_con_info   *pair_info;
struct IGRbsp_surface    *fillet_surface, *s1, *s2;
struct GRmd_env          *my_env;
{
 IGRlong               stat_OM, msg;
 IGRboolean            at_stop1, at_stop2;
 IGRboolean            status;
 IGRdouble             uvbegpt1[2], uvendpt1[2],
                       uvbegpt2[2], uvendpt2[2];
 IGRdouble             param[2];
 IGRdouble             chdht_tol, knot_tol, dist;
 IGRpoint              base_point, end_point;
 struct GRid           trim_edge1, trim_edge2, loop1, loop2;
 struct EMSdataselect  intdata1, intdata2;
 struct EMSdataselect  fillet_data;
 struct EMSpartolbasis fillet_partol;
 OM_S_CHANSELECT       to_edges, to_owner;

 /*------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 BSEXTRACTPAR(&msg, BSTOLCHRDHT, chdht_tol);
 BSEXTRACTPAR(&msg, BSTOLKNOT, knot_tol);

 stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
 stat_OM = EMmake_chanselect (EMSedge_to_owner, &to_owner);
 if (! (1 & stat_OM)) goto wrapup;

 stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, uvbegpt1,
                         uvendpt1, NULL, NULL, NULL),
                   senderid = NULL_OBJID,
                   targetid = pair_info[(*num_pair_info)-2].comm_edge);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

 stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, uvbegpt2,
                         uvendpt2, NULL, NULL, NULL),
                   senderid = NULL_OBJID,
                   targetid = pair_info[(*num_pair_info)-1].comm_edge);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

 BSsfeval(fillet_surface, uvbegpt1[0], uvbegpt1[1], 0, (IGRpoint *)end_point, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 status = BSmdistptsf (&msg, s1, end_point, &param[0], &param[1],
                       base_point, &dist);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 at_stop1 = (dist <= 2 * chdht_tol) ? TRUE : FALSE;

 BSsfeval(fillet_surface, uvbegpt2[0], uvbegpt2[1], 0, (IGRpoint *)end_point, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 status = BSmdistptsf (&msg, s2, end_point, &param[0], &param[1],         
                       base_point, &dist);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 at_stop2 = (dist <= 2 * chdht_tol) ? TRUE : FALSE;

 trim_edge1.objid = pair_info[(*num_pair_info)-2].comm_edge;
 trim_edge1.osnum = my_env->md_id.osnum;

 trim_edge2.objid = pair_info[(*num_pair_info)-1].comm_edge;
 trim_edge2.osnum = my_env->md_id.osnum;

 intdata1.datatype = EMSdata_object;
 intdata2.datatype = EMSdata_object;

 intdata1.data.object = &trim_edge1;
 intdata2.data.object = &trim_edge2;

 BSsfkttol2(fillet_surface->u_order, fillet_surface->v_order,
            fillet_surface->u_knots, fillet_surface->v_knots,
            fillet_surface->u_num_poles, fillet_surface->v_num_poles,
            fillet_surface->poles, fillet_surface->weights,
            &fillet_partol.tol, &msg);
 EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 fillet_partol.is_valid = TRUE;
 fillet_partol.in_world = TRUE;
 fillet_partol.mattyp = &my_env->md_env.matrix_type;
 fillet_partol.mat = my_env->md_env.matrix;

 fillet_data.datatype = EMSdata_surface;
 fillet_data.data.surface = fillet_surface;

 stat_OM = EMextend_intdata (&msg, &intdata1, &intdata2, at_stop1, 
                             at_stop2, &fillet_partol, NULL, &fillet_data,
                             my_env->md_env.matrix, 
                             &my_env->md_env.matrix_type);
 EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

 stat_OM = om$get_objid_at_index(
                        objid = pair_info[(*num_pair_info)-2].comm_edge,
                        p_chanselect = &to_owner,
                        index = 0,
                        objidaddr = &loop1.objid,
                        osnumaddr = &loop1.osnum);
 EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

 stat_OM = om$get_objid_at_index(
                        objid = pair_info[(*num_pair_info)-1].comm_edge,
                        p_chanselect = &to_owner,
                        index = 0,
                        objidaddr = &loop2.objid,
                        osnumaddr = &loop2.osnum);
 EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

 stat_OM = om$send (msg = message Root.disconnect (to_owner,
                          loop2.objid, loop2.osnum,
                          to_edges),
                    senderid = NULL_OBJID,
                    targetid = pair_info[(*num_pair_info)-1].comm_edge);
 if (! (1 & stat_OM)) goto wrapup;

 stat_OM = om$send (msg = message Root.connect (to_owner,
                          1, loop1.objid, loop1.osnum,
                          to_edges, NULL),
                    senderid = NULL_OBJID,
                    targetid = pair_info[(*num_pair_info)-1].comm_edge);
 if (! (1 & stat_OM)) goto wrapup;

 stat_OM = om$send(msg = message EMSloop.EMset_props(&msg,
                         EMLP_ACTIVE, EMS_O_OFF),
                   senderid = NULL_OBJID,
                   targetid = loop2.objid);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);

 wrapup:
   EMWRAPUP (*EMmsg, stat_OM, "EMSsubbs.EMclose_fillet_inters");
   return (stat_OM);
}

static IGRlong  EMmultiple_end_surface(EMmsg, s1, s2, beg_xyz, end_xyz,
                               num_vtx_edges, right_vtx, next_edge,
                               other_edge, multiple_intersection,
                               other_surf_id)

IGRlong                  *EMmsg;
struct IGRbsp_surface    *s1, *s2;
IGRpoint                 beg_xyz, end_xyz;
IGRboolean               *right_vtx;
IGRint                   num_vtx_edges;
GRobjid                  next_edge, other_edge;
IGRboolean               *multiple_intersection;
GRobjid                  *other_surf_id;

{
 IGRlong               stat_OM, msg;
 IGRint                num_edg;
 IGRboolean            status;
 IGRboolean            my_surf_OK, other_surf_OK;
 IGRdouble             chdht_tol;
 IGRdouble             param[2];
 IGRdouble             dist;
 IGRpoint              base_point;
 struct GRid           adj_edges[2];
 OM_S_CHANSELECT       to_common_edge;

 /*------------------------------------------------------------------*/

 if (*multiple_intersection) return (OM_S_SUCCESS);

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;
 my_surf_OK = FALSE;
 other_surf_OK = FALSE;

 stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);

 BSEXTRACTPAR(&msg, BSTOLCHRDHT, chdht_tol);

 status = BSmdistptsf (&msg, s1, beg_xyz, &param[0], &param[1],
                       base_point, &dist);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (dist <= chdht_tol)
  {
   my_surf_OK = TRUE;
  }
 else
  {
   status = BSmdistptsf (&msg, s1, end_xyz, &param[0], &param[1],
                         base_point, &dist);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   if (dist <= chdht_tol)
       my_surf_OK = TRUE;
  }

 status = BSmdistptsf (&msg, s2, end_xyz, &param[0], &param[1],
                       base_point, &dist);
 EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

 if (dist <= chdht_tol)
  {
   other_surf_OK = TRUE;
  }
 else
  {
   status = BSmdistptsf (&msg, s2, beg_xyz, &param[0], &param[1],
                         base_point, &dist);
   EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   if (dist <= chdht_tol)
       other_surf_OK = TRUE;
  }

 if (! my_surf_OK && ! other_surf_OK) return (OM_S_SUCCESS);

 if (! my_surf_OK)
  {
   *multiple_intersection = TRUE;

   stat_OM = om$send(msg = message EMSedge.EMget_sf_edges(&msg,
                       (right_vtx[0]) ? EMS_EDGE_END_PT : EMS_EDGE_BEG_PT,
                       &adj_edges[0], &num_edg),
                     senderid = NULL_OBJID,
                     targetid = next_edge);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

   stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                           (&msg, other_surf_id, NULL),
                     senderid = adj_edges[0].objid, 
                     p_chanselect = &to_common_edge);
   EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
  }

 if (! other_surf_OK)
  {
   *multiple_intersection = TRUE;

   stat_OM = om$send(msg = message EMSedge.EMget_sf_edges(&msg,
                       (right_vtx[num_vtx_edges-1]) ? EMS_EDGE_END_PT :
                                                      EMS_EDGE_BEG_PT,
                       &adj_edges[0], &num_edg),
                     senderid = NULL_OBJID,
                     targetid = other_edge);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

   stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                           (&msg, other_surf_id, NULL),
                     senderid = adj_edges[0].objid, 
                     p_chanselect = &to_common_edge);
   EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
  }

 wrapup:
   EMWRAPUP (*EMmsg, stat_OM, "EMSsubbs.EMmultiple_end_surface");
   return (stat_OM);
}

end implementation EMSsubbs;
